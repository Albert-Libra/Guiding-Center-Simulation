// igrfdlg.cpp : implementation file
//
#include "stdafx.h"
#include "splash.h"
#define mwh_fortran
// comment out above line if IGFCALC and INITIZE routines are not fortran
#include "\geophys\tauxe\mwhfort\mwhfort.h"
#include "\geophys\utilclas\general.h" 
//#include "mainfrm.h"
#include "igrfdoc.h"
#include "igrf.h"
#include "igrfdlg.h" 
#include "igrfview.h"

#include "\geophys\utilclas\viewprnt.h"
#include <math.h>  



#ifdef _DEBUG
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif
static TCHAR BASED_CODE szViewWinPos[]=_T("IGRFDlgWinPos");
/////////////////////////////////////////////////////////////////////////////
// CIGRFDlg

IMPLEMENT_DYNCREATE(CIGRFDlg, CFormView)

CIGRFDlg::CIGRFDlg()
	: CFormView(CIGRFDlg::IDD)
{
	//{{AFX_DATA_INIT(CIGRFDlg)
	m_Altitude = 0;
	m_Dec = 0;
	m_Inc = 0;
	m_nLatDeg = 0;
	m_nLongDeg = 0;
	m_nMonth = 1;
	m_total = 0;
	m_X = 0;
	m_Y = 0;
	m_nYear = 1990;
	m_Z = 0;
	m_LatMin = 0;
	m_LongMin = 0;
	m_FLGLONG = 0;
	m_FLGLAT = 0;
	//}}AFX_DATA_INIT
	m_ValChanged=FALSE;
	m_Focus=FOCUS_NONE;
	m_errorcode=0;
	m_bDoingCalc=FALSE;
}

CIGRFDlg::~CIGRFDlg()
{
}

void CIGRFDlg::DoDataExchange(CDataExchange* pDX)
{
	CFormView::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CIGRFDlg)
	DDX_Text(pDX, IDC_ALTITUDE, m_Altitude);
	DDV_MinMaxFloat(pDX, m_Altitude, 0.f, 30000.f);
	DDX_Text(pDX, IDC_DEC, m_Dec);
	DDX_Text(pDX, IDC_INC, m_Inc);
	DDX_Text(pDX, IDC_LATDEG, m_nLatDeg);
	DDV_MinMaxInt(pDX, m_nLatDeg, 0, 90);
	DDX_Text(pDX, IDC_LONGDEG, m_nLongDeg);
	DDV_MinMaxInt(pDX, m_nLongDeg, 0, 180);
	DDX_Text(pDX, IDC_MONTH, m_nMonth);
	DDV_MinMaxFloat(pDX, m_nMonth, 1.f, 12.99f);
	DDX_Text(pDX, IDC_TOTAL, m_total);
	DDX_Text(pDX, IDC_X, m_X);
	DDX_Text(pDX, IDC_Y, m_Y);
	DDX_Text(pDX, IDC_YEAR, m_nYear);
	DDX_Text(pDX, IDC_Z, m_Z);
	DDX_Text(pDX, IDC_LATMIN, m_LatMin);
	DDV_MinMaxFloat(pDX, m_LatMin, 0.f, 60.f);
	DDX_Text(pDX, IDC_LONGMIN, m_LongMin);
	DDV_MinMaxFloat(pDX, m_LongMin, 0.f, 60.f);
	DDX_Radio(pDX, IDC_EAST, m_FLGLONG);
	DDX_Radio(pDX, IDC_NORTH, m_FLGLAT);
	//}}AFX_DATA_MAP
CIgrfApp *pApp=(CIgrfApp *) AfxGetApp();
//ASSERT( pApp->IsKindOf(RUNTIME_CLASS(CIgrfApp)));
	DDV_MinMaxInt(pDX, m_nYear, pApp->m_YearStart, pApp->m_YearEnd+9);
}


