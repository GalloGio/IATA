public class clsCaseRecordTypeIDSingleton {
	
	//Note: this is the static handle to the single class reference.
  	//Its completely hidden to outside world. PRIVATE access modifier used  
	private static clsCaseRecordTypeIDSingleton self;
	private map<String, ID> m_recordTypes;
	
	// Private constructor
	private clsCaseRecordTypeIDSingleton(){
		
		system.debug('clsCaseRecordTypeIDSingleton constructor');
		List<RecordType> types = [Select r.Id, r.Name From RecordType r Where SobjectType  = 'Case'];
		m_recordTypes = new map<String, ID>();
		
		for (RecordType aType : types){
			m_recordTypes.put(aType.Name, aType.Id);
		}
	}
	
	
    //This static method will be the only way to get the Single 
    //instance of this class.
	public static clsCaseRecordTypeIDSingleton getInstance(){
		
		if (self != null) return self;
		
		self = new clsCaseRecordTypeIDSingleton();
		return self;
	}
	
	public map<String, ID> RecordTypes{
		get{
			return m_recordTypes;
		}
	}
	
	// TEST METHOD
  	public static testmethod void testSingleton() {
    	//Will print "Hello World" on console.
    	map<String, Id> recordtypes = clsCaseRecordTypeIDSingleton.getInstance().RecordTypes;
    	
    	//system.assertEquals(recordtypes.size(), 32);
  	}
}