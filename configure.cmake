include(CheckCSourceCompiles)
include(CheckFunctionExists)
include(CheckIncludeFile)
include(CheckLibraryExists)
include(CheckSymbolExists)
include(CheckTypeSize)
include(TestBigEndian)
########################################
function(set_define var)
  if(${ARGC} GREATER 1 AND ${var})
    set(DEFINE_${var} cmakedefine01 PARENT_SCOPE)
  else()
    set(DEFINE_${var} cmakedefine PARENT_SCOPE)
  endif()
  if(${var})
    set(ARES_TEST_DEFINES "${ARES_TEST_DEFINES} -D${var}" PARENT_SCOPE)
    set(CMAKE_REQUIRED_DEFINITIONS ${ARES_TEST_DEFINES} PARENT_SCOPE)
  endif(${var})
endfunction()
##########
macro(check_include_file_concat incfile var)
  if(${ARGC} GREATER 2)
    unset(code)
    foreach(arg ${ARGN})
      set(code "${code}#include <${arg}>\n")
    endforeach()
    set(code "${code}#include <${incfile}>
int main(void)
{
  return 0;
}
"     )
    check_c_source_compiles("${code}" ${var})
  else()
    check_include_file("${incfile}" ${var})
  endif()
  set_define(${var} 1)
  if(${var})
    set(ARES_INCLUDES ${ARES_INCLUDES} ${incfile})
  endif(${var})
endmacro()
##########
macro(check_exists_define01 func var)
  if(UNIX)
    check_function_exists("${func}" ${var})
  else()
    check_symbol_exists("${func}" "${ARES_INCLUDES}" ${var})
  endif()
  set_define(${var} 1)
endmacro()
##########
macro(check_library_exists_concat lib symbol var)
  check_library_exists("${lib};${ARES_LIBS}" ${symbol} "${CMAKE_LIBRARY_PATH}" ${var})
  set_define(${var} 1)
  if(${var})
    set(ARES_LIBS ${lib} ${ARES_LIBS})
    set(CMAKE_REQUIRED_LIBRARIES ${ARES_LIBS})
  endif(${var})
endmacro()
##########
function(typeSignature testname code results)
  string(TOLOWER ${testname} testname)
  string(TOUPPER ${testname} TESTNAME)
  set(scriptPath ${CMAKE_CURRENT_BINARY_DIR}/scripts/${testname}.cmake)
  set(cmd "function(${testname})\n")
  set(cmd "${cmd} set(attempt 1)\n")
  foreach(args ${ARGN})
    string(REPLACE "List" "" var ${args})
    set(cmd "${cmd} foreach(${var}")
    foreach(arg ${${args}})
      set(cmd "${cmd} \"${arg}\"")
    endforeach()
    set(cmd "${cmd})\n")
    list(INSERT vars 0 ${var})
  endforeach()
  set(cmd "${cmd} check_c_source_compiles(\"")
  set(cmd "${cmd}${code}\"\n")
  set(cmd "${cmd} ${TESTNAME}_\${attempt})\n")
  set(cmd "${cmd} if(${TESTNAME}_\${attempt})\n")
  set(cmd "${cmd}  set(hadSuccess true)\n")
  set(cmd "${cmd} else()\n")
  set(cmd "${cmd}  math(EXPR attempt \"\${attempt}+1\")\n")
  set(cmd "${cmd} endif()\n")
  list(LENGTH vars idx)
  foreach(var ${vars})
    math(EXPR idx "${idx}-1")
    list(GET results ${idx} res)
    set(cmd "${cmd} if(hadSuccess)\n")
    set(cmd "${cmd}  set(${res} \${${var}} PARENT_SCOPE)\n")
    set(cmd "${cmd}  break()\n")
    set(cmd "${cmd} endif()\n")
    set(cmd "${cmd} endforeach(${var})\n")
  endforeach()
  set(cmd "${cmd}endfunction()\n")
  set(cmd "${cmd}${testname}()\n")
  file(WRITE ${scriptPath} "${cmd}")
  include(${scriptPath})
  foreach(res ${results})
    set(${res} ${${res}} PARENT_SCOPE)
  endforeach()
endfunction()
########################################
check_include_file_concat(windows.h HAVE_WINDOWS_H)
if(HAVE_WINDOWS_H)
  set(WIN32_LEAN_AND_MEAN TRUE) # Define to avoid automatic inclusion of winsock.h
endif()
set_define(WIN32_LEAN_AND_MEAN)
check_include_file_concat(arpa/inet.h HAVE_ARPA_INET_H)
check_include_file_concat(arpa/nameser_compat.h HAVE_ARPA_NAMESER_COMPAT_H)
if(${CMAKE_SYSTEM_NAME} STREQUAL SunOS AND HAVE_ARPA_INET_H)
  # TRICKY: Solaris needs an extra include, arpa/nameser.h doesn't compile by itself
  set(additionalInc arpa/inet.h)
endif()
check_include_file_concat(arpa/nameser.h HAVE_ARPA_NAMESER_H ${additionalInc})
check_include_file_concat(assert.h HAVE_ASSERT_H)
check_include_file_concat(dlfcn.h HAVE_DLFCN_H)
check_include_file_concat(errno.h HAVE_ERRNO_H)
check_include_file_concat(fcntl.h HAVE_FCNTL_H)
check_include_file_concat(inttypes.h HAVE_INTTYPES_H)
check_include_file_concat(limits.h HAVE_LIMITS_H)
check_include_file_concat(malloc.h HAVE_MALLOC_H)
check_include_file_concat(memory.h HAVE_MEMORY_H)
check_include_file_concat(netdb.h HAVE_NETDB_H)
check_include_file_concat(netinet/in.h HAVE_NETINET_IN_H)
if(${CMAKE_SYSTEM_NAME} STREQUAL SunOS AND HAVE_NETINET_IN_H)
  # TRICKY: Solaris needs an extra include, netinet/tcp.h doesn't compile by itself
  set(additionalInc netinet/in.h)
endif()
check_include_file_concat(netinet/tcp.h HAVE_NETINET_TCP_H ${additionalInc})
check_include_file_concat(net/if.h HAVE_NET_IF_H)
check_include_file_concat(signal.h HAVE_SIGNAL_H)
check_include_file_concat(socket.h HAVE_SOCKET_H)
check_include_file_concat(stdbool.h HAVE_STDBOOL_H)
check_include_file_concat(stdint.h HAVE_STDINT_H)
check_include_file_concat(stdlib.h HAVE_STDLIB_H)
check_include_file_concat(strings.h HAVE_STRINGS_H)
check_include_file_concat(string.h HAVE_STRING_H)
check_include_file_concat(stropts.h HAVE_STROPTS_H)
check_include_file_concat(sys/ioctl.h HAVE_SYS_IOCTL_H)
check_include_file_concat(sys/param.h HAVE_SYS_PARAM_H)
check_include_file_concat(sys/select.h HAVE_SYS_SELECT_H)
check_include_file_concat(sys/socket.h HAVE_SYS_SOCKET_H)
check_include_file_concat(sys/stat.h HAVE_SYS_STAT_H)
check_include_file_concat(sys/time.h HAVE_SYS_TIME_H)
check_include_file_concat(sys/types.h HAVE_SYS_TYPES_H)
check_include_file_concat(sys/uio.h HAVE_SYS_UIO_H)
check_include_file_concat(time.h HAVE_TIME_H)
check_include_file_concat(unistd.h HAVE_UNISTD_H)
check_include_file_concat(winsock2.h HAVE_WINSOCK2_H)
if(NOT HAVE_WINSOCK2_H)
  check_include_file_concat(winsock.h HAVE_WINSOCK_H)
else()
  set_define(HAVE_WINSOCK_H)
endif()
check_include_file_concat(ws2tcpip.h HAVE_WS2TCPIP_H)
check_include_file_concat(getopt.h HAVE_GETOPT_H)
check_include_file_concat(process.h HAVE_PROCESS_H)
##########
check_library_exists_concat(ws2_32 getch HAVE_LIBWS2_32)
check_library_exists_concat(resolve hstrerror HAVE_LIBRESOLVE)
check_library_exists_concat(socket connect HAVE_LIBSOCKET)
check_library_exists_concat(nsl gethostbyaddr HAVE_LIBNSL)
check_library_exists_concat(rt clock_gettime HAVE_LIBRT)
##########
check_exists_define01(bitncmp HAVE_BITNCMP)
check_exists_define01(closesocket HAVE_CLOSESOCKET)
check_exists_define01(CloseSocket HAVE_CLOSESOCKET_CAMEL)
check_exists_define01(connect HAVE_CONNECT)
check_exists_define01(fcntl HAVE_FCNTL)
check_exists_define01(freeaddrinfo HAVE_FREEADDRINFO)
check_exists_define01(getenv HAVE_GETENV)
check_exists_define01(gethostbyaddr HAVE_GETHOSTBYADDR)
check_exists_define01(gethostbyname HAVE_GETHOSTBYNAME)
check_exists_define01(gethostname HAVE_GETHOSTNAME)
check_exists_define01(getnameinfo HAVE_GETNAMEINFO)
check_exists_define01(getservbyport_r HAVE_GETSERVBYPORT_R)
check_exists_define01(gettimeofday HAVE_GETTIMEOFDAY)
check_exists_define01(if_indextoname HAVE_IF_INDEXTONAME)
check_exists_define01(inet_net_pton HAVE_INET_NET_PTON)
check_exists_define01(inet_ntop HAVE_INET_NTOP)
check_exists_define01(inet_pton HAVE_INET_PTON)
check_exists_define01(ioctl HAVE_IOCTL)
check_exists_define01(ioctlsocket HAVE_IOCTLSOCKET)
check_exists_define01(IoctlSocket HAVE_IOCTLSOCKET_CAMEL)
check_exists_define01(recv HAVE_RECV)
check_exists_define01(recvfrom HAVE_RECVFROM)
check_exists_define01(send HAVE_SEND)
check_exists_define01(setsockopt HAVE_SETSOCKOPT)
check_exists_define01(socket HAVE_SOCKET)
check_exists_define01(strcasecmp HAVE_STRCASECMP)
check_exists_define01(strcmpi HAVE_STRCMPI)
check_exists_define01(strdup HAVE_STRDUP)
check_exists_define01(stricmp HAVE_STRICMP)
check_exists_define01(strncasecmp HAVE_STRNCASECMP)
check_exists_define01(strncmpi HAVE_STRNCMPI)
check_exists_define01(strnicmp HAVE_STRNICMP)
check_exists_define01(writev HAVE_WRITEV)
##########
set(CMAKE_EXTRA_INCLUDE_FILES ${ARES_INCLUDES})
check_type_size(int SIZEOF_INT)
check_type_size(long SIZEOF_LONG)
check_type_size(short SIZEOF_SHORT)
check_type_size(size_t SIZEOF_SIZE_T)
check_type_size(ssize_t SIZEOF_SSIZE_T)
check_type_size(time_t SIZEOF_TIME_T)
check_type_size("struct in6_addr" SIZEOF_STRUCT_IN6_ADDR)
check_type_size("struct in_addr" SIZEOF_STRUCT_IN_ADDR)
check_type_size(in_addr_t SIZEOF_IN_ADDR_T)
set(CMAKE_EXTRA_INCLUDE_FILES)
########################################
set(cares_includes_netdb "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_NETDB_H
# include <netdb.h>
#endif"
  )
set(cares_includes_none "
#ifdef NO_INCLUDES
# error no_includes
#endif"
  )
set(cares_includes_stdlib "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_STDLIB_H
# include <stdlib.h>
#endif"
  )
set(cares_includes_string "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_STRING_H
# include <string.h>
#endif
#ifdef HAVE_STRINGS_H
# include <strings.h>
#endif"
  )
set(cares_includes_stropts "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif
#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif
#ifdef HAVE_STROPTS_H
# include <stropts.h>
#endif"
  )
set(cares_includes_sys_socket "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif"
  )
set(cares_includes_sys_types "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif"
  )
set(cares_includes_unistd "
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif"
  )
set(cares_includes_winsock2 "
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
#endif"
  )
set(cares_includes_ws2tcpip "
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
#  ifdef HAVE_WS2TCPIP_H
#   include <ws2tcpip.h>
#  endif
# endif
#endif"
  )
set(cares_preprocess_callconv "
#ifdef HAVE_WINDOWS_H
# define FUNCALLCONV __stdcall
#else
# define FUNCALLCONV
#endif"
  )
########################################
if(HAVE_GETHOSTNAME)
  set(code "
${cares_includes_winsock2}
${cares_includes_unistd}
${cares_preprocess_callconv}
extern int FUNCALLCONV gethostname(\${arg1}, \${arg2});
int main (void)
{
  if(0 != gethostname(0, 0))
    return 1;
  ;
  return 0;
}
")
  set(results
    GETHOSTNAME_TYPE_ARG1
    GETHOSTNAME_TYPE_ARG2 # Define to the type of arg 2 for gethostname.
    )
  set(arg1List "char *" "unsigned char *" "void *")
  set(arg2List "int" "unsigned int" "size_t")
  typeSignature(GETHOSTNAME_TYPE "${code}" "${results}" arg1List arg2List)
endif(HAVE_GETHOSTNAME)
########################################
if(HAVE_GETNAMEINFO)
  set(code "
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# if (!defined(_WIN32_WINNT)) || (_WIN32_WINNT < 0x0501)
#  undef _WIN32_WINNT
#  define _WIN32_WINNT 0x0501
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
#  ifdef HAVE_WS2TCPIP_H
#   include <ws2tcpip.h>
#  endif
# endif
# define GNICALLCONV WSAAPI
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# ifdef HAVE_NETDB_H
#  include <netdb.h>
# endif
# define GNICALLCONV
#endif
extern int GNICALLCONV
  getnameinfo(\${arg1}, \${arg2}, char *, \${arg46}, char *, \${arg46}, \${arg7});
int main (void)
{
  \${arg2} salen=0;
  \${arg46} hostlen=0;
  \${arg46} servlen=0;
  \${arg7} flags=0;
  int res = getnameinfo(0, salen, 0, hostlen, 0, servlen, flags);
  ;
  return 0;
}
")
  set(results
    GETNAMEINFO_TYPE_ARG1 # Define to the type of arg 1 for getnameinfo.
    GETNAMEINFO_TYPE_ARG2 # Define to the type of arg 2 for getnameinfo.
    GETNAMEINFO_TYPE_ARG46 # Define to the type of args 4 and 6 for getnameinfo.
    GETNAMEINFO_TYPE_ARG7 # Define to the type of arg 7 for getnameinfo.
    )
  set(arg1List "const struct sockaddr *" "struct sockaddr *" "void *")
  set(arg2List "socklen_t" "size_t" "int")
  set(arg46List "size_t" "int" "socklen_t" "unsigned int" "DWORD")
  set(arg7List "int" "unsigned int")
  typeSignature(GETNAMEINFO_TYPE "${code}" "${results}"
    arg1List arg2List arg46List arg7List
    )
  ########################################
  # Define to the type qualifier of arg 1 for getnameinfo.
  string(FIND ${GETNAMEINFO_TYPE_ARG1} const isConst)
  if(${isConst} EQUAL -1) # const not found
    set(GETNAMEINFO_QUAL_ARG1 " ")
  else()
    set(GETNAMEINFO_QUAL_ARG1 const)
    string(REPLACE "const " "" GETNAMEINFO_TYPE_ARG1 ${GETNAMEINFO_TYPE_ARG1})
  endif()
endif(HAVE_GETNAMEINFO)
########################################
if(HAVE_RECVFROM)
  set(code "
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
# define RECVFROMCALLCONV PASCAL
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# define RECVFROMCALLCONV
#endif
extern \${retv} RECVFROMCALLCONV
  recvfrom(\${arg1}, \${arg2}, \${arg3}, \${arg4}, \${arg5}, \${arg6});
int main (void)
{
  \${arg1} s=0;
  \${arg2} buf=0;
  \${arg3} len=0;
  \${arg4} flags=0;
  \${arg5} addr=0;
  \${arg6} addrlen=0;
  \${retv} res=0;
  res = recvfrom(s, buf, len, flags, addr, addrlen);
  ;
  return 0;
}
")
  set(results
    RECVFROM_TYPE_ARG5 # Define to the type pointed by arg 5 for recvfrom.
    RECVFROM_TYPE_ARG4 # Define to the type of arg 4 for recvfrom.
    RECVFROM_TYPE_ARG3 # Define to the type of arg 3 for recvfrom.
    RECVFROM_TYPE_ARG2 # Define to the type pointed by arg 2 for recvfrom.
    RECVFROM_TYPE_ARG1 # Define to the type of arg 1 for recvfrom.
    RECVFROM_TYPE_RETV # Define to the function return type for recvfrom.
    RECVFROM_TYPE_ARG6 # Define to the type pointed by arg 6 for recvfrom.
    )
  set(arg5List "struct sockaddr *" "void *" "const struct sockaddr *")
  set(arg4List "int" "unsigned int")
  set(arg3List "size_t" "int" "socklen_t" "unsigned int")
  set(arg2List "char *" "void *")
  set(arg1List "int" "ssize_t" "SOCKET")
  set(retvList "int" "ssize_t")
  set(arg6List "int *" "socklen_t *" "unsigned int *" "size_t *" "void *")
  typeSignature(RECVFROM_TYPE "${code}" "${results}"
    arg5List arg4List arg3List arg2List arg1List retvList arg6List
    )
  string(REPLACE " *" "" RECVFROM_TYPE_ARG2 ${RECVFROM_TYPE_ARG2})
  string(REPLACE " *" "" RECVFROM_TYPE_ARG5 ${RECVFROM_TYPE_ARG5})
  string(REPLACE " *" "" RECVFROM_TYPE_ARG6 ${RECVFROM_TYPE_ARG6})
  ########################################
  # Define to the type qualifier pointed by arg 5 for recvfrom.
  string(FIND ${RECVFROM_TYPE_ARG5} const isConst)
  if(${isConst} EQUAL -1) # const not found
    set(RECVFROM_QUAL_ARG5 " ")
  else()
    set(RECVFROM_QUAL_ARG5 const)
    string(REPLACE "const " "" RECVFROM_TYPE_ARG5 ${RECVFROM_TYPE_ARG5})
  endif()
  ########################################
  # Define to 1 if the type pointed by arg 2 for recvfrom is void.
  string(FIND ${RECVFROM_TYPE_ARG2} void isVoid)
  if(NOT ${isVoid} EQUAL -1) # void found
    set(RECVFROM_TYPE_ARG2_IS_VOID TRUE)
  endif()
  set_define(RECVFROM_TYPE_ARG2_IS_VOID 1)
  ########################################
  # Define to 1 if the type pointed by arg 5 for recvfrom is void.
  string(FIND ${RECVFROM_TYPE_ARG5} void isVoid)
  if(NOT ${isVoid} EQUAL -1) # void found
    set(RECVFROM_TYPE_ARG5_IS_VOID TRUE)
  endif()
  set_define(RECVFROM_TYPE_ARG5_IS_VOID 1)
  ########################################
  # Define to 1 if the type pointed by arg 6 for recvfrom is void.
  string(FIND ${RECVFROM_TYPE_ARG6} void isVoid)
  if(NOT ${isVoid} EQUAL -1) # void found
    set(RECVFROM_TYPE_ARG6_IS_VOID TRUE)
  endif()
  set_define(RECVFROM_TYPE_ARG6_IS_VOID 1)
endif(HAVE_RECVFROM)
########################################
if(HAVE_RECV)
  set(code "
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
# define RECVCALLCONV PASCAL
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# define RECVCALLCONV
#endif
extern \${retv} RECVCALLCONV recv(\${arg1}, \${arg2}, \${arg3}, \${arg4});
int main (void)
{
  \${arg1} s=0;
  \${arg2} buf=0;
  \${arg3} len=0;
  \${arg4} flags=0;
  \${retv} res = recv(s, buf, len, flags);
  ;
  return 0;
}
")
  set(results
    RECV_TYPE_ARG1 # Define to the type of arg 1 for recv.
    RECV_TYPE_ARG2 # Define to the type of arg 2 for recv.
    RECV_TYPE_ARG3 # Define to the type of arg 3 for recv.
    RECV_TYPE_ARG4 # Define to the type of arg 4 for recv.
    RECV_TYPE_RETV # Define to the function return type for recv.
    )
  set(arg1List "int" "ssize_t" "SOCKET")
  set(arg2List "char *" "void *")
  set(arg3List "size_t" "int" "socklen_t" "unsigned int")
  set(arg4List "int" "unsigned int")
  set(retvList "int" "ssize_t")
  typeSignature(RECV_TYPE "${code}" "${results}"
    arg1List arg2List arg3List arg4List retvList
    )
endif(HAVE_RECV)
########################################
if(HAVE_SEND)
  set(code "
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
# define SENDCALLCONV PASCAL
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# define SENDCALLCONV
#endif
extern \${retv} SENDCALLCONV send(\${arg1}, \${arg2}, \${arg3}, \${arg4});
int main (void)
{
  \${arg1} s=0;
  \${arg3} len=0;
  \${arg4} flags=0;
  \${retv} res = send(s, 0, len, flags);
  ;
  return 0;
}
")
  set(results
    SEND_TYPE_ARG4 # Define to the type of arg 4 for send.
    SEND_TYPE_ARG3 # Define to the type of arg 3 for send.
    SEND_TYPE_ARG2 # Define to the type of arg 2 for send.
    SEND_TYPE_ARG1 # Define to the type of arg 1 for send.
    SEND_TYPE_RETV # Define to the function return type for send.
    )
  set(arg4List "int" "unsigned int")
  set(arg3List "size_t" "int" "socklen_t" "unsigned int")
  set(arg2List "const char *" "const void *" "char *" "void *")
  set(arg1List "int" "ssize_t" "SOCKET")
  set(retvList "int" "ssize_t")
  typeSignature(SEND_TYPE "${code}" "${results}"
    arg4List arg3List arg2List arg1List retvList
    )
  ########################################
  # Define to the type qualifier of arg 2 for send.
  string(FIND ${SEND_TYPE_ARG2} const isConst)
  if(${isConst} EQUAL -1) # const not found
    set(SEND_QUAL_ARG2 " ")
  else()
    set(SEND_QUAL_ARG2 const)
    string(REPLACE "const " "" SEND_TYPE_ARG2 ${SEND_TYPE_ARG2})
  endif()
endif(HAVE_SEND)
########################################
# Define as the return type of signal handlers (`int' or `void').
# Portable to assume C89, and that signal handlers return void.
# http://www.gnu.org/software/autoconf/manual/autoconf-2.69/html_node/Obsolete-Macros.html#index-AC_005fTYPE_005fSIGNAL-2213
set(RETSIGTYPE void)
########################################
if(HAVE_GETSERVBYPORT_R)
  # Specifies the number of arguments to getservbyport_r
  # Specifies the size of the buffer to pass to getservbyport_r
  check_c_source_compiles("
${cares_includes_netdb}
int main (void)
{
  if(0 != getservbyport_r(0, 0, 0, 0))
    return 1;
  ;
  return 0;
}
" GETSERVBYPORT_R_4
    )
  check_c_source_compiles("
${cares_includes_netdb}
int main (void)
{
  if(0 != getservbyport_r(0, 0, 0, 0, 0))
    return 1;
  ;
  return 0;
}
" GETSERVBYPORT_R_5
    )
  check_c_source_compiles("
${cares_includes_netdb}
int main (void)
{
  if(0 != getservbyport_r(0, 0, 0, 0, 0, 0))
    return 1;
  ;
  return 0;
}
" GETSERVBYPORT_R_6
    )
  if(GETSERVBYPORT_R_4)
    set(GETSERVBYPORT_R_ARGS 4)
    set(GETSERVBYPORT_R_BUFSIZE "sizeof(struct servent_data)")
  elseif(GETSERVBYPORT_R_5)
    set(GETSERVBYPORT_R_ARGS 5)
    set(GETSERVBYPORT_R_BUFSIZE 4096)
  elseif(GETSERVBYPORT_R_6)
    set(GETSERVBYPORT_R_ARGS 6)
    set(GETSERVBYPORT_R_BUFSIZE 4096)
  else() # error
    set(GETSERVBYPORT_R_ARGS 0)
    set(GETSERVBYPORT_R_BUFSIZE 0)
  endif()
endif(HAVE_GETSERVBYPORT_R)
########################################
# Define to 1 if you can safely include both <sys/time.h> and <time.h>.
check_c_source_compiles("
#include <sys/types.h>
#include <sys/time.h>
#include <time.h>
int main (void)
{
  if ((struct tm *) 0)
    return 0;
  ;
  return 0;
}
" TIME_WITH_SYS_TIME
  )
set_define(TIME_WITH_SYS_TIME 1)
########################################
# Define to 1 if bool is an available type.
check_c_source_compiles("
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_STDBOOL_H
#include <stdbool.h>
#endif
int main (void)
{
  if (sizeof (bool *) )
    return 0;
  ;
  return 0;
}
" HAVE_BOOL_T
  )
set_define(HAVE_BOOL_T 1)
########################################
if(HAVE_FCNTL)
  # Define to 1 if you have a working fcntl O_NONBLOCK function.
  check_c_source_compiles("
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif
#ifdef HAVE_FCNTL_H
# include <fcntl.h>
#endif
#if defined(sun) || defined(__sun__) || \
    defined(__SUNPRO_C) || defined(__SUNPRO_CC)
# if defined(__SVR4) || defined(__srv4__)
#  define PLATFORM_SOLARIS
# else
#  define PLATFORM_SUNOS4
# endif
#endif
#if (defined(_AIX) || defined(__xlC__)) && !defined(_AIX41)
# define PLATFORM_AIX_V3
#endif
#if defined(PLATFORM_SUNOS4) || defined(PLATFORM_AIX_V3) || defined(__BEOS__)
#error \"O_NONBLOCK does not work on this platform\"
#endif
int main (void)
{
  int flags = 0;
  if(0 != fcntl(0, F_SETFL, flags | O_NONBLOCK))
    return 1;
  ;
  return 0;
}
" HAVE_FCNTL_O_NONBLOCK
    )
endif(HAVE_FCNTL)
set_define(HAVE_FCNTL_O_NONBLOCK 1)
########################################
# Define to 1 if you have a working getaddrinfo function.
check_c_source_compiles("
${cares_includes_ws2tcpip}
${cares_includes_stdlib}
${cares_includes_string}
${cares_includes_sys_socket}
${cares_includes_netdb}
int main (void)
{
  struct addrinfo hints;
  struct addrinfo *ai = 0;
  int error;
  memset(&hints, 0, sizeof(hints));
  hints.ai_flags = AI_NUMERICHOST;
  hints.ai_family = AF_UNSPEC;
  hints.ai_socktype = SOCK_STREAM;
  error = getaddrinfo(\"127.0.0.1\", 0, &hints, &ai);
  if(error || !ai)
    exit(1); /* fail */
  else
    exit(0);
  ;
  return 0;
}
" HAVE_GETADDRINFO
  )
set_define(HAVE_GETADDRINFO 1)
########################################
# Define to 1 if the getaddrinfo function is threadsafe.
# POSIX-compliant should be thread-safe
# http://curl-library.cool.haxx.narkive.com/1EtVkLDi/detection-of-have-getaddrinfo-threadsafe-in-configure
set(HAVE_GETADDRINFO_THREADSAFE TRUE) # TODO determine
set_define(HAVE_GETADDRINFO_THREADSAFE 1)
########################################
if(HAVE_IOCTLSOCKET_CAMEL)
  # Define to 1 if you have a working IoctlSocket camel case FIONBIO function.
  check_c_source_compiles("
${cares_includes_stropts}
int main (void)
{
  long flags = 0;
  if(0 != IoctlSocket(0, FIONBIO, &flags))
    return 1;
  ;
  return 0;
}
" HAVE_IOCTLSOCKET_CAMEL_FIONBIO
    )
endif(HAVE_IOCTLSOCKET_CAMEL)
set_define(HAVE_IOCTLSOCKET_CAMEL_FIONBIO 1)
########################################
if(HAVE_IOCTLSOCKET)
  # Define to 1 if you have a working ioctlsocket FIONBIO function.
  check_c_source_compiles("
${cares_includes_winsock2}
int main (void)
{
  int flags = 0;
  if(0 != ioctlsocket(0, FIONBIO, &flags))
    return 1;
  ;
  return 0;
}
" HAVE_IOCTLSOCKET_FIONBIO
    )
endif(HAVE_IOCTLSOCKET)
set_define(HAVE_IOCTLSOCKET_FIONBIO 1)
########################################
if(HAVE_IOCTL)
  # Define to 1 if you have a working ioctl FIONBIO function.
  check_c_source_compiles("
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif
#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif
#ifdef HAVE_STROPTS_H
# include <stropts.h>
#endif
int main (void)
{
  int flags = 0;
  if(0 != ioctl(0, FIONBIO, &flags))
    return 1;
  ;
  return 0;
}
" HAVE_IOCTL_FIONBIO
    )
  ########################################
  # Define to 1 if you have a working ioctl SIOCGIFADDR function.
  check_c_source_compiles("
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_UNISTD_H
# include <unistd.h>
#endif
#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif
#ifdef HAVE_SYS_IOCTL_H
# include <sys/ioctl.h>
#endif
#ifdef HAVE_STROPTS_H
# include <stropts.h>
#endif
#ifdef HAVE_NET_IF_H
# include <net/if.h>
#endif
int main (void)
{
  struct ifreq ifr;
  if(0 != ioctl(0, SIOCGIFADDR, &ifr))
    return 1;
  ;
  return 0;
}
" HAVE_IOCTL_SIOCGIFADDR
    )
endif(HAVE_IOCTL)
set_define(HAVE_IOCTL_FIONBIO 1)
set_define(HAVE_IOCTL_SIOCGIFADDR 1)
########################################
# Define to 1 if the compiler supports the 'long long' data type.
check_type_size("long long" SIZEOF_LONG_LONG)
if(HAVE_SIZEOF_LONG_LONG)
  set(HAVE_LONGLONG 1)
else()
  set(HAVE_LONGLONG)
endif()
set_define(HAVE_LONGLONG 1)
########################################
# if your compiler supports LL
check_c_source_compiles("
int main (void)
{
  long long value = 1000LL;
  ;
  return 0;
}
" HAVE_LL
  )
set_define(HAVE_LL 1)
########################################
# Define to 1 if you have the MSG_NOSIGNAL flag.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
# endif
#endif
int main (void)
{
  int flag=MSG_NOSIGNAL;
  ;
  return 0;
}
" HAVE_MSG_NOSIGNAL
  )
set_define(HAVE_MSG_NOSIGNAL 1)
########################################
# Define to 1 if you have PF_INET6.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
#endif
#ifndef PF_INET6
 NJET
#endif
int main (void)
{
  return 0;
}
" HAVE_PF_INET6
  )
set_define(HAVE_PF_INET6 1)
########################################
# Define to 1 if you have AF_INET6.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
#endif
#ifndef AF_INET6
 NJET
#endif
int main (void)
{
  return 0;
}
" HAVE_AF_INET6
  )
set_define(HAVE_AF_INET6 1)
########################################
if(HAVE_SETSOCKOPT)
  # Define to 1 if you have a working setsockopt SO_NONBLOCK function.
  check_c_source_compiles("
int main (void)
{
  if(0 != setsockopt(0, SOL_SOCKET, SO_NONBLOCK, 0, 0))
    return 1;
  ;
  return 0;
}
" HAVE_SETSOCKOPT_SO_NONBLOCK
    )
endif(HAVE_SETSOCKOPT)
set_define(HAVE_SETSOCKOPT_SO_NONBLOCK 1)
########################################
# Define to 1 if sig_atomic_t is an available typedef.
check_c_source_compiles("
#ifdef HAVE_SIGNAL_H
# include <signal.h>
#endif
int main (void)
{
  sig_atomic_t dummy = 0;
  ;
  return 0;
}
" HAVE_SIG_ATOMIC_T
  )
set_define(HAVE_SIG_ATOMIC_T 1)
########################################
# Define to 1 if sig_atomic_t is already defined as volatile.
check_c_source_compiles("
#ifdef HAVE_SIGNAL_H
# include <signal.h>
#endif
int main (void)
{
  static volatile sig_atomic_t dummy = 0;
  ;
  return 0;
}
" HAVE_SIG_ATOMIC_T_VOLATILE
  )
# TODO: this is the test, AFAICT, in configure script, but it's returning
# true here in cmake and false in the configure script
set(HAVE_SIG_ATOMIC_T_VOLATILE FALSE)
set_define(HAVE_SIG_ATOMIC_T_VOLATILE 1)
########################################
# Define to 1 if your struct sockaddr_in6 has sin6_scope_id.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
#  ifdef HAVE_WS2TCPIP_H
#   include <ws2tcpip.h>
#  endif
# endif
#else
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_NETINET_IN_H
#  include <netinet/in.h>
# endif
#endif
int main (void)
{
  struct sockaddr_in6* tmp;
  tmp->sin6_scope_id;
  return 0;
}
" HAVE_SOCKADDR_IN6_SIN6_SCOPE_ID
  )
set_define(HAVE_SOCKADDR_IN6_SIN6_SCOPE_ID 1)
########################################
# Define to 1 if you have struct addrinfo.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
#  ifdef HAVE_WS2TCPIP_H
#   include <ws2tcpip.h>
#  endif
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_NETINET_IN_H
#  include <netinet/in.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# ifdef HAVE_NETDB_H
#  include <netdb.h>
# endif
#endif
int main (void)
{
  struct addrinfo struct_instance;
  ;
  return 0;
}
" HAVE_STRUCT_ADDRINFO
  )
set_define(HAVE_STRUCT_ADDRINFO 1)
########################################
# Define to 1 if you have struct in6_addr.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
#  ifdef HAVE_WS2TCPIP_H
#   include <ws2tcpip.h>
#  endif
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_NETINET_IN_H
#  include <netinet/in.h>
# endif
#endif
int main (void)
{
  struct in6_addr struct_instance;
  ;
  return 0;
}
" HAVE_STRUCT_IN6_ADDR
  )
set_define(HAVE_STRUCT_IN6_ADDR 1)
########################################
# Define to 1 if you have struct sockaddr_in6.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
#  ifdef HAVE_WS2TCPIP_H
#   include <ws2tcpip.h>
#  endif
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_NETINET_IN_H
#  include <netinet/in.h>
# endif
#endif
int main (void)
{
  struct sockaddr_in6 struct_instance;
  ;
  return 0;
}
" HAVE_STRUCT_SOCKADDR_IN6
  )
