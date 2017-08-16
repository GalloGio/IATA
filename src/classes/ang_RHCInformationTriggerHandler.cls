public class ANG_RHCInformationTriggerHandler{

	public List<ANG_RHC_Information__c> triggerNew = (List<ANG_RHC_Information__c>) Trigger.new;
	public List<ANG_RHC_Information__c> triggerOld = (List<ANG_RHC_Information__c>) Trigger.old;

	public Map<Id, ANG_RHC_Information__c> newMap = (Map<Id,ANG_RHC_Information__c>) Trigger.newMap;
	public Map<Id, ANG_RHC_Information__c> oldMap = (Map<Id,ANG_RHC_Information__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************
	
	public void onBeforeInsert(){
	}
	public void onAfterInsert(){
		recalculateConvertedAmount();
	}

	public void onBeforeUpdate(){
	}
	public void onAfterUpdate(){
		recalculateConvertedAmount();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void recalculateConvertedAmount(){
		set<id> accIdSet = new set<id>();
		
		for(ANG_RHC_Information__c rhc:triggerNew){
			if(Trigger.isInsert || (Trigger.isUpdate &&(rhc.currencyIsoCode != oldMap.get(rhc.id).CurrencyIsoCode)))	accIdSet.add(rhc.ANG_AccountId__c);
		}
		if(!accIdSet.isEmpty()){
			list<Financial_Security__c> fsList= Database.query('select account__C,amount__c,CurrencyIsoCode,ANG_ConvertedAmount__c from Financial_Security__c where account__C in:accIdSet');
			
			if(!fsList.isEmpty()){
				ANG_Risk_Helper.convertFSAmount(fsList,accIdSet);
				update fsList;
			}
		}
	}

}