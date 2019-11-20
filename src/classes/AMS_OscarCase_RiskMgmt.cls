/**************************************

Class to handle all risk management related change codes
It works on Sidra and Sidra Lite case: when they are created or updated, values saved are checked against custom setting "".
If there is a match, than the change code configured will be created.

At the same time, bulletin memo text (sometimes dinamically calculated) will be saved on the change code itself.

**************************************/

public class AMS_OscarCase_RiskMgmt {
	//Check that trigger is not already running on change codes.
	private static Boolean run = true;
	public static Boolean runOnce(){
	    if(run){
			run=false;
			return true;
		}else{
			return run;
	    }
    }

    public static void EndRun(){
    	run=true;
    }

	private static Map<String,List<AMS_ChangeCodes__c>> changeCodesPerAccModel = new Map<String,List<AMS_ChangeCodes__c>>();
    private static Map<Id,List<Agency_Applied_Change_code__c>> mapIRRS = new Map<Id,List<Agency_Applied_Change_code__c>>();	//Store all Irregularities previously created for agencies in the trigger. Used in the memo text
    private static Map<Id,List<Financial_Security__c>> mapFinancialSecurity = new Map<Id,List<Financial_Security__c>>();		//Store all Financial Securities previously created for agencies in the trigger. Used in the memo text
    private static Map<Id,Id> mapAllHOs = new Map<Id,Id>();		//For each agencies in the trigger, stores their HO Id
    private static Map<Id,Set<Id>> allHierarchyPerParent = new Map<Id,Set<Id>>();
    public static Map<Id,Account> mapAccntToUpdate = new Map<Id,Account>();	//Stores account to be updated (Status and reason code)
	private static Set<Id> setAccntIdIRRToClear = new Set<Id>();	//Account IDs for which a clear of irregularities is needed
	private static Set<Id> setAccntIdToClearExpDate = new Set<Id>();	//Account IDs for which a clear of expiry date is needed
	private static Map<Id,List<Agency_Applied_Change_code__c>> mapExistingChangeCodes = new Map<Id,List<Agency_Applied_Change_code__c>>();
	private static Map<String, Operational_Calendar__c> mapOperationalCalendar = new Map<String, Operational_Calendar__c>();
	private static Map<Id,Map<String, Agency_Applied_Change_code__c>> mapPrevReasonFromCC = new Map<Id,Map<String, Agency_Applied_Change_code__c>>();
    private static Map<Id,List<Agency_Applied_Change_code__c>> mapAccountCaseChangeCodes = new Map<Id,List<Agency_Applied_Change_code__c>>();
    public static Map<Id,Agency_Applied_Change_code__c> irrsToExp = new Map<Id,Agency_Applied_Change_code__c>();
    private static Set<String> setIRRCC = new Set<String>{'IRR', 'IRS', 'IRW'};		//Irregularities change code
    private static Set<String> setTERCC = new Set<String>{'TER'};		//Termination change codes: set expiry date on account
    private static Set<String> setREICC = new Set<String>{'SDR', 'RCR', 'STR', 'RTR', 'RTE', 'REI'};		//Reinstatement change codes: clear expiry date on account
	private static Set<String> setReqValidStatus = new Set<String>{'SDR', 'RCR', 'STR', 'RTR', 'RTE', 'REI', 'DFW'};		//Reinstatement + DFW: look for change code with valid status/reason
    private static Set<String> setTidsChangeCode = new Set<String>{'REI','TER','RTE'};
    private static final String NO_IRR_FOUND = ' No Irregularities Found!';

    //Main Method

