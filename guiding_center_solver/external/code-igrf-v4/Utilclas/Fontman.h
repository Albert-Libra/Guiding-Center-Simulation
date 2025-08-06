// fontman.h : header file
//
// creats and manages fonts
/* to use first create it with a supplied CDC pointer, this will tehn initialse it with
the family names of availbale fonts. These names can be accessed with
the  GetRasFamFont, GetVecFamFont and GetTrueFamFont, which returns pointers to 
CStringArray objects holding the names

To select a family font, chosse a name from these choices, and call the function:
SelectFontFamily. This will then place the names of INDIVIDUAL FONTS into the object
which can be accessed as if the CFontManger was a CStringArray, ie using GetAt
with approripriate boundary values checked with getupperbound() etc

To find info about the INDIVIDUAL fonts, pass one of these names to the
GetFontInfo, which returns a pointer to the logfont structure for that font.

a font can be selected into the CDC with MakeFont, the fontname should be one
of the individual fonts previously selected from the family
*/
/////////////////////////////////////////////////////////////////////////////
// CFontManager window                

#define MAN_FONT			-1
#define START_BYTE		'\xC8'
class CFontManager : public CStringArray
{   // holds font information, only holds one font in m_Font, but holds family names
// Construction
public:
	CFontManager(CDC *pDC);      // loads the family names
	CFontManager(CDC *pDC, int FType, LPCTSTR FamName); // loads family, and fonts in family
	CStringArray m_Vec; //vector font family names
	CStringArray m_Ras; // rastor font  family names
	CStringArray m_True; // true type font family names
	
private:
    CString m_SelectedFont; // name of selected font
    LOGFONT	m_Font; // stores info about font
    short m_ftype;
    BYTE m_Pitch;// the lfpitchand family in logfont, ==0 if not set
// Attributes
public:  
CStringArray *GetRasFamFont(void) { return (&m_Ras);};
CStringArray *GetVecFamFont(void) { return (&m_Vec);};
CStringArray *GetTrueFamFont(void) { return (&m_True);};
void SetPitch(BYTE p) { m_Pitch=p;};// sets pitch and family
int SelectFontFamily(CDC *pDC, int FType, LPCTSTR fontname); // selects font family into manager
LOGFONT *GetFontInfo(CDC *pDC, LPCTSTR fontname);// gets font info into logfont strcut, must be one family stored
int GetNumFonts(void) {return (GetSize());};// number of fonts stored

// Operations
public:
CFont *MakeFont(CDC *pDC, CFont& font, int PointSize, int Ftype, LPCTSTR fname);
private:
void AddRastor(LPTSTR str) ;
void AddVector(LPTSTR str) ;
void AddTrue(LPTSTR str) ;
void AddFont(LPTSTR str) ;// adds a font name to main list in m_Font
int SearchNames(int fType, CString& name);// searchs for name of font in databases
void SetFamilyNames(CDC *pDC); // stores
// Implementation
public:
	virtual ~CFontManager();
};
// sets pointer for number of families of fonts 
int CALLBACK  AFX_EXPORT EnumCallBackNum(LPLOGFONT lplf, 
			LPNEWTEXTMETRIC lpntm, short FontType, LPARAM fontcount);
// stores font names
int CALLBACK   AFX_EXPORT EnumFamCallBack(LPLOGFONT lplf, 
			LPNEWTEXTMETRIC lpntm, short FontType, LPARAM pCstr);
// copies logfont info into logfont strcuture
int CALLBACK   AFX_EXPORT EnumFamCallBackInfo(LPLOGFONT lplf, 
			LPNEWTEXTMETRIC lpntm, short FontType, LPARAM plogf);



/////////////////////////////////////////////////////////////////////////////
                                               