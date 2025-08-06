
class CPrintingDialog : public CDialog
{
public:
	//{{AFX_DATA(CPrintingDialog)
	enum { IDD = AFX_IDD_PRINTDLG };
	//}}AFX_DATA
	CPrintingDialog::CPrintingDialog(CWnd* pParent)
		{
			Create(CPrintingDialog::IDD, pParent);      // modeless !
//			afxUserAbort = FALSE;
		}

	virtual BOOL OnInitDialog();
	virtual void OnCancel();

protected:

#if 0 // for ClassWizard's use only
	//{{AFX_MSG(CPrintingDialog)
	//}}AFX_MSG
	DECLARE_MESSAGE_MAP()
#endif
};
BOOL CALLBACK AFX_EXPORT _AfxAbortProc(HDC, int);