set_define(HAVE_STRUCT_SOCKADDR_IN6 1)
########################################
# if struct sockaddr_storage is defined
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# ifdef HAVE_NETINET_IN_H
#  include <netinet/in.h>
# endif
# ifdef HAVE_ARPA_INET_H
#  include <arpa/inet.h>
# endif
#endif
int main (void)
{
  struct sockaddr_storage struct_instance;
  ;
  return 0;
}
" HAVE_STRUCT_SOCKADDR_STORAGE
  )
set_define(HAVE_STRUCT_SOCKADDR_STORAGE 1)
########################################
# Define to 1 if you have the timeval struct.
check_c_source_compiles("
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
#endif
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_SYS_TIME_H
# include <sys/time.h>
# ifdef TIME_WITH_SYS_TIME
#  include <time.h>
# endif
#else
# ifdef HAVE_TIME_H
#  include <time.h>
# endif
#endif
#ifdef HAVE_SYS_SOCKET_H
# include <sys/socket.h>
#endif
int main (void)
{
  struct timeval ts;
  ts.tv_sec  = 0;
  ts.tv_usec = 0;
  ;
  return 0;
}
" HAVE_STRUCT_TIMEVAL
  )
set_define(HAVE_STRUCT_TIMEVAL 1)
########################################
# Define to 1 if you have the clock_gettime function and monotonic timer.
check_c_source_compiles("
#ifdef HAVE_STDLIB_H
# include <stdlib.h>
#endif
#ifdef HAVE_SYS_TYPES_H
# include <sys/types.h>
#endif
#ifdef HAVE_SYS_TIME_H
# include <sys/time.h>
# ifdef TIME_WITH_SYS_TIME
#  include <time.h>
# endif
#else
# ifdef HAVE_TIME_H
#  include <time.h>
# endif
#endif
int main (void)
{
  struct timespec ts;
  (void)clock_gettime(CLOCK_MONOTONIC, &ts);
 ;
 return 0;
}
" HAVE_CLOCK_GETTIME_MONOTONIC
  )
