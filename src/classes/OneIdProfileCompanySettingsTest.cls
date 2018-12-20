@IsTest
private class OneIdProfileCompanySettingsTest {
    
     @isTest static void testMethod01()
     {  
        
        UserRole ur = [SELECT id  FROM UserRole where DeveloperName = 'TAPPartnerUser'];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal (Partner)'];
        
        Contact con = [select id, email,firstName,lastname,accountid from contact where Senior_Contact_Email__c = 'senior@dev.com'  limit 1 ];
        System.assert(con != null, 'User Contact is null');
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);   
         
        con.OwnerId = newUser.Id;
        update con;                                     
        
        System.runAs (newUser){
         
            Test.startTest();
          
            system.debug('Running as user: ' + newUser);
             
            Contact cnt = OneIdProfileCompanySettings.getUserContact();
         
            System.assert(Cnt != null, 'Contact is null');
         
            OneIdProfileCompanySettings.getCategoryPicklistValues();         
            OneIdProfileCompanySettings.getPreferredLanguagePicklistValues();
            OneIdProfileCompanySettings.getUserInfo();         
            OneIdProfileCompanySettings.saveProfileEdit('string' , 'string1', 'string2', 'string3', 'string4', 'string5', 'string6', 'string7');               

            Test.stopTest();
            
            /*EM The functionality used to create the contact has been completely changed
            system.assertEquals('test', [Select Firstname From Contact where id=:con.id].Firstname);        
            system.assertEquals('string2',[Select Phone From Contact where id=:con.id].Phone);
            system.assertEquals('string3',[Select MobilePhone From Contact where id=:con.id].Phone);
            system.assertEquals('string4',[Select Fax From Contact Where id=:con.id].Fax);
            system.assertEquals('string5',[Select Title From Contact Where id =:con.id].Title);
            system.assertEquals('string6',[Select Membership_Function__c From Contact Where id=:con.id].Membership_Function__c);
            system.assertEquals('string7',[Select Preferred_Language__c From Contact Where id =:con.id].Preferred_Language__c); */
         
        }
           
    }
     
    @testSetup static void setup() {
        Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.RecordTypeId = recordTypeId;       
        insert acc;
          
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Approved User';
        insert con;

    }     

}