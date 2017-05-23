public with sharing class ANG_Risk_Helper{
	// implements Queueable  


	public class changeAgencyRiskEvent implements Queueable, Database.AllowsCallouts{
		private List<ANG_Agency_Risk_Event__c> riskList;
		private Map<id,id> riskMap;
		public boolean isAllHierarchy = false;
		
		
		public changeAgencyRiskEvent (List<ANG_Agency_Risk_Event__c> listAgencyRiskEventToChange){			
			this.riskList = listAgencyRiskEventToChange;
			isAllHierarchy = true;			 
		}

		public changeAgencyRiskEvent(Map<Id,Id> mapToWork){
			this.riskMap = mapToWork;
		}

		public void execute (QueueableContext context){
			if(isAllHierarchy) inactivateRisk(riskList);
			if(!isAllHierarchy) changeOfHE(riskMap);
		}
	}


	public static void inactivateRisk (List<ANG_Agency_Risk_Event__c> listAgencyRiskEventToChange){		
		List<ANG_Agency_Risk_Event__c> riskEventToUpdate = new List<ANG_Agency_Risk_Event__c>();
		
		if(!listAgencyRiskEventToChange.isEmpty()){
			for(ANG_Agency_Risk_Event__c riskEvent : listAgencyRiskEventToChange){
				riskEvent.ANG_HE_AccountId__c = null;
				riskEvent.ANG_Event_Status__c = 'Inactive_CHO';
				riskEventToUpdate.add(riskEvent);
			}
		}

		if(!riskEventToUpdate.isEmpty()) update riskEventToUpdate;
	}

	/**
	List<ANG_Agency_Risk_Event__c> t = new List<ANG_Agency_Risk_Event__c>();
	t = [select id, ANG_HE_AccountId__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c where id = 'a9P7E0000008lEz'];

	ANG_Risk_Helper.changeAllHierarchy(t);
	System.enqueueJob(new ANG_Risk_Helper.changeAgencyRiskEvent(t));

	**/
	
	public static void changeOfHE(Map<Id,Id> mapToWork){
		List<ANG_Agency_Risk_Event__c> updateHE = new List<ANG_Agency_Risk_Event__c>();
		List<ANG_Agency_Risk_Event__c> agencyList = new List<ANG_Agency_Risk_Event__c>();	
		Set<Id> riskIds = new Set<Id>();
		
		for(Id riskEvent : mapToWork.keySet()){
			riskIds.add(riskEvent);			
		}

		agencyList = [Select id, ANG_HE_AccountId__c, ANG_AccountId__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c where ANG_HE_AccountId__c in :riskIds];
		
		if(!agencyList.isEmpty()){
			for(ANG_Agency_Risk_Event__c risk : agencyList){				
				risk.ANG_HE_AccountId__c = mapToWork.get(risk.ANG_HE_AccountId__c);				
				updateHE.add(risk);								
			}
		}

		if(!updateHE.isEmpty()) update updateHE;
	}

	/**
	Map<Id,id> h = new Map<id,id>();
Id i = '0017E00000WYXix';
id i2 = '0017E00000WKYcL';

h.put(i,i2);
ANG_Risk_Helper.changeOfHE(h);

	**/

}