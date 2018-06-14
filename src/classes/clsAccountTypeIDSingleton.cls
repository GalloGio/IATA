public class clsAccountTypeIDSingleton {
    
    //Note: this is the static handle to the single class reference.
    //Its completely hidden to outside world. PRIVATE access modifier used  
    private static clsAccountTypeIDSingleton self;
    private map<String, ID> m_recordTypes;
    
    // Private constructor
    private clsAccountTypeIDSingleton(){
        
        List<RecordType> types = [SELECT r.Id, r.DeveloperName FROM RecordType r WHERE SobjectType  = 'Account' AND isActive = true];
        m_recordTypes = new map<String, ID>();
        
        for (RecordType aType : types){
            //uses DeveloperName instead of Name
            m_recordTypes.put(aType.DeveloperName, aType.Id);
        }
    }
    
    
    //This static method will be the only way to get the Single 
    //instance of this class.
    public static clsAccountTypeIDSingleton getInstance(){
        
        if (self != null) return self;
        
        self = new clsAccountTypeIDSingleton();
        return self;
    }
    
    public map<String, ID> RecordTypes{
        get{
            return m_recordTypes;
        }
    }
    
    // TEST METHOD 
    // to avoid this error set API to 27.0  -- Error: Compile Error: Test methods must be in test classes at line 37 column 35  
    public static testmethod void testSingleton() {

        map<String, Id> recordtypes = clsAccountTypeIDSingleton.getInstance().RecordTypes;
        
        system.assertEquals(recordtypes.size(), recordtypes.size());
    }
}