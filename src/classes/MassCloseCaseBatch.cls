public class MassCloseCaseBatch implements Database.Batchable<sObject>, Database.Stateful{
	
	public list<Case> cases;
	public string logfile = '"Salesforce URL","Case Number","Error Message"\r\n';
	public integer numberOfErrors = 0;
	public string debug = '';
	
	public Map<Id, Account> accToUpdate = new Map<Id, Account>();
	
	public List<Case> start(Database.BatchableContext BC){
		return cases;
	}
	
	public void execute(Database.BatchableContext info, List<Case> scope){
		
		CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
		
		for(Case c : scope){
			c.Status = 'Closed';
		}
		
		list<database.saveresult> res = database.update(scope,false);
		for(integer i = 0; i < res.size(); i++){
			database.saveresult r = res[i];
			if(r.isSuccess()){
				scope[i].Account.Has_Financial_Review_Open_Cases__c  = false;
				scope[i].Account.Number_of_open_Financial_Review_Cases__c = 0;
				accToUpdate.put(scope[i].AccountId, scope[i].Account);
			} else {
				numberOfErrors ++;
				logfile += '"'+Url.getSalesforceBaseUrl().toExternalForm()+'/'+scope[i].id+'","'+scope[i].CaseNumber+'","';
				boolean firstmessage = true;
				for(Database.Error e : r.getErrors()){
					logfile += (firstmessage ? '' : ', ') + e.getMessage();
					if(firstmessage)	firstmessage = false;
				}
				//logs.put(scope[i].id,errmess);
				logfile += '"\r\n';
			}
			
		}
		
		update accToUpdate.values();        
	}
	
	public void finish(Database.BatchableContext info){
		Blob b =blob.valueOf(logfile);
		
		String body = 'The case you asked to close have been closed ';
		if(numberOfErrors==0)
			body += 'successfully.\n';
		else
			body += 'with '+numberOfErrors+' errors. Please find attached the log file.\n';
		body += 'Best regards\nThe IFAP team';
		
		
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
		// Sets the 'BACK Up Accounts Pre Acli ' + dateTime.now()of the email
		email.setSubject('Mass closing cases status ' + datetime.now());
		email.setTargetObjectId(userInfo.getUserId());
		email.setPlainTextBody( body );
		email.setSaveAsActivity(false);
		
		if(numberOfErrors>0){
			Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
			efa.setContentType('Text/csv');
			efa.setFileName('MassiveCasesClosureLog'+datetime.now()+'.csv');
			efa.setBody(b);
			Messaging.EmailFileAttachment[] attachements = new Messaging.EmailFileAttachment[]{} ;
				attachements.add(efa);
			email.setFileAttachments(attachements);
		}
		// Sends the email
		Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
		
	}
}