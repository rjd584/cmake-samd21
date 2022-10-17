#ifndef PRINTF_H
#define PRINTF_H

#include <stdarg.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>

typedef void (*write_out_raw)(const uint16_t);
typedef void (*write_out_string)(const char* );

void setprintoutput(write_out_raw out_raw, write_out_string out_string);
int my_printf(char const *fmt, ...) ;
int my_fprintf(FILE *file, char const *fmt, ...) ;
void ftoa_sci(char *buffer, double value);
int normalize(double *val);
int my_vfprintf(FILE *file, char const *fmt, va_list arg);
int	fputc (int, FILE *);
int	fputs (const char *__restrict, FILE *__restrict);

#endif