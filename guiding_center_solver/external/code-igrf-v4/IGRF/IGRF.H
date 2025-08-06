// igrf.h : main header file for the IGRF application
//
/* dependencies
	linked libs: general.lib igrfl2.lib
	paths: \geophys\utilclas\general\release,
			\geophys\igrf\igrfl2\release

	linked dll's mwh1.lib, mwhfort.lib 
		paths: \geophys\UTILCLAS\mwh1dll\release\
			  \geophys\tauxe\mwhfort\release,
*/
#ifndef __AFXWIN_H__
	#error include 'stdafx.h' before including this file for PCH
#endif

#include "resource.h"		// main symbols
#include "igrfl2\resource.h"

/////////////////////////////////////////////////////////////////////////////
// CIgrfApp: CPrintingDialog
// See igrf.cpp for the implementation of this class
//

class CIgrfApp : public CWinApp
{
public:
	CIgrfApp();
	CMultiDocTemplate  *m_pEditViewTemplate;
	CMultiDocTemplate *m_pIGRFDlgTemplate;
CDocument * EditViewSetUp(CIgrfDoc *pDoc) ;
	CString m_Model;// IGRF model name
	int m_YearStart, m_YearEnd;// start and end year of valid year inputs

// the splash window
     DWORD m_dwSplashTime;
	CSplashWnd m_splash;


// Overrides
	virtual BOOL InitInstance();
	virtual BOOL OnIdle(LONG lCount);
	virtual BOOL PreTranslateMessage(MSG* pMsg);
 	virtual CDocument* OpenDocumentFile(LPCSTR lpszFileName);

// Implementation

	//{{AFX_MSG(CIgrfApp)
	afx_msg void OnAppAbout();
	afx_msg void OnFileNew();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
private:
	BOOL GetInitInfo();
};

//extern    CIgrfApp theApp;

/////////////////////////////////////////////////////////////////////////////