set_define(HAVE_CLOCK_GETTIME_MONOTONIC 1)
########################################
# Define to 1 if you need the malloc.h header file even with stdlib.h
check_c_source_compiles("
#include <stdlib.h>
int main (void)
{
  void *p = malloc(10);
  void *q = calloc(10,10);
  free(p);
  free(q);
  ;
  return 0;
}
" DONT_NEED_MALLOC_H
  )
if(DONT_NEED_MALLOC_H)
  set(NEED_MALLOC_H FALSE)
else()
  set(NEED_MALLOC_H TRUE)
endif()
set_define(NEED_MALLOC_H 1)
########################################
# Define to 1 if you need the memory.h header file even with stdlib.h
check_c_source_compiles("
#include <stdlib.h>
int main (void)
{
  void *p = malloc(10);
  void *q = calloc(10,10);
  free(p);
  free(q);
  ;
  return 0;
}
" DONT_NEED_MEMORY_H
  )
if(DONT_NEED_MEMORY_H)
  set(NEED_MEMORY_H FALSE)
else()
  set(NEED_MEMORY_H TRUE)
endif()
set_define(NEED_MEMORY_H 1)
########################################
# Define to 1 if _REENTRANT preprocessor symbol must be defined.
if(${CMAKE_SYSTEM_NAME} STREQUAL SunOS)
  set(NEED_REENTRANT ON)
