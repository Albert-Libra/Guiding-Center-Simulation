// header file for  genmfc.cpp

#define ERR_BOX	0
#define ERR_TRACE	 1
#define ERR_DUMP	2
#define STRING_FREE	  100	  //used by extractstring to determine type of parseing 
#define STRING_CONNECTED	200
// error messages used by DisplayDocError
#define FILE_LOADERROR	-1  // error on reading, or decoding line
#define FILE_DATAERROR	-2 // data does not conform to that expected
#define DOCER_UNFORMAT		100 // unexpected ASCII file foemat
#define DOCER_EMPTY		101 // empty document on reading
#define DOCER_NOTGM400	102 // not gm400 record 
#define DOCER_INCGM400	103 // incomplete gm400 record detected in file
#define DOCER_WREMPTY	104 // empty doc trying to save
#define DOCER_REVCCORE	105 // trying to do reverse core correction
#define DOCER_FMTINCORRECT	106// cannot load this format of file

#ifdef __cplusplus
extern "C" {
#endif /* ---cplusplus */

 __declspec(dllexport)char FAR*   StrLtrim(LPTSTR str);// trims leading spaces off string
__declspec(dllexport) char FAR*   StrRtrim(LPTSTR str);// trims trailing spaces off string
  __declspec(dllexport) char FAR*  TrimTails(LPTSTR str);// trims both space tails     
  __declspec(dllexport) int   FAR   ExtractDelimitedText(LPTSTR input, char left, char right, LPTSTR str);
 __declspec(dllexport) int    FAR   RemoveExcessSpaces(LPTSTR  pstr);// removes excess spaces from string- used with sscanf
  __declspec(dllexport) int   FAR   ExtractStrings(LPTSTR numbers, LPTSTR strings, const UINT style);//, numbers contains input expression
 __declspec(dllexport) int FAR IsolateNumbers(LPTSTR pNum);// removes the padding characters in strings, returning in pNum a string with only numbers seperated by 1 space.
 __declspec(dllexport) void   FAR   Replace(LPTSTR strModify, LPCTSTR pszWhat, LPCTSTR pszWith);
 __declspec(dllexport) int  FAR   atof5(LPCTSTR str, float FAR* f1, float FAR* f2, float FAR* f3, float FAR* f4, float FAR* f5);// converts the 5 numbers contained in str into values in f1 to f5
 __declspec(dllexport) void   FAR   CurrentDate(LPTSTR date);// gets current date
 __declspec(dllexport) void   FAR   CurrentTime(LPTSTR time);// gets current time
 __declspec(dllexport) int   FAR   DisplayDocError(int ErrCode, UINT style);
 __declspec(dllexport) void   FAR    DisplayCFileErr(int cause, int opstream); 	 // displays the error passed to it. opstream=ERR_BOX , if to AFxmessageBox, 	ERR_TRACE if to TRACE
		// if Look Back=TRUe finds the character immdiately after the delim delimiters  =FALSE finds the char immediately precedding the delimter
		//in each case it returns the position in string of this character
int FindFromHere(LPTSTR pszStr, int pos, LPCTSTR delim, BOOL LookBack);

//do to with decoding text files
__declspec(dllexport) LPTSTR strstrN(LPCTSTR str, const TCHAR c, int N); // returns the Nth occurrence of character c in str
		// breaks the ascii str in bptr (length ibuflen) into none or more lines of data and placed into arr
__declspec(dllexport) int   BreakIntoLines(CPtrArray& arr, LPCTSTR bptr, int buflen,
										   BOOL removeblank=FALSE, BOOL ChangeContent=TRUE); 
__declspec(dllexport) void DeleteLineContents(CPtrArray& Lines);    //for removing the string assigned by BreakintoLines()
		// filter for text file- will read it and break it into lines of text, compressing
		// the lines so only 1 blank space between each item on each line
__declspec(dllexport) int   ReadTextDataFile(CArchive& ar, CPtrArray& Lines);
__declspec(dllexport) int FindNumColumns(LPCTSTR pStr, TCHAR c=' '); // returns with the number of columns delimited by c in pStr

__declspec(dllexport) LPTSTR ConvertDelimitersToSpace(LPTSTR str);	//converts the tab and ',' delimiters to spaces
		// write and read a window placement to settings section of app's ini file
__declspec(dllexport) void WriteWindowPlacement(LPWINDOWPLACEMENT pwp,TCHAR *szValue);
__declspec(dllexport) BOOL ReadWindowPlacement(LPWINDOWPLACEMENT pwp, TCHAR* szValue);

#ifdef __cplusplus
}
#endif 
   