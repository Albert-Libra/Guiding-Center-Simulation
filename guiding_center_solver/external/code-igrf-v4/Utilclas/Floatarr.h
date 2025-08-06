// floatarr.H
// also contains  code for routines which pass MFC objects in function headers
////////////////////////////////////////////////////////////////////////////

class CFloatArray : public CObject
{

	DECLARE_SERIAL(CFloatArray)
public:

// Construction
	CFloatArray();

// Attributes
	int GetSize() const 	{ return m_nSize; };
	int GetUpperBound() const 	{ return m_nSize-1; };
	void SetSize(int nNewSize, int nGrowBy = -1) 	;

// Operations
	// Clean up
	void FreeExtra();
	void RemoveAll(){ SetSize(0); };

	// Accessing elements
	float GetAt(int nIndex) const { ASSERT(nIndex >= 0 && nIndex < m_nSize);
		return m_pData[nIndex]; };
	void SetAt(int nIndex, float newElement) 	{ ASSERT(nIndex >= 0 && nIndex < m_nSize);
		m_pData[nIndex] = newElement; };
	float& ElementAt(int nIndex) { ASSERT(nIndex >= 0 && nIndex < m_nSize);
		return m_pData[nIndex]; };

	// Potentially growing the array
	void SetAtGrow(int nIndex, float newElement);
	int Add(float newElement){ int nIndex = m_nSize;
		SetAtGrow(nIndex, newElement);
		return nIndex; };
	void Copy( CFloatArray *Arr) {SetSize(0);InsertAt(0,Arr);}
	void Append(CFloatArray *Arr) {int nIndex = m_nSize;
				InsertAt(nIndex,Arr);}

	// overloaded operator helpers
	float operator[](int nIndex) const 	{ return GetAt(nIndex); };
	float& operator[](int nIndex) 	{ return ElementAt(nIndex); };

	// Operations that move elements around
	void InsertAt(int nIndex, float newElement, int nCount = 1);
	void RemoveAt(int nIndex, int nCount = 1);
	void InsertAt(int nStartIndex, CFloatArray* pNewArray);
	void Invert(void);// inverts the order of the elements
// for sorting 
	BOOL Sort(BYTE way); // sorts insitu
	BOOL SortTo(CWordArray& order, BYTE way); // returns sorted order in order
	BOOL AreSame(float f1, float f2);

// Implementation
protected:
	float* m_pData;   // the actual array of data
	int m_nSize;     // # of elements (upperBound - 1)
	int m_nMaxSize;  // max allocated
	int m_nGrowBy;   // grow amount 
	float *m_array; //used by sorting routines 
	
	BOOL SortArray(BYTE way);



public:
	~CFloatArray();

	void Serialize(CArchive&);
#ifdef _DEBUG
	void Dump(CDumpContext&) const;
	void AssertValid() const;
#endif 
                                                   
};

BOOL SortFloatArray(CFloatArray&  Nums, CWordArray&  order, BYTE way);
//  int  FAR FloatCompareAscend( const void* arg1, const void* arg2 );
//  int  FAR FloatCompareDecend( const void* arg1, const void* arg2 );

BOOL   SortLists(CStringArray& sp, CStringArray& holder, int order);
																																 
 int  FAR FloatCompareAscend( const void FAR *arg1, const void FAR* arg2 );
 int  FAR FloatCompareDecend( const void FAR* arg1, const void FAR* arg2 );

