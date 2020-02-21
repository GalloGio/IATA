public without sharing class OneId_Troubleshooting_Controller {

	@AuraEnabled
	public static Boolean submit(Case cse){
		System.debug('Start submitting - OneId_Troubleshooting_Controller');
		//Fetching the assignment rules on case
		List<AssignmentRule> arList = [SELECT Id FROM AssignmentRule WHERE SobjectType = 'Case' AND Active = true limit 1];

		//Creating the DMLOptions for "Assign using active assignment rules" checkbox
		Database.DMLOptions dmlOpts = new Database.DMLOptions();
		if(arList.size() > 0) {
			dmlOpts.assignmentRuleHeader.assignmentRuleId = arList[0].id;
		}

		try{
			cse.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('NDC Management').getRecordTypeId();
			cse.setOptions(dmlOpts);
			cse.Origin = 'Troubleshooting';

			if(isGuestUser()){
				System.debug('cse.Case_Creator_Email__c : ' + cse.Case_Creator_Email__c);
				List<Contact> contacts = [Select Id, Account.Name from Contact where Email =: cse.Case_Creator_Email__c];
				System.debug('found? : ' + contacts.size());
				System.debug('contacts : ' + contacts);
				if(!contacts.isEmpty()){
					cse.ContactId = contacts[0].Id;
					cse.Subject = contacts[0].Account.Name + ' : ' + cse.Subject;
					cse.Case_Creator_Email__c = '';
					cse.Case_Creator_Name__c = '';
				}
			}
			else{
				cse.Subject = cse.Contact.Account.Name + ' : ' + cse.Subject;
			}

			insert cse;

			if(isGuestUser()){
				Case cse2 = [SELECT Id, ContactId, Contact.Email, Case_Creator_Email__c, CaseNumber, Subject, Case_Thread_Id__c from Case WHERE Id =: cse.Id AND Contact.isEmailBounced = false AND (NOT Contact.Email LIKE '%.inactive')];

				OrgWideEmailAddress address = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];

				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setOrgWideEmailAddressId(address.Id);
				mail.setToAddresses(new List<String>{cse2.ContactId != null? cse2.Contact.Email : cse2.Case_Creator_Email__c});
				mail.setSubject('Case ' + cse2.CaseNumber + ' ' + cse2.Subject);

				String htmlBody = '<div style="margin:auto; width:600px">'
									+ '<span style="font-family:Open Sans,GillSansMT,Lucida Sans Unicode, Lucida Grande, sans-serif;color:#004577;">'
									+ '<b>Note that this is an auto-reply message. Please do not respond to this email.</b><p/>'
									+ 'Dear Customer,<br/><br/>'
									+ 'Thank you for your recent enquiry. Case #' + cse2.CaseNumber + ': "' + cse2.Subject + '" has now been created and a Customer Service Representative will contact you shortly.<br/>'
									+ 'Please ensure you refer to this Case Number in any further contact with us about this enquiry.<br/><br/>'
									+ 'Best regards,<br/>'
									+ 'IATA Customer Service<br/>'
									+ '</span>'
									+ '</div>'
									+ cse2.Case_Thread_ID__c;

				mail.setHtmlBody(htmlBody);
				Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			}
			return true;
		}
		catch(Exception e){
			System.debug(e.getMessage());
			return false;
		}
	}

	@AuraEnabled
	public static Boolean isGuestUser(){
		return [SELECT count() FROM User WHERE Name = 'identity Site Guest User' AND Id =: UserInfo.getUserId()] == 1;
	}

	@AuraEnabled
	public static Case loadEmptyCase(){
		if(isGuestUser()){
			return new Case(
				Status = 'New',
				Case_Creator_Name__c = '',
				Case_Creator_Email__c = '',
				Subject = '',
				Description = ''
			);
		}
		else{
			User u = [Select ContactId from User where Id =: UserInfo.getUserId()];
			Contact c = [select Id, Email, Account.Name from Contact where Id =: u.ContactId];
			return new Case(
				Status = 'New',
				Subject = '',
				Description = '',
				Contact = c
			);
		}
	}






}
