# Microsoft Visual C++ generated build script - Do not modify

PROJ = IGRF
DEBUG = 1
PROGTYPE = 0
CALLER = 
ARGS = 
DLLS = 
D_RCDEFINES = /d_DEBUG 
R_RCDEFINES = /dNDEBUG 
ORIGIN = MSVC
ORIGIN_VER = 1.00
PROJPATH = C:\GEOPHYS\IGRF\
USEMFC = 1
CC = cl
CPP = cl
CXX = cl
CCREATEPCHFLAG = 
CPPCREATEPCHFLAG = 
CUSEPCHFLAG = 
CPPUSEPCHFLAG = 
FIRSTC =             
FIRSTCPP = STDAFX.CPP  
RC = rc
CFLAGS_D_WEXE = /nologo /G2 /W3 /Zi /AL /Od /D "_DEBUG" /FR /GA /Fd"IGRF.PDB"
CFLAGS_R_WEXE = /nologo /Gs /G2 /W3 /AM /O1 /D "NDEBUG" /FR /GA 
LFLAGS_D_WEXE = /NOLOGO /NOD /NOE /PACKC:61440 /STACK:10240 /ALIGN:16 /ONERROR:NOEXE /CO  
LFLAGS_R_WEXE = /NOLOGO /NOD /PACKC:61440 /STACK:10240 /ALIGN:16 /ONERROR:NOEXE  
LIBS_D_WEXE = lafxcwd oldnames libw llibcew sheligdl commdlg.lib olecli.lib olesvr.lib shell.lib 
LIBS_R_WEXE = mafxcw oldnames libw mlibcew commdlg.lib olecli.lib olesvr.lib shell.lib 
RCFLAGS = /nologo /z 
RESFLAGS = /nologo /t /k
RUNFLAGS = 
DEFFILE = IGRF.DEF
OBJS_EXT = 
LIBS_EXT = ..\UTILCLAS\GENMWH1.LIB ..\UTILCLAS\GENERAL.LIB SHELIGDL.LIB 
!if "$(DEBUG)" == "1"
CFLAGS = $(CFLAGS_D_WEXE)
LFLAGS = $(LFLAGS_D_WEXE)
LIBS = $(LIBS_D_WEXE)
MAPFILE = nul
RCDEFINES = $(D_RCDEFINES)
!else
CFLAGS = $(CFLAGS_R_WEXE)
LFLAGS = $(LFLAGS_R_WEXE)
LIBS = $(LIBS_R_WEXE)
MAPFILE = nul
RCDEFINES = $(R_RCDEFINES)
!endif
!if [if exist MSVC.BND del MSVC.BND]
!endif
SBRS = STDAFX.SBR \
		IGRF.SBR \
		MAINFRM.SBR \
		IGRFDOC.SBR \
		IGRFDLG.SBR \
		SPLASH.SBR \
		IGRFVIEW.SBR \
		PROFLAT.SBR \
		PROFLONG.SBR \
		PROFHT.SBR \
		PROFDATE.SBR


GENMWH1_DEP = 

GENERAL_DEP = 

SHELIGDL_DEP = 

IGRF_RCDEP = c:\geophys\igrf\res\igrf.ico \
	c:\geophys\igrf\res\igrfdoc.ico \
	c:\geophys\igrf\res\icon1.ico \
	c:\geophys\igrf\res\ico00001.ico \
	c:\geophys\igrf\res\igrf.rc2 \
	c:\geophys\igrf\igrflib\igrfgen.rc


STDAFX_DEP = c:\geophys\igrf\stdafx.h


IGRF_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h \
	c:\geophys\igrf\igrf.h \
	c:\geophys\igrf\mainfrm.h \
	c:\geophys\igrf\igrfdoc.h \
	c:\geophys\igrf\igrfview.h \
	c:\geophys\utilclas\general.h \
	c:\geophys\utilclas\genmwh1.h \
	c:\geophys\utilclas\genmwh2.h \
	c:\geophys\utilclas\genmfc.h \
	c:\geophys\igrf\igrfdlg.h


MAINFRM_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h \
	c:\geophys\igrf\igrf.h \
	c:\geophys\igrf\mainfrm.h


