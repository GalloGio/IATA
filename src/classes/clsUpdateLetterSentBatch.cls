global class clsUpdateLetterSentBatch implements Database.Batchable<sObject>{

		global List<Case> caseList = new List<Case>();
		global Boolean isFALetterSent;
		global String type;
		global String batchNum;



		global List<Case> start(Database.BatchableContext BC){
				return caseList;
		}

		global void execute(Database.BatchableContext BC, List<Case> scope){


			 System.debug('** execute'+ caseList );

		 try{
				 for(Case c : scope)
							{

							System.debug('** scope ' + c);

						 Case ca = [Select c.Id, c.Status, c.FA_Letter_Sent__c,c.FS_Letter_Sent__c,c.BatchNumber__c From Case c Where c.Id =:c.Id ];



							 if(isFALetterSent)
							 {
										ca.FA_Letter_Sent__c = true;
										if (ca.Status == 'Agent to be Notified')
												ca.Status = 'Agent Notified (Mail)';

									 Update ca;
							 }
							 else
							 {
										if (ca.Status == 'Financial Security Requested')
												ca.FS_Letter_Sent__c = true;
										Update ca;
							 }


							}
		 }
		 catch(Exception e){}

		}

		global void finish(Database.BatchableContext BC){

			 User currentUser = [Select Id, Email, FirstName, LastName from User where Id =: UserInfo.getUserId() limit 1];

				// build email body
				String htmlEmailBody = '<html><body link=\'blue\' vlink=\'purple\' style=\'font-family:"Calibri","sans-serif";color:#1F497D;\'>Dear ' + currentUser.FirstName + ' ' + currentUser.LastName + ', <br />';
				htmlEmailBody += '<br />';
				htmlEmailBody += 'The '+type+' task for the Batch :'+batchNum+' has been completed.<br />';
				htmlEmailBody += '<br />';

				htmlEmailBody += '<br />Best Regards,<br />IFAP SF Administrator</body></html>';

				// build email object
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setSenderDisplayName('IATA Financial Review');
				mail.setTargetObjectId(currentUser.id);
				mail.setSubject('IFAP - ' +type+ ' Batch Completed');
				mail.setHtmlBody(htmlEmailBody);
				mail.saveAsActivity = false;

				// send email if not running test
				//if (!Test.isRunningTest())
						Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});

				 System.debug('** Send Batch Email 3');

		}

}
