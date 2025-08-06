#if !defined(AFX_LBEDITORWND_H__0C870AC1_BE09_4983_8993_68726834ABA3__INCLUDED_)
#define AFX_LBEDITORWND_H__0C870AC1_BE09_4983_8993_68726834ABA3__INCLUDED_

#if _MSC_VER > 1000
#pragma once
#endif // _MSC_VER > 1000
// LBEditorWnd.h : header file
//

/////////////////////////////////////////////////////////////////////////////
// CLBEditorWnd window

/*
 *		@doc
 *
 *		@class Edit box for in-place editing of list box items
 */
class CLBEditorWnd : public CEdit
{
// Construction
public:
	// @cmember Constructor
	CLBEditorWnd( CListBox* pLB );

protected:
	// @cmember Destructor
	virtual ~CLBEditorWnd();

// Attributes
public:

// Operations
public:
	// @cmember Starts editing
	bool Edit( int n );

// Overrides
	// ClassWizard generated virtual function overrides
	//{{AFX_VIRTUAL(CLBEditorWnd)
	//}}AFX_VIRTUAL

// Implementation

	// Generated message map functions
protected:
	// @cmember Index of item being edited
	int m_edit_index;
	// @cmember List box containing item being edited
	CListBox* m_pLB ;
	// @cmember Flag to prevent EndEditing() from executing more than once
	bool m_edit_ended ;

	// @cmember Ends edit sequence, optionally updating the list box
	void EndEditing( bool b = true );
	
	//{{AFX_MSG(CLBEditorWnd)
	afx_msg void OnLButtonDown(UINT nFlags, CPoint point);
	afx_msg void OnNcDestroy();
	afx_msg void OnKeyDown(UINT nChar, UINT nRepCnt, UINT nFlags);
	afx_msg UINT OnGetDlgCode();
	afx_msg void OnKillfocus();
	//}}AFX_MSG

	DECLARE_MESSAGE_MAP()
};

/////////////////////////////////////////////////////////////////////////////

//{{AFX_INSERT_LOCATION}}
// Microsoft Visual C++ will insert additional declarations immediately before the previous line.

#endif // !defined(AFX_LBEDITORWND_H__0C870AC1_BE09_4983_8993_68726834ABA3__INCLUDED_)
