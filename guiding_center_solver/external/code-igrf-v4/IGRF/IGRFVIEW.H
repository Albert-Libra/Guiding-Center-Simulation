// igrfview.h : interface of the CIgrfView class
//
/////////////////////////////////////////////////////////////////////////////

class CIgrfView : public CEditView
{
protected: // create from serialization only
	CIgrfView();
	DECLARE_DYNCREATE(CIgrfView)
	IGRFPROFILEIN m_Profile;// storage for IGRF profile input values
	CPtrArray m_Results; // storage for IGRF profile results
	int m_LScroll; //lines to scroll
	BOOL m_bDLLInit;
	// for accesssing the m_Results
	IGRFRESULTS *GetR(int i) { return( (IGRFRESULTS *) m_Results.GetAt(i));};
	int AddR(IGRFRESULTS *igrf) {return(m_Results.Add((void*) igrf));};
	CFont m_font;
// Attributes
public:
	CIgrfDoc* GetDocument();

// Operations
public:
void DisplayProfile(void);

// Implementation
public:
	virtual void OnUpdate(CView* pSender, LPARAM lHint, CObject* pHint );
	virtual ~CIgrfView();
//	virtual void OnDraw(CDC* pDC);  // overridden to draw this view
	virtual void OnInitialUpdate();
#ifdef _DEBUG
	virtual void AssertValid() const;
	virtual void Dump(CDumpContext& dc) const;

#endif

	// Printing support
protected:
	virtual BOOL OnPreparePrinting(CPrintInfo* pInfo);
	virtual void OnBeginPrinting(CDC* pDC, CPrintInfo* pInfo);
	virtual void OnEndPrinting(CDC* pDC, CPrintInfo* pInfo);
	
// calcualtes a profile of IGRF values and returns results as CPtrarray of IGRFRESULTS		
int CalculateIGRFProfile(IGRFPROFILEIN& prof);
 void EmptyProfile(void);


// Generated message map functions
protected:
	//{{AFX_MSG(CIgrfView)
	afx_msg void OnIgrfprofileOfheight();
	afx_msg void OnIgrfprofileOflongitude();
	afx_msg void OnIgrfprofileOfyears();
	afx_msg void OnIgrfProfileOflatitude();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

#ifndef _DEBUG	// debug version in igrfview.cpp
inline CIgrfDoc* CIgrfView::GetDocument()
   { return (CIgrfDoc*) m_pDocument; }
#endif

/////////////////////////////////////////////////////////////////////////////
