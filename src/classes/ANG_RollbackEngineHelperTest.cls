@isTest
private class ANG_RollbackEngineHelperTest {
	
	@testSetup static void setup(){
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account a1 = new Account(
			Is_PCI_compliant__c = 'Yes',
			ANG_HE_RiskStatus__c = 'B',
			ANG_HE_RiskHistoryAssessment__c = 'Passed',
			Remittance_frequency__c = 'Monthly',
			IATA_ISO_Country__c = ctry.id,
			RecordTypeId = accountAgencyRT,
			IATACode__c='1234561',
			Location_Type__c='HE',
			Name='Test1 Agency OK',
			Short_Name__c='Test1 Agency',
			Sector__c = 'Travel Agent',
			Location_Class__c = 'P',
			Category__c = 'IATA Passenger Sales Agent',
			Site = '123456',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

		insert a1;

        Account a2 = new Account(
			ParentId = a1.Id,
			Is_PCI_compliant__c = 'Yes',
			ANG_HE_RiskStatus__c = 'B',
			ANG_HE_RiskHistoryAssessment__c = 'Passed',
			Remittance_frequency__c = 'Monthly',
			IATA_ISO_Country__c = ctry.id,
			RecordTypeId = accountAgencyRT,
			IATACode__c='1234591',
			Location_Type__c='AE',
			Name='Test1 Agency OK',
			Short_Name__c='Test1 Agency',
			Sector__c = 'Travel Agent',
			Location_Class__c = 'P',
			Category__c = 'IATA Passenger Sales Agent',
			Site = '123459',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

        Account a3 = new Account(
			ParentId = a1.Id,
			Is_PCI_compliant__c = 'Yes',
			ANG_HE_RiskStatus__c = 'B',
			ANG_HE_RiskHistoryAssessment__c = 'Passed',
			Remittance_frequency__c = 'Monthly',
			IATA_ISO_Country__c = ctry.id,
			RecordTypeId = accountAgencyRT,
			IATACode__c='1264011',
			Location_Type__c='AE',
			Name='Test1 Agency OK',
			Short_Name__c='Test1 Agency',
			Sector__c = 'Travel Agent',
			Location_Class__c = 'P',
			Category__c = 'IATA Passenger Sales Agent',
			Site = '123401',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

		insert New List<Account>{a2,a3};

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
		insert hierarchy;

		AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);

		AMS_Agencies_relationhip__c rel2 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a3.Id);
		insert new List<AMS_Agencies_relationhip__c>{rel,rel2};

		Contact newContact1 = new Contact(
        FirstName = 'Joel',
        LastName = 'Chandler',
		AccountId = a1.Id
		);

		insert newContact1;

		Id ownerRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
        
        AMS_Account_Role__c role1 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = a1.Id, Person__c = null, Contact__c = newContact1.Id, Percentage__c=100.0);
        insert role1;

		Id	formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');
		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

        authorizations.add(new Agency_Authorization__c(Account__c = a1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        insert authorizations;

		Id oscarRT = AMS_Utils.getId('AMS_OSCAR__c', 'ANG_Agency_Changes');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = a1.id,
			recordTypeId = oscarRT			
		);

		insert oscar;


		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = newContact1.Id;
        insert oscarCase;

		ID rtChangesStagingId = Schema.SObjectType.AMS_Pax_Accreditation_Form__c.getRecordTypeInfosByName().get('New Gen Changes').getRecordTypeId();

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = a1.IATAcode__c,
                Branch_Office_Country__c = a1.IATA_ISO_Country__c,
                Location_Class__c = a1.Location_Class__c,
                Location_Type__c = a1.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
				Account_Name__c = a1.Name,
				ISSP_AMS_Legal_Status__c = 'Association',
				Short_Name__c = a1.Short_Name__c,
				TradeName__c = a1.Name,
				Trade_Name__c = a1.Name,
				Branch_Office_Email__c = a1.Email__c,
				Website__c = a1.Website,
				Abbreviated_name__c = a1.Abbreviated_name__c,
				VAT_Number_2__c = a1.VAT_Number__c,
				ANG_Accreditation_type__c = a1.ANG_Accreditation_Model__c,
				ISSP_AMS_License_No__c =  a1.License_Number__c
                );

			insert stagingArea;

			oscar.AMS_Online_Accreditation__c = stagingArea.Id;
			oscar.Process__c = AMS_Utils.NGCHANGES;

			update oscar;

	}
	@isTest static void RollbackTest0() {
		
		List<Account> accts = [Select Id, Name, Short_Name__c,TradeName__c,Abbreviated_name__c from Account ];

		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
		update oscar;

		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);

