#
# Copyright 2017 Threat Stack, Inc. All Rights Reserved.
#

set(acme_VERSION 1.0.0)

set(acme_DIST_FILE "acme-${acme_VERSION}-${CMAKE_SYSTEM_NAME}")

set(acme_INCLUDES
    ${THIRDPARTY_DIST_DIR}/$<CONFIG>/${acme_DIST_FILE}/include/
    PARENT_SCOPE
)

set(acme_LIBRARIES
    ${THIRDPARTY_DIST_DIR}/$<CONFIG>/${acme_DIST_FILE}/lib/libacme.so
    PARENT_SCOPE
)

set(acme_INSTALL_DIR ${CMAKE_CURRENT_BINARY_DIR}/acme/install)

if (BUILD_THIRDPARTY)
    ExternalProject_Add(vendor-acme
        SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/acme
        BINARY_DIR ${CMAKE_CURRENT_BINARY_DIR}/acme
        CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                   -DCMAKE_INSTALL_PREFIX=${acme_INSTALL_DIR}
        BUILD_COMMAND make
        INSTALL_COMMAND make install
    )
    set(BUILD_DEPS vendor-acme)
endif()

# CPack releated stuff

install(DIRECTORY ${acme_INSTALL_DIR}/include
    DESTINATION .
    COMPONENT 3p-acme
)

install(DIRECTORY ${acme_INSTALL_DIR}/lib
    DESTINATION .
    COMPONENT 3p-acme
)

install(FILES ${acme_BUILD_CONF_MARKER}
    DESTINATION .
    COMPONENT 3p-acme
)
install(FILES ${acme_GIT_REV_MARKER}
    DESTINATION .
    COMPONENT 3p-acme
)

set(CPACK_INSTALL_CMAKE_PROJECTS "${CMAKE_CURRENT_BINARY_DIR};MyProject;3p-acme;/")

set(CPACK_PACKAGING_INSTALL_PREFIX /)
set(CPACK_SOURCE_INSTALLED_DIRECTORIES "")
set(CPACK_INSTALLED_DIRECTORIES "")
set(CPACK_GENERATOR "TGZ")
set(CPACK_PACKAGE_NAME "3p-thirdparty-acme")
set(CPACK_PACKAGE_VERSION ${acme_VERSION})
set(CPACK_PACKAGE_FILE_NAME ${acme_DIST_FILE})
set(CPACK_OUTPUT_CONFIG_FILE ${CMAKE_CURRENT_BINARY_DIR}/acme-CPackConfig.cmake)
set(CPACK_COMPONENTS_ALL 3p-acme)
set(CPACK_INSTALL_COMPONENT 3p-acme)

include(CPack)
