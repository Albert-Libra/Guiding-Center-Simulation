// igrfdoc.cpp : implementation of the CIgrfDoc class
//

#include "stdafx.h"
#include "splash.h"
#include "..\utilclas\general.h"

#include "proflong.h"
#include "proflat.h"
#include "profHt.h"
#include "profdate.h"
#include "igrfdoc.h"
#include "igrfview.h"

#include "igrf.h"
#include "igrfdlg.h"



#ifdef _DEBUG
#undef THIS_FILE
static char BASED_CODE THIS_FILE[] = __FILE__;
#endif

/////////////////////////////////////////////////////////////////////////////
// CIgrfDoc

IMPLEMENT_DYNCREATE(CIgrfDoc, CDocument)

BEGIN_MESSAGE_MAP(CIgrfDoc, CDocument)
	//{{AFX_MSG_MAP(CIgrfDoc)
		// NOTE - the ClassWizard will add and remove mapping macros here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG_MAP
END_MESSAGE_MAP()

/////////////////////////////////////////////////////////////////////////////
// CIgrfDoc construction/destruction

CIgrfDoc::CIgrfDoc()
{
	// TODO: add one-time construction code here
}

CIgrfDoc::~CIgrfDoc()
{                                                  
}

BOOL CIgrfDoc::OnNewDocument()
{
	if (!CDocument::OnNewDocument())
		return FALSE;
	// TODO: add reinitialization code here
	// (SDI documents will reuse this document) 
	SetTitle("Geomagnetic Reference Field");

	return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CIgrfDoc serialization

void CIgrfDoc::Serialize(CArchive& ar)
{
if(!ar.IsLoading())
	{// save any text
	POSITION pos=GetFirstViewPosition();
	ASSERT(pos !=NULL);
	CView* pView;
	while (pos !=NULL)
		{
		pView=GetNextView(pos);
		if(pView->IsKindOf(RUNTIME_CLASS(CIgrfView)) )
			{// ceditview should be second in template	
			((CIgrfView *) pView)->SerializeRaw(ar);
			}
	}
	SetModifiedFlag(FALSE);// set to fresh
	}
}

BOOL CIgrfDoc::LoadTextFile(LPCSTR lpszFileName)
{ 
m_filepath=lpszFileName;
UpdateAllViews(NULL, VIEWLOAD_FILE, this);
return TRUE;
}

/////////////////////////////////////////////////////////////////////////////
// CIgrfDoc diagnostics

#ifdef _DEBUG
void CIgrfDoc::AssertValid() const
{
	CDocument::AssertValid();
}

void CIgrfDoc::Dump(CDumpContext& dc) const
{
	CDocument::Dump(dc);
}

#endif //_DEBUG

/////////////////////////////////////////////////////////////////////////////
// CIgrfDoc commands