BEGIN_MESSAGE_MAP(CIGRFDlg, CFormView)
	//{{AFX_MSG_MAP(CIGRFDlg)
	ON_BN_CLICKED(ID_IGRF_HELP, OnIgrfHelp)
	ON_EN_KILLFOCUS(IDC_ALTITUDE, OnKillfocus)
	ON_EN_CHANGE(IDC_YEAR, OnChange)
	ON_EN_SETFOCUS(IDC_ALTITUDE, OnSetfocusAltitude)
	ON_EN_SETFOCUS(IDC_LATDEG, OnSetfocusLatdeg)
	ON_EN_SETFOCUS(IDC_LATMIN, OnSetfocusLatmin)
	ON_EN_SETFOCUS(IDC_LONGDEG, OnSetfocusLongdeg)
	ON_EN_SETFOCUS(IDC_LONGMIN, OnSetfocusLongmin)
	ON_EN_SETFOCUS(IDC_MONTH, OnSetfocusMonth)
	ON_EN_SETFOCUS(IDC_YEAR, OnSetfocusYear)
	ON_BN_CLICKED(IDC_EAST, OnLongClicked)
	ON_BN_CLICKED(IDC_NORTH, OnLatClicked)
	ON_COMMAND(ID_FILE_PRINT, OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, OnFilePrintPreview)
	ON_WM_SHOWWINDOW()
	ON_WM_DESTROY()
	ON_EN_KILLFOCUS(IDC_DEC, OnKillfocus)
	ON_EN_KILLFOCUS(IDC_LATDEG, OnKillfocus)
	ON_EN_KILLFOCUS(IDC_LATMIN, OnKillfocus)
	ON_EN_KILLFOCUS(IDC_LONGDEG, OnKillfocus)
	ON_EN_KILLFOCUS(IDC_LONGMIN, OnKillfocus)
	ON_EN_KILLFOCUS(IDC_MONTH, OnKillfocus)
	ON_EN_KILLFOCUS(IDC_YEAR, OnKillfocus)
	ON_EN_CHANGE(IDC_MONTH, OnChange)
	ON_EN_CHANGE(IDC_LONGMIN, OnChange)
	ON_EN_CHANGE(IDC_LONGDEG, OnChange)
	ON_EN_CHANGE(IDC_LATMIN, OnChange)
	ON_EN_CHANGE(IDC_LATDEG, OnChange)
	ON_EN_CHANGE(IDC_ALTITUDE, OnChange)
	ON_BN_CLICKED(IDC_WEST, OnLongClicked)
	ON_BN_CLICKED(IDC_SOUTH, OnLatClicked)
	//}}AFX_MSG_MAP
//	ON_COMMAND(ID_FILE_PRINT, OnFilePrint)
//	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CView::OnFilePrintPreview)
END_MESSAGE_MAP()



/////////////////////////////////////////////////////////////////////////////
// CIGRFDlg message handlers


///////////////////////////////////////////////////// 
 BOOL CIGRFDlg::OnPreparePrinting(CPrintInfo* pInfo)
{
	// default preparation
	return DoPreparePrinting(pInfo);
}

 /////////////////////////////////////////////////////////////////////////////
// CIGRFDlg printing

// The following code shows the technique of setting up a CDC to do
//  the appropriate scaling for printing and print preview.
// The actual output HDC is then used to draw the individual controls.
// This technique sends the WM_PAINT message to the control passing
//  the HDC as the 'wParam'.  This is an alternative painting technique
//  that most Windows controls and all VB controls support.
// This technique has many caveats that make it inappropriate for some
//  cases.  If you find the general technique inappropriate, you can
//  add special case code to handle the printing of the troublesome
//  controls.
//  * If you are using non-VBX custom controls, that do not support
//     the WM_PAINT technique, they will not be printed
//  * Some controls may not result in the desired output format
//     since the controls print in the same fashion as they
//     are displayed on the screen.
//  * Some controls assume they are always being displayed on the
//     screen.  This sometimes results in incorrect fonts being
//     used and bitmaps drawn incorrectly.
//  * The implementation of control printing does not support
//     WS_VSCROLL and WS_HSCROLL styles correctly.

