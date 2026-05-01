cmake_minimum_required(VERSION 3.26)

add_library(veclib INTERFACE)
target_include_directories(veclib INTERFACE include)
target_link_libraries(veclib INTERFACE commonlib)

if (BUILD_TESTS)
	add_subdirectory(test)
endif()
