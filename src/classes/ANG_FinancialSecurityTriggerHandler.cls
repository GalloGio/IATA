public class ANG_FinancialSecurityTriggerHandler{

	public List<Financial_Security__c> triggerNew = (List<Financial_Security__c>) Trigger.new;
	public List<Financial_Security__c> triggerOld = (List<Financial_Security__c>) Trigger.old;

	public Map<Id, Financial_Security__c> newMap = (Map<Id,Financial_Security__c>) Trigger.newMap;
	public Map<Id, Financial_Security__c> oldMap = (Map<Id,Financial_Security__c>) Trigger.oldMap;

	private Map<string, ANG_RHC_Information__c> map2Insert {
		get{
			if(map2Insert==null){
				map2Insert = new Map<string, ANG_RHC_Information__c>();
			}
			return map2Insert;
		}
		set;
	}
	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	private set<id> accIdSet{
		get{
			if(accIdSet==null){
				accIdset = new set<id>();
				if(Trigger.isDelete){
					for(Financial_Security__c fs:triggerOld){
						accIdSet.add(fs.Account__c);
					}
				}else{
					for(Financial_Security__c fs:triggerNew){	
						if(Trigger.isUpdate &&  fs.Amount__c == oldMap.get(fs.id).Amount__c && fs.CurrencyIsoCode == oldMap.get(fs.id).CurrencyIsoCode && fs.Security_Status__c ==oldMap.get(fs.id).Security_Status__c && fs.Account__c ==oldMap.get(fs.id).Account__c) continue;
						accIdSet.add(fs.Account__c);
					}
				}							
			}
			return accIdSet;
		}
		set;
	}
	
	public void onBeforeInsert(){
		runValidations();
		convertFSAmount();
	}
	public void onAfterInsert(){
		calculateFSTotal();
		updateMinimumFS();
	}

	public void onBeforeUpdate(){
		convertFSAmount();
	}
	public void onAfterUpdate(){
		calculateFSTotal();
		updateMinimumFS();

	}

	public void onBeforeDelete(){		
	}
	public void onAfterDelete(){
		calculateFSTotal();
	}

	private void convertFSAmount(){	
		if(!accIdSet.isEmpty()) ANG_Risk_Helper.convertFSAmount(triggerNew,accIdSet);
	}

	private void calculateFSTotal(){
		
		if(!accIdSet.isEmpty()){
			list<ANG_RHC_Information__c> rhcInfoList= new list<ANG_RHC_Information__c>();
			for(account acc :[SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode, (SELECT Id, Security_Status__c, ANG_ConvertedAmount__c FROM Financial_Securities__r), (select id from RHC_Informations__r) FROM Account WHERE Id IN :accIdSet]){
				if(acc.RHC_Informations__r.size()==1){

					ANG_RHC_Information__c rhcinfo=new ANG_RHC_Information__c(
						id =acc.RHC_Informations__r.get(0).id,
						ANG_UniqueKey__c=acc.id+ANG_RHCHelper.RHC_INFO_STD_RT,
						ANG_AccountId__c=acc.id,
						ANG_Financial_Security__c=ANG_Risk_Helper.sumFSConvertedAmounts(acc.Financial_Securities__r)
						);
					 
					map2Insert.put(rhcinfo.ANG_UniqueKey__c,rhcinfo);
				}
			}
		}	
	}


	private void updateMinimumFS(){
		set<id> accIdFsSet= new set<id>();
		for(Financial_Security__c fs:triggerNew){
			if(fs.ANG_Minimum_Financial_Security__c !=null && fs.ANG_Financial_Security_Currency__c!=null && (Trigger.isInsert ||(Trigger.isUpdate && (fs.ANG_Minimum_Financial_Security__c != oldMap.get(fs.id).ANG_Minimum_Financial_Security__c || fs.ANG_Financial_Security_Currency__c != oldMap.get(fs.id).ANG_Financial_Security_Currency__c) ))  && fs.Security_Status__c=='Active'){
				accIdFsSet.add(fs.Account__c);
			}
		}
		ANG_Risk_Helper.accIdSet=accIdFsSet;
		list<ANG_RHC_Information__c> rhcList= new list<ANG_RHC_Information__c>();
		for(Financial_Security__c fs:triggerNew){
			if( fs.ANG_isToUpdateRHC__c && fs.ANG_Minimum_Financial_Security__c !=null && fs.ANG_Financial_Security_Currency__c!=null && (Trigger.isInsert ||(Trigger.isUpdate && (fs.ANG_Minimum_Financial_Security__c != oldMap.get(fs.id).ANG_Minimum_Financial_Security__c || fs.ANG_Financial_Security_Currency__c != oldMap.get(fs.id).ANG_Financial_Security_Currency__c) )) && fs.Security_Status__c=='Active'){
				if( map2Insert.containsKey(fs.Account__c+ANG_RHCHelper.RHC_INFO_STD_RT)){
					map2Insert.get(fs.Account__c+ANG_RHCHelper.RHC_INFO_STD_RT).ANG_Minimum_Financial_Security__c=ANG_Risk_Helper.currencyConverter(fs.ANG_Financial_Security_Currency__c , fs.ANG_Minimum_Financial_Security__c,ANG_Risk_Helper.accCurMap.get(fs.Account__c)!=null?ANG_Risk_Helper.accCurMap.get(fs.Account__c):fs.ANG_Financial_Security_Currency__c);
				}else{
					ANG_RHC_Information__c rhcinf= new ANG_RHC_Information__c(
						ANG_UniqueKey__c=fs.Account__c+ANG_RHCHelper.RHC_INFO_STD_RT,
						ANG_Minimum_Financial_Security__c =ANG_Risk_Helper.currencyConverter(fs.ANG_Financial_Security_Currency__c , fs.ANG_Minimum_Financial_Security__c,ANG_Risk_Helper.accCurMap.get(fs.Account__c)!=null?ANG_Risk_Helper.accCurMap.get(fs.Account__c):fs.ANG_Financial_Security_Currency__c)
					);
					map2Insert.put(rhcinf.ANG_UniqueKey__c,rhcinf);
				}
			}
		}			
		doDml();
	}

	private void doDml(){
		if(!map2Insert.values().isEmpty())upsert map2Insert.values() ANG_UniqueKey__c;
	}

	private void runValidations() {

		Set<Id> accsIds = new Set<Id>();
		List<SObject> fsToValidate = new List<SObject>();

		for(Financial_Security__c fs :triggerNew)
			accsIds.add(fs.Account__c);
		
		Map<Id,Account> accsMap = new Map<Id,Account>([SELECT Id FROM Account WHERE Id IN :accsIds AND ANG_Accreditation_Model__c = 'Multicountry']);

		if(accsMap.isEmpty())
			return;

		for (SObject obj:Trigger.new)
			if(accsMap.containsKey(String.valueOf(obj.get('Account__c'))))
				fsToValidate.add(obj);
		
		AMS_Utils.runCurrencyValidations(fsToValidate);
	}

}
