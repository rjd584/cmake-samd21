#include "uart.h"

// static mystdout = FDEV_SETUP_STREAM (uart_putchar, NULL, _FDEV_SETUP_WRITE);
receivedDataCallback _receivedDataCallback; 
char rData[RECEIVE_BUFFER_SIZE]; //The receive buffer
uint8_t rIndex;                  //buffer index

void Uart_init(receivedDataCallback ptr_callback) {
    uint32_t baud = 9600;
    uint64_t br = (uint64_t)65536 * (F_CPU - 16 * baud) / F_CPU;  // Variable for baud rate

    PORT->Group[0].DIRSET.reg = (1 << TXPIN);                          // Set TX Pin direction to output
    PORT->Group[0].PINCFG[TXPIN].reg |= PORT_PINCFG_INEN;              // Set TX Pin config for input enable (required for usart)
    PORT->Group[0].PINCFG[TXPIN].reg |= PORT_PINCFG_PMUXEN;            // enable PMUX
    PORT->Group[0].PMUX[TXPIN / 2].bit.PMUXE = PORT_PMUX_PMUXE_C_Val;  // Set the PMUX bit (if pin is even, PMUXE, if odd, PMUXO)

    PORT->Group[0].DIRCLR.reg = (1 << RXPIN);                          // Set RX Pin direction to input
    PORT->Group[0].PINCFG[RXPIN].reg |= PORT_PINCFG_INEN;              // Set RX Pin config for input enable
    PORT->Group[0].PINCFG[RXPIN].reg &= ~PORT_PINCFG_PULLEN;           // enable pullup/down resistor
    PORT->Group[0].PINCFG[RXPIN].reg |= PORT_PINCFG_PMUXEN;            // enable PMUX
    PORT->Group[0].PMUX[RXPIN / 2].bit.PMUXO = PORT_PMUX_PMUXE_C_Val;  // Set the PMUX bit (if pin is even, PMUXE, if odd, PMUXO)

    SERCOM3->USART.CTRLA.bit.SWRST = 1;
    while (SERCOM3->USART.CTRLA.bit.SWRST || SERCOM3->USART.SYNCBUSY.bit.SWRST) {}

    PM->APBCMASK.reg |= PM_APBCMASK_SERCOM3;  // Set the PMUX for SERCOM3 and turn on module in PM

    SYSCTRL->OSC8M.bit.PRESC = 0;
    GCLK->CLKCTRL.reg = GCLK_CLKCTRL_ID(SERCOM3_GCLK_ID_CORE) | GCLK_CLKCTRL_CLKEN | GCLK_CLKCTRL_GEN(0);

    // while ( GCLK->STATUS.reg & GCLK_STATUS_SYNCBUSY ) // Wait for Sync

    SERCOM3->USART.CTRLA.reg = SERCOM_USART_CTRLA_DORD | SERCOM_USART_CTRLA_MODE_USART_INT_CLK | SERCOM_USART_CTRLA_RXPO(1 /*PAD1*/) | SERCOM_USART_CTRLA_TXPO(0 /*PAD0*/);

    SERCOM3->USART.CTRLB.reg = SERCOM_USART_CTRLB_RXEN | SERCOM_USART_CTRLB_TXEN | SERCOM_USART_CTRLB_CHSIZE(0 /*8 bits*/);
    // while (SERCOM3->USART.SYNCBUSY.bit.CTRLB);

    SERCOM3->USART.BAUD.reg = (uint16_t)br;
    SERCOM3->USART.CTRLA.reg |= SERCOM_USART_CTRLA_ENABLE;

    SERCOM3->USART.INTENSET.reg = SERCOM_USART_INTENSET_RXC;  // Interrupt on received complete
    NVIC_EnableIRQ(SERCOM3_IRQn);

    // while(SERCOM3->USART.SYNCBUSY.bit.ENABLE) ;
    _receivedDataCallback = ptr_callback;
    resetInputBuffer();
}

void Uart_write_raw(const uint16_t data) {
    while (SERCOM3->USART.INTFLAG.bit.DRE == 0) {}
    SERCOM3->USART.DATA.reg = data;
}

void Uart_write(char c) {
    while (!(SERCOM3->USART.INTFLAG.reg & SERCOM_USART_INTFLAG_DRE)) {
    }
    SERCOM3->USART.DATA.reg = c;
}

void Uart_write_string(const char *s) {
    while (*s)
        Uart_write(*s++);
}

void resetInputBuffer(){
    rIndex = 0;
    memset(rData, 0, sizeof(rData));
}

void SERCOM3_Handler() {
    if (SERCOM3->USART.INTFLAG.reg & SERCOM_USART_INTFLAG_RXC) {
        char rxChar = SERCOM3->USART.DATA.reg;

        if(rIndex >= sizeof(rData)){
            resetInputBuffer();
            Uart_write_string(RX_BUFFER_OVERFLOW_MSG "\r\n");
            return;
        }

        switch (rxChar) {
            case RX_SOT:
                rData[rIndex] = rxChar;
                rIndex++;
                break;
            case RX_EOT:
                rData[rIndex] = rxChar;
                _receivedDataCallback(rData);
                resetInputBuffer();
                break;
            default:
                if (rIndex > 0) {
                    rData[rIndex] = rxChar;
                    rIndex++;
                } else {
                    resetInputBuffer();
                }
                break;
        }
    }
}

