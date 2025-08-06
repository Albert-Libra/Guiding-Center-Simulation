// igrf.cpp : Defines the class behaviors for the application.
//

#include "stdafx.h"
#include "splash.h"
#include <locale.h>
#include "\geophys\utilclas\general.h"

#include "mainfrm.h"
#include "igrfdoc.h"
#include "igrfview.h"
#include "igrf.h"
#include "igrfdlg.h"

#ifdef _DEBUG                                                                          
#define new DEBUG_NEW
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CIgrfApp

BEGIN_MESSAGE_MAP(CIgrfApp, CWinApp)
	//{{AFX_MSG_MAP(CIgrfApp)
	ON_COMMAND(ID_APP_ABOUT, OnAppAbout)
	ON_COMMAND(ID_FILE_NEW, OnFileNew)
	//}}AFX_MSG_MAP
	// Standard file based document commands
	ON_COMMAND(ID_FILE_NEW, CWinApp::OnFileNew)
	ON_COMMAND(ID_FILE_OPEN, CWinApp::OnFileOpen)
	// Standard print setup command
	ON_COMMAND(ID_FILE_PRINT_SETUP, CWinApp::OnFilePrintSetup)
	// Global help commands
	ON_COMMAND(ID_HELP_INDEX, CWinApp::OnHelpIndex)
	ON_COMMAND(ID_HELP_USING, CWinApp::OnHelpUsing)
	ON_COMMAND(ID_HELP, CWinApp::OnHelp)
	ON_COMMAND(ID_CONTEXT_HELP, CWinApp::OnContextHelp)
	ON_COMMAND(ID_DEFAULT_HELP, CWinApp::OnHelpIndex)
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CIgrfApp construction

CIgrfApp::CIgrfApp()
{
	// TODO: add construction code here,
	// Place all significant initialization in InitInstance
}

/////////////////////////////////////////////////////////////////////////////
// The one and only CIgrfApp object

CIgrfApp NEAR theApp;

/////////////////////////////////////////////////////////////////////////////
// CIgrfApp initialization

BOOL CIgrfApp::InitInstance()
{
	// Standard initialization
	// If you are not using these features and wish to reduce the size
	//  of your final executable, you should remove from the following
	//  the specific initialization routines you do not need.
	_tsetlocale(LC_ALL, _T(""));

	Enable3dControlsStatic();
	SetRegistryKey(_T("CEMP Systems Software"));

	SetDialogBkColor();        // set dialog background color to gray
	LoadStdProfileSettings();  // Load standard INI file options (including MRU)

	// Register the application's document templates.  Document templates
	//  serve as the connection between documents, frame windows and views.


	m_pIGRFDlgTemplate=new CMultiDocTemplate(IDR_IGRFTYPE,
			RUNTIME_CLASS(CIgrfDoc),
			RUNTIME_CLASS(CMDIChildWnd),        
			RUNTIME_CLASS(CIGRFDlg));
	m_pEditViewTemplate=new CMultiDocTemplate(IDR_IGRFEDIT,
			RUNTIME_CLASS(CIgrfDoc),
			RUNTIME_CLASS(CStdFrame),
			RUNTIME_CLASS(CIgrfView));

	AddDocTemplate(m_pIGRFDlgTemplate);
	AddDocTemplate(m_pEditViewTemplate);
	
	// create main MDI Frame window
	CMainFrame* pMainFrame = new CMainFrame;
	m_pMainWnd = pMainFrame;
	if (!pMainFrame->LoadFrame(IDR_MAINFRAME))
		return FALSE;
	((CMainFrame*)m_pMainWnd)->InitialShowWindow(m_nCmdShow);
	//	pMainFrame->ShowWindow(SW_SHOWMAXIMIZED);
	pMainFrame->UpdateWindow();
	
	if( !GetInitInfo())
		{
		return FALSE;
		}


		if (!m_pMainWnd->IsIconic() && m_lpCmdLine[0] == 0 &&
			m_splash.Create(m_pMainWnd))
		{
			m_splash.ShowWindow(SW_SHOW);
			m_splash.UpdateWindow();
		}
		m_dwSplashTime = ::GetCurrentTime();

	// create a new (empty) document
	OnFileNew();
	CStdFrame *pCalFrame =(CStdFrame *)
						 pMainFrame->GetFrame(RUNTIME_CLASS(CStdFrame));
	pCalFrame->OnCloseDlg(); // minimise the edit window, so user sees the igrd dlg				

	return TRUE;
}


