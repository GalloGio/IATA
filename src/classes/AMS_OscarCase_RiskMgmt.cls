/**************************************

Class to handle all risk management related change codes
It works on Sidra and Sidra Lite case: when they are created or updated, values saved are checked against custom setting "".
If there is a match, than the change code configured will be created.

At the same time, bulletin memo text (sometimes dinamically calculated) will be saved on the change code itself.

**************************************/

public class AMS_OscarCase_RiskMgmt {
	private static boolean run = true;
	
	public static boolean runOnce(){
	    if(run){
			run=false;
			return true;
		}else{
			return run;
	    }
    }
    
    private static map<id, list<Agency_Applied_Change_code__c>> mapIRRS = new map<id, list<Agency_Applied_Change_code__c>>();
    private static map<id, list<Financial_Security__c>> mapFinancialSecurity = new map<id, list<Financial_security__c>>();
    private static map<id, id> mapAllHOs = new map<id, id>();
    private static set<id> setAllAccntsHiearchy = new set<id>();
    private static map<id, list<Account>> mapAccntValues = new map<id, list<Account>>();	//contains all the accounts associated with a HO.
    
	public static void CreateRiskChangeCode(map<id, case> mapTrgOld, map<id, case> mapTrgNew){
		map<id, list<AMS_ChangeCodes__c>> mapChangeCodeToCreate = new map<id, list<AMS_ChangeCodes__c>>(); //index is the Id of the case
		
		list<AMS_ChangeCodes__c> lsConf = ReadConfiguration();
		
		if(!lsConf.isEmpty()){
			map<id, Account> mapAccnt = new map<id, Account>();
		
			for(ID i:mapTrgNew.keyset())
				mapAccnt.put(mapTrgNew.get(i).AccountId, null);
			
			for(Account a:[select id, Location_Class__c, Status__c, PreviousStatus__c, Previous_Reason__c, Reason__c, parentId, parent.ParentId from Account where id in:mapAccnt.keyset()]){
				mapAccnt.put(a.id, a);
				
				if(a.Parent.ParentId != null)
					mapAllHOs.put(a.id, a.Parent.ParentId);
				else if(a.PArentId!=null)
					mapAllHOs.put(a.id, a.ParentId);
				else
					mapAllHOs.put(a.id, a.id);
			}
			
			for(Account a:[select id from Account where id in:mapAllHOs.values() or parentId in:mapAllHOs.values()  or parent.parentId in:mapAllHOs.values()])
				setAllAccntsHiearchy.add(a.Id);
				
			for(Account a:[select id, Status__c, PreviousStatus__c, Reason__c, Previous_Reason__c, Accumulated_Irregularities__c, ParentId, Parent.ParentId from Account where id in:mapAllHOs.values() or ParentId in:mapAllHOs.values() or parent.parentId in:mapAllHOs.values()]){
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
			set<string> setFSStatus = new set<string>{'Close to Expiry Date', 'Active', 'Encashed', 'Encashment in progress'};
			for(Financial_Security__c fs:[select id, Unlimited_Security__c, Account__c, Amount__c, CurrencyIsoCode, Expiry_Date__c 
										  from Financial_Security__c 
										  //where Account__c in:mapAccnt.keyset() and Security_Status__c in:setFSStatus
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
			set<string> setIRRCC = new set<string>{'IRR', 'IRS', 'IRW'};
			for(Agency_Applied_Change_code__c irr:[select id, Account__c, Change_Code__c, Effective_Date__c, Irregularities_Expired__c, Operation__c, Irregularity_Type__c, Irregularities_Points__c
												   from Agency_Applied_Change_code__c 
												   //where Account__c in:mapAccnt.keyset() and Change_Code__c in:setIRRCC and Irregularities_Expired__c=false
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
			
			map<id, Case> mapCasePerAccount = new map<id, case>();
			
			map<id, case> mapCases = new map<id, case>([
			//list<Case> lsCases = [
			select id, recordType.DeveloperName, DEF_Withdrawal_Approval_Rejection__c, DEF_Withdrawal_Reason__c, DEF_Approval_Rejection__c, End_of_Grace_Period_Date__c, 
								  Shut_Down_TKT_System_GDS_and_BSPlink__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, IRR_Withdrawal_Reason__c, NOT_Date__c, NOT_Sent__c, 
								  Notify_Agreement_Approval_to_AG__c, Reason_for_Default__c, REI_ApprovalRejectin__c, Repayment_Schedule_Approval__c, SIDRA_Lite_Reason__c, TER_Approval_Rejection__c, 
								  Termination_Reason__c, Ticketing_Authority_Re_assigned__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c, 
								  Update_AIMS_Repayment_agreed__c, Update_AIMS_TER__c, Account.Accumulated_Irregularities__c, Parent.OSCAR__r.Type_of_change__c, Parent.OSCAR__c, IRR_Approval_Rejection_Date__c, IRR_Type__c,
								  Termination_date__c, Outstanding_Amount__c, 
								  Account.Location_Class__c, AccountId, Account.Status__c, Account.PreviousStatus__c, Account.Previous_Reason__c, Account.Reason__c from case where id in:mapTrgNew.keySet()]);
			
			//for(Case c: mapTrgNew.values()){
			//for(Case c: lsCases){
			for(Case c: mapCases.values()){
				string LocClass = mapAccnt.get(c.AccountId).Location_Class__c.toUpperCase();
				string sRecordTypeName = c.recordType.DeveloperName;
				
				for(AMS_ChangeCodes__c conf:lsConf){
					set<string> setLocClass = new set<string>(conf.Class_Type__c.toUpperCase().split(';'));
					if(!setLocClass.contains(LocClass))
						continue;
						
					if(!sRecordTypeName.equalsIgnoreCase(conf.Record_Type__c))
						continue;
					
					boolean CCToBeGenerated = false;
					if(conf.Field1__c!=null)
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
						mapCasePerAccount.put(c.AccountId, c);
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
						Agency_Applied_Change_code__c AACC = CreateChangeCode(mapCases, idCase, cc, null);
						if(AACC!=null)
							lsAACC.add(AACC);
						
						//Some change codes need to be created for the whole hierarchy...
						if(cc.Apply_to_hierarchy__c){
							id CurrAccntHOID = mapAllHOs.get(CurrAccntId);
							for(Account HIERAccnt:mapAccntValues.get(CurrAccntHOID)){
								if(HierAccnt.id!=CurrAccntId){
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
	
	private static map<id, Account> mapAccntToUpdate = new map<id, account>();
	private static set<id> setAccntIdIRRToClear = new set<id>();
	
	private static Agency_Applied_Change_code__c CreateChangeCode(map<id, case> mapCases, id idCase, AMS_ChangeCodes__c cc, Account acc){
		Agency_Applied_Change_code__c AACC = new Agency_Applied_Change_code__c();
						
		id AccountId = (Acc==null?mapCases.get(idCase).AccountId:acc.id);
		//if(acc==null)
		//	AccountId = mapCases.get(idCase).AccountId;
		//else
		//	AccountId = acc.id;
		
		AACC.Account__c = AccountId;
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
		}
		
		if(cc.Change_Code__c == 'IRW'){
			AACC.Operation__c = 'W';
		}
		
		AACC.SIDRA_Case__c = idCase;
		AACC.To_Publish_in_e_Bulletin__c = cc.Published_in_bulletin__c;
		AACC.Applied_Configuration__c = cc.id;
		AACC.OSCAR__c = mapCases.get(idCase).Parent.OSCAR__c;
		
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
	
	
	private static set<id> GetAllAccntIdInHierarchy(set<id> setAccntId){
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
	}
	
	
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
	
	
	
	
	private static list<AMS_ChangeCodes__c> ReadConfiguration(){
		return [select id, Billable__c, Change_Code__c, Published_in_bulletin__c, Reason_Code__c, Reason_Code_Description__c, Record_Type__c, Risk_ChangeCode__c, 
			    Field1__c, Field1Values__c, Field2__c, Field2Values__c, Field3__c, Field3Values__c, Field4__c, Field4Values__c, Field5__c, Field5Values__c, Field6__c, Field6Values__c, 
			    Account_status_change__c, Class_Type__c, Bulletin_Memo_Text__c, Bulletin_Memo_Text2__c, Bulletin_Memo_Text3__c, Apply_to_hierarchy__c, Clear_Irregularities__c, Integration_RecId__c
			    from AMS_ChangeCodes__c where Risk_ChangeCode__c=true];
	}
	
	
	
	private static string GenerateMemoText(case theCase, Agency_Applied_Change_code__c CC, string sMemo1, string sMemo2, string sMemo3, list<Agency_Applied_Change_code__c> lsIrr, list<Financial_Security__c> lsFS){
		string sMemoText = sMemo1 + sMemo2;
		if(sMemoText==null)
			return '';
		else{
			string sTmpVal = '';
			//Start substitutions!
			if(sMemoText.containsIgnoreCase('<Termination Date>')){
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
				sMemoText = sMemoText.replace('<DEF Withdrawal reason>', theCase.DEF_Withdrawal_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<SIDRA Lite Reason>')){
				sMemoText = sMemoText.replace('<SIDRA Lite Reason>', theCase.SIDRA_Lite_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<End Grace Period Date>')){
				sMemoText = sMemoText.replace('<End Grace Period Date>', GenerateDateForBulletin(theCase.End_of_Grace_Period_Date__c));
			}
			
			if(sMemoText.containsIgnoreCase('<IRR Withdrawal Reason>')){
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
				sMemoText = sMemoText.replace('<Outstanding Amount>', string.valueOf(theCase.Outstanding_Amount__c));
			}
			
			if(sMemoText.containsIgnoreCase('<OSCAR Type>')){
				sMemoText = sMemoText.replace('<OSCAR Type>', theCase.Parent.OSCAR__r.Type_of_change__c);
			}
			
			if(sMemoText.containsIgnoreCase('<Termination Reason>')){
				sMemoText = sMemoText.replace('<Termination Reason>', theCase.Termination_Reason__c);
			}
			
			if(sMemoText.containsIgnoreCase('<Update AIMS-DEF>')){
				sMemoText = sMemoText.replace('<Update AIMS-DEF>', GenerateDateForBulletin(date.ValueOf(theCase.Update_AIMS_DEF__c)));
			}
			
		}
		return sMemoText;
	}
	
	
	
	private static string GenerateDateForBulletin(date dValue){
		if(dValue==null) return '';
		list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
		return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
	}
}