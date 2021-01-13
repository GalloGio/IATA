global class ISSP_NonTD_Report_Email_Inteface  implements Messaging.InboundEmailHandler {


	global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope envelope) {
		Messaging.InboundEmailResult result = new Messaging.InboundEmailresult();
		System.debug('SFII  email ==> '+email);
		System.debug('SFII  email.BinaryAttachments ==> '+email.BinaryAttachments);
		Messaging.InboundEmail.BinaryAttachment[] bAttachments = email.BinaryAttachments;
		String inboundIataCode = email.subject;
		String fromAddress = email.fromAddress;
		if (bAttachments != null && inboundIataCode != null ){
			system.debug('HAS ATTACHMENTS And IATACODE');

			list<Account> accList = [select Id,IATACode__c from Account where IATACode__c =: inboundIataCode And RecordType.Name = 'Airline Headquarters'];
			System.debug('SFII  AccountList ==> '+accList);
			if (!accList.isEmpty()){

				//Create new NonTD Report
				ID inboundAccountID = accList[0].ID ;
				ISSP_NonTD_Report__c newReport = new ISSP_NonTD_Report__c(Posted_Date__c = System.Today() , Account__c = inboundAccountID);
				insert newReport;
				System.debug('SFII  newReport ==> '+newReport);
				System.debug('SFII  bAttachments ==> '+bAttachments);

				//Create Attachment ,Assign it to new Report
				Attachment newAttach = new Attachment();
				newAttach.ParentId = newReport.Id;
				newAttach.Body = bAttachments[0].Body;
				newAttach.Name = bAttachments[0].fileName;
				insert newAttach;

				sendErrorEmail(fromAddress, null, false);

				//Handling sharing settings for Contacts related to the givin Account
				List<Contact> SharingContacts_List = new List<Contact>([select Id , Name , AccountID From Contact Where AccountId =: inboundAccountID OR Account.Top_Parent__c = :inboundAccountID]);

				if (SharingContacts_List != null && !SharingContacts_List.isEmpty()){

					Set<Id> ContactIDs_set = new Set<Id>();
					Set <Id> contactIds_haveAccess = new Set <Id>();
					for (Contact con : SharingContacts_List)
					{
						ContactIDs_set.add(con.id);
					}

					//send notification to NonTD Report subscribers
					List <Portal_Application_Right__c> accessList = [SELECT Id, Contact__c FROM Portal_Application_Right__c
																	WHERE Portal_Application__r.Name LIKE 'Treasury Dashboard%'
																	AND Right__c = 'Access Granted'
																	AND Contact__c IN: ContactIDs_set];
					system.debug('ACCESS LIST: ' + accessList);
					if (!accessList.isEmpty()){
						for (Portal_Application_Right__c thisAccess : accessList){
							contactIds_haveAccess.add(thisAccess.Contact__c);
						}

						//Get all users related to contacts
						List<User> UserSharing_List = new List<User> ([SELECT ID,EMAIL FROM User WHERE contactid IN: contactIds_haveAccess]);

						//give access to specific record to User
						setNonTDReportSharingSetting(UserSharing_List , newReport , 'Read');
					}
				}
			}
			else{
				sendErrorEmail(fromAddress, 'an account with IATA Code ' + inboundIataCode + ' was not found.', true);
			}
		}
		else{
			if (bAttachments == null){
				sendErrorEmail(fromAddress, 'no attachment was sent.', true);
			}
			else if (inboundIataCode == null){
				sendErrorEmail(fromAddress, 'the IATA Code cannot be null.', true);
			}
		}
		return result;
	}

	public void sendErrorEmail(String fromAddress, String reason, Boolean fail){
		List<Messaging.SendEmailResult> listEmailResult = null;
		List<Messaging.Singleemailmessage> listSingleEmailMessages = new List<Messaging.Singleemailmessage>();
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
		List <OrgWideEmailAddress> addressList = [SELECT Id FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply'];
		if (!addressList.isEmpty()){
			mail.setOrgWideEmailAddressId(addressList[0].Id);
		}
		else{
			mail.setSenderDisplayName('IATA no reply');
			mail.setReplyTo('noreply@iata.org');
		}
		mail.setToAddresses(new String[] { fromAddress });
		if (fail)
			mail.setSubject('IATA - report not loaded');
		else
			mail.setSubject('IATA - report loaded correctly');
		String plainBody;
		if (fail)
			plainBody = 'The attempt to upload a report to the ISS Portal failed because ' + reason;
		else
			plainBody = 'The report sent from this email address to the ISS Portal was uploaded successfully';
		mail.setPlainTextBody(plainBody);
		listSingleEmailMessages.add(mail);

		if(!Test.isRunningTest())
			listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
	}

	public void setNonTDReportSharingSetting(List<User> inUserList , ISSP_NonTD_Report__c inNewReport , String inPermissionType)
	{
		List<ISSP_NonTD_Report__Share> NonTDReportShares  = new List<ISSP_NonTD_Report__Share>();

		for (User us : inUserList)
		{
			// Create a new ISSP_NonTD_Report__Share record to be inserted in to the Job_Share table.
			ISSP_NonTD_Report__Share NonTDReportShare = new ISSP_NonTD_Report__Share();

			// Populate the ISSP_NonTD_Report__Share record with the ID of the record to be shared.
			NonTDReportShare.ParentId = inNewReport.Id;

			// Then, set the ID of user or group being granted access.
			NonTDReportShare.UserOrGroupId = us.Id;

			// Specify  the AccessLevel (Edit / Read )
			NonTDReportShare.AccessLevel = inPermissionType;

			// Add the new Share record to the list of new Share records.
			NonTDReportShares.add(NonTDReportShare);
		}

		// Insert all of the newly created Share records and capture save result
		Database.SaveResult[] jobShareInsertResult = Database.insert(NonTDReportShares,false);
	}
}
