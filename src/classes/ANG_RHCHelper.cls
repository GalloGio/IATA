public class ANG_RHCHelper {

	// *********************************************************
	// ******************* Static Variables ********************
	// *********************************************************

	//RHC Information standard record type
	public static final String RHC_INFO_STD_RT = 'RHC_Information';

	public static final String RECTYPE_STDRHCINFO = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('ANG_RHC_Information__c').get(RHC_INFO_STD_RT);


	// *********************************************************
	// *********************** Methods *************************
	// *********************************************************


	public static void createRHCInfo(Set<Id> accountIds, Boolean sumFS) {
	    createRHCInfo([SELECT Id, IATA_ISO_Country__r.CurrencyIsoCode, (SELECT Id, Security_Status__c, ANG_ConvertedAmount__c FROM Financial_Securities__r) FROM Account WHERE Id IN :accountIds], sumFS);
	}

	public static void createRHCInfo(List<Account> accounts, Boolean sumFS) {

	    if(accounts.isEmpty()) return;

	    List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

	    for(Account a : accounts){
	        rhcInfos.add(new ANG_RHC_Information__c(
	            ANG_AccountId__c = a.Id,
	            RecordTypeId = RECTYPE_STDRHCINFO,
	            ANG_UniqueKey__c=a.id+RHC_INFO_STD_RT,
	            CurrencyIsoCode = a.IATA_ISO_Country__r.CurrencyIsoCode
	        ));
	    }

	    insert rhcInfos;

	    if(sumFS) ANG_Risk_Helper.sumFSAmount(accounts);
	}

	public static void deactivateRHCInfo(List<ANG_RHC_Information__c> rhcInfos) {
	    if(!rhcInfos.isEmpty()) delete rhcInfos;
	}

	private static void moveRHCInfos(List<ANG_RHC_Information__c> rhcInfos, Map<Id, Id> newParents) {
	    for(ANG_RHC_Information__c rhcInfo : rhcInfos) rhcInfo.ANG_AccountId__c = newParents.get(rhcInfo.ANG_AccountId__c);

	    if(!rhcinfos.isEmpty()) update rhcInfos;
	}

	/*public static void calculateRHCAmount(List<Account> accounts) {
		calculateRHCAmount([SELECT Id, ANG_CashCondition__c, ANG_Financial_Security__c, ANG_RHC_Amount__c, ANG_RHC_Amount_Forecasted__c, ANG_RME_Amount__c, ANG_Exceeding_Financial_Security__c, ANG_RHC_Amount_Provisional__c FROM ANG_RHC_Information__c WHERE ANG_AccountId__c IN :accounts]);
	}*/
	
	public static void calculateRHCAmount(List<ANG_RHC_Information__c> rhcInfo) {
		//calculates RHC and forescasted RHC amount based on business rules. this is not done on a formula field, because terminated accounts should not have the value changed
		for(ANG_RHC_Information__c rhc : rhcInfo){

			if(rhc.ANG_CashCondition__c && rhc.ANG_Financial_Security__c > 0){
				rhc.ANG_RHC_Amount__c = rhc.ANG_Financial_Security__c;
				rhc.ANG_RHC_Amount_Forecasted__c = rhc.ANG_Financial_Security__c;
			}else{
				Decimal fsAmount = rhc.ANG_Financial_Security__c == null ? 0 : rhc.ANG_Financial_Security__c;
				Decimal rmeAmount = rhc.ANG_RME_Amount__c == null ? 0 : rhc.ANG_RME_Amount__c;
				Decimal provisionalRHC = rhc.ANG_RHC_Amount_Provisional__c == null ? 0 : rhc.ANG_RHC_Amount_Provisional__c;
				Decimal exceedingFS = rhc.ANG_Exceeding_Financial_Security__c == null ? 0 : rhc.ANG_Exceeding_Financial_Security__c;

				if (fsAmount > (rmeAmount + exceedingFS)) rhc.ANG_RHC_Amount__c = fsAmount;
				else rhc.ANG_RHC_Amount__c = rmeAmount + exceedingFS;


				if (fsAmount > (provisionalRHC + exceedingFS)) rhc.ANG_RHC_Amount_Forecasted__c = fsAmount;
				else rhc.ANG_RHC_Amount_Forecasted__c = provisionalRHC + exceedingFS;
			}
		}
	}
}