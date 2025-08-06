// proflat.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CProfLat dialog

class CProfLat : public CDialog
{
// Construction
public:
	CProfLat(CWnd* pParent = NULL);	// standard constructor
	void GetProfile(IGRFPROFILEIN& profile);// gets and sets the profile values
	void SetProfile(IGRFPROFILEIN& profile);


// Dialog Data
	//{{AFX_DATA(CProfLat)
	enum { IDD = IDD_PROFILE_LAT };
	float	m_End;
	float	m_Start;
	int		m_N;
	float	m_Height;
	float	m_Long;
	float	m_Year;
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support

	// Generated message map functions
	//{{AFX_MSG(CProfLat)
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
