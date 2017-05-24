public with sharing class ANG_Risk_Helper{
	
	public class changeAgencyRiskEvent implements Queueable{
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
	
	public static void changeOfHE(Map<Id,Id> mapToWork){
		List<ANG_Agency_Risk_Event__c> updateHE = new List<ANG_Agency_Risk_Event__c>();					
		
		for(ANG_Agency_Risk_Event__c risk : [Select id, ANG_HE_AccountId__c, ANG_AccountId__c, ANG_Event_Status__c FROM ANG_Agency_Risk_Event__c where ANG_HE_AccountId__c in :mapToWork.keySet()]){				
			risk.ANG_HE_AccountId__c = mapToWork.get(risk.ANG_HE_AccountId__c);				
			updateHE.add(risk);								
		}		

		if(!updateHE.isEmpty()) update updateHE;
	}
}