add_custom_target(
  instantiate_compile_project
  DEPENDS instantiate_main_project
  COMMAND ${JULIA_EXECUTABLE} --project=${CMAKE_CURRENT_SOURCE_DIR} -e
          'import Pkg\; Pkg.instantiate\(\)\;')

add_custom_command(
  OUTPUT JetReconstructionCompiled/include/julia_init.h
         JetReconstructionCompiled/include/JetReconstruction.h
         JetReconstructionCompiled/lib/libjulia.so
         JetReconstructionCompiled/lib/libjetreconstruction.so
  COMMAND
    ${JULIA_EXECUTABLE} --project=${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/build.jl --output-dir
    ${CMAKE_CURRENT_BINARY_DIR}/JetReconstructionCompiled
  DEPENDS instantiate_compile_project)

add_custom_target(compile_package
                  DEPENDS 
                  JetReconstructionCompiled/include/JetReconstruction.h
                  JetReconstructionCompiled/include/julia_init.h
                  JetReconstructionCompiled/lib/libjulia.so
                  JetReconstructionCompiled/lib/libjetreconstruction.so)

add_library(libjetreconstruction SHARED IMPORTED)
set_target_properties(
  libjetreconstruction
  PROPERTIES
    DEPENDS compile_package
    IMPORTED_LOCATION
    "${CMAKE_CURRENT_BINARY_DIR}/JetReconstructionCompiled/lib/libjetreconstruction.so"
)
target_include_directories(libjetreconstruction INTERFACE
${CMAKE_CURRENT_BINARY_DIR}/JetReconstructionCompiled/include/
)

add_library(libjulia SHARED IMPORTED)
set_target_properties(
  libjulia
  PROPERTIES
    DEPENDS compile_package
    IMPORTED_LOCATION
    "${CMAKE_CURRENT_BINARY_DIR}/JetReconstructionCompiled/lib/libjulia.so")

add_executable(test_app test/jetreconstruction_test.c JetReconstructionCompiled/include/JetReconstruction.h JetReconstructionCompiled/include/julia_init.h)
target_link_libraries(test_app PUBLIC libjulia libjetreconstruction)

install(FILES JetReconstructionCompiled/include/JetReconstruction.h
              JetReconstructionCompiled/include/julia_init.h
        DESTINATION include/JetReconstruction)
install(DIRECTORY JetReconstructionCompiled/lib DESTINATION .)
install(DIRECTORY JetReconstructionCompiled/share DESTINATION .)
