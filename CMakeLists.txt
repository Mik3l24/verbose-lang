include("CMakeLists.txt.user")
cmake_minimum_required(VERSION 3.21)

project(verbose LANGUAGES CXX)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")
#set(PROJECT_SOURCE_DIR "${PROJECT_SOURCE_DIR}.../src")

#find_package(FLEX 2.6 REQUIRED)
find_library(reflex_lib reflex_lib REQUIRED HINTS "${REFLEX_DIR}")

set(LEXER_OUT "${PARSER_DIR}/lexer.cpp")

add_custom_target(lexer)
ADD_CUSTOM_COMMAND(
        TARGET lexer
        OUTPUTS ${PARSER_DIR}/lexer.cpp
        DEPENDS ${SRC_DIR}/lexer.l
        COMMAND ${REFLEX_COMMAND}
        ARGS -o ${PARSER_DIR}/lexer.cpp --header-file=${PARSER_DIR}/lexer.h ${CMAKE_CURRENT_LIST_DIR}/src/lexer.l)
        
SET(FLEX_lexer_OUTPUTS ${CMAKE_BINARY_DIR}/lexer.cpp)

#flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" DEFINES_FILE "${PARSER_DIR}/lexer.h")

add_executable(verbose "${SRC_DIR}/main.cpp" "${LEXER_OUT}")
target_include_directories(verbose PRIVATE "${PARSER_DIR}")
target_include_directories(verbose PRIVATE "${REFLEX_DIR}/../include")
add_dependencies(verbose lexer)
target_link_libraries(verbose ${reflex_lib})