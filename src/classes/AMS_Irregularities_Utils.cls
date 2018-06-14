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
			
		CalculateAccumulatedIrregularities(setAccntIDs);
	}
	
	
	public static void CalculateAccumulatedIrregularitiesFromChangeCode(list<Agency_Applied_Change_code__c> lsCCs){
		set<id> setAccntIDs = new set<id>();
		
		for(Agency_Applied_Change_code__c cc:lsCCs)
			setAccntIDs.add(cc.account__c);
			
		CalculateAccumulatedIrregularities(setAccntIDs);
	}
	
	private static void CalculateAccumulatedIrregularities(set<id> setAccntIds){
		if(!setAccntIds.isEmpty()){
			list<Account> lsAccntToUpdate = new list<Account>();
			map<id, decimal> mapAccIRRperAgency = new map<id, decimal>();
			
			for(ID a: setAccntIDs)
				mapAccIRRperAgency.put(a, 0);
			
			if(!mapAccIRRperAgency.isEmpty()){
				//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER - DONE!
				Map<id, Account> mapAccCurrAccIRR = new Map<Id, Account>([select id, Accumulated_Irregularities__c, CNS_Agency__c from Account where id in :mapAccIRRperAgency.KeySet()]);
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
				
				for(id a:mapAccIRRperAgency.keyset()){
					//DTULLO UNCOMMENT FOR CNS, COMMENT/DELETE SIMILAR LINES AFTER - DONE!!
					if(mapAccCurrAccIRR.get(a).CNS_Agency__c)	continue;
					
					decimal AccIrr = mapAccIRRperAgency.get(a);
					decimal CurrAccIrr = mapAccCurrAccIRR.get(a).Accumulated_Irregularities__c == null ? 0 : mapAccCurrAccIRR.get(a).Accumulated_Irregularities__c;
					
					if(AccIrr != CurrAccIrr)
						lsAccntToUpdate.add(new Account(id = a, Accumulated_Irregularities__c = (AccIrr<0?0:AccIrr)));
				}
				
				if(!lsAccntToUpdate.isEmpty())
					update lsAccntToUpdate;
			}
		}
	} 
	
}