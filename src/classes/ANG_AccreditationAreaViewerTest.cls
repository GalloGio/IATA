@isTest
private class ANG_AccreditationAreaViewerTest {

	@testSetup static void setup(){
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', Region__c = 'Europe', ANG_Enable_NewGen__c = true);
		insert ctry ;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = 'HE';
		account.ANG_Accreditation_Model__c = 'Cashless';
		account.IATA_ISO_Country__c = ctry.Id;
		account.ANG_IEP_HE_AccntNum__c = '1232132323';
		account.ANG_IEP_Status__c = 'Suspended' ;
		account.ANG_HE_CashCondition__c = true;
		account.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		account.ANG_HE_RiskStatus__c = 'Not Applicable';
		account.RecordTypeId = accountAgencyRT;
		account.Status__c = 'Approved';
       	account.Accreditation_date__c = system.today().addMonths(-9); 
       
		insert account;

		Contact co1 = new Contact(AccountId = account.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = true);
		insert co1;

		List<Account> accountList = new List<Account>();
		Account a1 = new Account(Status__c = 'Approved', Accreditation_date__c = system.today().addMonths(-9), IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' ,RecordTypeId = accountAgencyRT, IATACode__c='12345671',Name='Account AE1 H1',Short_Name__c='Account AE1 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		Account a2 = new Account(Status__c = 'Approved', Accreditation_date__c = system.today().addMonths(-9), IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12345672',Name='Account AE2 H1',Short_Name__c='Account AE2 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);
		Account a3 = new Account(Status__c = 'Approved', Accreditation_date__c = system.today().addMonths(-9), IATA_ISO_Country__c = ctry.id, ANG_IEP_Status__c = null, ANG_Accreditation_Model__c = 'Cashless' , RecordTypeId = accountAgencyRT, IATACode__c='12345673',Name='Account AE3 H1',Short_Name__c='Account AE3 H1',Category__c = 'IATA Passenger Sales Agent',Location_Class__c = 'P',Location_Type__c = 'AE', ParentId = account.Id);

		accountList.add(a1);
		accountList.add(a2);
		accountList.add(a3);

		insert accountList;

		AMS_Agencies_Hierarchy__c h = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy (old)');
		insert h;

		AMS_Agencies_relationhip__c r1 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a1.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);
		AMS_Agencies_relationhip__c r2 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a2.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);
		AMS_Agencies_relationhip__c r3 = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = a3.Id , Parent_Account__c = account.Id, Hierarchy__c = h.Id);

		insert new List<AMS_Agencies_relationhip__c>{r1,r2,r3};

		Portal_Applications__c pa = new Portal_Applications__c(name = 'Risk Profile and RHC');
		insert pa;

		List<ANG_AgencyChangesConfig__c> customsettings = new List<ANG_AgencyChangesConfig__c>();
		customsettings.add(new ANG_AgencyChangesConfig__c(Name = 'ChangeName', TC_Location_type__c = false,
							 TC_Legal_status__c = false, TC_Location__c = false,
							 TC_Minor_Shareholding__c = false, TC_Legal_Name__c = true, TC_Ownership__c = false, TC_Hierarchy__c = false,
							 TC_Major_Shareholding__c = false,  TC_VMFR__c = false,
													 TCA_Sanity_check__c = 'CHN', TCA_Application_withdrawal__c = 'CWD',Valid_Accreditation_Models__c='ALL'));
		insert customsettings;

	}

	@isTest static void createStagingAreaTest() {

		ANG_OscarProcessHelper.checkSFDCLimits();

		Test.startTest();

		List<String> fieldListAcct = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
			fieldListAcct.add(field);
		}

		List<String> fieldListContact = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapContacts = Contact.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapContacts.keySet()){
			fieldListContact.add(field);
		}

		List<Account> accts = Database.query('SELECT '+ String.join(fieldListAcct, ', ') + ' , ( SELECT ' +String.join(fieldListContact, ', ') + ' FROM Contacts) FROM Account');

		Account acct = accts.get(0);

		ANG_OscarProcessHelper.createRevalidationOscar(acct, acct.Contacts, true);

		Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
															,'IATACode__c' => 'IATACode__c'
															,'Short_Name__c' => 'Short_Name__c'
															,'TradeName__c' => 'Trade_Name__c'
															,'License_Number__c' => 'ISSP_AMS_License_No__c'
															,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
															,'BillingStreet' => 'Branch_Office_Street_name_number__c'
															,'Website' => 'Website__c'
															,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
															,'BillingCity' => 'Branch_Office_City__c'
															,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
															,'Iso_State__c' => 'IATA_ISO_State__c'
															,'ShippingStreet' => 'Shipping_Street__c'
															,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
															,'Email__c' => 'Branch_Office_Email__c'
															,'Phone' => 'Branch_Office_Phone__c'
															,'Fax' => 'Branch_Office_FAX__c'
															,'ShippingCity' => 'Shipping_City__c'
															,'Operation__c' => 'Operation__c'
															,'Abbreviated_name__c' => 'Abbreviated_name__c'
															,'Abbreviated_address__c' => 'Abbreviated_Address__c'
															,'Remittance_frequency__c' => 'Remittance_frequency__c'
															,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
															,'VAT_Number_2__c' => 'VAT_Number_2__c'
															,'CASS_Number__c' => 'CASS_Number__c'
															,'Location_Class__c' => 'Location_Class__c'
															,'Location_Type__c' => 'Location_Type__c'
															,'Mobile__c' => 'Mobile__c'
															,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
															,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
															,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
															,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
															,'Link_agent_name__c' => 'Link_agent_name__c'
															,'ANG_Accreditation_Model__c' => 'ANG_Accreditation_type__c'
															};

		Map<String,Object> fieldsOfObject = new Map<String,Object>();

		For(String fieldValue: fieldsMapping.keySet()){

			fieldsOfObject.put(fieldsMapping.get(fieldValue),acct.get(fieldValue));

		}

		fieldsOfObject.put('ISSP_AMS_Legal_Status__c',AMS_Utils.transformLegalStatus(acct.Company_Type__c));
		fieldsOfObject.put('ISSP_AMS_GDS_with_signed_contract__c',AMS_AgencyHelper.transformGDS(acct.GDS__c));
		String valueForAccountAirport = acct.In_a_Airport__c == true ? 'Yes' : 'No';
		fieldsOfObject.put('ISSP_AMS_Premises_located_at_airport__c',valueForAccountAirport);

		AMS_Pax_Accreditation_Form__c accr = ANG_EntityCreator.createStagingArea(RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes'), acct.Name, [select Id from case where Account.IATACODE__c = :acct.IATACode__c and reason1__c = 'Annual revalidation' and Status <> 'Closed'].Id, fieldsOfObject);
		accr.HO_Account__c = acct.Id;
		accr.IATACode__c = acct.IATACode__c;

		insert accr;

		ApexPages.StandardController sc = new ApexPages.StandardController(accr);

		PageReference pageRef = Page.ANG_AccreditationAreaViewer;
	 	Test.setCurrentPage(pageRef);
	 	pageRef.getParameters().put('Id', String.valueOf(accr.Id));

		ANG_AccreditationAreaViewer accreditationAreaV = new ANG_AccreditationAreaViewer(sc);

		List<String> accreditationFields = accreditationAreaV.accreditationFields;
		Map<String,boolean> accountFieldsMapping = accreditationAreaV.accountFieldsMapping;
		Boolean doNotHaveOscarYet = accreditationAreaV.doNotHaveOscarYet;
		List<String> noteList = accreditationAreaV.noteList;
		Set<String> notes = accreditationAreaV.notes;
		String existingOscarCaseNumber = accreditationAreaV.existingOscarCaseNumber;
		Id existingOscarCaseId = accreditationAreaV.existingOscarCaseId;
		Set<String> pageSections = accreditationAreaV.pageSections;
		Map<String, String> fieldsSectionMap = accreditationAreaV.fieldsSectionMap;
		List<ANG_AccreditationAreaViewer.AccreditationContact> accreditationContactFormList = accreditationAreaV.accreditationContactFormList;

		ANG_OscarProcessHelper.checkSFDCLimits();

		Test.stopTest();

	}

	@isTest static void createStagingAreaAndOscarChangesTest() {

		ANG_OscarProcessHelper.checkSFDCLimits();

		Test.startTest();

		List<String> fieldListAcct = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
			fieldListAcct.add(field);
		}

		List<String> fieldListContact = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapContacts = Contact.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapContacts.keySet()){
			fieldListContact.add(field);
		}

		List<Account> accts = Database.query('SELECT '+ String.join(fieldListAcct, ', ') + ' , ( SELECT ' +String.join(fieldListContact, ', ') + ' FROM Contacts) FROM Account');

		Account acct = accts.get(0);

		ANG_OscarProcessHelper.createRevalidationOscar(acct, acct.Contacts, true);

		Map<String, String> fieldsMapping = new Map<String, String> {'Name' => 'Account_Name__c'
															,'IATACode__c' => 'IATACode__c'
															,'Short_Name__c' => 'Short_Name__c'
															,'TradeName__c' => 'Trade_Name__c'
															,'License_Number__c' => 'ISSP_AMS_License_No__c'
															,'VAT_Number__c' => 'ISSP_AMS_VAT_number__c'
															,'BillingStreet' => 'Branch_Office_Street_name_number__c'
															,'Website' => 'Website__c'
															,'BillingPostalCode' => 'Branch_Office_Postal_code__c'
															,'BillingCity' => 'Branch_Office_City__c'
															,'IATA_ISO_Country__c' => 'Branch_Office_Country__c'
															,'Iso_State__c' => 'IATA_ISO_State__c'
															,'ShippingStreet' => 'Shipping_Street__c'
															,'ShippingPostalCode' => 'Shipping_Postal_Code__c'
															,'Email__c' => 'Branch_Office_Email__c'
															,'Phone' => 'Branch_Office_Phone__c'
															,'Fax' => 'Branch_Office_FAX__c'
															,'ShippingCity' => 'Shipping_City__c'
															,'Operation__c' => 'Operation__c'
															,'Abbreviated_name__c' => 'Abbreviated_name__c'
															,'Abbreviated_address__c' => 'Abbreviated_Address__c'
															,'Remittance_frequency__c' => 'Remittance_frequency__c'
															,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
															,'VAT_Number_2__c' => 'VAT_Number_2__c'
															,'CASS_Number__c' => 'CASS_Number__c'
															,'Location_Class__c' => 'Location_Class__c'
															,'Location_Type__c' => 'Location_Type__c'
															,'Mobile__c' => 'Mobile__c'
															,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
															,'IATA_ISO_Billing_State__c' => 'IATA_ISO_State__c'
															,'IATA_ISO_Shipping_Country__c' => 'Shipping_ISO_Country__c'
															,'IATA_ISO_Shipping_State__c' => 'Shipping_ISO_State__c'
															,'Link_agent_name__c' => 'Link_agent_name__c'
															,'ANG_Accreditation_Model__c' => 'ANG_Accreditation_type__c'
															};

		Map<String,Object> fieldsOfObject = new Map<String,Object>();

		For(String fieldValue: fieldsMapping.keySet()){

			fieldsOfObject.put(fieldsMapping.get(fieldValue),acct.get(fieldValue));

		}

		fieldsOfObject.put('ISSP_AMS_Legal_Status__c',AMS_Utils.transformLegalStatus(acct.Company_Type__c));
		fieldsOfObject.put('ISSP_AMS_GDS_with_signed_contract__c',AMS_AgencyHelper.transformGDS(acct.GDS__c));
		String valueForAccountAirport = acct.In_a_Airport__c == true ? 'Yes' : 'No';
		fieldsOfObject.put('ISSP_AMS_Premises_located_at_airport__c',valueForAccountAirport);

		AMS_Pax_Accreditation_Form__c accr = ANG_EntityCreator.createStagingArea(RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'New_Gen_Changes'), acct.Name, [select Id from case where Account.IATACODE__c = :acct.IATACode__c and reason1__c = 'Annual revalidation' and Status <> 'Closed'].Id, fieldsOfObject);
		accr.HO_Account__c = acct.Id;
		accr.IATACode__c = acct.IATACode__c;

		insert accr;

		Test.stopTest();

		ANG_OscarProcessHelper.createOscarChangesCase(accr.Id);

	}
}