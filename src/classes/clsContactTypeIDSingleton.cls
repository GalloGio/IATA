public class clsContactTypeIDSingleton {
    
    //Note: this is the static handle to the single class reference.
    //Its completely hidden to outside world. PRIVATE access modifier used  
    private static clsContactTypeIDSingleton self;
    private map<String, ID> m_recordTypes;
    
    // Private constructor
    private clsContactTypeIDSingleton(){
        
        List<RecordType> types = [SELECT r.Id, r.Name FROM RecordType r WHERE SobjectType  = 'Contact' AND isActive = true];
        m_recordTypes = new map<String, ID>();
        
        for (RecordType aType : types){
            m_recordTypes.put(aType.Name, aType.Id);
        }
    }
    
    
    //This static method will be the only way to get the Single 
    //instance of this class.
    public static clsContactTypeIDSingleton getInstance(){
        
        if (self != null) return self;
        
        self = new clsContactTypeIDSingleton();
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
        map<String, Id> recordtypes = clsContactTypeIDSingleton.getInstance().RecordTypes;
        
     //   system.assertEquals(recordtypes.size(), 7);
    }
}