else()
  set(NEED_REENTRANT) # TODO
endif()
set_define(NEED_REENTRANT 1)
########################################
# Define to 1 if _THREAD_SAFE preprocessor symbol must be defined.
check_c_source_compiles("
int main (void)
{
#ifdef _THREAD_SAFE
  int dummy=1;
#else
  force compilation erorr
#endif
  ;
  return 0;
}
" ALREADY_NEEDS_THREAD_SAFE
  )
if(ALREADY_NEEDS_THREAD_SAFE OR ${CMAKE_SYSTEM_NAME} STREQUAL AIX)
  # TODO: not all versions of AIX need _THREAD_SAFE
  set(NEED_THREAD_SAFE TRUE)
endif()
set_define(NEED_THREAD_SAFE 1)
########################################
# Define to 1 if your C compiler doesn't accept -c and -o together.
set(NO_MINUS_C_MINUS_O FALSE) # TODO determine
set_define(NO_MINUS_C_MINUS_O 1)
########################################
# if a /etc/inet dir is being used
if(EXISTS /etc/inet/hosts)
  set(ETC_INET TRUE)
endif()
set_define(ETC_INET 1)
########################################
# Define to the sub-directory in which libtool stores uninstalled libraries.
execute_process(COMMAND libtool --version
  OUTPUT_QUIET ERROR_QUIET RESULT_VARIABLE hasLibtool
  )