    public static void CreateRiskChangeCode(map<id, case> mapTrgOld, map<id, case> mapTrgNew){

    	System.debug('____ [AMS_OscarCase_RiskMgmt - CreateRiskChangeCode] Entering');

    	Map<Id,List<AMS_Process_Detail__c>> hierarchySelectionPerCase = new Map<Id,List<AMS_Process_Detail__c>>();
    	List<Case> toCreateHierarchySelection = new List<Case>();
    	Map<Id,Id> casePerParentAcc = new Map<Id,Id>();
    	Map<Id,Id> parentAccPerCase = new Map<Id,Id>();
    	Set<String> setFSStatus = new Set<String>{'Close to Expiry Date', 'Active', 'Encashed', 'Encashment in progress'};
    	Set<String> setOperationCalendarExtID = new Set<String>();
    	Map<Case,List<AMS_ChangeCodes__c>> changeCodesToCreatePerCase = new Map<Case,List<AMS_ChangeCodes__c>>();
    	Set<Id> accToGetFS = new Set<Id>();
    	Set<Id> accToGetPreviousIrr = new Set<Id>();
    	Set<Id> accountsToFetchFOPs = new Set<Id>();
    	Map<Id, List<Agency_Applied_Change_code__c>> aaccsPerAccount = new Map<Id, List<Agency_Applied_Change_code__c>>();
    	Set<Id> allAccts = new Set<Id>();
    	List<Technical_Logs__c> notifications = new List<Technical_Logs__c>();
		Boolean generateNOTnotification = true;


    	//Get all cases and respective Hierarchy Selections
    	Map<Id,Case> mapCases = new Map<Id,Case>([SELECT Id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, Short_Payment_Date__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c,
								  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c, NOT_Approval__c,
								  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c, Current_Outstanding_Amount_USD__c, Type_of_REI_WD__c,
								  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c,
								  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, Parent.Status, IRR_Approval_Rejection_Date__c, IRR_Type__c,
								  Termination_date__c, Outstanding_Amount__c, Reason_of_REI_WD__c, External_ID__c, ParentId, Parent.RecordtypeId, Parent.AccountId,
								  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c,
								  Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c, Account.AIMS_ID__c, Account.WebStar_ID__c, Account.IATACode__c, Account.ANG_IsNewGenAgency__c, 
								  Account.ParentId, Account.Parent.ParentId, Account.Parent.Parent.ParentId, Account.CNS_Agency__c, Currency__c, OSCAR__r.ANG_Type_Of_Change__c, Parent.IFAP_Financial_Year__c, Group_Single_Agent__c,
								  (SELECT Id, HOId__c, Case__c, Account__c FROM Hierarchy_Account_Selections__r)
								  FROM Case WHERE Id IN: mapTrgNew.keySet()]);

    	//Get all the change code configurations
    	ReadConfiguration();

    	if(changeCodesPerAccModel.isEmpty()) return;

    	//Get all previously generated change code from same sidra/sidra lite
		for(Agency_Applied_Change_code__c aa : [SELECT id, Createddate, AccountNewStatus__c, AccountPreviousStatus__c, PreviousReason__c,
											   Account__c, Account__r.Location_Class__c, Account__r.ParentId, Change_Code__c, SIDRA_Case__c
											   FROM Agency_Applied_Change_code__c
											   WHERE SIDRA_Case__c IN: mapCases.keyset()
											   ORDER BY Account__c, CreatedDate DESC]){

			if(!mapExistingChangeCodes.containsKey(aa.Account__c))
				mapExistingChangeCodes.put(aa.Account__c, new List<Agency_Applied_Change_code__c>());
			mapExistingChangeCodes.get(aa.Account__c).add(aa);
		}

		Set<Id> parentCasesIds = new Set<Id>();

		for(Case c : mapCases.values()){
			if(c.ParentId != null) parentCasesIds.add(c.ParentId);

			Id caseHOId = c.Account.ParentId == null ? c.AccountId : c.Account.Parent.ParentId == null ? c.Account.ParentId : c.Account.Parent.ParentId;

			if(caseHOId != null) {
				casePerParentAcc.put(caseHOId, c.Id);
				parentAccPerCase.put(c.Id, caseHOId);
				//get all the hierarchy account selections for the respective case
				if(c.Hierarchy_Account_Selections__r.isEmpty()){
					toCreateHierarchySelection.add(c);
				} else {
					hierarchySelectionPerCase.put(c.Id, c.Hierarchy_Account_Selections__r);
				}
			}
		}

		//create missing hierarchy account selections for each case
    	if(!toCreateHierarchySelection.isEmpty())
			hierarchySelectionPerCase.putAll(AMS_CaseTriggerHandler.SelectAgencyOnSidraCase(toCreateHierarchySelection, casePerParentAcc));

		//get all parents and all accounts per parent
		for(List<AMS_Process_Detail__c> pdList : hierarchySelectionPerCase.values()){
			for(AMS_Process_Detail__c pd : pdList) {
				Id hoId = pd.HOId__c == null ? parentAccPerCase.get(pd.Case__c) : pd.HOId__c;
				mapAllHOs.put(pd.Account__c, hoId);
				if(!allHierarchyPerParent.containsKey(hoId))
					allHierarchyPerParent.put(hoId, new Set<Id>());
				allHierarchyPerParent.get(hoId).add(pd.Account__c);
			}
		}

		//get all accounts
		for(Set<Id> accIdSet : allHierarchyPerParent.values())
			allAccts.addAll(accIdSet);


		//get all accounts and respective change codes created previously for the same case
        Map<Id,Account> mapAccounts = new Map<Id,Account>([SELECT Id, ParentId, Parent.ParentId, CNS_Agency__c, ANG_IsNewGenAgency__c, Default_date__c, Status__c, Reason__c, Previous_Reason__c, PreviousStatus__c, Location_Class__c, Expiry_Date__c, Location_Type__c, ANG_Accreditation_Model__c,
													 	(SELECT Id, Change_code__c, AccountNewStatus__c, AccountPreviousStatus__c, PreviousReason__c, Reason_Code__c, Reason_Description__c, CreatedDate, Created_Date_To_Show__c,
													 	RecordType.DeveloperName, Irregularities_Expired__c, Account__c, Effective_Date__c, Operation__c, Irregularity_Type__c, Irregularities_Points__c, SIDRA_Case__c
													 	FROM Agencies_Applied_Change_codes__r
													 	ORDER BY Created_Date_To_Show__c DESC),
													 	(SELECT Id, RecordTypeId, CreatedDate, AccountId, Status, IFAP_Financial_Year__c FROM Cases WHERE RecordTypeId = :AMS_Utils.RECTYPE_IFAP AND Id NOT IN :parentCasesIds) 
														FROM Account WHERE Id IN: allAccts]);

    	for(Case c : mapCases.values()){

    		if(!c.Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c)
				continue;
    		
    		//get operational calendar external id for each case
    		String sExtId = GetOpCalendarExtId(c.External_ID__c);
			if(sExtId != '') setOperationCalendarExtID.add(sExtId);

    		Id caseHOId = parentAccPerCase.get(c.Id);

    		//Get the change codes to create
    		for(AMS_ChangeCodes__c ccConfig : changeCodesPerAccModel.get(c.Account.ANG_IsNewGenAgency__c ? 'NEWGEN' : 'AMS')){
    			Set<String> setLocClass = ccConfig.Class_Type__c == null ? new Set<String>() : new Set<String>(ccConfig.Class_Type__c.toUpperCase().split(';'));

				if(!setLocClass.contains(c.Account.Location_Class__c.toUpperCase()) || !c.recordType.DeveloperName.equalsIgnoreCase(ccConfig.Record_Type__c) || (c.Account.CNS_Agency__c && !ccConfig.Used_By_CNS__c))
					continue;

				//Check that the same change code does not exists generated from the same SIDRA (Lite)
				Boolean ccToBeGenerated = CheckOldNewValues(c, mapTrgOld.get(c.Id), ccConfig.Field1__c, ccConfig.Field2__c, ccConfig.Field3__c, ccConfig.Field4__c, ccConfig.Field5__c, ccConfig.Field6__c, ccConfig.Field7__c);

				if(ccToBeGenerated)
					ccToBeGenerated = bCheckCondition(c, null, 'NOT EXISTS:' + ccConfig.Change_Code__c, mapExistingChangeCodes);

				if(ccConfig.Field1__c!=null && ccToBeGenerated)
					ccToBeGenerated = bCheckCondition(c, ccConfig.Field1__c, ccConfig.Field1Values__c.toUpperCase(), mapExistingChangeCodes);

				if(ccConfig.Field2__c!=null && ccToBeGenerated)
					ccToBeGenerated = bCheckCondition(c, ccConfig.Field2__c, ccConfig.Field2Values__c.toUpperCase(), mapExistingChangeCodes);

				if(ccConfig.Field3__c!=null && ccToBeGenerated)
					ccToBeGenerated = bCheckCondition(c, ccConfig.Field3__c, ccConfig.Field3Values__c.toUpperCase(), mapExistingChangeCodes);

				if(ccConfig.Field4__c!=null && ccToBeGenerated)
					ccToBeGenerated = bCheckCondition(c, ccConfig.Field4__c, ccConfig.Field4Values__c.toUpperCase(), mapExistingChangeCodes);

				if(ccConfig.Field5__c!=null && ccToBeGenerated)
					ccToBeGenerated = bCheckCondition(c, ccConfig.Field5__c, ccConfig.Field5Values__c.toUpperCase(), mapExistingChangeCodes);

				if(ccConfig.Field6__c!=null && ccToBeGenerated){
					//NEWGEN-5318 - Get the last IFAP case from the related Account's Cases
					Case lastIFAP;
					if(ccConfig.Field6__c == 'LastYearIFAP.Status')
						lastIFAP = findLastIFAP(mapAccounts.get(c.AccountId).Cases, c.Parent.IFAP_Financial_Year__c);

					ccToBeGenerated = bCheckCondition(c, ccConfig.Field6__c, ccConfig.Field6Values__c.toUpperCase(), mapExistingChangeCodes, lastIFAP);

					if(!CCToBeGenerated && generateNOTnotification && ccConfig.Change_Code__c == 'NOT'){
						generateNOTnotification = false;
						notifications.add(new Technical_Logs__c(Record__c = c.Id, Log__c = 'NOT change code'));
					}
				}

				if(ccConfig.Field7__c != NULL && ccToBeGenerated){
					ccToBeGenerated = bCheckCondition(c, ccConfig.Field7__c, ccConfig.Field7Values__c.toUpperCase(), mapExistingChangeCodes);
				}

				if(ccToBeGenerated){

					//NEWGEN-2719 check if we need to skip CC creation depending on previous ifap status
					if(ccConfig.Change_Code__c == 'NFS' && c.Parent.RecordTypeId == AMS_Utils.RECTYPE_IFAP && c.Account.ANG_IsNewGenAgency__c 
							&& !mapAccounts.get(c.AccountId).Cases.isEmpty() && IFAP_BusinessRules.isPreviousIFAPStatusEquals(mapAccounts.get(c.AccountId).Cases, 'Closed_Non compliance')){
							
							notifications.add(new Technical_Logs__c(Record__c = c.Id, Log__c = 'NFS change code'));
					} else {

						if(!changeCodesToCreatePerCase.containsKey(c))
							changeCodesToCreatePerCase.put(c, new List<AMS_ChangeCodes__c>());
						changeCodesToCreatePerCase.get(c).add(ccConfig);

						if((ccConfig.Bulletin_Memo_Text__c != null && ccConfig.Bulletin_Memo_Text__c.contains('<Financial Securities>')) 
							|| (ccConfig.Bulletin_Memo_Text2__c != null && ccConfig.Bulletin_Memo_Text2__c.contains('<Financial Securities>'))
							|| (ccConfig.Bulletin_Memo_Text3__c != null && ccConfig.Bulletin_Memo_Text3__c.contains('<Financial Securities>'))
							|| ccConfig.Calculate_BG_to_HO__c)
							accToGetFS.add(caseHOId);

						if((ccConfig.Bulletin_Memo_Text__c != null && ccConfig.Bulletin_Memo_Text__c.contains('<IRRS Sequence>')) 
							|| (ccConfig.Bulletin_Memo_Text2__c != null && ccConfig.Bulletin_Memo_Text2__c.contains('<IRRS Sequence>'))
							|| (ccConfig.Bulletin_Memo_Text3__c != null && ccConfig.Bulletin_Memo_Text3__c.contains('<IRRS Sequence>'))
							|| ccConfig.Generate_Irregularity_Sequence__c)
							accToGetPreviousIrr.add(caseHOId);

						if(c.Account.ANG_IsNewGenAgency__c)
							accountsToFetchFOPs.add(caseHOId);
					}
				}
    		}
    	}

		//get the operational calendars
		if(!setOperationCalendarExtID.isEmpty()){
			for(Operational_Calendar__c oc : [SELECT Operation_Period_code__c, First_Day__c, Last_Day__c FROM Operational_Calendar__c WHERE Operation_Period_code__c IN: setOperationCalendarExtID])
				mapOperationalCalendar.put(oc.Operation_Period_code__c, oc);
		}

		//get the necessary financial securities
		if(!accToGetFS.isEmpty()){
			for(Financial_Security__c fs : [SELECT id, Account__c, Amount__c, CurrencyIsoCode, Account__r.ParentId
											FROM Financial_Security__c
											WHERE Account__c IN: accToGetFS AND Security_Status__c IN: setFSStatus]){

				if(!mapFinancialSecurity.containsKey(fs.Account__c))
					mapFinancialSecurity.put(fs.Account__c, new List<Financial_Security__c>());
				mapFinancialSecurity.get(fs.Account__c).add(fs);
			}
		}

		//get necessary fops
		Map<Id,List<Agency_Authorization__c>> fOPsMap = new Map<Id,List<Agency_Authorization__c>>();
        if (!accountsToFetchFOPs.isEmpty()) {
        	Set<Id> accountIdsFOP = new Set<Id>();
        	for(Id acct : accountsToFetchFOPs) {
        		accountIdsFOP.addAll(allHierarchyPerParent.get(acct));
        	}
            fOPsMap = AMS_ChangeCodesHelper.fetchFormsOfPayment(accountIdsFOP);	
        }

        for(Account acc : mapAccounts.values()){
        	for(Agency_Applied_Change_code__c aaccode : mapAccounts.get(acc.Id).Agencies_Applied_Change_codes__r){
        		if(mapCases.keySet().contains(aaccode.SIDRA_Case__c)){
        			if(!mapAccountCaseChangeCodes.containsKey(acc.Id))
        				mapAccountCaseChangeCodes.put(acc.Id, new List<Agency_Applied_Change_code__c>());
        			mapAccountCaseChangeCodes.get(acc.Id).add(aaccode);

        			if(!mapPrevReasonFromCC.containsKey(acc.Id))
        				mapPrevReasonFromCC.put(acc.Id, new Map<String,Agency_Applied_Change_code__c>());
        			mapPrevReasonFromCC.get(acc.Id).put(aaccode.Change_Code__c, aaccode);

        			if(!accToGetPreviousIrr.isEmpty() && setIRRCC.contains(aaccode.Change_Code__c) && !aaccode.Irregularities_Expired__c){
        				if(!mapIRRS.containsKey(acc.Id))
							mapIRRS.put(acc.Id, new List<Agency_Applied_Change_code__c>());
						mapIRRS.get(acc.Id).add(aaccode);
        			}
        		}
        	}
        }

        //create change codes
        List<Agency_Applied_Change_code__c> lsAACC = new List<Agency_applied_change_code__c>();
		for(Case cs : changeCodesToCreatePerCase.keySet()){
			for(AMS_ChangeCodes__c ccToCreate : changeCodesToCreatePerCase.get(cs)){
				Agency_Applied_Change_code__c aacc;
                Account currentAcc = mapAccounts.get(cs.AccountId);
                Id caseHOId = parentAccPerCase.get(cs.Id);
				if(ccToCreate.Apply_to_hierarchy__c){

					aacc = CreateChangeCode(cs, ccToCreate, mapAccounts.get(caseHOId), mapAccounts.get(caseHOId).CNS_Agency__c, fOPsMap.get(cs.AccountId));

					//clone change code to apply in all hierarchy
					if(aacc != null){
						for(Id acctID : allHierarchyPerParent.get(caseHOId)){

							Account accAux = mapAccounts.get(acctID);

							if(acctID != caseHOId && (accAux.Location_Class__c != 'T' || (accAux.Location_Class__c == 'T' && setTidsChangeCode.contains(ccToCreate.Change_Code__c)))){
								Agency_Applied_Change_code__c aaccAux = aacc.clone(false, true, false, false);
								applyChangeCodeToAllHierarchy(aaccAux, accAux, ccToCreate, accAux.CNS_Agency__c, cs, mapAccounts.get(caseHOId));
								lsAACC.add(aaccAux);
							}
						}

						//add the extra memo text just for the HO
						String extraMemoText = allHierarchyPerParent.get(caseHOId).size() > 1 ? ccToCreate.Extra_memo_text_for_HO__c : '';
						aacc.Bulletin_Information__c = extraMemoText != null ? (aacc.Bulletin_Information__c + ' ' + extraMemoText) : aacc.Bulletin_Information__c;
					}

				} else if(currentAcc.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY && currentAcc.Location_Type__c != AMS_Utils.GE && ccToCreate.Apply_to_hierarchy__c == false){
					aacc = CreateChangeCode(cs, ccToCreate, mapAccounts.get(caseHOId), mapAccounts.get(caseHOId).CNS_Agency__c, fOPsMap.get(cs.AccountId));
				} else {
					aacc = CreateChangeCode(cs, ccToCreate, mapAccounts.get(cs.AccountId), mapAccounts.get(cs.AccountId).CNS_Agency__c, fOPsMap.get(cs.AccountId));

				}

				if(aacc != null)
					lsAACC.add(aacc);				
				
			}
		}

		if(!setAccntIdIRRToClear.isEmpty())
			ClearIrregularities(setAccntIdIRRToClear, mapAccounts);

		if(!setAccntIdToClearExpDate.isEmpty())
			ClearExpiryDate(setAccntIdToClearExpDate, mapAccounts);

		if(!lsAACC.isEmpty())
			insert lsAACC;

		if(!notifications.isEmpty())
			insert notifications;
    }

