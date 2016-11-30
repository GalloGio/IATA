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
    
    //Main Method
	public static void CreateRiskChangeCode(map<id, case> mapTrgOld, map<id, case> mapTrgNew){
		map<id, list<AMS_ChangeCodes__c>> mapChangeCodeToCreate = new map<id, list<AMS_ChangeCodes__c>>(); //index is the Id of the case
		set<string> setIRRCC = new set<string>{'IRR', 'IRS', 'IRW'};		//Irregularities change code
		set<string> setFSStatus = new set<string>{'Close to Expiry Date', 'Active', 'Encashed', 'Encashment in progress'};	//Financial Security status to be included in the memo text
		//map<id, Case> mapCasePerAccount = new map<id, case>();
		
		list<AMS_ChangeCodes__c> lsConf = ReadConfiguration();
		
		if(!lsConf.isEmpty()){
			map<id, Account> mapAccnt = new map<id, Account>();
			
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
			}
			
			//Get all Agencies IDs involved. Get all items in the hierarchy
			//for(Account a:[select id from Account where id in:mapAllHOs.values() or parentId in:mapAllHOs.values()  or parent.parentId in:mapAllHOs.values()])
			//	setAllAccntsHiearchy.add(a.Id);
			
			//For each HO, get its children
			//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
			//for(Account a:[select id, Status__c, CNS_Agency__c, PreviousStatus__c, Reason__c, Previous_Reason__c, Accumulated_Irregularities__c, ParentId, Parent.ParentId from Account where id in:mapAllHOs.values() or ParentId in:mapAllHOs.values() or parent.parentId in:mapAllHOs.values()]){
			for(Account a:[select id, Status__c, PreviousStatus__c, Reason__c, Previous_Reason__c, Accumulated_Irregularities__c, ParentId, Parent.ParentId from Account where id in:mapAllHOs.values() or ParentId in:mapAllHOs.values() or parent.parentId in:mapAllHOs.values()]){
				setAllAccntsHiearchy.add(a.Id);
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
			
			//Get all previously generated change code from same sidra/sidra lite
			map<id, list<Agency_Applied_Change_code__c>> mapExistingChangeCodes = new map<id, list<Agency_Applied_Change_code__c>>();
			list<Agency_Applied_Change_code__c> lsAACC;
			for(Agency_Applied_Change_code__c aa:[select id, Account__c, Account__r.Location_Class__c, Change_Code__c, SIDRA_Case__c from Agency_Applied_Change_code__c where SIDRA_Case__c in:mapTrgNew.keyset()]){
				lsAACC = new list<Agency_Applied_Change_code__c>();
				if(mapExistingChangeCodes.keyset().contains(aa.Account__c))
					lsAACC = mapExistingChangeCodes.get(aa.Account__c);
				
				lsAACC.add(aa);
				
				mapExistingChangeCodes.put(aa.Account__c, lsAACC);
			}
			
			//Get all financial securities related with accounts in the trigger. Used for generating bulletin memo text
			for(Financial_Security__c fs:[select id, Unlimited_Security__c, Account__c, Amount__c, CurrencyIsoCode, Expiry_Date__c 
										  from Financial_Security__c 
										  where Account__c in:setAllAccntsHiearchy and Security_Status__c in:setFSStatus
										  order by Unlimited_Security__c, Expiry_Date__c desc]){
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
												   order by Effective_Date__c desc]){
				list<Agency_Applied_Change_code__c> lsIRRS;
				if(mapIRRS.keyset().contains(irr.Account__c))
					lsIRRS = mapIRRS.get(irr.Account__c);
				else
					lsIRRS = new list<Agency_Applied_Change_code__c>();
				
				lsIRRS.add(irr);
				
				mapIRRS.put(irr.Account__c, lsIRRS);
			}
			
			//Clear the list: it will be used later to get data to insert, I don't need it anymore before.
			if(lsAACC!=null)
				lsAACC.clear();
			
			
			//Query the Cases and account info: from the trigger, I'm not getting all necessary lookup value. Trigger is always running AFTER
			map<id, case> mapCases = new map<id, case>([
			select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c, 
								  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c, 
								  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c, 
								  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c, 
								  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, IRR_Approval_Rejection_Date__c, IRR_Type__c,
								  Termination_date__c, Outstanding_Amount__c, 
								  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c, Account.Accumulated_Irregularities__c
								  , Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c, Account.AIMS_ID__c, Account.WebStar_ID__c, Account.IATACode__c
								  //DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
								  //, Account.CNS_Agency__c
								  from case where id in:mapTrgNew.keySet()]);
			
			system.debug(Logginglevel.ERROR, 'DTULLO 152 ' + mapCases.size());
			string sss = 'First Run';
			
			for(Case c: mapCases.values()){
				//Pilot countries only!
				system.debug(Logginglevel.ERROR, 'DTULLO 157 ' + sss);
				system.debug(Logginglevel.ERROR, 'DTULLO 156 ' + c.Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c);
				sss = 'Second Run?';
				if(!c.Account.IATA_ISO_Country__r.Enable_Risk_Change_Codes__c)
					continue;
				//string LocClass = mapAccnt.get(c.AccountId).Location_Class__c;
				string LocClass = c.Account.Location_Class__c;
				
				if(LocClass==null || LocClass == '')
					throw new transformationException('Account is missing Location Class!');
				else
					LocClass = LocClass.toUpperCase();
				
				string sRecordTypeName = c.recordType.DeveloperName;
				
				for(AMS_ChangeCodes__c conf:lsConf){
					set<string> setLocClass = new set<string>(conf.Class_Type__c.toUpperCase().split(';'));
					
					system.debug(Logginglevel.ERROR, 'DTULLO 172 ' + setLocClass.contains(LocClass));
					
					if(!setLocClass.contains(LocClass))
						continue;
					
					system.debug(Logginglevel.ERROR, 'DTULLO 177 ' + sRecordTypeName.equalsIgnoreCase(conf.Record_Type__c));
					
					if(!sRecordTypeName.equalsIgnoreCase(conf.Record_Type__c))
						continue;
						
					//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
					//if(mapCases.get(c).Account.CNS_Agency__c && !conf.Used_By_CNS__c)
					//	continue;
					
					boolean CCToBeGenerated = false;
					system.debug(Logginglevel.ERROR, 'DTULLO 179 ' + conf.Change_code__c);
					if(conf.Field1__c!=null)
						CCToBeGenerated = bCheckCondition(c, conf.Field1__c, conf.Field1Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 183. CCToBeGenerated ' + CCToBeGenerated);
					if(conf.Field2__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field2__c, conf.Field2Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 187. CCToBeGenerated ' + CCToBeGenerated);
					if(conf.Field3__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field3__c, conf.Field3Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 191. CCToBeGenerated ' + CCToBeGenerated);
					if(conf.Field4__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field4__c, conf.Field4Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 195. CCToBeGenerated ' + CCToBeGenerated);
					if(conf.Field5__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field5__c, conf.Field5Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 199. CCToBeGenerated ' + CCToBeGenerated);
					if(conf.Field6__c!=null && CCToBeGenerated)
						CCToBeGenerated = bCheckCondition(c, conf.Field6__c, conf.Field6Values__c.toUpperCase(), mapTrgOld.get(c.Id), mapExistingChangeCodes);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 203. CCToBeGenerated ' + CCToBeGenerated);
					if(CCToBeGenerated)
						CCToBeGenerated = CheckOldNewValues(c,  mapTrgOld.get(c.Id), conf.Field1__c, conf.Field2__c, conf.Field3__c, conf.Field4__c, conf.Field5__c, conf.Field6__c);
					
					system.debug(Logginglevel.ERROR, 'DTULLO 207. CCToBeGenerated ' + CCToBeGenerated);
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
			
			//Create the change codes!
			if(!mapChangeCodeToCreate.isEmpty()){
				lsAACC = new list<Agency_Applied_Change_code__c>();
				for(ID idCase:mapChangeCodeToCreate.keyset()){
					for(AMS_ChangeCodes__c cc :mapChangeCodeToCreate.get(idCase)){
						id CurrAccntId = mapCases.get(idCase).AccountId;
						//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
						//Agency_Applied_Change_code__c AACC = CreateChangeCode(mapCases, idCase, cc, null, mapCases.get(idCase).Account.CNS_Agency__c);
						Agency_Applied_Change_code__c AACC = CreateChangeCode(mapCases, idCase, cc, null);
						if(AACC!=null)
							lsAACC.add(AACC);
						
						//Some change codes need to be created for the whole hierarchy...
						if(cc.Apply_to_hierarchy__c){
							id CurrAccntHOID = mapAllHOs.get(CurrAccntId);
							for(Account HIERAccnt:mapAccntValues.get(CurrAccntHOID)){
								if(HierAccnt.id!=CurrAccntId){
									//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
									//Agency_Applied_Change_code__c AACCHier = CreateChangeCode(mapCases, idCase, cc, HIERAccnt, HierAccnt.CNS_Agency__c);
									Agency_Applied_Change_code__c AACCHier = CreateChangeCode(mapCases, idCase, cc, HIERAccnt);
									if(AACCHier!=null)
										lsAACC.add(AACCHier);
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
			}
		}
	}
	
	//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
	//private static Agency_Applied_Change_code__c CreateChangeCode(map<id, case> mapCases, id idCase, AMS_ChangeCodes__c cc, Account acc, boolean bIsCNS){
	private static Agency_Applied_Change_code__c CreateChangeCode(map<id, case> mapCases, id idCase, AMS_ChangeCodes__c cc, Account acc){
		datetime dt = system.now();
		
		Agency_Applied_Change_code__c AACC = new Agency_Applied_Change_code__c();
		
		id AccountId = (Acc==null?mapCases.get(idCase).AccountId:acc.id);
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
		
		//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER
		//AACC.Bulletin_Information__c = GenerateMemoText(mapCases.get(idCase), null
		//												, bIsCNS?cc.CNS_Bulletin_Memo_Text__c:cc.Bulletin_Memo_Text__c, bIsCNS?cc.CNS_Bulletin_Memo_Text2__c:cc.Bulletin_Memo_Text2__c, bIsCNS?cc.CNS_Bulletin_Memo_Text3__c:cc.Bulletin_Memo_Text3__c
		//												, mapIRRS.get(AccountId), mapFinancialSecurity.get(AccountId)).toUpperCase();
		
		AACC.Bulletin_Information__c = GenerateMemoText(mapCases.get(idCase), null
														, cc.Bulletin_Memo_Text__c, cc.Bulletin_Memo_Text2__c, cc.Bulletin_Memo_Text3__c
														, mapIRRS.get(AccountId), mapFinancialSecurity.get(AccountId)).toUpperCase();
		AACC.Change_Code__c = cc.Change_Code__c;
		//AACC.Effective_Date__c = ; //get the effective date from the oscar attached to the 
		if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS' || cc.Change_Code__c == 'IRW'){
  			if(mapCases.get(idCase).IRR_Type__c == 'Single Irregularity') AACC.Irregularities_Points__c = 1;
  			if(mapCases.get(idCase).IRR_Type__c == 'Double Irregularity') AACC.Irregularities_Points__c = 2;
			AACC.Irregularity_Type__c = '';
			AACC.Effective_Date__c = date.ValueOf(mapCases.get(idCase).IRR_Approval_Rejection_Date__c);
		}
					
		if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS'){
			AACC.Operation__c = 'A';
			sUniqueId = sUniqueId + '_A';
		}
		
		if(cc.Change_Code__c == 'IRW'){
			AACC.Operation__c = 'W';
			sUniqueId = sUniqueId + '_W';
		}
		
		AACC.SIDRA_Case__c = idCase;
		AACC.To_Publish_in_e_Bulletin__c = cc.Published_in_bulletin__c;
		AACC.Applied_Configuration__c = cc.id;
		AACC.OSCAR__c = mapCases.get(idCase).Parent.OSCAR__c;
		
		if(mapCases.get(idCase).Recordtype.DeveloperName=='SIDRA')
			AACC.DEF_Non_Payment__c = true;
		
		AACC.CreatedDate_User__c = GenerateDateForBulletin(system.today());
		
		AACC.AIMS_ID__C = sUniqueId;

		//Handles update on account
		boolean bAccntToUpd = false;
		Account accnt = new Account();
		accnt.Id = AccountId;
		if(cc.Account_status_change__c != null){
			bAccntToUpd = true;
			if(cc.Account_status_change__c.toUpperCase()=='PREV')
				if( (acc==null?(mapCases.get(idCase).Account.PreviousStatus__c):acc.PreviousStatus__c) != null )
					accnt.Status__c = mapCases.get(idCase).Account.PreviousStatus__c;
			else
				accnt.Status__c = AMS_Utils.getIATAReadableStatus(cc.Account_status_change__c);
		}
		
		//Handles Reason code and description on both Account and Change Code
		if(cc.Reason_Code__c!=null){
			bAccntToUpd = true;
			if(cc.Reason_Code__c.toUpperCase()=='PREV'){
				if(mapCases.get(idCase).Account.Previous_Reason__c!=null){
					//list<string> lsReason = mapCases.get(idCase).Account.Previous_Reason__c.split('-');
					list<string> lsReason = (acc==null?(mapCases.get(idCase).Account.Previous_Reason__c):Acc.Previous_Reason__c).split('-');
					AACC.Reason_Code__c = lsReason.get(0);
					AACC.Reason_Description__c = lsReason.get(1);
					
					//accnt.Reason__c = mapCases.get(idCase).Account.Previous_Reason__c;
					accnt.Reason__c = acc==null?(mapCases.get(idCase).Account.Previous_Reason__c):Acc.Previous_Reason__c;
				}
			}else{
				AACC.Reason_Code__c = cc.Reason_Code__c;
				AACC.Reason_Description__c = cc.Reason_Code_Description__c;
				
				accnt.Reason__c = AACC.Reason_Code__c + '-' + AACC.Reason_Description__c;
			}
		}
		
		if(cc.Clear_Irregularities__c)
			setAccntIdIRRToClear.add(AccountId);
		
		if(bAccntToUpd)
			mapAccntToUpdate.put(AccountId, accnt);
			
		return AACC;
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
	
	
	/*private static set<id> GetAllAccntIdInHierarchy(set<id> setAccntId){
		set<id> setAccntToReturn = new set<id>();
		if(setAccntId.isEmpty())
			return null;
		else{
			list<Account> lsAccnt = [select Id, ParentId, Parent.ParentId from Account where id=:setAccntId or parentid=:setAccntId or parent.parentid =:setAccntId];
			
			for(Account a:lsAccnt){
				setAccntToReturn.add(a.Id);
				if(a.ParentId!=null)
					setAccntToReturn.add(a.Parentid);
				if(a.Parent.ParentId!=null)
					setAccntToReturn.add(a.Parent.Parentid);
			}
			
			return setAccntToReturn;
		}
	}*/
	
	
	/**********************************************************************************************************************
		Method return true if condition is verified.
		Most of the times, a simple text value need to be checked. However, there are some expections such as:
		- NOT Blank
		- Blank
		- Not equal to <value>
		- TODAY
		- EXISTS <ChangeCodeToCheck>
		
		for above values, different check need to be done.
		
		Most of the time, field to check is taken directly from the SIDRA/SIDRA Lite case.
	***********************************************************************************************************************/ 
	private static boolean bCheckCondition(case NewCaseValues, string sFieldToCheck, string condition, case OldCaseValues, map<id, list<Agency_Applied_Change_code__c>> mapCC){
		set<string> setValues = new set<string>();
		
		system.debug(Logginglevel.ERROR, 'DTULLO bCheckCondition ' + sFieldToCheck);
		system.debug(Logginglevel.ERROR, 'DTULLO bCheckCondition ' + condition);
		//system.debug(Logginglevel.ERROR, 'DTULLO bCheckCondition ' + string.ValueOf(NewCaseValues.get(sFieldToCheck)));
		
		if(condition.equals('NOT BLANK')){
			system.debug(Logginglevel.ERROR, 'DTULLO bCheckCondition NOT BLANK' + string.ValueOf(NewCaseValues.get(sFieldToCheck))!=null);
			if(string.ValueOf(NewCaseValues.get(sFieldToCheck))!=null)
				return true;
			else return false;
		}
		
		if(condition.equals('BLANK')){
			system.debug(Logginglevel.ERROR, 'DTULLO bCheckCondition BLANK' + string.ValueOf(NewCaseValues.get(sFieldToCheck))==null);
			if(string.ValueOf(NewCaseValues.get(sFieldToCheck))==null)
				return true;
			else return false;
		}
		
		if(condition.startsWithIgnoreCase('NOT EQUAL TO:')){
			setValues.addAll((condition.right(condition.length()-'NOT EQUAL TO:'.length())).split(';'));
			if((string)NewCaseValues.get(sFieldToCheck) == null || !setValues.contains(((string)NewCaseValues.get(sFieldToCheck)).toUpperCase()))
				return true;
			else return false;
		}
		
		if(condition.equalsIgnoreCase('TODAY')){
			if((date)NewCaseValues.get(sFieldToCheck)==system.today())
				return true;
			else return false;
		}
		
		if(condition.startsWithIgnoreCase('<=:')){
			if((double)NewCaseValues.get(sFieldToCheck)<=double.valueOf(condition.right(condition.length()-'<=:'.length())))
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
		
		if(condition.startsWithIgnoreCase('VALUES:')){
			if((string)NewCaseValues.get(sFieldToCheck) == null) return false;
			setValues.addAll((condition.right(condition.length()-'VALUES:'.length())).split(';'));
			if(setValues.contains(((string)NewCaseValues.get(sFieldToCheck)).toUpperCase()))
				return true;
			else return false;
		}
		return false;
	}
	
	
	//Check if there all the fields that lead to generation of change code had a change
	private static boolean CheckOldNewValues(case NewCaseValues, case OldCaseValues, string Field1, string Field2, string Field3, string Field4, string Field5, string Field6){
		if(OldCaseValues!=null)
			if( (Field1 != null && NewCaseValues.get(Field1) == OldCaseValues.get(Field1)) &&
				(Field2 != null && NewCaseValues.get(Field2) == OldCaseValues.get(Field2)) &&
				(Field3 != null && NewCaseValues.get(Field3) == OldCaseValues.get(Field3)) &&
				(Field4 != null && NewCaseValues.get(Field4) == OldCaseValues.get(Field4)) &&
				(Field5 != null && NewCaseValues.get(Field5) == OldCaseValues.get(Field5)) &&
				(Field6 != null && NewCaseValues.get(Field6) == OldCaseValues.get(Field6))
				)
				return false;

		return true;
	}
	
	
	//Retrieve configuration items, stored in custom setting AMS Change Codes
	private static list<AMS_ChangeCodes__c> ReadConfiguration(){
		return [select id, Billable__c, Change_Code__c, Published_in_bulletin__c, Reason_Code__c, Reason_Code_Description__c, Record_Type__c, Risk_ChangeCode__c, 
			    Field1__c, Field1Values__c, Field2__c, Field2Values__c, Field3__c, Field3Values__c, Field4__c, Field4Values__c, Field5__c, Field5Values__c, Field6__c, Field6Values__c, 
			    Account_status_change__c, Class_Type__c, Bulletin_Memo_Text__c, Bulletin_Memo_Text2__c, Bulletin_Memo_Text3__c, Apply_to_hierarchy__c, Clear_Irregularities__c, Integration_RecId__c,
			    Used_By_CNS__c, CNS_Bulletin_Memo_Text__c, CNS_Bulletin_Memo_Text2__c, CNS_Bulletin_Memo_Text3__c
			    from AMS_ChangeCodes__c where Risk_ChangeCode__c=true];
	}
	
	
	//Method generates the bulletin memo text. It reads the stored values and replace all <xxxxxx> value with corresponding real value
	@TestVisible
	private static string GenerateMemoText(case theCase, Agency_Applied_Change_code__c CC, string sMemo1, string sMemo2, string sMemo3, list<Agency_Applied_Change_code__c> lsIrr, list<Financial_Security__c> lsFS){
		string sMemoText;
		if(sMemo1!=null)	sMemoText = sMemoText + sMemo1;
		if(sMemo2!=null)	sMemoText = sMemoText + sMemo2;
		if(sMemo3!=null)	sMemoText = sMemoText + sMemo3;

		if(sMemoText==null)
			return '';
		else{
			string sTmpVal = '';
			//Start substitutions!
			if(sMemoText.containsIgnoreCase('<Termination Date>')){
				if(theCase.Termination_date__c != null)
					sMemoText = sMemoText.replace('<Termination Date>', GenerateDateForBulletin(theCase.Termination_date__c));
			}
			
			if(sMemoText.containsIgnoreCase('<Financial Securities>')){
				sTmpVal = '';
				if(lsFS==null)	sTmpVal = 'Nil';
				else{
					for(Financial_Security__c fs:lsFS){
						sTmpVal = sTmpVal + FS.Amount__c + ', valid till ' + (fs.Unlimited_Security__c?'Unlimited':GenerateDateForBulletin(FS.Expiry_Date__c)) + '; ';
					}
				}
				
				sMemoText = sMemoText.replace('<Financial Securities>', sTmpVal);
			}
			
			if(sMemoText.containsIgnoreCase('<DEF Withdrawal reason>')){
				if(theCase.DEF_Withdrawal_Reason__c!=null)
					sMemoText = sMemoText.replace('<DEF Withdrawal reason>', theCase.DEF_Withdrawal_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<SIDRA Lite Reason>')){
				if(theCase.SIDRA_Lite_Reason__c!=null)
					sMemoText = sMemoText.replace('<SIDRA Lite Reason>', theCase.SIDRA_Lite_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<End Grace Period Date>')){
				if(theCase.End_of_Grace_Period_Date__c!=null)
					sMemoText = sMemoText.replace('<End Grace Period Date>', GenerateDateForBulletin(theCase.End_of_Grace_Period_Date__c));
			}
			
			if(sMemoText.containsIgnoreCase('<IRR Withdrawal Reason>')){
				if(theCase.IRR_Withdrawal_Reason__c!=null)
					sMemoText = sMemoText.replace('<IRR Withdrawal Reason>', theCase.IRR_Withdrawal_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<IRRS Sequence>')){
				sTmpVal = '';
				if(lsIrr==null)
					sTmpVal = ' No Irregularities Found!';
				else{
					string sPrevType = '';
					for(Agency_Applied_Change_code__c irr:lsIrr){
						if(sPrevType=='W' || sPrevType=='D' || irr.Operation__c=='W' || irr.Operation__c=='D'){
							sPrevType = irr.Operation__c;
						}else{
							sTmpVal = sTmpVal + GenerateDateForBulletin(irr.Effective_Date__c) + ' due to ' + irr.Irregularity_Type__c + '. inst.: ' + irr.Irregularities_Points__c + ';';
						}
						
						sPrevType = irr.Operation__c;
					}
					sTmpVal = sTmpVal + ' Total inst for 12 months: ' + theCase.Account.Accumulated_Irregularities__c +  '; ';
				}
				sMemoText = sMemoText.replace('<IRRS Sequence>', sTmpVal);
			}
			
			if(sMemoText.containsIgnoreCase('<Outstanding Amount>')){
				if(theCase.Outstanding_Amount__c!=null)
					sMemoText = sMemoText.replace('<Outstanding Amount>', string.valueOf(theCase.Outstanding_Amount__c));
			}
			
			if(sMemoText.containsIgnoreCase('<OSCAR Type>')){
				if(theCase.Parent.OSCAR__r.Type_of_change__c!=null)
					sMemoText = sMemoText.replace('<OSCAR Type>', theCase.Parent.OSCAR__r.Type_of_change__c);
			}
			
			if(sMemoText.containsIgnoreCase('<Termination Reason>')){
				if(theCase.Termination_Reason__c!=null)
					sMemoText = sMemoText.replace('<Termination Reason>', theCase.Termination_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<Update AIMS-DEF>')){
				if(theCase.Update_AIMS_DEF__c!=null)
					sMemoText = sMemoText.replace('<Update AIMS-DEF>', GenerateDateForBulletin(date.ValueOf(theCase.Update_AIMS_DEF__c)));
			}
			
			if(sMemoText.containsIgnoreCase('<Reason for default>')){
				if(theCase.Reason_for_Default__c!=null)
					sMemoText = sMemoText.replace('<Reason for default>', theCase.Reason_for_Default__c);
			}
			
		}
		return sMemoText;
	}
	
	
	//Format the date in the eBulletin Format (dd-mmm-yyyy)
	private static string GenerateDateForBulletin(date dValue){
		if(dValue==null) return '';
		list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
		return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
	}
}