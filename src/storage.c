#include "storage.h"
#include "printf.h"

#define FLASH_BUFFER_SIZE            (FLASH_PAGE_SIZE)
#define APP_SIGNATURE                "ATMEL SAMD21"
//! Size of signature in bytes
#define APP_SIGNATURE_SIZE           12
//! Size of CRC32 in bytes
#define APP_CRC_SIZE                 4


volatile uint8_t buffer[FLASH_BUFFER_SIZE];

static FIL file_object1;
const char* input_file_name = "INFO_UF2.TXT";

void derp() {
    my_printf("Inside Derp");
    uint32_t address_offset = 0;
	uint32_t buffer_size = 0;

    buffer_size = APP_CRC_SIZE + APP_SIGNATURE_SIZE;

   
    f_open(&file_object1, (char const *)input_file_name, FA_OPEN_EXISTING | FA_READ);

    /* Seek the file pointer to the current address offset */
    f_lseek(&file_object1, address_offset);

    /* Read the data from the firmware */
    f_read(&file_object1, (uint8_t *)buffer, FLASH_BUFFER_SIZE, (UINT*)&buffer_size);

    /* Check if there is any buffer */
    if (!buffer_size) {
            my_printf("Buffer is zero");

        /* Close the open file */
        f_close(&file_object1);
        /* Break out of the loop */
    } else {
            my_printf("printing buffer");

        my_printf((char*)&buffer);
    }

    /* Close the input file */
    f_close(&file_object1);
}