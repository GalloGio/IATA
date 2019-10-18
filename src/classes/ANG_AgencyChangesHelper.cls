public with sharing class ANG_AgencyChangesHelper {

	public static Boolean testRunnningForNonBackup = false;
	public static Boolean isMigrationRunning = false;
	public static AChangeStructure changesContainer = null;
	private static final Integer CHANGECODES_THRESHOLD = 25;

	public class AChangeStructure{

		public Map<Id,AMS_Agencies_relationhip__c> relationsMap;
		public Map<Id,Account> accountsMap;
		public Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> changesStruct;
		public List<Agency_Applied_Change_code__c> changeCodesToCreate;
		public List<AMS_OSCAR_JSON.ChangeCode> changeCodesToCreateDef;
		public List<Account> accountsToApplyChangeCodes;
		public Set<Id> accountsToRecalculateRHC; 
		public Set<Id> accountsToRecalculateFsAmounts;
		//Used to move financial securities and risk events
		//from one account (key) to the other (value)
		public Map<Id, Id> moveFsAndRiskEventsMap;

		public List<Account> accountsToCreateRhcInformationLst;
		public List<ANG_Agency_Risk_Event__c> inactivateRiskEventLst;
		public Id newParent;
		public List<AMS_Agencies_relationhip__c> relationsToDeleteLst;
		public List<ANG_RHC_Information__c> deactivateRhcInformationLst;
		public List<Agency_Authorization__c> agencyAuthorizationToUpdateLst;
		public Map<Id, Map<Id, Integer>> calculateRiskAssessmentMap;
		public List<ANG_Risk_Alert__c> riskAlertsToUpdateLst;

		public Set<Id> accountsChanged;

		public Map<Id,AMS_Agencies_Hierarchy__c> hierarchies;

		public AChangeStructure(){
			relationsMap = new Map<Id, AMS_Agencies_relationhip__c>();
			accountsMap = new Map<Id, Account>();
			changeCodesToCreate = new List<Agency_Applied_Change_code__c>();
			changeCodesToCreateDef = new List<AMS_OSCAR_JSON.ChangeCode>();
			accountsChanged = new Set<Id>();
			changesStruct = new Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct>();
			accountsToApplyChangeCodes = new List<Account>();
			accountsToRecalculateRHC = new Set<Id>();
			hierarchies = new Map<Id,AMS_Agencies_Hierarchy__c>();
			accountsToRecalculateFsAmounts = new Set<Id>();
			accountsToCreateRhcInformationLst = new List<Account>();
			inactivateRiskEventLst = new List<ANG_Agency_Risk_Event__c>();
			newParent = null;
			relationsToDeleteLst = new List<AMS_Agencies_relationhip__c>();
			deactivateRhcInformationLst = new List<ANG_RHC_Information__c>();
			agencyAuthorizationToUpdateLst = new List<Agency_Authorization__c>();
			calculateRiskAssessmentMap = new Map<Id, Map<Id, Integer>>();
			riskAlertsToUpdateLst = new List<ANG_Risk_Alert__c>();
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

		public void addAccountToRecalculateRHC(Id accountId){
			accountsToRecalculateRHC.add(accountId);
		}

		public void addHierarchy(AMS_Agencies_Hierarchy__c hierarchy){
			hierarchies.put(hierarchy.Id, hierarchy);
		}
		
		public void addRhcInformationToDeactivate(ANG_RHC_Information__c rhcInfo){
			deactivateRhcInformationLst.add(rhcInfo);
		}

		public void addRiskEventsToInactivate(List<ANG_Agency_Risk_Event__c> riskEventLst, Id newParentId){
			inactivateRiskEventLst.addAll(riskEventLst);
			this.newParent = newParentId;
		}

		public void addAccountToCreateRHC(Account account){
			accountsToCreateRhcInformationLst.add(account);
		}

		public void addRelationToDelete(AMS_Agencies_relationhip__c relation){
			relationsToDeleteLst.add(relation);
		}

		public void addAgencyAuthorizationToUpdate(Agency_Authorization__c aa){
			agencyAuthorizationToUpdateLst.add(aa);
		}

		public void addAccountToCalculateRiskAssessment(Id accountId){
			calculateRiskAssessmentMap.put(accountId, null);
		}

		public void addRiskAlertsToUpdate(List<ANG_Risk_Alert__c> riskAlertsLst){
			riskAlertsToUpdateLst.addAll(riskAlertsLst);
		}
		
		public void addAccountsToRecalculateFsAmounts(Id accountId){
			accountsToRecalculateFsAmounts.add(accountId);
		}

		public void runDeletes(){

			if(relationsToDeleteLst != NULL && !relationsToDeleteLst.isEmpty()){
				delete relationsToDeleteLst;
			}

			if(deactivateRhcInformationLst != NULL && !deactivateRhcInformationLst.isEmpty()){
				ANG_RHCHelper.deactivateRHCInfo(deactivateRhcInformationLst);
			}

		}

		public Boolean runUpsert(){

			System.debug('[ANG_AgencyChangesHelper] Running upsert'); 

			Boolean hasUpserted = false;

			AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = true;

			runDeletes();

			if(relationsMap != null && !relationsMap.isEmpty()){
				System.debug('[ANG_AgencyChangesHelper] Upserting following relations:'+relationsMap);
				upsert relationsMap.values();
				hasUpserted = true;
			}

			if(hierarchies != null && !hierarchies.isEmpty()){
				System.debug('[ANG_AgencyChangesHelper] Upserting following hierarchies:'+hierarchies);
				upsert hierarchies.values();
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

			if(accountsToCreateRhcInformationLst != NULL && !accountsToCreateRhcInformationLst.isEmpty()){
				ANG_RHCHelper.createRHCInfo(accountsToCreateRhcInformationLst, false);
			}

			if(agencyAuthorizationToUpdateLst != NULL && !agencyAuthorizationToUpdateLst.isEmpty()){
				update agencyAuthorizationToUpdateLst;
			}

			if(calculateRiskAssessmentMap != NULL && !calculateRiskAssessmentMap.isEmpty()){
				System.debug(LoggingLevel.FINE, '____ [cls ANG_AgencyChangesHelper - runUpsert] Calculate risk assessment for accounts: ' + calculateRiskAssessmentMap.keySet());
				new ANG_RiskAssessmentEngine(calculateRiskAssessmentMap).assessment();
			}

			if(riskAlertsToUpdateLst != NULL && !riskAlertsToUpdateLst.isEmpty()){
				update riskAlertsToUpdateLst;
			}

			if(!accountsToRecalculateRHC.isEmpty()){
				recalculateRHCInformation(accountsToRecalculateRHC);
			}
			
			if(!accountsToRecalculateFsAmounts.isEmpty()){
				ANG_FinancialSecurityTriggerHandler.triggerFsAmountsRecalculation(accountsToRecalculateFsAmounts, true, true);
			}

			if(moveFsAndRiskEventsMap != NULL && !moveFsAndRiskEventsMap.isEmpty()){
				System.enqueueJob(new ANG_Risk_Helper.FutureHandler(moveFsAndRiskEventsMap));
			}

			if(inactivateRiskEventLst != NULL && !inactivateRiskEventLst.isEmpty()){
				System.enqueueJob(new ANG_Risk_Helper.FutureHandler(inactivateRiskEventLst, newParent));
			}

			return hasUpserted;
		}

		public void addChangesStruct(Map<ID,AMS_ChangeCodesHelper.ObjectChangesStruct> changesStruct){
			this.changesStruct = changesStruct;
		}

	}

	public static void handleNewGenChangesProcess(List<AMS_Oscar__c> oscars){

		System.debug('[ANG_AgencyChangesHelper.handleNewGenChangesProcess] oscars List = ' +oscars);

		ANG_AgencyChangesConfigHelper.ChangesConfig config = null;

		AMS_OSCAR__c oscar = oscars[0];

		if(oscar.Process__c == AMS_UTils.NGCONVERSIONTOMULTICOUNTRY){
			System.debug(LoggingLevel.FINE, '##SSHK## [ANG_AgencyChangesHelper.handleNewGenChangesProcess] [BEFORE CONVERSION] BEGIN SOQL:' + Limits.getQueries());
			handleConversionToMulticountry(oscar);
			System.debug(LoggingLevel.FINE, '##SSHK## [ANG_AgencyChangesHelper.handleNewGenChangesProcess] [AFTER CONVERSION] END SOQL:' + Limits.getQueries());
			return;
		}

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

			changesContainer = new AChangeStructure();

			System.debug('[ANG_AgencyChangesHelper][handleNewGenChangesProcess] -- types of changes selected are valid!');

			AMS_OSCAR__c oldOSCAR = (AMS_OSCAR__c)Trigger.oldMap.get(oscar.Id);

			Set<Id> accountIdsInvolvedSet = ANG_AgencyChangesHelper.fetchAccountIdsToBeProcessed(oscar.Id);
			accountIdsInvolvedSet.add(oscar.Account__c);

			if(containsChange(new List<String>{AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY}, oscar.ANG_Type_Of_Change__c) && oscar.Previous_HE__c != NULL){
				accountIdsInvolvedSet.add(oscar.Previous_HE__c);
			}

			changesContainer.accountsMap = getAccounts(accountIdsInvolvedSet);

			String currHEAccount = changesContainer.accountsMap.get(oscar.Account__c).ParentId == null ? oscar.Account__c : changesContainer.accountsMap.get(oscar.Account__c).ParentId;

			AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = getAccreditation(oscar.AMS_Online_Accreditation__c);

			Boolean isMulticountry = (oscarOnlineAccreditation.ANG_Accreditation_type__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);

			Set<Id> accountIdsInvolvedSetAux = new Set<Id>();
			accountIdsInvolvedSetAux.addAll(accountIdsInvolvedSet);

			if(changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c != null)
				accountIdsInvolvedSetAux.add(changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c);

			//Fetch active change codes for each account (added subquery on getAccounts() method): map accountId -> active change code
			Map<Id, Agency_Applied_Change_code__c> accountsCurrentChangeCode = fetchActiveChangeCodesFromAccounts(changesContainer.accountsMap.values());

			if (oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {

                if(!validateTypeOfChange(oscar,changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c))
                    return;
                    
				if(!sanityCheckValidations(oscar, changesContainer, oscarOnlineAccreditation))
					return;

				String prevAccreditationModel = changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c;

				/** NEWGEN-5848 PREVENT Copy Data to Account if Multicountry Change of Hierarchy*/
				if(!(oscar.ANG_Type_Of_Change__c == AMS_Utils.ANG_HIERARCHY && oscarOnlineAccreditation != null && oscarOnlineAccreditation.ANG_Accreditation_type__c == 'Multicountry'))
				changesContainer = applyChangeOfFields(oscar, accountIdsInvolvedSet, changesContainer, oscarOnlineAccreditation);

				System.debug('[ANG_AgencyChangesHelper] changesContainer are:'+changesContainer);
				System.debug('[ANG_AgencyChangesHelper] Checkpoint1 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);
					
				//Set default value as "Not Applicable" 	
				oscar.ANG_FA_Opt_out__c = AMS_Utils.NOT_APPLICABLE;				

				//if(Pattern.matches(AMS_Utils.ANG_ACCREDITATION_TYPE, oscar.ANG_Type_Of_Change__c))				
				if(containsChange(New List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE},oscar.ANG_Type_Of_Change__c)){
					changesContainer = applyChangeOfAccreditationType(oscar, accountIdsInvolvedSet, changesContainer);

					if((oscarOnlineAccreditation.ANG_Accreditation_Type__c ==  AMS_Utils.ACCREDITATIONMODEL_CASH) && (prevAccreditationModel == AMS_Utils.ACCREDITATIONMODEL_CASHLESS)){
						Set<String> optOutCountryConfig = ANG_OscarProcessHelper.fetchOptOutFromFinancialReviewCountriesCfg(new Set<Id>{oscarOnlineAccreditation.Branch_Office_Country__c});
						String optOutCfgKey = oscarOnlineAccreditation.Branch_Office_Country__c + '.' + oscarOnlineAccreditation.Location_Class__c;
						//If for the associated country we have a 'Opt out at Accreditation' configuration record 
						//on AMS Country Specific Attributes the agent should be opt out from financial review
						if(optOutCountryConfig.contains(optOutCfgKey)){
							oscar.ANG_FA_Opt_out__c = AMS_Utils.FA_OPT_OUT;
						}
					}
				}

				//if(Pattern.matches(AMS_Utils.ANG_LOCATION_TYPE + '|' + AMS_Utils.ANG_HIERARCHY, oscar.ANG_Type_Of_Change__c))
				if(containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE,AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY, AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){
					
					Map<Id, List<AMS_Agencies_relationhip__c>> allRelationsOnHierarchy = null;

					if(containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){
						
						Set<Id> accountIdSet = new Set<Id>{oscar.Account__c};

						if(isMulticountry) accountIdset.add(oscar.New_Parent__c);


						allRelationsOnHierarchy = AMS_HierarchyHelper.getAccountsHierarchies(accountIdSet);

						accountHierarchyRelationships = extractAllAccounts(allRelationsOnHierarchy);
						accountHierarchyRelationships.add(oscar.Account__c);
            isAllHierarchySelected = isAllHierarchySelected(oscar,accountHierarchyRelationships);
            System.debug('[ANG_AgencyChangesHelper] isAllHierarchySelected is set to:'+isAllHierarchySelected);

						Account acct = changesContainer.accountsMap.get(oscar.Account__c);

						if(acct.IATA_ISO_Country__r.ANG_RHC_LocationType__c == 'Include All AEs'){
							changesContainer.addAccountsToRecalculateFsAmounts(currHEAccount);
							changesContainer.addAccountsToRecalculateFsAmounts(oscar.New_Parent__c);
						}
					}
					
					changesContainer = processHierarchyChangesAux(oscar, changesContainer, accountIdsInvolvedSet, isAllHierarchySelected,allRelationsOnHierarchy, isMulticountry);

					//NEWGEN-4856

					Account acct = changesContainer.accountsMap.get(oscar.Account__c);

					Boolean isGEInvolved = isMulticountry && (acct.Location_Type__c == AMS_Utils.GE || changesContainer.accountsMap.containsKey(acct.Top_Parent__c));

					if(oscar.ANG_Type_Of_Change__c == AMS_Utils.ANG_HIERARCHY){
						processRiskAlerts(changesContainer, oscar.New_Parent__c);
					}
					else if(!isMulticountry){
						processRiskAlerts(changesContainer, currHEAccount, oscar.Account__c);
					}
					else if(isGEInvolved){
						processRiskAlerts(changesContainer, acct.Location_Type__c == AMS_Utils.GE ? acct.Id : acct.Top_Parent__c);	
					}

					//NEWGEN-4856-END

				}
				System.debug('[ANG_AgencyChangesHelper] oscar.Process__c = ' +oscar.Process__c);
				//if(Pattern.matches(AMS_Utils.ANG_OWNERSHIP + '|' + AMS_Utils.ANG_MINOR_SHAREHOLDING + '|' + AMS_Utils.ANG_MAJOR_SHAREHOLDING, oscar.ANG_Type_Of_Change__c))
				if(containsChange(New List<String>{AMS_Utils.ANG_OWNERSHIP, AMS_Utils.ANG_MINOR_SHAREHOLDING, AMS_Utils.ANG_MAJOR_SHAREHOLDING},oscar.ANG_Type_Of_Change__c)) {
					changesContainer = applyChangeOfOwnership(oscar, accountIdsInvolvedSet, changesContainer, true);
				}

				if(oscar.Process__c == AMS_Utils.NGCHANGES){
					
					if(config == null) config = ANG_AgencyChangesConfigHelper.getConfig(oscar,changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c);

					if(!isMulticountry && containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE, AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY},oscar.ANG_Type_Of_Change__c)){
						oscar.Previous_HE__c = currHEAccount;
						changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.SANITYCHECK, accountIdsInvolvedSetAux, changesContainer);
					}
					else {
						changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.SANITYCHECK, accountIdsInvolvedSet, changesContainer);
					}
					
					System.debug('[ANG_AgencyChangesHelper] Checkpoint2 changesCodes are:'+ changesContainer.changeCodesToCreate.size() + ' ' + changesContainer.changeCodesToCreate);

					if(!isMulticountry){
						System.debug('[ANG_AgencyChangesHelper] Starting Risk Actions');
						performRiskEventActions(oscar,currHEAccount, oscar.New_parent__c, changesContainer.accountsMap.values());
						System.debug('[ANG_AgencyChangesHelper] Risk Actions Ended');
					}
	
					if (changesContainer.accountsMap.get(oscar.Account__c).IATA_ISO_Country__r.Due_diligence_mandatory__c && oscar.STEP17__c != AMS_Utils.NOT_APPLICABLE && 
						oscar.Type_of_change__c != AMS_Utils.ANG_LOCATION) {

                        if(changesContainer.accountsMap.get(oscar.Account__c).Due_Diligence_Status__c == AMS_Utils.IN_PROGRESS) oscar.STEP17__c = AMS_Utils.IN_PROGRESS;
                        else{
                            String dlResult = AMS_OSCAR_Webservice.createAMLCaseWithNoOscarUpdate(oscar);
                            if (dlResult.startsWith('ERROR')) oscar.addError(dlResult);
                            else changesContainer.accountsMap.get(oscar.Account__c).Due_Diligence_Status__c = AMS_Utils.IN_PROGRESS;
                        }
                    }

				}

				if(oscar.Process__c == AMS_Utils.NGCORRECTION){
					System.debug('[ANG_AgencyChangesHelper] Oscar Process is NGCORRECTION');
					
					List<Account> accountsToUpdate = new List<Account>();
					
					for(Id accId : accountIdsInvolvedSet){
						accountsToUpdate.add(changesContainer.accountsMap.get(accId));
					}
					
					System.debug('[ANG_AgencyChangesHelper] accountsToUpdate = ' +accountsToUpdate);
					System.debug('[ANG_AgencyChangesHelper] oscar.Account__c = ' +oscar.Account__c);
					
					
					if (!new Set<String>{'COR','CAD','LET'}.contains(oscar.AMS_Correction_change_code__c))
						oscar.addError('To pass sanity check a correction change code is required.');

					if(oscar.AMS_Correction_change_code__c == 'COR' || oscar.AMS_Correction_change_code__c == 'CAD'){
						System.debug('[ANG_AgencyChangesHelper] oscar.AMS_Correction_change_code__c = ' +oscar.AMS_Correction_change_code__c);
						AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

						changeCode.status  = null;
						if(oscar.AMS_Correction_change_code__c == 'COR') {
							changeCode.name = 'COR';
							changeCode.memoText = 'Correction';
							changeCode.publishedOnEBulletin = false;
							changesContainer.accountsToApplyChangeCodes.addAll(accountsToUpdate);
							System.debug('[ANG_AgencyChangesHelper]##AC: accountsToUpdate= ' + accountsToUpdate);
						}
						else if(oscar.AMS_Correction_change_code__c == 'CAD'){
							changeCode.name = 'CAD';
							changeCode.memoText = 'Minor Changes';
							changesContainer.accountsToApplyChangeCodes.add(changesContainer.accountsMap.get(oscar.Account__c));
						}
						
						List<Agency_Applied_Change_code__c> accountActiveChangeCode = [SELECT Reason_Code__c, Reason_Description__c,Account__r.Status__c FROM Agency_Applied_Change_code__c WHERE Account__c =: oscar.Account__c AND Active__c = TRUE];
						System.debug('[ANG_AgencyChangesHelper] accountActiveChangeCode = ' +accountActiveChangeCode);
						
						if(accountActiveChangeCode.size() > 0){
							changeCode.reasonCode = accountActiveChangeCode[0].Reason_Code__c;
							changeCode.reasonDesc = accountActiveChangeCode[0].Reason_Description__c;
							changeCode.status = AMS_Utils.getIATANumericStatus(accountActiveChangeCode[0].Account__r.Status__c);
						}

						System.debug('[ANG_AgencyChangesHelper] accountsToApplyChangeCodes = ' +changesContainer.accountsToApplyChangeCodes); 
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
						System.debug('[ANG_AgencyChangesHelper] changesContainer.accfountsToApplyChangeCodes = ' +changesContainer.accountsToApplyChangeCodes);
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
					config = ANG_AgencyChangesConfigHelper.getConfig(oscar,changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c);

				/** NEWGEN-5848 PREVENT Copy Data to Account if Multicountry Change of Hierarchy*/
				if(!(oscar.ANG_Type_Of_Change__c == AMS_Utils.ANG_HIERARCHY && oscarOnlineAccreditation != null && oscarOnlineAccreditation.ANG_Accreditation_type__c == 'Multicountry'))
				changesContainer = applyChangeOfFields(oscar, accountIdsInvolvedSet, changesContainer, oscarOnlineAccreditation);

				changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.APPROVAL, accountIdsInvolvedSet, changesContainer);

				
				Boolean applyOptOutFA = 
					containsChange(New List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE}, oscar.ANG_Type_Of_Change__c) &&
					(oscarOnlineAccreditation.ANG_Accreditation_Type__c ==  AMS_Utils.ACCREDITATIONMODEL_CASH) && 
					(oscar.ANG_FA_Opt_out__c == AMS_Utils.FA_OPT_OUT);

				if (containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)) {

					hierarchyAccs = new Map<Id,Account>([SELECT Id, ANG_FA_Opt_out__c, CNS_Agency__c, Is_PCI_compliant__c, (SELECT Id, ANG_FormOfPayment_ID__c, Status__c FROM Agency_Authorizations__r WHERE ANG_FormOfPayment_ID__c IN ('CA', 'EP','CC')) FROM Account WHERE Id = :oscar.New_parent__c OR Top_Parent__c = :oscar.New_parent__c]);
					
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

					//If it is a multicountry hierarchy split => updates forms of payments (CC, CA, EP)
					if(isMulticountry && accountIdsInvolvedSet.contains(oscar.New_parent__c)){
						ANG_MulticountryHelper.processAgenciesFormsOfPayment(hierarchyAccs.values(), changesContainer);
					}

				//NEWGEN-1088 apply FA opt-out = false when changing to cash or to cashless
				} else if (containsChange(New List<String>{AMS_Utils.ANG_ACCREDITATION_TYPE},oscar.ANG_Type_Of_Change__c) && !applyOptOutFA) {

	    			changesContainer= applyFAOptOut(oscar, changesContainer, changesContainer.accountsMap.values(), FALSE);
	    		
	    		//all other major changes
				}else if (applyOptOutFA || (oscar.ANG_FA_Opt_out__c == 'Opt-Out' || oscar.ANG_FA_Opt_out__c == 'Opt-In' && containsChange(new List<String>(AMS_Utils.ANG_OSCAR_MAJOR_CHANGES_PROCESSES), oscar.ANG_Type_Of_Change__c))){

					String hierTopParent = changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c == null ? changesContainer.accountsMap.get(oscar.Account__c).Id : changesContainer.accountsMap.get(oscar.Account__c).Top_Parent__c;
					hierarchyAccs = new Map<Id,Account>([SELECT Id, ANG_FA_Opt_out__c, CNS_Agency__c FROM Account WHERE Id = :hierTopParent OR Top_Parent__c = :hierTopParent]);

					changesContainer = applyFAOptOut(oscar, changesContainer, hierarchyAccs.values(), null);

					if(applyOptOutFA){ 
						ANG_OscarProcessHelper.updateCaseStatusForAccounts(new Set<Id>{oscar.Account__c}, AMS_Utils.RECTYPE_CASEIFAP, IFAP_BusinessRules.CLOSEDOPTOUT);
					}

				}				

			} else if (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) {

				if(config == null)
					config = ANG_AgencyChangesConfigHelper.getConfig(oscar,changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c);

				changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.WITHDRAWAL, accountIdsInvolvedSet, changesContainer);

			}else if (!oldOSCAR.Apply_Penalty_Fee__c && oscar.Apply_Penalty_Fee__c) {

				changesContainer = generateLNFChangeCode(oscar, accountsCurrentChangeCode, changesContainer);
			
			}else if(oldOSCAR.Status__c != AMS_Utils.OSCAR_CLOSED && oscar.Status__c == AMS_Utils.OSCAR_CLOSED){

				if(config == null)
					config = ANG_AgencyChangesConfigHelper.getConfig(oscar,changesContainer.accountsMap.get(oscar.Account__c).ANG_Accreditation_Model__c);

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

	public static void handleConversionToMulticountry(AMS_OSCAR__c oscar){

		AMS_OSCAR__c oldOSCAR = (AMS_OSCAR__c) Trigger.oldMap.get(oscar.Id);

		changesContainer = new AChangeStructure();

		Map<Id, Agency_Applied_Change_code__c> accountsCurrentChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

		if(oscar.STEP6__c == AMS_Utils.PASSED && oldOSCAR.STEP6__c != AMS_Utils.PASSED){
			
			Map<Id, Id> topEntityPerBspMap = new Map<Id, Id>();
			Map<Id, AMS_Process_Detail__c> processDetailsPerAccountMap = new Map<Id, AMS_Process_Detail__c>();

			for(AMS_Process_Detail__c pd : fetchAmsProcessDetails(oscar.Id)){
				processDetailsPerAccountMap.put(pd.Account__c, pd);
				if(pd.ANG_Location_Type_Conversion__c == AMS_Utils.HE){
					topEntityPerBspMap.put(pd.Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, pd.Account__c);
				}
			}

			Set<Id> allAccountsInvolvedSet = new Set<Id>{oscar.Account__c}; 
			allAccountsInvolvedSet.addAll(processDetailsPerAccountMap.keySet());

			changesContainer.accountsMap = getAccounts(allAccountsInvolvedSet);
			
			//The account related with the oscar becomes the GE
			Account accountGE = changesContainer.accountsMap.get(oscar.Account__c);

			topEntityPerBspMap.put(accountGE.IATA_ISO_Country__r.AMS_Settlement_System__c, accountGE.Id);
			
			AMS_Pax_Accreditation_Form__c stagingArea = getAccreditation(oscar.AMS_Online_Accreditation__c);

			List<AMS_Agencies_Hierarchy__c> hierarchiesToDeleteLst = new List<AMS_Agencies_Hierarchy__c>();
			List<AMS_Agencies_relationhip__c> relationsToUpdateHierarchyRef = new List<AMS_Agencies_relationhip__c>();
			
			for(Account acct : changesContainer.accountsMap.values()){

				acct.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
				acct.ANG_FA_Opt_out__c = false;

				if(acct.Id == accountGE.Id){
					acct.Location_Type__c = AMS_Utils.GE;
					acct.Top_Parent__c = null;
					acct.ParentId = null;
					acct.Remittance_Frequency__c = stagingArea.Remittance_Frequency__c;
					changesContainer.addAccountToCreateRHC(acct);
				}
				else {

					AMS_Process_Detail__c pd = processDetailsPerAccountMap.get(acct.Id);

					acct.Location_Type__c = pd.ANG_Location_Type_Conversion__c;
					acct.ParentId = accountGE.Id;
					acct.Top_Parent__c = accountGE.Id;
					acct.Financial_Review_Result__c = null;
					acct.Assessment_Performed_Date__c = null;
					acct.ANG_HE_RiskStatus__c = null;
					acct.ANG_HE_CashCondition__c = false;
					acct.ANG_HE_RiskHistoryAssessment__c = null;
					acct.Financial_Assessment_Points__c = null;

					if(acct.Location_Type__c == AMS_Utils.AE){
						acct.ParentId = topEntityPerBspMap.get(acct.IATA_ISO_Country__r.AMS_Settlement_System__c);
					}

					if(acct.IATA_ISO_Country__r.AMS_Settlement_System__c == accountGE.IATA_ISO_Country__r.AMS_Settlement_System__c){
						acct.Remittance_Frequency__c = stagingArea.Remittance_Frequency__c;
					}

					AMS_Agencies_relationhip__c rel = new AMS_Agencies_relationhip__c(
						Is_Newgen_Relation__c = true, 
						Child_Account__c = acct.Id, 
						Parent_Account__c = acct.ParentId
					);

					relationsToUpdateHierarchyRef.add(rel);

					changesContainer.addRelation(rel);

					List<ANG_Agency_Risk_Event__c> riskEventsLst = (List<ANG_Agency_Risk_Event__c>) acct.getSObjects('Location_Risk_Events__r');

					if(riskEventsLst != NULL && !riskEventsLst.isEmpty()){
						changesContainer.addRiskEventsToInactivate(riskEventsLst, accountGE.Id);
					}

					List<ANG_Risk_Alert__c> riskAlertsLst = (List<ANG_Risk_Alert__c>) acct.getSObjects('Risk_Alerts__r');

					if(riskAlertsLst != NULL && !riskAlertsLst.isEmpty()){
						moveRiskAlerts(riskAlertsLst, accountGE.Id);
						changesContainer.addRiskAlertsToUpdate(riskAlertsLst);
					}
				
				}

				List<ANG_RHC_Information__c> rhcLst = (List<ANG_RHC_Information__c>) acct.getSObjects('RHC_Informations__r');

				if(rhcLst != NULL && !rhcLst.isEmpty()){
					changesContainer.addRhcInformationToDeactivate(rhcLst.get(0));
				}

				List<AMS_Agencies_Hierarchy__c> hierarchyLst = (List<AMS_Agencies_Hierarchy__c>) acct.getSObjects('Main_Accounts__r');

				if(hierarchyLst != NULL && !hierarchyLst.isEmpty()){
					hierarchiesToDeleteLst.add(hierarchyLst.get(0));
				}

				changesContainer.addAccount(acct);	

				//Fetch all child accounts that are inactive (terminated, not in operation, not accreditated, listed, blank)
				List<Account> childAcctsLst = (List<Account>) acct.getSObjects('ChildAccounts');
				
				if(childAcctsLst != NULL && !childAcctsLst.isEmpty()){
					for(Account childAcct : childAcctsLst){
						childAcct.Top_Parent__c = NULL;
						childAcct.ParentId = NULL;
						changesContainer.addAccount(childAcct);
					}
				}

				Agency_Applied_Change_code__c activeChgCode = fetchActiveChangeCodeFromAccount(acct);

				if(activeChgCode != NULL){
					accountsCurrentChangeCode.put(activeChgCode.Account__c, activeChgCode);
				}

			}

			delete hierarchiesToDeleteLst;

			AMS_Agencies_Hierarchy__c newHierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'NewGen Hierarchy', Main_Account__c = accountGE.Id);
			insert newHierarchy;

			//Update Hierarchy reference for every new relationship
			for(AMS_Agencies_relationhip__c rel : relationsToUpdateHierarchyRef){
				rel.Hierarchy__c = newHierarchy.Id;
			}
			
			update new AMS_PAX_Accreditation_Form__c(
				Id = oscar.AMS_Online_Accreditation__c, 
				ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY
			);

			ANG_AgencyChangesConfigHelper.ChangesConfig config = ANG_AgencyChangesConfigHelper.getConfig(oscar, AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);

			changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.SANITYCHECK, allAccountsInvolvedSet, changesContainer);

		}
		else if(oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL && oldOSCAR.RPM_Approval__c != AMS_Utils.AUTH_APPROVAL){

			Set<Id> allAccountsInvolvedSet = fetchAccountIdsToBeProcessed(oscar.Id);
			allAccountsInvolvedSet.add(oscar.Account__c);

			changesContainer.accountsMap = getAccounts(allAccountsInvolvedSet);

			Account accountGE = changesContainer.accountsMap.get(oscar.Account__c);

			Agency_Authorization__c geCashMethodFoP = NULL;

			List<Agency_Authorization__c> formOfPaymentsLst = (List<Agency_Authorization__c>) accountGE.getSObjects('Agency_Authorizations__r');

			if(formOfPaymentsLst != NULL && !formOfPaymentsLst.isEmpty()){
				//Fetch cash form of payment from GE
				for(Agency_Authorization__c aa : formOfPaymentsLst){
					if(aa.ANG_FormOfPayment_ID__c == AMS_Utils.CA){
						geCashMethodFoP = aa;
						break;
					}
				}
			}

			for(Account acct : changesContainer.accountsMap.values()){

				if(acct.Identify_as_Multicountry_Key_Hierarchy__c){
					
					List<ANG_Agency_Risk_Event__c> riskEventsLst = (List<ANG_Agency_Risk_Event__c>) acct.getSObjects('Location_Risk_Events__r');

					if(riskEventsLst != NULL && !riskEventsLst.isEmpty()){
						changesContainer.addRiskEventsToInactivate(riskEventsLst, accountGE.Id);
					}

				}

				//Update cash form of payments according to the GE cash FoP status
				if(acct.Id != accountGE.Id && geCashMethodFoP != NULL){
					formOfPaymentsLst = (List<Agency_Authorization__c>) acct.getSObjects('Agency_Authorizations__r');

					for(Agency_Authorization__c aa : formOfPaymentsLst){
						if(aa.ANG_FormOfPayment_ID__c == AMS_Utils.CA){
							aa.Status__c = geCashMethodFoP.Status__c;
							changesContainer.addAgencyAuthorizationToUpdate(aa);
							break;
						}
					}
				}

				Agency_Applied_Change_code__c activeChgCode = fetchActiveChangeCodeFromAccount(acct);

				if(activeChgCode != NULL){
					accountsCurrentChangeCode.put(activeChgCode.Account__c, activeChgCode);
				}

			}

			ANG_AgencyChangesConfigHelper.ChangesConfig config = ANG_AgencyChangesConfigHelper.getConfig(oscar, AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);

			changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.APPROVAL, allAccountsInvolvedSet, changesContainer);

		}
		else if(oscar.STEP4__c == AMS_Utils.PASSED && oldOSCAR.STEP4__c != AMS_Utils.PASSED){
			
			Set<Id> allAccountsInvolvedSet = fetchAccountIdsToBeProcessed(oscar.Id);
			allAccountsInvolvedSet.add(oscar.Account__c);

			changesContainer.accountsMap = getAccounts(allAccountsInvolvedSet);

			for(Account acct : changesContainer.accountsMap.values()){

				Agency_Applied_Change_code__c activeChgCode = fetchActiveChangeCodeFromAccount(acct);

				if(activeChgCode != NULL){
					accountsCurrentChangeCode.put(activeChgCode.Account__c, activeChgCode);
				}

			}

			ANG_AgencyChangesConfigHelper.ChangesConfig config = ANG_AgencyChangesConfigHelper.getConfig(oscar, AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY);
			
			changesContainer = generateNewGenChangeCodes(oscar, config, accountsCurrentChangeCode, AMS_Utils.WITHDRAWAL, allAccountsInvolvedSet, changesContainer);

		}
		
		if(changesContainer.changesStruct != NULL){
			changesContainer = ANGcreateAAChangeCodes(changesContainer.changesStruct.values(), changesContainer.changeCodesToCreateDef, new List<AMS_OSCAR__c> {oscar}, changesContainer.accountsToApplyChangeCodes, false, changesContainer);
		}

		if(changesContainer != NULL){
			changesContainer.runUpsert();
		}

	}

	public static void performRiskEventActions(AMS_OSCAR__c oscar, String oldParentHierarchyId, Id newParentId, List<Account> accountLst){
		    
		if(containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY,AMS_Utils.ANG_LOCATION_TYPE},oscar.ANG_Type_Of_Change__c)){
			System.enqueueJob(new ANG_Risk_Helper.FutureHandler(new Map<Id,Id>{oldParentHierarchyId => oscar.Account__c}));
		}
		
		if(containsChange(new List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){

			List<ANG_Agency_Risk_Event__c> riskEventsToDeactivateLst = new List<ANG_Agency_Risk_Event__c>();
			
			for(Account acct : accountLst){
				List<ANG_Agency_Risk_Event__c> riskEventsLst = (List<ANG_Agency_Risk_Event__c>) acct.getSObjects('Location_Risk_Events__r');

				if(riskEventsLst != NULL && !riskEventsLst.isEmpty()){
					riskEventsToDeactivateLst.addAll(riskEventsLst);
				}
			}

			System.enqueueJob(new ANG_Risk_Helper.FutureHandler(riskEventsToDeactivateLst, newParentId));

		}
        
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

	public static AChangeStructure processHierarchyChangesAux(AMS_OSCAR__c oscar, AChangeStructure changesContainer, Set<Id> accountIdsInvolvedSet, Boolean isAllHierarchySelected, Map<Id, List<AMS_Agencies_relationhip__c>> allRelations, Boolean isMulticountry) {
		
        System.debug('[ANG_AgencyChangesHelper] - Accounts involved are:'+accountIdsInvolvedSet);
        System.debug('[ANG_AgencyChangesHelper] - ChangesContainer is'+changesContainer);
        System.debug('[ANG_AgencyChangesHelper] - isAllHierarchySelected is'+isAllHierarchySelected);

		if (containsChange(New List<String>{AMS_Utils.ANG_LOCATION_TYPE, AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY},oscar.ANG_Type_Of_Change__c))
			changesContainer = applyChangeOfLocationType(oscar, changesContainer,allRelations, isMulticountry);
		else if (containsChange(New List<String>{AMS_Utils.ANG_HIERARCHY},oscar.ANG_Type_Of_Change__c)){
		
			changesContainer = applyChangeOfHierarchy(oscar, changesContainer, accountIdsInvolvedSet, isAllHierarchySelected, isMulticountry, allRelations);
		
			//For the Change Of Hierarchy (HE Included), we need to take care of the hidden accounts 
			//(with Status terminated, "Terminated", "Not accreditated","New application pending" and "Not in Operation") and disconnect them from their parent

			if(isAllHierarchySelected){
				changesContainer = detachTerminatedAccountsFromHierarchy(allRelations,changesContainer);
			}
		
		}
		
		return changesContainer;
	}

	public static AChangeStructure  detachTerminatedAccountsFromHierarchy(Map<Id, List<AMS_Agencies_relationhip__c>> allRelations, AChangeStructure toReturn){

		Set<AMS_Agencies_Hierarchy__c> hierarchiesToDelete = new Set<AMS_Agencies_Hierarchy__c>();

		Set<String> terminatedStatus = new Set <String>{AMS_Utils.ACC_S0_TERMINATED, AMS_Utils.ACC_S1_NOTACCREDITED, AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING, AMS_Utils.ACC_S3_NOTINOPERATION, ''};
		
		List<AMS_Agencies_relationhip__c> relToDelete = new List<AMS_Agencies_relationhip__c>();

		for(List<AMS_Agencies_relationhip__c> rels: allRelations.values()){
			for(AMS_Agencies_relationhip__c rel:rels){
				
				if(String.isBlank(rel.Child_Account__r.Status__c) || terminatedStatus.contains(rel.Child_Account__r.Status__c)){
					
					Account childAccount = toReturn.accountsMap.get(rel.Child_Account__c) != null ?  toReturn.accountsMap.get(rel.Child_Account__c) : new Account(Id = rel.Child_Account__c);

					childAccount.ParentId = null;
					childAccount.Top_Parent__c = null;

					toReturn.addAccount(childAccount);

					relToDelete.add(rel);
					hierarchiesToDelete.add(new AMS_Agencies_Hierarchy__c(Id = rel.hierarchy__c));
				}
			
			}
		}

		if(!relToDelete.isEmpty()){
			delete relToDelete;
		}

		if(!hierarchiesToDelete.isEmpty()){
			delete new List<AMS_Agencies_Hierarchy__c>(hierarchiesToDelete);
		}
		
		return toReturn;

	}

	/**
	* Applies change of location type for multicountry agents
	* 
	* @param oscarToProcess: AMS_OSCAR__c
	* @param toReturn: AChangeStructure 
	* @param accountHierarchyRelationships: Map<Id, List<AMS_Agencies_relationhip__c>>
	* 
	* @return toReturn: AChangeStructure (could be avoided since the object is passed by reference)
	*
	*/
	public static AChangeStructure applyChangeOfLocationTypeMulticountry(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){

		// The hierarchy object ID. In case there is new GE Account, we need to change the Main_Account__c field on the hierarchy.
		Id hierarchyId;
		
		//Accounts Map contains only the two agencies that we are gonna swap
		Map<Id, Account> accountsMap = toReturn.accountsMap.deepClone();
		
		//Swap location types and related fields (parents + RHC info & risk fields if GE is involved)
		ANG_MulticountryHelper.SwapAccountsWrapper swapAccountsWrapper = ANG_MulticountryHelper.swapAccountsLocationType(accountsMap, toReturn);

		//Fetch all the agencies from the hierarchy 
		if(accountHierarchyRelationships == null){
			accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});
		}
		
		//Update the necessary relationships and respective accounts 
		for(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			hierarchyId = rel.Hierarchy__c;

			Account childAcct  = accountsMap.get(rel.Child_Account__c);
			Account parentAcct = accountsMap.get(rel.Parent_Account__c);

			Id childBSP = rel.Child_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c;
			
			//If the GE was involved in the swap we need to update the relation 
			Boolean needsUpdate = (swapAccountsWrapper.newGE != NULL);

			//If the change of location involves both of the accounts
			//from this relationship (rel) we basically swap them
			if(childAcct != NULL && parentAcct != NULL){
				rel.Child_Account__c = parentAcct.Id;
				rel.Parent_Account__c = childAcct.Id;
				needsUpdate = true;
			}
			else {

				//Means that the current child in this relationship was swapped 
				if(childAcct != NULL){
					//If we are upon a change of location involving different BSPs
					//and the given child is the new GE the parent in this relationship 
					//must be updated to become the new GE
					if(swapAccountsWrapper.diffBSP && childAcct.Id == swapAccountsWrapper.newGE){
						rel.Parent_Account__c = swapAccountsWrapper.newGE;
					}
					//The previous child becomes the correspondent swapped account
					rel.Child_Account__c = swapAccountsWrapper.swapMapping.get(rel.Child_Account__c).Id;
					needsUpdate = true;
				}

				
				if(parentAcct != NULL && //Means that the current parent in this relationship is being swapped
					(!swapAccountsWrapper.diffBSP || //if in the scope of a location change in the same BSP 
					//If we are swapping an AE with a GE and the current child 
					//in the relationship is not in the old GE's BSP (location change in different BSPs)
					(childBSP != swapAccountsWrapper.bspOldGE && swapAccountsWrapper.swapAE) || 
					//If the current child is in a BSP not involved in the swap (location change in different BSPs)
					(childBSP != swapAccountsWrapper.bspNewGE && childBSP != swapAccountsWrapper.bspOldGE))
				){
					//The previous parent becomes the correspondent swapped account 
					rel.Parent_Account__c = swapAccountsWrapper.swapMapping.get(rel.Parent_Account__c).Id;
					needsUpdate = true;
				}

				//If both of the accounts in this relationship were NOT involved in the swap
				//and the BSP of the given child account is the same as the new GE's BSP 
				//we need to update the parent to be the new GE
				if(childAcct == NULL && parentAcct == NULL && childBSP == swapAccountsWrapper.bspNewGE){
					rel.Parent_Account__c = swapAccountsWrapper.newGE;
					needsUpdate = true;
				}

			}

			if(needsUpdate){
				
				//If the child in this relationship was not involved in the swap
				//we need to update the account itself (parent and eventually top parent if the GE was swaped)
				if(childAcct == NULL){

					Account acct  = new Account(Id = rel.Child_Account__c);

					//Update the parent according to the new parent in this relationship
					acct.ParentId = rel.Parent_Account__c;

					//If we are upon a change of location involving different BSPs
					//and the given child was an HE that remained in the BSP of the new GE 
					//the location type of this account must be set as AE so that the hierarchy remains valid
					if(swapAccountsWrapper.diffBSP && rel.Child_Account__r.Location_Type__c == AMS_Utils.HE && childBSP == swapAccountsWrapper.bspNewGE){
						acct.Location_Type__c = AMS_Utils.AE;
					}

					//If there is a new GE in the hierarchy we must update the top parent
					if(swapAccountsWrapper.newGE != NULL){
						acct.Top_Parent__c = swapAccountsWrapper.newGE;
					}

					//Add the account to be updated
					toReturn.addAccount(acct);
				
				}
				
				//Add the relationship to be updated
				toReturn.addRelation(rel);

			}
		
		}

		if(swapAccountsWrapper.newGE <> NULL){
			AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(id = hierarchyId, Main_account__c = swapAccountsWrapper.newGE);
			toReturn.addHierarchy(hierarchy);
		}
		
		return toReturn;
	
	}

	public static AChangeStructure applyChangeOfLocationType(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships){
		return applyChangeOfLocationType(oscarToProcess, toReturn, accountHierarchyRelationships, false);
	}

	public static AChangeStructure applyChangeOfLocationType(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships, Boolean isMulticountry){

		if(isMulticountry){
			System.debug('[ANG_AgencyChangesHelper] Performing change of Location Type for Multicountry');
			return applyChangeOfLocationTypeMulticountry(oscarToProcess, toReturn, accountHierarchyRelationships);
		}

		// 1) need to fetch all the relations on the hierarchy
		// 2) need to fetch all the accounts involved in this "swap"
		// 3) need to change all the relations in the hierarchy to apply the new Parent
		// 4) need to change all the parent accounts and the location type of all agencies involved
		// 5) swap IEP information between old and new HE.

		System.debug('[ANG_AgencyChangesHelper] Performing change of Location Type');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		AMS_Agencies_Hierarchy__c hierarchy = null;

		if(accountHierarchyRelationships == null)
			accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c});

		for(AMS_Agencies_relationhip__c rel : accountHierarchyRelationships.get(oscarToProcess.Account__c)){

			if(rel.Child_Account__c == oscarToProcess.Account__c){
				
				Account parentAccount = [Select Id, Location_Type__c, ParentId, ANG_IEP_HE_AccntNum__c, ANG_IEP_Status__c, ANG_HE_CashCondition__c, ANG_HE_RiskHistoryAssessment__c, ANG_HE_RiskStatus__c, Financial_Review_Result__c, CNS_Agency__c, Financial_Assessment_Points__c, (SELECT Id, ANG_AccountId__c FROM RHC_Informations__r) From Account where Id =:rel.Parent_Account__c];

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
				childAccount.Financial_Assessment_Points__c = parentAccount.Financial_Assessment_Points__c;

				parentAccount.ANG_IEP_HE_AccntNum__c = null;
				parentAccount.ANG_IEP_Status__c = null;
				parentAccount.ANG_HE_CashCondition__c = false;
				parentAccount.ANG_HE_RiskHistoryAssessment__c = null;
				parentAccount.ANG_HE_RiskStatus__c = null;
				parentAccount.Financial_Assessment_Points__c = null;

				rel.Child_Account__c = rel.Parent_Account__c;

				toReturn.addAccount(parentAccount);
				toReturn.addAccount(childAccount);

				ANG_RHCHelper.moveRHCInfos(parentAccount.RHC_Informations__r, new Map<Id,Id>{rel.Child_Account__c => oscarToProcess.Account__C});

				hierarchy = new AMS_Agencies_Hierarchy__c(Id=rel.Hierarchy__c, Main_Account__c = childAccount.Id);

				toReturn.addHierarchy(hierarchy);

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
	
	public static AChangeStructure applyChangeOfHierarchyMulticountry(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Set<Id> accountIdsInvolvedSet, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchiesRelationships, Boolean isAllHierarchySelected){

		ANG_MulticountryHelper.TargetHierarchyWrapper thw = null;

		Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = hierarchiesRelationships;

		if(accountHierarchyRelationships == NULL){
			accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarToProcess.Account__c, oscarToProcess.New_parent__c});
		}

		Map<Id, Id> hePerBspMapping = new Map<Id, Id>();
				
		if(String.isNotBlank(oscarToProcess.HE_per_BSP_Mapping__c)){
			hePerBspMapping = (Map<Id, Id>) JSON.deserialize(oscarToProcess.HE_per_BSP_Mapping__c, Map<Id, Id>.class);
		}

		Account oscarAccount = toReturn.accountsMap.get(oscarToProcess.Account__c);

		Id topParentId = oscarAccount.Top_Parent__c != NULL ? oscarAccount.Top_Parent__c : oscarAccount.Id;

		if(!accountIdsInvolvedSet.contains(topParentId)){
			toReturn.addAccountToCalculateRiskAssessment(topParentId);
		}

		toReturn.addAccountToCalculateRiskAssessment(oscarToProcess.New_parent__c);

		Boolean isHierarchySplit = accountIdsInvolvedSet.contains(oscarToProcess.New_parent__c);

		if(isHierarchySplit){
			
			oscarToProcess.Generate_risk_event_MC__c = true;
			AMS_Agencies_Hierarchy__c newHierarchy = new AMS_Agencies_Hierarchy__c();
			newHierarchy.Hierarchy_Name__c = 'NewGen Hierarchy';
			newHierarchy.Main_Account__c = oscarToProcess.New_parent__c;
			insert newHierarchy;

			thw = new ANG_MulticountryHelper.TargetHierarchyWrapper();

			thw.hierarchyId = newHierarchy.Id;
			thw.targetGE = toReturn.accountsMap.get(oscarToProcess.New_parent__c);

			thw.hierarchyBspMap = new Map<Id, Account>{
				thw.targetGE.IATA_ISO_Country__r.AMS_Settlement_System__c => thw.targetGE
			};

		}
		else {
			thw = ANG_MulticountryHelper.prepareTargetHierarchyData(accountHierarchyRelationships.get(oscarToProcess.New_parent__c));
		}

		List<AMS_Agencies_relationhip__c> acquiredHierarchyLst = accountHierarchyRelationships.get(oscarToProcess.Account__c);
		List<ANG_MulticountryHelper.AgenciesRelationshipWrapper> acquiredHierarchyWrapperLst = ANG_MulticountryHelper.prepareAcquiredHierarchyData(acquiredHierarchyLst, hePerBspMapping);

		integer i = 0;
		integer listSize = acquiredHierarchyWrapperLst.size();
		Set<Id> processedAgenciesIdSet = new Set<Id>();

		while(i < listSize){
			AMS_Agencies_relationhip__c relation = acquiredHierarchyWrapperLst.get(i).relation;

			Account parentAccount = toReturn.accountsMap.get(relation.Parent_Account__c);
			Account childAccount = toReturn.accountsMap.get(relation.Child_Account__c);

			if(parentAccount != NULL && !processedAgenciesIdSet.contains(parentAccount.Id)){
				ANG_MulticountryHelper.processAgency(parentAccount, oscarToProcess.Account__c, oscarToProcess.New_parent__c, relation.Parent_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, null, thw, toReturn, isHierarchySplit);
				processedAgenciesIdSet.add(parentAccount.Id);
			}

			if(childAccount != NULL && !processedAgenciesIdSet.contains(childAccount.Id)){
				ANG_MulticountryHelper.processAgency(childAccount, oscarToProcess.Account__c, oscarToProcess.New_parent__c, relation.Child_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, relation, thw, toReturn, isHierarchySplit);
				processedAgenciesIdSet.add(childAccount.Id);
			}

			i++;
		}

		return toReturn;
		
	}

	public static AChangeStructure applyChangeOfHierarchy(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Set<Id> accountIdsInvolvedSet, Boolean isAllHierarchySelected){
		return applyChangeOfHierarchy(oscarToProcess, toReturn, accountIdsInvolvedSet, isAllHierarchySelected, false, null);
	}

	public static AChangeStructure applyChangeOfHierarchy(AMS_OSCAR__c oscarToProcess, AChangeStructure toReturn, Set<Id> accountIdsInvolvedSet, Boolean isAllHierarchySelected, Boolean isMulticountry, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchiesRelationships){

		if(isMulticountry){
			System.debug(LoggingLevel.FINE, '____ [cls ANG_AgencyChangesHelper - applyChangeOfHierarchy] Performing change of hierarchy for multicountry');
			return applyChangeOfHierarchyMulticountry(oscarToProcess, toReturn, accountIdsInvolvedSet, hierarchiesRelationships, isAllHierarchySelected);
		}

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

		Account newHEaccount = toReturn.accountsMap.get(oscarToProcess.New_parent__c);

		if((!accountIdsInvolvedSet.contains(oscarToProcess.New_parent__c) && oscarToProcess.Account__c != oscarToProcess.New_parent__c)){

			//Map<Id,Account> accountsMap;

			if(newHEaccount == null)
				newHEaccount = [Select Id , ANG_Accreditation_Model__c, Remittance_frequency__c, CNS_Agency__c, ANG_FA_Opt_out__c from Account where Id = :oscarToProcess.New_parent__c];

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
				/** NEWGEN-5751 */
				newH.Main_Account__c = oscarToProcess.New_parent__c;
				insert newH;

				hierarchyId = newH.Id;
				

				System.debug('[ANG_AgencyChangesHelper] Inserted new Hierarchy with Id:' + newH.Id + ' since the destination account is a single Account.');
			}

			Account oscarAccount = toReturn.accountsMap.get(oscarToProcess.Account__c) != null ? toReturn.accountsMap.get(oscarToProcess.Account__c) : new Account(Id = oscarToProcess.Account__c);
			
			if(oscarAccount.Location_type__c == AMS_Utils.HE){
				// it should have his own hierarchy, so we need to remove it since he is becoming an AE.
				System.debug('[ANG_AgencyChangesHelper] Deleting Hierarchy since the main account is becoming an AE');
				delete [Select Id from AMS_Agencies_Hierarchy__c where Main_account__c = :oscarAccount.Id LIMIT 1];
			}

			oscarAccount.Location_Type__c = AMS_Utils.AE;
			oscarAccount.Financial_Assessment_Points__c = null;
			oscarAccount.ParentId = oscarToProcess.New_parent__c;
			oscarAccount.Top_Parent__c = oscarToProcess.New_parent__c;
			oscarAccount.ANG_IEP_HE_AccntNum__c = null;
			oscarAccount.ANG_IEP_Status__c = null;
			oscarAccount.ANG_HE_CashCondition__c = false;
			oscarAccount.ANG_HE_RiskHistoryAssessment__c = null;
			oscarAccount.ANG_HE_RiskStatus__c = null;
			oscarAccount.Assessment_Performed_Date__c = null;
			oscarAccount.Financial_Review_Result__c = null;
			oscarAccount.ANG_FA_Opt_out__c = newHEaccount.ANG_FA_Opt_out__c;

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

			newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy', Main_account__C = oscarToProcess.New_parent__c);
			insert newH;
			System.debug('[ANG_AgencyChangesHelper] - Inserted new Hierarchy with Id:' + newH.Id);

		}else{

			hierarchyId = fetchHierarchyFromExternalAccount(oscarToProcess.New_parent__c);
			if(hierarchyId == null){
				newH = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Newgen Hierarchy',Main_account__c = oscarToProcess.New_parent__c);
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
			a.Financial_Assessment_Points__c = null;

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

		System.debug('[ANG_AgencyChangesHelper] sizeOfOldRelations:'+ sizeOfOldRelations);
		System.debug('[ANG_AgencyChangesHelper] sizeOfDeletedRelations:'+ sizeOfDeletedRelations);
		System.debug('[ANG_AgencyChangesHelper] oldHierarchyId:'+ oldHierarchyId);
		System.debug('[ANG_AgencyChangesHelper] isAllHierarchySelected:'+ isAllHierarchySelected);

		//since now all single agency hierarchies have a Hierarchy, only if all hierarchy is Migrated we delete the hierarchy.
		if(sizeOfOldRelations == sizeOfDeletedRelations && oldHierarchyId != null && isAllHierarchySelected){

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

	public static List<AMS_Process_Detail__c> fetchAmsProcessDetails(Id oscarId){
		return new List<AMS_Process_Detail__c>(
			[SELECT
				Id,
				OSCAR__c,
				Account__c,
				Account__r.IATA_ISO_Country__c,
				ANG_Location_Type_Conversion__c,
				Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c
			 FROM AMS_Process_Detail__c
			 WHERE
			 	OSCAR__c = :oscarId
			]
		);
	}	

	public static Set<Id> fetchAccountIdsToBeProcessed(Id oscarId){

		Set<Id> toReturn = new Set<Id>();

		if(oscarId != null){
			For(AMS_Process_Detail__c pd : fetchAmsProcessDetails(oscarId)){
				toReturn.add(pd.Account__c);
			}
		}

		return toReturn;

	}

	public static Id fetchHierarchyFromExternalAccount(Id accountId){

		List<AMS_Agencies_Hierarchy__c> hierarchies = [Select Id from AMS_Agencies_Hierarchy__c where Main_account__c = :accountId];
		
		if(!hierarchies.isEmpty()){
			return hierarchies.get(0).Id;
		}

		List<AMS_Agencies_relationhip__c> rels = [Select Id, Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c = :accountId];

		if(!rels.isEmpty()){
			return rels.get(0).Hierarchy__c;
		}

		return null;
				
	}

	public static AChangeStructure applyChangeOfFields(AMS_OSCAR__c oscarToProcess, Set<Id> accountsAffected, AChangeStructure toReturn, AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation){

		//NEWGEN-4299 - force Risk related information to be recalculated in account
		Map<Id,Map<Id,Integer>> involvedAccounts = new Map<Id,Map<Id,Integer>>();	

		System.debug('[ANG_AgencyChangesHelper] Performing change of fields');

		if(toReturn == null)
			toReturn = new AChangeStructure();

		Set<Id> accountsToUpdateRHC = new Set<Id>();

		System.debug('[ANG_AgencyChangesHelper] - Types of Change (' + oscarToProcess.ANG_Type_Of_Change__c + ') ');

		Set<String> fieldsToMigrate = ANG_AgencyChangesConfigHelper.getFieldsToMigrate(oscarToProcess.ANG_Type_Of_Change__c);

		Account oscarAcc = toReturn.accountsMap.get(oscarToProcess.Account__c);

		if(oscarAcc != null && oscarAcc.IATA_ISO_Country__r.AMS_Settlement_System__r.Remittance_Frequency_per_State__c && oscarToProcess.ANG_Type_Of_Change__c == AMS_Utils.LOCATION) fieldsToMigrate.add('Remittance_frequency__c');

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

                if(oscarToProcess.Process__c ==  AMS_Utils.NGCORRECTION && oscarToProcess.ANG_PCI_compliance_expiry_date__c != null && oscarToProcess.ANG_PCI_compliance_expiry_date__c != acc.ANG_PCI_compliance_expiry_date__c){
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

                    
					if(toReturn.accountsMap.containsKey(accId) && (toReturn.accountsMap.get(accId).Location_Type__c == AMS_Utils.HE || toReturn.accountsMap.get(accId).Location_Type__c == AMS_Utils.GE) && (oscarToProcess.ANG_Type_Of_Change__c == AMS_Utils.VFMR || (oscarToProcess.ANG_Type_Of_Change__c == AMS_Utils.LOCATION && acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Remittance_Frequency_per_State__c && accFieldApiName == 'Remittance_frequency__c' && oldValue != newValue))){
						involvedAccounts.put(accID,null);
						
						if(accFieldApiName == 'Remittance_frequency__c' && oldValue != newValue){
							toReturn.addAccountToRecalculateRHC(accId);
						}
					}

					acc.put(accFieldApiName, accountFieldNewValue.get(accFieldApiName));
				}

				AMS_ChangeCodesHelper.ObjectChangesStruct acctChangesStruct = new AMS_ChangeCodesHelper.ObjectChangesStruct(objectChangesList);

				toReturn.addAccount(acc);
				if(toReturn.changesStruct.get(acc.Id) == null)
					toReturn.changesStruct.put(acc.Id,acctChangesStruct);
				else
					toReturn.changesStruct.get(acc.Id).changes.addAll(objectChangesList);
			}

			if(!involvedAccounts.isEmpty()) new ANG_RiskAssessmentEngine(involvedAccounts).assessment();

		}

		//this would overwrite existing struct, create a new method in the wrapper to add content in this struct
		//toReturn.addChangesStruct(accountsToUpdate);

		return toReturn;

	}

	public static void recalculateRHCInformation(Set<Id> accountIds){

		List<ANG_RHC_Information__c> rhcInfoList = new List<ANG_RHC_Information__c>();
		Set<Id> accountIdsToProcess = new Set<Id>();

		for(ANG_RHC_Information__c r : [SELECT ANG_RHC_Amount_Equals_FS__c, CurrencyIsoCode, Id, ANG_AccountId__c, ANG_CashCondition__c, ANG_Financial_Security__c, ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RME_Amount__c, ANG_Exceeding_Financial_Security__c, ANG_RHC_Amount_Provisional__c, RHC_Amount_Equals_FS_Percent__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN :accountIds and ANG_AccountId__r.ANG_CashCondition__c = false]){
			rhcInfoList.add(r);
			accountIdsToProcess.add(r.ANG_AccountId__c);
		}

		if(!rhcInfoList.isEmpty()){
			ANG_RHCHelper.calculateRHCAmount(rhcInfoList);
			update rhcInfoList;
		}

		if(!accountIdsToProcess.isEmpty()){
			if(Limits.getLimitQueueableJobs() <= Limits.getQueueableJobs())
				Database.executeBatch(new ANG_UpdateRHCInformationBatch(accountIdsToProcess, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, false, 1));
			else 
				System.enqueueJob(new ANG_UpdateRHCInformationQueueable(accountIdsToProcess, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, false, 1));
		}
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

			Account currentAcc = toReturn.accountsMap.get(accId);

			if(AMS_AccountRoleCreator.totalCoveredOwnershipByAccount.containsKey(accId) ||
                (currentAcc.Top_Parent__c != null && AMS_AccountRoleCreator.totalCoveredOwnershipByAccount.containsKey(currentAcc.Top_Parent__c)))
				currentAcc.Covered_Ownership__c = AMS_AccountRoleCreator.totalCoveredOwnershipByAccount.get(currentAcc.Top_Parent__c == null ? accId : currentAcc.Top_Parent__c);
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
		
		List<Agency_Authorization__c> toUpsert = new List<Agency_Authorization__c>();

		List<Account> accs = [SELECT ID,Country_ISO_Code__c, (SELECT Id ,Account__c, Status__c FROM Agency_Authorizations__r
															  WHERE ANG_FormOfPayment_ID__c = 'CA' and Status__c != 'Active' and RecordType.DeveloperName = 'FormOfPayment')
							FROM ACCOUNT WHERE ID IN :accountsAffected];

		Id formOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		for(Account a: accs){
			if(a.Agency_Authorizations__r.isEmpty())
				toUpsert.add(new Agency_Authorization__c(Account__c = a.id, ANG_FormOfPayment_ID__c = 'CA', 
					Status__c = AMS_Utils.setChinaCountries.contains(a.Country_ISO_Code__c) ? 'Authorized' : 'Active', RecordTypeId = FormOfPaymentRT));
			else{
				for(Agency_Authorization__c aa : a.Agency_Authorizations__r){
					aa.Status__c = AMS_Utils.setChinaCountries.contains(a.Country_ISO_Code__c) ? 'Authorized' : 'Active';
					toUpsert.add(aa);
				}
			}
		}
		return toUpsert;
	}

	public static boolean validateTypeOfChange(AMS_OSCAR__c oscar, String accreditationModel) {

		System.debug('[ANG_AgencyChangesHelper] Validating type of change for ANG Changes process.');

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		List<String> oscarStepsApiName = AMS_Utils.getOSCARStepsApiName();

		if (oscar.ANG_Type_Of_Change__c <> oldMap.get(oscar.Id).ANG_Type_Of_Change__c && oldMap.get(oscar.Id).STEP6__c == AMS_Utils.PASSED && !isMigrationRunning)
		{
			oscar.addError('Type of Change cannot be changed after Sanity Check is passed.');
			return false;
		}

		if (oscar.ANG_Type_Of_Change__c <> oldMap.get(oscar.Id).ANG_Type_Of_Change__c || oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {
			ANG_AgencyChangesConfigHelper.ChangesConfig config = ANG_AgencyChangesConfigHelper.getConfig(oscar,accreditationModel);
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
				ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
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
		        ANG_IsNewGenAgency__c, ANG_FA_Opt_out__c, CNS_Agency__c, ANG_PCI_compliance_expiry_date__c, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c, Covered_Ownership__c,
		        ANG_IEP_Status__c, ANG_HE_RiskStatus__c, ANG_IEP_HE_AccntNum__c, ANG_HE_CashCondition__c, Financial_Review_Result__c, ANG_HE_RiskHistoryAssessment__c, Financial_Assessment_Points__c, IATA_ISO_Country__r.AMS_Settlement_System__r.Remittance_Frequency_per_State__c,
				Identify_as_Multicountry_Key_Hierarchy__c, Multicountry_Key_Hierarchy__c, IATA_ISO_Country__r.AMS_Settlement_System__c, IATA_ISO_Country__r.ANG_RHC_LocationType__c, 
				(SELECT Id, ANG_AccountId__c FROM RHC_Informations__r), (SELECT Id FROM Location_Risk_Events__r), (SELECT Id FROM Main_Accounts__r), (SELECT Id, ANG_Account__c FROM Risk_Alerts__r),
				(SELECT Id FROM ChildAccounts WHERE Status__c IN ('', NULL, :AMS_Utils.ACC_S0_TERMINATED, :AMS_Utils.ACC_S1_NOTACCREDITED, :AMS_Utils.ACC_S3_NOTINOPERATION)),
				(SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c FROM Agencies_Applied_Change_codes__r WHERE Active__c = true),
				(SELECT Id, Account__c, Status__c, RecordTypeId, ANG_FormOfPayment_ID__c FROM Agency_Authorizations__r WHERE RecordType.DeveloperName = 'FormOfPayment')
		         FROM Account WHERE Id IN :accountIds]);
	}

	/**
	Returns operations and respective BSP Configurations
	*/
	private static List<AMS_Settlement_System__c> fetchOperationConfiguration(Set<Id> countryIds, Id settlementRTId, Set<Id> operationsInputIds, String classType) {

		Set<Id> operationsIds = new Set<Id>();

		if(operationsInputIds != NULL && !operationsInputIds.isEmpty()){
			operationsIds.addAll(operationsInputIds);
		}

		if(CountryIds != null){
			for(IATA_ISO_Country__c  country : IATAIsoCountryDAO.getIsoCountriesByIds(countryIds)){
				if(country.AMS_Settlement_System__c != null) operationsIds.add(country.AMS_Settlement_System__c);
			}
		}
		
        return Database.query('SELECT Id, Allow_multiple_remittances__c, (SELECT Remittance_Frequency__c, Remittances_Per_Year__c FROM BSP_Attributes__r' +(classType != null ? ' WHERE Class_Type__c = :classType' : '') +' ORDER BY Remittances_Per_Year__c DESC) FROM AMS_Settlement_System__c WHERE RecordtypeID = :settlementRTId' + (OperationsIds != null ? ' AND Id IN :operationsIds' : ''));	}

	/**
	Returns operationCodes and respective BSP Configurations
	*/
	public static List<AMS_Settlement_System__c> fetchOperationConfiguration(Id settlementRTId, Set<Id> operationsIds) {

		return fetchOperationConfiguration(null, settlementRTId, operationsIds, null);
	}

	/**
	Returns operationCodes and respective BSP Configurations
	*/
	public static List<AMS_Settlement_System__c> fetchOperationConfiguration(Id settlementRTId, Id countryId, String classType) {

		return fetchOperationConfiguration(new Set<Id>{countryId}, settlementRTId, null, classType);
	}

	/**
	Returns a Map of Operations for the given accounts
	*/
	public static Map<Id,Account> fetchAgOperationPerAccount(List<Id> accIds) {

		Map<Id,Account> bspPerAcc = new Map<Id,Account>();
		for(Account agOp : [SELECT Id, IATA_ISO_Country__r.AMS_Settlement_System__c, IATA_ISO_Country__r.AMS_Settlement_System__r.RecordType.Name FROM Account WHERE Id in :accIds])
			bspPerAcc.put(agOp.IATA_ISO_Country__r.AMS_Settlement_System__c,agOp);

		return bspPerAcc;
	}

	    /**

     Create Change Codes NEW Method that creates Change Code History Objects

    */

	public static AChangeStructure ANGcreateAAChangeCodes(List<AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges, List<AMS_OSCAR_JSON.ChangeCode> changeCodes, List<AMS_OSCAR__c> oscars, List<Account> oscarAgencies, Boolean isToUpdateAccounts, ANG_AgencyChangesHelper.AChangeStructure changesContainer) {

		System.debug('[ANG_AgencyChangesHelper].ANGcreateAAChangeCodes List<AMS_ChangeCodesHelper.ObjectChangesStruct> objectChanges = '+ objectChanges);//param 1
		System.debug('[ANG_AgencyChangesHelper].ANGcreateAAChangeCodes List<AMS_OSCAR_JSON.ChangeCode> changeCodes = '+ changeCodes);//param 2
		System.debug('[ANG_AgencyChangesHelper].ANGcreateAAChangeCodes oscars = '+oscars);//param 3
		System.debug('[ANG_AgencyChangesHelper].ANGcreateAAChangeCodes oscarAgencies = '+oscarAgencies);//param 5
		System.debug('[ANG_AgencyChangesHelper].ANGcreateAAChangeCodes changesContainer:'+ changesContainer);////param 6

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
			
			AMS_ChangeCodesHelper.ChangeCodeStruct changeCodeResult;
			
            if(objectChanges != null && !objectChanges.isEmpty()){
				if(objectChanges.size() == 1)
					objectChangesByChangeCode = objectChanges.get(0);
				else
					objectChangesByChangeCode = objectChanges.get(index);
			
			}
            
            if(cc.Name == 'COR'){
            	for(Account ac : oscarAgencies){//when changeCode = COR, same change code for all Acc
            		changeCodeResult = AMS_ChangeCodesHelper.createAAChangeCode(objectChangesByChangeCode,cc, oscars.get(0), ac, isActive, fOPs.get(accId));
            		changesContainer.addChangeCode(changeCodeResult.changeCode);

					aaccHistoryToProcess.put(accId, changeCodeResult);
		
					if (!accountsToUpdate.contains(changeCodeResult.acct)){
						changesContainer.addAccount(changeCodeResult.acct);
					}
            	}
            }
            else{
				changeCodeResult = AMS_ChangeCodesHelper.createAAChangeCode(objectChangesByChangeCode,cc, oscars.get(0), oscarAgencies.get(index), isActive, fOPs.get(accId));
            	changesContainer.addChangeCode(changeCodeResult.changeCode);

				aaccHistoryToProcess.put(accId, changeCodeResult);
	
				if (!accountsToUpdate.contains(changeCodeResult.acct)){
					changesContainer.addAccount(changeCodeResult.acct);
				}
            }
			index++;
		}

		if(changesContainer.changeCodesToCreate != null && !changesContainer.changeCodesToCreate.isEmpty())
		{
			system.debug('changeCodesToCreate: ' + changesContainer.changeCodesToCreate);

			if(changesContainer.changeCodesToCreate.size() < CHANGECODES_THRESHOLD || (Limits.getLimitQueueableJobs() - Limits.getQueueableJobs()) <= 0){

				insert changesContainer.changeCodesToCreate;

				//create history for ebulletin
				AMS_ChangeCodesHelper.createAAChangeCodesHistory(changesContainer.changeCodesToCreate, aaccHistoryToProcess.values());

			} else {

				System.enqueueJob(new ANG_ChangeCodesCreation(changesContainer.changeCodesToCreate, aaccHistoryToProcess.values()));
			}

		}

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

	/* NEWGEN-4856 - When performing a change of Location / Hierarchy  
	 	* Move the Risk Alerts into the Main account 
	 	* Set Monitored Account with the previous account when Sanity Check is passed 
    */
    private static void processRiskAlerts(AChangeStructure changesContainer, Id newParentId){
			
			for(Account acct : changesContainer.accountsMap.values()){
				
				//Skip risk alerts for the new parent 
				//in case of change of location type
				if(acct.Id == newParentId){
					continue;
				}

				List<ANG_Risk_Alert__c> riskAlertsLst = (List<ANG_Risk_Alert__c>) acct.getSObjects('Risk_Alerts__r');

				if(riskAlertsLst != NULL && !riskAlertsLst.isEmpty()){
					moveRiskAlerts(riskAlertsLst, newParentId);
					changesContainer.addRiskAlertsToUpdate(riskAlertsLst);
				}

			}
			
		}
		
		private static void processRiskAlerts(AChangeStructure changesContainer, Id accountToFetchRiskAlerts, Id newParentId){
			
			List<ANG_Risk_Alert__c> riskAlertsLst = new List<ANG_Risk_Alert__c>(
				[SELECT Id, ANG_Account__c 
				 FROM ANG_Risk_Alert__c 
				 WHERE ANG_Account__c = :accountToFetchRiskAlerts
				]
			);

			if(!riskAlertsLst.isEmpty()){
				moveRiskAlerts(riskAlertsLst, newParentId);
				changesContainer.addRiskAlertsToUpdate(riskAlertsLst);
			}

		}

		private static void moveRiskAlerts(List<ANG_Risk_Alert__c> riskAlertsLst, Id newParentId){
			for(ANG_Risk_Alert__c ra : riskAlertsLst){
				ra.Monitored_Account__c = ra.ANG_Account__c;
				ra.ANG_Account__c = newParentId;
			}
		}

		private static Agency_Applied_Change_Code__c fetchActiveChangeCodeFromAccount(Account acct){
			List<Agency_Applied_Change_code__c> changeCodeLst = (List<Agency_Applied_Change_code__c>) acct.getSObjects('Agencies_Applied_Change_Codes__r');
			if(changeCodeLst != NULL && !changeCodeLst.isEmpty()){
				return changeCodeLst.get(0);
			}
			return null;
		}

		private static Map<Id, Agency_Applied_Change_Code__c> fetchActiveChangeCodesFromAccounts(List<Account> accountLst){
			
			Map<Id, Agency_Applied_Change_Code__c> accountsCurrentChangeCode = new Map<Id, Agency_Applied_Change_Code__c>();

			for(Account acct : accountLst){
				Agency_Applied_Change_code__c activeChgCode = fetchActiveChangeCodeFromAccount(acct);
				if(activeChgCode != NULL){
					accountsCurrentChangeCode.put(activeChgCode.Account__c, activeChgCode);
				}
			}

			return accountsCurrentChangeCode;

		}
}
