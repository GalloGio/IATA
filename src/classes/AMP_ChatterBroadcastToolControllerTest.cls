@isTest
private class AMP_ChatterBroadcastToolControllerTest {
	
	@isTest static void test_Method() {
		// CREATE TEST DATA
        		
		// create the custom setting values
        AMP_Account_Topics__c acceptedTopic = new AMP_Account_Topics__c(Name = 'Cargo');
        Insert acceptedTopic;

        // Create a new ISO Country
        IATA_ISO_Country__c country_qr = new IATA_ISO_Country__c(Name = 'Qatar', ISO_Code__c = 'QR', Region__c = 'Africa & Middle East');
        insert country_qr;
                
        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger', 
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_qr.Id, Membership_status__c = 'IATA member');
        insert acct_hq;


        test.startTest();
			
			PageReference pageRef = Page.AMP_ChatterBroadcastTool;
			
			Test.setCurrentPage(pageRef);

			ApexPages.currentPage().getParameters().put('accountId', acct_hq.Id);
		
        	AMP_ChatterBroadcastToolController ctrl = new AMP_ChatterBroadcastToolController();
        	system.assertEquals(1, ctrl.lstAccounts.size());
        	system.assertEquals(6, ctrl.getlstRegions().size());

        	ctrl.lstAccounts[0].isSelected = true;
        	ctrl.GoToStep2();
        	ctrl.GoBackToStep1();

        	ctrl.message = 'test broadcast #Cargo';

        	ctrl.BroadcastMessage();

        	ctrl.RestartFromStep1();

        	// verify that the message was broadcast
        	list<FeedItem> lstFIs = [SELECT Id FROM FeedItem WHERE ParentId = :acct_hq.Id];

        	system.assertEquals(1, lstFIs.size());


        test.stopTest();
	}
	
}