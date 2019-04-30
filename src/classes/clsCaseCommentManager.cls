public class clsCaseCommentManager {


	public static void notifyContacts(List<CaseComment> caseComments) {

		Set<Id> caseCommentIds = new Set<Id>();
		for (CaseComment caseComment : caseComments) {

			caseCommentIds.add(caseComment.Id);
		}
		Map<Id, CaseComment> caseCommentsMap = new Map<Id, CaseComment>([Select Id, parentId, Parent.Subject, Parent.CaseNumber, /*Parent.Product_Manager__c,*/
		        Parent.RecordType.Name, Parent.Product_Manager_ACR__r.Email, CreatedBy.Profile.Name, IsPublished, Parent.ACCA_Owner__r.Email,
		        parent.ContactId, parent.Contact.Email, parent.Owner.email, parent.owner.Name, CommentBody from CaseComment where Id IN :caseCommentIds AND parentId != null]);

		String emailTemplateName = 'Self-Service New Comment Notification';

		List<EmailTemplate> ets = [Select Name, Id From EmailTemplate where Name = :emailTemplateName];


		if (ets.size() > 0) {

			EmailTemplate et = ets[0];

			List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

			for (CaseComment caseComment : caseComments) {

				CaseComment cm = caseCommentsMap.get(caseComment.Id);

				if (cm.parent.contact.email != null) {

					// Create a new single email message object
					// that will send out a single email to the addresses in the To, CC & BCC list.
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

					String caseSubject = ' : ' + cm.Parent.Subject;
					if (cm.Parent.Subject == null)
						caseSubject = '';

					//Coded added on 12/11/2010
					mail.setSubject('New Case Comment to ACR No ' + cm.Parent.CaseNumber + caseSubject.replaceFirst(':', '-'));
					mail.setTargetObjectId(cm.parent.contactId);
					//Code added on 10-Nov-2011 by Jonas Biebuyck
					String[] ccaddress = new List<String>();

					// ********* ACR &  DPC SR cases Notifications **************
					// Added by shai Fisher in 31/07/14
					if ((cm.Parent.RecordType.Name == 'Application Change Request (DPC Systems - locked)') ||
					        (cm.Parent.RecordType.Name == 'Application Change Request (DPC System)') ||
					        (cm.Parent.RecordType.Name == 'Application Change Request (DPC Systems) - ACCA')) {
						if (cm.Parent.Owner.Email != null)
							ccaddress.add(cm.Parent.Owner.Email);

						if (cm.Parent.Product_Manager_ACR__r.Email != null)
							ccaddress.add(cm.Parent.Product_Manager_ACR__r.Email);

					}
					//****** end of ACR cases Notifications **********

					mail.setCcAddresses(ccaddress);
					//End Code added on 10-Nov-2011 by Jonas Biebuyck

					String emailbody =  UserInfo.getName() + ' has added a comment to case ' + cm.Parent.CaseNumber + caseSubject + '. Please read the comment below and then click on the link to respond appropriately.\n\n';
					emailbody += 'Comment:\n\n';
					emailbody += cm.CommentBody + '\n\n';
					// The below code added on 08-12-2010
					emailbody += System.Label.SF_Base_URL + '/' + cm.Parent.Id;


					mail.setPlainTextBody(emailbody);
					mail.setWhatId(cm.parentId);
					mail.setUseSignature(true);
					mail.setSaveAsActivity(false);
					emails.add(mail);
				} else {
					ISSP_Utilities.log('parent.contact.email is null: Parent: ' + cm.ParentId + ', Contact: ' + cm.Parent.contactId);
				}

			}

			if (emails.size () > 0)
				Messaging.sendEmail(emails);

		}
	}
}