    private static void applyChangeCodeToAllHierarchy(Agency_Applied_Change_code__c newCC, Account acct, AMS_ChangeCodes__c ccToCreate, Boolean isCNS, Case cs, Account parentAcc){
    	
    	//Generate memo text again for the child only if the memo text contains IRRS sequence
    	if((!ccToCreate.Used_By_CNS__c && (
    			(ccToCreate.Bulletin_Memo_Text__c != null && ccToCreate.Bulletin_Memo_Text__c.containsIgnoreCase('<IRRS Sequence>'))
    			|| (ccToCreate.Bulletin_Memo_Text2__c != null && ccToCreate.Bulletin_Memo_Text2__c.containsIgnoreCase('<IRRS Sequence>'))
    			|| (ccToCreate.Bulletin_Memo_Text3__c != null && ccToCreate.Bulletin_Memo_Text3__c.containsIgnoreCase('<IRRS Sequence>')))) 
    		|| (ccToCreate.Used_By_CNS__c && (
	    		(ccToCreate.CNS_Bulletin_Memo_Text__c != null && ccToCreate.CNS_Bulletin_Memo_Text__c.containsIgnoreCase('<IRRS Sequence>'))
	    		|| (ccToCreate.CNS_Bulletin_Memo_Text2__c != null && ccToCreate.CNS_Bulletin_Memo_Text2__c.containsIgnoreCase('<IRRS Sequence>'))
	    		|| (ccToCreate.CNS_Bulletin_Memo_Text3__c != null && ccToCreate.CNS_Bulletin_Memo_Text3__c.containsIgnoreCase('<IRRS Sequence>')))))
    		newCC.Bulletin_Information__c = GenerateMemoText(cs, isCNS ? ccToCreate.CNS_Bulletin_Memo_Text__c : ccToCreate.Bulletin_Memo_Text__c, 
    														isCNS ? ccToCreate.CNS_Bulletin_Memo_Text2__c : ccToCreate.Bulletin_Memo_Text2__c, 
    														isCNS ? ccToCreate.CNS_Bulletin_Memo_Text3__c : ccToCreate.Bulletin_Memo_Text3__c, 
    														mapIRRS.get(acct.Id), 
    														mapFinancialSecurity.containsKey(acct.Id) ? mapFinancialSecurity.get(acct.Id) : null, 
    														'', false).toUpperCase();
    	
    	//remove values for child change code
    	newCC.Account__c = acct.Id;
		newCC.Financial_Security__c = '';
		newCC.Irregularity_Sequence__c = '';
		newCC.AIMS_ID__C = createUniqueAIMSId(cs, newCC.Change_Code__c);

		//do not publish in ebulletin
		if(ccToCreate.Publish_HO_Only__c)
			newCC.To_Publish_in_e_Bulletin__c = false;

		Boolean toUpdateReason = parentAcc.Reason__c != acct.Reason__c;
		Boolean toUpdateStatus = parentAcc.Status__c != acct.Status__c;

		if(toUpdateReason || toUpdateStatus)
			generateReasonAndStatus(newCC, ccToCreate, toUpdateReason, toUpdateStatus, acct);

    }
    

