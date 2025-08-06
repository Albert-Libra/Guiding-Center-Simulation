rem @echo off
REM -- First make map file from App Studio generated resource.h
echo // MAKEHELP.BAT generated Help Map file.  Used by IGRF.HPJ. >hlp\igrf.hm
echo. >>hlp\igrf.hm
echo // Commands (ID_* and IDM_*) >>hlp\igrf.hm
makehm ID_,HID_,0x10000 IDM_,HIDM_,0x10000 resource.h >>hlp\igrf.hm
echo. >>hlp\igrf.hm
echo // Prompts (IDP_*) >>hlp\igrf.hm
makehm IDP_,HIDP_,0x30000 resource.h >>hlp\igrf.hm
echo. >>hlp\igrf.hm
echo // Resources (IDR_*) >>hlp\igrf.hm
makehm IDR_,HIDR_,0x20000 resource.h >>hlp\igrf.hm
echo. >>hlp\igrf.hm
echo // Dialogs (IDD_*) >>hlp\igrf.hm
makehm IDD_,HIDD_,0x20000 resource.h >>hlp\igrf.hm
echo. >>hlp\igrf.hm
echo // Frame Controls (IDW_*) >>hlp\igrf.hm
makehm IDW_,HIDW_,0x50000 resource.h >>hlp\igrf.hm

makehm ID_,HID_,0x11000 IDM_,HIDM_,0x11000 igrflib\resource.h >>hlp\igrf.hm
makehm IDP_,HIDP_,0x31000 igrflib\resource.h >>hlp\igrf.hm
makehm IDR_,HIDR_,0x21000  igrflib\resource.h >>hlp\igrf.hm
makehm IDD_,HIDD_,0x21000  igrflib\resource.h >>hlp\igrf.hm
makehm IDW_,HIDW_,0x51000  igrflib\resource.h >>hlp\igrf.hm
REM -- Make help for Project IGRF
rem call hc31 igrf.hpj
echo.