void CIGRFDlg::OnPrint(CDC* pDC, CPrintInfo*)
{
	//BLOCK: Set up scale mode
	{
		CClientDC dcScreen(NULL);
		pDC->SetMapMode(MM_ANISOTROPIC);
		// map 1 screen logical inch to 1 printer (/output) logical inch
		pDC->SetWindowExt(dcScreen.GetDeviceCaps(LOGPIXELSX),
				dcScreen.GetDeviceCaps(LOGPIXELSX));
		pDC->SetViewportExt(pDC->GetDeviceCaps(LOGPIXELSX),
				pDC->GetDeviceCaps(LOGPIXELSX));
	}
	// we must also offset the window positions relative to the scroll offset

	// We cheat here since some controls do not paint if they are invisible,
	//   so we temporary make set the appropriate visible bits during preview
	//   mode so the controls think they are visible even though they aren't.
	HWND hWndCheatVisible = NULL;
	if (!IsWindowVisible())
	{
		// walk up to the top until we find the invisible window
		for (HWND hWnd = m_hWnd;
			hWnd != NULL; hWnd = ::GetParent(hWnd))
		{
			ASSERT(hWnd != NULL);
			DWORD dwStyle = ::GetWindowLong(hWnd, GWL_STYLE);
			if ((dwStyle & WS_VISIBLE) == 0)
			{
				::SetWindowLong(hWnd, GWL_STYLE, dwStyle | WS_VISIBLE);
				hWndCheatVisible = hWnd;
				break;
			}
		}
		ASSERT(hWndCheatVisible != NULL);
	}


	CPen pen(PS_SOLID, 1, RGB(0,0,0));  // solid black pen
	CPen* pOldPen = pDC->SelectObject(&pen);
	ASSERT(pDC->GetWindowOrg() == CPoint(0,0));
	PaintChildWindows(m_hWnd, pDC, GetDeviceScrollPosition());
	ASSERT(pDC->GetWindowOrg() == CPoint(0,0));
	pDC->SelectObject(pOldPen);

	if (hWndCheatVisible != NULL)
		::SetWindowLong(hWndCheatVisible, GWL_STYLE,
			::GetWindowLong(hWndCheatVisible, GWL_STYLE) &~ WS_VISIBLE);
}

void CIGRFDlg::PaintChildWindows(HWND hWndParent, CDC* pDC, CPoint ptOffset)
{
	for (HWND hWndChild = ::GetTopWindow(hWndParent);
		hWndChild != NULL; hWndChild = ::GetNextWindow(hWndChild, GW_HWNDNEXT))
	{
		CRect rect;
		::GetWindowRect(hWndChild, rect);       // window rect in screen coords
		ScreenToClient(&rect);                  // relative to this view

		HDC hdcOut = pDC->m_hDC;
#ifdef _DEBUG
		CPoint pt = pDC->GetWindowOrg();
		ASSERT(pt.x == 0 && pt.y == 0);
#endif

		DWORD dwStyle = ::GetWindowLong(hWndChild, GWL_STYLE);
		if (dwStyle & (WS_HSCROLL|WS_VSCROLL))
		{
			TRACE("Warning: printing control with scrollbars not supported\n");
		}
		if (dwStyle & WS_BORDER)
		{
			// the only case we special case handle - manually drawn border
			::Rectangle(hdcOut, rect.left, rect.top, rect.right, rect.bottom);
			rect.InflateRect(-1,-1);        // 1 logical pixel
		}

		pDC->SaveDC();
		{
			CPoint pt(ptOffset.x + rect.left, ptOffset.y + rect.top);
			pDC->LPtoDP(&pt);
			pDC->OffsetViewportOrg(pt.x, pt.y);
				// set the viewport origin so that the window origin
				//  can be changed by the control

			// draw it using a non-virtual HDC
			::SendMessage(hWndChild, WM_PAINT, (WPARAM)hdcOut, 0L);
		}
		pDC->RestoreDC(-1);

		if (::GetTopWindow(hWndChild) != NULL)
			PaintChildWindows(hWndChild, pDC, ptOffset);
	}
}
 
