@isTest
private class ANG_TrackingHistoryTest {

	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry ;

		Account acc = new Account();
		acc.Name = 'HE Account';
		acc.Sector__c = 'Travel Agent';
		acc.Category__c = 'IATA Passenger Sales Agent';
		acc.Location_Type__c = 'HE';
		acc.Location_Class__c = 'P';
		acc.IATA_ISO_Country__c = ctry.Id;
		acc.Reason_for_creation__c = 'Account is missing';
		acc.RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Standard Account').RecordTypeId ;
		acc.VAT_Number_2__c = '666';
		acc.Abbreviated_address__c = 'Lisbon';
		acc.Legal_Name__c = 'Winterfell';

		insert acc;

	}
	
	@isTest static void testAccountChange() {

		Account acc = [SELECT Id FROM Account];

		acc.VAT_Number_2__c = '999';
		acc.Abbreviated_address__c = 'Leiria';

		update acc;

		List<ANG_Account_Tracking_History__c> historyRecords = new List<ANG_Account_Tracking_History__c>([SELECT Id, Old_Value__c, New_Value__c, What__c FROM ANG_Account_Tracking_History__c]);

		system.assertEquals(historyRecords.size(), 2);

		Integer count = 0;

		for(ANG_Account_Tracking_History__c hr: historyRecords){
			if(hr.What__c == 'VAT Number 2'){
				system.assertEquals(hr.Old_Value__c, '666');
				system.assertEquals(hr.New_Value__c, '999');
				count++;
			}
			else if(hr.What__c == 'Abbreviated address'){
				system.assertEquals(hr.Old_Value__c, 'Lisbon');
				system.assertEquals(hr.New_Value__c, 'Leiria');
				count++;
			}
		}

		system.assertEquals(count, 2);

	}


	@isTest static void testCustomHistoryTrackingController() {

		Account acc = [SELECT Id, VAT_Number_2__c, Abbreviated_address__c, Legal_Name__c FROM Account];

		acc.VAT_Number_2__c = '999';
		acc.Abbreviated_address__c = 'Leiria';

		update acc;
        
        PageReference pageRef = Page.ANG_AccountTrackingHistory;
        pageRef.getParameters().put('id', acc.Id);

        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(acc);

        ANG_GenericHistoryViewerController histController = new ANG_GenericHistoryViewerController(sc);

        histController.trackerObjApiName = 'ANG_Account_Tracking_History__c';

        histController.trackedObjApiName = 'Account';

        histController.getHistoryRecords();

	}
	
}