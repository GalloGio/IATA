@isTest (SeeAllData=true)
public with sharing class Faq2Case2Test {
        
    static testMethod void testFaq2Case010() {
		Id agencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account testAccount = new Account(
			name= 'testAccount',
			CNS_Account__c = true,
			Sector__c ='Airline',
			RecordTypeId = agencyRecordTypeId
		);
		insert testAccount;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
		IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'United States', ISO_Code__c = 't1', Case_BSP_Country__c = 'test1', Region__c = 'Europe');
		insert country;

		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
		
		//Case c=new Case(Subject='test 1',Status='Open', AccountId=parent.id, ContactId=con.id, Region__c = 'Europe', IFAP_Country_ISO__c ='t1' , RecordTypeId = recordTypeId);
		//insert c;
		
        con.AccountId= testAccount.Id;
		con.Email = 'Test@test11.com';
		con.CNS_Contact__c = true;
        insert con;
        
        System.debug('con Id: ' + con.Id);
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        
       
        Test.startTest();
        System.runAs(newUser)
        {
		  vfISSP_FAQ2Case controller = new vfISSP_FAQ2Case();
		  controller.pageLoad();
		  controller.topic = '2';
		  //controller.refreshAirlineList();
		  controller.setRecordType();
		  controller.create();
		  	  controller.back();
		  controller.refreshTopicPickList();
		  controller.refreshSubTopicPickList();
		  controller.subtopic = ENV.SelectOptionDefaultValue;
		  controller.refreshSubTopicPickList();
		  controller.createSatisfiedRecord();
		  controller.GeneralQueueMethod();
		  controller.CheckNewCaseRecordType();
		  controller.GenerateTopicHelpText();
		  controller.GeneratesubTopicHelpText();
		  //Set<String> stString = controller.topicsToShowButton;
		  Boolean b = controller.showButton;
		  Boolean b2 = controller.isAllowedCode('test');
		//   Boolean b3 = controller.isAllowedSector('test');
		  PageReference pr = controller.getSelectArtical();
		  PageReference pr2 = controller.create1();
		  PageReference pr3 = controller.ComplimentGeneralQueueMethod();
		  Boolean b4 = controller.isArticalSelected;
		//   controller.refreshAirlineList();

		  controller.isCompliment1 = true;
		  Case newCase = controller.newCase;
		  Case newCase1 = controller.newCase1;
		  newCase.IFAP_Country_ISO__c ='t1';
		  //controller.newCase1.IFAP_Country_ISO__c ='t1';
		  //controller.copyCountryISO();
		  
		  newCase.Subject = 'test';
		  newCase.Description = 'test';
		  controller.topic = '0';
		  controller.subtopic = 'CGO_Bank_Guarantees__c';
		  controller.newCase.IFAP_Country_ISO__c ='t1';
          Boolean sb = controller.showButton;
          //controller.save();

          controller.save();
		}
		Test.stopTest();
    }
    
}