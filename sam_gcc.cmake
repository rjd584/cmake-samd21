INCLUDE(CMakeForceCompiler)

SET ( CMAKE_SYSTEM_NAME Generic )
SET ( CMAKE_SYSTEM_PROCESSOR arm )
SET ( CMAKE_SYSTEM_VERSION 1 )
SET ( CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER )
SET ( CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY )
SET ( CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY )

SET ( CMAKE_FIND_ROOT_PATH  "/Applications/ARM/bin" )
SET ( ASF_ROOT_PATH         "/Users/rob/Dev_Libraries/xdk-asf-3.52.0")
SET ( SAMD21_LINKER         "../device/samd21g18a.ld")
SET ( BOARD_NAME            "metro_express")

SET ( CMAKE_C_COMPILER      "${CMAKE_FIND_ROOT_PATH}/arm-none-eabi-gcc" )
SET ( CMAKE_CXX_COMPILER    "${CMAKE_FIND_ROOT_PATH}/arm-none-eabi-g++" )
SET ( CMAKE_OBJCOPY         "${CMAKE_FIND_ROOT_PATH}/arm-none-eabi-objcopy" )
SET ( CMAKE_LINKER          "${CMAKE_FIND_ROOT_PATH}/arm-none-eabi-ld" )
SET ( CMAKE_SIZE            "${CMAKE_FIND_ROOT_PATH}/arm-none-eabi-size" )
SET ( CMAKE_OBJDUMP         "${CMAKE_FIND_ROOT_PATH}/arm-none-eabi-objdump")
   
SET ( CMSIS_INC_DIR         "${ASF_ROOT_PATH}/thirdparty/CMSIS/Include" )
SET ( SAMD21_INC_DIR        "${ASF_ROOT_PATH}/sam0/utils/cmsis/samd21/include" )
SET ( SAMD21_SRC_DIR        "${ASF_ROOT_PATH}/sam0/utils/cmsis/samd21/source")
SET ( SAMD21_STARTUP        "${ASF_ROOT_PATH}/sam0/utils/cmsis/samd21/source/gcc/startup_samd21.c")
SET ( SAMD21_SYSTEM         "${ASF_ROOT_PATH}/sam0/utils/cmsis/samd21/source/system_samd21.c")

SET ( CXX_LIBRARY            "/Library/Developer/CommandLineTools/usr/include/c++/v1")
SET ( PROJECT_SOURCE_DIR     "src/")
   
SET ( SAMD21_LINKER         "../device/samd21g18a.ld")

SET ( CMAKE_C_STANDARD 99 )
SET ( CMAKE_CXX_STANDARD 17 )

SET ( ARM_CPU cortex-m0plus )
SET ( ARM_UPLOADTOOL bossac )
SET ( ARM_UPLOADTOOL_PORT tty.usbmodem14301 )
SET ( ARM_PROGRAMMER cmsis-dap )
SET ( ARM_SIZE_ARGS -B)

SET (EXECUTABLE_NAME "cmake-samd21")
SET (ELF_OUTPUT_FILE "${EXECUTABLE_NAME}.elf")
SET (BIN_OUTPUT_FILE "${EXECUTABLE_NAME}.bin")
SET (UF2_OUTPUT_FILE "${EXECUTABLE_NAME}.uf2")
SET (HEX_OUTPUT_FILE "${EXECUTABLE_NAME}.hex")
SET (LST_OUTPUT_FILE "${EXECUTABLE_NAME}.lst")
SET (MAP_OUTPUT_FILE "${EXECUTABLE_NAME}.map")
SET (EEPROM_IMAGE "${EXECUTABLE_NAME}-eeprom.hex")

message(STATUS "Using CMAKE_BUILD_TYPE: ${CMAKE_BUILD_TYPE}")
message(STATUS "Using CMAKE_C_COMPILER: ${CMAKE_C_COMPILER}")
message(STATUS "Using CMAKE_CXX_COMPILER: ${CMAKE_CXX_COMPILER}")
message(STATUS "Using CMAKE_OBJCOPY: ${CMAKE_OBJCOPY}")
message(STATUS "Using CMAKE_LINKER: ${CMAKE_LINKER}")
message(STATUS "Using CMAKE_SIZE: ${CMAKE_SIZE}")
message(STATUS "Using CMAKE_C_STANDARD: ${CMAKE_C_STANDARD}")
message(STATUS "Using CMAKE_CXX_STANDARD: ${CMAKE_CXX_STANDARD}")
message(STATUS "Using ARM_SIZE_ARGS: ${ARM_SIZE_ARGS}")
message(STATUS "Using ARM_CPU: ${ARM_CPU}")

