public class ANG_UpdateRHCInformationBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

	public enum Process {PROVISIONAL, CONSUMED}

	private Set<Id> accountsIds;
	private Process p;
	private Boolean runEverything;
	private Integer scopeSize = 100; //sets default scope size . this is used on the Queuable Constructor

	private String successes ='';
	private String errors ='';

	// *********************************************************
	// ******************** Constructors ***********************
	// *********************************************************

	public ANG_UpdateRHCInformationBatch(Set<Id> a, Process p, Boolean r, Integer s) {
		this(a, p, r);
		this.scopeSize = s;
	}
	public ANG_UpdateRHCInformationBatch(Set<Id> a, Process p, Boolean r) {
		this.accountsIds = a;
		this.p = p;
		this.runEverything = r;
	}


	// *********************************************************
	// ****************** Queuable method **********************
	// *********************************************************
	/* removed due to the Database.Stateful that conflicts with Queueable interface. // caused by: System.AsyncException: 
		Queueable cannot be implemented with other system interfaces.
	public void execute(QueueableContext context) {
		Database.executeBatch(this, scopeSize);
	}
	*/

	// *********************************************************
	// ******************* Batch methods ***********************
	// *********************************************************
	public Database.QueryLocator start(Database.BatchableContext BC) {
		//fetch all accounts
		return Database.getQueryLocator([Select Id, Name, IATACode__c From Account Where Id in: accountsIds]);
	}

   	public void execute(Database.BatchableContext BC, List<Account> scope) {
   		//run the webservice for every account, webservice is not bulkified 
   		//because the external system can only run one account at a time. 
   		// scope must be, at maximum, 100 (this is set on the call to the batch)
   		ANG_RME_Alert_Service.WebserviceResult result;

		for(Account account : scope) {
			if(p == Process.PROVISIONAL) {
				result = ANG_RME_Alert_Service.requestProvisionalRHC(String.valueOf(account.id), true);
			} else {
				result = ANG_RME_Alert_Service.requestBalanceUpdate(String.valueOf(account.id));
			}

			if(result.isSuccess) successes += account.IATACode__c+' - '+account.Name +(result.description != null ? ' - '+result.description : '' )+'\n';
			else errors += account.IATACode__c+' - '+account.Name +' - '+(result.description != null ? ' - '+result.description : '' )+'\n';
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

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setToAddresses(new List<String>{UserInfo.getUserEmail()});    
            mail.setSubject('Request '+ (p == Process.PROVISIONAL ? 'Provisional RHC' : 'Balance Update' ) + ' Batch results');
            mail.setSenderDisplayName('Batch Processing Completed');
            mail.setPlainTextBody('Batch Process has been completed. End Time: ' + system.now() + '\n\n'+
              	(!String.isEmpty(successes) ? ': : Successes : :\n\n'+successes : '')+
               	(!String.isEmpty(errors) ? '\n\n: : Errors : :\n\n'+errors : '') );
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
	}
}