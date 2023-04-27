#
# Copyright 2017 Threat Stack, Inc. All Rights Reserved
#                J. Paul Reed
#

set(THIRDPARTY_DIST_DIR ${CMAKE_BINARY_DIR}/thirdparty/dist CACHE INTERNAL "")
set(THIRDPARTY_OBJ_DIR ${CMAKE_BINARY_DIR}/thirdparty/obj CACHE INTERNAL "")

include(3p-utils.cmake)

_3p_check_required_tools()

# List of thirdparty projects we use
set(THIRDPARTY_PROJECTS
    acme
)

file(MAKE_DIRECTORY ${THIRDPARTY_OBJ_DIR})
file(MAKE_DIRECTORY ${THIRDPARTY_DIST_DIR})

include(ExternalProject)

add_custom_command(OUTPUT ${THIRDPARTY_DIST_DIR}/${CMAKE_BUILD_TYPE}
    COMMAND ${CMAKE_COMMAND} -E make_directory ${THIRDPARTY_DIST_DIR}/${CMAKE_BUILD_TYPE}
)

foreach(_project ${THIRDPARTY_PROJECTS})
    unset(BUILD_DEPS)

    message(STATUS "Activating thirdparty project ${_project}")
    set(${_project}_BUILD_CONF_MARKER ${CMAKE_CURRENT_BINARY_DIR}/${_project}/BUILD_MODE)
    set(${_project}_GIT_REV_MARKER ${CMAKE_CURRENT_BINARY_DIR}/${_project}/GIT_REVISION)

    include(${CMAKE_SOURCE_DIR}/thirdparty/${_project}.cmake)

    set(_dist_cpack_file_basename ${${_project}_DIST_FILE}.tar.gz)
    set(_dist_output_file_basename ${${_project}_DIST_FILE}-${CMAKE_BUILD_TYPE}.tar.gz)
    set(_dist_output_file ${THIRDPARTY_DIST_DIR}/${_dist_output_file_basename})

    set(_dist_output_dir ${THIRDPARTY_DIST_DIR}/${CMAKE_BUILD_TYPE}/${${_project}_DIST_FILE})
    set(_expand_working_dir ${THIRDPARTY_DIST_DIR}/${CMAKE_BUILD_TYPE})

    if (BUILD_THIRDPARTY)
        add_custom_command(OUTPUT ${${_project}_GIT_REV_MARKER}
            COMMAND ${GIT_BIN} describe --always > ${${_project}_GIT_REV_MARKER}
            COMMENT Recording ${_project} Git revision...
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}/thirdparty/${_project}
            VERBATIM
        )

        # Not using CPACK_, so we don't conflict with any actual CPACK
        # configuration variables
        if (DEBUG_CMAKE)
            set(CALL_CPACK_DEBUG_ARGS --debug --verbose)
        else()
            set(CALL_CPACK_DEBUG_ARGS "")
        endif()

        add_custom_command(OUTPUT ${_dist_output_file}
            COMMAND ${CMAKE_COMMAND} -E echo ${CMAKE_BUILD_TYPE} > ${${_project}_BUILD_CONF_MARKER}
            COMMAND ${CMAKE_CPACK_COMMAND} ${CALL_CPACK_DEBUG_ARGS} -C ${CMAKE_BUILD_TYPE} --config ${CMAKE_CURRENT_BINARY_DIR}/${_project}-CPackConfig.cmake
            COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_BINARY_DIR}/${_dist_cpack_file_basename} ${_dist_output_file}
            COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_CURRENT_BINARY_DIR}/${_dist_cpack_file_basename}
            COMMENT "Calling CPack to create ${${_project}_DIST_FILE}..."
            DEPENDS ${${_project}_GIT_REV_MARKER}
            WORKING_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}
            VERBATIM
        )

        add_custom_target(${_project}-create-distfile
            DEPENDS ${_dist_output_file})

        if (BUILD_DEPS)
            ts_cmake_debug("add_dependencies(${_project}-create-distfile ${BUILD_DEPS})")
            add_dependencies(${_project}-create-distfile ${BUILD_DEPS})
        endif()

        #list(APPEND thirdparty_dep_list ${_project}-create-distfile)
    else()
        if (NOT EXISTS ${_dist_output_file})
            message(FATAL_ERROR "${_dist_output_file} missing, but BUILD_THIRDPARTY is OFF; bailing...")
        endif()
    endif()

    add_custom_command(OUTPUT ${_dist_output_dir}
        COMMAND ${CMAKE_COMMAND} -E remove_directory ${_dist_output_dir}
        COMMAND ${CMAKE_COMMAND} -E tar xvf ${_dist_output_file}
        COMMAND ${CMAKE_COMMAND} -E touch ${_dist_output_dir}/SYNCED_AT.txt
        WORKING_DIRECTORY ${_expand_working_dir}
        DEPENDS ${THIRDPARTY_DIST_DIR}/${CMAKE_BUILD_TYPE}
    )

    # XXX - TODO
    # add_dependencies(${dist_output_dir}/SYNCED_AT depends on the dist_file.tar.gz)
    add_custom_target(${_project}-expand-distfile
        DEPENDS ${_dist_output_dir})

    list(APPEND thirdparty_dep_list ${_project}-expand-distfile)

    if (BUILD_THIRDPARTY)
        add_dependencies(${_project}-expand-distfile ${_project}-create-distfile)
    endif()
endforeach()

message(STATUS "thirdparty_dep_list: ${thirdparty_dep_list}")

#add_custom_target(thirdparty-libs ALL
#		DEPENDS ${thirdparty_dep_list})
