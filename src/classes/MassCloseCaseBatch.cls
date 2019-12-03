global class MassCloseCaseBatch implements Database.Batchable<sObject>, Database.Stateful{

		global list<Case> cases;
		//global map<Id,String> logs = new map<id,string>();
		global string logfile = '"Salesforce URL","Case Number","Error Message"\r\n';
		global integer numberOfErrors = 0;
		global string debug = '';

	global map<Id, Account> accToUpdate = new map<Id, Account>();
	global map<Id, Case> caseStatusToClose = new map<Id, Case>();

	global List<Account> acc = new List<Account>();
	global List<Case> cas = new List<Case>();

		global List<Case> start(Database.BatchableContext BC){
				return cases;
		}
		global void execute(Database.BatchableContext info, List<Case> scope){

			 CaseChildHelper.noValidationsOnTrgCAseIFAP = true;

			 for(Case c : scope){
						c.Status = 'Closed';
						c.Account.Has_Financial_Review_Open_Cases__c  = false;
						c.Account.Number_of_open_Financial_Review_Cases__c = 0;
						accToUpdate.put(c.Account.Id, c.Account);
						caseStatusToClose.put(c.Id, c);
			 }

				list<database.saveresult> res = database.update(scope,false);
				for(integer i = 0; i < res.size(); i++){
						database.saveresult r = res[i];
						if(!r.isSuccess()){
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

			 for(Account a : accToUpdate.values())
			 	acc.add(a);

			 for(Case c : caseStatusToClose.values())
			 	cas.add(c);

			update acc;
			update cas;

	 }
	 global void finish(Database.BatchableContext info){
			 Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			 mail.setBccAddresses(new list<String>{UserInfo.getUserEmail()});

			 /*
			 string message='"Case ID";"Error message"\r\n';
			 for(string id : logs.keyset())
					 message += '"'+id+'";"'  + logs.get(id)+'"\r\n';
			 */
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
			 Messaging.SendEmailResult [] r =
			 Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});

	 }
}