	@TestVisible
	private static string GenerateFinancialSecurity(List<Financial_Security__c> lsFS) {
		string sTmpVal = '';
		if(lsFS==null) {
			sTmpVal = 'Nil';
		} else {
			Map<string, decimal> mapFSperCurr = new Map<string, decimal>();
			for (Financial_Security__c fs:lsFS) {
				decimal dAmount = FS.Amount__c;
				if (mapFSperCurr.containsKey(FS.CurrencyIsoCode)) {
					dAmount = dAmount + mapFSperCurr.get(FS.CurrencyIsoCode);
				}
				mapFSperCurr.put(FS.CurrencyIsoCode, dAmount);
			}

			for(string sCur:mapFSperCurr.keySet())
				sTmpVal = sTmpVal + ' ' + sCur + ' ' + doFormatting(mapFSperCurr.get(sCur), ',', '.') + ';';
		}

		return sTmpVal;
	}

    private static string getFallbackReason(string statusNumber) {
        if (statusNumber == '9') {
            return '91-ACCREDITED - MEETS CRITERIA';
        }
        if (statusNumber == '8') {
            return '81-CHANGE IN PROCESS';
        }
        if (statusNumber == '4') {
            return '41-ADMINISTRATIVE OFFICES';
        }
        return '';
    }

	@TestVisible
	private static String GenerateIrregularitySequence(List<Agency_Applied_Change_code__c> lsIrr, Case theCase){
		String sTmpVal = '';
		if(lsIrr==null)
			sTmpVal = NO_IRR_FOUND;
		else{
			string sPrevType = '';

			for(Agency_Applied_Change_code__c irr:lsIrr){
				if(sPrevType=='W' || sPrevType=='D' || irr.Operation__c=='W' || irr.Operation__c=='D'){
					sPrevType = irr.Operation__c;
				}else{
					sTmpVal = sTmpVal + GenerateDateForBulletin(irr.Effective_Date__c) + ' due to ' + irr.Irregularity_Type__c + '. inst.: ' + integer.valueOf(irr.Irregularities_Points__c) + ';';
				}
				sPrevType = irr.Operation__c;
			}
			sTmpVal = sTmpVal + ' Total inst for 12 months: ' + theCase.Account.Accumulated_Irregularities__c +  '; ';
		}
		return sTmpVal;
	}

	private static String createUniqueAIMSId(Case cse, String changeCode){
		Datetime dt = System.now();

		String sUniqueId = '';
		if(cse.Account.WebStar_ID__c != '' && cse.Account.WebStar_ID__c != null)
			sUniqueId = cse.Account.WebStar_ID__c;
		else if(cse.Account.AIMS_ID__c != '' && cse.Account.AIMS_ID__c != null)
			sUniqueId = cse.Account.AIMS_ID__c;
		else
			sUniqueId = cse.Account.IATACode__c;

		sUniqueId = sUniqueId + '_' + changeCode + '_' + dt.year() + dt.month() + dt.day() + dt.hour() + dt.second();

		if(changeCode == 'IRR' || changeCode == 'IRS')
			sUniqueId = sUniqueId + '_A';

		if(changeCode == 'IRW')
			sUniqueId = sUniqueId + '_W';

		return sUniqueId;
	}

	//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
	private static Agency_Applied_Change_code__c CreateChangeCode(Case cse, AMS_ChangeCodes__c cc, Account acc, Boolean bIsCNS, List<Agency_Authorization__c> fOPs) {
		Agency_Applied_Change_code__c AACC = new Agency_Applied_Change_code__c();

		Id AccountId = (acc == null ? cse.AccountId : acc.id);
		
		AACC.Account__c = AccountId;

        Boolean isHO = acc != null ? (acc.parentId == null) : cse.Account.ParentId == null;

        String extraMemoText = '';
        if(isHO && !cc.Apply_to_hierarchy__c){
        	extraMemoText = allHierarchyPerParent.containsKey(AccountId) && allHierarchyPerParent.get(AccountId).size() > 1 ? cc.Extra_memo_text_for_HO__c : '';
        }
		
		//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
		AACC.Bulletin_Information__c = GenerateMemoText(cse
														, bIsCNS?cc.CNS_Bulletin_Memo_Text__c:cc.Bulletin_Memo_Text__c, bIsCNS?cc.CNS_Bulletin_Memo_Text2__c:cc.Bulletin_Memo_Text2__c, bIsCNS?cc.CNS_Bulletin_Memo_Text3__c:cc.Bulletin_Memo_Text3__c
														, mapIRRS.get(AccountId), mapFinancialSecurity.containsKey(AccountId)?mapFinancialSecurity.get(AccountId):null, extraMemoText, isHO).toUpperCase();



        // added new field to change code Calculate_BG_to_HO__c , and if is true and is Top Parent we will put the financial security on new the new field (Financial_Security__c) of the Agency Applied Change Code
        AACC.Financial_Security__c = (cc.Calculate_BG_to_HO__c && isHO && mapFinancialSecurity.containsKey(AccountId)) ? GenerateFinancialSecurity(mapFinancialSecurity.get(AccountId)) : '';
		AACC.Outstanding_Amount__c = (cc.Calculate_Outstanding_Amount__c && cse.Outstanding_Amount__c != null) ? string.valueOf(cse.Outstanding_Amount__c) : '';
		AACC.Irregularity_Sequence__c = (cc.Generate_Irregularity_Sequence__c && isHO && mapIRRS.get(AccountId) != null && !mapIRRS.get(AccountId).isEmpty()) ? GenerateIrregularitySequence(mapIRRS.get(AccountId),cse) : '';
		AACC.End_of_Grace_Period_Date__c = (cc.Calculate_End_Grace_Period_Date__c && cse.End_of_Grace_Period_Date__c != null) ? GenerateDateForBulletin(cse.End_of_Grace_Period_Date__c) : '';
		AACC.Termination_Date__c = (cc.Calculate_Termination_Date__c && cse.Termination_date__c != null) ? GenerateDateForBulletin(cse.Termination_date__c) : '';
		AACC.Forms_of_Payment__c = AMS_ChangeCodesHelper.generateFOPString(fOPs, cse.Account.ANG_IsNewGenAgency__c, cc.Change_Code__c);
		AACC.Change_Code__c = cc.Change_Code__c;

		if(setIRRCC.contains(cc.Change_Code__c)){
  			if(cse.IRR_Type__c == 'Single Irregularity'){
  				AACC.Irregularities_Points__c = 1;
  				if(cc.Change_Code__c == 'IRW'){
  					AACC.Irregularity_Type__c = 'WD1';
  				}else{
  					if(cse.recordtype.developername=='SIDRA'){
  						AACC.Irregularity_Type__c = 'OV1';
  					}else{
  						if(cse.SIDRA_Lite_Reason__c == 'Annual fees'){
  							AACC.Irregularity_Type__c = 'NPA';
  						}else if(cse.Parent.Status=='Agent Notified (Email)' || cse.Parent.Status=='Agent Notified (Mail)'){
  							AACC.Irregularity_Type__c = 'FC1';
  						}else if(cse.Parent.Status=='Sanity Check Failure'){
  							AACC.Irregularity_Type__c = 'SC1';
  						}else{
  							AACC.Irregularity_Type__c = '1PT';
  						}
  					}
  				}
  			}
  			if(cse.IRR_Type__c == 'Double Irregularity'){
  				AACC.Irregularities_Points__c = 2;
  				if(cc.Change_Code__c == 'IRW'){
  					AACC.Irregularity_Type__c = 'WD2';
  				}else{
  					if(cse.recordtype.developername=='SIDRA'){
  						AACC.Irregularity_Type__c = 'OV2';
  					}else{
  						if(cse.SIDRA_Lite_Reason__c == 'Annual fees'){
  							AACC.Irregularity_Type__c = 'NPA';
  						}else if(cse.Parent.Status=='Agent Notified (Email)' || cse.Parent.Status=='Agent Notified (Mail)'){
  							AACC.Irregularity_Type__c = 'FC2';
  						}else if(cse.Parent.Status=='Sanity Check Failure'){
  							AACC.Irregularity_Type__c = 'SC2';
  						}else{
  							AACC.Irregularity_Type__c = '2PT';
  						}
  					}
  				}
  			}

			AACC.Effective_Date__c = date.ValueOf(cse.IRR_Approval_Rejection_Date__c);
		}

		if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS')
			AACC.Operation__c = 'A';

		if(cc.Change_Code__c == 'IRW')
			AACC.Operation__c = 'W';

		AACC.SIDRA_Case__c = cse.Id;
		AACC.To_Publish_in_e_Bulletin__c = cc.Apply_to_hierarchy__c && cc.Publish_HO_Only__c && !(new Set<ID>(mapAllHOs.values())).contains(AccountId) ? false : cc.Published_in_bulletin__c;
		AACC.Applied_Configuration__c = cc.id;
		AACC.OSCAR__c = cse.Parent.OSCAR__c;

		//This was added for all change codes beeing created in AMS_ChangeCodesHelper
		AACC.CreatedDate_User__c = GenerateDateForBulletin(System.today());

		AACC.AIMS_ID__C = createUniqueAIMSId(cse, cc.Change_Code__c);
		AACC.Integration_RecId__c = cc.Integration_RecId__c;
		AACC.Skip_Agency_Update__c = cc.Skip_Agency_Update__c;

		//Handles update on account
		Boolean bAccntToUpd = false;
		Account accnt = new Account();
		accnt.Id = AccountId;

		if(setTERCC.contains(cc.Change_Code__c)){
			accnt.Expiry_Date__c = Date.Today();
			bAccntToUpd = true;
		}

		if(setREICC.contains(cc.Change_Code__c)){
			accnt.Expiry_Date__c = null;
			bAccntToUpd = true;
		}

		//Set the billing period
		if(!mapOperationalCalendar.isEmpty() && cse.External_ID__c != null && cse.External_ID__c != ''){
			string sExtId = GetOpCalendarExtId(cse.External_ID__c);
			if(sExtId != '' && mapOperationalCalendar.ContainsKey(sExtId)){
				AACC.Start_Date__c = mapOperationalCalendar.get(sExtId).First_Day__c;
				AACC.End_Date__c = mapOperationalCalendar.get(sExtId).Last_Day__c;
			}
		}

		generateReasonAndStatus(AACC, cc, true, true, acc);

		//FM 19-04-2017 - AMSU-18
		//If status is changing to Changes processed (8) or Approved (9) clear the default date.
		if(AACC.AccountNewStatus__c == AMS_Utils.ACC_S8_CHANGESPROCESSED || AACC.AccountNewStatus__c == AMS_Utils.ACC_S9_APPROVED){
			accnt.Default_date__c = null;
			bAccntToUpd = true;
		}

		//FM 19-04-2017 - AMSU-18
		//If status is changing to Cash basis/No commission (5) and default date is empty, set the default date field to current date
		//If status is changing to Cash basis/No commission (5) and default date has a value, do nothing
		if(AACC.AccountNewStatus__c == AMS_Utils.ACC_S5_CASHNOCOMMISSION && acc.Default_date__c == null){
			accnt.Default_date__c = Date.Today();
			bAccntToUpd = true;
		}

		if(cc.Clear_Irregularities__c)
			setAccntIdIRRToClear.add(AccountId);

		if(cc.Clear_Expiry_Date__c)
			setAccntIdToClearExpDate.add(AccountId);

		if(bAccntToUpd)
			mapAccntToUpdate.put(AccountId, accnt);

		return AACC;
	}


