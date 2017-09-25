public class ANG_FinancialSecurityTriggerHandler{

	/*public List<Financial_Security__c> triggerNew = (List<Financial_Security__c>) Trigger.new;
	public List<Financial_Security__c> triggerOld = (List<Financial_Security__c>) Trigger.old;

	public Map<Id, Financial_Security__c> newMap = (Map<Id,Financial_Security__c>) Trigger.newMap;
	public Map<Id, Financial_Security__c> oldMap = (Map<Id,Financial_Security__c>) Trigger.oldMap;*/


	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	/*private set<id> accIdSet{
		get{
			reactivate on relase 3
			if(accIdSet==null){
				accIdset = new set<id>();
				if(Trigger.isDelete){
					for(Financial_Security__c fs:triggerOld){
						accIdSet.add(fs.Account__c);
					}
				}else{
					for(Financial_Security__c fs:triggerNew){	
						if(Trigger.isUpdate &&  fs.Amount__c == oldMap.get(fs.id).Amount__c && fs.CurrencyIsoCode == oldMap.get(fs.id).CurrencyIsoCode && fs.Security_Status__c ==oldMap.get(fs.id).Security_Status__c) continue;
						accIdSet.add(fs.Account__c);
					}
				}
							
			}
			return accIdSet;
		}
		set;
	}*/
	
	public void onBeforeInsert(){
		//convertFSAmount();
	}
	public void onAfterInsert(){
		//calculateFSTotal();
	}

	public void onBeforeUpdate(){
		//convertFSAmount();
	}
	public void onAfterUpdate(){
		//calculateFSTotal();
	}

	public void onBeforeDelete(){		
	}
	public void onAfterDelete(){
		//calculateFSTotal();
	}

	/*REACTIVATE ON RELASE 3
	private void convertFSAmount(){	
		if(!accIdSet.isEmpty()) ANG_Risk_Helper.convertFSAmount(triggerNew,accIdSet);
	}

	private void calculateFSTotal(){

		if(!accIdSet.isEmpty()){
			list<account> accList= [SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode, (SELECT Id, Security_Status__c, ANG_ConvertedAmount__c FROM Financial_Securities__r) FROM Account WHERE Id IN :accIdSet];
			if(!accList.isEmpty())ANG_Risk_Helper.sumFSAmount(accList);	
		}	
	}*/


}