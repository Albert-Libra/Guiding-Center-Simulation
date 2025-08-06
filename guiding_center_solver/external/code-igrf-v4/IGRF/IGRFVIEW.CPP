// igrfview.cpp : implementation of the CIgrfView class
//
#define mwh_fortran
// comment out above line if IGFCALC and INITIZE routines are not fortran
#include "stdafx.h"
#include "splash.h"
#include "..\utilclas\general.h"
#include "proflong.h"
#include "proflat.h"
#include "profHt.h"
#include "profdate.h"
#include "igrfdoc.h"
#include "igrf.h"
#include "igrfdlg.h"

#include "igrfview.h"

#ifdef _DEBUG
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CIgrfView

IMPLEMENT_DYNCREATE(CIgrfView, CEditView)

BEGIN_MESSAGE_MAP(CIgrfView, CEditView)
	//{{AFX_MSG_MAP(CIgrfView)
	ON_COMMAND(ID_IGRFPROFILE_OFHEIGHT, OnIgrfprofileOfheight)
	ON_COMMAND(ID_IGRFPROFILE_OFLONGITUDE, OnIgrfprofileOflongitude)
	ON_COMMAND(ID_IGRFPROFILE_OFYEARS, OnIgrfprofileOfyears)
	ON_COMMAND(ID_PROFILE_OFLATITUDE, OnIgrfProfileOflatitude)
	//}}AFX_MSG_MAP
	// Standard printing commands
	ON_COMMAND(ID_FILE_PRINT, CView::OnFilePrint)
	ON_COMMAND(ID_FILE_PRINT_PREVIEW, CView::OnFilePrintPreview)
END_MESSAGE_MAP()

#define new DEBUG_NEW

/////////////////////////////////////////////////////////////////////////////
// CIgrfView construction/destruction

CIgrfView::CIgrfView()
{
// set up the IGRFPROFILEIN structure
m_Profile.Ivar=IGRF_LATITUDE;
m_Profile.pos.Lat=60.0;m_Profile.pos.Long=0; m_Profile.Height=0.0;
m_Profile.Year=1998.0;m_Profile.Bvar=0.0;	
m_Profile.Nvar=10; m_Profile.Svar=(float) (120./m_Profile.Nvar);
m_LScroll=0;
m_bDLLInit=FALSE;
}

CIgrfView::~CIgrfView()
{
EmptyProfile();
}

void CIgrfView::OnInitialUpdate()
{
CEditView::OnInitialUpdate(); 
	BOOL ok=m_font.CreatePointFont(100,_T("Courier New"),NULL);
//	CFont *pf=NULL;
	if(ok)
		{
		GetEditCtrl().SetFont(&m_font);
		SetFont(&m_font);
		}
//GetDocument()->SetTitle("IGRF Profiling");
}
/////////////////////////////////////////////////////////////////////////////
// CIgrfView drawing
/*
void CIgrfView::OnDraw(CDC* pDC)
{
	CIgrfDoc* pDoc = GetDocument();
	CFont font;
	BOOL ok=font.CreatePointFont(110,_T("Courier New"),pDC);
	CFont *pf=NULL;
	if(ok)
		{
		pf=pDC->SelectObject(&font);
		}
	CEditView::OnDraw(pDC);
	if(ok)
	{
		pDC->SelectObject(pf);
		font.DeleteObject();
	}
}
*/
/////////////////////////////////////////////////////////////////////////////
// CIgrfView printing

BOOL CIgrfView::OnPreparePrinting(CPrintInfo* pInfo)
{
	return CEditView::DoPreparePrinting(pInfo);
}

void CIgrfView::OnBeginPrinting(CDC *pDC, CPrintInfo *pInfo)
{
//	CFont font;
//	font.CreatePointFont(110,_T("Courier New"),pDC);
//	SetPrinterFont(&font);
	CEditView::OnBeginPrinting(pDC, pInfo);
}

void CIgrfView::OnEndPrinting(CDC *pDC, CPrintInfo *pInfo)
{
	CEditView::OnEndPrinting(pDC, pInfo);
}




/////////////////////////////////////////////////////////////////////////////
// CIgrfView diagnostics

#ifdef _DEBUG
void CIgrfView::AssertValid() const
{
	CView::AssertValid();
}

void CIgrfView::Dump(CDumpContext& dc) const
{
	CView::Dump(dc);
}