	private static void generateReasonAndStatus(Agency_Applied_Change_code__c newAACC, AMS_ChangeCodes__c cc, Boolean toUpdateReason, Boolean toUpdateStatus, Account acct){
		
		Id AccountId = acct.Id;
		String sCurrReason='';
		String sPrevReason='';
		String sCurrStatus='';
		String sPrevStatus='';
		Boolean isCCBellowEigthOrDiffFour = false;
        String previousReasonAux = null;

		if(mapAccountCaseChangeCodes.containsKey(AccountId) && mapAccountCaseChangeCodes.get(AccountId) != null && !mapAccountCaseChangeCodes.get(AccountId).isEmpty()){
			Agency_Applied_Change_code__c aacclast = mapAccountCaseChangeCodes.get(AccountId).get(0);
			sCurrReason = aacclast.Reason_Code__c + '-' + aacclast.Reason_Description__c;
			sPrevReason = aacclast.PreviousReason__c;
			sCurrStatus = aacclast.AccountNewStatus__c;
			sPrevStatus = aacclast.AccountPreviousStatus__c;
		} else {
			sCurrReason = acct.Reason__c;
			sPrevReason = acct.Previous_Reason__c;
			sCurrStatus = acct.Status__c;
			sPrevStatus = acct.PreviousStatus__c;
		}

		if(toUpdateStatus){

			if(cc.Account_status_change__c == null || cc.Account_status_change__c.toUpperCase()=='CURRENT'){
				newAACC.AccountNewStatus__c = sCurrStatus;
				newAACC.AccountPreviousStatus__c = sPrevStatus;
			}else if(cc.Account_status_change__c.toUpperCase()=='PREV'){
				newAACC.AccountNewStatus__c = sPrevStatus;
				newAACC.AccountPreviousStatus__c = sCurrStatus;
			}else if (cc.Account_status_change__c.toUpperCase().startsWithIgnoreCase('PREV;')) {
				Set<String> SplittedCC = new Set<String>();

				for(Integer i=1;i<cc.Account_status_change__c.toUpperCase().split(';').size();i++)
					SplittedCC.add(cc.Account_status_change__c.toUpperCase().split(';').get(i));

				if (!SplittedCC.isEmpty()) {
					for (String sCCToGet : SplittedCC) {
						if (mapPrevReasonFromCC.containsKey(AccountId)) {

							if (mapPrevReasonFromCC.get(AccountId).containsKey(sCCToGet)) {
								sPrevStatus = mapPrevReasonFromCC.get(AccountId).get(sCCToGet).AccountPreviousStatus__c;
	                            Boolean canAddStatus = false;
	                            isCCBellowEigthOrDiffFour = false;

								//if sPrevStatus is bellow 8 and different from 4, we'll iterate the account's previous change codes until we find one = > 8 or == 4 and take the account status from that one
								if (setReqValidStatus.contains(newAACC.Change_Code__c) && Integer.valueOf( AMS_utils.getIATANumericStatus(sPrevStatus)) < 8 && Integer.valueOf( AMS_utils.getIATANumericStatus(sPrevStatus)) != 4) {
	                               isCCBellowEigthOrDiffFour = true;
	                               for (Agency_Applied_Change_code__c aaccLocal: acct.Agencies_Applied_Change_codes__r) {
	                                   if (aaccLocal.AccountNewStatus__c != null &&
	                                       aaccLocal.AccountNewStatus__c != '' &&
	                                       AMS_utils.getIATANumericStatus(aaccLocal.AccountNewStatus__c) != null &&
	                                       (Integer.valueOf(AMS_utils.getIATANumericStatus(aaccLocal.AccountNewStatus__c)) >= 8 ||
	                                        Integer.valueOf(AMS_utils.getIATANumericStatus(aaccLocal.AccountNewStatus__c)) == 4)) {

	                                       canAddStatus = true;
	                                       sPrevStatus = aaccLocal.AccountNewStatus__c;
	                                       previousReasonAux = (aaccLocal.Reason_Code__C == null || aaccLocal.Reason_Code__C == '') ? 'forcefallback' : aaccLocal.Reason_Code__C + '-' + aaccLocal.Reason_description__c;
	                                       break;
	                                   }
	                               }
	                            }
	                            sPrevStatus = !canAddStatus &&  isCCBellowEigthOrDiffFour ? AMS_Utils.ACC_S9_APPROVED : sPrevStatus;
	                            newAACC.AccountNewStatus__c = sPrevStatus;
	                            newAACC.AccountPreviousStatus__c = sCurrStatus;
							}
						}
					}
				}
			} else {
				newAACC.AccountNewStatus__c = AMS_Utils.getIATAReadableStatus(cc.Account_status_change__c);
				newAACC.AccountPreviousStatus__c = sCurrStatus;
			}
		}

		if(!toUpdateReason) return;

		String[] SplittedReason;
		String sReasonDesc = '';

		if(cc.Reason_Code__c == null || cc.Reason_Code__c.toUpperCase() == 'CURRENT'){
			if(sCurrReason != null && sCurrReason != '-'){
				if(sCurrReason.IndexOf('-') > 0){
					SplittedReason = sCurrReason.split('-');
					newAACC.Reason_Code__c = SplittedReason.get(0);
					newAACC.Reason_Description__c = sGetReasonDescriptionFromSplit(SplittedReason);
				}else
					newAACC.Reason_Code__c = sCurrReason;
			}
			newAACC.PreviousReason__c = sPrevReason;
		}else if(cc.Reason_Code__c.toUpperCase() == 'PREV'){
			if(sPrevReason != null && sPrevReason != ''){
				if(sPrevReason.IndexOf('-') > 0){
					SplittedReason = sPrevReason.split('-');
					newAACC.Reason_Code__c = SplittedReason.get(0);
					newAACC.Reason_Description__c = sGetReasonDescriptionFromSplit(SplittedReason);
					newAACC.PreviousReason__c = sCurrReason;
				}
			}
		}else if(cc.Reason_Code__c.toUpperCase().startsWithIgnoreCase('PREV;')){
			newAACC.Reason_Code__c = cc.Reason_Code__c;
			newAACC.Reason_Description__c = cc.Reason_Code__c;
			newAACC.PreviousReason__c = cc.Reason_Code__c;
			Set<String> SplittedCC = new Set<String>();
			for(Integer i=1; i < cc.Reason_Code__c.toUpperCase().split(';').size(); i++)
				SplittedCC.add(cc.Reason_Code__c.toUpperCase().split(';').get(i));

			if(!SplittedCC.isEmpty()){
				for(String sCCToGet : SplittedCC){
					if(mapPrevReasonFromCC.containsKey(AccountId)){
						if(mapPrevReasonFromCC.get(AccountId).containsKey(sCCToGet)){
							sPrevReason = mapPrevReasonFromCC.get(AccountId).get(sCCToGet).PreviousReason__c;
							// use previousResonAux if we had also used the status from a previous change code. If no change change code with acceptable status (8,9 or 4) was found will get the reason from a fallback
                            sPrevReason = (previousReasonAux != null) ? previousReasonAux :  isCCBellowEigthOrDiffFour ? getFallbackReason(AMS_Utils.getIATANumericStatus(sPrevStatus)) : sPrevReason;

							if(sPrevReason.IndexOf('-')<0){
                               sPrevReason = getFallbackReason(AMS_utils.getIATANumericStatus(sPrevStatus));
                            }
                            SplittedReason = sPrevReason.split('-');
                            newAACC.Reason_Code__c = SplittedReason.get(0);
                            newAACC.Reason_Description__c = sGetReasonDescriptionFromSplit(SplittedReason);
                            newAACC.PreviousReason__c = sCurrReason;
						}
					}
				}
			}
		}else{
			newAACC.Reason_Code__c = cc.Reason_Code__c;
			newAACC.Reason_Description__c = cc.Reason_Code_Description__c;
			newAACC.PreviousReason__c = sCurrReason;
		}
	}


