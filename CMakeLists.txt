cmake_minimum_required(VERSION 3.8)

set(CMAKE_TRY_COMPILE_TARGET_TYPE "STATIC_LIBRARY")

include("sam_gcc.cmake")

project ("cmake-samd21")

set (CMAKE_ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/archive")
set (CMAKE_LIBRARY_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/lib")
set (CMAKE_RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}/bin")


add_sam_executable("cmake-samd21" 
        "src/main.c" 
        "src/uart.c" 
        "src/printf.c"
        "src/storage.c")


