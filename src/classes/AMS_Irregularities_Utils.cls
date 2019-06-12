/*****************
	DT: This class handles the accumulated irregularities counting on an account.
	
	Rules:
		1) Irregularities with Operation "A" are summed up
		2) Irregularities with Operation "W" and "D" are deducted
		3) Irregularities with other type of operation are not counted
		4) Irregularities are counted within a specific timeframe (usually 12 months. Can differ per country and program)
		5) Irregularities "expire" 12 months after they are issued 
		6) A time-based workflow is taking care of irregularity expiration (IRR: Expire)
*****************/

public class AMS_Irregularities_Utils{
	
	public static void CalculateAccumulatedIrregularitiesFromAccount(list<Account> lsAccnt){
		set<id> setAccntIDs = new set<id>();
		
		for(Account accnt:lsAccnt)
			setAccntIDs.add(accnt.id);
			
		CalculateAccumulatedIrregularities(setAccntIDs, new Map<Id,Id>());
	}
	
	
	public static void CalculateAccumulatedIrregularitiesFromChangeCode(list<Agency_Applied_Change_code__c> lsCCs){
		set<id> setAccntIDs = new set<id>();
		Map<Id,Id> mapAccountCase = new Map<Id,Id>();
		
		for(Agency_Applied_Change_code__c cc:lsCCs) {
			setAccntIDs.add(cc.account__c);
			if(cc.SIDRA_Case__c <> null) {
				mapAccountCase.put(cc.account__c, cc.SIDRA_Case__c);
			}
		}	

		System.debug('setAccntIDs: ' + setAccntIDs);
		System.debug('mapAccountCase: ' + mapAccountCase);		
			
		CalculateAccumulatedIrregularities(setAccntIDs, mapAccountCase);
	}
	
