global class clsBounceEmailBatch implements Database.Batchable<sObject>{

		global List<Case> caseList = new List<Case>();


		global List<Case> start(Database.BatchableContext BC){
				return caseList;
		}

		//changes case status to Financial Security requested
		global void execute(Database.BatchableContext BC, List<Case> scope){

		 try
		 {
				 for(Case c : scope)
						 {

							System.debug('*** Bounce Email batch');
							System.debug('*** email subject' + c.BounceEmailSubject__c );

								//Query to get Email with same title for the case.

							List<EmailMessage> msg = [Select e.ToAddress, e.TextBody, e.Subject, e.Status, e.ParentId, e.MessageDate, e.Incoming, e.HtmlBody, e.Headers, e.FromName, e.FromAddress, e.CreatedDate, e.CreatedById, e.CcAddress, e.BccAddress From EmailMessage e where e.ParentId =: c.ID  and e.Subject =: c.BounceEmailSubject__c order by  MessageDate desc];

							System.debug('*** Bounce Email batch msg '+ msg);

							 //if its time to send the next msg after 8hrs of previous msg
							 datetime lastEmail = msg[0].MessageDate;
							 datetime now = datetime.now();

							boolean sameday = lastEmail.isSameDay(now);
							integer hourDiff = 8;

							if (sameday)
								hourDiff = Math.abs(lastEmail.hourGmt() - now.hourGmt());


							System.debug('*** Bounce Email batch hourDiff '+ hourDiff);

							 if (hourDiff >= 8)
								{
										//if email with same BounceEmailSubject__c  exist and BounceEmailCounter__c <3
										if  ( (c.BounceEmailCounter__c < 3 || c.BounceEmailCounter__c == null) && msg.Size()>0 )
										{
														// call resend email method
														sendEmail(msg[0]);

														// clear subject
														c.BounceEmailSubject__c  = '';
														// increase counter
														c.BounceEmailCounter__c = c.BounceEmailCounter__c  + 1;
												System.debug('*** It bounced again');

										}

										else
										{
												//case status = Action needed
												c.Status = 'Action Needed';
												// counter = 0
												c.BounceEmailCounter__c = 0;
												// clear subject
												c.BounceEmailSubject__c  = '';
												System.debug('*** Status set to action needed');
										}


									 Update c;

							 }

							 //change case status when counter = 3
							 if(c.BounceEmailCounter__c == 3 &&  c.BounceEmailSubject__c  != '')
							 {
								System.debug('*** Status set to action needed');
								c.Status = 'Action Needed';
								 c.BounceEmailCounter__c = 0;
								// clear subject
								 c.BounceEmailSubject__c  = '';
								 Update c;
							 }
					 }
		 }
		 catch(Exception e){
			System.debug('*** errror '+ e);

		 }

		}

		global void finish(Database.BatchableContext BC){
		}

		 private void sendEmail(EmailMessage msg){

			 OrgWideEmailAddress  orgID = [Select o.Id  From OrgWideEmailAddress o where Address = 'noreply.ifap@iata.org'];


				// build email object
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

				List <String> toAddress = new List<String>();
				toAddress.add(msg.ToAddress);
				List <String> ccAddress = new List<String>();
				ccAddress.add(msg.CcAddress);

				mail.setOrgWideEmailAddressId(orgID.Id);
				mail.setToAddresses(toAddress);
				mail.setCcAddresses(ccAddress);
			 // mail.setSenderDisplayName(msg.FromName);

				string s = msg.Subject.Replace('Sandbox: ', '');
				mail.setSubject(s);
				mail.setHtmlBody(msg.HtmlBody+' '+msg.TextBody);
				mail.saveAsActivity = false;



				Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});


		}

}
