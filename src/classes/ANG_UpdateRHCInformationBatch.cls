public class ANG_UpdateRHCInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts {

	public enum Process {PROVISIONAL, CONSUMED}

	private Set<Id> accountsIds;
	private Process p;
	private Boolean runEverything;


	public ANG_UpdateRHCInformationBatch(Set<Id> a, Process p, Boolean r) {
		this.accountsIds = a;
		this.p = p;
		this.runEverything = r;
	}

	public Database.QueryLocator start(Database.BatchableContext BC) {
		//fetch all accounts
		return Database.getQueryLocator([Select Id From Account Where Id in: accountsIds]);
	}

   	public void execute(Database.BatchableContext BC, List<Account> scope) {
   		//run the webservice for every account, webservice is not bulkified 
   		//because the external system can only run one account at a time. 
   		// scope must be, at maximum, 100 (this is set on the call to the batch)
		for(Account account : scope) {
			if(p == Process.PROVISIONAL) {
				ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestProvisionalRHC(String.valueOf(account.id), true);
			} else {
				ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestBalanceUpdate(String.valueOf(account.id));
			}
		}
   	}

	public void finish(Database.BatchableContext BC) {
		//if we need to run both processes, run another batch with the process that has not been ran
		if (runEverything) {

			//define next process in line
			Integer processNumber = p.ordinal();
			List<Process> allProcesses = Process.values();
			Process pp = allProcesses.get(processNumber+1 == allProcesses.size() ? 0 : processNumber+1);

			database.executebatch(new ANG_UpdateRHCInformationBatch(accountsIds, pp, false), 100);
		}
	}
}