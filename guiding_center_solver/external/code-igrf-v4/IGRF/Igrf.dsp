# Microsoft Developer Studio Project File - Name="Igrf" - Package Owner=<4>
# Microsoft Developer Studio Generated Build File, Format Version 6.00
# ** DO NOT EDIT **

# TARGTYPE "Win32 (x86) Application" 0x0101

CFG=Igrf - Win32 Debug
!MESSAGE This is not a valid makefile. To build this project using NMAKE,
!MESSAGE use the Export Makefile command and run
!MESSAGE 
!MESSAGE NMAKE /f "Igrf.mak".
!MESSAGE 
!MESSAGE You can specify a configuration when running NMAKE
!MESSAGE by defining the macro CFG on the command line. For example:
!MESSAGE 
!MESSAGE NMAKE /f "Igrf.mak" CFG="Igrf - Win32 Debug"
!MESSAGE 
!MESSAGE Possible choices for configuration are:
!MESSAGE 
!MESSAGE "Igrf - Win32 Release" (based on "Win32 (x86) Application")
!MESSAGE "Igrf - Win32 Debug" (based on "Win32 (x86) Application")
!MESSAGE 

# Begin Project
# PROP AllowPerConfigDependencies 0
# PROP Scc_ProjName ""
# PROP Scc_LocalPath ""
CPP=cl.exe
F90=df.exe
MTL=midl.exe
RSC=rc.exe

!IF  "$(CFG)" == "Igrf - Win32 Release"

# PROP BASE Use_MFC 1
# PROP BASE Use_Debug_Libraries 0
# PROP BASE Output_Dir "Release"
# PROP BASE Intermediate_Dir "Release"
# PROP BASE Target_Dir ""
# PROP Use_MFC 1
# PROP Use_Debug_Libraries 0
# PROP Output_Dir "Release"
# PROP Intermediate_Dir "Release"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MT /W3 /GX /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD CPP /nologo /MT /W3 /GX /O1 /D "WIN32" /D "NDEBUG" /D "_WINDOWS" /FR /YX"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "NDEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "NDEBUG"
# ADD RSC /l 0x409 /d "NDEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 oldnames.lib /nologo /stack:0x2800 /subsystem:windows /machine:IX86
# ADD LINK32 oldnames.lib general.lib mwh1.lib mwhfort.lib igrfl2.lib /nologo /stack:0x2800 /subsystem:windows /machine:IX86 /nodefaultlib:"mfc42.lib" /nodefaultlib:"mfcs42.lib" /nodefaultlib:"msvcrt.lib" /libpath:"\geophys\utilclas\general\release" /libpath:"\geophys\utilclas\mwh1dll\release" /libpath:"\geophys\tauxe\mwhfort\release" /libpath:"\geophys\igrf\igrfl2\release"

!ELSEIF  "$(CFG)" == "Igrf - Win32 Debug"

# PROP BASE Use_MFC 1
# PROP BASE Use_Debug_Libraries 1
# PROP BASE Output_Dir "Debug"
# PROP BASE Intermediate_Dir "Debug"
# PROP BASE Target_Dir ""
# PROP Use_MFC 1
# PROP Use_Debug_Libraries 1
# PROP Output_Dir "Debug"
# PROP Intermediate_Dir "Debug"
# PROP Ignore_Export_Lib 0
# PROP Target_Dir ""
# ADD BASE CPP /nologo /MTd /W3 /Gm /GX /Zi /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX /FD /c
# ADD CPP /nologo /MTd /W3 /Gm /GX /ZI /Od /D "WIN32" /D "_DEBUG" /D "_WINDOWS" /FR /YX"stdafx.h" /FD /c
# ADD BASE MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD MTL /nologo /D "_DEBUG" /mktyplib203 /o "NUL" /win32
# ADD BASE RSC /l 0x409 /d "_DEBUG"
# ADD RSC /l 0x409 /d "_DEBUG"
BSC32=bscmake.exe
# ADD BASE BSC32 /nologo
# ADD BSC32 /nologo
LINK32=link.exe
# ADD BASE LINK32 oldnames.lib sheligdl.lib /nologo /stack:0x2800 /subsystem:windows /debug /machine:IX86 /pdbtype:sept
# ADD LINK32 oldnames.lib general.lib mwh1.lib mwhfort.lib igrfl2.lib /nologo /stack:0x2800 /subsystem:windows /debug /machine:IX86 /nodefaultlib:"msvcrtd.lib" /pdbtype:sept /libpath:"\geophys\utilclas\general\debug" /libpath:"\geophys\utilclas\mwh1dll\debug" /libpath:"\geophys\tauxe\mwhfort\debug" /libpath:"\geophys\igrf\igrfl2\debug"

!ENDIF 

# Begin Target

# Name "Igrf - Win32 Release"
# Name "Igrf - Win32 Debug"
# Begin Group "Source Files"

# PROP Default_Filter "cpp;c;cxx;rc;def;r;odl;hpj;bat"
# Begin Source File

SOURCE=.\IGRF.CPP
# End Source File
# Begin Source File

SOURCE=.\IGRFDOC.CPP
# End Source File
# Begin Source File

SOURCE=.\IGRFVIEW.CPP
# End Source File
# Begin Source File

SOURCE=.\MAINFRM.CPP
# End Source File
# Begin Source File

SOURCE=.\PROFDATE.CPP
# End Source File
# Begin Source File

SOURCE=.\PROFHT.CPP
# End Source File
# Begin Source File

SOURCE=.\PROFLAT.CPP
# End Source File
# Begin Source File

SOURCE=.\PROFLONG.CPP
# End Source File
# Begin Source File

SOURCE=.\SPLASH.CPP
# End Source File
# Begin Source File

SOURCE=.\STDAFX.CPP
# End Source File
# End Group
# Begin Group "Header Files"

# PROP Default_Filter "h;hpp;hxx;hm;inl;fi;fd"
# Begin Source File

SOURCE=.\IGRF.H
# End Source File
# Begin Source File

SOURCE=.\IGRFDLG.H
# End Source File
# Begin Source File

SOURCE=.\IGRFDOC.H
# End Source File
# Begin Source File

SOURCE=.\IGRFVIEW.H
# End Source File
# Begin Source File

SOURCE=.\MAINFRM.H
# End Source File
# Begin Source File

SOURCE=.\PROFDATE.H
# End Source File
# Begin Source File

SOURCE=.\PROFHT.H
# End Source File
# Begin Source File

SOURCE=.\PROFLAT.H
# End Source File
# Begin Source File

SOURCE=.\PROFLONG.H
# End Source File
# Begin Source File

SOURCE=.\SPLASH.H
# End Source File
# End Group
# Begin Group "Resource Files"

# PROP Default_Filter "ico;cur;bmp;dlg;rc2;rct;bin;cnt;rtf;gif;jpg;jpeg;jpe"
# Begin Source File

SOURCE=.\RES\ICO00001.ICO
# End Source File
# Begin Source File

SOURCE=.\RES\ICON1.ICO
# End Source File
# Begin Source File

SOURCE=.\RES\IGRF.ICO
# End Source File
# Begin Source File

SOURCE=.\IGRF.RC
# End Source File
# Begin Source File

SOURCE=.\res\igrf.rc2
# End Source File
# Begin Source File

SOURCE=.\RES\IGRFDOC.ICO
# End Source File
# Begin Source File

SOURCE=.\RES\setup_sml.bmp
# End Source File
# Begin Source File

SOURCE=.\RES\TOOLBAR.BMP
# End Source File
# End Group
# End Target
# End Project