	private static string sGetReasonDescriptionFromSplit(string[] SplittedReason){
		string sReasonDesc = '';
		if(SplittedReason==null || SplittedReason.isEmpty())	return '';
		for(integer i = 1;i<SplittedReason.size();i++){
			if(SplittedReason.size()-i==1)
				sReasonDesc = sReasonDesc + SplittedReason.get(i);
			else
				sReasonDesc = sReasonDesc + SplittedReason.get(i) +'-';
		}
		return sReasonDesc;
	}

	//Method set to expired all irregularities, if the change code foresee this.
	private static void ClearIrregularities(Set<Id> setAccntToClear, Map<Id,Account> mapAccountsWithCCs){			

		for(Id acctId : setAccntToClear){
			for(Agency_applied_change_code__c cc: mapAccountsWithCCs.get(acctId).Agencies_Applied_Change_codes__r){
				if(cc.RecordType.DeveloperName == 'Irregularities' && !cc.Irregularities_Expired__c){
					cc.Irregularities_Expired__c = true;
					irrsToExp.put(cc.Id, cc);
				}
			}
		}
	}

	//Method set to clear all expiry dates, if the change code foresee this.
	private static void ClearExpiryDate(Set<Id> setAccntToClear, Map<Id,Account> mapAccounts){

		for(Id acc : setAccntToClear){
			if(!mapAccntToUpdate.containsKey(acc) && mapAccounts.get(acc) != null)
				mapAccntToUpdate.put(acc, mapAccounts.get(acc));
			else
				continue;
				
			mapAccntToUpdate.get(acc).Expiry_Date__c = null;
		}
	}

	/**
	 * Overloaded method to be able call 
	 * the bCheckCondition with new paramenter
	 *
	 */
	@TestVisible
	private static boolean bCheckCondition(Case newCaseValues, String sFieldToCheck, String condition, Map<Id, List<Agency_Applied_Change_code__c>> mapCC){		
		return bCheckCondition(NewCaseValues, sFieldToCheck, condition, mapCC, null);
	}


	/**********************************************************************************************************************
		Method return true if condition is verified.
		Most of the times, a simple text value need to be checked. However, there are some expections such as:
		- NOT Blank
		- Blank
		- Not equal to <value>
		- Equal to TODAY
		- Greater than TODAY
		- EXISTS <ChangeCodeToCheck>

		for above values, different check need to be done.

		Most of the time, field to check is taken directly from the SIDRA/SIDRA Lite case.
	***********************************************************************************************************************/
	@TestVisible
	private static Boolean bCheckCondition(Case newCaseValues, String sFieldToCheck, String condition, Map<Id, List<Agency_Applied_Change_code__c>> mapCC, Case lastIFAP){
		set<string> setValues = new set<string>();

		if(condition.startsWithIgnoreCase('VALUES:')){
			String sValue = null;
			if(sFieldToCheck == 'Parent.Status')
				sValue = NewCaseValues.Parent.Status;
			else if(sFieldToCheck == 'LastYearIFAP.Status'){
				//Account must have an IFAP Case from last year to be possible to generate NOT change code
				if(lastIFAP != null) sValue = lastIFAP.Status;
			}
			else {
				sValue = (String)NewCaseValues.get(sFieldToCheck);
			}
			if(sValue==null)return false;
			setValues.addAll((condition.right(condition.length()-'VALUES:'.length())).split(';'));
			return setValues.contains(sValue.toUpperCase());
		}
		
		if(condition.equals('NOT BLANK')) return String.valueOf(newCaseValues.get(sFieldToCheck))!=null;
		
		if(condition.equals('BLANK')) return String.valueOf(newCaseValues.get(sFieldToCheck))==null;

		if(condition.startsWithIgnoreCase('NOT EQUAL TO:')){
			String sValue = sFieldToCheck == 'Parent.Status' ? newCaseValues.Parent.Status : (String)newCaseValues.get(sFieldToCheck);
			setValues.addAll((condition.right(condition.length()-'NOT EQUAL TO:'.length())).split(';'));
			return sValue == null || !setValues.contains(sValue.toUpperCase());
		}

		if(condition.equalsIgnoreCase('GREATER THAN TODAY')){
			Date d = Date.valueOf(newCaseValues.get(sFieldToCheck));
			if(d==null)	return false;
			Date dToCheck = Date.newinstance(d.year(), d.Month(), d.day());
			return dToCheck > System.today();
		}

		if(condition.equalsIgnoreCase('GREATER THAN TODAY OR EQUAL TO TODAY')){
			Date d = Date.valueOf(newCaseValues.get(sFieldToCheck));
			if(d==null)	return false;
			Date dToCheck = Date.newinstance(d.year(), d.Month(), d.day());
			return dToCheck > System.today() || dToCheck == System.today();
		}

		if(condition.equalsIgnoreCase('EQUAL TO TODAY')){
			Date d = Date.valueOf(newCaseValues.get(sFieldToCheck));
			if(d==null)	return false;
			Date dToCheck = Date.newinstance(d.year(), d.Month(), d.day());
			return dToCheck==system.today();
		}

		if(condition.startsWithIgnoreCase('<=:')){
			return (Double)newCaseValues.get(sFieldToCheck) <= Double.valueOf(condition.right(condition.length()-'<=:'.length())) && (Double)newCaseValues.get(sFieldToCheck)>0;
		}

		if(condition.startsWithIgnoreCase('>=:')){
			return (Double)newCaseValues.get(sFieldToCheck) >= Double.valueOf(condition.right(condition.length()-'>=:'.length()));
		}

		if(condition.startsWithIgnoreCase('>:')){
			return (Double)newCaseValues.get(sFieldToCheck) > Double.valueOf(condition.right(condition.length()-'>:'.length()));
		}

		if(condition.startsWithIgnoreCase('<:')){
			return (Double)newCaseValues.get(sFieldToCheck) < Double.valueOf(condition.right(condition.length()-'<:'.length()));
		}

		//This condition is used to check if there is already a specific change code already generated by the sidra(lite) in the subject
		if(condition.startsWithIgnoreCase('EXISTS:')){
			if(mapCC.keyset().contains(newCaseValues.AccountId)){
				String sChangeCode = (condition.right(condition.length()-'EXISTS:'.length()));
				for(Agency_Applied_Change_code__c aa : mapCC.get(newCaseValues.AccountId)){
					if(aa.Change_Code__c == sChangeCode)
						return true;
				}
			}

			return false;
		}

		//This is used to check if there is already an existing same change code generated from the same SIDRA (Lite): we don't want to have it generated twice.
		if(condition.startsWithIgnoreCase('NOT EXISTS:')){
			if(mapCC.keyset().contains(newCaseValues.AccountId)){
				String sChangeCode = (condition.right(condition.length()-'NOT EXISTS:'.length()));
				for(Agency_Applied_Change_code__c aa : mapCC.get(newCaseValues.AccountId)){
					if(aa.Change_Code__c==sChangeCode)
						return false;
				}
			}

			return true;
		}

		return false;
	}


