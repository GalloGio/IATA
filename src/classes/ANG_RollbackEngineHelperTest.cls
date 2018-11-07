@isTest
private class ANG_RollbackEngineHelperTest {
	
	private static void setupData(Boolean useAEAccount){
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

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

		Id ownerRtId = AMS_Utils.AccountRoleOwnershipRT;
        
        AMS_Account_Role__c role1 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = a1.Id, Person__c = null, Contact__c = newContact1.Id, Percentage__c=100.0);
        insert role1;

		Id	formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');
		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

        authorizations.add(new Agency_Authorization__c(Account__c = a1.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        insert authorizations;

		Id oscarRT = AMS_Utils.RECTYPE_NGCHANGES;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = useAEAccount ? a2.id : a1.id,
			recordTypeId = oscarRT			
		);

		insert oscar;


		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = useAEAccount ? a2.id : a1.id;
        oscarCase.ContactId = newContact1.Id;
        insert oscarCase;

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		Account accountToUse = useAEAccount ? a2 : a1;

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = accountToUse.IATAcode__c,
                Branch_Office_Country__c = accountToUse.IATA_ISO_Country__c,
                Location_Class__c = accountToUse.Location_Class__c,
                Location_Type__c = accountToUse.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
				Account_Name__c = accountToUse.Name,
				ISSP_AMS_Legal_Status__c = 'Association',
				Short_Name__c = accountToUse.Short_Name__c,
				TradeName__c = accountToUse.Name,
				Trade_Name__c = accountToUse.Name,
				Branch_Office_Email__c = accountToUse.Email__c,
				Website__c = accountToUse.Website,
				Abbreviated_name__c = accountToUse.Abbreviated_name__c,
				VAT_Number_2__c = accountToUse.VAT_Number__c,
				ANG_Accreditation_type__c = accountToUse.ANG_Accreditation_Model__c,
				ISSP_AMS_License_No__c =  accountToUse.License_Number__c
                );

			insert stagingArea;

			oscar.AMS_Online_Accreditation__c = stagingArea.Id;
			oscar.Process__c = AMS_Utils.NGCHANGES;

