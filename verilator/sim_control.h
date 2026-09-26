#ifndef SIM_CONTROL_H
#define SIM_CONTROL_H

#include <cerrno>
#include <cstdint>
#include <cstring>
#include <deque>
#include <limits>
#include <sstream>
#include <string>
#ifndef _WIN32
#include <fcntl.h>
#include <sys/stat.h>
#include <unistd.h>
#endif

// Optional local, newline-delimited control stream. No input is opened or
// event emitted by construction. All clocks below are simulated rising edges.
struct SimControlCommand {
	enum Kind { Down, Up, Wait, Shot, ProfileStart, ProfileStop, RamDump, Quit } kind;
	uint64_t value = 0;
	bool extended = false;
};

class SimControl {
public:
	static constexpr size_t QueueLimit = 64, LineLimit = 160;
	SimControl() = default;
	SimControl(const SimControl&) = delete;
	SimControl& operator=(const SimControl&) = delete;
	~SimControl() {
#ifndef _WIN32
		if (fd_ >= 0) ::close(fd_);
#endif
	}
	bool open(const std::string& path, std::string& error) {
#ifndef _WIN32
		const int fd = ::open(path.c_str(), O_RDONLY | O_NONBLOCK | O_CLOEXEC);
		if (fd < 0) { error = std::strerror(errno); return false; }
		struct stat st;
		if (::fstat(fd, &st) < 0) {
			error = std::strerror(errno); ::close(fd); return false;
		}
		if (!S_ISREG(st.st_mode) && !S_ISFIFO(st.st_mode)) {
			error = "control path must be a regular file or FIFO";
			::close(fd); return false;
		}
		if (fd_ >= 0) ::close(fd_);
		fd_ = fd;
		return true;
#else
		(void)path;
		error = "--control requires POSIX nonblocking local files/FIFOs";
		return false;
#endif
	}
	bool enabled() const { return fd_ >= 0; }
	size_t queued() const { return queue_.size(); }
	size_t rejected() const { return rejected_; }
	const std::string& read_error() const { return read_error_; }

	// Bounded byte ingestion, also used by deterministic parser tests. Return
	// consumed bytes so a full command queue never loses buffered input.
	size_t feed(const char* data, size_t count) {
		size_t used = 0;
		while (used < count && queue_.size() < QueueLimit) {
			const char ch = data[used++];
			if (ch == '\n') {
				if (!discard_line_) parse_line();
				line_.clear(); discard_line_ = false;
			} else if (!discard_line_) {
				if (line_.size() == LineLimit) {
					++rejected_; line_.clear(); discard_line_ = true;
				} else line_ += ch;
			}
		}
		return used;
	}

	void poll() {
#ifndef _WIN32
		if (fd_ < 0) return;
		size_t budget = 1024;
		while (budget && queue_.size() < QueueLimit) {
			if (input_pos_ == input_size_) {
				const ssize_t n = ::read(fd_, input_, sizeof(input_));
				if (n < 0 && errno != EAGAIN && errno != EWOULDBLOCK && errno != EINTR)
					read_error_ = std::strerror(errno);
				// EOF leaves the descriptor and partial line intact: regular
				// files can be appended, FIFO writers can disconnect/reconnect.
				if (n <= 0) break;
				input_pos_ = 0; input_size_ = static_cast<size_t>(n);
			}
			const size_t remaining = input_size_ - input_pos_;
			const size_t used = feed(input_ + input_pos_, remaining < budget ? remaining : budget);
			input_pos_ += used; budget -= used;
			if (!used) break;
		}
#endif
	}

	// Service once before each rising-edge eval. Poll at most once per 16384
	// clocks, accept at most one command per clock, and wait for the existing
	// key queue/pacing timer before starting the next command. Wait N inserts
	// N complete idle clocks after the wait command's acceptance clock.
	bool step(bool paused, bool keys_ready, SimControlCommand& command) {
		if ((poll_ticks_++ & 16383U) == 0) poll();
		if (paused) return false;
		if (wait_left_) { --wait_left_; return false; }
		if (!keys_ready || queue_.empty()) return false;
		command = queue_.front(); queue_.pop_front();
		if (command.kind == SimControlCommand::Wait) wait_left_ = command.value;
		return true;
	}

private:
	static bool number(const std::string& text, unsigned base, uint64_t& value) {
		size_t i = 0;
		if (base == 16 && text.size() > 2 && text[0] == '0' &&
		    (text[1] == 'x' || text[1] == 'X')) i = 2;
		if (i == text.size()) return false;
		value = 0;
		for (; i < text.size(); ++i) {
			const char ch = text[i];
			const unsigned digit = ch >= '0' && ch <= '9' ? unsigned(ch - '0') :
				ch >= 'a' && ch <= 'f' ? unsigned(ch - 'a' + 10) :
				ch >= 'A' && ch <= 'F' ? unsigned(ch - 'A' + 10) : 99;
			if (digit >= base || value > (std::numeric_limits<uint64_t>::max() - digit) / base)
				return false;
			value = value * base + digit;
		}
		return true;
	}
	void parse_line() {
		const auto comment = line_.find('#');
		std::istringstream in(line_.substr(0, comment));
		std::string op, arg, ext, extra;
		if (!(in >> op)) return;
		SimControlCommand command{};
		bool valid = false;
		if (op == "down" || op == "up") {
			command.kind = op == "down" ? SimControlCommand::Down : SimControlCommand::Up;
			if ((in >> arg) && number(arg, 16, command.value) && command.value <= 255) {
				if (!(in >> ext)) valid = true;
				else if (ext == "ext" && !(in >> extra)) { command.extended = true; valid = true; }
			}
		} else if (op == "wait") {
			command.kind = SimControlCommand::Wait;
			valid = bool(in >> arg) && number(arg, 10, command.value) && !(in >> extra);
		} else if (op == "ramdump") {
            command.kind = SimControlCommand::RamDump;
            valid = bool(in >> arg) && number(arg, 10, command.value) &&
                    command.value >= 1 && command.value <= 128 && !(in >> extra);
        } else if (op == "shot") {
			command.kind = SimControlCommand::Shot;
			valid = !(in >> extra);
		} else if (op == "quit") {
			command.kind = SimControlCommand::Quit;
			valid = !(in >> extra);
		} else if (op == "profile") {
			if ((in >> arg) && (arg == "start" || arg == "stop") && !(in >> extra)) {
				command.kind = arg == "start" ? SimControlCommand::ProfileStart : SimControlCommand::ProfileStop;
				valid = true;
			}
		}
		if (valid) queue_.push_back(command);
		else ++rejected_;
	}
	int fd_ = -1;
	uint32_t poll_ticks_ = 0;
	uint64_t wait_left_ = 0;
	size_t rejected_ = 0, input_pos_ = 0, input_size_ = 0;
	bool discard_line_ = false;
	std::string line_, read_error_;
	std::deque<SimControlCommand> queue_;
	char input_[512];
};

#endif
