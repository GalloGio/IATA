public with sharing class ANG_AgencyChangesHelper {
	
	public class AChangeStructure{

		public Map<Id,AMS_Agencies_relationhip__c> relationsMap;
		public Map<Id,Account> accountsMap;
		public Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> changesStruct;
		public List<Agency_Applied_Change_code__c> changeCodesToCreate;

		public AChangeStructure(){

			relationsMap = new Map<Id, AMS_Agencies_relationhip__c>();			
			accountsMap = new Map<Id, Account>();
			changeCodesToCreate = new List<Agency_Applied_Change_code__c>();

		}

		public AChangeStructure(Map<Id,AMS_Agencies_relationhip__c> relationsMap,  Map<Id,Account> accountsMap, List<Agency_Applied_Change_code__c> changeCodesToCreate){

			this.relationsMap = relationsMap;
			this.accountsMap = accountsMap;
			this.changeCodesToCreate = changeCodesToCreate;

		}

		public void addAccount(Account account){
				this.accountsMap.put(account.Id, account);
		}

		public void addRelation(AMS_Agencies_relationhip__c relation){
			this.relationsMap.put(relation.Child_Account__c, relation);
		}

		public void addChangeCode(Agency_Applied_Change_code__c changeCode){
            this.changeCodesToCreate.add(changeCode);
        }

        public void runUpsert(){

        	if(relationsMap != null && !relationsMap.isEmpty())
        		upsert relationsMap.values();
        	

        	if(accountsMap != null && !accountsMap.isEmpty())
        		upsert accountsMap.values();

        	if(changeCodesToCreate != null && !changeCodesToCreate.isEmpty())
        		insert changeCodesToCreate;
        	
        }

		public void addChangesStruct(Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> changesStruct){
			this.changesStruct = changesStruct;
		}

	}

	public static void handleNewGenChangesProcess(List<AMS_Oscar__c> oscars){

		AMS_OSCAR__c oscar = oscars[0];

		List<Map<String, String>> configs = ANG_AgencyChangesConfigHelper.getAgencyChangesConfigData();

		if(oscar.Process__c == AMS_Utils.NGCHANGES && oscar.ANG_Type_Of_Change__c != null && validateTypeOfChange(oscar, configs)){

			System.debug('[ANG_AgencyChangesHelper][handleNewGenChangesProcess] -- PROCESSING agency changes');

			AChangeStructure changesContainer = new AChangeStructure();

			System.debug('[ANG_AgencyChangesHelper][handleNewGenChangesProcess] -- types of changes selected are valid!');

			AMS_Utils.AgChangesConfig config = ANG_AgencyChangesConfigHelper.getSelectedTypeOfChangeCombinationConfig(oscar, configs);

			AMS_OSCAR__c oldOSCAR = (AMS_OSCAR__c)Trigger.oldMap.get(oscar.Id);

			Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
  			accountIdsInvolvedSet.add(oscar.Account__c);

  			//TODO TODO TODO////
  			Map<Id, Agency_Applied_Change_code__c> accountsCurrentChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

			if (oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {

				changesContainer = applyChangeOfFields(oscar, accountIdsInvolvedSet, changesContainer);

				if(Pattern.matches(AMS_Utils.LOCATION_TYPE + '|' + AMS_Utils.HIERARCHY, oscar.Process__c)){
					changesContainer = processHierarchyChanges(oscar, changesContainer, accountIdsInvolvedSet);

					changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.SANITYCHECK, accountIdsInvolvedSet, changesContainer);

				}else if (oldOSCAR.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL) {

					changesContainer = applyChangeOfFields(oscar, accountIdsInvolvedSet, changesContainer);

					changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.AUTH_APPROVAL, accountIdsInvolvedSet, changesContainer);

				} else if (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) {

					changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.WITHDRAWAL, accountIdsInvolvedSet, changesContainer);

				}

			}

			if(changesContainer != null)
				changesContainer.runUpsert();

		}

	}

	public static AChangeStructure processHierarchyChanges(AMS_OSCAR__c oscar, AChangeStructure changesContainer, Set<Id> accountIdsInvolvedSet) {

		Set<String> tocList = new Set<String>();
		tocList.addAll(oscar.ANG_Type_Of_Change__c.split(';'));


		if (tocList.contains(AMS_Utils.LOCATION_TYPE))
			changesContainer = applyChangeOfLocationType(oscar, changesContainer);
		else if (tocList.contains(AMS_Utils.HIERARCHY))
			changesContainer = applyChangeOfHierarchy(oscar, changesContainer, accountIdsInvolvedSet);

		return changesContainer;
	}

	public static AChangeStructure applyChangeOfLocationType(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn){

		// 1) need to fetch all the relations on the hierarchy
		// 2) need to fetch all the accounts involved in this "swap"
		// 3) need to change all the relations in the hierarchy to apply the new Parent
		// 4) need to change all the parent accounts and the location type of all agencies involved
		// 5) swap IEP information between old and new HE.

		if(toReturn == null)
			toReturn = new AChangeStructure();

		Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});

		For(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			System.debug('[applyChangeOfLocationType] - Found these relations to change:' + accountHierarchyRelationships.get(oscarToProcess.Account__c));

			if(rel.Child_Account__c == oscarToProcess.Account__c){
				
				System.debug('[applyChangeOfLocationType] - The AE to be changed is the following:'+ rel.Child_Account__c);

				Account parentAccount = [Select Id, Location_Type__c, ParentId, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c From Account where Id =:rel.Parent_Account__c];

				parentAccount.Location_Type__c = AMS_Utils.AE;
				parentAccount.ParentId = oscarToProcess.Account__c;

				Account childAccount = new Account(Id = rel.Child_Account__c);

				childAccount.Location_Type__c = AMS_Utils.HE;
				childAccount.ParentId = null;
				childAccount.ANG_IEP_HE_AccntNum__c = null;
				childAccount.ANG_IEP_Status__c = 'No IEP Account';
				childAccount.ANG_HE_CashCondition__c = parentAccount.ANG_HE_CashCondition__c;
				childAccount.ANG_HE_RiskHistoryAssessment__c = parentAccount.ANG_HE_RiskHistoryAssessment__c;
				childAccount.ANG_HE_RiskStatus__c = parentAccount.ANG_HE_RiskStatus__c;

				parentAccount.ANG_IEP_HE_AccntNum__c = null;
				parentAccount.ANG_IEP_Status__c = null;
				parentAccount.ANG_HE_CashCondition__c = false;
				parentAccount.ANG_HE_RiskHistoryAssessment__c = null;
				parentAccount.ANG_HE_RiskStatus__c = null;

				rel.Child_Account__c = rel.Parent_Account__c;

				toReturn.addAccount(parentAccount);
				toReturn.addAccount(childAccount);

			} else{

				Account relAccount = new Account(Id = rel.Child_Account__c, ParentId = oscarToProcess.Account__c);
				toReturn.addAccount(relAccount);

			}

			rel.Parent_Account__c = oscarToProcess.Account__c;
			toReturn.addRelation(rel);

		}

		return toReturn;

	}

	public static AChangeStructure applyChangeOfHierarchy(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Set<Id> accountIdsInvolvedSet){

		System.debug('[ANG_AgencyChangesHelper] Performing change of Hierarchy');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});

		System.debug('[ANG_AgencyChangesHelper] - accountHierarchyRelationships:' + accountHierarchyRelationships);

		AMS_Agencies_Hierarchy__c newH = null;

		Id hierarchyId = null;

		if(accountHierarchyRelationships.get(oscarToProcess.Account__c).isEmpty()){ // this is just moving one single account to a new hierchy

			System.debug('[ANG_AgencyChangesHelper] Moving non-hierarchy account.');

			hierarchyId = fetchHierarchyFromExternalAccount(oscarToProcess.New_parent__c);

			if(hierarchyId == null){

				newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy');
				insert newH;

				hierarchyId = newH.Id;

				System.debug('[ANG_AgencyChangesHelper] Inserted new Hierarchy with Id:' + newH.Id + ' since the destination account is a single Account.');
			}

			Account oscarAccount = new Account(Id = oscarToProcess.Account__c);
			oscarAccount.Location_Type__c = AMS_Utils.AE;
			oscarAccount.ParentId = oscarToProcess.New_parent__c;
			oscarAccount.ANG_IEP_HE_AccntNum__c = null;
			oscarAccount.ANG_IEP_Status__c = null;
			oscarAccount.ANG_HE_CashCondition__c = false;
			oscarAccount.ANG_HE_RiskHistoryAssessment__c = null;
			oscarAccount.ANG_HE_RiskStatus__c = null;

			toReturn.addAccount(oscarAccount);

			AMS_Agencies_relationhip__c newRel = new AMS_Agencies_relationhip__c();
			newRel.Parent_Account__c = oscarToProcess.New_parent__c;
			newRel.Child_Account__c = oscarToProcess.Account__c;
			newRel.Is_Newgen_Relation__c = true;
			newRel.Hierarchy__c = hierarchyId;

			toReturn.addRelation(newRel);

			return toReturn; // no more processing needed.
		}

		// The diff between moving to an existing Hierarchy and a new will be determined by the New_parent__c field on the Oscar  

		boolean isNewHierarchy = verifyNewHierarchy(accountHierarchyRelationships.get(oscarToProcess.Account__c),oscarToProcess.New_parent__c);

		Set<AMS_Agencies_relationhip__c> relationsToDelete = new Set<AMS_Agencies_relationhip__c>();

		if(isNewHierarchy){ // meaning is to create a new hierarchy ?

			newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy');
			insert newH;
			System.debug('[ANG_AgencyChangesHelper] - Inserted new Hierarchy with Id:' + newH.Id);

		}else{

			hierarchyId = fetchHierarchyFromExternalAccount(oscarToProcess.New_parent__c);
			if(hierarchyId == null){
				newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy');
				insert newH;
				System.debug('[ANG_AgencyChangesHelper] - Inserted new Hierarchy with Id:' + newH.Id + ' since the destination account is a single Account.');
			}
			else{
				newH = new AMS_Agencies_Hierarchy__c(Id = hierarchyId);
			}

		}

		// create new relations

		System.debug('[ANG_AgencyChangesHelper] - Agencies involved to create new relations and update the accounts:'+accountIdsInvolvedSet);

		for(Id accountID: accountIdsInvolvedSet){

			if(accountID == oscarToProcess.New_parent__c){ // this means that one of the old AE's is going to be the new HE, so let's change it !

				Account newHe = new Account(Id = oscarToProcess.New_parent__c);
				newHe.Location_Type__c = AMS_Utils.HE;
				newHe.ParentId = null;
				newHe.ANG_IEP_HE_AccntNum__c = null;
				newHe.ANG_IEP_Status__c = 'No IEP Account';
				newHe.ANG_HE_CashCondition__c = false;
				newHe.ANG_HE_RiskHistoryAssessment__c = null;
				newHe.ANG_HE_RiskStatus__c = 'Not Applicable';

				toReturn.addAccount(newHe);

				continue;
			}

			AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(Is_Newgen_Relation__c = true, Child_Account__c = accountID , Parent_Account__c = oscarToProcess.New_parent__c, Hierarchy__c = newH.Id);
			toReturn.addRelation(rel);
			
			Account a = new Account(id = accountID, ParentId = oscarToProcess.New_parent__c, Location_Type__c = AMS_Utils.AE);

			a.ANG_IEP_HE_AccntNum__c = null;
			a.ANG_IEP_Status__c = null;
			a.ANG_HE_CashCondition__c = false;
			a.ANG_HE_RiskHistoryAssessment__c = null;
			a.ANG_HE_RiskStatus__c = null;

			toReturn.addAccount(a);
			

		}

		System.debug('[ANG_AgencyChangesHelper]- relations to create:' + toReturn.relationsMap);

		Id oldHierarchyId = null;

		// remove old relations from the hierarchy
		For(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			if(accountIdsInvolvedSet.contains(rel.Child_Account__c) || rel.Child_Account__c == oscarToProcess.Account__c){
				relationsToDelete.add(rel);
				oldHierarchyId = rel.Hierarchy__c;
			}
		}

		Integer sizeOfOldRelations = accountHierarchyRelationships.get(oscarToProcess.Account__c).size();
		Integer sizeOfDeletedRelations = relationsToDelete.size();

		System.debug('[ANG_AgencyChangesHelper] Deleting the following relations:'+ relationsToDelete);

		delete new List<AMS_Agencies_relationhip__c>(relationsToDelete);

		if(sizeOfOldRelations == sizeOfDeletedRelations && oldHierarchyId != null){

			AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c (Id = oldHierarchyId);
			delete hierarchy;
		}

		return toReturn;
	}

	public static Boolean verifyNewHierarchy(List<AMS_Agencies_relationhip__c> rels, Id targetAccount){

		for(AMS_Agencies_relationhip__c rel: rels){
			if(rel.Child_Account__c == targetAccount || rel.Parent_Account__c == targetAccount)
				return true;
		}

		return false;

	}

	public static Set<Id> fetchAccountIdsToBeProcessed(Id oscarId){

		Set<Id> toReturn = new Set<Id>();

		For(AMS_Process_Detail__c pd : [Select Id, Account__c from AMS_Process_Detail__c where OSCAR__c = :oscarId]){
			toReturn.add(pd.Account__c);
		}

		return toReturn;

	}

	public static Id fetchHierarchyFromExternalAccount(Id accountId){

		List<AMS_Agencies_relationhip__c> rels = [Select Id, Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c = :accountId];
		
		if(rels.isEmpty())
			return null;
		else
			return rels.get(0).Hierarchy__c;
	}

	public static AChangeStructure applyChangeOfFields(AMS_OSCAR__c oscarToProcess, Set<Id> accountsAffected, AChangeStructure toReturn){
		
		System.debug('[ANG_AgencyChangesHelper] Performing change of fields');

		if(toReturn == null)
			toReturn = new AChangeStructure();

        System.debug('[ANG_AgencyChangesHelper] - Types of Change (' + oscarToProcess.ANG_Type_Of_Change__c + ') ');

        Set<String> fieldsToMigrate = ANG_AgencyChangesConfigHelper.getFieldsToMigrate(oscarToProcess.ANG_Type_Of_Change__c);

        System.debug('[ANG_AgencyChangesHelper]: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + accountsAffected);

        AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = getAccreditation(oscarToProcess.AMS_Online_Accreditation__c);

        Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new  Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();
        
        Map<String, Schema.SObjectField>  acctFieldsMap= Schema.SObjectType.Account.fields.getMap();
        
        // Account Fields => AMS Pax Accreditation Fields (Staging area)
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
                                                                    ,'Link_agent_name__c' => 'Link_agent_name__c'};

        if (fieldsToMigrate != null && oscarOnlineAccreditation != null) {
                Map<String, Object> accountFieldNewValue = new Map<String,Object>();

                for (String key : fieldsMapping.keySet()) {
                    String value = fieldsMapping.get(key);
                    if (fieldsToMigrate.contains(value)) {
                    
                        accountFieldNewValue.put(key, oscarOnlineAccreditation.get(value));
                        System.debug(key + ':' + oscarOnlineAccreditation.get(value));
                    }
                }

                //fields that require transformation
                if (fieldsToMigrate.contains('ISSP_AMS_Premises_located_at_airport__c'))
                    accountFieldNewValue.put('In_a_Airport__c', (oscarOnlineAccreditation.ISSP_AMS_Premises_located_at_airport__c == 'Yes') ? true : false);
                if (fieldsToMigrate.contains('ISSP_AMS_Legal_Status__c'))
                    accountFieldNewValue.put('Company_Type__c', AMS_Utils.transformCompanyType(oscarOnlineAccreditation.ISSP_AMS_Legal_Status__c));
                if (fieldsToMigrate.contains('ISSP_AMS_GDS_with_signed_contract__c'))
                    accountFieldNewValue.put('GDS__c', AMS_Utils.transformGDS(oscarOnlineAccreditation.ISSP_AMS_GDS_with_signed_contract__c));
                if (fieldsToMigrate.contains('Branch_Office_Country__c'))
                    accountFieldNewValue.put('BillingCountry', oscarOnlineAccreditation.Branch_Office_Country__r.Name);
                if (fieldsToMigrate.contains('Shipping_ISO_Country__c'))
                    accountFieldNewValue.put('ShippingCountry', oscarOnlineAccreditation.Shipping_ISO_Country__r.Name);
                if (fieldsToMigrate.contains('Shipping_ISO_State__c'))
                    accountFieldNewValue.put('ShippingState', oscarOnlineAccreditation.IATA_ISO_State__r.Valid_for_Address__c == true ? oscarOnlineAccreditation.Shipping_ISO_State__r.Name : null);
                if (fieldsToMigrate.contains('IATA_ISO_State__c'))
                    accountFieldNewValue.put('BillingState', oscarOnlineAccreditation.IATA_ISO_State__r.Valid_for_Address__c == true ? oscarOnlineAccreditation.IATA_ISO_State__r.Name : null);

                for(Id accId: accountsAffected){

                    List<AMS_ChangeCodesHelper.ObjectChange> objectChangesList = new List <AMS_ChangeCodesHelper.ObjectChange>();

                   	Account acc = toReturn.accountsMap.get(accId) == null ? New Account(Id = accId) : toReturn.accountsMap.get(accId);

                    for(String accFieldApiName: accountFieldNewValue.keySet())
                    {
                        
                        Schema.SObjectField field = acctFieldsMap.get(accFieldApiName);
                        Schema.DisplayType fldType = field.getDescribe().getType();
                        
                        //Add Account Changes to be used when generating the Change Codes History Entities
                        
                        String newValue,oldValue,oldValueLookupID,newValueLookupID;
                        if (String.valueOf(fldType) == 'REFERENCE'){

                            oldValue = String.valueOf(AMS_Utils.processParentDependecies(accFieldApiName.replace('__c','__r.Name'),acc));
                            newValue = String.valueOf(AMS_Utils.processParentDependecies(fieldsMapping.get(accFieldApiName).replace('__c','__r.Name'),oscarOnlineAccreditation)); 
                            oldValueLookupID = String.valueOf(acc.get(accFieldApiName));
                            newValueLookupID = String.valueOf(accountFieldNewValue.get(accFieldApiName));
                            
                        }
                        else{
                       
                            oldValue = String.valueOf(acc.get(accFieldApiName));
                            newValue = String.valueOf(accountFieldNewValue.get(accFieldApiName));
                       }
                                                
                        if (oldValue != newValue)
                            objectChangesList.add(new AMS_ChangeCodesHelper.ObjectChange('Account',accFieldApiName,oldValue,newValue,oldValueLookupID,newValueLookupID));
                            

                        acc.put(accFieldApiName, accountFieldNewValue.get(accFieldApiName));
                    }

                    AMS_ChangeCodesHelper.ObjectChangesStruct acctChangesStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(objectChangesList);

                    toReturn.addAccount(acc);
                    accountsToUpdate.put(acc.Id,acctChangesStruct);
                }

        }

        toReturn.addChangesStruct(accountsToUpdate);

    	return toReturn;

	}

	
	public static boolean validateTypeOfChange(AMS_OSCAR__c oscar, List<Map<String, String>> configs) {

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		List<String> oscarStepsApiName = AMS_Utils.getOSCARStepsApiName();

		if (oscar.ANG_Type_Of_Change__c <> oldMap.get(oscar.Id).ANG_Type_Of_Change__c && oldMap.get(oscar.Id).STEP6__c == AMS_Utils.PASSED)
		{
			oscar.addError('Type of Change cannot be changed after Sanity Check is passed.');
			return false;
		}

		if (oscar.ANG_Type_Of_Change__c <> oldMap.get(oscar.Id).ANG_Type_Of_Change__c || oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {
			AMS_Utils.AgChangesConfig config = ANG_AgencyChangesConfigHelper.getSelectedTypeOfChangeCombinationConfig(oscar, configs);
			if (config != null && config.config != null) {
				List<String> notApplicableSteps = ANG_AgencyChangesConfigHelper.getNotApplicableSteps(config.config);
				if (notApplicableSteps != null)
					ANG_AgencyChangesConfigHelper.setNotApplicableSteps(notApplicableSteps, oscarStepsApiName, oscar);
			}
			else{
				return false;
			}
		}

		return true;
		
	}

	public static ANG_AgencyChangesHelper.AChangeStructure generateNewGenChangeCodes(AMS_OSCAR__c oscar, AMS_Utils.AgChangesConfig config, Map<Id, Agency_Applied_Change_code__c> accountsPrevChangeCode, String action, Set<Id> allHierarchyAccountsToApplyCC, ANG_AgencyChangesHelper.AChangeStructure changesContainer) {

        List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
        List<Account> accts = new List<Account>();

        AMS_OSCAR_JSON.ChangeCode changeCodeDef;
        Agency_Applied_Change_code__c changeCode;
        String changeCodeIdentifier;


        if (action == AMS_Utils.SANITYCHECK)
            changeCodeIdentifier = ANG_AgencyChangesConfigHelper.getSanityCheckChangeCode(config.config);
        else if (action == AMS_Utils.APPROVAL)
            changeCodeIdentifier = ANG_AgencyChangesConfigHelper.getManagerApprovalChangeCode(config.config);
        else if (action == AMS_Utils.WITHDRAWAL)
            changeCodeIdentifier = ANG_AgencyChangesConfigHelper.getWithdrawalChangeCode(config.config);

        system.debug('AGENCY CHANGES: Change code to apply: ' + changeCodeIdentifier);
        if (changeCodeIdentifier != null) {

            for (Id acc : allHierarchyAccountsToApplyCC) {
                
                Account accToUpdateStatus = changesContainer.accountsMap.get(acc);

                if (accToUpdateStatus != null) {
                    changeCodeDef = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeIdentifier, config.typesOfChange, accToUpdateStatus.Status__c, accountsPrevChangeCode.get(accToUpdateStatus.Id), action);
                    changeCode = createChangeCode(changeCodeDef, oscar, acc);

                    changesContainer.addChangeCode(changeCode);
                    
                    accToUpdateStatus.Status__c = changeCodeDef.status;
                    changesContainer.accountsMap.put(accToUpdateStatus.Id, accToUpdateStatus);
                }
            }

        }

        system.debug('AGENCY CHANGES: changeCodes: ' + changeCodes);
        system.debug('AGENCY CHANGES: Accounts: ' + accts);

        return changesContainer;
    }

    public static Agency_Applied_Change_code__c createChangeCode(AMS_OSCAR_JSON.ChangeCode chaneCodeDefinition, AMS_OSCAR__c oscar, Id accId){

    	String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

        Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(
            Active__c = true
            , Account__c = accId
            , Change_Code__c = chaneCodeDefinition.name
            , OSCAR__c = oscar.Id
            , Bulletin_Information__c = (chaneCodeDefinition.memoText == null) ? '' : chaneCodeDefinition.memoText.toUpperCase()
            , Reason_Code__c = chaneCodeDefinition.reasonCode
            , Reason_Description__c = chaneCodeDefinition.reasonDesc
            , Source__c = source
            , CreatedDate_User__c = convertToHubEffectiveDate(system.today())
            //, To_Publish_in_e_Bulletin__c = changeCode.publishedOnEBulletin
        );

        return aacNEW;

    }

    private static string convertToHubEffectiveDate(datetime dValue){
        if(dValue==null) return '';
        list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
        return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
    }

    private static AMS_Pax_Accreditation_Form__c getAccreditation(Id oscarOnlineAccredId){
		return [SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
		        ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
		        Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
		        Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
		        Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
		        Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, IATA_ISO_State__r.Valid_for_Address__c   
		        FROM AMS_Pax_Accreditation_Form__c
		        WHERE Id =: oscarOnlineAccredId limit 1];
	}

}