if(hasLibtool EQUAL 0) # 0 == success
  set(LT_OBJDIR .libs/)
endif()
########################################
# a suitable file/device to read random data from
if(EXISTS /dev/urandom)
  set(RANDOM_FILE /dev/urandom)
endif()
########################################
# Definition to make a library symbol externally visible.
if(CMAKE_COMPILER_IS_GNUCC OR CMAKE_COMPILER_IS_GNUCXX OR ${CMAKE_CXX_COMPILER_ID} MATCHES "Clang")
  set(CARES_SYMBOL_SCOPE_EXTERN "__attribute__ ((__visibility__ (\"default\")))")
endif()
########################################
# Define if building universal (internal helper macro)
set(AC_APPLE_UNIVERSAL_BUILD)
set_define(AC_APPLE_UNIVERSAL_BUILD)
########################################
# when building as static part of libcurl
# from m4/cares-compilers.m4:
# TODO: Verify if the BUILDING_LIBCURL definition is still required.
set_define(BUILDING_LIBCURL)
########################################
# Define to 1 if you have the ANSI C header files.
set(STDC_HEADERS TRUE) # TODO: determine if true
set_define(STDC_HEADERS 1)
########################################
# Define to disable non-blocking sockets.
# TODO
set_define(USE_BLOCKING_SOCKETS)
########################################
# Define WORDS_BIGENDIAN to 1 if your processor stores words with the most
# significant byte first (like Motorola and SPARC, unlike Intel).
test_big_endian(WORDS_BIGENDIAN)
set_define(WORDS_BIGENDIAN 1)
# define this if ares is built for a big endian system
if(WORDS_BIGENDIAN)
  set(ARES_BIG_ENDIAN TRUE)
