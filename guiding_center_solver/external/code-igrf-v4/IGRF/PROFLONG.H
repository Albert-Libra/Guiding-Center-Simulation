// proflong.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// Cproflong dialog

class Cproflong : public CDialog
{
// Construction
public:
	Cproflong(CWnd* pParent = NULL);	// standard constructor
	void GetProfile(IGRFPROFILEIN& profile);// gets and sets the profile values
	void SetProfile(IGRFPROFILEIN& profile);

// Dialog Data
	//{{AFX_DATA(Cproflong)
	enum { IDD = IDD_PROFILE_LONG };
	float	m_End;
	float	m_Height;
	float	m_Lat;
	int		m_N;
	float	m_Start;
	float	m_Year;
	//}}AFX_DATA

// Implementation
protected:
	virtual void DoDataExchange(CDataExchange* pDX);	// DDX/DDV support

	// Generated message map functions
	//{{AFX_MSG(Cproflong)
	virtual void OnOK();
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};
