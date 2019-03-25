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
    	return (
    			(allowedLocationsSet.contains(account.Location_Class__c) && account.ANG_IsNewGenAgency__c) 
    			|| 
    			(account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY)
    		   );
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

		//NEWGEN-5055 - Check If ISO Country selected to the account is a Multicountry Enable
		if(!account.IATA_ISO_Country__r.Multicountry_Enabled__c){
			vw.valid = false;
			if(!String.isBlank(account.Location_Type__c)) 
				vw.message = Label.ANG_Multicountry_Country_not_Enabled_for_Multicountry;
			else // Account created from from account creator page
				vw.message = 'The country ' + account.IATA_ISO_Country__r.Name  + ' is not enabled for multicountry';
            return vw;
		}

		else if(account.Location_Type__c == AMS_Utils.AE){

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
                IATA_ISO_Country__r.Multicountry_Enabled__c,
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
		}
		//If we are swapping a GE we store the new GE Id, the old GE BSP and the new GE BSP
		else if(secondAccount.Location_Type__c == AMS_Utils.GE){
			swapRelatedFields(secondAccount, firstAccount);
			swapWrapper.newGE = secondAccount.Id;
			swapWrapper.bspOldGE = firstAccount.IATA_ISO_Country__r.AMS_Settlement_System__c;
			swapWrapper.bspNewGE = secondAccount.IATA_ISO_Country__r.AMS_Settlement_System__c;
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

		srcAcct.ANG_IEP_Status__c = null;
		srcAcct.ANG_HE_RiskStatus__c = null;
		srcAcct.ANG_IEP_HE_AccntNum__c = null;
		srcAcct.ANG_HE_CashCondition__c = false;
		srcAcct.ANG_HE_RiskHistoryAssessment__c = null;

		ANG_RHCHelper.moveRHCInfos(srcAcct.RHC_Informations__r, new Map<Id,Id>{srcAcct.Id => assignFieldsAcct.Id});

        System.enqueueJob(new ANG_Risk_Helper.FutureHandler(new Map<Id,Id>{srcAcct.Id => assignFieldsAcct.Id}));
		
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

}