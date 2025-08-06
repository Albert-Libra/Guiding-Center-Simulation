// mainfrm.h : interface of the CMainFrame class
//
/////////////////////////////////////////////////////////////////////////////

class CMainFrame : public CMDIFrameWnd
{
	DECLARE_DYNAMIC(CMainFrame)
public:
	CMainFrame();

// Attributes
public:
	void InitialShowWindow(UINT nCmdShow);
// Operations
public:
 CMDIChildWnd *CMainFrame::GetFrame(CRuntimeClass *pFrame);
// Implementation
public:
	virtual ~CMainFrame();
#ifdef _DEBUG
	virtual	void AssertValid() const;
	virtual	void Dump(CDumpContext& dc) const;
#endif


protected:	// control bar embedded members
	CStatusBar	m_wndStatusBar;
	CToolBar	m_wndToolBar;

// Generated message map functions
protected:
	//{{AFX_MSG(CMainFrame)
	afx_msg int OnCreate(LPCREATESTRUCT lpCreateStruct);
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
class CStdFrame : public CMDIChildWnd
{
	DECLARE_DYNCREATE(CStdFrame)
public:
	void OnCloseDlg(void) {OnClose();} // minimises the view
	// closes the window, and the document
	void OnCloseDoc(void) { CMDIChildWnd::OnClose();};  
protected:
	BOOL PreCreateWindow(CREATESTRUCT& cs);
// Generated message map functions
protected:
	//{{AFX_MSG(CXRDStdFrame)
	afx_msg void OnClose();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