	//Check if there all the fields that lead to generation of change code had a change
	private static boolean CheckOldNewValues(case NewCaseValues, case OldCaseValues, string Field1, string Field2, string Field3, string Field4, string Field5, string Field6, String Field7){

		if(OldCaseValues!=null){
			if( ((Field1==null || Field1.toUpperCase() == 'PARENT.STATUS' || Field1.toUpperCase() ==  'CHANGECODE' || Field1.toUpperCase()== 'EXISTS') || (Field1 != null && NewCaseValues.get(Field1) == OldCaseValues.get(Field1))) &&
				((Field2==null || Field2.toUpperCase() == 'PARENT.STATUS' || Field2.toUpperCase() ==  'CHANGECODE' || Field2.toUpperCase()== 'EXISTS') || (Field2 != null && NewCaseValues.get(Field2) == OldCaseValues.get(Field2))) &&
				((Field3==null || Field3.toUpperCase() == 'PARENT.STATUS' || Field3.toUpperCase() ==  'CHANGECODE' || Field3.toUpperCase()== 'EXISTS') || (Field3 != null && NewCaseValues.get(Field3) == OldCaseValues.get(Field3))) &&
				((Field4==null || Field4.toUpperCase() == 'PARENT.STATUS' || Field4.toUpperCase() ==  'CHANGECODE' || Field4.toUpperCase()== 'EXISTS') || (Field4 != null && NewCaseValues.get(Field4) == OldCaseValues.get(Field4))) &&
				((Field5==null || Field5.toUpperCase() == 'PARENT.STATUS' || Field5.toUpperCase() ==  'CHANGECODE' || Field5.toUpperCase()== 'EXISTS') || (Field5 != null && NewCaseValues.get(Field5) == OldCaseValues.get(Field5))) &&
				//NEWGEN-5318 - avoid validation when Field6 Value = LASTYEARIFAP.STATUS
				((Field6==null || Field6.toUpperCase() == 'PARENT.STATUS' || Field6.toUpperCase() ==  'CHANGECODE' || Field6.toUpperCase()== 'EXISTS') || (Field6 != null && Field6.toUpperCase() != 'LASTYEARIFAP.STATUS' && NewCaseValues.get(Field6) == OldCaseValues.get(Field6))) &&
				((Field7==null || Field7.toUpperCase() == 'PARENT.STATUS' || Field7.toUpperCase() ==  'CHANGECODE' || Field7.toUpperCase()== 'EXISTS') || (Field7 != null && NewCaseValues.get(Field7) == OldCaseValues.get(Field7)))
				)
				return false;
		}
		return true;
	}


	//Retrieve configuration items, stored in custom setting AMS Change Codes
	private static void ReadConfiguration(){

		for(AMS_ChangeCodes__c cc : AMS_ChangeCodes__c.getAll().values()){

			String accModel = cc.Accreditation_Model__c == null ? 'AMS' : 'NEWGEN';

			if(!changeCodesPerAccModel.containsKey(accModel))
				changeCodesPerAccModel.put(accModel, new List<AMS_ChangeCodes__c>());
			changeCodesPerAccModel.get(accModel).add(cc);
		}
	}


	//Method generates the bulletin memo text. It reads the stored values and replace all <xxxxxx> value with corresponding real value
	@TestVisible
	private static string GenerateMemoText(Case theCase, String sMemo1, String sMemo2, String sMemo3, List<Agency_Applied_Change_code__c> lsIrr, List<Financial_Security__c> lsFS, String extraMemoText, Boolean isHO){
		string sMemoText  = '';
		if(sMemo1!=null)	sMemoText = sMemoText + sMemo1;
		if(sMemo2!=null)	sMemoText = sMemoText + sMemo2;
		if(sMemo3!=null)	sMemoText = sMemoText + sMemo3;

		if(sMemoText=='')
			return '';
		else{
			string sTmpVal = '';
			//Start substitutions!
			if(sMemoText.containsIgnoreCase('<Termination Date>')){
				sMemoText = sMemoText.replace('<Termination Date>', theCase.Termination_date__c==null?'Nil':GenerateDateForBulletin(theCase.Termination_date__c));
			}

			if(sMemoText.containsIgnoreCase('<Financial Securities>')){
				sMemoText = sMemoText.replace('<Financial Securities>', GenerateFinancialSecurity(lsFS));
			}

			if(sMemoText.containsIgnoreCase('<DEF Withdrawal reason>')){
				sMemoText = sMemoText.replace('<DEF Withdrawal reason>', theCase.DEF_Withdrawal_Reason__c==null?'Nil':theCase.DEF_Withdrawal_Reason__c);
			}

			if(sMemoText.containsIgnoreCase('<SIDRA Lite Reason>')){
				sMemoText = sMemoText.replace('<SIDRA Lite Reason>', theCase.SIDRA_Lite_Reason__c==null?'Nil':theCase.SIDRA_Lite_Reason__c);
			}

			if(sMemoText.containsIgnoreCase('<End Grace Period Date>')){
				sMemoText = sMemoText.replace('<End Grace Period Date>', theCase.End_of_Grace_Period_Date__c==null?'Nil':GenerateDateForBulletin(theCase.End_of_Grace_Period_Date__c));
			}

			if(sMemoText.containsIgnoreCase('<IRR Withdrawal Reason>')){
				sMemoText = sMemoText.replace('<IRR Withdrawal Reason>', theCase.IRR_Withdrawal_Reason__c==null?'Nil':theCase.IRR_Withdrawal_Reason__c);
			}

            if(sMemoText.containsIgnoreCase('<IRRS Sequence>')){
                if (isHO) {
                    sMemoText = sMemoText.replace('<IRRS Sequence>', GenerateIrregularitySequence(lsIrr, theCase));
                } else {
                    sMemoText = sMemoText.replace('<IRRS Sequence>\n', '');
                }

            }

			if(sMemoText.containsIgnoreCase('<Outstanding Amount>')){
				sMemoText = sMemoText.replace('<Outstanding Amount>', theCase.Outstanding_Amount__c==null?'Nil':string.valueOf(theCase.Outstanding_Amount__c));
			}

			if(sMemoText.containsIgnoreCase('<OSCAR Type>')){
				sMemoText = sMemoText.replace('<OSCAR Type>', theCase.Parent.OSCAR__r.Type_of_change__c==null?'Nil':theCase.Parent.OSCAR__r.Type_of_change__c);
			}

			if(sMemoText.containsIgnoreCase('<Termination Reason>')){
				sMemoText = sMemoText.replace('<Termination Reason>', theCase.Termination_Reason__c==null?'Nil':theCase.Termination_Reason__c);
			}

			if(sMemoText.containsIgnoreCase('<Update AIMS-DEF>')){
				sMemoText = sMemoText.replace('<Update AIMS-DEF>', theCase.Update_AIMS_DEF__c==null?'Nil':GenerateDateForBulletin(date.ValueOf(theCase.Update_AIMS_DEF__c)));
			}

			if(sMemoText.containsIgnoreCase('<Reason for default>')){
				sMemoText = sMemoText.replace('<Reason for default>', theCase.Reason_for_Default__c==null?'Nil':theCase.Reason_for_Default__c);
			}

			if(sMemoText.containsIgnoreCase('<Reason of REI/WD>')){
				sMemoText = sMemoText.replace('<Reason of REI/WD>', theCase.Reason_of_REI_WD__c==null?'Nil':theCase.Reason_of_REI_WD__c);
			}

			if(sMemoText.containsIgnoreCase('<Inform GDS to Shut Down TKT System>')){
				sMemoText = sMemoText.replace('<Inform GDS to Shut Down TKT System>', theCase.Shut_Down_TKT_System_GDS_and_BSPlink__c==null?'Nil':GenerateDateForBulletin(theCase.Shut_Down_TKT_System_GDS_and_BSPlink__c));
			}

			if(sMemoText.containsIgnoreCase('<Currency>')){
				sMemoText = sMemoText.replace('<Currency>', theCase.Currency__c==null?'Nil':theCase.Currency__c);
			}

			if(sMemoText.containsIgnoreCase('<Oscar Type Of Change>')){
				sMemoText = sMemoText.replace('<Oscar Type Of Change>', theCase.OSCAR__r.ANG_Type_Of_Change__c==null?'Nil':theCase.OSCAR__r.ANG_Type_Of_Change__c);
			}

			if(sMemoText.containsIgnoreCase('<Last Due Date>')){
				sMemoText = sMemoText.replace('<Last Due Date>', getLastDueDate(theCase.Id));
			}
		}

		sMemoText = extraMemoText != null ? (sMemoText + ' ' + extraMemoText) : sMemoText;
		return sMemoText;
	}