void CIGRFDlg::OnIgrfHelp()
{
AfxGetApp()->WinHelp( (DWORD) (0x20006));	
	
}
void CIGRFDlg::OnFilePrint()
{
	CPrintInfo printInfo;           // Get Default print info
	ASSERT(printInfo.m_pPD != NULL);    // must be set

	if (OnPreparePrinting(&printInfo))
	{       // print if OK
		ASSERT(printInfo.m_pPD->m_pd.hDC != NULL);
				// must be set (did you remember to call DoPreparePrinting?)
		CDC dcPrint;
		dcPrint.Attach(printInfo.m_pPD->m_pd.hDC);          // attach printer dc
		dcPrint.m_bPrinting = TRUE;
		OnBeginPrinting(&dcPrint, &printInfo);
		CPrintingDialog dlgPrintStatus(this);
		CString docTitle = "IGRF"; //GetDocument()->GetTitle();

		dlgPrintStatus.SetDlgItemText(AFX_IDC_PRINT_DOCNAME, docTitle);
		dlgPrintStatus.SetDlgItemText(AFX_IDC_PRINT_PRINTERNAME,
			printInfo.m_pPD->GetDeviceName());

		CString strPort;
		AfxFormatString1(strPort, AFX_IDS_PRINTONPORT,
			printInfo.m_pPD->GetPortName());
		dlgPrintStatus.SetDlgItemText(AFX_IDC_PRINT_PORTNAME, strPort);
		dlgPrintStatus.ShowWindow(SW_SHOW);
		dcPrint.SetAbortProc(_AfxAbortProc);
		if (docTitle.GetLength() > 31)
			docTitle.ReleaseBuffer(31);
		DOCINFO docInfo;
		docInfo.cbSize = sizeof(DOCINFO);
		docInfo.lpszDocName = docTitle;
		docInfo.lpszOutput = NULL;
		if (dcPrint.StartDoc(&docInfo) == SP_ERROR)
		{
			AfxMessageBox(AFX_IDP_FAILED_TO_START_PRINT);
			return;
		}
		AfxGetMainWnd()->EnableWindow(FALSE);   // Disable main window
		UINT nEndPage = printInfo.GetToPage();
		UINT nStartPage = printInfo.GetFromPage();

		// Guarantee values are in the valid range
		if (nEndPage < printInfo.GetMinPage())
			nEndPage = printInfo.GetMinPage();
		if (nEndPage > printInfo.GetMaxPage())
			nEndPage = printInfo.GetMaxPage();

		if (nStartPage < printInfo.GetMinPage())
			nStartPage = printInfo.GetMinPage();
		if (nStartPage > printInfo.GetMaxPage())
			nStartPage = printInfo.GetMaxPage();

		int nStep = (nEndPage >= nStartPage) ? 1 : -1;
		nEndPage = (nEndPage == 0xffff) ? 0xffff : nEndPage + nStep;

		BOOL bError = FALSE;
		for (printInfo.m_nCurPage = nStartPage;
			!bError && printInfo.m_nCurPage != nEndPage;
			printInfo.m_nCurPage += nStep)
		{
			OnPrepareDC(&dcPrint, &printInfo);
			if (!printInfo.m_bContinuePrinting)
				break;          // reached end of print

			// Set up drawing rect to entire page (in logical coordinates)
			printInfo.m_rectDraw.SetRect(0, 0, dcPrint.GetDeviceCaps(HORZRES),
											   dcPrint.GetDeviceCaps(VERTRES));
			dcPrint.DPtoLP(&printInfo.m_rectDraw);
			CString strFmt;
			VERIFY(strFmt.LoadString(AFX_IDS_PRINTPAGENUM));
			char szBuf[80];
			wsprintf(szBuf, strFmt, printInfo.m_nCurPage);
			dlgPrintStatus.SetDlgItemText(AFX_IDC_PRINT_PAGENUM, szBuf);

			VERIFY(dcPrint.StartPage());
			OnPrint(&dcPrint, &printInfo);
			if (dcPrint.EndPage() < 0)
				bError = TRUE;
		}
		if (!bError)
			dcPrint.EndDoc();
		AfxGetMainWnd()->EnableWindow(TRUE);    // Enable main window
		OnEndPrinting(&dcPrint, &printInfo);        // Clean up after printing
		dlgPrintStatus.DestroyWindow();
	}
}



