cmake_minimum_required(VERSION 3.26)

add_library(matlib INTERFACE)
target_include_directories(matlib INTERFACE include)
target_link_libraries(matlib INTERFACE commonlib veclib)

if (BUILD_TESTS)
    add_subdirectory(test)
endif()
