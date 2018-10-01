public with sharing class ANG_AgencyChangesHelper {

	public static Boolean testRunnningForNonBackup = false;
	public static Boolean isMigrationRunning = false;

	public class AChangeStructure{

		public Map<Id,AMS_Agencies_relationhip__c> relationsMap;
		public Map<Id,Account> accountsMap;
		public Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> changesStruct;
		public List<Agency_Applied_Change_code__c> changeCodesToCreate;
		public List<AMS_OSCAR_JSON.ChangeCode> changeCodesToCreateDef;
		public List<Account> accountsToApplyChangeCodes;

		public Set<Id> accountsChanged;

		public AChangeStructure(){

			relationsMap = new Map<Id, AMS_Agencies_relationhip__c>();
			accountsMap = new Map<Id, Account>();
			changeCodesToCreate = new List<Agency_Applied_Change_code__c>();
			changeCodesToCreateDef = new List<AMS_OSCAR_JSON.ChangeCode>();
			accountsChanged = new Set<Id>();
			changesStruct = new Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();
			accountsToApplyChangeCodes = new List<Account>();
		}

		public void addAccount(Account account){
			this.accountsMap.put(account.Id, account);
			this.accountsChanged.add(account.Id);
		}

		public void addRelation(AMS_Agencies_relationhip__c relation){
			this.relationsMap.put(relation.Child_Account__c, relation);
		}

		public void addChangeCode(Agency_Applied_Change_code__c changeCode){
			this.changeCodesToCreate.add(changeCode);
		}

		public void addChangeCodeDef(AMS_OSCAR_JSON.ChangeCode changeCodeDef, Account acc){
			this.changeCodesToCreateDef.add(changeCodeDef);
			this.accountsToApplyChangeCodes.add(acc);
		}

		public Boolean runUpsert(){

			System.debug('[ANG_AgencyChangesHelper] Running upsert');

			Boolean hasUpserted = false;

			AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = true;

			if(relationsMap != null && !relationsMap.isEmpty()){
				System.debug('[ANG_AgencyChangesHelper] Upserting following relations:'+relationsMap);
				upsert relationsMap.values();
				hasUpserted = true;
			}


			if(accountsMap != null && !accountsMap.isEmpty() && !accountsChanged.isEmpty()){

				List<Account> toUpsert = new List<Account>();					

				for(Id accountId: accountsChanged){
					if(accountsMap.get(accountID) != null)
						toUpsert.add(accountsMap.get(accountID));		
				}

				if(!toUpsert.isEmpty()){
					System.debug('[ANG_AgencyChangesHelper] Upserting following accounts:'+toUpsert);
					upsert toUpsert;
					hasUpserted = true;
				}
			}

        	/*if(changeCodesToCreate != null && !changeCodesToCreate.isEmpty()){
				System.debug('[ANG_AgencyChangesHelper] Creating following change codes:'+changeCodesToCreate);
        		insert changeCodesToCreate;
				hasUpserted = true;
        	}*/

			AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = false;

			System.debug('[ANG_AgencyChangesHelper] Upsert has run.');

			return hasUpserted;
		}

		public void addChangesStruct(Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> changesStruct){
			this.changesStruct = changesStruct;
		}

	}

	public static void handleNewGenChangesProcess(List<AMS_Oscar__c> oscars){

		ANG_AgencyChangesConfigHelper.ChangesConfig config = null;

		AMS_OSCAR__c oscar = oscars[0];

		if((oscar.Process__c == AMS_Utils.NGCHANGES || oscar.Process__c == AMS_Utils.NGCORRECTION) && oscar.STEP6__c == AMS_Utils.PASSED && ((Map<Id,AMS_OSCAR__c>)Trigger.oldMap).get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.ANG_Type_Of_Change__c == null && !isMigrationRunning){
			oscar.addError('Cannot pass Sanity Check before choosing a type of change.');
			return;
		}
	

		if(oscar.Process__c == AMS_Utils.NGCHANGES && oscar.STEP6__c == AMS_Utils.PASSED  && oscar.ANG_Type_Of_Change__c != null && !isMigrationRunning && oscar.Backup_In_Progress__c){	
				oscar.addError('There is a backup in progress for this Oscar, please wait a few moments until it finishes.');
				return;
		}

		if(oscar.Process__c == AMS_Utils.NGCHANGES && oscar.STEP6__c != AMS_Utils.PASSED && oscar.Change_effective_as_of__c > Date.today()) {
			system.debug('oscar status before: '+ oscar.Status__c);
			oscar.Status__c = 'Accepted_Future Date';
			system.debug('oscar status after: '+ oscar.Status__c);
		}

		if((oscar.Process__c == AMS_Utils.NGCHANGES || oscar.Process__c == AMS_Utils.NGCORRECTION) && oscar.ANG_Type_Of_Change__c != null){

			System.debug('[ANG_AgencyChangesHelper][handleNewGenChangesProcess] -- PROCESSING agency changes');


			Boolean isAllHierarchySelected = false;
			Boolean oscarHierFAOptOut;
			Set<Id> accountHierarchyRelationships = new Set<Id>();

			AChangeStructure changesContainer = new AChangeStructure();

			System.debug('[ANG_AgencyChangesHelper][handleNewGenChangesProcess] -- types of changes selected are valid!');

			AMS_OSCAR__c oldOSCAR = (AMS_OSCAR__c)Trigger.oldMap.get(oscar.Id);

			Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
			accountIdsInvolvedSet.add(oscar.Account__c);

			changesContainer.accountsMap = getAccounts(accountIdsInvolvedSet);

			String currHEAccount = changesContainer.accountsMap.get(oscar.Account__c).ParentId == null ? oscar.Account__c : changesContainer.accountsMap.get(oscar.Account__c).ParentId;

			AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = getAccreditation(oscar.AMS_Online_Accreditation__c);

			//map accountId -> active change code
			Map<Id, Agency_Applied_Change_code__c> accountsCurrentChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

			Set<Id> accountIdsInvolvedSetAux = new Set<Id>();
			accountIdsInvolvedSetAux.addAll(accountIdsInvolvedSet);

			if(changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c != null)
				accountIdsInvolvedSetAux.add(changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c);

			for (Agency_Applied_Change_code__c changeCode : [SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c FROM Agency_Applied_Change_code__c WHERE Account__c IN :accountIdsInvolvedSetAux AND Active__c = true])
				accountsCurrentChangeCode.put(changeCode.Account__c, changeCode);

			if (oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {

                if(!validateTypeOfChange(oscar))
                    return;
                    
				if(!sanityCheckValidations(oscar, changesContainer, oscarOnlineAccreditation))
					return;

				changesContainer = applyChangeOfFields(oscar, accountIdsInvolvedSet, changesContainer, oscarOnlineAccreditation);

				System.debug('[ANG_AgencyChangesHelper] changesContainer are:'+changesContainer);
				System.debug('[ANG_AgencyChangesHelper] Checkpoint1 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);

				//if(Pattern.matches(AMS_Utils.ANG_ACCREDITATION_TYPE, oscar.ANG_Type_Of_Change__c))				
				if(containsChange(New List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE},oscar.ANG_Type_Of_Change__c))
					changesContainer = applyChangeOfAccreditationType(oscar, accountIdsInvolvedSet, changesContainer);
					
				//Set default value as "Not Applicable" 	
				oscar.ANG_FA_Opt_out__c = 'Not Applicable';				

				//if(Pattern.matches(AMS_Utils.ANG_LOCATION_TYPE + '|' + AMS_Utils.ANG_HIERARCHY, oscar.ANG_Type_Of_Change__c))
				if(containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE,AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY, AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){
					
					Map<Id, List<AMS_Agencies_relationhip__c>> allRelationsOnHierarchy = null;

					if(containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){

						allRelationsOnHierarchy = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c});

						accountHierarchyRelationships = extractAllAccounts(allRelationsOnHierarchy);
						accountHierarchyRelationships.add(oscar.Account__c);
                		isAllHierarchySelected = isAllHierarchySelected(oscar,accountHierarchyRelationships);
                        System.debug('[ANG_AgencyChangesHelper] isAllHierarchySelected is set to:'+isAllHierarchySelected);
					}
					
					changesContainer = processHierarchyChangesAux(oscar, changesContainer, accountIdsInvolvedSet, isAllHierarchySelected,allRelationsOnHierarchy);


				}

				//if(Pattern.matches(AMS_Utils.ANG_OWNERSHIP + '|' + AMS_Utils.ANG_MINOR_SHAREHOLDING + '|' + AMS_Utils.ANG_MAJOR_SHAREHOLDING, oscar.ANG_Type_Of_Change__c))
				if(containsChange(New List<String>{AMS_Utils.ANG_OWNERSHIP, AMS_Utils.ANG_MINOR_SHAREHOLDING, AMS_Utils.ANG_MAJOR_SHAREHOLDING},oscar.ANG_Type_Of_Change__c))
					changesContainer = applyChangeOfOwnership(oscar, accountIdsInvolvedSet, changesContainer, true);

				if(oscar.Process__c == AMS_Utils.NGCHANGES){
					
					if(config == null) config = ANG_AgencyChangesConfigHelper.getConfig(oscar);

					if(containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE},oscar.ANG_Type_Of_Change__c))
						changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.SANITYCHECK, accountIdsInvolvedSetAux, changesContainer);
					else
						changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.SANITYCHECK, accountIdsInvolvedSet, changesContainer);
					
					System.debug('[ANG_AgencyChangesHelper] Checkpoint2 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);

					System.debug('[ANG_AgencyChangesHelper] Starting Risk Actions');

					performRiskEventActions(oscar,currHEAccount,isAllHierarchySelected);

					if (changesContainer.accountsMap.get(oscar.Account__c).IATA_ISO_Country__r.Due_diligence_mandatory__c && oscar.STEP17__c != AMS_Utils.NOT_APPLICABLE && 
						oscar.Type_of_change__c != AMS_Utils.ANG_LOCATION) {

                        if(changesContainer.accountsMap.get(oscar.Account__c).Due_Diligence_Status__c == AMS_Utils.IN_PROGRESS) oscar.STEP17__c = AMS_Utils.IN_PROGRESS;
                        else{
                            String dlResult = AMS_OSCAR_Webservice.createAMLCaseWithNoOscarUpdate(oscar);
                            if (dlResult.startsWith('ERROR')) oscar.addError(dlResult);
                            else changesContainer.accountsMap.get(oscar.Account__c).Due_Diligence_Status__c = AMS_Utils.IN_PROGRESS;
                        }
                    }

					System.debug('[ANG_AgencyChangesHelper] Risk Actions Ended');
				}

				if(oscar.Process__c == AMS_Utils.NGCORRECTION){

					List<Account> accountsToUpdate = new List<Account>();

					if (!new Set<String>{'COR','CAD','LET'}.contains(oscar.AMS_Correction_change_code__c))
						oscar.addError('To pass sanity check a correction change code is required.');

					if(oscar.AMS_Correction_change_code__c == 'COR' || oscar.AMS_Correction_change_code__c == 'CAD'){
						AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

						changeCode.status  = null;

						if(oscar.AMS_Correction_change_code__c == 'COR') {
							changeCode.name = 'COR';
							changeCode.memoText = 'Correction';
							changeCode.publishedOnEBulletin = false;
						}
						else if(oscar.AMS_Correction_change_code__c == 'CAD'){
							changeCode.name = 'CAD';
							changeCode.memoText = 'Minor Changes';
						}

						List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c,Account__r.Status__c FROM Agency_Applied_Change_code__c WHERE Account__c =: oscar.Account__c AND Active__c = TRUE];

						if(accountActiveChangeCode.size() > 0){
							changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
							changeCode.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
							changeCode.status = AMS_Utils.getIATANumericStatus(accountActiveChangeCode[0].Account__r.Status__c);
						}

						//changesContainer = ANGcreateAAChangeCodes(null,new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {oscar}, new List<Id> (accountIdsInvolvedSet), false, changesContainer);
						changesContainer.accountsToApplyChangeCodes.add(changesContainer.accountsMap.get(oscar.Account__c));
						changesContainer.changeCodesToCreateDef.add(changeCode);				
					}

					if(oscar.AMS_Correction_change_code__c == 'LET') {

						AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

						changeCode.name = 'LET';
						changeCode.reasonCode = '91';
						changeCode.memoText = '';
						changeCode.reasonDesc  = 'ACCREDITED-MEETS-STANDARDS';
						changeCode.status  = '9';

						//changesContainer = ANGcreateAAChangeCodes(null,new List<AMS_OSCAR_JSON.ChangeCode> {changeCode}, new List<AMS_OSCAR__c> {oscar}, new List<Id> (accountIdsInvolvedSet), false, changesContainer);
						changesContainer.accountsToApplyChangeCodes.add(changesContainer.accountsMap.get(oscar.Account__c));
						changesContainer.changeCodesToCreateDef.add(changeCode);	
					}

					if(oscar.Is_PCI_compliant__c == 'Corporate Card'){
                    	Date dt = Date.newInstance(2099, 12, 31);

                    	for (Id accId : accountIdsInvolvedSet){

	                    	if (changesContainer.accountsMap.get(accId) == null){
	                    		changesContainer.addAccount(new Account(Id = accId, ANG_PCI_compliance_expiry_date__c = dt));
	                    	}else{
	                    		changesContainer.accountsMap.get(accId).ANG_PCI_compliance_expiry_date__c = dt;
	                    	}
	                    }
                    }

				}

			}else if (oldOSCAR.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL) {

				Map<Id,Account> hierarchyAccs;

				if(config == null)
					config = ANG_AgencyChangesConfigHelper.getConfig(oscar);

				changesContainer = applyChangeOfFields(oscar, accountIdsInvolvedSet, changesContainer, oscarOnlineAccreditation);

				changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.APPROVAL, accountIdsInvolvedSet, changesContainer);

				if (containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)) {

					hierarchyAccs = new Map<Id,Account>([SELECT Id, ANG_FA_Opt_out__c, CNS_Agency__c FROM Account WHERE Id = :oscar.New_parent__c OR Top_Parent__c = :oscar.New_parent__c]);
					
					// If opt-out is not applicable we'll put the value of the new parent
					if(oscar.ANG_FA_Opt_out__c == 'Not Applicable'){ 

						Account newParent;
						if (changesContainer.accountsMap.keySet().contains(oscar.New_Parent__c))
							newParent = changesContainer.accountsMap.get(oscar.New_Parent__c);
							
						else
							newParent = hierarchyAccs.get(oscar.New_parent__c);

						changesContainer = applyFAOptOut(oscar, changesContainer, hierarchyAccs.values(), newParent.ANG_FA_Opt_out__c == null ? false : newParent.ANG_FA_Opt_out__c);
					
					//else we'll get the value input on the oscar AND apply it to all the accounts involved + the new parent's entire hierarchy
					}else { 
						changesContainer = applyFAOptOut(oscar, changesContainer, hierarchyAccs.values(), null);					
					}

				//NEWGEN-1088 apply FA opt-out = false when changing to cash or to cashless
				} else if (containsChange(New List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE},oscar.ANG_Type_Of_Change__c)) {

	    			changesContainer= applyFAOptOut(oscar, changesContainer, changesContainer.accountsMap.values(), FALSE);
	    		
	    		//all other major changes
				}else if (oscar.ANG_FA_Opt_out__c == 'Opt-Out' || oscar.ANG_FA_Opt_out__c == 'Opt-In' && containsChange(new List<String>(AMS_Utils.ANG_OSCAR_MAJOR_CHANGES_PROCESSES), oscar.ANG_Type_Of_Change__c)){

					String hierTopParent = changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c == null ? changesContainer.accountsMap.get(oscar.Account__c).Id : changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c;
					hierarchyAccs = new Map<Id,Account>([SELECT Id, ANG_FA_Opt_out__c, CNS_Agency__c FROM Account WHERE Id = :hierTopParent OR Top_Parent__c = :hierTopParent]);

					changesContainer = applyFAOptOut(oscar, changesContainer, hierarchyAccs.values(), null);
				}				

			} else if (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) {

				if(config == null)
					config = ANG_AgencyChangesConfigHelper.getConfig(oscar);

				changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.WITHDRAWAL, accountIdsInvolvedSet, changesContainer);

			}else if (!oldOSCAR.Apply_Penalty_Fee__c && oscar.Apply_Penalty_Fee__c) {

				changesContainer = generateLNFChangeCode(oscar, accountsCurrentChangeCode, changesContainer);
			
			}else if(oldOSCAR.Status__c != AMS_Utils.OSCAR_CLOSED && oscar.Status__c == AMS_Utils.OSCAR_CLOSED){

				if(config == null)
					config = ANG_AgencyChangesConfigHelper.getConfig(oscar);

				validationBeforeClosure(oscar);

			}

			System.debug('[ANG_AgencyChangesHelper] Checkpoint5 changesCodes are:'+ changesContainer.changeCodesToCreateDef);
			System.debug('[ANG_AgencyChangesHelper] Checkpoint6 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);
			if(changesContainer.changesStruct != null)
				changesContainer = ANGcreateAAChangeCodes(changesContainer.changesStruct.values(), changesContainer.changeCodesToCreateDef, new List<AMS_OSCAR__c> {oscar}, changesContainer.accountsToApplyChangeCodes, false, changesContainer);

			System.debug('[ANG_AgencyChangesHelper] Checkpoint4 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);

			if(changesContainer != null){

				changesContainer.runUpsert();

			}

		}

	}

	public static void performRiskEventActions(AMS_OSCAR__c oscar, String oldParentHierarchyId, Boolean isAllHierarchySelected){
		    
		if(containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY,AMS_Utils.ANG_LOCATION_TYPE},oscar.ANG_Type_Of_Change__c))
            System.enqueueJob(new ANG_Risk_Helper.FutureHandler(new Map<Id,Id>{oldParentHierarchyId => oscar.Account__c}));
		
		if(containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c) && isAllHierarchySelected)
            System.enqueueJob(new ANG_Risk_Helper.FutureHandler([SELECT Id FROM ANG_Agency_Risk_Event__c WHERE ANG_HE_AccountId__c = :oldParentHierarchyId]));
        
    }

	public static boolean isAllHierarchySelected(AMS_OSCAR__c oscar, Set<Id> accountHierarchyRelationships){


		Set<Id> allAccountsInvolved = fetchAccountIdsToBeProcessed(oscar.Id);
		allAccountsInvolved.add(oscar.Account__c);
        
        System.debug('[ANG_AgencyChangesHelper.isAllHierarchySelected] allAccountsInvolved are ' + allAccountsInvolved);
        System.debug('[ANG_AgencyChangesHelper.isAllHierarchySelected] accountHierarchyRelationships are ' + accountHierarchyRelationships);

		return allAccountsInvolved.containsAll(accountHierarchyRelationships);

	}


	public static boolean containsChange(List<String> changesAllowed, String changesSelected){
		
		if(changesSelected != null){
			List<String> splitChangesList= new List<String>(changesSelected.split(';'));

			Set<String> changesAllowedSet = new Set<String>(changesAllowed);

			For(String change: splitChangesList){
				if(changesAllowedSet.contains(change))
					return true;
			}
		}

		return false;
	}

	public static AChangeStructure processHierarchyChanges(AMS_OSCAR__c oscar, AChangeStructure changesContainer, Set<Id> accountIdsInvolvedSet, Boolean isAllHierarchySelected) {
		return processHierarchyChangesAux(oscar, changesContainer, accountIdsInvolvedSet, isAllHierarchySelected, null);
	}

	public static AChangeStructure processHierarchyChangesAux(AMS_OSCAR__c oscar, AChangeStructure changesContainer, Set<Id> accountIdsInvolvedSet, Boolean isAllHierarchySelected, Map<Id, List<AMS_Agencies_relationhip__c>> allRelations) {
		
        System.debug('[ANG_AgencyChangesHelper] - Accounts involved are:'+accountIdsInvolvedSet);
        System.debug('[ANG_AgencyChangesHelper] - ChangesContainer is'+changesContainer);
        System.debug('[ANG_AgencyChangesHelper] - isAllHierarchySelected is'+isAllHierarchySelected);

		if (containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE, AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY},oscar.ANG_Type_Of_Change__c))
			changesContainer = applyChangeOfLocationType(oscar, changesContainer,allRelations);
		else if (containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){
		
			changesContainer = applyChangeOfHierarchy(oscar, changesContainer, accountIdsInvolvedSet, isAllHierarchySelected);
		
			//For the Change Of Hierarchy (HE Included), we need to take care of the hidden accounts 
			//(with Status terminated, "Terminated", "Not accreditated","New application pending" and "Not in Operation") and disconnect them from their parent

			if(isAllHierarchySelected){
				changesContainer = detachTerminatedAccountsFromHierarchy(allRelations,changesContainer);
			}
		
		}

		
		return changesContainer;
	}

	public static AChangeStructure  detachTerminatedAccountsFromHierarchy(Map<Id, List<AMS_Agencies_relationhip__c>> allRelations, AChangeStructure toReturn){

		Set<String> terminatedStatus = new Set <String>{AMS_Utils.ACC_S0_TERMINATED, AMS_Utils.ACC_S1_NOTACCREDITED, AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING, AMS_Utils.ACC_S3_NOTINOPERATION, ''};
		
		List<AMS_Agencies_relationhip__c> relToDelete = new List<AMS_Agencies_relationhip__c>();

		for(List<AMS_Agencies_relationhip__c> rels: allRelations.values()){
			for(AMS_Agencies_relationhip__c rel:rels){
				
				if(terminatedStatus.contains(rel.Child_Account__r.Status__c)){
					
					Account childAccount = toReturn.accountsMap.get(rel.Child_Account__c) != null ?  toReturn.accountsMap.get(rel.Child_Account__c) : new Account(Id = rel.Child_Account__c);

					childAccount.ParentId = null;
					childAccount.Top_Parent__c = null;

					toReturn.addAccount(childAccount);

					relToDelete.add(rel);
				}
			
			}
		}

		if(!relToDelete.isEmpty())
			delete relToDelete;

		return toReturn;

	}

	public static AChangeStructure applyChangeOfLocationType(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){

		// 1) need to fetch all the relations on the hierarchy
		// 2) need to fetch all the accounts involved in this "swap"
		// 3) need to change all the relations in the hierarchy to apply the new Parent
		// 4) need to change all the parent accounts and the location type of all agencies involved
		// 5) swap IEP information between old and new HE.

		System.debug('[ANG_AgencyChangesHelper] Performing change of Location Type');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		if(accountHierarchyRelationships == null)
			accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});

		for(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			if(rel.Child_Account__c == oscarToProcess.Account__c){
				
				Account parentAccount = [Select Id, Location_Type__c, ParentId, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, Financial_Review_Result__c, CNS_Agency__c, (SELECT Id, ANG_AccountId__c FROM RHC_Informations__r) From Account where Id =:rel.Parent_Account__c];

				parentAccount.Location_Type__c = AMS_Utils.AE;
				parentAccount.ParentId = oscarToProcess.Account__c;
				parentAccount.Top_Parent__c = oscarToProcess.Account__c;

				Account childAccount = toReturn.accountsMap.get(rel.Child_Account__c) != null ?  toReturn.accountsMap.get(rel.Child_Account__c) : new Account(Id = rel.Child_Account__c);

				childAccount.Location_Type__c = AMS_Utils.HE;
				childAccount.ParentId = null;
				childAccount.ANG_IEP_HE_AccntNum__c = parentAccount.ANG_IEP_HE_AccntNum__c;
				childAccount.ANG_IEP_Status__c = parentAccount.ANG_IEP_Status__c;
				childAccount.ANG_HE_CashCondition__c = parentAccount.ANG_HE_CashCondition__c;
				childAccount.ANG_HE_RiskHistoryAssessment__c = parentAccount.ANG_HE_RiskHistoryAssessment__c;
				childAccount.ANG_HE_RiskStatus__c = parentAccount.ANG_HE_RiskStatus__c;
				childAccount.Financial_Review_Result__c = parentAccount.Financial_Review_Result__c;
				childAccount.Top_Parent__c = null;

				parentAccount.ANG_IEP_HE_AccntNum__c = null;
				parentAccount.ANG_IEP_Status__c = null;
				parentAccount.ANG_HE_CashCondition__c = false;
				parentAccount.ANG_HE_RiskHistoryAssessment__c = null;
				parentAccount.ANG_HE_RiskStatus__c = null;

				rel.Child_Account__c = rel.Parent_Account__c;

				toReturn.addAccount(parentAccount);
				toReturn.addAccount(childAccount);

				ANG_RHCHelper.moveRHCInfos(parentAccount.RHC_Informations__r, new Map<Id,Id>{rel.Child_Account__c => oscarToProcess.Account__C});

			} else{

				Account relAccount = toReturn.accountsMap.get(rel.Child_Account__c) != null ? toReturn.accountsMap.get(rel.Child_Account__c) : new Account(Id = rel.Child_Account__c);

				relAccount.Top_Parent__c = oscarToProcess.Account__c;
				relAccount.ParentId = oscarToProcess.Account__c;

				toReturn.addAccount(relAccount);

			}

			rel.Parent_Account__c = oscarToProcess.Account__c;
			toReturn.addRelation(rel);

		}

		return toReturn;

	}

	public static AChangeStructure applyChangeOfHierarchy(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Set<Id> accountIdsInvolvedSet, Boolean isAllHierarchySelected){

		System.debug('[ANG_AgencyChangesHelper] Performing change of Hierarchy');

		String newAccreditationModel = '';
		String newRemittanceFrequency = '';
		Boolean switchAccreditationModel = false;
		Boolean switchRemittanceFrequency = false;
		Boolean doesItContainAccreditationType = containsChange(New List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE},oscarToProcess.ANG_Type_Of_Change__c);
		Set<Id> accountsAffected = new Set<Id>();

		System.debug('[ANG_AgencyChangesHelper] - doesItContainAccreditationType is set to ' + doesItContainAccreditationType);

		if(toReturn == null)
			toReturn = new AChangeStructure();

		/*
			New parent = external HE
			The selected agencies will be transformed into AE and linked to the new paren, therefore they will automatically get the Accreditation type "XXX"
		*/
		if((!accountIdsInvolvedSet.contains(oscarToProcess.New_parent__c) && oscarToProcess.Account__c != oscarToProcess.New_parent__c)){

			//Map<Id,Account> accountsMap;

			Account newHEaccount = toReturn.accountsMap.get(oscarToProcess.New_parent__c);

			if(newHEaccount == null)
				newHEaccount = [Select Id , ANG_Accreditation_Model__c, Remittance_frequency__c, CNS_Agency__c from Account where Id = :oscarToProcess.New_parent__c];

			Account oscarAccount = toReturn.accountsMap.get(oscarToProcess.Account__c);

			if(oscarAccount == null)
				oscarAccount = [Select Id , ANG_Accreditation_Model__c, Remittance_frequency__c, CNS_Agency__c from Account where Id = :oscarToProcess.Account__c];

			if(!doesItContainAccreditationType && newHEaccount.ANG_Accreditation_Model__c != oscarAccount.ANG_Accreditation_Model__c){

				switchAccreditationModel = true;
				newAccreditationModel = newHEaccount.ANG_Accreditation_Model__c;

			}

			if(newHEaccount.Remittance_frequency__c != oscarAccount.Remittance_frequency__c){

				switchRemittanceFrequency = true;
				newRemittanceFrequency = newHEaccount.Remittance_frequency__c;
			}
		}

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

			Account oscarAccount = toReturn.accountsMap.get(oscarToProcess.Account__c) != null ? toReturn.accountsMap.get(oscarToProcess.Account__c) : new Account(Id = oscarToProcess.Account__c);
			oscarAccount.Location_Type__c = AMS_Utils.AE;
			oscarAccount.ParentId = oscarToProcess.New_parent__c;
			oscarAccount.Top_Parent__c = oscarToProcess.New_parent__c;
			oscarAccount.ANG_IEP_HE_AccntNum__c = null;
			oscarAccount.ANG_IEP_Status__c = null;
			oscarAccount.ANG_HE_CashCondition__c = false;
			oscarAccount.ANG_HE_RiskHistoryAssessment__c = null;
			oscarAccount.ANG_HE_RiskStatus__c = null;

			if(switchAccreditationModel){
				oscarAccount.ANG_Accreditation_Model__c = newAccreditationModel;
				accountsAffected.add(oscarToProcess.Account__c);
			}

			if(switchRemittanceFrequency){
				oscarAccount.Remittance_frequency__c = newRemittanceFrequency;
			}


			toReturn.addAccount(oscarAccount);

			AMS_Agencies_relationhip__c newRel = new AMS_Agencies_relationhip__c();
			newRel.Parent_Account__c = oscarToProcess.New_parent__c;
			newRel.Child_Account__c = oscarToProcess.Account__c;
			newRel.Is_Newgen_Relation__c = true;
			newRel.Hierarchy__c = hierarchyId;

			toReturn.addRelation(newRel);

			if(switchAccreditationModel){

				System.debug('[ANG_AgencyChangesHelper] Switching Accreditation Models');

				List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

				if(newAccreditationModel ==  'Cashless'){
					toUpsert = performCashLessTransformation(accountsAffected);
					removeContactsFlag(accountsAffected); 

                    for(Id accountId: accountsAffected)
						if(toReturn.accountsMap.get(accountId) != null)
    	                    toReturn.accountsMap.get(accountId).Has_a_Financial_Assessment_Contact__c = false;

				}
				if(newAccreditationModel ==  'Cash')
					toUpsert = performCashTransformation(accountsAffected);

				if(!toUpsert.isEmpty())
					upsert toUpsert;
			}

			ANG_RHCHelper.deactivateRHCInfo(new Set<Id>{oscarToProcess.Account__c});

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

				Account newHe = toReturn.accountsMap.get(oscarToProcess.New_parent__c) != null ? toReturn.accountsMap.get(oscarToProcess.New_parent__c) : new Account(Id = oscarToProcess.New_parent__c);
				newHe.Location_Type__c = AMS_Utils.HE;
				newHe.ParentId = null;
				newHe.Top_Parent__c = null;
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

			Account a = toReturn.accountsMap.get(accountID) != null ? toReturn.accountsMap.get(accountID) : new Account(id = accountID);

			a.Top_Parent__c = oscarToProcess.New_parent__c;
			a.ParentId = oscarToProcess.New_parent__c;
			a.Location_Type__c = AMS_Utils.AE;
			a.ANG_IEP_HE_AccntNum__c = null;
			a.ANG_IEP_Status__c = null;
			a.ANG_HE_CashCondition__c = false;
			a.ANG_HE_RiskHistoryAssessment__c = null;
			a.ANG_HE_RiskStatus__c = null;

			if(switchAccreditationModel){
				a.ANG_Accreditation_Model__c = newAccreditationModel;
				accountsAffected.add(accountID);
			}

			if(switchRemittanceFrequency){
				a.Remittance_frequency__c = newRemittanceFrequency;
			}

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

		if(switchAccreditationModel){

			System.debug('[ANG_AgencyChangesHelper] Switching Accreditation Models');

			List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

			if(newAccreditationModel ==  'Cashless'){
				toUpsert = performCashLessTransformation(accountsAffected);

				removeContactsFlag(accountsAffected);

                for(Id accountId: accountsAffected)
					if(toReturn.accountsMap.get(accountId) != null)
	                    toReturn.accountsMap.get(accountId).Has_a_Financial_Assessment_Contact__c = false;

			}

			if(newAccreditationModel ==  'Cash')
				toUpsert = performCashTransformation(accountsAffected);

            if(!toUpsert.isEmpty()){

				upsert toUpsert;

            }
		}

		//Perform changes on RHC object

		//Moving to external HE
		if(!accountIdsInvolvedSet.contains(oscarToProcess.New_parent__c)){
			if(isAllHierarchySelected) ANG_RHCHelper.deactivateRHCInfo(accountIdsInvolvedSet);
			// if the hierarchy is not entirely selected, it means we are only moving AEs and nothing needs to be done
		}else{ //moving part of the hierarchy to a new AE (no need to sum fs because no FS existis)
			ANG_RHCHelper.createRHCInfo(new List<Account>{toReturn.accountsMap.get(oscarToProcess.New_Parent__c)}, false);
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

	public static AChangeStructure applyChangeOfFields(AMS_OSCAR__c oscarToProcess, Set<Id> accountsAffected, AChangeStructure toReturn, AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation){

		System.debug('[ANG_AgencyChangesHelper] Performing change of fields');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		System.debug('[ANG_AgencyChangesHelper] - Types of Change (' + oscarToProcess.ANG_Type_Of_Change__c + ') ');

		Set<String> fieldsToMigrate = ANG_AgencyChangesConfigHelper.getFieldsToMigrate(oscarToProcess.ANG_Type_Of_Change__c);

		System.debug('[ANG_AgencyChangesHelper]: fields to migrate (' + fieldsToMigrate + ') for accounts: ' + accountsAffected);

		//Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> accountsToUpdate = new  Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();

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
		,'Link_agent_name__c' => 'Link_agent_name__c'
		,'ANG_Accreditation_Model__c' => 'ANG_Accreditation_type__c'};

		if (fieldsToMigrate != null && oscarOnlineAccreditation != null) {
			Map<String, Object> accountFieldNewValue = new Map<String,Object>();

			for (String key : fieldsMapping.keySet()) {
				String value = fieldsMapping.get(key);
				if (fieldsToMigrate.contains(value)) {

					accountFieldNewValue.put(key, oscarOnlineAccreditation.get(value));
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


                if(oscarToProcess.Process__c ==  AMS_Utils.NGCORRECTION && oscarToProcess.Is_PCI_compliant__c != acc.Is_PCI_compliant__c){
                    acc.Is_PCI_compliant__c = oscarToProcess.Is_PCI_compliant__c;
                }

                if(oscarToProcess.Process__c ==  AMS_Utils.NGCORRECTION && oscarToProcess.ANG_PCI_compliance_expiry_date__c != acc.ANG_PCI_compliance_expiry_date__c){
                    acc.ANG_PCI_compliance_expiry_date__c = oscarToProcess.ANG_PCI_compliance_expiry_date__c;
                }
                    

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
				if(toReturn.changesStruct.get(acc.Id) == null)
					toReturn.changesStruct.put(acc.Id,acctChangesStruct);
				else
					toReturn.changesStruct.get(acc.Id).changes.addAll(objectChangesList);
			}

		}

		//this would overwrite existing struct, create a new method in the wrapper to add content in this struct
		//toReturn.addChangesStruct(accountsToUpdate);

		return toReturn;

	}

	public static AChangeStructure applyChangeOfOwnership(AMS_OSCAR__c oscarToProcess, Set<Id> accountsAffected, AChangeStructure toReturn, Boolean isCorrection){

		System.debug('[ANG_AgencyChangesHelper] Performing change of Ownership');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		if(toReturn.accountsMap.isEmpty())
			toReturn.accountsMap = getAccounts(accountsAffected);

		Map<Id, Set<Id>> stagingToAccount = new Map<Id, Set<Id>>();
		stagingToAccount.put(oscarToProcess.AMS_Online_Accreditation__c, accountsAffected);

		// get from the struct
		//Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges = new  Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();
		Map<Id,AMS_AccountRoleCreator.OldAndNewOwners> oldAndNewOwnersMap = new Map<Id,AMS_AccountRoleCreator.OldAndNewOwners>();

		oldAndNewOwnersMap = AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(stagingToAccount, isCorrection, false, new Map<Id,AMS_OSCAR__c>{oscarToProcess.Id => oscarToProcess}, 
			new Map<Id,String>{oscarToProcess.Id => toReturn.accountsMap.get(oscarToProcess.Account__c).Location_Type__c},
			new Map<Id,Id>{oscarToProcess.Id => toReturn.accountsMap.get(oscarToProcess.Account__c).Top_Parent__c == null ? oscarToProcess.Account__c : toReturn.accountsMap.get(oscarToProcess.Account__c).Top_Parent__c});

		System.debug('[ANG_AgencyChangesHelper] oldAndNewOwnersMap -> ' + oldAndNewOwnersMap);

		/*Capture Owner history for change codes*/

		for(Id accId : accountsAffected) {

			AMS_AccountRoleCreator.OldAndNewOwners oldNewOwnersByOscar = oldAndNewOwnersMap.get(oscarToProcess.AMS_Online_Accreditation__c);

			if (oldNewOwnersByOscar != null) {

				String oldOwnerCSV, newOwnerCSV = '';

				if (oldNewOwnersByOscar.getOldOwnersByAccountId(accId) != null) oldOwnerCSV = oldNewOwnersByOscar.getOldOwnersByAccountId(accId).allOwnersCSV;
				if (oldNewOwnersByOscar.getNewOwnersByAccountId(accId) != null) newOwnerCSV = oldNewOwnersByOscar.getNewOwnersByAccountId(accId).allOwnersCSV;

				AMS_ChangeCodesHelper.ObjectChange objectChangesOwnership;

				if (oldOwnerCSV != newOwnerCSV) objectChangesOwnership = new AMS_ChangeCodesHelper.ObjectChange('Account', 'Owners', oldOwnerCSV, newOwnerCSV);

				//if there are still no changes for the current account, add new change entry in the map for it
				if (objectChangesOwnership != null && toReturn.changesStruct.get(accId) == null) {
					AMS_ChangeCodesHelper.ObjectChangesStruct acctChangesStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List <AMS_ChangeCodesHelper.ObjectChange>{
							objectChangesOwnership
					});
					toReturn.changesStruct.put(accId, acctChangesStruct);
					//system.debug('DDD accountsToUpdate add Owners Info:' + accountsToUpdate.get(acc.Id));
				} else if (objectChangesOwnership != null)
					toReturn.changesStruct.get(accId).changes.add(objectChangesOwnership);

			}

		}
		//toReturn.addChangesStruct(accountsToUpdate);

		return toReturn;

	}

	public static AChangeStructure applyChangeOfAccreditationType(AMS_OSCAR__c oscarToProcess, Set<Id> accountsAffected, AChangeStructure toReturn){

		System.debug('[ANG_AgencyChangesHelper] Performing change of Accreditation Type');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = getAccreditation(oscarToProcess.AMS_Online_Accreditation__c);

		List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

        if(oscarOnlineAccreditation.ANG_Accreditation_Type__c ==  'Cashless'){
            
        	toUpsert = performCashLessTransformation(accountsAffected);

        	removeContactsFlag(accountsAffected);

            for(Id accountId: accountsAffected)
				if(toReturn.accountsMap.get(accountId) != null)
	                toReturn.accountsMap.get(accountId).Has_a_Financial_Assessment_Contact__c = false;

        	ANG_RHCHelper.deactivateRHCInfo(new Set<Id>{oscarToProcess.Account__c});
        }
        if(oscarOnlineAccreditation.ANG_Accreditation_Type__c ==  'Cash'){
        	toUpsert = performCashTransformation(accountsAffected);
			if(toReturn.accountsMap.get(oscarToProcess.Account__c)!=null)
        		ANG_RHCHelper.createRHCInfo(new List<Account>{toReturn.accountsMap.get(oscarToProcess.Account__c)}, false);
        }

		if(!toUpsert.isEmpty())
			upsert toUpsert;

		return toReturn;
	}

    @future
	public static void removeContactsFlag(Set<Id> accountsAffected){

		List<Contact> contactsToUpdate = new List<Contact>();
		List<Portal_Application_Right__c> portalARtoUpdate= new List<Portal_Application_Right__c>();

		List<Contact> contacts = [Select Id , Financial_Assessment_Contact__c, (select id from Portal_Application_Rights__r where Portal_Application__r.Name = 'IFAP' and Right__c = 'Access Granted') from Contact where AccountId in :accountsAffected and Financial_Assessment_Contact__c = true];

		for(Contact cnt: contacts){

			cnt.Financial_Assessment_Contact__c = false;

			contactsToUpdate.add(cnt);

			for(Portal_Application_Right__c par:cnt.Portal_Application_Rights__r){

				par.Right__c = 'Access Denied';
				portalARtoUpdate.add(par);

			}

		}

        updateContactsAndPortalRights(portalARtoUpdate, contactsToUpdate);
 
    }

    public static void updateContactsAndPortalRights(List<Portal_Application_Right__c> portalARtoUpdate, List<Contact> contactsToUpdate){

		if(!portalARtoUpdate.isEmpty())
			update portalARtoUpdate;

		if(!contactsToUpdate.isEmpty())
			update contactsToUpdate;
	}

	public static List<Agency_Authorization__c> performCashLessTransformation(Set<Id> accountsAffected){

		List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

		For(Agency_Authorization__c aa: [Select Id , Status__c from Agency_Authorization__c where Account__c in:accountsAffected and ANG_FormOfPayment_ID__c = 'CA' and Status__c != 'Not Authorized' and RecordType.DeveloperName = 'FormOfPayment']){

			aa.Status__c = 'Not Authorized';
			toUpsert.add(aa);

		}

		return toUpsert;

	}

	public static List<Agency_Authorization__c> performCashTransformation(Set<Id> accountsAffected){

		Set<Id> accountsToProcess = accountsAffected.clone();

		List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

		Set<Id> accountsUpdated = new Set<Id>();

		For(Agency_Authorization__c aa: [Select Id ,Account__c, Status__c from Agency_Authorization__c where Account__c in:accountsAffected and ANG_FormOfPayment_ID__c = 'CA' and Status__c != 'Active' and RecordType.DeveloperName = 'FormOfPayment']){

			aa.Status__c = 'Active';
			toUpsert.add(aa);
			accountsUpdated.add(aa.Account__c);

		}

		accountsToProcess.removeAll(accountsUpdated);

		Id formOfPaymentRT = null;

		if(!accountsToProcess.isEmpty())
			formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		For(Id accountId: accountsToProcess){

			toUpsert.add(new Agency_Authorization__c(Account__c = accountId, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));

		}

		return toUpsert;

	}

	public static boolean validateTypeOfChange(AMS_OSCAR__c oscar) {

		System.debug('[ANG_AgencyChangesHelper] Validating type of change for ANG Changes process.');

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		List<String> oscarStepsApiName = AMS_Utils.getOSCARStepsApiName();

		if (oscar.ANG_Type_Of_Change__c <> oldMap.get(oscar.Id).ANG_Type_Of_Change__c && oldMap.get(oscar.Id).STEP6__c == AMS_Utils.PASSED && !isMigrationRunning)
		{
			oscar.addError('Type of Change cannot be changed after Sanity Check is passed.');
			return false;
		}

		if (oscar.ANG_Type_Of_Change__c <> oldMap.get(oscar.Id).ANG_Type_Of_Change__c || oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {
			ANG_AgencyChangesConfigHelper.ChangesConfig config = ANG_AgencyChangesConfigHelper.getConfig(oscar);
			if (config != null){
					ANG_AgencyChangesConfigHelper.setNotApplicableSteps(config.config, oscar);
			} else return false;
		}

		return true;

	}

	public static ANG_AgencyChangesHelper.AChangeStructure generateNewGenChangeCodes(AMS_OSCAR__c oscar, ANG_AgencyChangesConfigHelper.ChangesConfig config, Map<Id, Agency_Applied_Change_code__c> accountsPrevChangeCode, String action, Set<Id> allHierarchyAccountsToApplyCC, ANG_AgencyChangesHelper.AChangeStructure changesContainer) {

		AMS_OSCAR_JSON.ChangeCode changeCodeDef;
		Agency_Applied_Change_code__c changeCode;
		String changeCodeIdentifier;

		if (action == AMS_Utils.SANITYCHECK) changeCodeIdentifier = config.config.TCA_Sanity_check__c;
		else if (action == AMS_Utils.APPROVAL) changeCodeIdentifier = config.config.TCA_Manager_approval__c;
		else if (action == AMS_Utils.WITHDRAWAL) changeCodeIdentifier = config.config.TCA_Application_withdrawal__c;

		system.debug('[ANG_AgencyChangesHelper] : Change code to apply: ' + changeCodeIdentifier);
		system.debug('[ANG_AgencyChangesHelper] : allHierarchyAccountsToApplyCC: ' + allHierarchyAccountsToApplyCC);

		if (changeCodeIdentifier != null) {

			for (Id acc : allHierarchyAccountsToApplyCC) {

				Account accToUpdateStatus = changesContainer.accountsMap.get(acc);

				if (accToUpdateStatus != null) {
					changeCodeDef = AMS_ChangeCodesConfigHelper.createChangeCodeFromConfigSetting(changeCodeIdentifier, oscar.ANG_Type_of_change__c, accToUpdateStatus.Status__c, accountsPrevChangeCode.get(accToUpdateStatus.Id), action);
					system.debug('[ANG_AgencyChangesHelper] : Change code def: ' + changeCodeDef);
					changesContainer.addChangeCodeDef(changeCodeDef, accToUpdateStatus);

					if(changeCodeDef.status != null){
						accToUpdateStatus.Status__c = AMS_Utils.getIATAReadableStatus(changeCodeDef.status);
						changesContainer.addAccount(accToUpdateStatus);
					}
				}
			}

		}
        
		return changesContainer;
	}

	public static AChangeStructure generateLNFChangeCode(AMS_OSCAR__c oscar, Map<Id, Agency_Applied_Change_code__c> accountsCurrentChangeCode, AChangeStructure changesContainer){

		AMS_OSCAR_JSON.ChangeCode changeCodeDef = new AMS_OSCAR_JSON.ChangeCode();
		Agency_Applied_Change_code__c changeCode;
		Agency_Applied_Change_code__c lastChangeCode = accountsCurrentChangeCode.get(oscar.Account__c);

		changeCodeDef.name = 'LNF';
		changeCodeDef.reasonCode = lastChangeCode.Reason_Code__c;
		changeCodeDef.reasonDesc = lastChangeCode.Reason_Description__c;

		Account acc = changesContainer.accountsMap.get(oscar.Account__c);

		//changeCode = createChangeCode(changeCodeDef, oscar, oscar.Account__c);
		changesContainer.addChangeCodeDef(changeCodeDef, acc);

		return changesContainer;

	}

	public static Agency_Applied_Change_code__c createChangeCode(AMS_OSCAR_JSON.ChangeCode changeCodeDefinition, AMS_OSCAR__c oscar, Id accId){

		String source = UserInfo.getUserType() == 'PowerPartner' ? 'Portal' : 'Internal';

		Agency_Applied_Change_code__c aacNEW = new Agency_Applied_Change_code__c(
				Active__c = true
		, Account__c = accId
		, Change_Code__c = changeCodeDefinition.name
		, OSCAR__c = oscar.Id
		, Bulletin_Information__c = (changeCodeDefinition.memoText == null) ? '' : changeCodeDefinition.memoText.toUpperCase()
		, Reason_Code__c = changeCodeDefinition.reasonCode
		, Reason_Description__c = changeCodeDefinition.reasonDesc
		, Source__c = source
		, CreatedDate_User__c = convertToHubEffectiveDate(system.today())
				//, To_Publish_in_e_Bulletin__c = changeCode.publishedOnEBulletin
		);

		return aacNEW;

	}

	public static boolean sanityCheckValidations(AMS_OSCAR__c oscar, AChangeStructure changesContainer, AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation){

		if(oscar.ANG_Type_of_change__c.containsIgnoreCase(AMS_Utils.ANG_ACCREDITATION_TYPE)){
			if(changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c == oscarOnlineAccreditation.ANG_Accreditation_type__c){
				oscar.addError('To pass sanity checks when type of change includes "Accreditation Type", this value must be modified.');
				return false;
			}
		}

		return true;

	}

	private static string convertToHubEffectiveDate(datetime dValue){
		if(dValue==null) return '';
		list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
		return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
	}

	public static AMS_Pax_Accreditation_Form__c getAccreditation(Id oscarOnlineAccredId){
		return [SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
				ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
				Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
				Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
				Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
				Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, IATA_ISO_State__r.Valid_for_Address__c, ANG_Accreditation_type__c
		FROM AMS_Pax_Accreditation_Form__c
		WHERE Id =: oscarOnlineAccredId limit 1];
	}

	private static Map<Id, Account> getAccounts(Set<Id> accountIds) {
		return new Map<Id, Account>([SELECT Status__c,ParentId, Top_Parent__c, Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
		        BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry, Is_Branch_Abroad__c,
		        ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
		        Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
		        Due_Diligence_Status__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,IATA_ISO_Country__r.Name,IATA_ISO_Country__r.Due_diligence_mandatory__c,IATA_ISO_Shipping_Country__c,IATA_ISO_Shipping_Country__r.Name,
		        IATA_ISO_Billing_State__c,IATA_ISO_Billing_State__r.Name, ANG_Accreditation_Model__c, IATA_ISO_Country__r.CurrencyIsoCode, Is_PCI_compliant__c,IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, 
		        ANG_IsNewGenAgency__c, ANG_FA_Opt_out__c, CNS_Agency__c, ANG_PCI_compliance_expiry_date__c, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c
		         FROM Account WHERE Id IN :accountIds]);
	}

	/**
	Returns operationCodes and respective BSP Configurations
	*/
	private static List<AMS_Operation__c> fetchOperationCodeConfiguration(Set<Id> countryIds, Id settlementRTId, Set<Id> operationsIds, String classType) {

		return Database.query('SELECT Id, Allow_multiple_remittances__c, (SELECT Remittance_Frequency__c, Remittances_Per_Year__c FROM BSP_Attributes__r' +(classType != null ? ' WHERE Class_Type__c = :classType' : '') +' ORDER BY Remittances_Per_Year__c DESC) FROM AMS_Operation__c WHERE Settlement__r.RecordtypeID = :settlementRTId' + (CountryIds != null ? ' AND Country__c IN :countryIds' : '' ) + (OperationsIds != null ? ' AND Id IN :operationsIds' : ''));
	}

	/**
	Returns operationCodes and respective BSP Configurations
	*/
	public static List<AMS_Operation__c> fetchOperationCodeConfiguration(Id settlementRTId, Set<Id> operationsIds) {

		return fetchOperationCodeConfiguration(null, settlementRTId, operationsIds, null);
	}

	/**
	Returns operationCodes and respective BSP Configurations
	*/
	public static List<AMS_Operation__c> fetchOperationCodeConfiguration(Id settlementRTId, Id countryId, String classType) {

		return fetchOperationCodeConfiguration(new Set<Id>{countryId}, settlementRTId, null, classType);
	}

	/**
	Returns a Map of Agency Operations Operation Codes for the given accounts
	*/
	public static Map<Id,AMS_Agency_Operations__c> fetchAccountAgOperationPerOpCode(List<Id> accIds) {

		Map<Id,AMS_Agency_Operations__c> agencyOperations = new Map<Id,AMS_Agency_Operations__c>();
		for(AMS_Agency_Operations__c agOp : [SELECT Id, Account__c, Operation__c, Operation__r.Settlement__r.RecordType.Name FROM AMS_Agency_Operations__c WHERE Account__c in :accIds])
			agencyOperations.put(agOp.Operation__c,agOp);

		return agencyOperations;
	}

	    /**

     Create Change Codes NEW Method that creates Change Code History Objects

    */

	public static AChangeStructure ANGcreateAAChangeCodes(List<AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges, List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts, ANG_AgencyChangesHelper.AChangeStructure changesContainer) {

		Map<Account, Boolean> accountsChecker = new Map<Account, Boolean>();

		Set<Account> accountsToUpdate = new Set<Account>();

		Set<Id> accountIds = new Set<Id>();
		for(Account acc: oscarAgencies)
			accountIds.add(acc.Id);

		// get the forms of payment for all accounts involved in the changes to display on eBulletin
		Map<Id,List<Agency_Authorization__c>> fOPs = AMS_ChangeCodesHelper.fetchFormsOfPayment(accountIds);

		AMS_ChangeCodesHelper.ObjectChangesStruct objectChangesByChangeCode = null;

		//Account ID => Change Code Struct
		Map<ID,AMS_ChangeCodesHelper.ChangeCodeStruct> aaccHistoryToProcess = new Map <ID,AMS_ChangeCodesHelper.ChangeCodeStruct> ();

		system.debug('[ANG_AgencyChangesHelper] The list of agencies to insert the change codes are the following:'+oscarAgencies);
		system.debug('[ANG_AgencyChangesHelper] Change Codes:'+ changeCodes);

		Integer index = 0;

		for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

			Id accId = oscarAgencies.get(index).Id;

			Account acct = changesContainer.accountsMap.get(accId) != null ?  changesContainer.accountsMap.get(accId) : new Account(Id = accId);

			Boolean isActive = false;

			if (!accountsChecker.containsKey(acct)) {
				accountsChecker.put(acct, false);
				isActive = true;
			}

            if(objectChanges != null && !objectChanges.isEmpty()){
				if(objectChanges.size() == 1)
					objectChangesByChangeCode = objectChanges.get(0);
				else
					objectChangesByChangeCode = objectChanges.get(index);
			}
            
			AMS_ChangeCodesHelper.ChangeCodeStruct changeCodeResult = AMS_ChangeCodesHelper.createAAChangeCode(objectChangesByChangeCode,cc, oscars.get(0), oscarAgencies.get(index), isActive, fOPs.get(accId));

			changesContainer.addChangeCode(changeCodeResult.changeCode);

			aaccHistoryToProcess.put(accId, changeCodeResult);

			if (!accountsToUpdate.contains(changeCodeResult.acct)){
				changesContainer.addAccount(changeCodeResult.acct);
			}

			index++;
		}

		/*for (AMS_OSCAR_JSON.ChangeCode cc : changeCodes) {

			Integer index = 0;

			for(Id acctId: oscarAgencies){

				Account acct = changesContainer.accountsMap.get(acctId) != null ?  changesContainer.accountsMap.get(acctId) : new Account(Id = acctId);

				Boolean isActive = false;

				if (!accountsChecker.containsKey(acct)) {
					accountsChecker.put(acct, false);
					isActive = true;
				}

				if(objectChanges != null && !objectChanges.isEmpty())
					objectChangesByChangeCode = objectChanges.get(index);

				system.debug('[ANG_AgencyChangesHelper] Change Codes Check:'+ cc);
				AMS_ChangeCodesHelper.ChangeCodeStruct changeCodeResult = AMS_ChangeCodesHelper.createAAChangeCode(objectChangesByChangeCode,cc, oscars.get(index), acct, isActive, fOPs.get(acctId));

				system.debug('[ANG_AgencyChangesHelper] Change Codes Check2:'+ cc);
				changesContainer.addChangeCode(changeCodeResult.changeCode);

				aaccHistoryToProcess.put(acct.Id, changeCodeResult);

				//changesContainer.addChangeCode(changeCodeResult.changeCode);

				if (!accountsToUpdate.contains(changeCodeResult.acct)){
					changesContainer.addAccount(changeCodeResult.acct);
				}
				system.debug('[ANG_AgencyChangesHelper] HELLO:'+ index);
			}

			index++;
		}*/

		if(changesContainer.changeCodesToCreate != null && !changesContainer.changeCodesToCreate.isEmpty())
		{
			system.debug('changeCodesToCreate: ' + changesContainer.changeCodesToCreate);
			insert changesContainer.changeCodesToCreate;

		}

		//create history for ebulletin
		AMS_ChangeCodesHelper.createAAChangeCodesHistory( changesContainer.changeCodesToCreate, aaccHistoryToProcess.values());
		System.debug('[ANG_AgencyChangesHelper] Checkpoint4 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);

		return changesContainer;
	}

    public static void validationBeforeClosure(AMS_OSCAR__c oscar){

    	if(ANG_AgencyChangesHelper.containsChange(new List<String>(AMS_Utils.changesRequiringManagerApproval),oscar.ANG_Type_Of_Change__c) && oscar.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RecordTypeId != AMS_Utils.RECTYPE_NGCORRECTION)
    		oscar.addError('Cannot close the OSCAR until the Manager Approval Step is not completed.');

    }

    public static Set<Id> extractAllAccounts(Map<Id, List<AMS_Agencies_relationhip__c>> relations){

		Set<String> terminatedStatus = new Set <String>{AMS_Utils.ACC_S0_TERMINATED, AMS_Utils.ACC_S1_NOTACCREDITED, AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING,AMS_Utils.ACC_S3_NOTINOPERATION, ''};

    	Set<Id> toReturn = new Set<Id>();

    	for(List<AMS_Agencies_relationhip__c> relationsLst: relations.values())
    		for(AMS_Agencies_relationhip__c rel : relationsLst){

    			toReturn.add(rel.Parent_Account__c);
    			
    			if(!terminatedStatus.contains(rel.Child_Account__r.Status__c))
    				toReturn.add(rel.Child_Account__c);

    	}

    	return toReturn;
    }

    private static AChangeStructure applyFAOptOut(AMS_Oscar__c oscar, AChangeStructure changesContainer, List<Account> accountsInvolved, Boolean bOptOut){

			Boolean valueToAgency;
			String prevOptOut;

			// check if we are forcing a value - depending on type of changes
			if(bOptOut != null){
				valueToAgency = bOptOut;

			} else {
				valueToAgency = oscar.ANG_FA_Opt_out__c == 'Opt-Out' ? true : false;
			}

			for (Account acc: accountsInvolved){

				prevOptOut = String.valueOf(acc.ANG_FA_Opt_out__c);

                if (changesContainer.accountsMap.keySet().contains(acc.Id)){
               		changesContainer.accountsMap.get(acc.Id).ANG_FA_Opt_out__c = valueToAgency;
                } else {
                	acc.ANG_FA_Opt_out__c = valueToAgency;
                	changesContainer.accountsMap.put(acc.Id,acc);
                }
                changesContainer.accountsChanged.add(acc.id);
	
				// create history on change code
				if (valueToAgency != null && prevOptOut != null && prevOptOut != '' && String.valueOf(valueToAgency) != prevOptOut){
					AMS_ChangeCodesHelper.ObjectChange objectChange = new AMS_ChangeCodesHelper.ObjectChange('Account','ANG_FA_Opt_out__c', prevOptOut, String.valueOf(valueToAgency));
	            	AMS_ChangeCodesHelper.ObjectChangesStruct objectChangeStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(new List<AMS_ChangeCodesHelper.ObjectChange>{objectChange});
	            	changesContainer.changesStruct.put(acc.Id, objectChangeStruct);
				}
			}


		return changesContainer;
    }
}
