bin_PROGRAMS = drill
AM_CPPFLAGS = @DRILL_CFLAGS@
AM_LDFLAGS = @DRILL_LIBS@

SUFFIXES: .w .tex .pdf
.w.c:
	ctangle $< $@
.w.tex:
	cweave $< $@
.tex.pdf:
	pdftex $<
