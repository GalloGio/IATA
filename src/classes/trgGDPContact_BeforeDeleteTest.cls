@isTest
private class trgGDPContact_BeforeDeleteTest {  
    
    static testMethod void myUnitTest() {
        
        ID gdpContactRecordTypeID = TestClass_SetupVariables.gdpContactRecordTypeID;        
        Contact con = new Contact();
        con.FirstName = 'Name';
        con.LastName = 'TestContact';
        con.RecordTypeId = gdpContactRecordTypeID;
        insert con;
        List<Profile> profiles = [SELECT Id FROM Profile WHERE  Name = 'System Administrator' limit 1];       
        List<User> u = [SELECT Id FROM User WHERE ProfileId =: profiles[0].Id AND IsActive = true];
        
        ID standardContactRecordTypeID = clsContactTypeIDSingleton.getInstance().RecordTypes.get('Standard');  
        Contact con1 = new Contact();
        con1.FirstName = 'Name';
        con1.LastName = 'TestContact';
        con1.Email = 'email@email.org';
        con1.VER_Number__c = 123456;
        con1.RecordTypeId = standardContactRecordTypeID;
        insert con1; 
        
        Profile p = [SELECT Id,Name FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'standt', Email='standarduser@testorg.com', 
                           EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                           LocaleSidKey='en_US', ProfileId = p.Id, 
                           TimeZoneSidKey='America/Los_Angeles', UserName='asd123123@testorg.com', License_Cost_Center__c = 'ISF005CH01');
        insert u1;
        con1.OwnerId = u1.Id;
        update con1;   
        
        test.startTest();  
        System.runAs(u[0])
        {
            delete con;          
        }   
        
        System.runAs(u1) {
            try
            {
                delete con1;                      
                
            }
            catch (DMLException e)
            {
                con1.addError('there was a problem...');
            } 
        }
        
        List<Contact> lcon = [SELECT Id from Contact WHERE Id =: con1.Id];		
        System.assertEquals(lcon.size() == 0,false);
        
        System.runAs(u[0]){       
            try
            {
                delete con1;           
                
            }
            catch (DMLException e)
            {
                con1.addError('there was a problem...');
            }                  
        }
        
        lcon = [SELECT Id from Contact WHERE Id =: con1.Id];		
        System.assertEquals(lcon.size() == 0,true);
        
        test.stopTest();
    }
}