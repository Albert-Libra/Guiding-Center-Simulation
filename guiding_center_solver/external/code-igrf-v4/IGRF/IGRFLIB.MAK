# Microsoft Visual C++ generated build script - Do not modify

PROJ = IGRFLIB
DEBUG = 1
PROGTYPE = 1
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
CPPCREATEPCHFLAG = /YcSTDAFX.H
CUSEPCHFLAG = 
CPPUSEPCHFLAG = /YuSTDAFX.H
FIRSTC =             
FIRSTCPP = IGRFDLG.CPP 
RC = rc
CFLAGS_D_WDLL = /nologo /G2 /W3 /Zi /ALw /Od /D "_DEBUG" /GD /Fd"IGRFLIB.PDB" 
CFLAGS_R_WDLL = /nologo /W3 /ALw /O1 /D "NDEBUG" /FR /GD 
LFLAGS_D_WDLL = /NOLOGO /ONERROR:NOEXE /NOD /PACKC:61440 /CO /NOE /ALIGN:16 /MAP:FULL
LFLAGS_R_WDLL = /NOLOGO /ONERROR:NOEXE /NOD /PACKC:61440 /NOE /ALIGN:16 /MAP:FULL
LIBS_D_WDLL = lafxdwd oldnames libw commdlg shell olecli olesvr ldllcew
LIBS_R_WDLL = lafxdw oldnames libw commdlg shell olecli olesvr ldllcew
RCFLAGS = /nologo /z
RESFLAGS = /nologo /t
RUNFLAGS = 
DEFFILE = IGRF.DEF
OBJS_EXT = 
LIBS_EXT = 
!if "$(DEBUG)" == "1"
CFLAGS = $(CFLAGS_D_WDLL)
LFLAGS = $(LFLAGS_D_WDLL)
LIBS = $(LIBS_D_WDLL)
MAPFILE = nul
RCDEFINES = $(D_RCDEFINES)
!else
CFLAGS = $(CFLAGS_R_WDLL)
LFLAGS = $(LFLAGS_R_WDLL)
LIBS = $(LIBS_R_WDLL)
MAPFILE = nul
RCDEFINES = $(R_RCDEFINES)
!endif
!if [if exist MSVC.BND del MSVC.BND]
!endif
SBRS = IGRFDLG.SBR


IGRF_RCDEP = c:\geophys\igrf\res\igrf.ico \
	c:\geophys\igrf\res\igrfdoc.ico \
	c:\geophys\igrf\res\icon1.ico \
	c:\geophys\igrf\res\ico00001.ico \
	c:\geophys\igrf\res\igrf.rc2 \
	c:\geophys\igrf\igrflib\igrfgen.rc


IGRFDLG_DEP = c:\geophys\igrf\stdafx.h \
	c:\geophys\igrf\splash.h \
	c:\geophys\utilclas\general.h \
	c:\geophys\utilclas\genmwh1.h \
	c:\geophys\utilclas\genmwh2.h \
	c:\geophys\utilclas\genmfc.h \
	c:\geophys\igrf\igrfdoc.h \
	c:\geophys\igrf\igrf.h \
	c:\geophys\igrf\igrfdlg.h \
	c:\geophys\utilclas\viewprnt.h


all:	$(PROJ).DLL

IGRF.RES:	IGRF.RC $(IGRF_RCDEP)
	$(RC) $(RCFLAGS) $(RCDEFINES) -r IGRF.RC

IGRFDLG.OBJ:	IGRFDLG.CPP $(IGRFDLG_DEP)
	$(CPP) $(CFLAGS) $(CPPCREATEPCHFLAG) /c IGRFDLG.CPP


$(PROJ).DLL::	IGRF.RES

$(PROJ).DLL::	IGRFDLG.OBJ $(OBJS_EXT) $(DEFFILE)
	echo >NUL @<<$(PROJ).CRF
IGRFDLG.OBJ +
$(OBJS_EXT)
$(PROJ).DLL
$(MAPFILE)
c:\msvc\lib\+
c:\msvc\mfc\lib\+
$(LIBS)
$(DEFFILE);
<<
	link $(LFLAGS) @$(PROJ).CRF
	$(RC) $(RESFLAGS) IGRF.RES $@
	@copy $(PROJ).CRF MSVC.BND
	implib /nowep $(PROJ).LIB $(PROJ).DLL

$(PROJ).DLL::	IGRF.RES
	if not exist MSVC.BND 	$(RC) $(RESFLAGS) IGRF.RES $@

run: $(PROJ).DLL
	$(PROJ) $(RUNFLAGS)


$(PROJ).BSC: $(SBRS)
	bscmake @<<
/o$@ $(SBRS)
<<
