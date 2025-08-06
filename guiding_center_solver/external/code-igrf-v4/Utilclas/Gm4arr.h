// class CGM400Array, holds arrays of GM400 structures 
// designed for compiling into a static library used by MFC and CPP routines

class CGM400Array : public CPtrArray
{
// holds, and manipulates the array of gm400 structures
// this class does not know how to change the values in the
// GM400 strcuture, that is known by the document only
public :
	// constructor  
		CGM400Array() {return;};
		DECLARE_DYNCREATE(CGM400Array)                       
		~CGM400Array(){ DeleteContents();};
// manipulation functions
	    GM400REC *Get(int index) { ASSERT(index >=0 && index <=GetUpperBound());
	    		return ((GM400REC*) GetAt(index));};
	    int Set(int index, GM400REC *rec); // set single gm400
	    int Insert(int index, GM400REC *rec); // insert   new value at index
	    int Insert( int index, CGM400Array& array); // insert array of gm400
		void Delete(int index); // delete one record
		int Delete(int index, int num); // deletes many
	void DeleteContents(void);	    
}; 
// flags for type of edit operation last performed
#define EDIT_INIT	-1 // initialise the values to unset
#define UNDO_CUT	100
#define UNDO_PASTE	101
#define UNDO_COPY	102
#define UNDO_UNDO	103
#define SORT_LIST	104  // tells it it will contain a sort list

class CEditSelect : public CWordArray
{
// holds information  about the last edit operation, so that the operation can be
// undone.
// Holds WORD's which indicate the indexes of the values modified
private:
			int Operation;// holds last operation flag, applies to all stored indexes
			int AppCode;// indicates a unique edit operation code supplied by application
public:
	CEditSelect() { Operation=EDIT_INIT; AppCode=EDIT_INIT; return;};
	DECLARE_DYNCREATE (CEditSelect)
	~CEditSelect() {};
// manipulation functions
	void Refresh() {RemoveAll();} //clears storage for new operation
	void AddIndex( int index) {Add( (WORD) index);};  
	void SetCodes(int op, int code); 
	int GetIndex(int i) { return ( (int) GetAt(i));};
	int GetOperation(void) {return (Operation);};
	int GetAppCode(void) { return (AppCode);};
	void Duplicate(CEditSelect& obj); // duplicates the supplied obj-ie copy it
	int FindValue(int val); // finds the index position of the supplied value
} ;

 