// profht.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CprofHt dialog

class CprofHt : public CDialog
{
// Construction
public:
	CprofHt(CWnd* pParent = NULL);	// standard constructor 
	void GetProfile(IGRFPROFILEIN& profile);// gets and sets the profile values
	void SetProfile(IGRFPROFILEIN& profile);


// Dialog Data
	//{{AFX_DATA(CprofHt)
	enum { IDD = IDD_PROFILE_HEIGHT };
	float	m_End;
	float	m_Lat;
	float	m_Long;
	int		m_N;
	float	m_Start;
	float	m_Year;
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support

	// Generated message map functions
	//{{AFX_MSG(CprofHt)
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
