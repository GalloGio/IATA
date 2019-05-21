global class ANG_MulticountryOscarCreatorBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	
	global Set<Id> accountIds;

	global List<ANG_ConversionHelper.ConversionBatchItem> resultItems;

	global ANG_MulticountryOscarCreatorBatch(Set<Id> accountIds) {

		resultItems = new List<ANG_ConversionHelper.ConversionBatchItem>();

		List<String> fieldListAcct = new List<String>();
		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
			fieldListAcct.add(field);
		}

		fieldListAcct.add('IATA_ISO_Country__r.Name');
		
		this.accountIds = accountIds;	

		this.query = 'SELECT '+ String.join(fieldListAcct, ', ') + ' FROM Account WHERE Id in:accountIds';
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	
		System.SavePoint sp = Database.setSavepoint();

		Account acct = null;
		AMS_OSCAR__c oscar = null;
		Case newCaseMC = null;
		AMS_Pax_Accreditation_Form__c stagingArea = null;
		
		try{
			
			acct = (Account) scope.get(0);
			Case c = [Select id, Subject, Origin, CaseNumber, RecordTypeId, CaseArea__c, Reason, Reason1__c, Visible_on_ISS_Portal__c, Region__c, BSPCountry__c, AccountId, ContactId from Case where accountid =: acct.Top_Parent__c AND reason1__c = 'New HE multicountry'];
			System.debug('[ANG_MulticountryOscarCreatorBatch]Parent Case recordType = ' +c.recordTypeId);
			Map<String,Object> fieldsOfObject = new Map<String,Object>();

			sp = Database.setSavePoint();

	        fieldsOfObject.put('Process__c', AMS_Utils.MCAE);
			fieldsOfObject.put('Status__c','Open');
			
			oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_MCAE, acct.Id, fieldsOfObject);

			insert oscar;

	        fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('Oscar__c',oscar.Id);
	        fieldsOfObject.put('ContactId',c.ContactId);
	        fieldsOfObject.put('ParentId',c.Id);
	        fieldsOfObject.put('BSPCountry__c',acct.BillingCountry);
	        fieldsOfObject.put('CaseArea__c',c.CaseArea__c);
	        fieldsOfObject.put('ContactId',c.ContactId);
			fieldsOfObject.put('Reason1__c', 'New AE Multicountry');
	        fieldsOfObject.put('Region__c',acct.Region_formula__c);
	        fieldsOfObject.put('Subject', 'New Associate Entity - GoGlobal - ' + acct.IATA_ISO_Country__r.Name);
	        fieldsOfObject.put('Visible_on_ISS_Portal__c', c.Visible_on_ISS_Portal__c);
	        fieldsOfObject.put('Origin', c.Origin);
	        
	        newCaseMC = ANG_EntityCreator.createCase(c.RecordTypeId, acct.id, fieldsOfObject);
			System.debug('[ANG_MulticountryOscarCreatorBatch]new Case = ' + newCaseMC);
			
	        insert newCaseMC;
	        
	        fieldsOfObject = new Map<String,Object>();
	        
	        fieldsOfObject.put('ANG_Accreditation_type__c',acct.ANG_Accreditation_Model__c);
	        fieldsOfObject.put('Abbreviated_Address__c',acct.Abbreviated_address__c);
	        fieldsOfObject.put('Abbreviated_name__c',acct.Abbreviated_name__c);
	        fieldsOfObject.put('Accept_terms_and_conditions__c',true);
	        fieldsOfObject.put('Billing_State__c',acct.BillingState);
	        fieldsOfObject.put('Branch_Office_City__c',acct.BillingCity);
	        fieldsOfObject.put('Branch_Office_Country__c',acct.IATA_ISO_Country__c);
	        fieldsOfObject.put('Branch_Office_Email__c',acct.Email__c);
	        fieldsOfObject.put('Branch_Office_FAX__c',acct.Fax);
	        fieldsOfObject.put('Branch_Office_Phone__c',acct.Phone);
	        fieldsOfObject.put('Branch_Office_Postal_code__c',acct.BillingPostalCode);
	        fieldsOfObject.put('Branch_Office_Street_name_number__c',acct.BillingStreet);
	        fieldsOfObject.put('IATACode__c',acct.IATACode__c);
	        fieldsOfObject.put('IATA_ISO_State__c',acct.Iso_State__c);
	        fieldsOfObject.put('ISSP_AMS_Legal_Status__c',AMS_AgencyHelper.transformCompanyType(acct.Company_Type__c));
	        fieldsOfObject.put('ISSP_AMS_License_No__c',acct.License_Number__c);
	        fieldsOfObject.put('ISSP_AMS_VAT_number__c',acct.VAT_Number__c);
	        fieldsOfObject.put('Location_Class__c',acct.Location_Class__c);
	        fieldsOfObject.put('Location_Type__c',acct.Location_Type__c);
	        fieldsOfObject.put('Mobile__c',acct.Mobile__c);
	        fieldsOfObject.put('Operation__c',acct.Operation__c);
	        fieldsOfObject.put('Remittance_frequency__c','');
	        fieldsOfObject.put('Shipping_City__c',acct.ShippingCity);
	        fieldsOfObject.put('Shipping_Country__c',acct.ShippingCountry);
	        fieldsOfObject.put('Shipping_ISO_Country__c',acct.IATA_ISO_Shipping_Country__c);
	        fieldsOfObject.put('Shipping_ISO_State__c',acct.IATA_ISO_Shipping_State__c);
	        fieldsOfObject.put('Shipping_Postal_Code__c',acct.ShippingPostalCode);
	        fieldsOfObject.put('Shipping_State__c',acct.ShippingState);
	        fieldsOfObject.put('Shipping_Street__c',acct.ShippingStreet);
	        fieldsOfObject.put('Short_Name__c',acct.Short_Name__c);
	        fieldsOfObject.put('Solicitation_Flag__c',acct.Solicitation_Flag__c);
	        fieldsOfObject.put('Submitted_to_IATA__c',true);
	        fieldsOfObject.put('Trade_Name__c',acct.TradeName__c);
	        fieldsOfObject.put('VAT_Number_2__c',acct.VAT_Number_2__c);
	        fieldsOfObject.put('Website__c',acct.Website);
	        
	        stagingArea = ANG_EntityCreator.createStagingArea(RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Associate_Entity'), acct.Name, newCaseMC.Id, fieldsOfObject);
	        
	        insert stagingArea;
	        
	        fieldsOfObject = new Map<String,Object>();
	        fieldsOfObject.put('AMS_Online_Accreditation__c',stagingArea.Id);
	        fieldsOfObject.put('Oscar_Communication_Case_Id__c', newCaseMC.Id);
	        ANG_EntityCreator.updateOscar(oscar, fieldsOfObject);
	        	        
	        upsert oscar;
	        
		}catch(Exception e){
			
            System.debug('[ANG_MulticountryOscarCreatorBatch] Exception processing account ' + acct.Id + ':' + e.getStackTraceString());
            
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), true, e.getMessage());

			System.debug(item);
			resultItems.add(item);
			Database.rollback(sp);

		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}