endif()
set_define(ARES_BIG_ENDIAN 1)
########################################
# Define to 1 if OS is AIX.
if(${CMAKE_SYSTEM_NAME} STREQUAL AIX)
  set(_ALL_SOURCE TRUE)
endif()
set_define(_ALL_SOURCE 1)
# Define for large files, on AIX-style hosts.
if(${CMAKE_SYSTEM_NAME} STREQUAL AIX)
  set(_LARGE_FILES TRUE) # TODO: determine as configure does
endif()
set_define(_LARGE_FILES 1)
########################################
# Enable large inode numbers on Mac OS X 10.5.
# TODO
#ifndef _DARWIN_USE_64_BIT_INODE
# define _DARWIN_USE_64_BIT_INODE 1
#endif
########################################
# Number of bits in a file offset, on hosts where this is settable.
set(offsetCode "
#include <sys/types.h>
 /* Check that off_t can represent 2**63 - 1 correctly.
    We can't simply define LARGE_OFF_T to be 9223372036854775807,
    since some C++ compilers compilers masquerading as C compilers
    incorrectly reject 9223372036854775807.  */
#define LARGE_OFF_T ((((off_t) 1 << 31) << 31) - 1 + (((off_t) 1 << 31) << 31))
  int off_t_is_large[(LARGE_OFF_T % 2147483629 == 721
                       && LARGE_OFF_T % 2147483647 == 1)
                      ? 1 : -1];
int main()
{
  ;
  return 0;
}
" )
set(_FILE_OFFSET_BITS) # nothing, by default
check_c_source_compiles("${offsetCode}" OFFSET_NONE_COMPILES)
if(NOT OFFSET_NONE_COMPILES)
  check_c_source_compiles("#define _FILE_OFFSET_BITS 64\n${offsetCode}" OFFSET_64_COMPILES)
  if(OFFSET_64_COMPILES)
    set(_FILE_OFFSET_BITS 64)
  endif()
endif()
########################################
# Define to empty if `const' does not conform to ANSI C.
# TODO
set_define(const)
########################################
# Type to use in place of in_addr_t when system does not provide it.
if(NOT HAVE_SIZEOF_IN_ADDR_T)
  set(code "
#undef inline
#ifdef HAVE_WINDOWS_H
# ifndef WIN32_LEAN_AND_MEAN
#  define WIN32_LEAN_AND_MEAN
# endif
# include <windows.h>
# ifdef HAVE_WINSOCK2_H
#  include <winsock2.h>
# else
#  ifdef HAVE_WINSOCK_H
#   include <winsock.h>
#  endif
# endif
#else
# ifdef HAVE_SYS_TYPES_H
#  include <sys/types.h>
# endif
# ifdef HAVE_SYS_SOCKET_H
#  include <sys/socket.h>
# endif
# ifdef HAVE_NETINET_IN_H
#  include <netinet/in.h>
# endif
# ifdef HAVE_ARPA_INET_H
#  include <arpa/inet.h>
# endif
#endif
int main (void)
{
  \${equiv} data = inet_addr(\\\"1.2.3.4\\\");
  return 0;
}
")
  set(results in_addr_t)
  set(equivList "unsigned long" "int" "size_t" "unsigned" "long")
  typeSignature(IN_ADDR_TYPE "${code}" "${results}" equivList)
endif()
########################################
# Define to `unsigned int' if <sys/types.h> does not define.
if(NOT HAVE_SIZEOF_SIZE_T)
  set(size_t "unsigned int")
endif()
########################################
# the signed version of size_t
if(NOT HAVE_SIZEOF_SSIZE_T)
  if(HAVE_WINDOWS_H AND SIZEOF_SIZE_T EQUAL 8)
    set(ssize_t "__int64")
  else()
    set(ssize_t "int")
  endif()
endif()
########################################
# cpu-machine-OS
set(OS ${CMAKE_SYSTEM_PROCESSOR}-${CMAKE_SYSTEM_NAME})
# Name of package
set(PACKAGE "c-ares")
# Version number of package
file(STRINGS ares_version.h verStr REGEX "^#define[\t ]+ARES_VERSION_STR[\t ]+\".*\".*")
string(REGEX REPLACE "^#define[\t ]+ARES_VERSION_STR[\t ]+\"([^\"]+)\".*" "\\1" VERSION "${verStr}")
# Define to the address where bug reports for this package should be sent.
set(PACKAGE_BUGREPORT "c-ares mailing list: http://cool.haxx.se/mailman/listinfo/c-ares")
# Define to the full name of this package.
set(PACKAGE_NAME ${PACKAGE})
# Define to the version of this package.
set(PACKAGE_VERSION ${VERSION})
# Define to the full name and version of this package.
set(PACKAGE_STRING "${PACKAGE} ${PACKAGE_VERSION}")
# Define to the one symbol short name of this package.
set(PACKAGE_TARNAME ${PACKAGE})
# Define to the home page for this package.
set(PACKAGE_URL)
########################################
configure_file(${CMAKE_SOURCE_DIR}/ares_config.in .)
configure_file(${CMAKE_BINARY_DIR}/ares_config.in ${CMAKE_BINARY_DIR}/ares_config.h)
add_definitions(-DHAVE_CONFIG_H)
########################################
set(code "
${cares_includes_ws2tcpip}
${cares_includes_sys_socket}
${cares_preprocess_callconv}
extern int FUNCALLCONV getpeername(\${arg1}, \${arg2} *, \${t} *);
int main (void)
{
  \${t} *lenptr = 0;
  if(0 != getpeername(0, 0, lenptr))
    return 1;
  ;
  return 0;
}
")
set(results
  GETPEERNAME_TYPE_ARG1
  GETPEERNAME_TYPE_ARG2
  CARES_TYPEOF_ARES_SOCKLEN_T # Integral data type used for ares_socklen_t.
  )
set(arg1List "int" "SOCKET")
set(arg2List "struct sockaddr" "void")
set(tList "socklen_t" "int" "size_t" "unsigned int" "long" "unsigned long" "void")
typeSignature(GETPEERNAME_TYPE "${code}" "${results}" arg1List arg2List tList)
##########
string(FIND ${CARES_TYPEOF_ARES_SOCKLEN_T} void isVoid)
if(NOT ${isVoid} EQUAL -1) # void found
  set(code "
${cares_includes_sys_socket}
typedef \${t} ares_socklen_t;
int main (void)
{
  ares_socklen_t dummy;
  ;
  return 0;
}
")
  set(tList "socklen_t" "int")
  set(results
    CARES_TYPEOF_ARES_SOCKLEN_T # Integral data type used for ares_socklen_t.
    )
  typeSignature(GETSOCKLEN_TYPE "${code}" "${results}" tList)
endif()
########################################
set(CMAKE_EXTRA_INCLUDE_FILES ${ARES_INCLUDES})
# The size of `ares_socklen_t', as computed by sizeof.
check_type_size(${CARES_TYPEOF_ARES_SOCKLEN_T} CARES_SIZEOF_ARES_SOCKLEN_T)
# The size of `long', as computed by sizeof.
check_type_size(long CARES_SIZEOF_LONG)
set(CMAKE_EXTRA_INCLUDE_FILES)
########################################
set(code "
\${inc}
typedef ${CARES_TYPEOF_ARES_SOCKLEN_T} ares_socklen_t;
typedef char dummy_arr[sizeof(ares_socklen_t) == ${CARES_SIZEOF_ARES_SOCKLEN_T} ? 1 : -1];
int main (void)
{
  ares_socklen_t dummy;
  ;
  return 0;
}
")
if(HAVE_WS2TCPIP_H)
  set(incList "${cares_includes_none}" "${cares_includes_ws2tcpip}")
else()
  set(incList "${cares_includes_none}" "${cares_includes_sys_types}" "${cares_includes_sys_socket}")
endif()
set(results pull)
typeSignature(CARES_PULL_HDRS "${code}" "${results}" incList)
if(${pull} STREQUAL ${cares_includes_ws2tcpip})
  # system header file ws2tcpip.h must be included by the external interface
  set(CARES_PULL_WS2TCPIP_H TRUE)
elseif(${pull} STREQUAL ${cares_includes_sys_types})
  # system header file sys/types.h must be included by the external interface
  set(CARES_PULL_SYS_TYPES_H TRUE)
elseif(${pull} STREQUAL ${cares_includes_sys_socket})
  # system header file sys/types.h must be included by the external interface
  set(CARES_PULL_SYS_TYPES_H TRUE)
  # system header file sys/socket.h must be included by the external interface
  set(CARES_PULL_SYS_SOCKET_H TRUE)
endif()
set_define(CARES_PULL_WS2TCPIP_H 1)
set_define(CARES_PULL_SYS_TYPES_H 1)
set_define(CARES_PULL_SYS_SOCKET_H 1)
##########
if(EXISTS ${CMAKE_SOURCE_DIR}/ares_build.h)
  file(REMOVE ${CMAKE_SOURCE_DIR}/ares_build.h)
endif()
configure_file(${CMAKE_SOURCE_DIR}/ares_build.in .)
configure_file(${CMAKE_BINARY_DIR}/ares_build.in ${CMAKE_BINARY_DIR}/ares_build.h)
##########
set(CMAKE_REQUIRED_LIBRARIES)
set(CMAKE_REQUIRED_DEFINITIONS)
include_directories(${CMAKE_BINARY_DIR})
