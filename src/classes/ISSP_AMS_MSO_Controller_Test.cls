@isTest
private class ISSP_AMS_MSO_Controller_Test {
	
	@isTest static void test_method() {

		Test.startTest();

        Id conRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='Standard_Contact' AND SobjectType = 'Contact'].Id;
        Id accRtId = [SELECT Id FROM RecordType WHERE DeveloperName ='IATA_Airline' AND SobjectType = 'Account'].Id;

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account acc = new Account (
	        RecordTypeId = accRtId,
	        Name = 'Airline HQ', 
	        IATACode__c = '012',
	        IATA_ISO_Country__c = isoc.Id
	        );  
        insert acc;

        Contact con = new Contact (
	        AccountId = acc.id,
	        RecordTypeId = conRtId, 
	        LastName = 'portalUser',
	        User_Portal_Status__c = 'Approved User'
	        );
        insert con;

        Profile p = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Airline User (Partner)' LIMIT 1];
         
        User newUser = new User(
	        profileId = p.id,
	        username = 'someuser@iata.org',
	        email = 'someuser@iata.org',
	        emailencodingkey = 'UTF-8',
	        localesidkey = 'en_US',
	        languagelocalekey = 'en_US',
	        timezonesidkey = 'America/Los_Angeles',
	        alias='nuser',
	        lastname='lastname',
	        contactId = con.id
	        );
        insert newUser;

        System.runAs(newUser){
        	PageReference pageRef = Page.ISSP_AMS_MSO;
			Test.setCurrentPage(pageRef);
            ISSP_AMS_MSO_Controller ctrl = new ISSP_AMS_MSO_Controller();
            
            ctrl.searchText = 'dsd';
            ctrl.refreshMsoGsaList();

            system.assertEquals(false, ctrl.hasNext);
            system.assertEquals(false, ctrl.hasPrevious);
            system.assertEquals(1, ctrl.pageNumber);
            system.assertEquals(0, ctrl.totalPages);
            system.assertEquals(5, ctrl.getselectOptionItems().size());
            system.assertEquals(0, ctrl.lstDisplayAccounts.size());

            ctrl.first();
            ctrl.last();
            ctrl.previous();
            ctrl.next();


            system.assertEquals('/ISSP_Homepage', ctrl.checkIfUserHasAccessToService().getUrl());

        }

        Test.stopTest();

	}
	
}