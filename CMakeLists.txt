cmake_minimum_required(VERSION 3.14)

include(ExternalProject)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/cmake/modules")

project(openocd VERSION ${BUILD_VERSION})
set(OPENOCD_VERSION ${BUILD_VERSION})

set(CMAKE_TOOLCHAIN_FILE CMake/toolchainfiles/toolchain_windows_32.cmake)

macro(append_compiler_flags)
	foreach(FLAG IN ITEMS ${ARGN})
		set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} ${FLAG}")
		set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${FLAG}")
	endforeach()
endmacro()


# build options for targets
option(BUILD_XDS110 "Enable building support for the TI XDS110 Debug Probe")
if(BUILD_XDS110)
    message("Build with support for TI XDS110 Debug Probe.")
endif()

option(BUILD_STLINK "Enable building support for the ST-Link JTAG Programmer")
if(BUILD_XDS110)
    message("Build with support for ST-Link JTAG Programmer.")
endif()

# use this as libusb install location
set(LIBUSB_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/libusb/install)

# Libusb from my GitHub fork
ExternalProject_Add( 
    libusb
    PREFIX libusb_lib
    GIT_REPOSITORY  https://github.com/josesimoes/libusb
    GIT_TAG "build"  # target CMake branch
    GIT_SHALLOW 1   # download only the tip of the branch, not the complete history
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX:PATH=${LIBUSB_INSTALL_DIR}
)

ExternalProject_Get_Property(libusb install_dir)
include_directories(${LIBUSB_INSTALL_DIR}/include)

# Provide all variables for the build
set(LIBRARY ${LIBUSB_INSTALL_DIR}/lib/libusb-1.0.dll.a)
include_directories(${libusb_INCLUDE_DIRS})

# find declaration for HIDAPI (required for ST-Link Jtag)
find_path(HIDAPI_INCLUDE_DIR hidapi.h
	PATH_SUFFIXES hidapi)

if(HIDAPI_INCLUDE_DIR)
    include_directories(${HIDAPI_INCLUDE_DIR})
endif()

include(config.cmake)

include_directories(${CMAKE_CURRENT_BINARY_DIR} ${LIBUSB1_INCLUDE_DIR} ${HIDAPI_INCLUDE_DIR})

add_subdirectory(jimtcl-cmake)
add_subdirectory(src)

install(DIRECTORY tcl/ DESTINATION share/openocd/scripts)
install(DIRECTORY contrib DESTINATION share/openocd)