void CIGRFDlg::OnFilePrintPreview() 
{
CView::OnFilePrintPreview();
}

BOOL CIGRFDlg::OnCalculate()
{//returns true if a fortran or data error, false if ok
	float latitude,longitude,year; 
	int coordtype;
	m_bDoingCalc=TRUE;
	IGRFRESULTS res;      // structure to hold results
	 latitude=ToDecimalDeg(m_nLatDeg, m_LatMin); // convert to decimal
	 if(m_FLGLAT ==1) latitude =-latitude;  // -ve if in south
	 longitude=ToDecimalDeg(m_nLongDeg,m_LongMin);
	if(m_FLGLONG ==1) longitude=-longitude;    // -ve if west of GM
	 // convert to decimal year -1 since jan 01 is ~0.0 and dec 30 ~1.0
	 year=(float) m_nYear + ((m_nMonth-1)/12.0F);
	coordtype=GEODETIC;
	CIgrfApp *pApp=	(CIgrfApp *) AfxGetApp();
	if(year <pApp->m_YearStart || year >=((pApp->m_YearEnd)+10))
		{// year is outside the range of the input data files
		DisplayInvalidData(IGRF_YEAR);
		return TRUE;
		}
	ASSERT(m_Altitude >=0);
//	ASSERT(latitude >=-90 && latitude <=90);
//	ASSERT(longitude >=-180 && longitude <=180);
//need to set the cur direct to place exe is found, since this also where dat found
//otherwise the fortran will find the *.dat
	SetCurrentDirectoryToExePath(TRUE);
	if( (m_errorcode=CalculateIGRF(res, year,m_Altitude,latitude,longitude)) !=0)
		{//error detected
		if(m_errorcode <0) WriteFortranError(m_errorcode);
		if(m_errorcode >0) {DisplayInvalidData(m_errorcode); m_errorcode=0;}
		m_bDoingCalc=FALSE;
		SetCurrentDirectoryToExePath(FALSE);
		return (TRUE);
		}
	ASSERT(m_errorcode==0);
	SetCurrentDirectoryToExePath(FALSE);
	// now copy into controls
	char num[33];
	ftoadS(res.igrf.Int,num,1);
	GetDlgItem(IDC_TOTAL)->SetWindowText(num); // total field
	ftoadS(res.x,num,1);
	GetDlgItem(IDC_X)->SetWindowText(num); // X
	ftoadS(res.y,num,1);
	GetDlgItem(IDC_Y)->SetWindowText(num); // Y
	ftoadS(res.z,num,1);
	GetDlgItem(IDC_Z)->SetWindowText(num); // Z
	if( res.igrf.Dec <0.0) res.igrf.Dec=(float) (360.0+res.igrf.Dec); //make sure +ve
	ftoadS(res.igrf.Dec,num,1);
	GetDlgItem(IDC_DEC)->SetWindowText(num); // Dec
	ftoadS(res.igrf.Inc,num,1);
	GetDlgItem(IDC_INC)->SetWindowText(num); // Inc
	m_bDoingCalc=FALSE;
	return(FALSE);
}

void CIGRFDlg::OnKillfocus()
{// possibly do the calculation
if(m_ValChanged)
	{	// user has changed value in last edit box to have focus
	if( UpdateData(TRUE) ==0)
		{
		TRACE0(" CIGRFDlg updatedata failed during dialog killfocus\n");	
		return;
		} 
		if(m_errorcode ==0 && !m_bDoingCalc) OnCalculate();//do not do calc if a previous fortran error or doing one already
	}
m_ValChanged=FALSE;
m_Focus=FOCUS_NONE;
	
}

void CIGRFDlg::OnChange()
{
m_ValChanged=TRUE;
}

void CIGRFDlg::OnSetfocusAltitude()
{
m_Focus=IDC_ALTITUDE;	
}

void CIGRFDlg::OnSetfocusLatdeg()
{
m_Focus=IDC_LATDEG;	
}

void CIGRFDlg::OnSetfocusLatmin()
{
m_Focus=IDC_LATMIN;	
}

