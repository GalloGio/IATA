@isTest
private class ANG_AccreditationAreaViewerTest {
	
	@testSetup static void setup(){
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', Region__c = 'Europe', ANG_Enable_NewGen__c = true);
        insert ctry ;

        Id accountAgencyRT = AMS_Utils.getId('Account', 'IATA_Agency');

        Account acct = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountAgencyRT, IATACode__c='1234561',Location_Type__c='HE',Name='The Agency CIA',Short_Name__c='The Agency CIA', Sector__c = 'Travel Agent', Type ='IATA Passenger Sales Agent', Location_Class__c = 'P', Status__c = AMS_Utils.ACC_S9_APPROVED);
        
        insert acct;
        
        Contact co1 = new Contact(AccountId = acct.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = true);
		insert co1;

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

		AMS_Pax_Accreditation_Form__c accr = ANG_EntityCreator.createStagingArea(Schema.AMS_Pax_Accreditation_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('New Gen Changes').getRecordTypeId(), acct.Name, [select Id from case where Account.IATACODE__c = :acct.IATACode__c and reason1__c = 'Annual revalidation' and Status <> 'Closed'].Id, fieldsOfObject);
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

		ANG_OscarProcessHelper.checkSFDCLimits();

		Test.stopTest();

	}

	@isTest static void createOscarFromBatchTest() {

		Test.startTest();

		ANG_AnualRevalCaseCreationBatch anualRevalCaseCreationBatch = new ANG_AnualRevalCaseCreationBatch(new Set<Id>{[Select Id from Account].Id});
		Id anualRevalCaseCreationBatchId = Database.executeBatch(anualRevalCaseCreationBatch,1);	

		Test.stopTest();
	}

	@isTest static void createAnualRevalCaseCreationController(){

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

		ANG_AnualRevalCaseCreationController annualRevalCaseCtrl = new ANG_AnualRevalCaseCreationController();

		annualRevalCaseCtrl.setmode('Country');
		annualRevalCaseCtrl.setregion('Europe');
		annualRevalCaseCtrl.setcountry([select Id, Name, Region__c from IATA_ISO_Country__c].Id);
		annualRevalCaseCtrl.searchAgencies();

		annualRevalCaseCtrl.getregionobj();
		annualRevalCaseCtrl.getmodeObj();
		annualRevalCaseCtrl.getyearobj();
		annualRevalCaseCtrl.getcountryobj();
		annualRevalCaseCtrl.getshouldDisableButton();
		annualRevalCaseCtrl.launchCampaign();

		annualRevalCaseCtrl.refreshPageSize();

		Boolean hasNext = annualRevalCaseCtrl.hasNext;
		Boolean hasPrevious = annualRevalCaseCtrl.hasPrevious;
		Integer pageNumber = annualRevalCaseCtrl.pageNumber;
		annualRevalCaseCtrl.next();
		annualRevalCaseCtrl.last();
		annualRevalCaseCtrl.first();

		Test.stopTest();

	}

	@isTest static void createAnualRevalCaseCreationController2(){

		Test.startTest();

		ANG_AnualRevalCaseCreationController annualRevalCaseCtrl = new ANG_AnualRevalCaseCreationController();
		annualRevalCaseCtrl.getcountryobj();
		annualRevalCaseCtrl.setyear('January');

		annualRevalCaseCtrl.setmode('Country');
		annualRevalCaseCtrl.setregion('Europe');
		annualRevalCaseCtrl.setcountry([select Id from IATA_ISO_Country__c].Id);
		annualRevalCaseCtrl.searchAgencies();

		annualRevalCaseCtrl.getregionobj();
		annualRevalCaseCtrl.getmodeObj();
		annualRevalCaseCtrl.getyearobj();
		annualRevalCaseCtrl.getcountryobj();
		annualRevalCaseCtrl.getshouldDisableButton();

		annualRevalCaseCtrl.launchCampaign();

		annualRevalCaseCtrl.refreshPageSize();

		Boolean hasNext = annualRevalCaseCtrl.hasNext;
		Boolean hasPrevious = annualRevalCaseCtrl.hasPrevious;
		Integer pageNumber = annualRevalCaseCtrl.pageNumber;
		annualRevalCaseCtrl.next();
		annualRevalCaseCtrl.last();
		annualRevalCaseCtrl.first();
		annualRevalCaseCtrl.previous();

		Test.stopTest();

		annualRevalCaseCtrl.getBatchStatus();
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

		AMS_Pax_Accreditation_Form__c accr = ANG_EntityCreator.createStagingArea(Schema.AMS_Pax_Accreditation_Form__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('New Gen Changes').getRecordTypeId(), acct.Name, [select Id from case where Account.IATACODE__c = :acct.IATACode__c and reason1__c = 'Annual revalidation' and Status <> 'Closed'].Id, fieldsOfObject);
		accr.HO_Account__c = acct.Id;
		accr.IATACode__c = acct.IATACode__c;

		insert accr;

		Test.stopTest();

		ANG_OscarProcessHelper.createOscarChangesCase(accr.Id);

	}
}