		beh.executeAdhoc();

		Test.startTest();

		List<Agency_Authorization__c> autorizations = [Select Id,Status__c from Agency_Authorization__c];

		for(Agency_Authorization__c aa: autorizations){
			aa.Status__c = 'Non-Active';
		}

		Id	formOfPaymentRT = AMS_Utils.getId('Agency_Authorization__c','FormOfPayment');

        Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = accts.get(0).Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT);

		autorizations.add(aa);

		upsert autorizations;

		For(Technical_Logs__c tlog : [Select Id,Log__c,Status__c,Record__c,Operation__c from Technical_Logs__c])
			System.System.debug(tlog);

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.executeAdhoc();

		Test.StopTest();

		autorizations = [Select Id,Status__c,ANG_FormOfPayment_ID__c from Agency_Authorization__c];

		System.assertEquals(1,autorizations.size());
		System.assertEquals('Active',autorizations.get(0).Status__c);
		System.assertEquals('CA',autorizations.get(0).ANG_FormOfPayment_ID__c);

	}

	@isTest static void RollbackTest1() {
		
		List<Account> accts = [Select Id, Name, Short_Name__c,TradeName__c,Abbreviated_name__c from Account ];

		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LEGAL_NAME + ';' + AMS_Utils.ANG_OWNERSHIP;
		update oscar;

		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);

		beh.executeAdhoc();

		for(Account acct: accts){
			
			System.assertEquals('Test1 Agency OK',acct.Name);
			System.assertEquals('Test1 Agency OK',acct.Short_Name__c);
			System.assertEquals('Test1 Agency OK',acct.TradeName__c);
			System.assertEquals(null,acct.Abbreviated_name__c);

			acct.Name = 'Test1 Agency OK CHANGED';
			acct.Short_Name__c = 'Test1 Agency OK CHANGED';
			acct.TradeName__c = 'Test1 Agency OK CHANGED TRADE NAME';
			acct.Abbreviated_name__c = 'Abreviated Name new value';

		}

		Test.startTest();

		Contact newContact = new Contact(
			FirstName = 'New Contact',
			LastName = 'Last Name',
			AccountId = accts.get(0).Id
		);

		insert newContact;

		Id ownerRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');

		AMS_Account_Role__c oldRole = [select Id, Percentage__c from AMS_Account_Role__c];
		oldRole.Percentage__c = 50.0;

        AMS_Account_Role__c role = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = accts.get(0).Id, Person__c = null, Contact__c = newContact.Id, Percentage__c=50.0);

        upsert new List<AMS_Account_Role__c>{oldRole,role};

		update accts;

		For(Technical_Logs__c tlog : [Select Id,Log__c,Status__c,Record__c,Operation__c from Technical_Logs__c])
			System.System.debug(tlog);

		accts = [Select Id, Name, Short_Name__c,TradeName__c, Abbreviated_name__c from Account ];

		for(Account acct: accts){

			System.assertEquals('Test1 Agency OK CHANGED',acct.Name);
			System.assertEquals('Test1 Agency OK CHANGED TRADE NAME',acct.Short_Name__c);
			System.assertEquals('Test1 Agency OK CHANGED TRADE NAME',acct.TradeName__c);
			System.assertEquals('Abreviated Name new value',acct.Abbreviated_name__c);
		
		}


		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.executeAdhoc();

		Test.StopTest();

		accts = [Select Id, Name, Short_Name__c,TradeName__c,Abbreviated_name__c from Account ];

		for(Account acct: accts){
			
			System.assertEquals('Test1 Agency OK',acct.Name);
			System.assertEquals('Test1 Agency OK',acct.Short_Name__c);
			System.assertEquals('Test1 Agency OK',acct.TradeName__c);
			System.assertEquals(null,acct.Abbreviated_name__c);

		}

		List<Contact> contacts = [Select Id, FirstName, LastName from Contact];

		System.assertEquals(1,contacts.size());

		System.assertNotEquals(contacts.get(0).Id, newContact.Id);

		List<AMS_Account_Role__c> roles = [Select Id, Percentage__c from AMS_Account_Role__c];

		System.assertEquals(1,roles.size());

		System.assertEquals(roles.get(0).Id, oldRole.Id);
		System.assertEquals(100.0 , roles.get(0).Percentage__c);

	}
	
	@isTest static void RollbackTest2() {
		
		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		update oscar;

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Test.startTest();

        Account a1 = new Account(
			Is_PCI_compliant__c = 'Yes',
			ANG_HE_RiskStatus__c = 'B',
			ANG_HE_RiskHistoryAssessment__c = 'Passed',
			Remittance_frequency__c = 'Monthly',
			IATA_ISO_Country__c = ctry.id,
			RecordTypeId = accountAgencyRT,
			IATACode__c='1234001',
			Location_Type__c='HE',
			Name='Test1 Agency OK NEW BIG BOSS',
			Short_Name__c='Test1 Agency',
			Sector__c = 'Travel Agent',
			Location_Class__c = 'P',
			Category__c = 'IATA Passenger Sales Agent',
			Site = '123400',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

		insert a1;

        Account a2 = new Account(
			ParentId = a1.Id,
			Is_PCI_compliant__c = 'Yes',
			ANG_HE_RiskStatus__c = 'B',
			ANG_HE_RiskHistoryAssessment__c = 'Passed',
			Remittance_frequency__c = 'Monthly',
			IATA_ISO_Country__c = ctry.id,
			RecordTypeId = accountAgencyRT,
			IATACode__c='1234011',
			Location_Type__c='AE',
			Name='Test1 Agency OK',
			Short_Name__c='Test1 Agency',
			Sector__c = 'Travel Agent',
			Location_Class__c = 'P',
			Category__c = 'IATA Passenger Sales Agent',
			Site = '123401',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

		insert a2;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy2');
		insert hierarchy;

		AMS_Agencies_relationhip__c relsToInsert = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Hierarchy__c = hierarchy.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id);
		insert relsToInsert;

		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);
		beh.setNewParentHierarchyId(a1.Id);
		
		beh.executeAdhoc();

		Account setupAccountAE = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1234591'];

		Account setupAccountAE3 = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1264011'];

		delete [Select Id From AMS_Agencies_relationhip__c where Id <> :relsToInsert.Id and Child_Account__c <> :setupAccountAE3.Id];

		setupAccountAE.ParentId = a1.Id;
		setupAccountAE.Top_Parent__c = a1.Id;

		update setupAccountAE;

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = a1.Id, Child_Account__c = setupAccountAE.Id, Hierarchy__c = hierarchy.Id);

		List<AMS_Agencies_relationhip__c> relationsAfterChange = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterChange are:'+relationsAfterChange);

		System.assertEquals(3,relationsAfterChange.size());

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.setNewParentHierarchyId(a1.Id);

		reh.executeAdhoc();

		Test.StopTest();

		List<AMS_Agencies_relationhip__c> relationsAfterRollback = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterRollback are:'+relationsAfterRollback);

		System.assertEquals(3,relationsAfterRollback.size());

		System.debug('Accounts are:' + [Select Id, Location_Type__c, IATAcode__c, ParentId, Top_Parent__c, Name from Account]);
	
	}

	@isTest static void RollbackTest3() {
		
		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		update oscar;

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

		Test.startTest();

		Account setupAccountAE = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1234591'];
		Account setupAccountAE2 = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1264011'];

		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);
		beh.setNewParentHierarchyId(setupAccountAE.Id);
		
		beh.executeAdhoc();

		delete [Select Id From AMS_Agencies_relationhip__c];

		delete [Select Id From AMS_Agencies_Hierarchy__c];

		setupAccountAE.ParentId = null;
		setupAccountAE.Top_Parent__c = null;
		setupAccountAE.Location_Type__c = 'HE';

		setupAccountAE2.ParentId = setupAccountAE.Id;
		setupAccountAE2.Top_Parent__c = setupAccountAE.Id;	
		
		update new List<Account>{setupAccountAE};

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy2');
		insert hierarchy;

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = setupAccountAE.Id, Child_Account__c = setupAccountAE2.Id, Hierarchy__c = hierarchy.Id);

		List<AMS_Agencies_relationhip__c> relationsAfterChange = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterChange are:'+relationsAfterChange);

		for(AMS_Agencies_relationhip__c rel: relationsAfterChange){
			System.assertEquals(setupAccountAE.Id,rel.Parent_Account__c);
			System.assertEquals(hierarchy.Id,rel.Hierarchy__c);
		}

		System.assertEquals(1,relationsAfterChange.size());

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.setNewParentHierarchyId(setupAccountAE.Id);

		reh.executeAdhoc();

		Test.StopTest();

		List<AMS_Agencies_relationhip__c> relationsAfterRollback = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterRollback are:'+relationsAfterRollback);

		System.assertEquals(2,relationsAfterRollback.size());

		System.debug('Accounts are:' + [Select Id, Location_Type__c, IATAcode__c, ParentId, Top_Parent__c, Name from Account]);
	
	}
	
}