void CIGRFDlg::OnSetfocusLongdeg()
{
m_Focus=IDC_LONGDEG;	
}

void CIGRFDlg::OnSetfocusLongmin()
{
m_Focus=IDC_LONGMIN;	
}

void CIGRFDlg::OnSetfocusMonth()
{
m_Focus=IDC_MONTH;	
}

void CIGRFDlg::OnSetfocusYear()
{
m_Focus=IDC_YEAR;	
}

void CIGRFDlg::OnLongClicked()
{
m_ValChanged=TRUE;
OnKillfocus();	
}

void CIGRFDlg::OnLatClicked()
{
m_ValChanged=TRUE;
OnKillfocus();	
}
void CIGRFDlg::OnInitialUpdate()
{
	CFormView::OnInitialUpdate();
	WINDOWPLACEMENT wp;
	if (!ReadWindowPlacement(&wp,szViewWinPos))
		{
		return;
		}
//	CSize ws; ws.cx=wp.rcNormalPosition.right- wp.rcNormalPosition.left;
//	ws.cy=wp.rcNormalPosition.bottom - wp.rcNormalPosition.top;
//	SetScrollSizes(MM_TEXT,ws);
	BOOL success=GetParent()->SetWindowPlacement(&wp);
	if(!success) TRACE0(_T("SetWindowPlacement Failed\n"));

}


void CIGRFDlg::OnDestroy() 
{
	CFormView::OnDestroy();
		// before it is destroyed, save the position of the window
	WINDOWPLACEMENT wp;
	wp.length = sizeof wp;
	if (GetParent()->GetWindowPlacement(&wp))
	{
		wp.flags = 0;
		if (IsZoomed())
			wp.flags |= WPF_RESTORETOMAXIMIZED;
		// and write it to the .INI file
		WriteWindowPlacement( &wp,szViewWinPos);
	}	

}
//void CIGRFDlg::OnActivateFrame(int state, CFrameWnd *pWnd) 
//{
	// TODO: Add your specialized code here and/or call the base class
//if(state==WA_ACTIVE || state == WA_CLICKACTIVE) return;
//}

void CIGRFDlg::OnShowWindow(BOOL bShow, UINT nStatus) 
{
	CFormView::OnShowWindow(bShow, nStatus);
	WINDOWPLACEMENT wp;
	if(bShow || nStatus==SW_PARENTOPENING)
	{
	if (!ReadWindowPlacement(&wp,szViewWinPos))
		{
		return;
		}
	BOOL success=SetWindowPlacement(&wp);
	if(!success) TRACE0(_T("SetWindowPlacement Failed\n"));
	GetParentFrame()->RecalcLayout();
	}
}


 int  CalculateIGRF( IGRFRESULTS FAR&  res, 
			float year, float alt,float lat,float longt)
