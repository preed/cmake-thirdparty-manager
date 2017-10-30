#
# Copyright 2017 Threat Stack, Inc. All Rights Reserved
#
# These are macros/functions we need to do various things.
#
# The two functions below allow us to safely include the CPack module multiple
# times without receiving the "multiple inclusion" warning.
#
# While CPack was not designed for this purpose, this allows us to utilize
# CPack to generate 3rdparty package archives inside of this framework without
# tainting or leaking CPack configuration to the rest of the project.
#
# The approach was vetted by the developer who actually wrote that warning:
#
#   https://cmake.org/pipermail/cmake/2017-October/066437.html
#
# The two macros below implement his suggestions.
#

macro(_3p_reset_cpack_state)
    get_cmake_property(_varNames VARIABLES)
    foreach (_varName ${_varNames})
        string(TOLOWER ${_varName} _lc_varName)
        string(REGEX MATCH "^cpack_" _cpack_var ${_lc_varName})

        if (_cpack_var)
            ts_cmake_debug("_3p_reset_cpack_state(): unsetting ${_varName}")
            unset(${_varName})
        endif()
    endforeach()
    unset(CPack_CMake_INCLUDED)
endmacro()

macro(_3p_set_thirdpartymgr_cpack_vars)
    get_cmake_property(_varNames VARIABLES)
    foreach (_varName ${_varNames})
        string(TOLOWER ${_varName} _lc_varName)
        string(REGEX MATCH "^_3p_cpack_" _3p_cpack_var ${_lc_varName})

        if (_3p_cpack_var)
            string(REGEX REPLACE "^_3p_(.*)$" "\\1" _cpack_var "${_varName}")
            ts_cmake_debug("_3p_set_thirdpartymgr_cpack_vars(): setting ${_cpack_var} => ${${_varName}}")
            set(${_cpack_var} ${${_varName}})
        endif()
    endforeach()
endmacro()
