#include <samd21.h>

#define RXPIN PIN_PA23
#define TXPIN PIN_PA22
#define RXLED PIN_PA31
#define TXLED PIN_PA27

#define F_CPU 8000000  // 8MHz

void Uart_init(void);
void Uart_write(char);
void Uart_write_string(char *s);
void Uart_write_raw(const uint16_t data);
void Uart_write(char);