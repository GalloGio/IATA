public class ANG_RHCHelper {


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