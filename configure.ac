AC_INIT([drill], [0.1], [maedaqu@gmail.com], [],
  [https://github.com/chu-mirror/drill])
AC_CONFIG_SRCDIR([src/drill.w])
AC_CONFIG_AUX_DIR([utils])
AM_INIT_AUTOMAKE([-Wall -Werror foreign])
AC_PROG_CC
dnl AC_SEARCH_LIBS([json_object_get], [json-c], [INCLUDES="$INCLUDES $(pkg-config --cflags json-c)"])
PKG_CHECK_MODULES([DRILL], [json-c])
AC_CONFIG_HEADERS([config.h])
AC_CONFIG_FILES([
  Makefile
  src/Makefile
])
AC_OUTPUT

