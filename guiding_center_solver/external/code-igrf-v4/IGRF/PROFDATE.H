// profdate.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CprofDate dialog

class CprofDate : public CDialog
{
// Construction
public:
	CprofDate(CWnd* pParent = NULL);	// standard constructor 
	void GetProfile(IGRFPROFILEIN& profile);// gets and sets the profile values
	void SetProfile(IGRFPROFILEIN& profile);


// Dialog Data
	//{{AFX_DATA(CprofDate)
	enum { IDD = IDD_PROFILE_DATE };
	float	m_End;
	float	m_Height;
	float	m_Lat;
	float	m_Long;
	int		m_N;
	float	m_Start;
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support

	// Generated message map functions
	//{{AFX_MSG(CprofDate)
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
