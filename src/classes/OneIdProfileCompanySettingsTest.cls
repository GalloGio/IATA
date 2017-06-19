@IsTest
private class OneIdProfileCompanySettingsTest {
    
     @isTest static void testMethod01()
     {	
		
		UserRole ur = [SELECT id  FROM UserRole where DeveloperName = 'TAPPartnerUser'];
        
        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal (Partner)'];
		
    	Contact con = [select id, email,firstName,lastname,accountid from contact where Senior_Contact_Email__c = 'senior@dev.com' and email = 'ISSP_test@test.test'  limit 1 ];
    	System.assert(con != null, 'User Contact is null');
    	
        /*User newUser = new User(alias = 'dsfsdfds', 
                                email = con.email,
                                ContactID = con.id,
                                emailencodingkey = 'UTF-8', 
                                firstname = con.firstName, 
                                lastname = con.lastname, 
                                languagelocalekey = 'en_US', 
                                localesidkey = 'en_US',	                            
                                timezonesidkey = 'Asia/Dubai',
                                username = con.email+'dfgdf',
                                PortalRole = 'Manager',
                                UserRoleId = ISSP_Constant.TEST_User_ProfileID,
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = p.id,
                                IsActive = true);
                                */
                                
		 User newUser = ISSP_ObjectFactory.createPortalUser(con);   
		 
 		 con.OwnerId = newUser.Id;
		 update con;                             		
         System.runAs (newUser){
         
          //Contact con1 = [select id, email,firstName,lastname from contact where Senior_Contact_Email__c = 'senior@dev.com' and email = 'ISSP_test@test.test'  limit 1 ];
          //System.debug('debugggg1' + con1);
    	  //System.assert(con1 != null, 'User Contact is null');
		
         system.debug('debug' + newUser);
             
         Contact cnt = OneIdProfileCompanySettings.getUserContact();
         
         System.assert(Cnt != null, 'Contact is null');
             
         
         OneIdProfileCompanySettings.getCategoryPicklistValues();         
         OneIdProfileCompanySettings.getPreferredLanguagePicklistValues();
         OneIdProfileCompanySettings.getUserInfo();         
         OneIdProfileCompanySettings.saveProfileEdit('string' , 'string1', 'string2', 'string3', 'string4', 'string5', 'string6');                
         system.assertEquals('string', [Select Firstname From Contact where id=:con.id].Firstname);        
         system.assertEquals('string2',[Select Phone From Contact where id=:con.id].Phone);
         system.assertEquals('string3',[Select Fax From Contact Where id=:con.id].Fax);
         system.assertEquals('string4',[Select Title From Contact Where id =:con.id].Title);
         system.assertEquals('string5',[Select Membership_Function__c From Contact Where id=:con.id].Membership_Function__c);
         system.assertEquals('string6',[Select Preferred_Language__c From Contact Where id =:con.id].Preferred_Language__c);
         
         }   
     }
     
	@testSetup static void setup() {
		String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'IATA_Airline'].Id;
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