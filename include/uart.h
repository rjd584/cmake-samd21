#ifndef UART_H
#define UART_H

#include <samd21.h>

#define RXPIN PIN_PA23
#define TXPIN PIN_PA22
#define RXLED PIN_PA31
#define TXLED PIN_PA27

#define RX_SOT 0x01
#define RX_EOT 0x04

#define RX_BUFFER_OVERFLOW_MSG "RX BUFFER OVERFLOW ERROR"

#define RECEIVE_BUFFER_SIZE 8

#define F_CPU 8000000  // 8MHz

typedef void (*receivedDataCallback)(char*);

void Uart_init(receivedDataCallback ptr_callback);
void Uart_write(char);
void Uart_write_string(const char *s);
void Uart_write_raw(const uint16_t data);
void Uart_write(char);
void resetInputBuffer();

#endif  

