include("CMakeLists.txt.user")
cmake_minimum_required(VERSION 3.21)

project(verbose LANGUAGES C CXX)

set(SRC_DIR "src")
set(PARSER_DIR "${CMAKE_CURRENT_BINARY_DIR}")
#set(PROJECT_SOURCE_DIR "${PROJECT_SOURCE_DIR}.../src")

find_library(reflex_lib reflex_lib reflex REQUIRED HINTS "${REFLEX_DIR}")
find_package(BISON 3.8 REQUIRED)
#find_package(LLVM REQUIRED CONFIG)


set(LEXER_OUT "${PARSER_DIR}/lexer.cpp")
set(PARSER_OUT "${PARSER_DIR}/parser.cpp")


add_custom_target(lexer)
ADD_CUSTOM_COMMAND(
        TARGET lexer
        OUTPUTS ${PARSER_DIR}/lexer.cpp
        DEPENDS ${SRC_DIR}/lexer.l
        COMMAND ${REFLEX_COMMAND}
        ARGS -o ${PARSER_DIR}/lexer.cpp --header-file=${PARSER_DIR}/lexer.h ${CMAKE_CURRENT_LIST_DIR}/src/lexer.l --bison)
        
SET(FLEX_lexer_OUTPUTS ${CMAKE_BINARY_DIR}/lexer.cpp)
bison_target(PARSER "${SRC_DIR}/parser.y" "${PARSER_OUT}" DEFINES_FILE "${PARSER_DIR}/parser.hpp")

#include_directories(${LLVM_INCLUDE_DIRS})
#add_definitions(${LLVM_DEFINITIONS})

add_executable(verbose "${SRC_DIR}/main.cpp" "${LEXER_OUT}" "${PARSER_OUT}" "${SRC_DIR}/ast.cpp")
target_include_directories(verbose PRIVATE "${SRC_DIR}")
target_include_directories(verbose PRIVATE "${PARSER_DIR}")
target_include_directories(verbose PRIVATE "${REFLEX_DIR}/../include")
add_dependencies(verbose lexer)
target_link_libraries(verbose ${reflex_lib})

# Find the libraries that correspond to the LLVM components
# that we wish to use
#llvm_map_components_to_libnames(llvm_libs support core irreader)

# Link against LLVM libraries
#target_link_libraries(verbose ${llvm_libs})

enable_testing()

message(CMAKE_CURRENT_SRC_DIR: ${PROJECT_SOURCE_DIR})

add_test( difftest1 "${PROJECT_SOURCE_DIR}/tests/difftest.sh"
        ${PROJECT_SOURCE_DIR} 1
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)
add_test( difftest1_1 "${PROJECT_SOURCE_DIR}/tests/difftest.sh"
        ${PROJECT_SOURCE_DIR} 1_1
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)

add_test( difftest2_while_if "${PROJECT_SOURCE_DIR}/tests/difftest.sh"
        ${PROJECT_SOURCE_DIR} 2
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)
add_test( difftest2_if_else "${PROJECT_SOURCE_DIR}/tests/difftest.sh"
        ${PROJECT_SOURCE_DIR} 2_1
        WORKING_DIRECTORY ${PROJECT_SOURCE_DIR}
)