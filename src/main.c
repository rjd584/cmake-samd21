#include <samd21.h>

#include "printf.h"
#include "storage.h"
#include "uart.h"
#include "utilities.h"

#define TURN_LEFT 0x02
#define TURN_RIGHT 0x03

void receivedDataHandler(char *data) {
    switch (data[1]) {
        case TURN_LEFT:
            my_printf("Turning Left\r\n");
            break;
        case TURN_RIGHT:
            my_printf("Turning Right\r\n");
            ;
            break;
        default:
            my_printf("Unknown Command\r\n");
            break;
    }
}

int main(void) {
    SystemInit();
    setprintoutput(Uart_write_raw, Uart_write_string);
    Uart_init(&receivedDataHandler);
    PORT->Group[0].DIRSET.reg = PORT_PA27;
    PORT->Group[0].DIRSET.reg = PORT_PA31;
    my_printf("System Started\r\n");
    derp();
    while (1) {
        delayMs(1000);
        PORT->Group[0].OUTTGL.reg = PORT_PA27;
    }

    return 0;
}

void HardFault_Handler() {
    int counter = 0;
    while (counter < 20) {
        delayMs(2000);
        PORT->Group[0].OUTTGL.reg = PORT_PA31;
        PORT->Group[0].OUTTGL.reg = PORT_PA27;
        counter++;
    }
    NVIC_SystemReset();
}