global class ANG_UpdateRHCInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	private static Integer FIRST_WS = 1;
	private static Integer SECOND_WS = 2;

	Set<Id> accountsIds;
	List<Account> accountList;
	Integer wsToRun;


	global ANG_UpdateRHCInformationBatch(List<Account> accountList, Integer wsToRun) {
		this.wsToRun = wsToRun;
		this.accountList = accountList;
		this.accountsIds = new Set<Id>();
		for(Account a : accountList) this.accountsIds.add(a.id);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([Select Id From Account Where Id in: accountsIds]);
	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
		ExecuteUpdateInformationHandler(scope, wsToRun);
   	}

	global void finish(Database.BatchableContext BC) {
		if (this.wsToRun == FIRST_WS) {
			ANG_UpdateRHCInformationBatch b = new ANG_UpdateRHCInformationBatch(this.accountList, SECOND_WS);
			database.executebatch(b);
		}
	}

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