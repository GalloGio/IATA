@isTest
private class AMS_Change_Code_Notification_Contr_Test {

	@TestSetup
	static void makeData(){

		Id conRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Id agcRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id airRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;

		Account airlineAccount = new Account(
			RecordTypeId = airRtId,
			Name = 'Airline',
			IATACode__c = '123',
			Airline_designator__c='AA',
			IATA_ISO_Country__c = isoc.Id
		);

		Account msoAccount =  new Account (
			RecordTypeId = agcRtId,
			Name = 'Agency',
			Location_Class__c = 'N',
			IATA_ISO_Country__c = isoc.Id,
			Status__c = 'Approved'
		);

		insert new List<Account> {airlineAccount, msoAccount};


		Contact con = new Contact (
			AccountId = airlineAccount.id,
			RecordTypeId = conRtId,
			LastName = 'portalUser',
			FirstName = 'firstname',
			Phone = '123456789',
			User_Portal_Status__c = 'Approved User'
			);
		insert con;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c();
			oscar.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'VOLUNTARY_RELINQUISHMENT');
			oscar.Name = 'tempName'; 
			oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
			oscar.Account__c = msoAccount.Id;
		insert oscar;

		Case oscarCase = new Case();
			oscarCase.AccountId = airlineAccount.Id;
			oscarCase.ContactId = con.Id;
			oscarCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
			oscarCase.OSCAR__c = oscar.Id;
			oscarCase.Status = 'Open';
			oscarCase.Account_Concerned__c = msoAccount.Id;
		insert oscarCase;

		Case ccase = new Case();
			ccase.AccountId = airlineAccount.Id;
			ccase.ContactId = con.Id;
			ccase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
			ccase.Status = 'Open';
			ccase.Late_Payment_Date__c = Date.today();
			ccase.Account_Concerned__c = msoAccount.Id;
		insert ccase;

		Agency_Applied_Change_code__c ccode= new Agency_Applied_Change_code__c();
		ccode.Change_Code__c = 'TER';
		ccode.SIDRA_Case__c = ccase.Id;
		ccode.Account__c = msoAccount.Id;
		insert ccode;

		Test.startTest();

			ApexPages.StandardController stdController = new ApexPages.StandardController(ccase);

			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

			ctrl.setNotificationMessage();

