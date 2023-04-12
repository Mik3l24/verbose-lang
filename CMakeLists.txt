cmake_minimum_required(VERSION 3.26)

project(verbose LANGUAGES CXX)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")

find_package(FLEX 2.6 REQUIRED)

set(LEXER_OUT "${PARSER_DIR}/lexer.cpp")

flex_target(LEXER "${SRC_DIR}/lexer.l" "${LEXER_OUT}" DEFINES_FILE "${PARSER_DIR}/lexer.h")

add_executable(verbose "${SRC_DIR}/main.cpp" "${LEXER_OUT}")
target_include_directories(verbose PRIVATE "${PARSER_DIR}")