function (add_sam_executable EXECUTABLE_NAME)

	set (ADDT_SRC_FILES ${ARGN})
	list(LENGTH ADDT_SRC_FILES SRC_FILE_COUNT)

	if (SRC_FILE_COUNT LESS 0)
		message(FATAL_ERROR "No source files provided for ${EXECUTABLE_NAME}")
	else()
		foreach(src_file ${ADDT_SRC_FILES})
			message (STATUS "Including source: ${src_file}")
		endforeach()
	endif()

	add_executable (
		${ELF_OUTPUT_FILE}
		EXCLUDE_FROM_ALL ${ADDT_SRC_FILES} ${SAMD21_SYSTEM} ${SAMD21_STARTUP}
	) 

	target_include_directories (
		${ELF_OUTPUT_FILE}
		PUBLIC ${SAMD21_INC_DIR}
		PUBLIC ${CMSIS_INC_DIR}
		PUBLIC ${SAMD21_SRC_DIR}
		PUBLIC ${PROJECT_SOURCE_DIR}
		PUBLIC "include/"
	)

	set_target_properties (
      ${ELF_OUTPUT_FILE}
      PROPERTIES
	  COMPILE_FLAGS  "-mcpu=${ARM_CPU} -mthumb -Wall -Werror -g -ffunction-sections -fdata-sections -nostdlib -nostartfiles --param max-inline-insns-single=500 -Os -DDEBUG=0 -D__SAMD21G18A__ -D SYSTICK_MODE -D__${BOARD_NAME}__ -Wno-unused-but-set-variable -Wno-unused-variable"  #-DBOARD=USER_BOARD -DUSB_PID_HIGH=0x00 -DUSB_PID_LOW=0x4D -DUSB_VID_LOW=0x41 -DUSB_VID_HIGH=0x23"
	  LINK_FLAGS     "-mcpu=${ARM_CPU} -mthumb -Wall -Wl,--cref -Wl,--check-sections -Wl,--gc-sections -save-temps -Wl,--unresolved-symbols=report-all -Wl,--warn-common -Wl,--warn-section-align -Wl,--warn-unresolved-symbols --specs=nano.specs --specs=nosys.specs -Wl,-Map,${MAP_OUTPUT_FILE} -Wl,--start-group -lm -Wl,--end-group -T ${SAMD21_LINKER}"
    )

endfunction(add_sam_executable)

#bin file
add_custom_command (
	OUTPUT ${BIN_OUTPUT_FILE}
	COMMAND ${CMAKE_OBJCOPY} -S -O binary bin/${ELF_OUTPUT_FILE} ${BIN_OUTPUT_FILE}
	COMMAND ${CMAKE_SIZE} ${ARM_SIZE_ARGS} bin/${ELF_OUTPUT_FILE}
	DEPENDS bin/${ELF_OUTPUT_FILE}
)
#hex file
add_custom_command (
	OUTPUT ${HEX_OUTPUT_FILE}
	COMMAND ${CMAKE_OBJCOPY} -O ihex bin/${ELF_OUTPUT_FILE} ${HEX_OUTPUT_FILE}
	COMMAND ${CMAKE_SIZE} ${ARM_SIZE_ARGS} bin/${ELF_OUTPUT_FILE}
	DEPENDS bin/${ELF_OUTPUT_FILE}
)
#EEPROM
add_custom_command (
	OUTPUT ${EEPROM_IMAGE}
	COMMAND ${CMAKE_OBJCOPY} -j .eeprom --set-section-flags=.eeprom=alloc,load --change-section-lma .eeprom=0 --no-change-warnings -O ihex bin/${ELF_OUTPUT_FILE} ${EEPROM_IMAGE}
	DEPENDS ${ELF_OUTPUT_FILE}
)
#Build all and dissasemble
add_custom_target(
	build_all_${EXECUTABLE_NAME}
	ALL
	DEPENDS ${HEX_OUTPUT_FILE} ${EEPROM_IMAGE} ${BIN_OUTPUT_FILE} disassemble_${EXECUTABLE_NAME}
)
#Disassemble
add_custom_target(
    disassemble_${EXECUTABLE_NAME}
    ${CMAKE_OBJDUMP} -d -S bin/${ELF_OUTPUT_FILE} > ${LST_OUTPUT_FILE}
    DEPENDS ${ELF_OUTPUT_FILE}
)
#Build and Upload
add_custom_target(
	build_and_upload_${EXECUTABLE_NAME}
	ALL
	DEPENDS ${HEX_OUTPUT_FILE} ${EEPROM_IMAGE} ${BIN_OUTPUT_FILE} Upload_${EXECUTABLE_NAME}
)
#Upload
add_custom_target (
	Upload_${EXECUTABLE_NAME}
	${ARM_UPLOADTOOL} --port=${ARM_UPLOADTOOL_PORT} --offset=0x2000 --info --erase --write --verify --reset ${BIN_OUTPUT_FILE}
	DEPENDS ${BIN_OUTPUT_FILE}
)

add_custom_target (
	read_${EXECUTABLE_NAME}
	${ARM_UPLOADTOOL} -r mem --port=${ARM_UPLOADTOOL_PORT}
)


#Hasnt been used yet
function (add_sam_library LIBRARY_NAME)

	set (ADDT_SRC_FILES ${ARGN})
	list(LENGTH ADDT_SRC_FILES SRC_FILE_COUNT)

	if (SRC_FILE_COUNT LESS 0)
		message(FATAL_ERROR "No source files provided for ${LIBRARY_NAME}")
	else()
		foreach(src_file ${ADDT
	_SRC_FILES})
			message (STATUS "Including source: ${src_file}")
		endforeach()
	endif()

	set (STATICLIB_OUTPUT_FILE "${LIBRARY_NAME}.a")

	add_library(${LIBRARY_NAME} STATIC EXCLUDE_FROM_ALL ${ADDT_SRC_FILES})

	target_include_directories(${LIBRARY_NAME} PUBLIC ${CMSIS_INC_DIR} PUBLIC ${SAMD21_INC_DIR}  )
	set_target_properties (
		${LIBRARY_NAME}
		PROPERTIES
			COMPILE_FLAGS "-x c -mthumb -D__SAMD21G18AU__ -DDEBUG -O1 -ffunction-sections -mlong-calls -g3 -Wall -mcpu=${ARM_CPU} -c -std=gnu99 -MD -MP -MF ${LIBRARY_NAME}.d" #-MT\"library.d\" -MT\"library.o\"   -o \"library.o\" \".././library.c\""			
			LINKER_LANGUAGE "C"
			ARCHIVE_OUTPUT_NAME "${LIBRARY_NAME}"
	)

endfunction(add_sam_library)