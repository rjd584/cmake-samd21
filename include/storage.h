#include <samd21.h>
#include <diskio.h>
#include <ff.h>
#include <ffconf.h>
#include <integer.h>

#define NVM_BASE_ADDRESS 0x00000000
#define EEPROM_PAGE_SIZE 64
#define EEPROM_ROW_SIZE (4 * EEPROM_PAGE_SIZE)
#define NO_OF_ROWS 1
#define EEPROM_SIZE (NO_OF_ROWS * EEPROM_ROW_SIZE)
#define NVM_SIZE (128*1024)
#define EEPROM_STORAGE_START (NVM_BASE_ADDRESS + NVM_SIZE - EEPROM_SIZE)

void derp();