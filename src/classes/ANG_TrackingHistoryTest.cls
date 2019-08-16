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
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
		acc.VAT_Number_2__c = '666';
		acc.Abbreviated_address__c = 'Lisbon';
		acc.Legal_Name__c = 'Winterfell';
		insert acc;

		AccountHistory standardAccountHist = new AccountHistory(AccountId=acc.Id, Field='Type');
		Insert standardAccountHist;

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


	@isTest static void testCaseChange() {

		Account acc = [SELECT Id FROM Account];

		Account acc2 = ISSP_ObjectFactory.createNewAccount();
		insert acc2;

		Contact con = ISSP_ObjectFactory.createNewContact();

		Case c0 = new Case();
		insert c0;

		Case c1 = new Case();
		insert c1;

		Case c2 = new Case();
		c2.ParentId = c0.Id;
		insert c2;

		/*c2.AccountId = acc.Id;
		c2.ContactId = con.Id;
		c2.OwnerId = UserInfo.getUserId();*/
		c2.ParentId = c1.Id;
		//c2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE');
		update c2;

		List<CaseHistory> standardCaseHistList = new List<CaseHistory>{new CaseHistory(CaseId=c2.Id, Field='Account'),
																		new CaseHistory(CaseId=c2.Id, Field='Owner'),
																		new CaseHistory(CaseId=c2.Id, Field='Contact'),
																		new CaseHistory(CaseId=c2.Id, Field='RecordType')};
		insert standardCaseHistList;

		
		PageReference pageRef = Page.CaseTrackingHistory;
        pageRef.getParameters().put('id', c2.Id);
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.standardController(c2);

        ANG_GenericHistoryViewerController histController = new ANG_GenericHistoryViewerController(sc);
        //histController.trackedObjId = c2.Id;
        histController.trackerObjApiName = 'ANG_Case_Tracking_History__c';
        histController.trackedObjApiName = 'Case';
        histController.getHistoryRecords();
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