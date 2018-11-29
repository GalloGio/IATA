global without sharing class ANG_BackupEngineHelper implements Queueable{

		// Account -> AMS_Pax_Accreditation_Form__c
	private	Map<String, String> fieldsMapping = new Map<String, String> {'Account_Name__c' => 'Name'
																	,'IATACode__c' => 'IATACode__c'
																	,'Short_Name__c' => 'Short_Name__c'
																	,'Trade_Name__c' => 'TradeName__c'
																	,'ISSP_AMS_License_No__c' => 'License_Number__c'
																	,'ISSP_AMS_VAT_number__c' => 'VAT_Number__c'
																	,'Branch_Office_Street_name_number__c' => 'BillingStreet'
																	,'Website__c' => 'Website'
																	,'Branch_Office_Postal_code__c' => 'BillingPostalCode'
																	,'Branch_Office_City__c' => 'BillingCity'
																	,'Branch_Office_Country__c' => 'IATA_ISO_Country__c'
																	,'IATA_ISO_State__c' => 'Iso_State__c'
																	,'Shipping_Street__c' => 'ShippingStreet'
																	,'Shipping_Postal_Code__c' => 'ShippingPostalCode'
																	,'Branch_Office_Email__c' => 'Email__c'
																	,'Branch_Office_Phone__c' => 'Phone'
																	,'Branch_Office_FAX__c' => 'Fax'
																	,'Shipping_City__c' => 'ShippingCity'
																	,'Operation__c' => 'Operation__c'
																	,'Abbreviated_name__c' => 'Abbreviated_name__c'
																	,'Abbreviated_Address__c' => 'Abbreviated_address__c'
																	,'Remittance_frequency__c' => 'Remittance_frequency__c'
																	,'Solicitation_Flag__c' => 'Solicitation_Flag__c'
																	,'VAT_Number_2__c' => 'VAT_Number_2__c'
																	,'CASS_Number__c' => 'CASS_Number__c'
																	,'Location_Class__c' => 'Location_Class__c'
																	,'Location_Type__c' => 'Location_Type__c'
																	,'Mobile__c' => 'Mobile__c'
																	,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c'
																	,'IATA_ISO_State__c' => 'IATA_ISO_Billing_State__c'
																	,'Shipping_ISO_Country__c' => 'IATA_ISO_Shipping_Country__c'
																	,'Shipping_ISO_State__c' => 'IATA_ISO_Shipping_State__c'
																	,'Link_agent_name__c' => 'Link_agent_name__c'
																	,'ANG_Accreditation_type__c' => 'ANG_Accreditation_Model__c'
																	,'ISSP_AMS_Premises_located_at_airport__c' => 'In_a_Airport__c'
																	,'ISSP_AMS_Legal_Status__c' => 'Company_Type__c'
																	,'ISSP_AMS_GDS_with_signed_contract__c' => 'GDS__c'
																	,'Branch_Office_Country__c' => 'BillingCountry'
																	,'Shipping_ISO_Country__c' => 'Shipping_ISO_Country__c'
																	,'IATA_ISO_State__c' => 'ShippingState'
																	,'IATA_ISO_State__c' => 'BillingState'
	};

	private Map<String,List<String>> entitiesToBackupConfig = new Map<String,List<String>> {
		'Legal name' => new List<String>{'ANG_RHC_Information__c'},
		'Legal status' => new List<String>{'ANG_RHC_Information__c'},
		'Minor shareholding' => new List<String>{'AMS_Account_Role__c','Contact','ANG_RHC_Information__c'},
		'Major shareholding' => new List<String>{'AMS_Account_Role__c','Contact','ANG_RHC_Information__c'},
		'Ownership' => new List<String>{'AMS_Account_Role__c','Contact','ANG_RHC_Information__c'},
		'Location type' => new List<String>{'ANG_RHC_Information__c','Financial_Security__c','ANG_Agency_Risk_Event__c','AMS_Agencies_Hierarchy__c','AMS_Agencies_relationhip__c'},
		'Location' => new List<String>{'ANG_RHC_Information__c'},
		'Hierarchy' => new List<String>{'Agency_Authorization__c','ANG_Agency_Risk_Event__c','ANG_RHC_Information__c','AMS_Agencies_Hierarchy__c','AMS_Agencies_relationhip__c','Contact','Financial_Security__c','Portal_Application_Right__c'},
		'VMFR' => new List<String>{'ANG_RHC_Information__c'},
		'Accreditation type' => new List<String>{'Agency_Authorization__c', 'Portal_Application_Right__c', 'ANG_RHC_Information__c'},
		'Location type to different legal entity' => new List<String>{'ANG_RHC_Information__c','Financial_Security__c','ANG_Agency_Risk_Event__c','AMS_Agencies_Hierarchy__c','AMS_Agencies_relationhip__c','Agency_Authorization__c'},
		'Trade name' => new List<String>{'ANG_RHC_Information__c'},
		'Conversion to GoLite' => new List<String>{'Agency_Authorization__c','ANG_Agency_Risk_Event__c','ANG_RHC_Information__c','AMS_Agencies_Hierarchy__c','AMS_Agencies_relationhip__c'},
		'Conversion to Domestic with Cash' => new List<String>{'Agency_Authorization__c','ANG_Agency_Risk_Event__c','ANG_RHC_Information__c','AMS_Agencies_Hierarchy__c','AMS_Agencies_relationhip__c'}
	};

	private Map<String,String> whereClausesMap = new Map<String,String>{
			'AMS_ACCOUNT_ROLE__C' => ' Account__c in:objectIds',
			'AGENCY_AUTHORIZATION__C' => ' Account__c in:objectIds',
			'CONTACT' => ' AccountId in:objectIds',
			'ANG_RHC_INFORMATION__C' => ' ANG_AccountId__c in:objectIds',
			'FINANCIAL_SECURITY__C' => ' Account__c in:objectIds',
			'ANG_AGENCY_RISK_EVENT__C' => 'ANG_AccountId__c in:objectIds',
//			'ANG_AGENCY_RISK_EVENT__C' => ' ANG_AccountId__c in:objectIds and ANG_OscarId__c =:oscarId',
			'ACCOUNT' => ' Id in:objectIds',
			'PORTAL_APPLICATION_RIGHT__C' => ' Contact__r.AccountId IN :objectIds AND Application_Name__c = \'IFAP\'',
			'AMS_OSCAR__C' => ' Id =:oscarId',
			'AMS_AGENCIES_HIERARCHY__C' => ' Id in (select Hierarchy__c  from AMS_AGENCIES_RELATIONHIP__C WHERE Child_Account__c in:objectIds or Parent_Account__c in:objectIds)',
			'AMS_AGENCIES_RELATIONHIP__C' => ' Child_Account__c in:objectIds or Parent_Account__c in:objectIds '
	};

	private Map<String,Set<String>> fieldsInEntity;

	private Map<Id,Technical_Logs__c> technicalLogsMap;

	private Id oscarId;

	private AMS_OSCAR__c oscar;

	private Id newParentHierarchyId;

	private Map<String,List<sObject>> entitiesToBackup;

	public ANG_BackupEngineHelper(Id oscarId){

		this.technicalLogsMap = new Map<Id,Technical_Logs__c>();
		this.oscarId = oscarId;
		this.entitiesToBackup = new Map<String,List<sObject>>();
		this.fieldsInEntity = new Map<String,Set<String>>();

	}

	public ANG_BackupEngineHelper(Id oscarId, boolean toDeleteExisting){

		this.technicalLogsMap = new Map<Id,Technical_Logs__c>();
		this.oscarId = oscarId;
		this.entitiesToBackup = new Map<String,List<sObject>>();
		this.fieldsInEntity = new Map<String,Set<String>>();

		if(toDeleteExisting){
			deleteAllBackups();
		}
	}
	
	public void deleteAllBackups(){
		delete [Select Id from Technical_Logs__c where Record__c = :oscarId];
	}

	public void execute(QueueableContext context){
		executeAdhoc();
	}

	public void executeAdhoc(){
		initData();
		//backupData();
	}

	public void setNewParentHierarchyId(Id newParentHierarchyId){
		this.newParentHierarchyId = newParentHierarchyId;
	}

	private void initData(){

		system.debug('[ANG_BackupEngineHelper] (1) Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

		oscar = (AMS_OSCAR__c)getObject('AMS_OSCAR__c',new Set<Id>{oscarId},toUpperCase(new Set<String>{'account__c','ANG_Type_Of_Change__c','New_parent__c'}),whereClausesMap.get('AMS_OSCAR__C')).get(0);

		if(oscar.ANG_Type_Of_Change__c == null)
			return;

		Set<Id> accountIds = new Set<Id>();
		accountIds.addAll(fetchHierarchySelection(oscar.Account__c));
		accountIds.add(oscar.account__c);

		if(oscar.ANG_Type_Of_Change__c.contains(AMS_Utils.ANG_LOCATION_TYPE) || oscar.ANG_Type_Of_Change__c.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)){

			For(List<AMS_Agencies_relationhip__c> rels : AMS_HierarchyHelper.getAccountsHierarchies(accountIds).values()){
				For(AMS_Agencies_relationhip__c rel: rels){
					accountIds.add(rel.Parent_Account__c);
					accountIds.add(rel.Child_Account__c);
				}
			}
		}
		
		if(newParentHierarchyId == null)
			newParentHierarchyId = oscar.New_parent__c;

		Set<String> accountFields = fetchAccountFieldsFromAccreditationConfig(oscar.ANG_Type_Of_Change__c);

		accountFields.add('ParentId');
		accountFields.add('Location_Type__c');
		accountFields.add('ANG_FA_Opt_out__c');
		accountFields.add('Is_PCI_compliant__c');
		accountFields.add('ANG_PCI_compliance_expiry_date__c');
		accountFields.add('Top_Parent__c');
		accountFields.add('Financial_Review_Result__c');
		accountFields.add('Assessment_Performed_Date__c');
		accountFields.add('ANG_Accreditation_Model__c');
		accountFields.add('ANG_IEP_Status__c');
		accountFields.add('ANG_IEP_HE_AccntNum__c');
		
		Set<String> contactFields = new Set<String>();
		
		contactFields.add('FirstName');
		contactFields.add('LastName');
		contactFields.add('Title');
		contactFields.add('AccountId');
		contactFields.add('Membership_Main_Contact__c');
		contactFields.add('Financial_Assessment_Contact__c');
		contactFields.add('Phone');
		contactFields.add('Mobilephone');
		contactFields.add('Fax');
		contactFields.add('Birthdate');
		contactFields.add('Email');
		contactFields.add('ISO_Country__c');
		contactFields.add('RecordTypeId');
		contactFields.add('Training_dangerous_goods_completed__c');
		contactFields.add('list_Dangerous_Goods_Awareness__c');
		contactFields.add('Authorized_Signatory__c');
		contactFields.add('Designated_Portal_Admin__c');
		contactFields.add('Invoicing_Contact__c');
		contactFields.add('OtherStreet');
		contactFields.add('OtherCity');
		contactFields.add('OtherPostalCode');
		contactFields.add('OtherCountry');


		Set<String> entitiesToRollback = new Set<String>();

		for(String typeOfChange: oscar.ANG_Type_Of_Change__c.split(';'))
			entitiesToRollback.addAll(entitiesToBackupConfig.get(typeOfChange));

		if(newParentHierarchyId != null){
			accountIds.add(newParentHierarchyId);	
		}

		system.debug('[ANG_BackupEngineHelper] (2) Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

		entitiesToBackup.put('Account',getObject('Account',accountIds,toUpperCase(accountFields),whereClausesMap.get('ACCOUNT')));
		// we are using DefaultChange in the Map, but later we need to define which entities should we backup for each type of change...

		backupData(); // for Account

		system.debug('[ANG_BackupEngineHelper] (3) Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

		For(String entity : entitiesToRollback){

			system.debug('[ANG_BackupEngineHelper] Cleanup : (3.1) Before Entity '+entity +' Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

			this.entitiesToBackup = null;
			this.entitiesToBackup = new Map<String,List<sObject>>();

			system.debug('[ANG_BackupEngineHelper] Cleanup done : (3.1) Before Entity '+entity +' Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

			if(newParentHierarchyId != null && (entity == 'AMS_Agencies_Hierarchy__c'|| entity == 'AMS_Agencies_relationhip__c')){
				accountIds.add(newParentHierarchyId);	
			}
			
			Set<String> fieldSet = entity == 'Contact' ? contactFields : null;

			entitiesToBackup.put(entity,getObject(entity,accountIds,fieldSet,whereClausesMap.get(entity.toUpperCase())));
			system.debug('[ANG_BackupEngineHelper] (4) after Entity '+entity +' Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

			backupData();
		}

		oscar.Backup_In_Progress__c	= false;
		update oscar;


	}

	private void backupData(){
		
		List<Technical_Logs__c> backupToInsert = new List<Technical_Logs__c>();

		Set<String> entitiesToBackupLst = entitiesToBackup.keySet();

		for(String entity : entitiesToBackupLst){

			List<sObject> objectList = entitiesToBackup.get(entity);

			for(sObject sobjectToInsert: entitiesToBackup.get(entity)){

				Technical_Logs__c backupData = new Technical_Logs__c(
					Log__c= JSON.serialize(serializeObject(entity,sobjectToInsert)), 
					Status__c= entity, 
					Record__c= oscarId,
					Operation__c= 'Rollback');

				backupToInsert.add(backupData);
                
				system.debug('[ANG_BackupEngineHelper] (5) after Entity '+entity +' and object ' + sobjectToInsert.Id+' Heap size: ' + Limits.getHeapSize() + ' of ' + Limits.getLimitHeapSize());

			}

		}

		if(!backupToInsert.isEmpty()){
			System.debug('[ANG_BackupEngineHelper] backupToInsert are' + backupToInsert);
			insert backupToInsert;
		}

		//oscar.Backup_In_Progress__c	= false;
		//update oscar;

	}

	private Map<String,Object> serializeObject(String entity, sObject objectToSerialize){

		Map<String,Object> fieldsToSerialize = new Map<String,Object>();

		for(String field: fieldsInEntity.get(entity))
			fieldsToSerialize.put(field, objectToSerialize.get(field));

		return fieldsToSerialize;

	}

	private Set<Id> fetchHierarchySelection(Id accountOscar){

		Set<Id> accountIds = new Set<Id>();
		
		Account acct = [Select Id, Location_Type__c, ParentId from Account where Id =:accountOscar];
		Id accountId = acct.Id;
		
		if(acct.Location_Type__c <> AMS_Utils.HE)
			accountId = acct.ParentId;

		for(Account acctToSearch: [Select Id from Account where ParentId =:accountId])
			accountIds.add(acctToSearch.Id);
	
		accountIds.add(accountId);

		return accountIds;
	}


	public List<sObject> getObject(String selectedObject, Set<Id> objectIds, Set<String> objectFields, String adhocConditions){

		Map<String, Schema.SObjectType> gdMap = Schema.getGlobalDescribe();
		Schema.Describesobjectresult dsr = gdMap.get(selectedObject).getDescribe();
		Map<String, Schema.SObjectField> schemaFieldMap = dsr.fields.getMap();

		Set<String> fieldSet = new Set<String>();

		for(String field : schemaFieldMap.keySet()){
			
			String str = field.toUpperCase();

			if(objectFields == null || objectFields.contains(str))
				fieldSet.add(str);
		}

		if(objectFields != null)
			fieldSet.add('Id');

		List<String> fieldList = new List<String>();
		fieldList.addAll(fieldSet);

		fieldsInEntity.put(selectedObject,fieldSet);

		String query = 'SELECT '+ String.join(fieldList, ', ') + ' FROM '+selectedObject;

		if(adhocConditions != null)
			query += ' WHERE ' + adhocConditions;

		return Database.query(query);

	}

	public Set<String> fetchAccountFieldsFromAccreditationConfig(String TypeOfChanges){

		Set<String> fieldsToReturn = new Set<String>();

		for(String field: ANG_AgencyChangesConfigHelper.getFieldsToMigrate(TypeOfChanges)){
			if(fieldsMapping.get(field) != null)
				fieldsToReturn.add(fieldsMapping.get(field));
		}

		return fieldsToReturn;
	}

	public Set<String> toUpperCase(Set<String> inSet){

		if(inSet == null)
			return null;

		Set<String> outSet = new Set<String>();
		
		for(String str: inSet){
			outSet.add(str.toUpperCase());
		}

		return outSet;
	}

}