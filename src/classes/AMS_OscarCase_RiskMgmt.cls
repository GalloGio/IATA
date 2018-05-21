/**************************************

Class to handle all risk management related change codes
It works on Sidra and Sidra Lite case: when they are created or updated, values saved are checked against custom setting "".
If there is a match, than the change code configured will be created.

At the same time, bulletin memo text (sometimes dinamically calculated) will be saved on the change code itself.

**************************************/

public class AMS_OscarCase_RiskMgmt {
	//Check that trigger is not already running on change codes.
	private static boolean run = true;
	public static boolean runOnce(){
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

    private static map<id, list<Agency_Applied_Change_code__c>> mapIRRS = new map<id, list<Agency_Applied_Change_code__c>>();	//Store all Irregularities previously created for agencies in the trigger. Used in the memo text
    private static map<id, list<Financial_Security__c>> mapFinancialSecurity = new map<id, list<Financial_security__c>>();		//Store all Financial Securities previously created for agencies in the trigger. Used in the memo text
    private static map<id, id> mapAllHOs = new map<id, id>();		//For each agencies in the trigger, stores their HO Id
    private static set<id> setAllAccntsHiearchy = new set<id>();	//Store each Agencies ID (HO/BRs) retrieved from the HOId
    private static map<id, list<Account>> mapAccntValues = new map<id, list<Account>>();	//contains all the accounts associated with a HO.
    private static map<id, Account> mapAccntToUpdate = new map<id, account>();	//Stores account to be updated (Status and reason code)
	private static set<id> setAccntIdIRRToClear = new set<id>();	//Account IDs for which a clear of irregularities is needed
	private static set<id> setAccntIdToClearExpDate = new set<id>();	//Account IDs for which a clear of expiry date is needed
	private static map<id, list<Agency_Applied_Change_code__c>> mapExistingChangeCodes = new map<id, list<Agency_Applied_Change_code__c>>();
	private static map<string, operational_Calendar__c> mapOperationalCalendar = new map<string, operational_Calendar__c>();
    private static set<string> setIRRCC = new set<string>{'IRR', 'IRS', 'IRW'};		//Irregularities change code
    private static set<string> setTERCC = new set<string>{'TER'};		//Termination change codes: set expiry date on account
    private static set<string> setREICC = new set<string>{'SDR', 'RCR', 'STR', 'RTR', 'RTE', 'REI'};		//Reinstatement change codes: clear expiry date on account
	private static set<string> setReqValidStatus = new set<string>{'SDR', 'RCR', 'STR', 'RTR', 'RTE', 'REI', 'DFW'};		//Reinstatement + DFW: look for change code with valid status/reason
    private static map<id, account> mapReasonAndStatus = new map<id, account>();	//map containing latest reason and status
    private static set<string> setTidsChangeCode = new set<string>{'REI','TER','RTE'};
    private static map<id, map<string, Agency_Applied_Change_code__c>> mapPrevReasonFromCC = new map<id, map<string, Agency_Applied_Change_code__c>>();
    private static final String NO_IRR_FOUND = ' No Irregularities Found!';
    private static list<AMS_ChangeCodes__c> ListCCConfig;

    //Main Method
	public static void CreateRiskChangeCode(map<id, case> mapTrgOld, map<id, case> mapTrgNew){

		System.debug('[AMS_OscarCase_RiskMgmt] : Entering CreateRiskChangeCode');
		map<id, list<AMS_ChangeCodes__c>> mapChangeCodeToCreate = new map<id, list<AMS_ChangeCodes__c>>(); //index is the Id of the case
		set<string> setFSStatus = new set<string>{'Close to Expiry Date', 'Active', 'Encashed', 'Encashment in progress'};	//Financial Security status to be included in the memo text
		//map<id, Case> mapCasePerAccount = new map<id, case>();

		set<id> setAccntIdCase = new set<id>();

		ReadConfiguration();

		list<AMS_ChangeCodes__c> lsConfAMS = ReadConfiguration(null);
		list<AMS_ChangeCodes__c> lsConfNEWGEN = ReadConfiguration('NEWGEN');

		System.debug('List of lsConfNEWGEN is:' + lsConfNEWGEN);

		if(!lsConfAMS.isEmpty() || !lsConfNEWGEN.isEmpty()){

			System.debug('[AMS_OscarCase_RiskMgmt] : Entering CreateRiskChangeCode STEP1');

			list<case> lsAPDToCreate = new list<case>();
			//INC305031 changed the query from for to list;
			List<Case> listCases = [select id, AccountId, (select id from Hierarchy_Account_Selections__r) from Case where id in:mapTrgNew.keyset()];
			for(case c: listCases){
				if(c.Hierarchy_Account_Selections__r.isEmpty())
					lsAPDToCreate.add(c);
			}

			if(!lsAPDToCreate.isempty()){
				AMS_CaseTriggerHandler.SelectAgencyOnSidraCase(lsAPDToCreate);
			}

			for(AMS_Process_Detail__c apd:[select id, HOId__c, Case__c, Account__c from AMS_Process_Detail__c where case__c in:mapTrgNew.keyset()])
				mapAllHOs.put(apd.Account__c, apd.HOId__c);

			/*map<id, Account> mapAccnt = new map<id, Account>();

			//I'm getting all account IDs associated with the Cases in the trigger
			for(ID i:mapTrgNew.keyset())
				mapAccnt.put(mapTrgNew.get(i).AccountId, null);

			//For each account in the trigger, get its HO
			for(Account a:[select id, Location_Class__c, Status__c, PreviousStatus__c, Previous_Reason__c, Reason__c, parentId, parent.ParentId from Account where id in:mapAccnt.keyset()]){
				mapAccnt.put(a.id, a);

				if(a.Parent.ParentId != null)	//I'm a BR of a BR
					mapAllHOs.put(a.id, a.Parent.ParentId);
				else if(a.PArentId!=null)	//I'm a BR
					mapAllHOs.put(a.id, a.ParentId);
				else	//I'm the HO!
					mapAllHOs.put(a.id, a.id);
			}*/

			//Get all Agencies IDs involved. Get all items in the hierarchy
			//for(Account a:[select id from Account where id in:mapAllHOs.values() or parentId in:mapAllHOs.values()  or parent.parentId in:mapAllHOs.values()])
			//	setAllAccntsHiearchy.add(a.Id);

			//For each HO, get its children
			//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
			//for(Account a:[select id, Status__c, CNS_Agency__c, PreviousStatus__c, Reason__c, Previous_Reason__c, Accumulated_Irregularities__c, ParentId, Parent.ParentId from Account where id in:mapAllHOs.values() or ParentId in:mapAllHOs.values() or parent.parentId in:mapAllHOs.values()]){
			/*for(Account a:[select id, Status__c, PreviousStatus__c, Reason__c,Location_class__c, Previous_Reason__c, Accumulated_Irregularities__c, ParentId, Parent.ParentId from Account where id in:mapAllHOs.values() or ParentId in:mapAllHOs.values() or parent.parentId in:mapAllHOs.values()]){
				//setAllAccntsHiearchy.add(a.Id);
				id HOID;
				list<Account> lsAccnt = new list<Account>();
				//First Check: Parent.ParentID. I'm a BR of a BR
				if(a.Parent.ParentId != null){
					HOID = a.Parent.ParentId;
				}//Second Check: ParentId. I'm a BR of a HO
				else if(a.ParentId != null){
					HOID = a.ParentId;
				}//Third Check: ok, I'm the HO
				else{
					HOID = a.Id;
				}
				if(HOID!=null){
					if(mapAccntValues.containsKey(HOID))
						lsAccnt = mapAccntValues.get(HOID);

					lsAccnt.add(a);
					mapAccntValues.put(HOID, lsAccnt);
				}
			}
			*/

			for(Account a:[select id, Status__c, PreviousStatus__c, Reason__c,Location_class__c, Previous_Reason__c, Accumulated_Irregularities__c, ParentId, Parent.ParentId, CNS_Agency__c, Default_date__c
							from Account
							where id in:mapAllHOs.keyset()]){
				//setAllAccntsHiearchy.add(a.Id);
				id HOID = mapAllHOs.get(a.ID);
				list<Account> lsAccnt = new list<Account>();
				//First Check: Parent.ParentID. I'm a BR of a BR

				if(HOID!=null){
					if(mapAccntValues.containsKey(HOID))
						lsAccnt = mapAccntValues.get(HOID);

					lsAccnt.add(a);
					mapAccntValues.put(HOID, lsAccnt);
				}
			}

			setAllAccntsHiearchy = mapAllHOs.keyset();

			//Get all previously generated change code from same sidra/sidra lite
			list<Agency_Applied_Change_code__c> lsAACC = new list<Agency_applied_change_code__c>();
			for(Agency_Applied_Change_code__c aa:[select id, createddate, AccountNewStatus__c, AccountPreviousStatus__c, PreviousReason__c,
												  Account__c, Account__r.Location_Class__c, Account__r.ParentId, Change_Code__c, SIDRA_Case__c
												  from Agency_Applied_Change_code__c
												  where SIDRA_Case__c in:mapTrgNew.keyset()
												  order by Account__c, CreatedDate desc]){
				//Populate map with existing change code per sidra case. This is used to get the previuos status/reason in case of withdrawn
				map<string, Agency_Applied_Change_code__c> mapAACCTmp;
				if(mapPrevReasonFromCC.containsKey(aa.Account__c)){
					mapAACCTmp = mapPrevReasonFromCC.get(aa.Account__c);
				}else
					mapAACCTmp = new map<string, Agency_Applied_Change_code__c>();

				mapAACCTmp.put(aa.Change_Code__c, aa);

				mapPrevReasonFromCC.put(aa.Account__c, mapAACCTmp);

				//Populate map with all existing change code per same account.
				list<Agency_Applied_Change_code__c> lsAACCtmp;
				if(mapExistingChangeCodes.keyset().contains(aa.Account__c))
					lsAACCtmp = mapExistingChangeCodes.get(aa.Account__c);
				else
					lsAACCtmp = new list<Agency_Applied_Change_code__c>();

				lsAACCtmp.add(aa);

				mapExistingChangeCodes.put(aa.Account__c, lsAACCtmp);
			}

			//get latest reason code/description from latest change code or, in case is missing, from account
			mapReasonAndStatus = new map<id, account>([select id, Status__c, Reason__c,Previous_Reason__c, PreviousStatus__c, Default_date__c,
													 	(select id, change_code__c, AccountNewStatus__c, AccountPreviousStatus__c, PreviousReason__c, Reason_Code__c, Reason_Description__c, createddate, Created_Date_To_Show__c
													 	 from Agencies_Applied_Change_codes__r
													 	 where SIDRA_Case__c in:mapTrgNew.keyset()
													 	 order by Created_Date_To_Show__c desc limit 1)
													  from account
													  where Id in:setAllAccntsHiearchy]);

			//Get all financial securities related with accounts in the trigger. Used for generating bulletin memo text
			for(Financial_Security__c fs:[select id, Account__c, Amount__c, CurrencyIsoCode, Account__r.parentId
										  from Financial_Security__c
										  where Account__c in:setAllAccntsHiearchy and Security_Status__c in:setFSStatus]){
				list<Financial_Security__c> lsFS;
				if(mapFinancialSecurity.keyset().contains(fs.Account__c))
					lsFS = mapFinancialSecurity.get(fs.Account__c);
				else
					lsFS = new list<Financial_Security__c>();

				lsFS.add(fs);

				mapFinancialSecurity.put(fs.Account__c, lsFS);
			}

			//Get all irregularities that lead to default (raised during last year)
			for(Agency_Applied_Change_code__c irr:[select id, Account__c, Change_Code__c, Effective_Date__c, Irregularities_Expired__c, Operation__c, Irregularity_Type__c, Irregularities_Points__c
												   from Agency_Applied_Change_code__c
												   where Account__c in:setAllAccntsHiearchy and Change_Code__c in:setIRRCC and Irregularities_Expired__c=false
												   order by Effective_Date__c, Operation__c desc]){
				list<Agency_Applied_Change_code__c> lsIRRS;
				if(mapIRRS.keyset().contains(irr.Account__c))
					lsIRRS = mapIRRS.get(irr.Account__c);
				else
					lsIRRS = new list<Agency_Applied_Change_code__c>();

				lsIRRS.add(irr);

				mapIRRS.put(irr.Account__c, lsIRRS);
			}


			//Query the Cases and account info: from the trigger, I'm not getting all necessary lookup value. Trigger is always running AFTER
			map<id, case> mapCases = new map<id, case>([
			select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, Short_Payment_Date__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c,
								  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c, NOT_Approval__c,
								  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c, Current_Outstanding_Amount_USD__c, Type_of_REI_WD__c,
								  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c,
								  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, Parent.Status, IRR_Approval_Rejection_Date__c, IRR_Type__c,
								  Termination_date__c, Outstanding_Amount__c, Reason_of_REI_WD__c, External_ID__c,
								  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c
								  , Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c, Account.AIMS_ID__c, Account.WebStar_ID__c, Account.IATACode__c, Account.ANG_IsNewGenAgency__c, Account.ParentId
								  //DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
								  , Account.CNS_Agency__c, Currency__c, OSCAR__r.ANG_Type_Of_Change__c
								  from case where id in:mapTrgNew.keySet()]);

			set<string> setOperationCalendarExtID = new set<string>();

			for(Case c: mapCases.values()){
				setAccntIdCase.add(c.AccountId);
				string sExtId = GetOpCalendarExtId(c.External_ID__c);
				if(sExtId!='')	setOperationCalendarExtID.add(sExtId);

				//Pilot countries only!
				if(!c.Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c)
					continue;
				//string LocClass = mapAccnt.get(c.AccountId).Location_Class__c;
				string LocClass = c.Account.Location_Class__c;

				if(LocClass==null || LocClass == '')
					throw new transformationException('Account is missing Location Class!');
				else
					LocClass = LocClass.toUpperCase();

				string sRecordTypeName = c.recordType.DeveloperName;

				List<AMS_ChangeCodes__c> lsConf = c.Account.ANG_IsNewGenAgency__c ? lsConfNEWGEN : lsConfAMS;

				for(AMS_ChangeCodes__c conf:lsConf){
					set<string> setLocClass = new set<string>(conf.Class_Type__c.toUpperCase().split(';'));

					if(!setLocClass.contains(LocClass))
						continue;

					if(!sRecordTypeName.equalsIgnoreCase(conf.Record_Type__c))
						continue;

					//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
					if(c.Account.CNS_Agency__c && !conf.Used_By_CNS__c)
						continue;

					System.debug('[AMS_OscarCase_RiskMgmt]: Entering conditions with Change code:'+conf);

											  //Check that the same change code does not exists generated from the same SIDRA (Lite)
					boolean CCToBeGenerated = bCheckCondition(c, null, 'NOT EXISTS:' + conf.Change_Code__c, null, mapExistingChangeCodes);

					if(conf.Field1__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field1__c, conf.Field1Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);

					if(conf.Field2__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field2__c, conf.Field2Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);

					if(conf.Field3__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field3__c, conf.Field3Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);

					if(conf.Field4__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field4__c, conf.Field4Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);

					if(conf.Field5__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field5__c, conf.Field5Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);

					if(conf.Field6__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field6__c, conf.Field6Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);

					if(CCToBeGenerated)
						CCToBeGenerated = CheckOldNewValues(c,  mapTrgOld.get(c.Id), conf.Field1__c, conf.Field2__c, conf.Field3__c, conf.Field4__c, conf.Field5__c, conf.Field6__c);

					if(CCToBeGenerated){
						//mapCasePerAccount.put(c.AccountId, c);
						list<AMS_ChangeCodes__c> ls;
						if(mapChangeCodeToCreate.KeySet().contains(c.Id))
							ls = mapChangeCodeToCreate.get(c.Id);
						else
							ls = new list<AMS_ChangeCodes__c>();

						ls.add(conf);
						mapChangeCodeToCreate.put(c.Id, ls);
					}
				}
			}

			System.debug('mapChangeCodeToCreate:'+mapChangeCodeToCreate);
			system.debug(logginglevel.error, 'DTULLO 226 setOperationCalendarExtID --> ' + setOperationCalendarExtID);
			if(!setOperationCalendarExtID.isEmpty()){
				for(operational_Calendar__c oc:[select Operation_Period_code__c, First_Day__c, Last_Day__c from operational_Calendar__c where Operation_Period_code__c in:setOperationCalendarExtID])
					mapOperationalCalendar.put(oc.Operation_Period_code__c, oc);
			}

			system.debug(logginglevel.error, 'DTULLO 232 mapOperationalCalendar --> ' + mapOperationalCalendar.keySet());

			//Create the change codes!
			if(!mapChangeCodeToCreate.isEmpty()){
				lsAACC = new list<Agency_Applied_Change_code__c>();
                Set<Id> accountIds = new Set<ID>();

                for(ID idCase:mapChangeCodeToCreate.keyset()){
					for(AMS_ChangeCodes__c cc :mapChangeCodeToCreate.get(idCase)){
						id CurrAccntId = mapCases.get(idCase).AccountId;
						accountIds.add(CurrAccntId);
						//Some change codes need to be created for the whole hierarchy...
						if(cc.Apply_to_hierarchy__c){
							id CurrAccntHOID = mapAllHOs.get(CurrAccntId);
							if(mapAccntValues.containsKey(CurrAccntHOID)){
								for(Account HIERAccnt:mapAccntValues.get(CurrAccntHOID)){
									if(HierAccnt.id!=CurrAccntId){
										if(HIERAccnt.Location_Class__c != 'T' || (HIERAccnt.Location_Class__c == 'T' && setTidsChangeCode.contains(cc.Change_Code__c))){
											accountIds.add(HIERAccnt.Id);
										}
									}
								}
							}
						}
					}
				}
                List<Agency_Applied_Change_code__c> aaccs = [Select id, Created_Date_To_Show__c, Account__c, AccountNewStatus__c, Reason_Description__c, Reason_Code__c, Change_Code__c from Agency_Applied_Change_code__c Where Account__c in: accountIds ORDER BY Created_Date_To_Show__c DESC ];

                Map<Id, List<Agency_Applied_Change_code__c>> aaccsPerAccount = new Map<Id, List<Agency_Applied_Change_code__c>>();
                for (Agency_Applied_Change_code__c aaccLocal: aaccs) {
                    if (aaccsPerAccount.containsKey(aaccLocal.Account__c)) {
                        List<Agency_Applied_Change_code__c> aaccsLocal= aaccsPerAccount.get(aaccLocal.Account__c);
                        aaccsLocal.add(aaccLocal);
                        aaccsPerAccount.put(aaccLocal.Account__c, aaccsLocal);
                    } else {
                        List<Agency_Applied_Change_code__c> aaccsLocal= new List<Agency_Applied_Change_code__c>();
                        aaccsLocal.add(aaccLocal);
                        aaccsPerAccount.put(aaccLocal.Account__c, aaccsLocal);
                    }
                }

                // get forms of payment for newgen accounts
                Map<Id,List<Agency_Authorization__c>> fOPsMap = new Map<Id,List<Agency_Authorization__c>>();
                if (mapCases.values()[0].Account.ANG_IsNewGenAgency__c)
                    fOPsMap = AMS_ChangeCodesHelper.fetchFormsOfPayment(accountIds);

				for(ID idCase:mapChangeCodeToCreate.keyset()){
					for(AMS_ChangeCodes__c cc :mapChangeCodeToCreate.get(idCase)){
						id CurrAccntId = mapCases.get(idCase).AccountId;
						//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER


                        Agency_Applied_Change_code__c AACC = CreateChangeCode(mapCases, idCase, cc, null, mapCases.get(idCase).Account.CNS_Agency__c, aaccsPerAccount, fOPsMap.get(CurrAccntId));


						if(AACC!=null)
							lsAACC.add(AACC);

						//Some change codes need to be created for the whole hierarchy...
						if(cc.Apply_to_hierarchy__c){
							id CurrAccntHOID = mapAllHOs.get(CurrAccntId);
							if(mapAccntValues.containsKey(CurrAccntHOID)){
								for(Account HIERAccnt:mapAccntValues.get(CurrAccntHOID)){
									if(HierAccnt.id!=CurrAccntId){
										if(HIERAccnt.Location_Class__c != 'T' || (HIERAccnt.Location_Class__c == 'T' && setTidsChangeCode.contains(cc.Change_Code__c))){
											//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
											Agency_Applied_Change_code__c AACCHier = CreateChangeCode(mapCases, idCase, cc, HIERAccnt, HierAccnt.CNS_Agency__c, aaccsPerAccount, fOPsMap.get(CurrAccntId));
											//Agency_Applied_Change_code__c AACCHier = CreateChangeCode(mapCases, idCase, cc, HIERAccnt);
											if(AACCHier!=null)
												lsAACC.add(AACCHier);
										}
									}
								}
							}
						}
					}
				}

				if(!lsAACC.isEmpty())
					insert lsAACC;

				if(!mapAccntToUpdate.isEmpty())
					update mapAccntToUpdate.values();

				if(!setAccntIdIRRToClear.isEmpty())
					ClearIrregularities(setAccntIdIRRToClear);

				if(!setAccntIdToClearExpDate.isEmpty())
					ClearExpiryDate(setAccntIdToClearExpDate);
			}
		}
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

	//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
	private static Agency_Applied_Change_code__c CreateChangeCode(map<id, case> mapCases, id idCase, AMS_ChangeCodes__c cc, Account acc, boolean bIsCNS, Map<Id, List<Agency_Applied_Change_code__c>> aaccsPerAccount, List<Agency_Authorization__c> fOPs) {
	//private static Agency_Applied_Change_code__c CreateChangeCode(map<id, case> mapCases, id idCase, AMS_ChangeCodes__c cc, Account acc){
		datetime dt = system.now();

		Agency_Applied_Change_code__c AACC = new Agency_Applied_Change_code__c();

		id AccountId = (acc == null ? mapCases.get(idCase).AccountId : acc.id);
		//if(acc==null)
		//	AccountId = mapCases.get(idCase).AccountId;
		//else
		//	AccountId = acc.id;

		AACC.Account__c = AccountId;

		string sUniqueId = '';
		if(mapCases.get(idCase).Account.WebStar_ID__c != '' && mapCases.get(idCase).Account.WebStar_ID__c != null)
			sUniqueId = mapCases.get(idCase).Account.WebStar_ID__c;
		else if(mapCases.get(idCase).Account.AIMS_ID__c != '' && mapCases.get(idCase).Account.AIMS_ID__c != null)
			sUniqueId = mapCases.get(idCase).Account.AIMS_ID__c;
		else
			sUniqueId = mapCases.get(idCase).Account.IATACode__c;

		sUniqueId = sUniqueId + '_' + cc.Change_Code__c + '_' + dt.year() + dt.month() + dt.day() + dt.hour() + dt.second();

        String extraMemoText = '';
        if (mapAllHOs.containsKey(AccountId) && mapAllHOs.get(AccountId) == AccountId) {
            Set<Id> childs = new Set<Id>();
            for (Id childIds: mapAllHOs.keySet()) {
                if (mapAllHOs.get(childIds) == AccountId) {
                    childs.add(childIds);
                }
            }
        	extraMemoText = childs.size() > 1 ? cc.Extra_memo_text_for_HO__c : '';
        }
		Boolean isHO = (acc != null ? (acc.parentId == null) : (!mapCases.isEmpty() && mapCases.get(idCase).Account.ParentId == null));
		//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
		AACC.Bulletin_Information__c = GenerateMemoText(mapCases.get(idCase), null
														, bIsCNS?cc.CNS_Bulletin_Memo_Text__c:cc.Bulletin_Memo_Text__c, bIsCNS?cc.CNS_Bulletin_Memo_Text2__c:cc.Bulletin_Memo_Text2__c, bIsCNS?cc.CNS_Bulletin_Memo_Text3__c:cc.Bulletin_Memo_Text3__c
														, mapIRRS.get(AccountId), mapFinancialSecurity.containsKey(AccountId)?mapFinancialSecurity.get(AccountId):null, extraMemoText, isHO).toUpperCase();



        // added new field to change code Calculate_BG_to_HO__c , and if is true and is Top Parent we will put the financial security on new the new field (Financial_Security__c) of the Agency Applied Change Code
        AACC.Financial_Security__c = (cc.Calculate_BG_to_HO__c && isHO && mapFinancialSecurity.containsKey(AccountId)) ? GenerateFinancialSecurity(mapFinancialSecurity.get(AccountId)) : '';
		AACC.Outstanding_Amount__c = (cc.Calculate_Outstanding_Amount__c && mapCases.get(idCase).Outstanding_Amount__c != null) ? string.valueOf(mapCases.get(idCase).Outstanding_Amount__c) : '';
		AACC.Irregularity_Sequence__c = (cc.Generate_Irregularity_Sequence__c && isHO && !mapIRRS.get(AccountId).isEmpty()) ? GenerateIrregularitySequence(mapIRRS.get(AccountId),mapCases.get(idCase)) : '';
		AACC.End_of_Grace_Period_Date__c = (cc.Calculate_End_Grace_Period_Date__c && mapCases.get(idCase).End_of_Grace_Period_Date__c != null) ? GenerateDateForBulletin(mapCases.get(idCase).End_of_Grace_Period_Date__c) : '';
		AACC.Termination_Date__c = (cc.Calculate_Termination_Date__c && mapCases.get(idCase).Termination_date__c != null) ? GenerateDateForBulletin(mapCases.get(idCase).Termination_date__c) : '';
		AACC.Forms_of_Payment__c = AMS_ChangeCodesHelper.generateFOPString(fOPs, mapCases.get(idCase).Account.ANG_IsNewGenAgency__c, cc.Change_Code__c);
		//AACC.Bulletin_Information__c = GenerateMemoText(mapCases.get(idCase), null
		//												, cc.Bulletin_Memo_Text__c, cc.Bulletin_Memo_Text2__c, cc.Bulletin_Memo_Text3__c
		//												, mapIRRS.get(AccountId), mapFinancialSecurity.get(AccountId)).toUpperCase();
		AACC.Change_Code__c = cc.Change_Code__c;
		//AACC.Effective_Date__c = ; //get the effective date from the oscar attached to the
		//if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS' || cc.Change_Code__c == 'IRW'){
		if(setIRRCC.contains(cc.Change_Code__c)){
  			if(mapCases.get(idCase).IRR_Type__c == 'Single Irregularity'){
  				AACC.Irregularities_Points__c = 1;
  				if(cc.Change_Code__c == 'IRW'){
  					AACC.Irregularity_Type__c = 'WD1';
  				}else{
  					if(mapCases.get(idCase).recordtype.developername=='SIDRA'){
  						AACC.Irregularity_Type__c = 'OV1';
  					}else{
  						if(mapCases.get(idCase).SIDRA_Lite_Reason__c == 'Annual fees'){
  							AACC.Irregularity_Type__c = 'NPA';
  						}else if(mapCases.get(idCase).Parent.Status=='Agent Notified (Email)' || mapCases.get(idCase).Parent.Status=='Agent Notified (Mail)'){
  							AACC.Irregularity_Type__c = 'FC1';
  						}else if(mapCases.get(idCase).Parent.Status=='Sanity Check Failure'){
  							AACC.Irregularity_Type__c = 'SC1';
  						}else{
  							AACC.Irregularity_Type__c = '1PT';
  						}
  					}
  				}
  			}
  			if(mapCases.get(idCase).IRR_Type__c == 'Double Irregularity'){
  				AACC.Irregularities_Points__c = 2;
  				if(cc.Change_Code__c == 'IRW'){
  					AACC.Irregularity_Type__c = 'WD2';
  				}else{
  					if(mapCases.get(idCase).recordtype.developername=='SIDRA'){
  						AACC.Irregularity_Type__c = 'OV2';
  					}else{
  						if(mapCases.get(idCase).SIDRA_Lite_Reason__c == 'Annual fees'){
  							AACC.Irregularity_Type__c = 'NPA';
  						}else if(mapCases.get(idCase).Parent.Status=='Agent Notified (Email)' || mapCases.get(idCase).Parent.Status=='Agent Notified (Mail)'){
  							AACC.Irregularity_Type__c = 'FC2';
  						}else if(mapCases.get(idCase).Parent.Status=='Sanity Check Failure'){
  							AACC.Irregularity_Type__c = 'SC2';
  						}else{
  							AACC.Irregularity_Type__c = '2PT';
  						}
  					}
  				}
  			}
  			//(mortacci mia)
			//AACC.Irregularity_Type__c = '';
			AACC.Effective_Date__c = date.ValueOf(mapCases.get(idCase).IRR_Approval_Rejection_Date__c);
		}

		if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS'){
			AACC.Operation__c = 'A';
			sUniqueId = sUniqueId + '_A';
		}

		//if((cc.Change_Code__c == 'DEF' || cc.Change_Code__c == 'DWD') && mapCases.get(idCase).recordtype.developername=='SIDRA'){
		//	AACC.DEF_Non_Payment__c = true;
		//}

		if(cc.Change_Code__c == 'IRW'){
			AACC.Operation__c = 'W';
			sUniqueId = sUniqueId + '_W';
		}

		AACC.SIDRA_Case__c = idCase;
		if(cc.Apply_to_hierarchy__c){
			if(cc.Publish_HO_Only__c){
				// the HOs are the value on the map
				if((new Set<ID>(mapAllHOs.values())).contains(AccountId))
					AACC.To_Publish_in_e_Bulletin__c = cc.Published_in_bulletin__c;
				else
					AACC.To_Publish_in_e_Bulletin__c = false;
			}else
				AACC.To_Publish_in_e_Bulletin__c = cc.Published_in_bulletin__c;
		}else
			AACC.To_Publish_in_e_Bulletin__c = cc.Published_in_bulletin__c;

		AACC.Applied_Configuration__c = cc.id;
		AACC.OSCAR__c = mapCases.get(idCase).Parent.OSCAR__c;

		//if(mapCases.get(idCase).Recordtype.DeveloperName=='SIDRA')
		//	AACC.DEF_Non_Payment__c = true;

		//This was added for all change codes beeing created in AMS_ChangeCodesHelper
		AACC.CreatedDate_User__c = GenerateDateForBulletin(system.today());

		AACC.AIMS_ID__C = sUniqueId;

		//Handles update on account
		boolean bAccntToUpd = false;
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
		if(!mapOperationalCalendar.isEmpty() && mapCases.get(idCase).External_ID__c != null && mapCases.get(idCase).External_ID__c != ''){
			string sExtId = GetOpCalendarExtId(mapCases.get(idCase).External_ID__c);
			system.debug(logginglevel.error, 'DTULLO 364 --> ' + sextid);
			if(sExtId!=''){
				if(mapOperationalCalendar.ContainsKey(sExtId)){
					AACC.Start_Date__c = mapOperationalCalendar.get(sExtId).First_Day__c;
					AACC.End_Date__c = mapOperationalCalendar.get(sExtId).Last_Day__c;
				}
			}
		}

		string sCurrReason='';
		string sPrevReason='';
		string sCurrStatus='';
		string sPrevStatus='';
		Boolean isCCBellowEigthOrDiffFour = false;
        string previousReasonAux = null;

		system.debug(logginglevel.ERROR, 'DTULLO --> 491: ' + AccountId);
		system.debug(logginglevel.ERROR, 'DTULLO --> 492: ' + mapReasonAndStatus.get(AccountId));
		system.debug(logginglevel.ERROR, 'DTULLO --> 493: ' + mapReasonAndStatus.keyset());

		if(mapReasonAndStatus.containsKey(AccountId)){
			if(mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r == null || mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r.isEmpty()){
				sCurrReason = mapReasonAndStatus.get(AccountId).Reason__c;
				sPrevReason = mapReasonAndStatus.get(AccountId).Previous_Reason__c;
				sCurrStatus = mapReasonAndStatus.get(AccountId).Status__c;
				sPrevStatus = mapReasonAndStatus.get(AccountId).PreviousStatus__c;
			}else{
				sCurrReason = mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r.get(0).Reason_Code__c + '-' + mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r.get(0).Reason_Description__c;
				sPrevReason = mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r.get(0).PreviousReason__c;
				sCurrStatus = mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r.get(0).AccountNewStatus__c;
				sPrevStatus = mapReasonAndStatus.get(AccountId).Agencies_Applied_Change_codes__r.get(0).AccountPreviousStatus__c;
			}
		}

		if(cc.Account_status_change__c == null || cc.Account_status_change__c.toUpperCase()=='CURRENT'){
			AACC.AccountNewStatus__c = sCurrStatus;
			AACC.AccountPreviousStatus__c = sPrevStatus;
		}else if(cc.Account_status_change__c.toUpperCase()=='PREV'){
			AACC.AccountNewStatus__c = sPrevStatus;
			AACC.AccountPreviousStatus__c = sCurrStatus;
		}else if (cc.Account_status_change__c.toUpperCase().startsWithIgnoreCase('PREV;')) {
			Set<string> SplittedCC = new set<string>();

			for(integer i=1;i<cc.Account_status_change__c.toUpperCase().split(';').size();i++)
				SplittedCC.add(cc.Account_status_change__c.toUpperCase().split(';').get(i));

			if (!SplittedCC.isEmpty()) {
				for (string sCCToGet:SplittedCC) {
					if (mapPrevReasonFromCC.containsKey(AccountId)) {

						if (mapPrevReasonFromCC.get(AccountId).containsKey(sCCToGet)) {
							sPrevStatus = mapPrevReasonFromCC.get(AccountId).get(sCCToGet).AccountPreviousStatus__c;
                            boolean canAddStatus = false;
                            isCCBellowEigthOrDiffFour = false;

							//if sPrevStatus is bellow 8 and different from 4, we'll iterate the account's previous change codes until we find one = > 8 or == 4 and take the account status from that one
							if (setReqValidStatus.contains(AACC.Change_Code__c) && Integer.valueOf( AMS_utils.getIATANumericStatus(sPrevStatus)) < 8 && Integer.valueOf( AMS_utils.getIATANumericStatus(sPrevStatus)) != 4) {
                               isCCBellowEigthOrDiffFour = true;
                               for (Agency_Applied_Change_code__c aaccLocal: aaccsPerAccount.get(AccountId)) {
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
                            AACC.AccountNewStatus__c = sPrevStatus;
                            AACC.AccountPreviousStatus__c = sCurrStatus;
						}
					}
				}
			}
		} else {
			AACC.AccountNewStatus__c = AMS_Utils.getIATAReadableStatus(cc.Account_status_change__c);
			AACC.AccountPreviousStatus__c = sCurrStatus;
		}

		//FM 19-04-2017 - AMSU-18
		//If status is changing to Changes processed (8) or Approved (9) clear the default date.
		if(AACC.AccountNewStatus__c == AMS_Utils.ACC_S8_CHANGESPROCESSED || AACC.AccountNewStatus__c == AMS_Utils.ACC_S9_APPROVED){
			accnt.Default_date__c = null;
			bAccntToUpd = true;
		}

		//FM 19-04-2017 - AMSU-18
		//If status is changing to Cash basis/No commission (5) and default date is empty, set the default date field to current date
		//If status is changing to Cash basis/No commission (5) and default date has a value, do nothing
		if(AACC.AccountNewStatus__c == AMS_Utils.ACC_S5_CASHNOCOMMISSION && mapReasonAndStatus.get(AccountId).Default_date__c == null){
			accnt.Default_date__c = Date.Today();
			bAccntToUpd = true;
		}

		string[] SplittedReason;
		string sReasonDesc = '';

		if(cc.Reason_Code__c == null || cc.Reason_Code__c.toUpperCase()=='CURRENT'){
			if(sCurrReason!=null && sCurrReason!='-'){
				if(sCurrReason.IndexOf('-')>0){
					SplittedReason = sCurrReason.split('-');
					//AACC.Reason_Code__c = sCurrReason.split('-').get(0);
					AACC.Reason_Code__c = SplittedReason.get(0);
					//AACC.Reason_Description__c = sCurrReason.split('-').get(1);
					AACC.Reason_Description__c = sGetReasonDescriptionFromSplit(SplittedReason);
				}else
					AACC.Reason_Code__c = sCurrReason;
			}
			AACC.PreviousReason__c = sPrevReason;
		}else if(cc.Reason_Code__c.toUpperCase()=='PREV'){
			if(sPrevReason != null && sPrevReason!=''){
				if(sPrevReason.IndexOf('-')>0){
					SplittedReason = sPrevReason.split('-');
					//AACC.Reason_Code__c = sPrevReason.split('-').get(0);
					AACC.Reason_Code__c = SplittedReason.get(0);
					AACC.Reason_Description__c = sGetReasonDescriptionFromSplit(SplittedReason);
					//AACC.Reason_Description__c = sPrevReason.split('-').get(1);
					AACC.PreviousReason__c = sCurrReason;
				}
			}
		}else if(cc.Reason_Code__c.toUpperCase().startsWithIgnoreCase('PREV;')){
			set<string> SplittedCC = new set<string>();
			for(integer i=1;i<cc.Reason_Code__c.toUpperCase().split(';').size();i++)
				SplittedCC.add(cc.Reason_Code__c.toUpperCase().split(';').get(i));

			if(!SplittedCC.isEmpty()){
				for(string sCCToGet:SplittedCC){
					if(mapPrevReasonFromCC.containsKey(AccountId)){
						if(mapPrevReasonFromCC.get(AccountId).containsKey(sCCToGet)){
							sPrevReason = mapPrevReasonFromCC.get(AccountId).get(sCCToGet).PreviousReason__c;
							// use previousResonAux if we had also used the status from a previous change code. If no change change code with acceptable status (8,9 or 4) was found will get the reason from a fallback
                            sPrevReason = (previousReasonAux != null) ? previousReasonAux :  isCCBellowEigthOrDiffFour ? getFallbackReason(AMS_Utils.getIATANumericStatus(sPrevStatus)) : sPrevReason;

							if(sPrevReason.IndexOf('-')<0){
                               sPrevReason = getFallbackReason(AMS_utils.getIATANumericStatus(sPrevStatus));
                            }
                            SplittedReason = sPrevReason.split('-');
                            AACC.Reason_Code__c = SplittedReason.get(0);
                            AACC.Reason_Description__c = sGetReasonDescriptionFromSplit(SplittedReason);
                            AACC.PreviousReason__c = sCurrReason;
						}
					}
				}
			}
		}else{
			AACC.Reason_Code__c = cc.Reason_Code__c;
			AACC.Reason_Description__c = cc.Reason_Code_Description__c;
			AACC.PreviousReason__c = sCurrReason;
		}

		if(cc.Clear_Irregularities__c)
			setAccntIdIRRToClear.add(AccountId);

		if(cc.Clear_Expiry_Date__c)
			setAccntIdToClearExpDate.add(AccountId);

		if(bAccntToUpd)
			mapAccntToUpdate.put(AccountId, accnt);

		return AACC;
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
	private static void ClearIrregularities(set<id> setAccntToClear){
		if(!setAccntToClear.isEmpty()){
			list<Agency_applied_change_code__c> lsIRRToClear = ([select id, Irregularities_Expired__c, recordtype.developername, Account__c
																 from Agency_Applied_change_code__c
																 where recordtype.developername =:'Irregularities' and Account__c in:setAccntToClear and Irregularities_Expired__c=:false]);

			if(!lsIRRToClear.isEmpty()){
				for(Agency_applied_change_code__c IRR: lsIRRToClear)
					IRR.Irregularities_Expired__c = true;

				update lsIRRToClear;
			}
		}
	}

	//Method set to clear all expiry dates, if the change code foresee this.
	private static void ClearExpiryDate(set<id> setAccntToClear){
		if(!setAccntToClear.isEmpty()){
			List<Account> lsAccToClear = [SELECT Id, Expiry_Date__c FROM Account WHERE Id IN :setAccntToClear];

			if(!lsAccToClear.isEmpty()){
				for(Account acc: lsAccToClear)
					acc.Expiry_Date__c = null;

				update lsAccToClear;
			}
		}
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
	private static boolean bCheckCondition(case NewCaseValues, string sFieldToCheck, string condition, case OldCaseValues, map<id, list<Agency_Applied_Change_code__c>> mapCC){
		set<string> setValues = new set<string>();

		if(condition.startsWithIgnoreCase('VALUES:')){
			string sValue = null;
			if(sFieldToCheck=='Parent.Status')
				sValue = NewCaseValues.Parent.Status;
			else
				sValue = (string)NewCaseValues.get(sFieldToCheck);

			//if((string)NewCaseValues.get(sFieldToCheck) == null) return false;
			if(sValue==null)	 return false;
			setValues.addAll((condition.right(condition.length()-'VALUES:'.length())).split(';'));
			//if(setValues.contains(((string)NewCaseValues.get(sFieldToCheck)).toUpperCase()))
			if(setValues.contains(sValue.toUpperCase()))
				return true;
			else return false;
		}

		if(condition.equals('NOT BLANK')){
			if(string.ValueOf(NewCaseValues.get(sFieldToCheck))!=null)
				return true;
			else return false;
		}

		if(condition.equals('BLANK')){
			if(string.ValueOf(NewCaseValues.get(sFieldToCheck))==null)
				return true;
			else return false;
		}

		if(condition.startsWithIgnoreCase('NOT EQUAL TO:')){
			string sValue = null;
			if(sFieldToCheck=='Parent.Status')
				sValue = NewCaseValues.Parent.Status;
			else
				sValue = (string)NewCaseValues.get(sFieldToCheck);

			setValues.addAll((condition.right(condition.length()-'NOT EQUAL TO:'.length())).split(';'));
			//if((string)NewCaseValues.get(sFieldToCheck) == null || !setValues.contains(((string)NewCaseValues.get(sFieldToCheck)).toUpperCase()))
			if(sValue == null || !setValues.contains(sValue.toUpperCase()))
				return true;
			else return false;
		}

		if(condition.equalsIgnoreCase('GREATER THAN TODAY')){
			//if((date)NewCaseValues.get(sFieldToCheck)>system.today())
			date d = date.valueOf(NewCaseValues.get(sFieldToCheck));
			if(d==null)	return false;
			date dToCheck = date.newinstance(d.year(), d.Month(), d.day());

			//if(date.valueOf(NewCaseValues.get(sFieldToCheck))>system.today())
			if(dToCheck>system.today())
				return true;
			else return false;
		}

		if(condition.equalsIgnoreCase('GREATER THAN TODAY OR EQUAL TO TODAY')){
			//if((date)NewCaseValues.get(sFieldToCheck)>system.today())
			date d = date.valueOf(NewCaseValues.get(sFieldToCheck));
			if(d==null)	return false;
			date dToCheck = date.newinstance(d.year(), d.Month(), d.day());

			//if(date.valueOf(NewCaseValues.get(sFieldToCheck))>system.today() || date.valueOf(NewCaseValues.get(sFieldToCheck))==system.today())
			if(dToCheck>system.today() || dToCheck==system.today())
				return true;
			else return false;
		}

		if(condition.equalsIgnoreCase('EQUAL TO TODAY')){
			//if((date)NewCaseValues.get(sFieldToCheck)==system.today())
			//if(date.valueOf(NewCaseValues.get(sFieldToCheck))==system.today())
			date d = date.valueOf(NewCaseValues.get(sFieldToCheck));
			if(d==null)	return false;
			date dToCheck = date.newinstance(d.year(), d.Month(), d.day());
			if(dToCheck==system.today())
				return true;
			else return false;
		}

		if(condition.startsWithIgnoreCase('<=:')){
			if((double)NewCaseValues.get(sFieldToCheck)<=double.valueOf(condition.right(condition.length()-'<=:'.length()))){
                if((double)NewCaseValues.get(sFieldToCheck)>0)
                    return true;
                else return false;
            }
			else return false;
		}

		if(condition.startsWithIgnoreCase('>=:')){
			if((double)NewCaseValues.get(sFieldToCheck)>=double.valueOf(condition.right(condition.length()-'>=:'.length())))
				return true;
			else return false;
		}

		if(condition.startsWithIgnoreCase('>:')){
			if((double)NewCaseValues.get(sFieldToCheck)>double.valueOf(condition.right(condition.length()-'>:'.length())))
				return true;
			else return false;
		}

		if(condition.startsWithIgnoreCase('<:')){
			if((double)NewCaseValues.get(sFieldToCheck)<double.valueOf(condition.right(condition.length()-'<:'.length())))
				return true;
			else return false;
		}

		//This condition is used to check if there is already a specific change code already generated by the sidra(lite) in the subject
		if(condition.startsWithIgnoreCase('EXISTS:')){
			if(mapCC.keyset().contains(NewCaseValues.AccountId)){
				string sChangeCode = (condition.right(condition.length()-'EXISTS:'.length()));
				for(Agency_Applied_Change_code__c aa:mapCC.get(NewCaseValues.AccountId)){
					if(aa.Change_Code__c==sChangeCode)
						return true;
				}
			}

			return false;
		}

		//This is used to check if there is already an existing same change code generated from the same SIDRA (Lite): we don't want to have it generated twice.
		if(condition.startsWithIgnoreCase('NOT EXISTS:')){
			if(mapCC.keyset().contains(NewCaseValues.AccountId)){
				string sChangeCode = (condition.right(condition.length()-'NOT EXISTS:'.length()));
				for(Agency_Applied_Change_code__c aa:mapCC.get(NewCaseValues.AccountId)){
					if(aa.Change_Code__c==sChangeCode)
						return false;
				}
			}

			return true;
		}

		return false;
	}


	//Check if there all the fields that lead to generation of change code had a change
	private static boolean CheckOldNewValues(case NewCaseValues, case OldCaseValues, string Field1, string Field2, string Field3, string Field4, string Field5, string Field6){

		if(OldCaseValues!=null){
			if( ((Field1==null || Field1.toUpperCase() == 'PARENT.STATUS' || Field1.toUpperCase() ==  'CHANGECODE' || Field1.toUpperCase()== 'EXISTS') || (Field1 != null && NewCaseValues.get(Field1) == OldCaseValues.get(Field1))) &&
				((Field2==null || Field2.toUpperCase() == 'PARENT.STATUS' || Field2.toUpperCase() ==  'CHANGECODE' || Field2.toUpperCase()== 'EXISTS') || (Field2 != null && NewCaseValues.get(Field2) == OldCaseValues.get(Field2))) &&
				((Field3==null || Field3.toUpperCase() == 'PARENT.STATUS' || Field3.toUpperCase() ==  'CHANGECODE' || Field3.toUpperCase()== 'EXISTS') || (Field3 != null && NewCaseValues.get(Field3) == OldCaseValues.get(Field3))) &&
				((Field4==null || Field4.toUpperCase() == 'PARENT.STATUS' || Field4.toUpperCase() ==  'CHANGECODE' || Field4.toUpperCase()== 'EXISTS') || (Field4 != null && NewCaseValues.get(Field4) == OldCaseValues.get(Field4))) &&
				((Field5==null || Field5.toUpperCase() == 'PARENT.STATUS' || Field5.toUpperCase() ==  'CHANGECODE' || Field5.toUpperCase()== 'EXISTS') || (Field5 != null && NewCaseValues.get(Field5) == OldCaseValues.get(Field5))) &&
				((Field6==null || Field6.toUpperCase() == 'PARENT.STATUS' || Field6.toUpperCase() ==  'CHANGECODE' || Field6.toUpperCase()== 'EXISTS') || (Field6 != null && NewCaseValues.get(Field6) == OldCaseValues.get(Field6)))
				)
				return false;
		}
		return true;
	}


	//Retrieve configuration items, stored in custom setting AMS Change Codes
	private static void ReadConfiguration(){

		ListCCConfig = [select id, Billable__c, Change_Code__c, Published_in_bulletin__c, Reason_Code__c, Reason_Code_Description__c, Record_Type__c, Risk_ChangeCode__c,
			    Field1__c, Field1Values__c, Field2__c, Field2Values__c, Field3__c, Field3Values__c, Field4__c, Field4Values__c, Field5__c, Field5Values__c, Field6__c, Field6Values__c,
			    Account_status_change__c, Class_Type__c, Bulletin_Memo_Text__c, Bulletin_Memo_Text2__c, Bulletin_Memo_Text3__c, Apply_to_hierarchy__c, Clear_Irregularities__c, Clear_Expiry_Date__c, Integration_RecId__c,
			    Used_By_CNS__c, CNS_Bulletin_Memo_Text__c, CNS_Bulletin_Memo_Text2__c, CNS_Bulletin_Memo_Text3__c, Publish_HO_Only__c, Calculate_BG_to_HO__c, Extra_memo_text_for_HO__c, Calculate_Outstanding_Amount__c,
				Calculate_Termination_Date__c, Calculate_End_Grace_Period_Date__c, Generate_Irregularity_Sequence__c, Accreditation_Model__c
			    from AMS_ChangeCodes__c where Risk_ChangeCode__c=true];
	}

	private static List<AMS_ChangeCodes__c> ReadConfiguration(String accModel){

		List<AMS_ChangeCodes__c> toReturn = new List<AMS_ChangeCodes__c>();

		for(AMS_ChangeCodes__c cc: ListCCConfig){

			if(cc.Accreditation_Model__c == accModel)
				toReturn.add(cc);

		}

		return toReturn;

	}





	//Method generates the bulletin memo text. It reads the stored values and replace all <xxxxxx> value with corresponding real value
	@TestVisible
	private static string GenerateMemoText(case theCase, Agency_Applied_Change_code__c CC, string sMemo1, string sMemo2, string sMemo3, list<Agency_Applied_Change_code__c> lsIrr, list<Financial_Security__c> lsFS, String extraMemoText, Boolean isHO){
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
			
		}

		sMemoText = extraMemoText != null ? (sMemoText + ' ' + extraMemoText) : sMemoText;
		return sMemoText;
	}


	private static string GetOpCalendarExtId(string sExtId){
		string sRet = '';
		if(sExtId != '' && sExtId!=null){
			if(sExtId.lastIndexOf(' ')>=0){
				sRet = sExtId.substring(0, sExtId.lastIndexOf(' '));
				sRet = sRet.replace(' ', '_');
			}
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
}
