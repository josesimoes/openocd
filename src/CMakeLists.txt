include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${PROJECT_SOURCE_DIR}/src/helper ${PROJECT_SOURCE_DIR}/jimtcl ${PROJECT_BINARY_DIR}/jimtcl ${CMAKE_CURRENT_BINARY_DIR})

add_compile_definitions(HAVE_CONFIG_H PKGDATADIR="../../share/openocd" BINDIR="../../bin")
# need this hack here because of typeof being GCC extension
# https://stackoverflow.com/questions/27029643/define-error-expected-declaration-specifiers-or-before-token
add_compile_definitions(typeof=__typeof__)

add_subdirectory(helper)

add_library(
    transport
    
    transport/transport.c
)

add_library(
    svf
    
    svf/svf.c
)

add_library(
    xsvf
    
    xsvf/xsvf.c
)

add_library(
    pld
    
    pld/pld.c 
    pld/xilinx_bit.c 
    pld/virtex2.c
)

add_library(
    server 
    server/server.c 
    server/telnet_server.c 
    server/gdb_server.c 
    server/server_stubs.c 
    server/tcl_server.c
)

add_library(
    rtos 
    
    rtos/rtos.c 
    rtos/rtos_standard_stackings.c 
    rtos/rtos_ecos_stackings.c 
    rtos/rtos_chibios_stackings.c 
    rtos/rtos_embkernel_stackings.c 
    rtos/rtos_mqx_stackings.c 
    rtos/FreeRTOS.c 
    rtos/ThreadX.c 
    rtos/eCos.c 
    rtos/linux.c 
    rtos/ChibiOS.c 
    rtos/embKernel.c 
    rtos/mqx.c 
    # rtos/rtos_multicore.c 
    rtos/rtos_ucos_iii_stackings.c 
    rtos/uCOS-III.c 
    rtos/nuttx.c 
    rtos/chromium-ec.c 
    rtos/hwthread.c
)

add_subdirectory(flash)
add_subdirectory(jtag)
add_subdirectory(target)

set(CMAKE_C_LINK_EXECUTABLE "<CMAKE_C_COMPILER>  <FLAGS> <CMAKE_C_LINK_FLAGS> <LINK_FLAGS> <OBJECTS>  -o <TARGET> -Wl,--start-group <LINK_LIBRARIES> -Wl,--end-group")

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/startup.tcl 
    COMMAND sh ARGS -c "cat ${CMAKE_CURRENT_SOURCE_DIR}/helper/startup.tcl ${CMAKE_CURRENT_SOURCE_DIR}/jtag/startup.tcl ${CMAKE_CURRENT_SOURCE_DIR}/target/startup.tcl ${CMAKE_CURRENT_SOURCE_DIR}/flash/startup.tcl ${CMAKE_CURRENT_SOURCE_DIR}/server/startup.tcl > ${CMAKE_CURRENT_BINARY_DIR}/startup.tcl" 
    MAIN_DEPENDENCY helper/startup.tcl
)

add_custom_command(
    OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/startup_tcl.inc 
    COMMAND sh ARGS -c "${CMAKE_CURRENT_SOURCE_DIR}/helper/bin2char.sh < ${CMAKE_CURRENT_BINARY_DIR}/startup.tcl > ${CMAKE_CURRENT_BINARY_DIR}/startup_tcl.inc" 
    MAIN_DEPENDENCY ${CMAKE_CURRENT_BINARY_DIR}/startup.tcl
)

string(TIMESTAMP BUILD_TIMESTAMP "%Y-%m-%d-%H:%M")

add_executable(openocd openocd.c main.c hello.c ${CMAKE_CURRENT_BINARY_DIR}/startup_tcl.inc)

add_dependencies(openocd libusb)

target_link_libraries(
    openocd

	xsvf
	svf
	jtag
	ocdjtagdrivers
	ocdjlink
	pld
	jim
	transport
	server
	rtos
	flash
	ocdflashnand
	ocdflashnor
	ocdhla
	ocdaice
	ocdusbblaster
	openrisc
	target
    ws2_32 
    hidapi 
    setupapi 
    usb 
    usb-1.0 
    # ftd2xx 
    libusb-1.0.dll.a
    helper
)

set_target_properties(openocd PROPERTIES COMPILE_FLAGS "-DPKGBLDDATE=\\\"${BUILD_TIMESTAMP}\\\" -DRELSTR=\\\"\\\" -DGITVERSION=\\\"\\\"")
# set_target_properties(openocd PROPERTIES LINK_FLAGS "-m32 -static-libgcc -static-libstdc++ ")

install(TARGETS openocd DESTINATION bin)
install(FILES ${PROJECT_BINARY_DIR}/libusb/install/lib/libusb-1.0.dll DESTINATION ${CMAKE_CURRENT_BINARY_DIR})
install(FILES jtag/drivers/OpenULINK/ulink_firmware.hex DESTINATION share/openocd/OpenULINK)

