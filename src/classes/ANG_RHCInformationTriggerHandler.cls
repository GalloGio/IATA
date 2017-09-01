public class ANG_RHCInformationTriggerHandler{

	public List<ANG_RHC_Information__c> triggerNew = (List<ANG_RHC_Information__c>) Trigger.new;
	public List<ANG_RHC_Information__c> triggerOld = (List<ANG_RHC_Information__c>) Trigger.old;

	public Map<Id, ANG_RHC_Information__c> newMap = (Map<Id,ANG_RHC_Information__c>) Trigger.newMap;
	public Map<Id, ANG_RHC_Information__c> oldMap = (Map<Id,ANG_RHC_Information__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************
	
	public void onBeforeInsert(){
		convertAndSumFS();
	}
	public void onAfterInsert(){
		 new ANG_AgencyEventsGenerator('Create',triggerNew,oldMap,triggerNew.getSObjectType(),'RHC_Information','ANG_AccountId__c', 'ANG_AccountId__c').run();
	}
	public void onBeforeUpdate(){
		 convertAndSumFS();
	}
	public void onAfterUpdate(){
		new ANG_AgencyEventsGenerator('Update',triggerNew,oldMap,triggerNew.getSObjectType(),'RHC_Information','ANG_AccountId__c', 'ANG_AccountId__c').run();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************


	private void convertAndSumFS(){
		set<id> accIdSet = new set<id>();		
		map<id,ANG_RHC_Information__c> accRhcMap = new map<id,ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhc:triggerNew){
			accIdSet.add(rhc.ANG_AccountId__c);
			accRhcMap.put(rhc.ANG_AccountId__c,rhc);
		}

		if(!accIdSet.isEmpty()){
			Map<id,list<Financial_Security__c>> accFSmap =new map<id,list<Financial_Security__c>>();
			for(account acc:[SELECT Id, (SELECT Id, amount__c,CurrencyIsoCode,Security_Status__c FROM Financial_Securities__r) FROM Account WHERE Id IN :accIdSet]){
				accFSmap.put(acc.id,acc.Financial_Securities__r);
			}
			list<Financial_Security__c> fsList= new list<Financial_Security__c>();
			for(id accid :accFSmap.KeySet()){
				ANG_Risk_Helper.convertFSAmountToTargetCur(accFSmap.get(accid),accRhcMap.get(accid).CurrencyIsoCode);
				accRhcMap.get(accid).ANG_Financial_Security__c =ANG_Risk_Helper.sumFSConvertedAmounts(accFSmap.get(accid));
				fsList.addAll(accFSmap.get(accid));
			}
			if(!fsList.isEmpty()){
				update fsList;
			}
		}
	}	
}