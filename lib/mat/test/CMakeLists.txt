cmake_minimum_required(VERSION 3.26)

file(GLOB TEST_SOURCES test_files/*.cu)

foreach(src ${TEST_SOURCES})

	get_filename_component(test_name ${src} NAME_WE)

	add_executable(${test_name}
        test_files/${test_name}.cu
    )

	target_link_libraries(${test_name} PRIVATE commonlib matlib)
    add_test(NAME ${test_name} COMMAND ${test_name})

endforeach()
