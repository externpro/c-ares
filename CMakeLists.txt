cmake_minimum_required(VERSION 3.0)
project(cares)
set(lib_name ${PROJECT_NAME})
include(flags OPTIONAL)
########################################
set_property(GLOBAL PROPERTY USE_FOLDERS ON) # enables MSVC Solution Folders
include(configure.cmake)
include_directories(${CMAKE_SOURCE_DIR})
########################################
# library sources
set(cmake
  ares_build.in
  ares_config.in
  configure.cmake
  )
source_group(cmake FILES ${cmake})
list(APPEND ${lib_name}_libsrcs ${cmake})
####################
set(libsrcs
  ares__close_sockets.c
  ares__get_hostent.c
  ares__read_line.c
  ares__timeval.c
  ares_cancel.c
  ares_create_query.c
  ares_data.c
  ares_destroy.c
  ares_expand_name.c
  ares_expand_string.c
  ares_fds.c
  ares_free_hostent.c
  ares_free_string.c
  ares_getenv.c
  ares_gethostbyaddr.c
  ares_gethostbyname.c
  ares_getnameinfo.c
  ares_getsock.c
  ares_init.c
  ares_library_init.c
  ares_llist.c
  ares_mkquery.c
  ares_nowarn.c
  ares_options.c
  ares_parse_a_reply.c
  ares_parse_aaaa_reply.c
  ares_parse_mx_reply.c
  ares_parse_naptr_reply.c
  ares_parse_ns_reply.c
  ares_parse_ptr_reply.c
  ares_parse_soa_reply.c
  ares_parse_srv_reply.c
  ares_parse_txt_reply.c
  ares_platform.c
  ares_process.c
  ares_query.c
  ares_search.c
  ares_send.c
  ares_strcasecmp.c
  ares_strdup.c
  ares_strerror.c
  ares_timeout.c
  ares_version.c
  ares_writev.c
  bitncmp.c
  inet_net_pton.c
  inet_ntop.c
  windows_port.c
  )
source_group(src FILES ${libsrcs})
list(APPEND ${lib_name}_libsrcs ${libsrcs})
####################
set(librcs
  cares.rc
  )
source_group(rc FILES ${librcs})
list(APPEND ${lib_name}_libsrcs ${librcs})
####################
set(libhdrs
  ares_data.h
  ares_getenv.h
  ares_inet_net_pton.h
  ares_iphlpapi.h
  ares_ipv6.h
  ares_library_init.h
  ares_llist.h
  ares_nowarn.h
  ares_platform.h
  ares_private.h
  ares_setup.h
  ares_strcasecmp.h
  ares_strdup.h
  ares_writev.h
  bitncmp.h
  nameser.h
  setup_once.h
  ${CMAKE_BINARY_DIR}/ares_config.h
  )
source_group(hdrs FILES ${libhdrs})
list(APPEND ${lib_name}_libsrcs ${libhdrs})
####################
set(hdrs
  ares.h
  ares_dns.h
  ares_rules.h
  ares_version.h
  ${CMAKE_BINARY_DIR}/ares_build.h
  )
source_group(include FILES ${hdrs})
list(APPEND ${lib_name}_libsrcs ${hdrs})
########################################
# library
add_definitions(-DCARES_STATICLIB)
add_library(${lib_name} STATIC ${${lib_name}_libsrcs})
if(DEFINED ARES_LIBS)
  target_link_libraries(${lib_name} ${ARES_LIBS})
endif()
########################################
# install
install(TARGETS ${lib_name} EXPORT ${PROJECT_NAME}-targets
  RUNTIME DESTINATION bin
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  )
install(EXPORT ${PROJECT_NAME}-targets DESTINATION lib/cmake)
install(FILES ${hdrs} DESTINATION include/cares)
