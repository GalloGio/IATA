@isTest
private class AMS_Change_Code_Notification_Contr_Test {
	
	@isTest static void test_Oscar_notification() {

		Id conRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Id agcRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account msoAccount =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency', 
            Location_Class__c = 'M',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert msoAccount;

        Contact con = new Contact (
          AccountId = msoAccount.id,
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
        oscarCase.AccountId = msoAccount.Id;
        oscarCase.ContactId = con.Id; 
        oscarCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        oscarCase.OSCAR__c = oscar.Id;
        oscarCase.Status = 'Open';
        insert oscarCase;


        Agency_Applied_Change_code__c ccode= new Agency_Applied_Change_code__c();
        ccode.Change_Code__c = 'TER';
        ccode.OSCAR__c = oscar.Id;
        ccode.Account__c = msoAccount.Id;
		insert ccode;

        Test.startTest();

	        ApexPages.StandardController stdController = new ApexPages.StandardController(oscarCase);

	        AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

	        ctrl.setNotificationMessage();

        Test.stopTest();

	}



	@isTest static void test_Case_notification() {

		Id conRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Id agcRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Account msoAccount =  new Account (
            RecordTypeId = agcRtId,
            Name = 'Agency', 
            Location_Class__c = 'M',
            IATA_ISO_Country__c = isoc.Id,
            Status__c = 'Approved'
            );  
        insert msoAccount;

        Contact con = new Contact (
          AccountId = msoAccount.id,
          RecordTypeId = conRtId, 
          LastName = 'portalUser',
            FirstName = 'firstname',
            Phone = '123456789',
          User_Portal_Status__c = 'Approved User'
          );
        insert con;

        Case ccase = new Case();
        ccase.AccountId = msoAccount.Id;
        ccase.ContactId = con.Id; 
        ccase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        ccase.Status = 'Open';
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

	}



	@isTest static void test_Attachment_notification() {

		Id conRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        	Id agcRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;


		Account msoAccount =  new Account (
				RecordTypeId = agcRtId,
				Name = 'Agency',
				Location_Class__c = 'M',
				IATA_ISO_Country__c = isoc.Id,
				Status__c = 'Approved'
		);
		insert msoAccount;

		Contact con = new Contact (
				AccountId = msoAccount.id,
				RecordTypeId = conRtId,
				LastName = 'portalUser',
				FirstName = 'firstname',
				Phone = '123456789',
				User_Portal_Status__c = 'Approved User'
		);
		insert con;

		Id caseRecrdType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA').getRecordTypeId();

		Case ccase = new Case();
				ccase.AccountId = msoAccount.Id;
				ccase.ContactId = con.Id;
				ccase.RecordTypeId = caseRecrdType;
				ccase.Status = 'Open';
				ccase.Remittance_Period__c='20180615W';
        			
		insert ccase;

		RecordTypeInfo rtInfo = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByName().get('File');

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


		AmazonFile__c azFile = new AmazonFile__c(
				Name='ICE POP' + ' ' + '20180615W' + ' ' + '13737.04',
				RecordTypeId = rtInfo.getRecordTypeId(),
				Remittance_Period__c = '20180615W',
				Category__c = 'ICE POP',
				File_Identifier_picklist__c = 'ICE_POP',
				Account__c = msoAccount.Id,
				Full_Name_Unique__c = '500/'+msoAccount+'/ICE POP'
		);
		insert azFile;

		Test.startTest();

			ApexPages.StandardController stdController = new ApexPages.StandardController(ccase);

			AMS_Change_Code_Notification_Controller ctrl = new AMS_Change_Code_Notification_Controller(stdController);

			ctrl.setNotificationMessage();

		Test.stopTest();

	}


}