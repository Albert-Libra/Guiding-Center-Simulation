// igrfdoc.h : interface of the CIgrfDoc class
//
/////////////////////////////////////////////////////////////////////////////
#define VIEWLOAD_FILE 200
#define VIEWSAVE_FILE 201

class CIgrfDoc : public CDocument
{
protected: // create from serialization only
	CIgrfDoc();
	DECLARE_DYNCREATE(CIgrfDoc)

// Attributes
public:
	CString m_filepath;
// Operations
public:

// Implementation
public:
	BOOL LoadTextFile( LPCSTR lpszFileName);
	virtual ~CIgrfDoc();
	virtual void Serialize(CArchive& ar);	// overridden for document i/o
#ifdef _DEBUG
	virtual	void AssertValid() const;
	virtual	void Dump(CDumpContext& dc) const;
#endif
protected:
	virtual	BOOL	OnNewDocument();

// Generated message map functions
protected:
	//{{AFX_MSG(CIgrfDoc)
		// NOTE - the ClassWizard will add and remove member functions here.
		//    DO NOT EDIT what you see in these blocks of generated code !
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////