CIgrfDoc* CIgrfView::GetDocument() // non-debug version is inline
{
	ASSERT(m_pDocument->IsKindOf(RUNTIME_CLASS(CIgrfDoc)));
	return (CIgrfDoc*) m_pDocument;
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CIgrfView message handlers

void CIgrfView::OnIgrfprofileOfheight()
{
CprofHt Dlg;
Dlg.SetProfile(m_Profile);
if(Dlg.DoModal() == IDOK)
	{
	Dlg.GetProfile(m_Profile);
	DisplayProfile(); // displays profile to editview
	}
}

void CIgrfView::OnIgrfprofileOflongitude()
{
Cproflong Dlg;
Dlg.SetProfile(m_Profile);
if(Dlg.DoModal() == IDOK)
	{
	Dlg.GetProfile(m_Profile);
	DisplayProfile(); // displays profile to editview
	}
	
}

void CIgrfView::OnIgrfprofileOfyears()
{
CprofDate Dlg;
Dlg.SetProfile(m_Profile);
if(Dlg.DoModal() == IDOK)
	{
	Dlg.GetProfile(m_Profile);
	DisplayProfile(); // displays profile to editview
	}
}

void CIgrfView::OnIgrfProfileOflatitude()
{
CProfLat Dlg;
Dlg.SetProfile(m_Profile);
if(Dlg.DoModal() == IDOK)
	{
	Dlg.GetProfile(m_Profile);
	DisplayProfile(); // displays profile to editview
	}
}
 #define BUFLEN	200
void CIgrfView::DisplayProfile(void)
 {  //calcualtes and displays the profile values to the edit view
int errcode=CalculateIGRFProfile(m_Profile);
 if( errcode  <0) 
	{
	  WriteFortranError(errcode);
	 return; 
	}
	// determine if ok
 // now display to editview, 
 // first display header line, followed by calc data, followed by inputs
 CString var;// variable calculated from
 float KVar=m_Profile.Bvar;// variable counter
 switch (m_Profile.Ivar)
 	{
 	case IGRF_LATITUDE: var="Latitude";break;
 	case IGRF_LONGITUDE: var="Longitude";break;
 	case IGRF_HEIGHT: var="Height"; break;
 	case IGRF_YEAR: var=" Date";break;
 	}
 char buf[BUFLEN];
 CString op;
 _snprintf(buf,BUFLEN,"----------------------------------------------------------------------------------------\r\n\r\n");
 op+=buf;
 _snprintf(buf,BUFLEN,"%s    X\t\t     Y\t\t     Z\t\t Dec\t Inc\t Intensity (nT)\r\n",var);
 op+=buf;
 for(int i=0; i<m_Profile.Nvar; i++)
 	{// now each line of calc data
 	  _snprintf(buf,BUFLEN,"%6.2f\t%8.1f\t%8.1f\t%8.1f\t%5.1f\t%5.1f\t%8.1f\r\n",
 	  	KVar,GetR(i)->x, GetR(i)->y, GetR(i)->z, GetR(i)->igrf.Dec, GetR(i)->igrf.Inc, GetR(i)->igrf.Int);
 	  	op+=buf;
 	  	KVar=KVar+m_Profile.Svar;
 	}
// now print the values done calculation for
 _snprintf(buf,BUFLEN,"+++++++++++++++++++++++++++++++++++++++++++++++++++++++++\r\n");
 op+=buf;
 switch (m_Profile.Ivar)
 	{
 	case IGRF_LATITUDE: 
 		_snprintf(buf, BUFLEN, "Longitude=%5.2f\tDate=%5.2f\tHeight=%5.2f Km\r\n",
 			m_Profile.pos.Long, m_Profile.Year, m_Profile.Height);break;
 	case IGRF_LONGITUDE: 
 		_snprintf(buf, BUFLEN, "Latitude=%5.2f\tDate=%5.2f\tHeight=%5.2f Km\r\n",
 			m_Profile.pos.Lat, m_Profile.Year, m_Profile.Height);break;
 	case IGRF_HEIGHT: 
 		_snprintf(buf, BUFLEN, "Latitude=%5.2f\tLongitude=%5.2f\tDate=%5.2f\r\n",
 			m_Profile.pos.Lat, m_Profile.pos.Long, m_Profile.Year);break;
 	case IGRF_YEAR: 
 		_snprintf(buf, BUFLEN, "Latitude=%5.2f\tLongitude=%5.2f\tHeight=%5.2f Km\r\n",
 			m_Profile.pos.Lat, m_Profile.pos.Long, m_Profile.Height);break;
 	}
op+=buf; 
// now add op onto end of text in view
CString CurText;
CEdit& ctrl=GetEditCtrl();
ctrl.GetWindowText(CurText);
CurText+=op;
ctrl.SetWindowText(CurText);
m_LScroll=m_LScroll+m_Profile.Nvar+3;
if(m_LScroll >0) ctrl.LineScroll(m_LScroll);
GetDocument()->SetModifiedFlag(TRUE);
 }
 
 #undef BUFLEN
 
 int CIgrfView::CalculateIGRFProfile(IGRFPROFILEIN& prof)
 {// callc the fortran routine to calculate the profile of IGRF values

/* calcualtes the IGRF profile using the fortran Shellig routines contained in the
IGRF directory within the SHELIGDL.DLL 
retuns the field values in the igrfresults structure which iscreated 
 and pointer placed into m_Results

Valid Ranges:
	year: 1940.0 to 2000.0
	lat : +- 90
	long +-360
	height 0 to 30,000 km
returns:
	=0 all OK
	<0 fortran runtime error returned
	>0 invalid range , code indicates one of  IGRF_LATITUDE to IGRF_YEAR,
	and res is empty
*/
// chcekc input range is good
EmptyProfile();
//if(prof.Year <1940.0 || prof.Year >2005.0) return(IGRF_YEAR);
if(prof.Height <0.0 || prof.Height >30000.0) return(IGRF_HEIGHT); // in km
if(prof.pos.Lat <-90.0 || prof.pos.Lat >90.0) return(IGRF_LATITUDE);
if(prof.pos.Long <-360.0 || prof.pos.Long >360.0) return(IGRF_LONGITUDE);

float *BNORTH= new float[prof.Nvar]; // field, x, y, z
float * BEAST= new float [prof.Nvar];
float * BDOWN= new float [prof.Nvar];
float *XCOR= new float [prof.Nvar]; // work space
float * BABS=new float [prof.Nvar]; // total field intensity
float *XL= new float [prof.Nvar];  // l-value
float *DEC= new float [prof.Nvar];
float *DIP= new float [prof.Nvar];
int *ICODE= new int [prof.Nvar]; // indicates error in XL
int  IBBB;
IGRFRESULTS *res;
float DIMO;

CIgrfApp *pApp=	(CIgrfApp *) AfxGetApp();
SetCurrentDirectoryToExePath(TRUE);

IBBB=IGRF_IGAUSS;
// call fortran subrouitnes
//TESTDLL(&IBBB);
if( ! m_bDLLInit) 
	{
	INITIZE(ICODE);// initialse fortran common blocks
	// can return error codes of -4= too many files
	// or fortran error code
	if(ICODE[0] <0) return(ICODE[0]);
	m_bDLLInit=TRUE;
	}
IGFCALC(BNORTH,BEAST, BDOWN, &DIMO,
	XCOR, BABS, DIP,DEC, XL ,ICODE,
	 &prof.pos.Lat,&prof.pos.Long,&prof.Height,&prof.Year,  &prof.Bvar,
	 &prof.Svar, &prof.Nvar, &prof.Ivar,&IBBB);

SetCurrentDirectoryToExePath(FALSE);

if(ICODE[0] >0)
	{ // all ok in fortran routine, so lets copy into m_Results
	for(int i=0; i<prof.Nvar; i++)
		{
		res= new IGRFRESULTS;
		res->x= BNORTH[i]*GAUSSTOnT; 
		res->y= BEAST[i]*GAUSSTOnT; 
		res->z=BDOWN[i]*GAUSSTOnT; 
		res->igrf.Int=BABS[i]*GAUSSTOnT; // convert to nT
		res->igrf.Dec=DEC[i];res->igrf.Inc=DIP[i];
		SetSensibleDec(res->igrf);
		res->DIcode=ICODE[i];
		res->l_value=XL[i];
		res->DipoleInt=DIMO*GAUSSTOnT;
		AddR(res);
		}
	IBBB=0;
	}
	 //else error  in fortran routine, returns fortran error code in IBBB
	else
	{
	IBBB=ICODE[0];
	if( IBBB ==-29) AfxMessageBox(_T("Software not properly installed:\nThe IGRF and DGRF Coeffcients not found"));
	}
delete [] BNORTH; delete [] BEAST; delete []BDOWN;
delete [] XCOR; delete [] BABS; delete [] XL;
delete [] DEC;delete [] DIP; delete [] ICODE;
return(IBBB);
}

 void CIgrfView::EmptyProfile(void)
{// clears the m_Results array of data
if(m_Results.GetSize()==0) return;
for(int i=m_Results.GetUpperBound(); i>=0; i--)
	{
	delete GetR(i);
	}
m_Results.RemoveAll();
} 



void CIgrfView::OnUpdate(CView *pSender, LPARAM lHint, CObject *pHint)
{
if(lHint== VIEWLOAD_FILE && pHint != NULL)
	{//laod the text file into the editview
	CIgrfDoc *pDoc=(CIgrfDoc *)pHint;
	CFile file;
	CFileException  e;
	if(file.Open(pDoc->m_filepath, CFile::modeRead ,&e) ==0)
		{
	  CString err=_T("File could not be opened: \n");
	     err+= e.m_cause;
		AfxMessageBox(err);
		return;
		}

	CArchive ar(&file, CArchive::load );
	SerializeRaw(ar);
	ar.Close();	file.Close();
	}
}
