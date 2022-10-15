#include <samd21.h>
#include "uart.h"
#include "utilities.h"


int main(void) {
    SystemInit();
    Uart_init();

    while (1) {

    }

    return 0;
}