			update oscar;

	}
	@isTest static void RollbackTest0() {

		Test.startTest();

		setupData(false);

		List<Account> accts = [Select Id, Name, Short_Name__c,TradeName__c,Abbreviated_name__c from Account ];

		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_ACCREDITATION_TYPE;
		update oscar;

/*
		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);

		beh.executeAdhoc();
*/
		Test.StopTest();

		List<Agency_Authorization__c> autorizations = [Select Id,Status__c from Agency_Authorization__c];

		for(Agency_Authorization__c aa: autorizations){
			aa.Status__c = 'Non-Active';
		}

		Id	formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'FormOfPayment');

        Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = accts.get(0).Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT);

		autorizations.add(aa);

		upsert autorizations;

		For(Technical_Logs__c tlog : [Select Id,Log__c,Status__c,Record__c,Operation__c from Technical_Logs__c])
			System.System.debug(tlog);

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.executeAdhoc();


		autorizations = [Select Id,Status__c,ANG_FormOfPayment_ID__c from Agency_Authorization__c];

		System.assertEquals(1,autorizations.size());
		System.assertEquals('Active',autorizations.get(0).Status__c);
		System.assertEquals('CA',autorizations.get(0).ANG_FormOfPayment_ID__c);

	}

	@isTest static void RollbackTest1() {
		
		Test.startTest();

		setupData(false);

		List<Account> accts = [Select Id, Name, Short_Name__c,TradeName__c,Abbreviated_name__c from Account ];

		Case c = [Select Id from Case LIMIT 1];

		AMS_OSCAR__c oscar = [Select Id, Account__c from AMS_OSCAR__c];

		List<AMS_Process_Detail__c> pdLst = new List<AMS_Process_Detail__c>();

		for(Account acct: accts){
			if(acct.Id != oscar.Account__c)
				pdLst.add(new AMS_Process_Detail__c(Account__c = acct.Id, Case__c = c.Id,OSCAR__c =oscar.Id )) ;
		}

		insert pdLst;

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_LEGAL_NAME + ';' + AMS_Utils.ANG_OWNERSHIP;
		update oscar;

		Test.StopTest();

/*
		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);

		beh.executeAdhoc();
*/
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

		//Test.startTest();

		Contact newContact = new Contact(
			FirstName = 'New Contact',
			LastName = 'Last Name',
			AccountId = accts.get(0).Id
		);

		insert newContact;

		Id ownerRtId = AMS_Utils.AccountRoleOwnershipRT;

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
		
		Test.startTest();

		setupData(false);

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

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

/*
		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);
		beh.setNewParentHierarchyId(a1.Id);
		
		beh.executeAdhoc();
*/

		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		oscar.New_parent__c = a1.Id;

		update oscar;
		
		Account setupAccountAE = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1234591'];

		Account setupAccountAE3 = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1264011'];

		Test.StopTest();

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

		List<AMS_Agencies_relationhip__c> relationsAfterRollback = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterRollback are:'+relationsAfterRollback);

		System.assertEquals(3,relationsAfterRollback.size());

		System.debug('Accounts are:' + [Select Id, Location_Type__c, IATAcode__c, ParentId, Top_Parent__c, Name from Account]);
	
	}

	@isTest static void RollbackTest3() {
		
		Test.startTest();

		setupData(false);

		Account setupAccountAE = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1234591'];
		Account setupAccountAE2 = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1264011'];

		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		oscar.New_parent__c = setupAccountAE.Id;
		update oscar;

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

		Test.StopTest();
/*
		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);
		beh.setNewParentHierarchyId(setupAccountAE.Id);
		
		beh.executeAdhoc();
*/

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

		//Test.StopTest();

		List<AMS_Agencies_relationhip__c> relationsAfterRollback = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterRollback are:'+relationsAfterRollback);

		System.assertEquals(2,relationsAfterRollback.size());

		System.debug('Accounts are:' + [Select Id, Location_Type__c, IATAcode__c, ParentId, Top_Parent__c, Name from Account]);
	
	}

	@isTest static void RollbackTest4() {
		
		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

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
			Site = '893451',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

        Account a2 = new Account(
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
			Site = '843251',
			Status__c = 'Approved',
			ANG_Accreditation_Model__c = 'Cash',
			Company_Type__c = 'A',
			Email__c='ltg23@fefff2.com',
			Website = 'wwww.asdasidsss12233.pt',
			VAT_Number__c = '111222333',
			License_Number__c = '111222333',
			TradeName__c = 'Test1 Agency OK'
			);

		insert new List<Account>{a1,a2};

		Contact newContact1 = new Contact(
        FirstName = 'Joel',
        LastName = 'Chandler',
		AccountId = a1.Id
		);

		insert newContact1;

		Id oscarRT = AMS_Utils.RECTYPE_NGCHANGES;


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

		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

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


		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		oscar.Account__c = a1.Id;
		oscar.New_parent__c = a2.id; 
		update oscar;
/*
		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);
		beh.setNewParentHierarchyId(a2.Id);
		
		System.debug('Starting ANG_BackupEngineHelper executing adhoc.');
		beh.executeAdhoc();
		System.debug('Done ANG_BackupEngineHelper executing adhoc.');
*/



		Test.StopTest();

		a1.ParentId = a2.Id;
		a1.Top_Parent__c = a2.Id;
		a1.Location_Type__c = 'AE';

		update a1;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy2');
		insert hierarchy;

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = a2.Id, Child_Account__c = a1.Id, Hierarchy__c = hierarchy.Id);

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.setNewParentHierarchyId(a2.Id);

		reh.executeAdhoc();

		System.debug('Relations are:' + [Select Id,Parent_Account__c,Child_Account__c,Hierarchy__c from AMS_Agencies_relationhip__c]);
		System.debug('Hierarchies are:' + [Select Id from AMS_Agencies_Hierarchy__c]);
		System.debug('Accounts are:' + [Select Id,ParentId,Location_Type__c,Name,IATAcode__c,Top_Parent__c from Account]);
		System.debug('Technical_Logs__c are:' + [select Id, Log__c, Status__c, Record__c, Operation__c FROM Technical_Logs__c WHERE Record__c =:oscar.Id AND Operation__c = 'Rollback']);
	}
	
	@isTest static void RollbackTest5() {
		
		Test.startTest();

		setupData(true);

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

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

		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		oscar.New_parent__c = a1.Id;

		update oscar;
		
		Account setupAccountAE = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1234591'];

		Test.StopTest();

		delete [Select Id From AMS_Agencies_relationhip__c where Child_Account__c =:setupAccountAE.Id];

		setupAccountAE.ParentId = a1.Id;
		setupAccountAE.Top_Parent__c = a1.Id;

		update setupAccountAE;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy2');
		insert hierarchy;

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = a1.Id, Child_Account__c = setupAccountAE.Id, Hierarchy__c = hierarchy.Id);

		List<AMS_Agencies_relationhip__c> relationsAfterChange = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		List<AMS_Agencies_Hierarchy__c> hierarchiesAfterChange = [Select Id from AMS_Agencies_Hierarchy__c];


		System.debug('relationsAfterChange are:'+relationsAfterChange);
		System.debug('hierarchiesAfterChange are:'+hierarchiesAfterChange);

		System.assertEquals(2,relationsAfterChange.size());
		System.assertEquals(2,hierarchiesAfterChange.size());

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.setNewParentHierarchyId(a1.Id);

		reh.executeAdhoc();

		List<AMS_Agencies_relationhip__c> relationsAfterRollback = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterRollback are:'+relationsAfterRollback);

		System.assertEquals(2,relationsAfterRollback.size());

		System.debug('Accounts are:' + [Select Id, Location_Type__c, IATAcode__c, ParentId, Top_Parent__c, Name from Account]);

		hierarchiesAfterChange = [Select Id from AMS_Agencies_Hierarchy__c];
		System.debug('hierarchiesAfterChange are:'+hierarchiesAfterChange);

		System.assertEquals(1,hierarchiesAfterChange.size());


	}

	@isTest static void RollbackTest6() {
		
		Test.startTest();

		setupData(true);

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c];

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

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
			TradeName__c = 'Test1 Agency OK',
			ParentId = a1.Id,
			Top_Parent__c = a1.Id
			);

		insert a2;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy2');
		insert hierarchy;

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = a1.Id, Child_Account__c = a2.Id, Hierarchy__c = hierarchy.Id);


		AMS_OSCAR__c oscar = [Select Id from AMS_OSCAR__c];

		oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
		oscar.New_parent__c = a1.Id;

		update oscar;
		
		Account setupAccountAE = [Select Id, ParentId, Location_Type__c,Top_Parent__c from Account where location_Type__c = 'AE' and IATAcode__c = '1234591'];

		Test.StopTest();

		delete [Select Id From AMS_Agencies_relationhip__c where Child_Account__c =:setupAccountAE.Id];

		setupAccountAE.ParentId = a1.Id;
		setupAccountAE.Top_Parent__c = a1.Id;

		update setupAccountAE;

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = a1.Id, Child_Account__c = setupAccountAE.Id, Hierarchy__c = hierarchy.Id);

		List<AMS_Agencies_relationhip__c> relationsAfterChange = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		List<AMS_Agencies_Hierarchy__c> hierarchiesAfterChange = [Select Id from AMS_Agencies_Hierarchy__c];


		System.debug('relationsAfterChange are:'+relationsAfterChange);
		System.debug('hierarchiesAfterChange are:'+hierarchiesAfterChange);

		System.assertEquals(3,relationsAfterChange.size());
		System.assertEquals(2,hierarchiesAfterChange.size());

		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.setNewParentHierarchyId(a1.Id);

		reh.executeAdhoc();

		List<AMS_Agencies_relationhip__c> relationsAfterRollback = [Select Id, Child_Account__c, Child_Account__r.IATACode__c, Child_Account__r.ParentId, Parent_Account__c,Parent_Account__r.IATAcode__c,Parent_Account__r.ParentId, Hierarchy__c from AMS_Agencies_relationhip__c];

		System.debug('relationsAfterRollback are:'+relationsAfterRollback);

		System.assertEquals(3,relationsAfterRollback.size());

		System.debug('Accounts are:' + [Select Id, Location_Type__c, IATAcode__c, ParentId, Top_Parent__c, Name from Account]);

		hierarchiesAfterChange = [Select Id from AMS_Agencies_Hierarchy__c];
		System.debug('hierarchiesAfterChange are:'+hierarchiesAfterChange);

		System.assertEquals(2,hierarchiesAfterChange.size());


	}

	@isTest static void RollbackTest7() {

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US',ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.RECTYPE_IATAAGENCY;

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

		Contact newContact1 = new Contact(
        FirstName = 'Joel',
        LastName = 'Chandler',
		AccountId = a1.Id,
		Financial_Assessment_Contact__c = true
		);

		insert newContact1;

		Id ownerRtId = AMS_Utils.AccountRoleOwnershipRT;
        
        AMS_Account_Role__c role1 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = a1.Id, Person__c = null, Contact__c = newContact1.Id, Percentage__c=100.0);
        insert role1;

		Id oscarRT = AMS_Utils.RECTYPE_NGCHANGES;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			Account__c = a1.id,
			recordTypeId = oscarRT			
		);

		insert oscar;

		String OSCAR_RECORD_TYPE_ID = Schema.SObjectType.Case.RecordTypeInfosByName.get('OSCAR Communication').RecordTypeId;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = OSCAR_RECORD_TYPE_ID);
        oscarCase.AccountId = a1.id;
        oscarCase.ContactId = newContact1.Id;
        insert oscarCase;

        Financial_Institution__c FI = new Financial_Institution__c(Name = 'FI1', INSTITUTION_TYPE__C='Bank');
        insert FI;

        Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='Bank Guarantee', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=oscarCase.Id);
        insert FS;

        ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
            ANG_AccountId__c =a1.id,
            CurrencyIsoCode ='EUR',
            RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
            ANG_Financial_Security__c=0
        );
        
        insert rhcInfo;

        ANG_Agency_Risk_Calculation__c rule = new ANG_Agency_Risk_Calculation__c(
        	ANG_Order__c = 1, 
        	ANG_Occurrence_Num__c = 1, 
        	ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO, 
        	ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH, 
        	RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES);

        ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
	            Name = 'Risk Event Test',
	            ANG_Description__c = 'Risk Event Test',
	            ANG_Expiration__c = 24,
	            ANG_Risk_ID__c = 'testRiskId',
	            ANG_Agency_Risk_Calculation__c = rule.Id,
	            Limit_Cash_conditions__c = false
        	);

        insert ret;

        ANG_Agency_Risk_Event__c re1 = new ANG_Agency_Risk_Event__c(
	            ANG_AccountId__c = a1.id,
	            ANG_Risk_Type__c = ret.id,
	            ANG_Issued_Date__c = System.today(),
	            ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE
        	);

        insert re1;	


		ID rtChangesStagingId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes');

		Test.StopTest();
		
		Account accountToUse = a1;

                 // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c stagingArea = new  AMS_Pax_Accreditation_Form__c(
        		RecordTypeId = rtChangesStagingId,
                IATAcode__c = accountToUse.IATAcode__c,
                Branch_Office_Country__c = accountToUse.IATA_ISO_Country__c,
                Location_Class__c = accountToUse.Location_Class__c,
                Location_Type__c = accountToUse.Location_Type__c,
                SAAM_Case__c = oscarCase.Id,
				Account_Name__c = accountToUse.Name,
				ISSP_AMS_Legal_Status__c = 'Association',
				Short_Name__c = accountToUse.Short_Name__c,
				TradeName__c = accountToUse.Name,
				Trade_Name__c = accountToUse.Name,
				Branch_Office_Email__c = accountToUse.Email__c,
				Website__c = accountToUse.Website,
				Abbreviated_name__c = accountToUse.Abbreviated_name__c,
				VAT_Number_2__c = accountToUse.VAT_Number__c,
				ANG_Accreditation_type__c = accountToUse.ANG_Accreditation_Model__c,
				ISSP_AMS_License_No__c =  accountToUse.License_Number__c
                );

			insert stagingArea;

			oscar.AMS_Online_Accreditation__c = stagingArea.Id;
			oscar.Process__c = AMS_Utils.NGCHANGES;

			update oscar;

			oscar.ANG_Type_Of_Change__c = AMS_Utils.ANG_HIERARCHY;
			update oscar;

/*
		ANG_BackupEngineHelper beh = new ANG_BackupEngineHelper(oscar.Id);

		beh.executeAdhoc();
*/
		

        Account a2 = new Account(
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
			Site = '123457',
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

		insert new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true,Parent_Account__c = a2.Id, Child_Account__c = a1.Id, Hierarchy__c = hierarchy.Id);

		a1.ParentId = a2.Id;
		a1.Top_Parent__c = a2.Id;

		update a1;

		For(Technical_Logs__c tlog : [Select Id,Log__c,Status__c,Record__c,Operation__c from Technical_Logs__c])
			System.System.debug(tlog);
		/*
		ANG_RollbackEngineHelper reh = new ANG_RollbackEngineHelper(oscar.Id);
		reh.executeAdhoc();

		System.assertEquals(true,[Select Id from AMS_Agencies_relationhip__c].size() == 0);
		System.assertEquals(true,[Select Id from AMS_Agencies_Hierarchy__c].size() == 0);
		*/

	}
}