/* calcualtes the IGRF using the fortran Shellig routines contained in the
IGRF directory within the mwhfort.DLL  under the Tauxe folder
retuns the field values in the igrfresults structure which is passed to it
- only does for one igrf value

Valid Ranges:
	year: 1940.0 to IGRF_MAXYEAR
	lat : +- 90
	long +-360
	height 0 to 30,000 km
returns:
	=0 all OK
	=-2 values out of order
	=-3 too many coefficents
	=-4 too many files
	<0 fortran runtime error returned
	>0 invalid range , code indicates one of  IGRF_LATITUDE to IGRF_YEAR
*/
// chcekc input range is good
{
//if(!ValidateIGRFYear(year)) return(IGRF_YEAR);
if(!ValidateIGRFHeight(alt)) return(IGRF_HEIGHT); // in km
if(!ValidateIGRFLatitude(lat)) return(IGRF_LATITUDE);
if(!ValidateIGRFLongitude(longt,FALSE)) return(IGRF_LONGITUDE);

float BNORTH, BEAST, BDOWN,XCOR, BABS;
float  BVAR, SVAR,INC,DEC,L_VALUE;
 int NVAR, IVAR, IBBB,ICODE;

BVAR=lat; SVAR=0.0;NVAR=1;
IVAR=IGRF_LATITUDE;IBBB=IGRF_IGAUSS;
static BOOL bDoneInit=FALSE;
// call fortran subrouitnes
if( !bDoneInit) // initialse fortran common blocks
	{INITIZE(&ICODE);
// can return error codes of -4= too many files
// or fortran error code
	if(ICODE <0) return(ICODE);
	bDoneInit=TRUE;
	}
IGFCALC(&BNORTH,&BEAST, &BDOWN, &(res.DipoleInt),
	&XCOR, &BABS, &INC,&DEC, &L_VALUE, &ICODE,
	 &lat,&longt,&alt,&year,  &BVAR,&SVAR,
	 &NVAR, &IVAR,&IBBB);

if(ICODE <0)
	{ //error  in fortran routine, returns fortran error code
	// or -2 = values out of order in file
	//		-3 too many coefficents
	return(ICODE);
	}
	else
	{ // all ok in fortran routine
	res.x= BNORTH*GAUSSTOnT; res.y= BEAST*GAUSSTOnT; 
	res.z=BDOWN*GAUSSTOnT;  res.igrf.Int=BABS*GAUSSTOnT; // convert to nT
	res.igrf.Dec=DEC;res.igrf.Inc=INC;
	res.DIcode=ICODE;
	res.l_value=L_VALUE;
	SetSensibleDec(res.igrf);
	return(0);
	}
}


void CIGRFDlg::DisplayInvalidData(int errorcode)
{
CString errstr;
switch(errorcode)
	{
	case IGRF_YEAR: errstr.LoadString(IDS_ERRYEAR);break;
	case IGRF_HEIGHT: errstr.LoadString(IDS_ERRHEIGHT);break;
	case IGRF_LATITUDE: errstr.LoadString(IDS_ERRLAT);break;
	case IGRF_LONGITUDE: errstr.LoadString(IDS_ERRLONGITUDE);break;
	}
AfxMessageBox(errstr);
}


void WriteFortranError(int err)
{//	=-2 values out of order
//=-3 too many coefficents
//	=-4 too many files

CString errstr;
switch(err)
	{
	case -2: errstr=_T("Coeffcient values in *.dat files are apparently out of order\n please check the format of the *.dat files");		break;
	case -3: errstr=_T("Too many Coeffcients in *.dat files\n- program can only cope with up to 13 coefficients in any *.dat file"); break;
	case -4: errstr=_T("Too many .dat files for fortran code\n- program can only cope with up to 23 *.dat file");	break;
	case -9: errstr=_T("Permission to access .dat file denied\n Change the protection  or process used before rerunning program");	break;
	case -29: errstr=_T(" Fortran Error: \nA file with the specified name could not\n be found during an open operation\n\n *.dat files must be in the same folder as the exe file !");break;
	case -30:errstr=_T("An error was detected by the Compaq Fortran RTL I/O system while attempting to open a *.dat file ");	break;
	default:
		errstr.Format(_T("Compaq Fortran RTL  error code with value of: %d retuned"),err);
	}
int ret=AfxMessageBox(errstr);
}

//below must be included in a library linked to app
// AND *.dat files must exist in the same directory as the hlp file for this exe
BOOL SetCurrentDirectoryToExePath(BOOL set)
{//sets the current director to this exe path if set=true, set to stored old current if set=false
static TCHAR CurDir[180] ; 
static BOOL bCurSet=FALSE;
if(set==FALSE && bCurSet== FALSE) return(FALSE);// must call with set=true the first time
if(set)
	{
	if(!bCurSet)
		{
		int errdir=::GetCurrentDirectory(180, (LPTSTR) CurDir); 
		ASSERT(errdir !=0);
		}
		bCurSet=TRUE;		
	CString ExePath=AfxGetApp()->m_pszHelpFilePath;
	int pos=ExePath.ReverseFind('\\');// find last 
	ExePath=ExePath.Left(pos);// extrarct the path without the exe name
	::SetCurrentDirectory(ExePath);
	}
	else 
	{
		::SetCurrentDirectory(CurDir);
	}
return(TRUE);
}
