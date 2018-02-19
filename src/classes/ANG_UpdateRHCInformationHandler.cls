public with sharing class ANG_UpdateRHCInformationHandler {
	
	public static void ExecuteUpdateInformationHandler(List<Account> accountList, Integer wsToRun) {
		for(Account account : accountList) {
			if(wsToRun == 1) {
				ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestProvisionalRHC(String.valueOf(account.id), true);
			} else if(wsToRun == 2) {
				ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate(String.valueOf(account.id));
			}
		}
	}
}