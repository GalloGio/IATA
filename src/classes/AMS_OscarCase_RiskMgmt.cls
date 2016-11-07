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
	public static void CreateRiskChangeCode(map<id, case> mapTrgOld, map<id, case> mapTrgNew){
		map<id, list<AMS_ChangeCodes__c>> mapChangeCodeToCreate = new map<id, list<AMS_ChangeCodes__c>>(); //index is the Id of the case
		
		list<AMS_ChangeCodes__c> lsConf = ReadConfiguration();
		
		if(!lsConf.isEmpty()){
			map<id, Account> mapAccnt = new map<id, Account>();
		
			for(ID i:mapTrgNew.keyset())
				mapAccnt.put(mapTrgNew.get(i).AccountId, null);
			
			for(Account a:[select id, Location_Class__c from Account where id in:mapAccnt.keyset()])
				mapAccnt.put(a.id, a);
			
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
			
			//Clear the list: it will be used later to get data to insert, I don't need it anymore before.
			if(lsAACC!=null)
				lsAACC.clear();
			
			map<id, Case> mapCasePerAccount = new map<id, case>();
			
			for(Case c: mapTrgNew.values()){
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
					
					if(CCToBeGenerated)
						CCToBeGenerated = CheckOldNewValues(c,  mapTrgOld.get(c.Id), conf.Field1__c, conf.Field2__c, conf.Field3__c, conf.Field4__c, conf.Field5__c);
					
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
						Agency_Applied_Change_code__c AACC = new Agency_Applied_Change_code__c();
						
						AACC.Account__c = mapTrgNew.get(idCase).AccountId;
						AACC.Bulletin_Information__c = '';
						AACC.Change_Code__c = cc.Change_Code__c;
						//AACC.Effective_Date__c = ; //get the effective date from the oscar attached to the 
						if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS' || cc.Change_Code__c == 'IRW'){
							if(mapTrgNew.get(idCase).IRR_Type__c == 'Single Irregularity') AACC.Irregularities_Points__c = 1;
      						if(mapTrgNew.get(idCase).IRR_Type__c == 'Double Irregularity') AACC.Irregularities_Points__c = 2;
							AACC.Irregularity_Type__c = '';
						}
						
						if(cc.Change_Code__c == 'IRR' || cc.Change_Code__c == 'IRS'){
							AACC.Operation__c = 'A';
						}
						
						if(cc.Change_Code__c == 'IRW'){
							AACC.Operation__c = 'W';
						}
						
						AACC.Reason_Code__c = cc.Reason_Code__c;
						AACC.Reason_Description__c = cc.Reason_Code_Description__c;
						AACC.SIDRA_Case__c = idCase;
						AACC.To_Publish_in_e_Bulletin__c = cc.Published_in_bulletin__c;
						AACC.Applied_Configuration__c = cc.id;
						lsAACC.add(AACC);
					}
				}
				
				if(!lsAACC.isEmpty())
					insert lsAACC;
			}
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
	
	private static boolean CheckOldNewValues(case NewCaseValues, case OldCaseValues, string Field1, string Field2, string Field3, string Field4, string Field5){
		if(OldCaseValues!=null)
			if( (Field1 != null && NewCaseValues.get(Field1) == OldCaseValues.get(Field1)) &&
				(Field2 != null && NewCaseValues.get(Field2) == OldCaseValues.get(Field2)) &&
				(Field3 != null && NewCaseValues.get(Field3) == OldCaseValues.get(Field3)) &&
				(Field4 != null && NewCaseValues.get(Field4) == OldCaseValues.get(Field4)) &&
				(Field5 != null && NewCaseValues.get(Field5) == OldCaseValues.get(Field5))
				)
				return false;
			else
				return true;
		else
			return true;
	}
	
	private static list<AMS_ChangeCodes__c> ReadConfiguration(){
		return [select id, Billable__c, Change_Code__c, Published_in_bulletin__c, Reason_Code__c, Reason_Code_Description__c, Record_Type__c, Risk_ChangeCode__c, 
			    Field1__c, Field1Values__c, Field2__c, Field2Values__c, Field3__c, Field3Values__c, Field4__c, Field4Values__c, Field5__c, Field5Values__c, 
			    Account_status_change__c, Class_Type__c
			    from AMS_ChangeCodes__c where Risk_ChangeCode__c=true];
	}
	
	
	private static string GenerateMemoText(){
		return null;
	}
}