	private static void CalculateAccumulatedIrregularities(set<id> setAccntIds, Map<Id,Id> mapAccountCase){
		if(!setAccntIds.isEmpty()){
			list<Account> lsAccntToUpdate = new list<Account>();
			map<id, decimal> mapAccIRRperAgency = new map<id, decimal>();
			Map<Id,Decimal> mapCurrentIrr = new Map<Id,Decimal>();
			
			for(ID a: setAccntIDs)
				mapAccIRRperAgency.put(a, 0);
			
			if(!mapAccIRRperAgency.isEmpty()){
				//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER - DONE!
				//WMO-451 Retrieve location class and country
				Map<id, Account> mapAccCurrAccIRR = new Map<Id, Account>([select id, Accumulated_Irregularities__c, CNS_Agency__c, IATA_ISO_Country__c, Location_Class__c from Account where id in :mapAccIRRperAgency.KeySet()]);
				//Map<id, Account> mapAccCurrAccIRR = new Map<Id, Account>([select id, Accumulated_Irregularities__c from Account where id in :mapAccIRRperAgency.KeySet()]);
				
				for(Agency_Applied_Change_code__c IRRS : [select ID, Account__c, Irregularities_Expired__c, Irregularities_Points__c, Operation__c, Created_Date_To_Show__c from Agency_Applied_Change_code__c 
														  where RecordType.Developername = 'Irregularities' and Account__c in :setAccntIds AND Created_Date_To_Show__c >= LAST_YEAR]){
					if(IRRS.Operation__c == 'A' && (IRRS.Irregularities_Expired__c==null || IRRS.Irregularities_Expired__c==false)){
						mapAccIRRperAgency.put(IRRS.Account__c, integer.ValueOf(mapAccIRRperAgency.get(IRRS.Account__c)) + Integer.ValueOf((IRRS.Irregularities_Points__c==null?0:IRRS.Irregularities_Points__c)));
					}
					
					if((IRRS.Operation__c == 'W' || IRRS.Operation__c == 'D') && (IRRS.Irregularities_Expired__c==null || IRRS.Irregularities_Expired__c==false)){
						mapAccIRRperAgency.put(IRRS.Account__c, integer.ValueOf(mapAccIRRperAgency.get(IRRS.Account__c)) - Integer.ValueOf((IRRS.Irregularities_Points__c==null?0:IRRS.Irregularities_Points__c)));
					}
				}
				
				Set<Id> countriesIds = new Set<Id>();
				for(id a:mapAccIRRperAgency.keyset()){
					//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER - DONE!!
					//WMO-451
					Account accCurr = mapAccCurrAccIRR.get(a);
					if(accCurr.CNS_Agency__c)	continue;
					
					decimal AccIrr = mapAccIRRperAgency.get(a);
					decimal CurrAccIrr = accCurr.Accumulated_Irregularities__c == null ? 0 : accCurr.Accumulated_Irregularities__c;
					mapCurrentIrr.put(a, CurrAccIrr);
					
					if(AccIrr != CurrAccIrr) {
						lsAccntToUpdate.add(new Account(Id = a, Accumulated_Irregularities__c = (AccIrr<0?0:AccIrr), Location_Class__c= accCurr.Location_Class__c, IATA_ISO_Country__c= accCurr.IATA_ISO_Country__c));
						countriesIds.add(accCurr.IATA_ISO_Country__c);
					}
				}
				
				if(!lsAccntToUpdate.isEmpty()) {
					update lsAccntToUpdate;
					if(!mapAccountCase.isEmpty()) {
						checkIRRTreshold(lsAccntToUpdate, countriesIds, mapAccountCase, mapCurrentIrr);
			}
		}
	} 
		}
	} 

	
	/**
		WMO-451
	**/
	public static void checkIRRTreshold(List<Account> accounts, Set<Id> countriesIds, Map<Id,Id> mapAccountCase, Map<Id,Decimal> mapCurrentIrr) {
		Id irrFsRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Irregularities_for_FS_Request');
		Map<Id,Map<String,AMS_Country_Specific_Attribute__c>> mapCountryTreshold = new Map<Id,Map<String,AMS_Country_Specific_Attribute__c>>();
		
		for(AMS_Country_Specific_Attribute__c attr : [SELECT IATA_ISO_Country__c, Location_Class__c, Threshold__c, Reason__c FROM AMS_Country_Specific_Attribute__c WHERE IATA_ISO_Country__c IN :countriesIds AND RecordTypeId = :irrFsRT]) {
			Map<String,AMS_Country_Specific_Attribute__c> mapClassTreshold = 	mapCountryTreshold.get(attr.IATA_ISO_Country__c);
			if(mapClassTreshold == null) {
				mapClassTreshold = new Map<String,AMS_Country_Specific_Attribute__c>();
				mapCountryTreshold.put(attr.IATA_ISO_Country__c, mapClassTreshold);
			}
			mapClassTreshold.put(attr.Location_Class__c, attr);			
		}

		Map<Id,String> mapCases = new Map<Id,String>();
		for(Account acc : accounts) {
			Map<String,AMS_Country_Specific_Attribute__c> mapClassTreshold = mapCountryTreshold.get(acc.IATA_ISO_Country__c);
			Id caseId = mapAccountCase.get(acc.Id);

			if(caseId == null || mapClassTreshold == null) {
				continue;
			}

			AMS_Country_Specific_Attribute__c classTreshold =  mapClassTreshold.get(acc.Location_Class__c);
			if(classTreshold == null) {
				continue;
			}

			Decimal prevIRR = mapCurrentIrr.get(acc.Id);//Avoid to create a case when the irregularities decrease
			System.debug('prevIRR: ' + prevIRR);
			System.debug('currIRR: ' + acc.Accumulated_Irregularities__c);
			if(classTreshold.Threshold__c <= acc.Accumulated_Irregularities__c && prevIRR < classTreshold.Threshold__c) {
				String irrReason;
				if(classTreshold.Reason__c == 'Financial Security Request') {
					mapCases.put(caseId, 'FS');
				} else if(classTreshold.Reason__c == 'Adhoc Review') {
					mapCases.put(caseId, 'FA');
				}				
			}			
		}

		if(!mapCases.isEmpty()) {
			Database.executeBatch(new CreateIRRCaseBatch(mapCases), 1);
		}
	}
}