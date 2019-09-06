set(CMAKE_SYSTEM_NAME Windows)
set(CMAKE_SYSTEM_PROCESSOR i686)

# set VERBOSE if needed
#set(CMAKE_VERBOSE_MAKEFILE ON)

set(tools /usr/bin)
set(CMAKE_C_COMPILER ${tools}/i686-w64-mingw32-gcc)
set(CMAKE_CXX_COMPILER ${tools}/i686-w64-mingw32-g++)
set(CMAKE_RC_COMPILER ${tools}/i686-w64-mingw32-windres)

# need to do this to properly set C flags when cross compiling
# https://stackoverflow.com/questions/11423313/cmake-cross-compiling-c-flags-from-toolchain-file-ignored
# need to add -static to linker options to prevent having to deploy GCC DLLs
# https://stackoverflow.com/questions/4702732/the-program-cant-start-because-libgcc-s-dw2-1-dll-is-missing
UNSET(CMAKE_C_FLAGS CACHE)
UNSET(CMAKE_CXX_FLAGS CACHE)
set(CMAKE_C_FLAGS "-m32 -static -static-libgcc -static-libstdc++" CACHE STRING "" FORCE)
set(CMAKE_CXX_FLAGS "-m32 -static -static-libgcc -static-libstdc++" CACHE STRING "" FORCE)