void CIgrfApp::OnFileNew()
{      
	POSITION pos=GetFirstDocTemplatePosition();
	CDocTemplate* pTemplate = GetNextDocTemplate(pos);
	ASSERT(pTemplate != NULL);
	ASSERT(pTemplate->IsKindOf(RUNTIME_CLASS(CDocTemplate)));
	CIgrfDoc *pDoc=( CIgrfDoc *)pTemplate->OpenDocumentFile(NULL);  
	if(pDoc ==NULL)
	 	{
		TRACE0("Error : no document templates registered with CWinApp\n");
		AfxMessageBox(AFX_IDP_FAILED_TO_CREATE_DOC);
		return;
	}
	// let statioviewsetup display the 2nd view
	EditViewSetUp(  pDoc); 
	// now we want to display the prime dialog
//	pDoc->OnEditPrimedata();
}                                                              

 CDocument* CIgrfApp::OpenDocumentFile(LPCSTR lpszFileName)
{
	// CWinApp::OpenDocmentFile creates the first MDI child window
	// for the igrfdlg view.  This override creates the second MDI child
	// window for the edit view.  Then it tiles the two MDI children
	// windows.

	CIgrfDoc* pDoc = (CIgrfDoc*)CWinApp::OpenDocumentFile(lpszFileName);
	if (pDoc == NULL)
	{
		CString strMessage;
		AfxFormatString1(strMessage, IDS_CANNOT_OPEN_FILE, 
			lpszFileName);
		AfxMessageBox(strMessage);
		return NULL;
	}   
	EditViewSetUp(pDoc);
	if(lpszFileName !=NULL )pDoc->LoadTextFile(lpszFileName);
	return pDoc;
}
CDocument * CIgrfApp::EditViewSetUp(CIgrfDoc *pDoc)
{ // draws the station form after the notepad view has been dispalyed

	CFrameWnd* pNewFrame = m_pEditViewTemplate->CreateNewFrame(pDoc, NULL);
	if (pNewFrame == NULL)
		return pDoc;
	m_pEditViewTemplate->InitialUpdateFrame(pNewFrame, pDoc);

/*	// Tile the two MDI children windows within the MDI frame window.

	ASSERT(pNewFrame->IsKindOf(RUNTIME_CLASS(CMDIChildWnd)));
	CMDIFrameWnd* pMDIFrameWnd = ((CMDIChildWnd*)pNewFrame)->GetMDIFrame();
	ASSERT(pMDIFrameWnd != NULL);
	pMDIFrameWnd->MDITile(MDITILE_HORIZONTAL); 
	*/
	return pDoc;
}

BOOL CIgrfApp::GetInitInfo()
{//retrieves the initialisation info from the igrfip.dat file
//returns TRUE if OK, FALSE if a problem
// .dat file is in the location of the exe path
CString ExePath=m_pszHelpFilePath;
int pos=ExePath.ReverseFind('\\');// find last 
ExePath=ExePath.Left(pos);// extrarct the path without the exe name
ExePath+=_T("\\igrfip.dat");// append the file name
CFile file;
CFileException  e;
if(	 !file.Open(ExePath, CFile::modeRead |CFile::shareDenyNone, &e))
{
	AfxMessageBox(IDS_ERR_NOIGRFIP, MB_OK|MB_ICONSTOP);
	DisplayCFileErr(e.m_cause,ERR_BOX);
	return FALSE;
}
UINT errcode;
int len=file.GetLength();
LPTSTR buf=new TCHAR[len];
memset(buf,0,len);
file.Read(buf,len);
CPtrArray lines;
CString years;
int nl=BreakIntoLines(lines, buf,len, TRUE, TRUE);
LPTSTR str;
int nblank=0;
for(int i=0; i<=lines.GetUpperBound(); i++)
	{
	str=(LPTSTR) lines.GetAt(i);
	if(str == NULL || _tcslen(str )<6) nblank++;
	}
int numfiles, index;
if(nl <17) {errcode= IDS_ERR_IPFEWLINES; goto BADFILE;}
m_Model=(LPTSTR) lines.GetAt(1);// model string
if(m_Model.IsEmpty()) 
	{errcode= IDS_ERR_IPNOMODEL; goto BADFILE;}

years=(LPTSTR) lines.GetAt(2);// model string
years.TrimLeft(); years.TrimRight();
numfiles=atoi(years);
if(numfiles <14 ) 
	{errcode= IDS_ERR_IPFEWFILES; goto BADFILE;}
if(numfiles >23 ) 
	{errcode= IDS_ERR_IPTOMANYFILES; goto BADFILE;}
 index=years.Find(_T(" "));// find the seperating space
if(index ==-1) 
	{errcode= IDS_ERR_BADYEARFORMAT; goto BADFILE;}
years=years.Right(years.GetLength() -index);
years.TrimLeft();

m_YearStart=atoi(years);
if(m_YearStart <1900 || m_YearStart >2000) 
	{errcode= IDS_ERR_BADYEARS; goto BADFILE;}
index=years.Find(_T(" "));// find the seperating space
if(index ==-1) 
	{errcode= IDS_ERR_BADYEARFORMAT; goto BADFILE;}
years=years.Right(years.GetLength() -index);

m_YearEnd=atoi(years);
if(m_YearEnd < m_YearStart || m_YearEnd >2200) 
	{errcode= IDS_ERR_BADYEARS; goto BADFILE;}
if( numfiles != nl-3-nblank)
	{errcode= IDS_ERR_IPBADNUMFILES; goto BADFILE;}
DeleteLineContents(lines);
delete [] buf;
return TRUE;

BADFILE:
DeleteLineContents(lines);
delete [] buf;
AfxMessageBox(errcode,MB_OK|MB_ICONSTOP);
	return FALSE;
}

