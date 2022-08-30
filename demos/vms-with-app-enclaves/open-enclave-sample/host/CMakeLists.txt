# Copyright (c) Open Enclave SDK contributors.
# Licensed under the MIT License.
add_custom_command(
  OUTPUT openenclavesample_u.h openenclavesample_u.c openenclavesample_args.h
  DEPENDS ${CMAKE_SOURCE_DIR}/openenclavesample.edl
  COMMAND
    openenclave::oeedger8r --untrusted ${CMAKE_SOURCE_DIR}/openenclavesample.edl
    --search-path ${OE_INCLUDEDIR} --search-path
    ${OE_INCLUDEDIR}/openenclave/edl/sgx)

add_executable(openenclavesample_host host.c
                               ${CMAKE_CURRENT_BINARY_DIR}/openenclavesample_u.c)

if (WIN32)
  copy_oedebugrt_target(openenclavesample_host_oedebugrt)
  add_dependencies(openenclavesample_host openenclavesample_host_oedebugrt)
endif ()

target_include_directories(
  openenclavesample_host PRIVATE # Needed for the generated file openenclavesample_u.h
                          ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(openenclavesample_host openenclave::oehost)
