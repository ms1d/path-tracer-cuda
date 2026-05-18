cmake_minimum_required(VERSION 3.26)

add_library(raylib INTERFACE)
target_include_directories(raylib INTERFACE include)
target_link_libraries(raylib INTERFACE commonlib veclib)

if (BUILD_TESTS)
	add_subdirectory(test)
endif()
