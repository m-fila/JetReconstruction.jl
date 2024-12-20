cmake_minimum_required(VERSION 3.23)

# Project name
project(JetReconstruction C)

set(CMAKE_C_STANDARD 99)
set(CMAKE_C_STANDARD_REQUIRED True)

find_program(JULIA_EXECUTABLE NAMES julia)

if(NOT JULIA_EXECUTABLE)
  message(
    FATAL_ERROR
      "Julia executable not found. Please install Julia or add it to your PATH."
  )
else()
  message(STATUS "Found Julia executable: ${JULIA_EXECUTABLE}")
endif()

add_custom_target(
  instantiate_main_project
  COMMAND ${JULIA_EXECUTABLE} --project=${CMAKE_CURRENT_SOURCE_DIR} -e
          'import Pkg\; Pkg.instantiate\(\)\;')

add_subdirectory("compile")
