// Simulation stand-in for Main_MiSTer's spi.h: the SPI transfer is not
// modelled (the bench moves the block bytes itself).
#ifndef SPI_H
#define SPI_H

#include <stdint.h>

void     EnableIO();
void     DisableIO();
uint16_t spi_w(uint16_t word);
void     spi_block_read(uint8_t *addr, int wide, int sz = 512);
void     spi_block_write(const uint8_t *addr, int wide, int sz = 512);

#endif