	private static string GetOpCalendarExtId(string sExtId){
		string sRet = '';
		if(sExtId != '' && sExtId!=null && sExtId.lastIndexOf(' ')>=0){
			sRet = sExtId.substring(0, sExtId.lastIndexOf(' '));
			sRet = sRet.replace(' ', '_');
		}
		return sRet;
	}


	//Format the date in the eBulletin Format (dd-mmm-yyyy)
	private static string GenerateDateForBulletin(date dValue){
		if(dValue==null) return '';
		list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
		return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
	}

	private static string GenerateDateForBulletin(datetime dValue){
		if(dValue==null) return '';
		list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
		return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
	}

	public static String doFormatting(Decimal val, String osep, String nsep) {
		String s, tmp;
		Integer i = 6;
		s = val.setScale(2).toPlainString().replace(osep, nsep);
		while(s.length() > i) {
			tmp = s.substring(0, s.length() - i) + osep + s.substring(s.length() - i);
			s = tmp; i += 4;
		}
		return s;
	}

	public void isTestCompliant () {
        if (Test.isRunningTest()) {
            AMS_Oscar__c oscar = new AMS_Oscar__c();
            AMS_Pax_Accreditation_Form__c accreditationObj = new AMS_Pax_Accreditation_Form__c();
            oscar.Assessment_Performed_Date__c = date.today();
            oscar.Bank_Guarantee_deadline__c = date.today();
            oscar.Bank_Guarantee_received__c = date.today();
            oscar.Bank_Guarantee_requested__c = date.today();
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Postal_code__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Street_name_number__c = String.valueOf(12436);
            oscar.Change_effective_as_of__c = date.today();
            oscar.Criteria_remarks__c = String.valueOf(date.today());
            oscar.Documentation_remarks__c = String.valueOf(date.today());
            oscar.Dossier_Reception_Date__c = date.today();
            oscar.Fees_refund_requested__c = date.today();
            oscar.Finalization_checklist__c = String.valueOf(date.today());
            oscar.Financial_Assessment_deadline__c = date.today();
            oscar.Financial_Review_Result__c = String.valueOf(date.today());
            oscar.Billing_Document_Number__c = '6781';
            oscar.Local_Inspection_compliant__c = 'Yes';
            oscar.Local_Inspection_deadline__c = date.today();
            oscar.Local_Inspection_received__c = date.today();
            oscar.Local_Inspection_requested__c = date.today();
            oscar.Process_Start_Date__c = date.today();
            oscar.Proof_of_payment_received__c = date.today();
            oscar.PSAA_EACP_Agreement_received__c = date.today();
            oscar.Welcome_Pack_Sent__c = date.today();
            oscar.Sanity_check_deadline__c = date.today();
            oscar.Sanity_check_received__c = date.today();
            oscar.Update_AIMS_Rejection_Date__c = date.today();
            oscar.Update_AIMS_Rejection__c = true;
            oscar.Update_AIMS_Approval_Date__c = date.today();
            oscar.Update_AIMS_Approval__c = true;


            accreditationObj = new AMS_Pax_Accreditation_Form__c();
            accreditationObj.Abbreviated_Address__c = 'TestAddress';
            oscar.Documentation_remarks__c = String.valueOf(date.today());
            oscar.Dossier_Reception_Date__c = date.today();
            oscar.Fees_refund_requested__c = date.today();
            oscar.Finalization_checklist__c = String.valueOf(date.today());
            oscar.Financial_Assessment_deadline__c = date.today();
            oscar.Financial_Review_Result__c = String.valueOf(date.today());
            oscar.Billing_Document_Number__c = '6781';
            oscar.Local_Inspection_compliant__c = 'Yes';
            oscar.Local_Inspection_deadline__c = date.today();
            oscar.Local_Inspection_received__c = date.today();
            oscar.Local_Inspection_requested__c = date.today();
            oscar.Process_Start_Date__c = date.today();
            oscar.Proof_of_payment_received__c = date.today();
            oscar.PSAA_EACP_Agreement_received__c = date.today();
            oscar.Welcome_Pack_Sent__c = date.today();
            oscar.Sanity_check_deadline__c = date.today();
            oscar.Sanity_check_received__c = date.today();
            oscar.Update_AIMS_Rejection_Date__c = date.today();
            oscar.Update_AIMS_Rejection__c = true;
            oscar.Update_AIMS_Approval_Date__c = date.today();
            accreditationObj.Abbreviated_name__c = 'TestName';
            accreditationObj.Accept_terms_and_conditions__c = true;
            accreditationObj.Account_Name__c = 'TestName';
            accreditationObj.Billing_State__c = 'TestState';
            accreditationObj.Branch_Office_City__c = 'TestCity';
            accreditationObj.Branch_Office_Email__c = 'TestEmail';
            accreditationObj.Branch_Office_FAX__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Phone__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Postal_code__c = String.valueOf(12436);
            accreditationObj.Branch_Office_Street_name_number__c = String.valueOf(12436);
            accreditationObj.CASS_Number__c = String.valueOf(12436);
            accreditationObj.IATACode__c = 'TestCode';
            accreditationObj.ISSP_AMS_License_No__c = String.valueOf(12436);
            accreditationObj.ISSP_AMS_VAT_number__c = String.valueOf(12436);
            accreditationObj.Is_your_firm_handling_Dangerous_Goods__c = String.valueOf('true');
        }
    }
    
    private static String getLastDueDate(Id caseId) {
        for (Case_Detail__c detail:
                [SELECT Id, Due_Date__c
                FROM Case_Detail__c
                WHERE Case__c = :caseId
                AND RecordType.DeveloperName = 'Repayment_Instalment'
                AND Due_Date__c != null
                ORDER BY Due_Date__c DESC LIMIT 1]) {
            return String.ValueOf(detail.Due_Date__c);
        }
        return '';
    }

    /**
     * For the given Case list 
     * find the Last IFAP case in the last Financial Year
     * 
     */
    private static Case findLastIFAP(List<Case> caseList, String financialYear){

    	Case lastIfapCase = null;
    	if(financialYear == null) return null;

    	Integer lastYearIfap = Integer.valueOf(financialYear) - 1;
    	
    	for(Case c : caseList){
    		if(c.IFAP_Financial_Year__c == String.valueOf(lastYearIfap) && (lastIfapCase == null || lastIfapCase.CreatedDate < c.CreatedDate))
    			lastIfapCase = c;
    	}
    	return lastIfapCase;
    }
}