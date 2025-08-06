// igrfdlg.h : header file
//
                                                                                          
/////////////////////////////////////////////////////////////////////////////
// CIGRFDlg form view

#ifndef __AFXEXT_H__
#include <afxext.h>
#endif                                           

#if defined(GDYNAMIC)
#include "\geophys\igrf\igrflib\resource.h"
#endif

#if !defined(FOCUS_NONE)
#define FOCUS_NONE	-1
#endif

class CIGRFDlg : public CFormView
{
	DECLARE_DYNCREATE(CIGRFDlg)
protected:
	CIGRFDlg();			// protected constructor used by dynamic creation
	int m_errorcode;
	BOOL m_bDoingCalc;
// Form Data
public:
	//{{AFX_DATA(CIGRFDlg)
	enum { IDD = IDD_IGRFDLG };
	float	m_Altitude;
	float	m_Dec;
	float	m_Inc;
	int		m_nLatDeg;
	int		m_nLongDeg;
	float		m_nMonth;
	double	m_total;
	double	m_X;
	double	m_Y;
	int		m_nYear;
	double	m_Z;
	float	m_LatMin;
	float	m_LongMin;
	int		m_FLGLONG;
	int		m_FLGLAT;
	//}}AFX_DATA
	int m_Focus;// control having focus
	BOOL m_ValChanged;
private:   


// Attributes
/*public:
	CMainDoc* GetDocument()
			{
				ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CMainDoc)));
				return (CMainDoc*) m_pDocument;
			}

*/
// Operations
protected:
	BOOL OnCalculate();
 
// Implementation
protected:
	void DisplayInvalidData(int errorcode);
	virtual ~CIGRFDlg();
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnPrint(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnInitialUpdate();
	//virtual void OnActivateFrame(int state, CFrameWnd *pWnd) ;

	void PaintChildWindows(HWND hWndParent, CDC* pDC, CPoint ptOffset);
	// Generated message map functions
	//{{AFX_MSG(CIGRFDlg)
	afx_msg void OnIgrfHelp();
	afx_msg void OnKillfocus();
	afx_msg void OnChange();
	afx_msg void OnSetfocusAltitude();
	afx_msg void OnSetfocusLatdeg();
	afx_msg void OnSetfocusLatmin();
	afx_msg void OnSetfocusLongdeg();
	afx_msg void OnSetfocusLongmin();
	afx_msg void OnSetfocusMonth();
	afx_msg void OnSetfocusYear();
	afx_msg void OnLongClicked();
	afx_msg void OnLatClicked();
	afx_msg void OnFilePrint();
	afx_msg void OnFilePrintPreview();
	afx_msg void OnShowWindow(BOOL bShow, UINT nStatus);
	afx_msg void OnDestroy();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};


/////////////////////////////////////////////////////////////////////////////
// calculates a single IGRF value, cannot be put into dll becuaes cannot then call the fortran dll
int	 CalculateIGRF(  IGRFRESULTS FAR&  res, float year,
		float altitude,float latitude,float longitude);
void WriteFortranError(int err);
BOOL SetCurrentDirectoryToExePath(BOOL set);
