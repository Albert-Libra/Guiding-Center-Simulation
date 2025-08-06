// proflong.cpp : implementation file
//

#include "stdafx.h"
#include "splash.h"
//#include "..\utilclas\genmwh1.h"
#include "..\utilclas\general.h"
#include "igrfdoc.h"
#include "igrf.h"
#include"igrfdlg.h"
#include "proflong.h"

#ifdef _DEBUG
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// Cproflong dialog


Cproflong::Cproflong(CWnd* pParent /*=NULL*/)
	: CDialog(Cproflong::IDD, pParent)
{
	//{{AFX_DATA_INIT(Cproflong)
	m_End = 180;
	m_Height = 0;
	m_Lat = 0;
	m_N = 0;
	m_Start = 0;
	m_Year = 1990;
	//}}AFX_DATA_INIT
}

void Cproflong::DoDataExchange(CDataExchange* pDX)
{
	CDialog::DoDataExchange(pDX);
	//{{AFX_DATA_MAP(Cproflong)
	DDX_Text(pDX, IDC_END, m_End);
	DDV_MinMaxFloat(pDX, m_End, -360., 360.);
	DDX_Text(pDX, IDC_HEIGHT, m_Height);
	DDV_MinMaxFloat(pDX, m_Height, 0., 30000.);
	DDX_Text(pDX, IDC_LAT, m_Lat);
	DDV_MinMaxFloat(pDX, m_Lat, -90., 90.);
	DDX_Text(pDX, IDC_N, m_N);
	DDV_MinMaxInt(pDX, m_N, 2, 50);
	DDX_Text(pDX, IDC_START, m_Start);
	DDV_MinMaxFloat(pDX, m_Start, -360., 360.);
	DDX_Text(pDX, IDC_PYEAR, m_Year);
	//}}AFX_DATA_MAP
CIgrfApp *pApp=(CIgrfApp *) AfxGetApp();
	DDV_MinMaxFloat(pDX, m_Year, (float) pApp->m_YearStart, (float) pApp->m_YearEnd+9);

}

BEGIN_MESSAGE_MAP(Cproflong, CDialog)
	//{{AFX_MSG_MAP(Cproflong)
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()


/////////////////////////////////////////////////////////////////////////////
// Cproflong message handlers

void Cproflong::OnOK()
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

void Cproflong::GetProfile(IGRFPROFILEIN& p)
{// returns profile to user
p.pos.Lat=m_Lat; p.pos.Long=m_Start;
p.Height=m_Height; p.Year=m_Year;
p.Bvar=m_Start;
if(m_N>1) p.Svar=(m_End - m_Start)/(m_N-1);
	else p.Svar=0.0;
p.Nvar=m_N; p.Ivar=IGRF_LONGITUDE;
}
void Cproflong::SetProfile(IGRFPROFILEIN& p)
{  // sets initial value of dialog fields
p.Ivar=IGRF_LONGITUDE;
ValidateIGRFProfile(p);
m_Lat=p.pos.Lat; m_Height=p.Height; m_Year=p.Year; m_Start=p.pos.Long;
if(p.Nvar>0) m_N=p.Nvar;
	else m_N=5;
}
