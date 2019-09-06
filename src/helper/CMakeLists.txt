include_directories(${CMAKE_CURRENT_SOURCE_DIR} ${PROJECT_SOURCE_DIR}/src/helper ${PROJECT_SOURCE_DIR}/jimtcl ${PROJECT_BINARY_DIR}/jimtcl ${CMAKE_CURRENT_BINARY_DIR})

add_compile_definitions(HAVE_CONFIG_H)

add_library(
    helper
 
    binarybuffer.c 
    command.c 
    configuration.c 
    fileio.c 
    ioutil_stubs.c 
    jep106.c 
    jim-nvp.c 
    log.c 
    options.c 
    replacements.c 
    time_support_common.c 
    time_support.c 
    util.c
)
