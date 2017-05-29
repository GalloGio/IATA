public class ANG_RiskEventTriggerHandler {

	public List<ANG_Agency_Risk_Event__c> triggerNew = (List<ANG_Agency_Risk_Event__c>) Trigger.new;
    public List<ANG_Agency_Risk_Event__c> triggerOld = (List<ANG_Agency_Risk_Event__c>) Trigger.old;

    public Map<Id, ANG_Agency_Risk_Event__c> newMap = (Map<Id,ANG_Agency_Risk_Event__c>) Trigger.newMap;
    public Map<Id, ANG_Agency_Risk_Event__c> oldMap = (Map<Id,ANG_Agency_Risk_Event__c>) Trigger.oldMap;

    // ************************************************************
    // ****************** distribution methods ********************
    // ************************************************************

    public void onBeforeInsert(){
    	loadInformationsInsert();
    }
    public void onBeforeUpdate(){
    	loadInformationsUpdate();
    }

    public void onAfterInsert(){
        map<id,Map<id,integer>> updAccMap = new map<id,Map<id,integer>>();
        for(ANG_Agency_Risk_Event__c re : triggerNew){  
            if(re.ANG_HE_AccountId__c !=null) updAccMap.put(re.ANG_HE_AccountId__c,null);
        }
        if(updAccMap.isEmpty()) return;
        new ANG_RiskAssessmentEngine(updAccMap).assessment();
    }
    public void onAfterUpdate(){     
        map<id,Map<id,integer>> updAccMap = new map<id,Map<id,integer>>();        
        for(ANG_Agency_Risk_Event__c re : triggerNew){                  
            ANG_Agency_Risk_Event__c oldRe = oldMap.get(re.Id);
            if(re.ANG_HE_AccountId__c != oldRe.ANG_HE_AccountId__c){
                if(re.ANG_HE_AccountId__c!=null) updAccMap.put(re.ANG_HE_AccountId__c,null);
                if(oldRe.ANG_HE_AccountId__c!=null) updAccMap.put(oldRe.ANG_HE_AccountId__c,null);
            }else{
                if(re.ANG_HE_AccountId__c!=null) updAccMap.put(re.ANG_HE_AccountId__c,null);
            } 
        } 
        if(updAccMap.isEmpty()) return;
        
        new ANG_RiskAssessmentEngine(updAccMap).assessment();           
    }

    // ************************************************************
    // ********************* action methods ***********************
    // ************************************************************
	
	private void loadInformationsInsert() {
        new ANG_RiskEventGenerator(triggerNew).loadInitialInformations();
	}
	
	private void loadInformationsUpdate() {
		List<ANG_Agency_Risk_Event__c> changedRisks = new List<ANG_Agency_Risk_Event__c>();

		for(ANG_Agency_Risk_Event__c re : triggerNew){
			ANG_Agency_Risk_Event__c oldRe = oldMap.get(re.Id);
			if(
                re.ANG_AccountId__c != oldRe.ANG_AccountId__c
                || re.ANG_Issued_Date__c != oldRe.ANG_Issued_Date__c
                || re.ANG_Risk_Type__c != oldRe.ANG_Risk_Type__c
                || re.ANG_Source_Id__c != oldRe.ANG_Source_Id__c
                || re.ANG_Event_Status__c != oldRe.ANG_Event_Status__c
            ){
				changedRisks.add(re);
			}
		}

		if(changedRisks.isEmpty()) return;

        new ANG_RiskEventGenerator(changedRisks).loadInitialInformations();
	}

}
