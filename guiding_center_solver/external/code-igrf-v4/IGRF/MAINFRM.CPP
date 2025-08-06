// mainfrm.cpp : implementation of the CMainFrame class
//

#include "stdafx.h"
#include "splash.h"
#include "igrfdoc.h"
#include "igrf.h"
#include "\geophys\utilclas\general.h" 

#include "mainfrm.h"

#ifdef _DEBUG
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif
static TCHAR BASED_CODE szMainWinPos[] = _T("IGRFMainWindowPos");

/////////////////////////////////////////////////////////////////////////////
// CMainFrame

IMPLEMENT_DYNAMIC(CMainFrame, CMDIFrameWnd)

BEGIN_MESSAGE_MAP(CMainFrame, CMDIFrameWnd)
	//{{AFX_MSG_MAP(CMainFrame)
	ON_WM_CREATE()
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// arrays of IDs used to initialize control bars

// toolbar buttons - IDs are command buttons
static UINT BASED_CODE buttons[] =
{
	// same order as in the bitmap 'toolbar.bmp'
	ID_FILE_NEW,
	ID_FILE_OPEN,
	ID_FILE_SAVE,
		ID_SEPARATOR,
	ID_EDIT_CUT,
	ID_EDIT_COPY,
	ID_EDIT_PASTE,
		ID_SEPARATOR,
	ID_FILE_PRINT,
	ID_APP_ABOUT,
	ID_CONTEXT_HELP,
};

static UINT BASED_CODE indicators[] =
{
	ID_SEPARATOR,			// status line indicator
	ID_INDICATOR_CAPS,
	ID_INDICATOR_NUM,
	ID_INDICATOR_SCRL,
};

/////////////////////////////////////////////////////////////////////////////
// CMainFrame construction/destruction

CMainFrame::CMainFrame()
{
	// TODO: add member initialization code here
}

CMainFrame::~CMainFrame()
{
}

int CMainFrame::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	if (CMDIFrameWnd::OnCreate(lpCreateStruct) == -1)
		return -1;
		//if(!m_ToolBar.Create(this,
//			WS_CHILD | WS_VISIBLE | CBRS_SIZE_DYNAMIC |	CBRS_TOP | CBRS_TOOLTIPS ,
	//		IDR_MAINFRAME) || 
//				!m_ToolBar.LoadToolBar(IDR_MAINFRAME)) 

	if (!m_wndToolBar.Create(this,WS_CHILD | WS_VISIBLE | CBRS_SIZE_DYNAMIC |	CBRS_TOP | CBRS_TOOLTIPS
		) || !m_wndToolBar.LoadBitmap(IDR_MAINFRAME) ||
		!m_wndToolBar.SetButtons(buttons,
		  sizeof(buttons)/sizeof(UINT)))
	{
		TRACE("Failed to create toolbar\n");
		return -1;		// fail to create
	}

	if (!m_wndStatusBar.Create(this) ||
		!m_wndStatusBar.SetIndicators(indicators,
		  sizeof(indicators)/sizeof(UINT)))
	{
		TRACE("Failed to create status bar\n");
		return -1;		// fail to create
	}

	return 0;
}


/////////////////////////////////////////////////////////////////////////////
// CMainFrame diagnostics

#ifdef _DEBUG
void CMainFrame::AssertValid() const
{
	CMDIFrameWnd::AssertValid();
}

void CMainFrame::Dump(CDumpContext& dc) const
{
	CMDIFrameWnd::Dump(dc);
}

#endif //_DEBUG

 CMDIChildWnd *CMainFrame::GetFrame(CRuntimeClass *pFrame)
 {   // returns a pointer to the one accurance of this frame type passed
 // as parameter pFrame
 	CMDIChildWnd* pMDIActive = MDIGetActive();
	ASSERT(pMDIActive != NULL);
	if( pMDIActive->IsKindOf(pFrame))
				return pMDIActive; 
	CDocument *pDoc=pMDIActive->GetActiveDocument();  
	ASSERT(pDoc !=NULL);
	CMDIChildWnd *pLastActive=pMDIActive;
	// use pDoc as means of telling when get back to this start again
	MDINext();
	pMDIActive=MDIGetActive();
	ASSERT(pMDIActive != NULL);
	while(pMDIActive->GetActiveDocument() !=pDoc)
		{
		if( pMDIActive->IsKindOf(pFrame))
			goto OK;
		MDINext();
         pMDIActive=MDIGetActive();
		ASSERT(pMDIActive != NULL);
		}
// not found
TRACE0(" MainFrame::GetFrame,=expected frame type not found\n");
return NULL;
OK:
MDIActivate(pLastActive);
return pMDIActive;
}

 void CMainFrame::InitialShowWindow(UINT nCmdShow)
{
	WINDOWPLACEMENT wp;
	if (!ReadWindowPlacement(&wp,szMainWinPos))
	{
		ShowWindow(nCmdShow);
		return;
	}
	if (nCmdShow != SW_SHOWNORMAL)
		wp.showCmd = nCmdShow;
	SetWindowPlacement(&wp);
	ShowWindow(wp.showCmd);
// If the style says the ToolBar is visible then it is visible.
//	m_bDialogBar = ((m_SelectBar.GetStyle() & WS_VISIBLE) != 0);
//	m_bCalcBar = ((m_Calc_ToolBar.GetStyle() & WS_VISIBLE) != 0);
//	m_bMainToolBar = ((m_ToolBar.GetStyle() & WS_VISIBLE) != 0);
//	OnViewDlgbarTop();
}

void CMainFrame::OnClose()
{
//	SaveBarState(_T("General"));
	// before it is destroyed, save the position of the main window
	WINDOWPLACEMENT wp;
	wp.length = sizeof wp;
//	RECT rect;
	if (GetWindowPlacement(&wp))
	{
		wp.flags = 0;
		if (IsZoomed())
			wp.flags |= WPF_RESTORETOMAXIMIZED;
		// and write it to the .INI file
		WriteWindowPlacement(&wp,szMainWinPos);
	}
/*	//for the calc tool bar
	//save screen coordinates
		m_Calc_ToolBar.GetWindowRect( &rect);
		WriteToolBarStatus(rect, m_Calc_ToolBar.GetBarStyle(), 
			m_Calc_ToolBar.IsFloating(),szCalcBarStatus);
		//for selct tool bar
		m_SelectBar.GetWindowRect(&rect);
		WriteToolBarStatus(rect, m_SelectBar.GetBarStyle(), 
			m_SelectBar.IsFloating(),szDialogBarStatus);
//	CDockState ds;
//	GetDockState(ds);
*/

	CMDIFrameWnd::OnClose();
}

/////////////////////////////////////////////////////////////////////////////
// CStdFrame message handlers

IMPLEMENT_DYNCREATE(CStdFrame, CMDIChildWnd)  

BEGIN_MESSAGE_MAP(CStdFrame, CMDIChildWnd)
	//{{AFX_MSG_MAP(CXRDStdFrame)
	ON_WM_CLOSE()
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

BOOL CStdFrame::PreCreateWindow(CREATESTRUCT& cs)
{
	// By turning off the default MFC-defined FWS_ADDTOTITLE style,
	// the framework will use first string in the document template
	// STRINGTABLE resource instead of the document name.

	cs.style &= ~(LONG)FWS_ADDTOTITLE;
	return CMDIChildWnd::PreCreateWindow(cs);
}

void CStdFrame::OnClose()
{
	// TODO: Add your message handler code here and/or call default
	
	::CloseWindow(m_hWnd);
//	CMDIChildWnd::OnClose();
}
 