		Test.stopTest();

		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred;
		Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred2;

		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
				new AWSKey__c(
						name = 'adevconf',
						Key__c = 'asd',
						Secret__c = 'asd',
						IAS_configuration_name__c = 'asdas',
						IAS_Access_Point__c = 'asd',
						Bucket__c = 'asd',
						AWS_ENDPOINT_URL__c = 'asd')
				};
		insert AWS_KEYs;

		Account_Statement__c acctS = new Account_Statement__c(
				Period__c ='20180604W',
				Operation__c='SA_BSP_Y_SAR_I',
				Name ='12712054620180604WSA_BSP_Y_SAR_I',
				Account__c = msoAccount.Id,
				Amount_to_be_Paid__c = 13737.04,
				Balance__c= 13737.04,
				Billing_Amount__c = 13737.04,
				Paid__c = 0,
				Remittance_Date__c = Date.newInstance(2018, 7, 15),
				Key__c = '12712054620180604WSA_BSP_Y_SAR_I'
		);
		insert acctS;

		Account_Statement__c acctS1 = new Account_Statement__c(
				Period__c ='20180604W',
				Operation__c='SA_BSP_Y_SAR_I',
				Name ='test_random',
				Account__c = airlineAccount.Id,
				Amount_to_be_Paid__c = 13737.04,
				Balance__c= 13737.04,
				Billing_Amount__c = 13737.04,
				Paid__c = 0,
				Remittance_Date__c = Date.newInstance(2018, 7, 15),
				Key__c = 'test_random'
		);
		insert acctS1;

		AmazonFile__c azFile = new AmazonFile__c(
				Name='ICE POP' + ' ' + '20180604W' + ' ' + '13737.040',
				RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AmazonFile__c', 'File'),
				Remittance_Period__c = '20180604W',
				Category__c = 'ICE POP',
				File_Identifier_picklist__c = 'ICE_POP',
				Account__c = msoAccount.Id,
				Full_Name_Unique__c = '500/'+msoAccount+'/ICE POP'
		);
		insert azFile;


	}


	@isTest static void test_Oscar_notification() {
		
		IATA_ISO_Country__c isoc = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
	
		Case oscarCase = [SELECT Id FROM Case WHERE Remittance_Period__c = null LIMIT 1];

		Test.startTest();

			ApexPages.StandardController stdController = new ApexPages.StandardController(oscarCase);
			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);
			ctrl.setNotificationMessage();
		
		Test.stopTest();

	}

	@isTest static void test_Case_notification() {
	
		IATA_ISO_Country__c isoc = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];
	
		Case ccase = [SELECT Id FROM Case LIMIT 1];
		
		Test.startTest();

			ApexPages.StandardController stdController = new ApexPages.StandardController(ccase);
			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);
			ctrl.setNotificationMessage();
		
		Test.stopTest();

	}

	@isTest static void test_Attachment_notification() {
	
		Case ccase = [SELECT Id, AccountId, Account_Concerned__c FROM Case WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA') LIMIT 1];
		ccase.AccountId = ccase.Account_Concerned__c;
		ccase.Remittance_Period__c = '20180604W';
		update ccase;

		Technical_Logs__c notif1 = new Technical_Logs__c();
		notif1.Record__c = ccase.Id;
		notif1.Log__c = 'some notification';
		Technical_Logs__c notif2 = new Technical_Logs__c();
		notif2.Record__c = ccase.Id;
		notif2.Log__c = 'NOT';
		insert new List<Technical_Logs__c> { notif1, notif2 };

		Test.startTest();
			ApexPages.StandardController stdController = new ApexPages.StandardController(ccase);

			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

			ctrl.setNotificationMessage();
			
		Test.stopTest();

	}

	@isTest static void test_Amazon_File() {
	  
		Account  airlineAccount  = [SELECT Id FROM Account WHERE Name = 'Airline' LIMIT 1];
		Account  msoAccount  = [SELECT Id FROM Account WHERE Name = 'Agency' LIMIT 1];
		Contact con  = [SELECT Id FROM Contact LIMIT 1];
		
		Case ccase2 = new Case();
			ccase2.AccountId = airlineAccount.Id;
			ccase2.ContactId = con.Id;
			ccase2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
			ccase2.Status = 'Open';
			ccase2.Remittance_Period__c='20180604W';
			ccase2.Late_Payment_Date__c = Date.today();  
			ccase2.Account_Concerned__c = airlineAccount.Id;
		insert ccase2;
		
		AmazonFile__c  amazonFile = new AmazonFile__c();
			amazonFile.Name = 'ICE POP 20180604W 13737.040';
			amazonFile.Account__c = ccase2.AccountId;
			amazonFile.Full_Name_Unique__c = 'cristianaFabio_test';
		insert amazonFile;
			
		Test.startTest();
					
			ApexPages.StandardController stdController = new ApexPages.StandardController(ccase2);

			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

			ctrl.setNotificationMessage();
			
		Test.stopTest();
	}

	
	@isTest static void test_Check_Logs() {
		
		Case ccase2 = [SELECT Id,Remittance_Period__c, AccountId  FROM Case LIMIT 1];
		ccase2.Remittance_Period__c = '20180604W';
	 	update ccase2;
 
		Technical_Logs__c techLog = new Technical_Logs__c();
		techLog.Record__c = ccase2.Id;
		techLog.Log__c = 'Error for test';
		insert techLog;
		
		Test.startTest();
			
			ApexPages.StandardController stdController = new ApexPages.StandardController(ccase2);

			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

			ctrl.setNotificationMessage();

		Test.stopTest();
		
		List<Apexpages.Message> messages = ApexPages.getMessages();

		boolean b = false;

		for(Apexpages.Message msg:messages){
			if (msg.getDetail().contains('not generated, please issue Notice of Termination')) b = true;
		}

		System.assert(b);


	}

	
	@isTest
	public static void test_Case_multicountry()
	{
		Case ccase = [SELECT Id, AccountId, Account_Concerned__c FROM Case WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('Case','SIDRA') LIMIT 1];
		
		Account acc1 = [SELECT Id, ANG_Accreditation_Model__c FROM Account WHERE Id =: ccase.AccountId LIMIT 1];
		acc1.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		update acc1;
		
		Agency_Applied_Change_code__c ccode = new Agency_Applied_Change_code__c();
		ccode.Change_Code__c = 'TER';
		ccode.SIDRA_Case__c = ccase.Id;
		ccode.Account__c = ccase.Account_Concerned__c;
		insert ccode;

		Test.startTest();

		ApexPages.StandardController stdController = new ApexPages.StandardController(ccase);

		AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

		ctrl.setNotificationMessage();

		Test.stopTest();
	}
}
