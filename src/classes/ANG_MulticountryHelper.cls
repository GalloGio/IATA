public class ANG_MulticountryHelper {
	
	private class ValidationWrapper {
		public Boolean valid;
		public String message;
	}

	public class SwapAccountsWrapper {
		public Id newGE;
		public Id bspOldGE;
		public Id bspNewGE;
		public Boolean swapAE;
		public Boolean diffBSP;
		public Map<Id, Account> swapMapping;
	}

	public class AgenciesRelationshipWrapper implements Comparable {

		public AMS_Agencies_relationhip__c relation;
		public Map<Id, Id> hePerBspMapping;

		public AgenciesRelationshipWrapper(AMS_Agencies_relationhip__c relation, Map<Id, Id> hePerBspMapping){
			this.relation = relation;
			this.hePerBspMapping = hePerBspMapping;
		}

		public Integer compareTo(Object compareTo){

			AgenciesRelationshipWrapper compareToRelationWrapper = (AgenciesRelationshipWrapper) compareTo;
			AMS_Agencies_relationhip__c compareToRelation = compareToRelationWrapper.relation;

			Id relationHeInBsp = hePerBspMapping.get(relation.Child_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c);
			Id compareRelationHeInBsp = hePerBspMapping.get(compareToRelation.Child_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c);
			
			//If agencies location type are GE: they have priority over any other 
			if(relation.Parent_Account__r.Location_Type__c == AMS_Utils.GE){
				return -1;
			}
			else if(compareToRelation.Parent_Account__r.Location_Type__c == AMS_Utils.GE){
				return 1;
			}
			//If any of the agencies with location type AE was selected by the user to become a new HE: they have priority over HE's 
			else if(relation.Child_Account__r.Location_Type__c == AMS_Utils.AE && relation.Child_Account__c == relationHeInBsp){
				return -1;
			}
			else if(compareToRelation.Child_Account__r.Location_Type__c == AMS_Utils.AE && compareToRelation.Child_Account__c == compareRelationHeInBsp){
				return 1;
			}
			//If agencies location type are HE: they have priority over any other AE
			else if(relation.Parent_Account__r.Location_Type__c == AMS_Utils.HE){
				return -1;
			}
			else if(compareToRelation.Parent_Account__r.Location_Type__c == AMS_Utils.HE){
				return 1;
			}

			return 0;

		}

	}

	public class TargetHierarchyWrapper {
		public Map<Id, Account> hierarchyBspMap;
		public Account targetGE;
		public Id hierarchyId;
	}

	public static Set<String> allowedLocationsSet = new Set<String>{'D', 'P'};

    public static Set<String> locationTypesSet = new Set<String>{
        AMS_Utils.HE, 
        AMS_Utils.AE,
        AMS_Utils.GE
    };

	/**
	* Verifies if the immediate parent 
	* associated with the acctId 
	* has the given change code
	* 
	* @param acctId: Id 
	* @param changeCode: String
	* @return Boolean 
	*
	*/
	private static Boolean parentHasChangeCode(Id acctId, String changeCode){
		
		integer nbrOfChangeCodes =
			[SELECT
				count()
			 FROM
				Agency_Applied_Change_Code__c
			 WHERE								
			 	 Change_Code__c = :changeCode 	
			 AND Account__c IN 					
			 	(SELECT ParentId				
			 	 FROM Account 					
			 	 WHERE Id = :acctId)
			];

		return nbrOfChangeCodes > 0;
	
	}

	/**
	* Verifies if the IATA Code generation should be allowed
	* 
	* @param oscar: AMS_OSCAR__c
	* @return Boolean
	*
	*/
	public static Boolean allowIATACodeGeneration(AMS_OSCAR__c oscar){
		return 
			(parentHasChangeCode(oscar.Account__c, 'NEW') && 
			 (AMS_Utils.ACTIVEAGENCYSTATUS.contains(oscar.Account__r.Parent.Status__c) || 
			  oscar.Account__r.Parent.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING)
			);
	}

	/**
	* Verifies if the OSCAR approval step should be allowed
	* 
	* @param oscar: AMS_OSCAR__c
	* @return Boolean
	*
	*/
	public static Boolean allowApprovalStep(AMS_OSCAR__c oscar){
		return parentHasChangeCode(oscar.Account__c, 'FIN');
	}

	/**
	* Verifies if the multicountry validations
	* should run for the given account
	*
	* @param account: Account
	* @return Boolean
	*
	*/
	public static Boolean shouldRunMulticountryValidations(Account account){
    	return (allowedLocationsSet.contains(account.Location_Class__c) && account.ANG_IsNewGenAgency__c);
	}

	/**
	* Executes the validations on accounts 
	* in a multicountry hierarchy
	*
	* @param accountsHePerBspMap: Map<String, Set<Id>>
	* @param account: Account
	* @return vw: ValidationWrapper
	*
	*/
	private static ValidationWrapper runMulticountryValidations(Account account, Map<String, Set<Id>> accountsHePerBspMap){

		ValidationWrapper vw = new ValidationWrapper();
		vw.valid = true;

		if(account.Location_Type__c == AMS_Utils.AE){

           	if(account.IATA_ISO_Country__r.AMS_Settlement_System__c != account.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c){
                vw.valid = false;
                vw.message = Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_HE_Error;
            	return vw;
            }

        }
        else if(account.Location_Type__c == AMS_Utils.HE){

            String bspId = account.IATA_ISO_Country__r.AMS_Settlement_System__c;
            String topParent = account.Top_Parent__c;

            Set<Id> accountIds = accountsHePerBspMap.get(bspId+topParent);

			if(account.Parent.Location_Type__c == AMS_Utils.GE && account.IATA_ISO_Country__r.AMS_Settlement_System__c == account.Parent.IATA_ISO_Country__r.AMS_Settlement_System__c){
            	vw.valid = false;
            	vw.message = Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_Error;
				return vw;
			}

            if(accountIds != NULL && accountIds.size() > 1){
            	vw.valid = false;
                vw.message = Label.ANG_Multicountry_Already_Has_Locations_Only_Allow_AE_With_Correct_HE_Error;
                return vw;
            }

        }

        return vw;

	}

	/**
	* Fetches the accounts related
	* with the given parent Ids
	* 
	* @param parentIdSet: Set<Id>
	* @return accountMap: Map<Id, Account>
	*
	*/ 	
	private static Map<Id, Account> fetchMulticountryAccounts(Set<Id> parentIdSet){

		Map<Id, Account> accountMap = new Map<Id, Account>(
            [SELECT
                Id,
                ParentId,
                Top_Parent__c,
                Location_Type__c,
                Location_Class__c,
                Parent.Location_Type__c,
                IATA_ISO_Country__r.AMS_Settlement_System__c,
                IATA_ISO_Country__r.Name,
                Parent.IATA_ISO_Country__r.AMS_Settlement_System__c
             FROM
                Account
             WHERE 
                (Id IN :parentIdSet OR ParentId IN :parentIdSet)
            /* AND
                Location_Type__c IN :locationTypesSet */
             AND
             	(
             	Top_Parent__r.Location_Type__c = :AMS_Utils.GE OR Location_Type__c = :AMS_Utils.GE) 
            ]
        );

       	System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryHelper - fetchMulticountryAccounts] Account Map: ' + accountMap);

        return accountMap;

	}

	/**
	* Aggregate HE accounts for each BSP/GE
	* 
	* @param accountLst: List<Account>
	* @return accountsHePerBspMap: Map<String, Set<Id>>
	*
	*/
	private static Map<String, Set<Id>> aggregateHeadEntitiesForEachBSP(List<Account> accountLst){

		Map<String, Set<Id>> accountsHePerBspMap = new Map<String, Set<Id>>();

        for(Account acct : accountLst){

            if(acct.Location_Type__c == AMS_Utils.HE){

                String bspId     = acct.IATA_ISO_Country__r.AMS_Settlement_System__c;
                String topParent = acct.Top_Parent__c;
                String aggrKey   = bspId+topParent;

                if(accountsHePerBspMap.containsKey(aggrKey)){
                    accountsHePerBspMap.get(aggrKey).add(acct.Id);
                    continue;
                }

                accountsHePerBspMap.put(aggrKey, new Set<Id>{acct.Id});   
            }

        }

        return accountsHePerBspMap;

    }

	/**
	* Process the given accounts to make sure 
	* that for each multicountry account 
	* the validations are executed.
	* 
	* @param accountLst: List<Account>
	* @param parentIdSet: Set<Id>
	*
	*/
	public static void processMulticountryValidations(List<Account> accountLst, Set<Id> parentIdSet){

		Map<Id, Account> acctWithRelshipsMap = fetchMulticountryAccounts(parentIdSet);

		if(acctWithRelshipsMap.isEmpty()) return;

        Map<String, Set<Id>> accountsHePerBspMap = aggregateHeadEntitiesForEachBSP(acctWithRelshipsMap.values());
        
        for(Account acct : accountLst){
    	
            Account acctWithRelships = acctWithRelshipsMap.get(acct.Id);
           
			System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryHelper - processMulticountryValidations] Processing account: ' + acct);
			System.debug(LoggingLevel.FINE, '____ [cls ANG_MulticountryHelper - processMulticountryValidations] Processing account with relations: ' + acctWithRelships);

			if(acctWithRelships != null){
				ValidationWrapper vw = runMulticountryValidations(acctWithRelships, accountsHePerBspMap);
				if(!vw.valid){
					acct.addError(vw.message);
				}
			}

		}

	}

   /**
	* Gets the Remittance frequency from the current AMS Online Accreditation
	*
	* @param accreditationID: ID
	* @return String
	*
	*/
	private static String getPaxRemittanceFrequencyByID(Id accreditationID){
		
		List<AMS_Pax_Accreditation_Form__c> onlineAccred = [SELECT Remittance_frequency__c 
															FROM AMS_Pax_Accreditation_Form__c
															WHERE id = :accreditationID];

		String rf;

		if(!onlineAccred.isEmpty()) rf = onlineAccred[0].Remittance_frequency__c;

		return rf;
	}


	/**
	 * Checks if an Multicountry account (GE or HE) 
	 * has an empty Remittance_frequency__c
	 * NEWGEN-4850
	 * 
	 * @param oscar: AMS_OSCAR__c
	 * @return Boolean
	 */
	public static Boolean multicountryAccountHasRemittenceFrequencyEmpty(AMS_OSCAR__c oscar){
		return ( String.isEmpty(getPaxRemittanceFrequencyByID(oscar.AMS_Online_Accreditation__c))
			&& ((oscar.Location_Type__c == AMS_Utils.HE && oscar.Process__c == AMS_Utils.MCAE) 
				|| oscar.Location_Type__c == AMS_Utils.GE));
	}

	/**
	 * cloneOwnersFromParentAccount description - Process to clone the Accreditation Contacts from Parent's Online Form into this one
	 * @param  accountId         account from Accreditation Form
	 * @param  accreditationFormId Online Accreditation from where to clone the contacts
	 */
	public static String cloneOwnersFromParentAccount(Id accreditationFormId){

		if(accreditationFormId == null)
			return 'You must provide a valid Online Accreditation Form Id.';

		AMS_Pax_Accreditation_Form__c onlineForm = [Select Id, SAAM_Case__r.AccountId, SAAM_Case__r.Account.ParentId from AMS_Pax_Accreditation_Form__c where Id = :accreditationFormId];

		// check null value for parent

		if(onlineForm == null || onlineForm.SAAM_Case__r.AccountId == null || onlineForm.SAAM_Case__r.Account.ParentId == null)
			return 'The Parent Account could not be found.';

		List<AMS_Accreditation_Contact__c> aContactLst = new List<AMS_Accreditation_Contact__c>();

		for(AMS_Account_Role__c contactRole: [Select Id, Owner_Account__c, Owner_Account__r.Name, Contact__c, Contact__r.FirstName, Contact__r.LastName, Contact_Email__c,Financial_Assessment_Contact__c,Percentage__c,Legacy_External_ID__c,Person__c, Person__r.First_Name__c, Person__r.Lastname__c, Person__r.Contact__r.FirstName, Person__r.Contact__r.LastName, Person__r.Name, Contact_Phone__c from AMS_Account_Role__c where Account__c = :onlineForm.SAAM_Case__r.Account.ParentId and active__c = true and RecordTypeId = :AMS_Utils.AccountRoleOwnershipRT]){

			String firstName = contactRole.Owner_Account__c <> null ? contactRole.Owner_Account__r.Name : contactRole.Contact__c <> null ? contactRole.contact__r.FirstName : contactRole.Person__c <> null ? '' : contactRole.Owner_Name__c;
			String lastName =  contactRole.Owner_Account__c <> null ? contactRole.Owner_Account__r.Name : contactRole.Contact__c <> null ? contactRole.contact__r.LastName : contactRole.Person__c <> null ? contactRole.Person__r.Name : contactRole.Owner_Name__c;

			AMS_Accreditation_Contact__c aContact = new AMS_Accreditation_Contact__c();
				
			aContact.AMS_Pax_Accreditation_Form__c =accreditationFormId;
			aContact.Agency_owner__c = true;
			aContact.Company__c = contactRole.Owner_Account__c;
			aContact.Contact__c = contactRole.Contact__c;
			aContact.Email__c = contactRole.Contact_Email__c; 
			aContact.Financial_Assessment_Contact__c = contactRole.Financial_Assessment_Contact__c;
			aContact.Financial_interest__c = contactRole.Percentage__c;
			aContact.First_name__c = firstName;
			aContact.Last_name__c = lastName;
			aContact.Legacy_External_Id__c = contactRole.Legacy_External_ID__c;
			aContact.Name = firstName == null ? LastName : firstName + ' ' + LastName;
			aContact.Person_AMS__c = contactRole.Person__c;
			aContact.Phone__c = contactRole.Contact_Phone__c;
			aContact.RecordTypeId = contactRole.Owner_Account__c == null ? AMS_Utils.AccreditationContactPersonRT : AMS_Utils.AccreditationContactCompanyRT;

			aContactLst.add(aContact);

		}

		insert aContactLst;
	
		return null;
	
	}

	/**
	* Swap location types between two accounts 
	* in the scope of change of location type
	* for multicountry agencies
	*
	* @param accountsMap: Map<Id, Account>
	* @param toReturn: AChangeStructure
	*
	*/
	public static SwapAccountsWrapper swapAccountsLocationType(Map<Id, Account> accountsMap, ANG_AgencyChangesHelper.AChangeStructure toReturn){
		
		SwapAccountsWrapper swapWrapper = new SwapAccountsWrapper();

		swapWrapper.swapAE = false;
		
		//Swap mapping stores the mapping between the swapping accounts
		Map<Id, Account> swapMapping = new Map<Id, Account>();
		
		List<Account> accountLst = accountsMap.values();

		Account firstAccount  = accountLst.get(0);
		Account secondAccount = accountLst.get(1);
		
		String locationTypeAux = firstAccount.Location_Type__c;

		//Swap location types from the involved accounts
		firstAccount.Location_Type__c  = secondAccount.Location_Type__c;
		secondAccount.Location_Type__c = locationTypeAux;

		//Identifies if involved accounts are in a different BSP
		Boolean diffBSP = 
			(firstAccount.IATA_ISO_Country__r.AMS_Settlement_System__c != 
				secondAccount.IATA_ISO_Country__r.AMS_Settlement_System__c);

		//If the swapped accounts are in different BSPs 
		//and one of them has the location type AE it must be updated to HE
		//to make sure that the multicountry hierarchy remains valid  
		if(diffBSP && firstAccount.Location_Type__c == AMS_Utils.AE){
			firstAccount.Location_Type__c = AMS_Utils.HE;
			swapWrapper.swapAE = true;
		} else if(diffBSP && secondAccount.Location_Type__c == AMS_Utils.AE){
			secondAccount.Location_Type__c = AMS_Utils.HE;
			swapWrapper.swapAE = true;
		}

		//If we are swapping a GE we store the new GE Id, the old GE BSP and the new GE BSP
		if(firstAccount.Location_Type__c == AMS_Utils.GE){
			swapRelatedFields(firstAccount, secondAccount);
			swapWrapper.newGE = firstAccount.Id;
			swapWrapper.bspOldGE = secondAccount.IATA_ISO_Country__r.AMS_Settlement_System__c;
			swapWrapper.bspNewGE = firstAccount.IATA_ISO_Country__r.AMS_Settlement_System__c;
			toReturn.moveFsAndRiskEventsMap = new Map<Id,Id>{secondAccount.Id => firstAccount.Id};
		}
		//If we are swapping a GE we store the new GE Id, the old GE BSP and the new GE BSP
		else if(secondAccount.Location_Type__c == AMS_Utils.GE){
			swapRelatedFields(secondAccount, firstAccount);
			swapWrapper.newGE = secondAccount.Id;
			swapWrapper.bspOldGE = firstAccount.IATA_ISO_Country__r.AMS_Settlement_System__c;
			swapWrapper.bspNewGE = secondAccount.IATA_ISO_Country__r.AMS_Settlement_System__c;
			toReturn.moveFsAndRiskEventsMap = new Map<Id,Id>{firstAccount.Id => secondAccount.Id};
		}
		else if(firstAccount.Location_Type__c == AMS_Utils.HE){
			swapRelatedFields(firstAccount, secondAccount);
		}
		else {
			swapRelatedFields(secondAccount, firstAccount);
		}

		swapMapping.put(firstAccount.Id, secondAccount);
		swapMapping.put(secondAccount.Id, firstAccount);
		
		swapWrapper.diffBSP = diffBSP;
		swapWrapper.swapMapping = swapMapping;

		toReturn.addAccount(firstAccount);
		toReturn.addAccount(secondAccount);
		
		return swapWrapper;
		
	}

	/**
	* Move risk related fields and RHC information
	* from one account to another in the scope of
	* change of location type for multicountry agencies
	*
	* @param assignFieldsAcct: Account
	* @param srcAcct: Account
	*
	*/
	public static void moveRiskRelatedFieldsFromAccount(Account assignFieldsAcct, Account srcAcct){
		
		assignFieldsAcct.ANG_IEP_Status__c = srcAcct.ANG_IEP_Status__c;
		assignFieldsAcct.ANG_HE_RiskStatus__c = srcAcct.ANG_HE_RiskStatus__c;
		assignFieldsAcct.ANG_IEP_HE_AccntNum__c = srcAcct.ANG_IEP_HE_AccntNum__c;
		assignFieldsAcct.ANG_HE_CashCondition__c = srcAcct.ANG_HE_CashCondition__c;
		assignFieldsAcct.Financial_Review_Result__c = srcAcct.Financial_Review_Result__c;
		assignFieldsAcct.ANG_HE_RiskHistoryAssessment__c = srcAcct.ANG_HE_RiskHistoryAssessment__c;
		assignFieldsAcct.Financial_Assessment_Points__c = srcAcct.Financial_Assessment_Points__c;
		assignFieldsAcct.Identify_as_Multicountry_Key_Hierarchy__c = srcAcct.Identify_as_Multicountry_Key_Hierarchy__c; 

		srcAcct.ANG_IEP_Status__c = null;
		srcAcct.ANG_HE_RiskStatus__c = null;
		srcAcct.ANG_IEP_HE_AccntNum__c = null;
		srcAcct.ANG_HE_CashCondition__c = false;
		srcAcct.ANG_HE_RiskHistoryAssessment__c = null;
		srcAcct.Financial_Assessment_Points__c = null;
		srcAcct.Identify_as_Multicountry_Key_Hierarchy__c = false;

		ANG_RHCHelper.moveRHCInfos(srcAcct.RHC_Informations__r, new Map<Id,Id>{srcAcct.Id => assignFieldsAcct.Id});
	
	}


	/**
	* Swap field values between two accounts 
	* in the scope of change of location type
	* for multicountry agencies
	*
	* @param parentAcct: Account
	* @param childAcct: Account
	*
	*/
	public static void swapRelatedFields(Account parentAcct, Account childAcct){

		if(parentAcct.Location_Type__c == AMS_Utils.GE){
			parentAcct.ParentId = null;
			parentAcct.Top_Parent__c = null;
			childAcct.ParentId = parentAcct.Id;
			childAcct.Top_Parent__c = parentAcct.Id;
			moveRiskRelatedFieldsFromAccount(parentAcct, childAcct);
		}
		else if(parentAcct.Location_Type__c == AMS_Utils.HE && childAcct.Location_Type__c == AMS_Utils.AE){
			parentAcct.ParentId = childAcct.ParentId;
			childAcct.ParentId = parentAcct.Id;
		}

	}

	/**
	 * Processes and sorts the acquired hierarchy relationship records.
	 * - The sort is custom to make sure that we later process the relationship records from top location types to bottom 
	 * (see compareTo method from wrapper class AgenciesRelationshipWrapper)
	 *
	 * @param  acquiredHierarchyLst 		contains all relationship records from the acquired hierarchy 
	 * @param  hePerBspMapping      		contains the previously user selected HE for each new BSP in the target hierarchy 
	 * @return acquiredHierarchyWrapperLst	sorted list of relationship wrappers containing all the acquired hierarchy relationships  
	 */ 
	public static List<AgenciesRelationshipWrapper> prepareAcquiredHierarchyData(List<AMS_Agencies_relationhip__c> acquiredHierarchyLst, Map<Id, Id> hePerBspMapping){

		List<AgenciesRelationshipWrapper> acquiredHierarchyWrapperLst = new List<AgenciesRelationshipWrapper>();

		integer i = 0;
		integer listSize = acquiredHierarchyLst.size();

		while(i < listSize){
			AMS_Agencies_relationhip__c relation = acquiredHierarchyLst.get(i);
			acquiredHierarchyWrapperLst.add(new AgenciesRelationshipWrapper(relation, hePerBspMapping));
			i++;
		}

		acquiredHierarchyWrapperLst.sort();

		return acquiredHierarchyWrapperLst;
		
	}

	/**
	 * Processes all the target relationships from the target hierarchy
	 * and splits the hierarchy head locations (GE/HE) for each different BSP
	 * <GE, BSP>; <HE 1; BSP 1>; <HE 2; BSP 2>; etc    
	 * 
	 * @param  targetHierarchyLst contains all relationship records from the target hierarchy 
	 * @return thw                wrapper containing the target hierarchy head locations splited by BSP, GE record and target hierarchy id
	 */
	public static TargetHierarchyWrapper prepareTargetHierarchyData(List<AMS_Agencies_relationhip__c> targetHierarchyLst){
		
		TargetHierarchyWrapper thw = new TargetHierarchyWrapper();

		thw.hierarchyBspMap = new Map<Id, Account>();

		integer i = 0;
		integer listSize = targetHierarchyLst.size();

		while(i < listSize){
			AMS_Agencies_relationhip__c relation = targetHierarchyLst.get(i);
			
			if(thw.hierarchyId == NULL){
				thw.hierarchyId = relation.Hierarchy__c;
			}

			if(relation.Parent_Account__r.Location_Type__c == AMS_Utils.GE){
				thw.targetGE = (Account) relation.getSObject('Parent_Account__r');
				thw.hierarchyBspMap.put(relation.Parent_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, thw.targetGE);
			}

			if(relation.Child_Account__r.Location_Type__c == AMS_Utils.HE){
				thw.hierarchyBspMap.put(relation.Child_Account__r.IATA_ISO_Country__r.AMS_Settlement_System__c, (Account)  relation.getSObject('Child_Account__r'));
			}

			i++;
		}

		return thw;
	}

	/**
	 * Processes a given acquired agency by another multicountry hierarchy
	 * or an agency splitted into a new multicountry hierarchy
	 * 
	 * @param  agency           current account that is being processed
	 * @param  oscarAccountId   account id associated with the change oscar
	 * @param  newParentId      account id of the hierarchy parent (GE)
	 * @param  currentBspId     bsp associated with the current account
	 * @param  currentRelation  relationship record associated with the current account
	 * @param  thw              wrapper containing the hierarchy head locations splited by BSP, GE record and hierarchy record id
	 * @param  toReturn         agency changes wrapper
	 * @param  isHierarchySplit identifies if this change of hierarchy is a hierarchy split
	 */
	public static void processAgency(Account agency, Id oscarAccountId, Id newParentId, Id currentBspId, AMS_Agencies_relationhip__c currentRelation, TargetHierarchyWrapper thw, ANG_AgencyChangesHelper.AChangeStructure toReturn, Boolean isHierarchySplit){
		
		if(isHierarchySplit){
			processSplitAgency(agency, oscarAccountId, newParentId, currentBspId, currentRelation, thw, toReturn);
		}
		else {
			processAcquiredAgency(agency, newParentId, currentBspId, currentRelation, thw, toReturn);
		}

		if(agency.Location_Risk_Events__r != NULL){
			toReturn.addRiskEventsToInactivate(agency.Location_Risk_Events__r, newParentId);
		}

	}

	/**
	 * Processes a given split agency into a new multicountry hierarchy:
	 *  - Updates current account relationships/location types
	 *  - Creates RHC information record for the new GE
	 *  - Deletes previous relationships where the new GE was a child 
	 * 
	 * @param  splitAgency     current account that is being processed
	 * @param  oscarAccountId   account id associated with the change oscar
	 * @param  newParentId      account id of the hierarchy parent (GE)
	 * @param  currentBspId     bsp associated with the current account
	 * @param  currentRelation  relationship record associated with the current account
	 * @param  thw              wrapper containing the hierarchy head locations splited by BSP, GE record and hierarchy record id
	 * @param  toReturn         agency changes wrapper
	 */
	public static void processSplitAgency(Account splitAgency, Id oscarAccountId, Id newParentId, Id currentBspId, AMS_Agencies_relationhip__c currentRelation, TargetHierarchyWrapper thw, ANG_AgencyChangesHelper.AChangeStructure toReturn){

		Account headEntityIdInBSP = thw.hierarchyBspMap.get(currentBspId);

		if(splitAgency.Id == oscarAccountId){
			splitAgency.Location_Type__c = AMS_Utils.GE;
			splitAgency.ParentId = null;
			splitAgency.Top_Parent__c = null;
			splitAgency.Identify_as_Multicountry_Key_Hierarchy__c = true;

			toReturn.addAccountToCreateRHC(splitAgency);

			if(currentRelation != NULL){
				toReturn.addRelationToDelete(currentRelation);
			}

			return; 
		}
		
		updateAgencyRelationships(splitAgency, oscarAccountId, currentBspId, headEntityIdInBSP, thw.hierarchyBspMap);
		
		if(currentRelation != NULL){
			currentRelation.Hierarchy__c = thw.hierarchyId;
			currentRelation.Parent_Account__c = splitAgency.ParentId;
			toReturn.addRelation(currentRelation);
		}

	}

	/**
	 * Processes a given acquired agency by another multicountry hierarchy:
	 * 	- If the agency location is GE we need to create a new relationship record pointing to the target GE
	 *  and we need to clean and delete a couple of fields/related records (RHC e.g.)
	 *  - Inactivate risk events associated with the current account
	 * 	- Updates current account relationships/location types
	 * 
	 * @param  acquiredAgency  current account that is being processed
	 * @param  newParentId     account id of the target hierarchy parent (GE)
	 * @param  currentBspId    bsp associated with the current account
	 * @param  currentRelation relationship record associated with the current account
	 * @param  thw             wrapper containing the target hierarchy head locations splited by BSP, GE record and target hierarchy id
	 * @param  toReturn        agency changes wrapper
	 */
	public static void processAcquiredAgency(Account acquiredAgency, Id newParentId, Id currentBspId, AMS_Agencies_relationhip__c currentRelation, TargetHierarchyWrapper thw, ANG_AgencyChangesHelper.AChangeStructure toReturn){

		Account headEntityIdInBSP = thw.hierarchyBspMap.get(currentBspId);

		if(acquiredAgency.Location_Type__c == AMS_Utils.GE){
			AMS_Agencies_relationhip__c newRel = new AMS_Agencies_relationhip__c();
			newRel.Parent_Account__c = headEntityIdInBSP != NULL ? headEntityIdInBSP.Id : newParentId;
			newRel.Child_Account__c = acquiredAgency.Id;
			newRel.Is_Newgen_Relation__c = true;
			newRel.Hierarchy__c = thw.hierarchyId;
			toReturn.addRelation(newRel);

			acquiredAgency.ANG_HE_RiskHistoryAssessment__c = null;
			acquiredAgency.ANG_HE_RiskStatus__c = null;
			acquiredAgency.Assessment_Performed_Date__c = null;
			acquiredAgency.Financial_Review_Result__c = null;
			acquiredAgency.ANG_HE_CashCondition__c = false;
			acquiredAgency.Financial_Assessment_Points__c = null;
			acquiredAgency.Identify_as_Multicountry_Key_Hierarchy__c = false;
			
			if(acquiredAgency.RHC_Informations__r != NULL){
				toReturn.addRhcInformationToDeactivate(acquiredAgency.RHC_Informations__r[0]);
			}

		}

		acquiredAgency.ANG_FA_Opt_out__c = thw.targetGE.ANG_FA_Opt_out__c;

		if(headEntityIdInBSP != NULL){
			acquiredAgency.Remittance_frequency__c = headEntityIdInBSP.Remittance_frequency__c;
		}

		updateAgencyRelationships(acquiredAgency, newParentId, currentBspId, headEntityIdInBSP, thw.hierarchyBspMap);

		if(currentRelation != NULL){
			currentRelation.Parent_Account__c = acquiredAgency.ParentId;
			currentRelation.Hierarchy__c = thw.hierarchyId;
			toReturn.addRelation(currentRelation);
		}
		
	}

	/**
	 * Updates the current account relationships (Parent and Top Parent) 
	 * and assigns the proper location type accordingly to the following:
	 * 	- If the target hierarchy does not contain (yet) the associated BSP: HE
	 *	- Otherwise: AE
	 * 
	 * @param  acct                  current account that is being processed
	 * @param  newParentId           account id of the target hierarchy parent (GE)
	 * @param  currentBspId          bsp associated with the current account
	 * @param  headEntityIdInBSP     account id of the head entity for the current BSP (if present) 
	 * @param  targetHierarchyBspMap contains the target hierarchy head locations (GE or HE) splited by BSP 
	 */
	private static void updateAgencyRelationships(Account acct, Id newParentId, Id currentBspId, Account headEntityIdInBSP, Map<Id, Account> targetHierarchyBspMap){

		if(headEntityIdInBSP != NULL){
			acct.Location_Type__c = AMS_Utils.AE;
			acct.ParentId = headEntityIdInBSP.Id;
			acct.Top_Parent__c = newParentId;
		} else {
			acct.Location_Type__c = AMS_Utils.HE;
			acct.ParentId = newParentId;
			acct.Top_Parent__c = newParentId;
			targetHierarchyBspMap.put(currentBspId, acct);
		}
		
	}

	/**
	 * Process agencies forms of payments so that: 
	 *  - Cash & IEP forms of payments are set to Active
	 *  - Credit Card form of payment are set accordingly to PCI Compliance
	 *  
	 * @param  accountLst agencies to process
	 * @param  toReturn   agency changes wrapper
	 */
	public static void processAgenciesFormsOfPayment(List<Account> accountLst, ANG_AgencyChangesHelper.AChangeStructure toReturn){

		for(Account acct : accountLst){
			List<Agency_Authorization__c> agencyAuthorizationLst = acct.Agency_Authorizations__r;

			if(agencyAuthorizationLst != NULL){
				for(Agency_Authorization__c aa : agencyAuthorizationLst){
					if(AMS_Utils.assignFormOfPaymentStatus(aa, acct.Is_PCI_compliant__c)){
						toReturn.addAgencyAuthorizationToUpdate(aa);
					}
				}
			}
		}
		
	}

	/**
	 * Method that perform the staging area mapping with the Account values
	 *  
	 * @param  acc 				Account values to map into staging area fields
	 * @param  fieldsOfObject   Map of Field Object - AMS_Pax_Accreditation_Form__c
	 */
	public static Map<String,Object> buildStagingAreaFieldsObject(Account acct){

		Map<String,Object> fieldsOfObject = new Map<String,Object>();

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
		fieldsOfObject.put('ISSP_Branch_AccountId__c',acct.Id);

		return fieldsOfObject;
	}

	public static Boolean isMulticountryAccount(Account acct)
	{
		return acct.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
	}
	
	public static List<IATA_ISO_Country__c> getAccountCountry(List<Account> accts)
	{
		Set<Id> countries = new Set<Id>();
		for (Account a : accts)
			countries.add(a.IATA_ISO_Country__c);

		return IATAIsoCountryDAO.getIsoCountriesByIds(countries);
	}
	
	public static Boolean isMulticountryCountry(IATA_ISO_Country__c cntry)
	{
		return cntry == null ? false : cntry.Multicountry_Enabled__c;
	}

	/**
	 * Returns a list of HE account child to the given list of accounts.
	 * 
	 * @param	accountIds			List of parent accounts
	 * @return	Map<Id, Account>	List of child HE accounts
	 */
	public static Map<Id, Account> getChildHEAccounts(Set<Id> accountIds)
	{
		if (accountIds.isEmpty())
			return new Map<Id, Account>();

		return new Map<Id, Account>(
			   [SELECT Id, BillingCountry, Region_formula__c, Abbreviated_address__c, Abbreviated_name__c,
					Name, BillingState, BillingCity, IATA_ISO_Country__c, Email__c, Fax, Phone, BillingPostalCode,
					BillingStreet, CASS_Number__c, IATACode__c, Iso_State__c, License_Number__c, VAT_Number__c,
					Is_your_firm_handling_Dangerous_Goods__c, Location_Class__c, Location_Type__c, Mobile__c,
					Operation__c, ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
					Short_Name__c, Solicitation_Flag__c, TradeName__c, VAT_Number_2__c, Website, Company_Type__c,
					ANG_RiskStatus__c, ANG_Accreditation_Model__c
				FROM Account
				WHERE ParentId IN :accountIds
					AND Location_Type__c = :AMS_Utils.HE
					AND Status__c NOT IN (
						'', NULL,
						:AMS_Utils.ACC_S4_LISTED,
						:AMS_Utils.ACC_S0_TERMINATED, 
						:AMS_Utils.ACC_S1_NOTACCREDITED, 
						:AMS_Utils.ACC_S3_NOTINOPERATION
					)
			   ]);
	}

}