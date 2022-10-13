#include <samd21.h>

#if defined(__metro_express__)
    #define PORTA 0
    #define BLINK_LED PORT_PA31 //rx led
#elif defined(__seeed_xaio__)
    #define PORTA 0
    #define BLINK_LED PORT_PA27 //tx led
#endif


void delayMs(int n) {
    int i;
    for (; n > 0; n--) {
        for (i = 0; i < 199; i++) {
            __asm("nop");
        }
    }
}

int main(void) {
    SystemInit();

    //Blink LED
    PORT->Group[PORTA].DIRSET.reg = BLINK_LED;

    while (1){
        delayMs(500);
        PORT->Group[PORTA].OUTTGL.reg = BLINK_LED;
    }

    return 0;
}


