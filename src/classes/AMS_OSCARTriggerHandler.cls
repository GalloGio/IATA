public class AMS_OSCARTriggerHandler {

	//*************************************
	//************ variables **************
	//*************************************

	class AMSException extends Exception {}
	
	public static Map<String, String> closedStatusMapping{
		get{
			if(closedStatusMapping == null){
				closedStatusMapping = new Map<String, String>{
					'Closed (Closed)' => 'Closed',
					'Closed_Not Accepted' => 'Closed_ Not Accepted',
					'Closed_Rejected' => 'Closed_Rejected',
					'Closed_Withrawn' => 'Closed_Withdrawn'
				};
			}
			return closedStatusMapping;
		}
		set;
	}

	//used to identify situations where the LocationType of an SA Agency should not be changed
	public static boolean keepSALocationTypeFlag = false;

	//*************************************
	//********* context methods ***********
	//*************************************

	public static void handleBeforeUpdate(List<AMS_OSCAR__c> oscars) {
		prepopulateValues();
		AMS_AccreditationContactHelper.mirrorAccrediationContactsFromAccountRole(oscars, (Map<Id,AMS_OSCAR__c>)Trigger.oldMap);
		handleChangesProcess(oscars);
	}

	public static void handleBeforeInsert() {
		prepopulateValues();
		AMS_AccreditationContactHelper.mirrorAccrediationContactsFromAccountRole((List<AMS_OSCAR__c>)Trigger.New, null);
	}

	public static void handleAfterInsert() {
		updateCaseKPIFields();
	}

	public static void handleAfterUpdate() {
		
		updateCaseKPIFields();
		updateCaseInfo();
	}

	//*************************************
	//********** helper methods ***********
	//*************************************
	private static void prepopulateValues() {
		//AMS-1674 - [Agency changes] when "Type of change" include "Location type" the "Change of location type behavior" shoule be pre-populated

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		for(AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New){
			if(
				oscar.Process__c == AMS_Utils.AGENCYCHANGES
				&& oscar.Type_of_change__c != null
				&& oscar.Change_of_location_type_behavior__c == null
				//&& (Trigger.isInsert || oscar.Type_of_change__c != oldMap.get(oscar.Id).Type_of_change__c)
			){
			    Set<String> tocList = new Set<String>();
			    tocList.addAll(oscar.Type_of_change__c.split(';'));

		        if(tocList.contains(AMS_Utils.LOCATION_TYPE)){
		            oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_STANDARD;
		        }

			}
		}
	}

	public static void handleChangesProcess(List<AMS_OSCAR__c> oscars) {

		//do Not run minor changes on agency changes trigger????
		AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;

		List<AMS_OSCAR__c> oscarsToValidate = getAgencyChangeOSCARS(oscars);

		if (oscarsToValidate.size() > 0) {

			List<Map<String, String>> configs = AMS_AgencyChangesConfigHelper.getAgencyChangesConfigData();

			validateTypeOfChange(oscarsToValidate, configs);
	
			List<AMS_OSCAR__c> oscarsToProcess = getAgencyChangeOSCARSToProcess(oscarsToValidate);

			if (oscarsToProcess.size() > 0)
				processAgencyChanges(oscarsToProcess, configs);
		}
	}

	public static void validateTypeOfChange(List<AMS_OSCAR__c> oscars, List<Map<String, String>> configs) {

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		List<String> oscarStepsApiName = getOSCARStepsApiName();

		for (AMS_OSCAR__c oscar : oscars) {

			if (oscar.Type_of_change__c <> oldMap.get(oscar.Id).Type_of_change__c && oldMap.get(oscar.Id).STEP6__c == AMS_Utils.PASSED)
					oscar.addError('Type of Change cannot be changed after Sanity Check is passed.');


			if (oscar.Type_of_change__c <> oldMap.get(oscar.Id).Type_of_change__c || oldMap.get(oscar.Id).STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {
				AMS_Utils.AgChangesConfig config = AMS_AgencyChangesConfigHelper.getSelectedTypeOfChangeCombinationConfig(oscar, configs);
				if (config != null && config.config != null) {
					List<String> notApplicableSteps = AMS_AgencyChangesConfigHelper.getNotApplicableSteps(config.config);
					if (notApplicableSteps != null)
						AMS_AgencyChangesConfigHelper.setNotApplicableSteps(notApplicableSteps, oscarStepsApiName, oscar);
				}
			}
		}
	}

	public static Map<String, Schema.SObjectField> getOSCARFieldMap() {

		return Schema.getGlobalDescribe().get('AMS_OSCAR__c').getDescribe().fields.getMap();

	}

	public static List<String> getOSCARStepsApiName() {

		List<String> oscarSteps = new List<String>();

		for (String fieldApiName : getOSCARFieldMap().keySet()) {
			if (fieldApiName.startsWithIgnoreCase('STEP'))
				oscarSteps.add(fieldApiName);

		}

		return oscarSteps;
	}

	public static List<AMS_OSCAR__c> getAgencyChangeOSCARS(List<AMS_OSCAR__c> oscars) {

		ID changeRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

		List<AMS_OSCAR__c> changeOscars = new List<AMS_OSCAR__c>();
		for (AMS_OSCAR__c oscar : oscars) {
			if (oscar.recordTypeID == changeRT)
				changeOscars.add(oscar);
		}

		return changeOscars;
	}

	//get only the Agency Change OSCARs that need to be processed
	private static List<AMS_OSCAR__c> getAgencyChangeOSCARSToProcess(List<AMS_OSCAR__c> oscars) {

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		ID changeRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

		List<AMS_OSCAR__c> changeOscars = new List<AMS_OSCAR__c>();
		for (AMS_OSCAR__c oscar : oscars) {
			if (oscar.recordTypeID == changeRT) {
				AMS_OSCAR__c oldOSCAR = oldMap.get(oscar.Id);
				if ((oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) || (oldOSCAR.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL) || (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED))
					changeOscars.add(oscar);

			}
		}

		return changeOscars;
	}

	public static void processAgencyChanges(List<AMS_OSCAR__c> oscars, List<Map<String, String>> configs) {

		boolean isSanityCheck = false;

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		//map that will be used to verify ownership consistency between a list of agencies
		Map<Id, Set<Id>> accsToCompareOwnership = new Map<Id, Set<Id>>();

		//map that given an agency will give us the id of its terminated child accounts
		Map<Id, Set<Id>> agencyTerminatedChildAgencies = new Map<Id, Set<Id>>();

		//this Container will store all change codes that need to be created
		List<AMS_Utils.Container> changesContainer = new List<AMS_Utils.Container>();

		//store all the updates to be made on account as consequence of migration of data from staging area to master data
		List<Account> accountsToUpdate = new List<Account>();

		//this structure contains all the hierarchy relationships that need to be inserted/updated/deleted
		List<AMS_HierarchyHelper.HierarchyStruct> hierarchyChanges = new List<AMS_HierarchyHelper.HierarchyStruct>();

		Set<Id> accountIds = new Set<Id>();
		Set<Id> oscarIds = new Set<Id>();
		Set<Id> oscarOnlineAccredIds = new Set<Id>();

		Map<Id, List<AMS_Process_Detail__c>> processDetailPerOSCAR = new Map<Id, List<AMS_Process_Detail__c>>();

		for (AMS_OSCAR__c oscar : oscars) {
			accountIds.add(oscar.Account__c);
			accountIds.add(oscar.AMS_Target_Agency__c);
			oscarIds.add(oscar.Id);
			oscarOnlineAccredIds.add(oscar.AMS_Online_Accreditation__c);
		}

		//query the the Process Detail object for all the agencies that are being bought
		List<AMS_Process_Detail__c> allProcessDetails = new List<AMS_Process_Detail__c>([SELECT Id, Account__c, OSCAR__c, Account__r.Status__c FROM AMS_Process_Detail__c WHERE OSCAR__c IN :oscarIds]);

		for (AMS_Process_Detail__c pd : allProcessDetails) {
			//TERMINATED AGENCIES IGNORED
			if(pd.Account__c != null && pd.Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED){
				if (processDetailPerOSCAR.get(pd.OSCAR__c) == null)
					processDetailPerOSCAR.put(pd.OSCAR__c, new List<AMS_Process_Detail__c> {pd});
				else
					processDetailPerOSCAR.get(pd.OSCAR__c).add(pd);
			}

		}

		//need to get all the hierarchy relationships for the account related to each OSCAR
		Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(accountIds);

		for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {
			for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {

				accountIds.add(relationship.Parent_Account__c);
				accountIds.add(relationship.Child_Account__c);

				if(relationship.Child_Account__r.Status__c == AMS_Utils.ACC_S0_TERMINATED){
					if(!agencyTerminatedChildAgencies.containsKey(relationship.Parent_Account__c))
						agencyTerminatedChildAgencies.put(relationship.Parent_Account__c, new Set<Id>());

					agencyTerminatedChildAgencies.get(relationship.Parent_Account__c).add(relationship.Child_Account__c);
					
				}

			}
		}

		//need to find the list of SAs directly related to the each account related to an OSCAR
		Map<Id, Set<Id>> agencyToSAs = new Map<Id, Set<Id>>();
		
		for(AMS_OSCAR__c oscar : oscars){
			for (List<AMS_Agencies_relationhip__c> hierarchyRelations : accountHierarchyRelationships.values()) {
				for (AMS_Agencies_relationhip__c relationship : hierarchyRelations) {

					if(relationship.Parent_Account__c == oscar.Account__c && 
						relationship.Child_Account__r.Location_Type__c==AMS_Utils.SA && 
						relationship.Child_Account__r.Status__c!=AMS_Utils.ACC_S0_TERMINATED){
						if(agencyToSAs.get(oscar.Account__c)==null)
							agencyToSAs.put(oscar.Account__c, new Set<Id>());
						agencyToSAs.get(oscar.Account__c).add(relationship.Child_Account__c);
                        system.debug(LoggingLevel.ERROR,'[LF]: Agenzia '+oscar.Account__c+' ha SA '+relationship.Child_Account__c);
					}

				}
			}
		}
		system.debug(LoggingLevel.ERROR,'[LF]: FINE CALCOLO SA');

		//get the active changecode for each account
		List<Agency_Applied_Change_code__c> activeChangeCodes =
		    new List<Agency_Applied_Change_code__c>([SELECT Id, Account__c, Reason_Code__c, Reason_Description__c FROM Agency_Applied_Change_code__c WHERE Account__c IN :accountIds AND Active__c = true]);

		//map accountId -> active change code
		Map<Id, Agency_Applied_Change_code__c> accountsChangeCode = new Map<Id, Agency_Applied_Change_code__c>();
		for (Id accId : accountIds) {
			for (Agency_Applied_Change_code__c changeCode : activeChangeCodes)
				if (changeCode.Account__c == accId)
					accountsChangeCode.put(accId, changeCode);
		}

		Map<Id, Account> accounts = new Map<Id, Account>([SELECT Id, ParentId, Parent.Location_Type__c, Status__c, Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
		        BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
		        ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
		        Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c FROM Account WHERE Id IN :accountIds]);


		Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
		        ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
		        Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
		        Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
		        Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
		        Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name
		        FROM AMS_Pax_Accreditation_Form__c
		        WHERE Id IN :oscarOnlineAccredIds]);

		//Here we will save the accounts that will suffer ownership changes
		Map<Id, Set<Id>> accountsAffectedPerOnlineAccreditation = new Map<Id, Set<Id>>();

		AMS_Utils.AgChangesConfig config;
		//configuration used when we need to apply a different change Code on agencies in Process Detail
		AMS_Utils.AgChangesConfig config2;
		//configuration used when we need to apply a different change Code for change of location to SAs
		AMS_Utils.AgChangesConfig config3;

		system.debug('processAgencyChanges() --> oscars = ' + oscars);
		for (AMS_OSCAR__c oscar : oscars) {

			AMS_OSCAR__c oldOSCAR = oldMap.get(oscar.Id);

			system.debug('processAgencyChanges() --> oscar = ' + oscar.Type_of_change__c + ' - oscar.staging = ' + oscar.AMS_Online_Accreditation__c);
			if (oscar.Type_of_change__c != null) {

				//Separate types of changes in 2 groups:
				//types of changes to be applied on all the hierarchy agencies defined in the Process Detail plus the Agency where the OSCAR was opened
				String cascadingTOCs = AMS_AgencyChangesConfigHelper.getPropagatableTypesOfChange(oscar.Type_of_change__c);

				//types of changes only to be applied on the Agency where the OSCAR was opened
				String nonCascadingTOCs =  AMS_AgencyChangesConfigHelper.getNonPropagatableTypesOfChange(oscar.Type_of_change__c);

				System.debug('AGENCY CHANGES: Propagate changes selected: ' + cascadingTOCs);
				System.debug('AGENCY CHANGES: Non Propagate changes selected: ' + nonCascadingTOCs);

				config = AMS_AgencyChangesConfigHelper.getSelectedTypeOfChangeCombinationConfig(oscar, configs);

				if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0)
					config2 = AMS_AgencyChangesConfigHelper.getTypeOfChangeCombinationConfig(cascadingTOCs, oscar, configs);

				List<AMS_Process_Detail__c> pds = processDetailPerOSCAR.get(oscar.Id);

				Set<Id> agenciesAffected = new Set<Id>();

				if (pds != null)
					for (AMS_Process_Detail__c pd : pds)
						agenciesAffected.add(pd.Account__c);

				AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = onlineAccreditations.get(oscar.AMS_Online_Accreditation__c);

				Id hierarchyHO = AMS_HierarchyHelper.getHierarchyHO(accountHierarchyRelationships.get(oscar.Account__c));

				Set<String> tocList = new Set<String>();
				tocList.addAll(oscar.Type_of_change__c.split(';'));


				//this is used by change of location: create a list of SAs involved in the change and SA not involved in the change
				boolean changeContainsLocation = (nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION) || nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE));
				String changeOfLocation = '';
				if (nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION))
					changeOfLocation = AMS_Utils.LOCATION;
				else if (nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE))
					changeOfLocation = AMS_Utils.LOCATION_INSPECTION;

				Set<Id> SAsInvolved = new Set<Id>();
				Set<Id> SAsNotInvolved = new Set<Id>();

				if(changeContainsLocation && agencyToSAs.get(oscar.Account__c)!=null){	
					config3 = AMS_AgencyChangesConfigHelper.getTypeOfChangeCombinationConfig(changeOfLocation, oscar, configs);
			
					for(Id sa : agencyToSAs.get(oscar.Account__c)){
						boolean found = false;
						for(Id ag : agenciesAffected){
							if(sa==ag){
								SAsInvolved.add(sa);
								found = true;
								break;
							}
						}
						if(!found)
							SAsNotInvolved.add(sa);
					}
					system.debug(LoggingLevel.ERROR,'[LF]: SAS affected: '+SAsInvolved);
					system.debug(LoggingLevel.ERROR,'[LF]: SAS NOT affected: '+SAsNotInvolved);
				}
				if (oldOSCAR.STEP6__c <> AMS_Utils.PASSED && oscar.STEP6__c == AMS_Utils.PASSED) {

					isSanityCheck = true;

					if(!performOscarValidations(toclist, agenciesAffected, oscar, accounts, accountHierarchyRelationships))
						return;

					//Location Type will always be selected as a single change.
					if (nonCascadingTOCs.length() > 0 && nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE)) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing change of location type in sanity checks');

						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, new Set<Id> {oscar.Account__c, hierarchyHO}));
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, new Set<Id> {oscar.Account__c, hierarchyHO}, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));
					}
					// here there are several possible cases:
					else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing both cascade and not cascade changes in sanity checks');
						Set<Id> agenciesWithSingleCode = agenciesAffected.clone(); // normally this list includes all the agencies listed in the hierarchy account selection
						Set<Id> agenciesWithMultipleCode = new Set<Id> {oscar.Account__c}; // normally only the main agency is affected by all the changes
						
						// in case of change which includes location, the SAs should be affected  by the change of location so:
						if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
							agenciesWithSingleCode.removeAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection should not receive a partial change 
							agenciesWithMultipleCode.addAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection will be affected by the complete change
							// the SAs which are not listed in the hierarchy account selection will be affected by change of location only!
						}

						system.debug(LoggingLevel.ERROR, '[LF]: Main '+oscar.Account__c);
						system.debug(LoggingLevel.ERROR, '[LF]: agenciesAffected '+agenciesAffected);
						system.debug(LoggingLevel.ERROR, '[LF]: SAsInvolved '+SAsInvolved);
                        system.debug(LoggingLevel.ERROR, '[LF]: SAsNotInvolved '+SAsNotInvolved);
						system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithMultipleCode '+agenciesWithMultipleCode);
						system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithSingleCode '+agenciesWithSingleCode);

						// Apply cascade changes: change code + data migration
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, agenciesWithSingleCode, cascadingTOCs, accounts, oscarOnlineAccreditation));
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config2, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, agenciesWithSingleCode));


						// Apply cascade + no cascade changes: change code + data migration
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, agenciesWithMultipleCode, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, agenciesWithMultipleCode));


						// Apply change of location to children SAs not explicitly involved in the change
						if(SAsNotInvolved.size()>0){
							//change code generated only for the agencies not affected by any other change
							accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, SAsNotInvolved, changeOfLocation, accounts, oscarOnlineAccreditation));
							changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config3, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, SAsNotInvolved));
						}

					} else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() == 0) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing not cascade changes in sanity checks');
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, new Set<Id> {oscar.Account__c}));
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, new Set<Id> {oscar.Account__c}, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));

						// in case of location (for the moment is 100% but only God knows what will happen in the future)
						// I'll apply the change and generate a CHL also to the SAs  
						if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
							changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, SAsNotInvolved));
							accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, SAsNotInvolved, changeOfLocation, accounts, oscarOnlineAccreditation));
						}

					} else if (nonCascadingTOCs.length() == 0 && cascadingTOCs.length() > 0) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing cascade changes in sanity checks');
						agenciesAffected.add(oscar.Account__c);
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.SANITYCHECK, agenciesAffected));
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, agenciesAffected, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));
						// change of location is not affecting this scenario
					}

					agenciesAffected.add(oscar.Account__c);

					Boolean isChangeOwnershipToIATA = tocList.contains(AMS_Utils.OWNERSHIP_IATA) ? true : false;
					//All terminated agencies that would be left without parent MUST be automatically migrated, thus following their parents
					//Exception to the above rule is when we have change of ownership to IATA, where BRs will be left as standalone
					Set<Id> agenciesToMigrate = AMS_HierarchyHelper.addTerminatedDescendants(agenciesAffected, agencyTerminatedChildAgencies, isChangeOwnershipToIATA, accounts);
					system.debug('AgenciesToMigrateHierarchy: ' + agenciesToMigrate);
					system.debug('AgenciesToMigrateData: ' + agenciesAffected);

					AMS_HierarchyHelper.HierarchyStruct hs = processHierarchyChanges(oscar, accounts, accountHierarchyRelationships, agenciesToMigrate);

					hierarchyChanges.add(hs);

					//check if ownership needs to be copied from online form to Accounts
					if (AMS_Utils.ownershipIsToBeMigrated(oscar.Type_of_change__c)){
						accountsAffectedPerOnlineAccreditation.put(oscar.AMS_Online_Accreditation__c, agenciesAffected);

						//fill map to check ownership alignment in hierarchy
						if(cascadingTOCs.contains(AMS_Utils.OWNERSHIP_IATA)){
							//the target agency owners will be compared with the agency owners we are trying to migrate to the target agency hierarchy
							Set<Id> agsToCompareOwner = new Set<Id>(agenciesAffected);
							agsToCompareOwner.add(oscar.AMS_Target_Agency__c);
							accsToCompareOwnership.put(oscar.Id, agsToCompareOwner);
						}

					}

					

				} else if (oldOSCAR.RPM_Approval__c <> AMS_Utils.AUTH_APPROVAL && oscar.RPM_Approval__c == AMS_Utils.AUTH_APPROVAL) {


					//Location Type will always be selected as a single change.
					if (nonCascadingTOCs.length() > 0 && nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE)) {
						System.debug('AGENCY CHANGES: Processing Location Type Change Codes on approval.');

						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.APPROVAL, new Set<Id> {oscar.Account__c, hierarchyHO}));
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, new Set<Id> {oscar.Account__c, hierarchyHO}, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));
					}
					//need to apply two different Sets of Change Codes. One for Oscar Account and other for process details
					// here there are several possible cases:
					else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing both cascade and not cascade changes on approval');
						Set<Id> agenciesWithSingleCode = agenciesAffected.clone(); // normally this list includes all the agencies listed in the hierarchy account selection
						Set<Id> agenciesWithMultipleCode = new Set<Id> {oscar.Account__c}; // normally only the main agency is affected by all the changes
						
						// in case of change which includes location, the SAs should be affected  by the change of location so:
						if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
							agenciesWithSingleCode.removeAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection should not receive a partial change 
							agenciesWithMultipleCode.addAll(SAsInvolved); // the SAs which are also listed in the hierarchy account selection will be affected by the complete change
							// the SAs which are not listed in the hierarchy account selection will be affected by change of location only!
						}

						system.debug(LoggingLevel.ERROR, '[LF]: Main '+oscar.Account__c);
						system.debug(LoggingLevel.ERROR, '[LF]: agenciesAffected '+agenciesAffected);
						system.debug(LoggingLevel.ERROR, '[LF]: SAsInvolved '+SAsInvolved);
                        system.debug(LoggingLevel.ERROR, '[LF]: SAsNotInvolved '+SAsNotInvolved);
						system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithMultipleCode '+agenciesWithMultipleCode);
						system.debug(LoggingLevel.ERROR, '[LF]: agenciesWithSingleCode '+agenciesWithSingleCode);

						// Apply cascade changes: change code + data migration
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, agenciesWithSingleCode, cascadingTOCs, accounts, oscarOnlineAccreditation));
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config2, accounts, accountsChangeCode, AMS_Utils.APPROVAL, agenciesWithSingleCode));


						// Apply cascade + no cascade changes: change code + data migration
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, agenciesWithMultipleCode, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.APPROVAL, agenciesWithMultipleCode));


						// Apply change of location to children SAs not explicitly involved in the change
						if(SAsNotInvolved.size()>0){
							//change code generated only for the agencies not affected by any other change
							accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, SAsNotInvolved, changeOfLocation, accounts, oscarOnlineAccreditation));
							changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config3, accounts, accountsChangeCode, AMS_Utils.APPROVAL, SAsNotInvolved));
						}

						
					} else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() == 0) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing not cascade changes on approval');
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.APPROVAL, new Set<Id> {oscar.Account__c}));
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, new Set<Id> {oscar.Account__c}, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));

						// in case of location (for the moment is 100% but only God knows what will happen in the future)
						// I'll apply the change and generate a CHL also to the SAs  
						if(changeContainsLocation  && agencyToSAs.get(oscar.Account__c)!=null){
							changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.APPROVAL, SAsNotInvolved));
							accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, SAsNotInvolved, changeOfLocation, accounts, oscarOnlineAccreditation));
						}

					} else if (nonCascadingTOCs.length() == 0 && cascadingTOCs.length() > 0) {
						system.debug(LoggingLevel.ERROR,'[LF]: AMS_OSCARTriggerHandler() Processing cascade changes on approval');
						agenciesAffected.add(oscar.Account__c);
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.APPROVAL, agenciesAffected));
						accountsToUpdate.addAll(AMS_Utils.copyDataToAccountForAgencyChanges(oscar, agenciesAffected, oscar.Type_of_change__c, accounts, oscarOnlineAccreditation));
						// change of location is not affecting this scenario
					}

					//APPLY HIERARCHY CHANGES
					//Hierarchy changes are applied to the agencies in the process detail and also to the OSCAR Account
					agenciesAffected.add(oscar.Account__c);

					/*MOVED TO SANITY CHECK
					Boolean isChangeOwnershipToIATA = tocList.contains(AMS_Utils.OWNERSHIP_IATA) ? true : false;
					//All terminated agencies that would be left without parent MUST be automatically migrated, thus following their parents
					//Exception to the above rule is when we have change of ownership to IATA, where BRs will be left as standalone
					Set<Id> agenciesToMigrate = AMS_HierarchyHelper.addTerminatedDescendants(agenciesAffected, agencyTerminatedChildAgencies, isChangeOwnershipToIATA, accounts);
					system.debug('AgenciesToMigrateHierarchy: ' + agenciesToMigrate);
					system.debug('AgenciesToMigrateData: ' + agenciesAffected);

					AMS_HierarchyHelper.HierarchyStruct hs = processHierarchyChanges(oscar, accounts, accountHierarchyRelationships, agenciesToMigrate);

					hierarchyChanges.add(hs);
					************************/

					//check if ownership needs to be copied from online form to Accounts
					if (AMS_Utils.ownershipIsToBeMigrated(oscar.Type_of_change__c)){
						accountsAffectedPerOnlineAccreditation.put(oscar.AMS_Online_Accreditation__c, agenciesAffected);

						//fill map to check ownership alignment in hierarchy
						if(cascadingTOCs.contains(AMS_Utils.OWNERSHIP_IATA)){
							//the target agency owners will be compared with the agency owners we are trying to migrate to the target agency hierarchy
							Set<Id> agsToCompareOwner = new Set<Id>(agenciesAffected);
							agsToCompareOwner.add(oscar.AMS_Target_Agency__c);
							accsToCompareOwnership.put(oscar.Id, agsToCompareOwner);
						}

					}


				} else if (oldOSCAR.STEP4__c <> AMS_Utils.PASSED && oscar.STEP4__c == AMS_Utils.PASSED) {
					if (nonCascadingTOCs.length() > 0 && nonCascadingTOCs.containsIgnoreCase(AMS_Utils.LOCATION_TYPE)) {
						System.debug('AGENCY CHANGES: Processing Location Type Change Codes on Withdrawal.');

						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.WITHDRAWAL, new Set<Id> {oscar.Account__c, hierarchyHO}));
					} else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() > 0) {
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config2, accounts, accountsChangeCode, AMS_Utils.WITHDRAWAL, agenciesAffected));

						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.WITHDRAWAL, new Set<Id> {oscar.Account__c}));
					} else if (nonCascadingTOCs.length() > 0 && cascadingTOCs.length() == 0) {
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.WITHDRAWAL, new Set<Id> {oscar.Account__c}));
					} else if (nonCascadingTOCs.length() == 0 && cascadingTOCs.length() > 0) {
						agenciesAffected.add(oscar.Account__c);
						changesContainer.add(AMS_ChangeCodesHelper.generateChangeCodes(oscar, config, accounts, accountsChangeCode, AMS_Utils.WITHDRAWAL, agenciesAffected));
					}

				}

			}
		}


		Savepoint sp = Database.setSavepoint();

		try {

			List<Account> accsToUpdateFromCC = new List<Account>();

			//insert the change codes
			if (changesContainer.size() > 0) {
				List<AMS_OSCAR_JSON.ChangeCode> changeCodes = new List<AMS_OSCAR_JSON.ChangeCode>();
				List<Account> accts = new List<Account>();
				List<AMS_OSCAR__c> theoscars = new List<AMS_OSCAR__c>();

				//merge everything
				for (AMS_Utils.Container c : changesContainer) {
					changeCodes.addAll(c.changeCodes);
					accts.addAll(c.accts);
					theoscars.addAll(c.oscars);
					}

				//create change codes
				accsToUpdateFromCC = AMS_Utils.createAAChangeCodes(changeCodes, theoscars, accts, false);
			}

			List<Account> mergedAccountUpdate = mergeAccountsToUpdate(accsToUpdateFromCC, accountsToUpdate);

			if (!mergedAccountUpdate.isEmpty()) {
				AMS_AccountTriggerHandler.processMinorChangesValidationFlag = true;
 				update mergedAccountUpdate;
				AMS_AccountTriggerHandler.processMinorChangesValidationFlag = false;
			}

			if (hierarchyChanges.size() > 0) {
				List<AMS_Agencies_Hierarchy__c> allHierarchiesToInsert = new List<AMS_Agencies_Hierarchy__c>();
				List<AMS_Agencies_relationhip__c> allRelationsToUpdate = new List<AMS_Agencies_relationhip__c>();
				List<AMS_Agencies_relationhip__c> allRelationsToInsert = new List<AMS_Agencies_relationhip__c>();
				List<AMS_Agencies_relationhip__c> allRelationsToDelete = new List<AMS_Agencies_relationhip__c>();
				List<Id> allHierarchiesToDelete = new List<Id>();

				for (AMS_HierarchyHelper.HierarchyStruct hs : hierarchyChanges) {
					if (hs.relationsToUpdate != null)
						allRelationsToUpdate.addAll(hs.relationsToUpdate);
					if (hs.relationsToInsert != null)
						allRelationsToInsert.addAll(hs.relationsToInsert);
					if (hs.relationsToDelete != null)
						allRelationsToDelete.addAll(hs.relationsToDelete);
					if (hs.hierarchiesToDelete != null)
						allHierarchiesToDelete.addAll(hs.hierarchiesToDelete);
				}

				if (!allRelationsToDelete.isEmpty())
					delete allRelationsToDelete;
				if (!allRelationsToUpdate.isEmpty())
					update allRelationsToUpdate;
				if (!allRelationsToInsert.isEmpty())
					insert allRelationsToInsert;

				if(!allHierarchiesToDelete.isEmpty()){
					List<AMS_Agencies_Hierarchy__c> hierarchiesDel = new List<AMS_Agencies_Hierarchy__c>([SELECT Id FROM AMS_Agencies_Hierarchy__c WHERE Id IN :allHierarchiesToDelete]);
					if (!hierarchiesDel.isEmpty())
						delete hierarchiesDel;
				}

			}

			//Migrate Ownership
			if (!accountsAffectedPerOnlineAccreditation.isEmpty()) {
				system.debug('processAgencyChanges() --> accountsAffectedPerOnlineAccreditation = ' + accountsAffectedPerOnlineAccreditation);

				AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(accountsAffectedPerOnlineAccreditation, !isSanityCheck);

				//verify ownership alignment
				if(accsToCompareOwnership.size()>0 && !AMS_HierarchyHelper.checkHierarchyIntegrity(accsToCompareOwnership))
					throw new AMSException('Performing this operation will result in hierarchy ownership inconsistency. Please make sure the owners being processed match with the owners of the target agency.');
			}



		} catch (Exception ex) {
			System.debug('DML exception: ' + ex);
			Database.rollback(sp);
			throw ex;
		}

	}

	public static AMS_HierarchyHelper.HierarchyStruct processHierarchyChanges(AMS_OSCAR__c oscar, Map<Id, Account> accounts, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies, Set<Id> agenciesAffected) {

		keepSALocationTypeFlag = false;

		//this container will store all database operations that need to be performed
		AMS_HierarchyHelper.HierarchyStruct hierarchyChanges = new AMS_HierarchyHelper.HierarchyStruct();



		Set<String> tocList = new Set<String>();
		tocList.addAll(oscar.Type_of_change__c.split(';'));

		Account oscarAccount = accounts.get(oscar.Account__c);

		if (tocList.contains(AMS_Utils.LOCATION_TYPE))
			hierarchyChanges = processChangeOfLocationType(oscar, accounts, hierarchies);
		else if (tocList.contains(AMS_Utils.OWNERSHIP_IATA)) {
			keepSALocationTypeFlag = true;
			hierarchyChanges = processChangeOfOwnershipToIATA(oscar, hierarchies, agenciesAffected, accounts);
		} else if (tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) {
			keepSALocationTypeFlag = true;
			hierarchyChanges = processChangeOfOwnershipToNonIATA(oscar, accounts, hierarchies, agenciesAffected);
			//change of location for SA where the oscar has a target agency defined. this requires the SA to move under the target agency
		} else if ((tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) && oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.SA) && oscar.AMS_Target_Agency__c != null) {
			keepSALocationTypeFlag = true;
			hierarchyChanges = processSAChangeOfLocation(oscar, accounts, hierarchies);
		}

		return hierarchyChanges;
	}

	public static AMS_HierarchyHelper.HierarchyStruct processChangeOfLocationType(AMS_OSCAR__c oscar, Map<Id, Account> accounts, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies) {


		Id oscarAccountId = oscar.Account__c;

		//get the parent of the oscar account
		Account child = accounts.get(oscarAccountId);

		Account parent;

		if (child != null && child.parentId != null)
			parent = accounts.get(child.parentId);

		system.debug('AGENCY CHANGES: the parent that will become child: ' + parent);

		List<AMS_Agencies_relationhip__c> hierarchyRelationships = hierarchies.get(oscar.Account__c);

		if (child != null && parent != null)
			return AMS_HierarchyHelper.switchParentWithChild(child.Id, parent.Id, oscar.Change_of_location_type_behavior__c, accounts, hierarchyRelationships);

		throw new AMSException('Data inconsistency issue.');

	}

	public static AMS_HierarchyHelper.HierarchyStruct processChangeOfOwnershipToIATA(AMS_OSCAR__c oscar, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies, Set<Id> agenciesAffected, Map<Id, Account> accounts) {

		System.debug('AGENCY CHANGES: Processing change of ownership. Scenario IATA Buys IATA');

		Id targetHierarchyHO = oscar.AMS_Target_Agency__c;
		//the hierarchy relationships where the agencies will be migrated to
		List<AMS_Agencies_relationhip__c> newHierarchy = hierarchies.get(targetHierarchyHO);
		List<AMS_Agencies_relationhip__c> currentHierarchy = hierarchies.get(oscar.Account__c);
		AMS_HierarchyHelper.HierarchyStruct relationshipsToManage;

		relationshipsToManage = AMS_HierarchyHelper.migrateAccountsToExistingHierarchy(oscar.Account__c, currentHierarchy, targetHierarchyHO, newHierarchy, agenciesAffected, accounts);

		if (relationshipsToManage.errorMessage != null)
			oscar.addError(relationshipsToManage.errorMessage);

		return relationshipsToManage;

	}

	public static AMS_HierarchyHelper.HierarchyStruct processChangeOfOwnershipToNonIATA(AMS_OSCAR__c oscar, Map<Id, Account> accounts, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies, Set<Id> agenciesAffected) {
		//DEFINE A SET OF LOCATION CLASSES WHERE THE LOGIC SHOULD BE APPLIED

		System.debug('AGENCY CHANGES: Processing change of ownership. Scenario Non IATA Buys IATA');

		List<AMS_Agencies_relationhip__c> accountHierarchy = hierarchies.get(oscar.Account__c);
		AMS_HierarchyHelper.HierarchyStruct relationshipsToManage;

		//get the relationships that need to be updated/inserted/deleted
		relationshipsToManage = AMS_HierarchyHelper.migrateAccountsToNewHierarchy(oscar.Account__c, accounts, accountHierarchy, agenciesAffected);

		if (relationshipsToManage.errorMessage != null)
			oscar.addError(relationshipsToManage.errorMessage);

		return relationshipsToManage;
	}

	public static AMS_HierarchyHelper.HierarchyStruct processSAChangeOfLocation(AMS_OSCAR__c oscar, Map<Id, Account> accounts, Map<Id, List<AMS_Agencies_relationhip__c>> hierarchies) {

		System.debug('AGENCY CHANGES: Processing change of location. OSCAR opened on SA and has a Target agency defined.');

		Id oscarAccountId = oscar.Account__c;

		//the child in the relation that needs to be moved
		Account child = accounts.get(oscarAccountId);
		//the new parent for the child
		Account parent = accounts.get(oscar.AMS_Target_Agency__c);

		List<AMS_Agencies_relationhip__c> hierarchyRelationships = hierarchies.get(oscar.Account__c);

		if (child != null && parent != null)
			return AMS_HierarchyHelper.reparentChildSA(child.Id, parent.Id, accounts, hierarchyRelationships);

		throw new AMSException('Data inconsistency issue.');

	}

	public static boolean performOscarValidations(Set<String> toclist, Set<Id> agenciesAffected, AMS_OSCAR__c oscar, Map<Id, Account> accounts, Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships) {

		boolean validationsPassed = true;
		Set<Id> agenciesToMigrate = new Set<Id>(agenciesAffected);
		agenciesToMigrate.add(oscar.Account__c);

		//Do not allow change of ownerships that leave an hierarchy without an HO
		if (tocList.contains(AMS_Utils.OWNERSHIP_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) {
			//Set<Id> agenciesToMigrate = new Set<Id>(agenciesAffected);
			//agenciesToMigrate.add(oscar.Account__c);
			Set<Id> agenciesNotMigrated = AMS_HierarchyHelper.getAccountNotMigrated(accountHierarchyRelationships.get(oscar.Account__c), agenciesToMigrate);
			String error = AMS_HierarchyHelper.validateIncompleteMigration(agenciesNotMigrated);
			if (error != null){
				oscar.addError(error);
				validationsPassed=false;
			}
		}

		if (tocList.contains(AMS_Utils.OWNERSHIP_IATA) && oscar.AMS_Target_Agency__c == null){
			oscar.AMS_Target_Agency__c.addError('The field "Target Agency" is mandatory when a change of ownership to IATA agent is being performed.');
			validationsPassed= false;
		}


		Account oscarAccount = accounts.get(oscar.Account__c);
		if (tocList.contains(AMS_Utils.LOCATION_TYPE)){
			//block change of location type in Head Office
			if(oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.HO) || oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.AO)){
				oscar.addError('OSCAR for Change of Location Type cannot be performed in an HO.');
				validationsPassed=false;
			}

			else if(oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.BR)){
				if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP){
					oscar.Change_of_location_type_behavior__c.addError('The field Change of location type behavior cannot have value Dont change the parent when the OSCAR is opened for a Branch.');
					validationsPassed=false;
				}
			}
			//do not allow change of location type behaviour to be dont change the parent when the oscar agency is directly under an HO
			else if(oscarAccount.Parent.Location_Type__c.equalsIgnoreCase(AMS_Utils.HO) || oscarAccount.Parent.Location_Type__c.equalsIgnoreCase(AMS_Utils.AO)){
				if(oscar.Change_of_location_type_behavior__c == AMS_Utils.CHLOCTYPEBEHAVIOR_NOSWAP){
					oscar.Change_of_location_type_behavior__c.addError('The field Change of location type behavior cannot have value Dont change the parent when the oscar is opened for an account directly under an HO.');
					validationsPassed=false;
				}
			}

		}else{
			//Only allowed to be filled in for change of Location Type
			if(oscar.Change_of_location_type_behavior__c != null){
				oscar.Change_of_location_type_behavior__c.addError('The field Change of location type behavior can only be filled for changes of Location Type.');
				validationsPassed=false;
			}
		}


		//Target Agency field validations
		if (oscar.AMS_Target_Agency__c != null){
			//Target Agency field only allowed on change of ownership iata to iata and change of Location or Location with Inspection
			if (tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION) || tocList.contains(AMS_Utils.OWNERSHIP_IATA)){

				if(tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)){
					/*if(!oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.SA)){
						oscar.AMS_Target_Agency__c.addError('A change of location for an agency which is not an “SA” cannot specify a target agency');
						validationsPassed=false;
					}
					else */if((tocList.contains(AMS_Utils.OWNERSHIP_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) && oscarAccount.Location_Type__c.equalsIgnoreCase(AMS_Utils.SA)){
						oscar.AMS_Target_Agency__c.addError('A change of location for an SA agency, which specify a target agency, cannot be mixed with a change of ownership');
						validationsPassed=false;
					}

				}
				//Target agency -> A validation must ensure that only accounts with location type “HO” or “BR” should be selected.
				Account target = accounts.get(oscar.AMS_Target_Agency__c);
				if(target != null)
					if(target.Location_Type__c != AMS_Utils.BR && target.Location_Type__c != AMS_Utils.HO && target.Location_Type__c != AMS_Utils.AO){
						oscar.AMS_Target_Agency__c.addError('The target Agency Location Type must be either HO, AO or BR');
						validationsPassed=false;
					}

			}
			else{
				oscar.AMS_Target_Agency__c.addError('Target Agency field can only be filled for the following types of changes: Ownership to IATA Agent, Location and Location with inspection.');
				validationsPassed=false;
			}
		}

		//When performing change of shareholding all active hierarchy agencies must be selected
		if (tocList.contains(AMS_Utils.MAJ_SHAREHOLDING) || tocList.contains(AMS_Utils.MIN_SHAREHOLDING) ) {
			System.debug('Agencies Affected: ' + agenciesToMigrate);
			System.debug('Hierarchy Agencies: ' + accountHierarchyRelationships.get(oscar.Account__c));
			if(!AMS_HierarchyHelper.isAllHierarchySelected(agenciesToMigrate, accountHierarchyRelationships.get(oscar.Account__c), accounts)){
				oscar.addError('When performing a change of shareholding all the active agencies in the hierarchy must be selected.');
				validationsPassed=false;
			}
		}

		return validationsPassed;

	}


	private static void updateCaseInfo() {

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;
		Map<Id, AMS_OSCAR__c> newMap = (Map<Id,AMS_OSCAR__c>) Trigger.newMap;

		List<AMS_OSCAR__c> updatedOscars = new List<AMS_OSCAR__c>();
		for(AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New){
			if(
				(oscar.Status__c != null && oscar.Status__c != oldMap.get(oscar.Id).Status__c)
				|| oscar.OwnerId != oldMap.get(oscar.Id).OwnerId
				|| (oscar.Sanity_check_results__c == AMS_Utils.PASSED && oldMap.get(oscar.Id).Sanity_check_results__c != AMS_Utils.PASSED)
			){
				updatedOscars.add(oscar);
			}
		}

		if(updatedOscars.isEmpty()) return;

		List<Case> casesToUpdate = new List<Case>();
		for(Case c : [SELECT Id, Status, OwnerId, Oscar__c, Process_Start_Date__c from CASE WHERE Oscar__c != null AND RecordType.Name = 'OSCAR Communication' AND Oscar__c IN :updatedOscars
						AND ((Oscar__r.Process__c = 'BANK.ACCOUNT.CHANGES' AND ParentId = null) OR (Oscar__r.Process__c != 'BANK.ACCOUNT.CHANGES'))]){

			AMS_OSCAR__c updatedOSCAR = newMap.get(c.Oscar__c);
			Boolean caseChanged = false;

	        if ( AMS_OSCARTriggerHandler.closedStatusMapping.containsKey(updatedOSCAR.Status__c) ) {
	        	String closedStatus = AMS_OSCARTriggerHandler.closedStatusMapping.get(updatedOSCAR.Status__c);
	        	if(c.Status != closedStatus){
	        		c.Status = closedStatus;
	        		caseChanged = true;
	        	}
	        }else if(c.Status != updatedOSCAR.Status__c){
        		c.Status = updatedOSCAR.Status__c;
        		caseChanged = true;
        	}

        	if(c.OwnerId != updatedOSCAR.OwnerId){
        		c.OwnerId = updatedOSCAR.OwnerId;
        		caseChanged = true;
        	}
        	if(c.Process_Start_Date__c == null){
        		c.Process_Start_Date__c = updatedOSCAR.Process_Start_Date__c;
        		caseChanged = true;
        	}

		    if(caseChanged) casesToUpdate.add(c);
		}

		if(!casesToUpdate.isEmpty()) update casesToUpdate;
	}
	
	//TD: udpate case reason. Used for calculating KPIs
	public static void updateCaseKPIFields() {

		Map<Id, AMS_OSCAR__c> oldMap = (Map<Id,AMS_OSCAR__c>) Trigger.oldMap;

		Map<Id, AMS_OSCAR__c> mapOscars = new Map<Id, AMS_OSCAR__c>();
		for (AMS_OSCAR__c oscar : (List<AMS_OSCAR__c>)Trigger.New ) {
			if (
					Trigger.isInsert ||
			    	(
			    		(oscar.Reason_For_KPI__c != oldMap.get(oscar.id).Reason_For_KPI__c) ||
			        	(oscar.Process_Start_Date__c != oldMap.get(oscar.id).Process_Start_Date__c) ||
			        	(oscar.Dossier_Reception_Date__c != oldMap.get(oscar.id).Dossier_Reception_Date__c)
			        )
			    )
				mapOscars.put(oscar.id, oscar);
		}

		if(mapOscars.isEmpty()) return;

		try {
			List<Case> lsCaseToUpdate = new List<Case>();
			for(case ca:[select id, Reason1__c, OSCAR__c, Account.IATA_ISO_Country__r.Name, Account.Region_Formula__c from Case where OSCAR__c in:mapOscars.keySet()]){
				lsCaseToUpdate.add(new case(id = ca.id
											, Reason1__c = mapOscars.get(ca.OSCAR__C).Reason_For_KPI__c != null ? mapOscars.get(ca.OSCAR__C).Reason_For_KPI__c : ca.Reason1__c
											, Process_Start_Date__c = mapOscars.get(ca.OSCAR__C).Process_Start_Date__c
											, BSPCountry__c = ca.Account.IATA_ISO_Country__r.Name
											, Region__c = ca.Account.Region_formula__c
											, Dossier_reception_date__c = mapOscars.get(ca.OSCAR__C).Dossier_Reception_Date__c));
			}
			
			if(!lsCaseToUpdate.isEmpty())
				update lsCaseToUpdate;
		} catch (exception e) {
			system.debug('DTULLO 39 --> exception --> ' + e.getMessage());
		}
	}

	//the oscar process requires updates on the accounts on 2 situations
	//-when a change code is generated (in this situation only the status is updated)
	//-when migrating fields from staging area to master data
	//because the above situations are done in separate ocasions, we need to merge the account updates in only one list
	//to prevent double update on accounts
	private static List<Account> mergeAccountsToUpdate(List<Account> accountUpdatesFromChangeCodes, List<Account> accountUpdatesFromStagingArea){

		List<Account> mergedAccountsToUpdate = new List<Account>();

		//gather all account Ids into a set
		Map<Id, Account> mapA = new Map<Id, Account>(accountUpdatesFromStagingArea);
		Map<Id, Account> mapB = new Map<Id, Account>(accountUpdatesFromChangeCodes);
		

		Set<Id> allAccountsToUpdateIds = new Set<Id>();
		allAccountsToUpdateIds.addAll(mapA.keySet());
		allAccountsToUpdateIds.addAll(mapB.keySet());

		for(Id accId: allAccountsToUpdateIds){
			Account a;
			if(mapA.containsKey(accId))
				a = mapA.get(accId);
			if(mapB.containsKey(accId))
				if(a == null)
					a = mapB.get(accId);
				else
					a.Status__c = mapA.get(accId).Status__c;

			if(a!=null)
				mergedAccountsToUpdate.add(a);
		}

		return mergedAccountsToUpdate;

	}

}