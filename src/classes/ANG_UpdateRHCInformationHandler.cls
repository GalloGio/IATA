public with sharing class ANG_UpdateRHCInformationHandler {
	
	private static Integer FIRST_WS = 1;
	private static Integer SECOND_WS = 2;

	public static void ExecuteUpdateInformationHandler(List<Account> accountList, Integer wsToRun) {
		for(Account account : accountList) {
			if(wsToRun == FIRST_WS) {
				ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestProvisionalRHC(String.valueOf(account.id), true);
			} else if(wsToRun == SECOND_WS) {
				ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate(String.valueOf(account.id));
			}
		}
	}
}