global class clsMassEmailReminderBatch implements Database.Batchable<sObject>{
	global List<Case> caseList = new List<Case>();
	global String emailTemplate;
	global String type;

	global List<Case> start(Database.BatchableContext BC){
		return caseList;
	}

	//changes case status to Financial Security requested
	global void execute(Database.BatchableContext BC, List<Case> scope){
		list<Case> casesToUpdate = new list<Case>();
		try{
			for(Case c : scope){
				System.debug('*** type '+ type);
				//c.EmailTemplate__c = emailTemplate;
				if (type == 'FA - Financial Assessment'){
					System.debug('*** FA');

					c.Reminder_EmailTemplate__c = emailTemplate;
					c.Mass_Email_Send__c = true;

					System.debug('** reminder temp' + c.Reminder_EmailTemplate__c);
				}else if(type == 'SCF - Sanity Check Failure'){
					c.SCF_Reminder_Template__c = emailTemplate;
					c.SCF_Letter_Sent__c = true;
				}

				casesToUpdate.add(c);
			}

			if(!casesToUpdate.isEmpty())
				Update casesToUpdate;
		}
		catch(Exception e){}
	}

	global void finish(Database.BatchableContext BC){}
}