IGRFDOC_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h \
	c:\geophys\igrf\igrf.h \
	c:\geophys\igrf\igrfdoc.h


IGRFDLG_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h \
	c:\geophys\igrf\igrf.h \
	c:\geophys\utilclas\general.h \
	c:\geophys\utilclas\genmwh1.h \
	c:\geophys\utilclas\genmwh2.h \
	c:\geophys\utilclas\genmfc.h \
	c:\geophys\igrf\igrfdlg.h \
	c:\geophys\utilclas\viewprnt.h


SPLASH_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h


IGRFVIEW_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h \
	c:\geophys\igrf\igrf.h \
	c:\geophys\igrf\igrfdoc.h \
	c:\geophys\igrf\igrfview.h


all:	$(PROJ).EXE $(PROJ).BSC

IGRF.RES:	IGRF.RC $(IGRF_RCDEP)
	$(RC) $(RCFLAGS) $(RCDEFINES) -r IGRF.RC

STDAFX.OBJ:	STDAFX.CPP $(STDAFX_DEP)
	$(CPP) $(CFLAGS) $(CPPCREATEPCHFLAG) /c STDAFX.CPP

IGRF.OBJ:	IGRF.CPP $(IGRF_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c IGRF.CPP

MAINFRM.OBJ:	MAINFRM.CPP $(MAINFRM_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c MAINFRM.CPP

IGRFDOC.OBJ:	IGRFDOC.CPP $(IGRFDOC_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c IGRFDOC.CPP

IGRFDLG.OBJ:	IGRFDLG.CPP $(IGRFDLG_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c IGRFDLG.CPP

SPLASH.OBJ:	SPLASH.CPP $(SPLASH_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c SPLASH.CPP

IGRFVIEW.OBJ:	IGRFVIEW.CPP $(IGRFVIEW_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c IGRFVIEW.CPP

PROFLAT.OBJ:	PROFLAT.CPP $(PROFLAT_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c PROFLAT.CPP

PROFLONG.OBJ:	PROFLONG.CPP $(PROFLONG_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c PROFLONG.CPP

PROFHT.OBJ:	PROFHT.CPP $(PROFHT_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c PROFHT.CPP

PROFDATE.OBJ:	PROFDATE.CPP $(PROFDATE_DEP)
	$(CPP) $(CFLAGS) $(CPPUSEPCHFLAG) /c PROFDATE.CPP


$(PROJ).EXE::	IGRF.RES

$(PROJ).EXE::	STDAFX.OBJ IGRF.OBJ MAINFRM.OBJ IGRFDOC.OBJ IGRFDLG.OBJ SPLASH.OBJ \
	IGRFVIEW.OBJ PROFLAT.OBJ PROFLONG.OBJ PROFHT.OBJ PROFDATE.OBJ $(OBJS_EXT) $(DEFFILE)
	echo >NUL @<<$(PROJ).CRF
STDAFX.OBJ +
IGRF.OBJ +
MAINFRM.OBJ +
IGRFDOC.OBJ +
IGRFDLG.OBJ +
SPLASH.OBJ +
IGRFVIEW.OBJ +
PROFLAT.OBJ +
PROFLONG.OBJ +
PROFHT.OBJ +
PROFDATE.OBJ +
$(OBJS_EXT)
$(PROJ).EXE
$(MAPFILE)
c:\msvc\lib\+
c:\msvc\mfc\lib\+
..\UTILCLAS\GENMWH1.LIB+
..\UTILCLAS\GENERAL.LIB+
SHELIGDL.LIB+
$(LIBS)
$(DEFFILE);
<<
	link $(LFLAGS) @$(PROJ).CRF
	$(RC) $(RESFLAGS) IGRF.RES $@
	@copy $(PROJ).CRF MSVC.BND

$(PROJ).EXE::	IGRF.RES
	if not exist MSVC.BND 	$(RC) $(RESFLAGS) IGRF.RES $@

run: $(PROJ).EXE
	$(PROJ) $(RUNFLAGS)


$(PROJ).BSC: $(SBRS)
	bscmake @<<
/o$@ $(SBRS)
<<
