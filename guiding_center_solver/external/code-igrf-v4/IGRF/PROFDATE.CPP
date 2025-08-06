// profdate.cpp : implementation file
//

#include "stdafx.h"
#include "splash.h"
#include "..\utilclas\general.h"
#include "igrfdoc.h"
#include "igrf.h"
#include "igrfdlg.h"
#include "profdate.h"

#ifdef _DEBUG
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CprofDate dialog


CprofDate::CprofDate(CWnd* pParent /*=NULL*/)
	: CDialog(CprofDate::IDD, pParent)
{
	//{{AFX_DATA_INIT(CprofDate)
	m_End = 2000;
	m_Height = 0;
	m_Lat = 0;
	m_Long = 0;
	m_N = 0;
	m_Start = 1990;
	//}}AFX_DATA_INIT
}

void CprofDate::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(CprofDate)
	DDX_Text(pDX, IDC_END, m_End);
	DDX_Text(pDX, IDC_HEIGHT, m_Height);
	DDV_MinMaxFloat(pDX, m_Height, 0., 30000.);
	DDX_Text(pDX, IDC_LAT, m_Lat);
	DDV_MinMaxFloat(pDX, m_Lat, -90., 90.);
	DDX_Text(pDX, IDC_LONG, m_Long);
	DDV_MinMaxFloat(pDX, m_Long, -360., 360.);
	DDX_Text(pDX, IDC_N, m_N);
	DDV_MinMaxInt(pDX, m_N, 2, 50);
	DDX_Text(pDX, IDC_START, m_Start);
	//}}AFX_DATA_MAP
CIgrfApp *pApp=(CIgrfApp *) AfxGetApp();

	DDV_MinMaxFloat(pDX, m_End, (float) pApp->m_YearStart, (float) pApp->m_YearEnd+9);
	DDV_MinMaxFloat(pDX, m_Start, (float) pApp->m_YearStart, (float) pApp->m_YearEnd+9);
}

BEGIN_MESSAGE_MAP(CprofDate, CDialog)
	//{{AFX_MSG_MAP(CprofDate)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// CprofDate message handlers
 
void CprofDate::OnOK()
{
	if( UpdateData(TRUE)==0)return;
	if(AreSamef(m_End, m_Start))
		{
		AfxMessageBox(" Start and End values are the Same !!");
		GotoDlgCtrl(GetDlgItem(IDC_START));
		return;
		}
	if(m_End <m_Start)
		{
		AfxMessageBox(" End value is  less than Start");
		GotoDlgCtrl(GetDlgItem(IDC_START));
		return;
		}	
	
	CDialog::OnOK();
}

void CprofDate::GetProfile(IGRFPROFILEIN& p)
{// returns profile to user
p.pos.Lat=m_Lat; p.pos.Long=m_Long;
p.Height=m_Height; p.Year=m_Start;
p.Bvar=m_Start;
if(m_N>1) p.Svar=(m_End - m_Start)/(m_N-1);
	else p.Svar=0.0;
p.Nvar=m_N; p.Ivar=IGRF_YEAR;
}
void CprofDate::SetProfile(IGRFPROFILEIN& p)
{  // sets initial value of dialog fields
p.Ivar=IGRF_YEAR;
ValidateIGRFProfile(p);
m_Lat=p.pos.Lat; m_Height=p.Height; m_Start=p.Year; m_Long=p.pos.Long;
if(p.Nvar>0) m_N=p.Nvar;
	else
	m_N=5;
}