/////////////////////////////////////////////////////////////////////////////
// CAboutDlg dialog used for App About

class CAboutDlg : public CDialog
{
public:
	CAboutDlg();

// Dialog Data
	//{{AFX_DATA(CAboutDlg)
	enum { IDD = IDD_ABOUTBOX };
	CString	m_Model;
	CString	m_YearRange;
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	//{{AFX_MSG(CAboutDlg)
		// No message handlers
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

CAboutDlg::CAboutDlg() : CDialog(CAboutDlg::IDD)
{
	//{{AFX_DATA_INIT(CAboutDlg)
	m_Model = _T("");
	m_YearRange = _T("");
	//}}AFX_DATA_INIT
}

void CAboutDlg::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CAboutDlg)
	DDX_Text(pDX, IDC_MODEL, m_Model);
	DDX_Text(pDX, IDC_YEARRANGE, m_YearRange);
	//}}AFX_DATA_MAP
}

BEGIN_MESSAGE_MAP(CAboutDlg, CDialog)
	//{{AFX_MSG_MAP(CAboutDlg)
		// No message handlers
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

// App command to run the dialog
void CIgrfApp::OnAppAbout()
{
	CAboutDlg aboutDlg;
	aboutDlg.m_Model=m_Model;
	aboutDlg.m_YearRange.Format(_T("%d - %d (%d)"),m_YearStart,m_YearEnd, m_YearEnd+10);
	aboutDlg.DoModal();
}

/////////////////////////////////////////////////////////////////////////////
// CIgrfApp commands

BOOL CIgrfApp::OnIdle(LONG lCount)
{
	// call base class idle first
	BOOL bResult = CWinApp::OnIdle(lCount);

	// then do our work
	if (m_splash.m_hWnd != NULL)
	{
		if (::GetCurrentTime() - m_dwSplashTime > 3500)
		{
			// timeout expired, destroy the splash window
			m_splash.DestroyWindow();
			m_pMainWnd->UpdateWindow();

			// NOTE: don't set bResult to FALSE,
			//  CWinApp::OnIdle may have returned TRUE
		}
		else
		{
			// check again later...
			bResult = TRUE;
		}
	}

	return bResult;
}

BOOL CIgrfApp::PreTranslateMessage(MSG* pMsg)
{
	BOOL bResult = CWinApp::PreTranslateMessage(pMsg);

	if (m_splash.m_hWnd != NULL &&
		(pMsg->message == WM_KEYDOWN ||
		 pMsg->message == WM_SYSKEYDOWN ||
		 pMsg->message == WM_LBUTTONDOWN ||
		 pMsg->message == WM_RBUTTONDOWN ||
		 pMsg->message == WM_MBUTTONDOWN ||
		 pMsg->message == WM_NCLBUTTONDOWN ||
		 pMsg->message == WM_NCRBUTTONDOWN ||
		 pMsg->message == WM_NCMBUTTONDOWN))
	{
		m_splash.DestroyWindow();
		m_pMainWnd->UpdateWindow();
	}

	return bResult;
}



