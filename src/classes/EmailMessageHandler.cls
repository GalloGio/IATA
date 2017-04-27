public with sharing class EmailMessageHandler {
	
	/*
	 * Set the the NOI Sent Date on the parent case to now() every time that an email message is sent and:
	 * - it is attached to a SIDRA case
	 * - it has an attachment that contains "Notice of Irregularity" 
	 * Trigger on EmailMessage that checks the attachment linked to the parent case: the attachment is the result of a Conga merge operation and is automatically attached
	 * to the parent case by Conga. Solution chosen because at this time SF cannot detect the attachment on the outbound email message, and Attachment triggers doesn't trigger 
	 * on EmailMessage attachments. 
	 */
	public static void SetTheNOISentDateOnParentCase (list<EmailMessage> lstTriggerNew) {
		ID SIDRAcaseRecordTypeID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('SIDRA');
		
		Set<String> cids = new Set<String>();
		map<String, EmailMessage> messagesPerCaseId = new Map<String, EmailMessage>();
		for (EmailMessage myEmail : lstTriggerNew) {
			cids.add(myEmail.ParentId);
			messagesPerCaseId.put(myEmail.ParentId, myEmail);
		}
		
		// select all parent SIDRA cases and their last attachment
		Case[] parentSIDRACases = [SELECT Id, RecordTypeId, NOI_sent__c, 
										(SELECT Id, Name FROM Attachments ORDER BY Id DESC LIMIT 1) 
									FROM Case 
									WHERE Id IN :cids AND RecordTypeId = :SIDRAcaseRecordTypeID];
		
		// Get the Ids of SIDRA cases and get the last attachments related to each them into a map
		Set<String> setSidraCaseIds = new Set<String>();
		map<Id, Attachment> mapAttachmentsPerCaseId = new map<Id, Attachment>(); 
		
		for (Case c : parentSIDRACases) {
			setSidraCaseIds.add(c.Id);
			for (Attachment att : c.Attachments) {
				mapAttachmentsPerCaseId.put(c.Id, att);
			}
		}
		
		List<case> cases2update = new List<case>();
		
		for (Case parentCase : parentSIDRACases) {
			EmailMessage myEmail = messagesPerCaseId.get(parentCase.Id);
			
			// if parent is SIDRA case && email is a notice of irregularity, then update the NOI Sent field to NOW()
			// Added condition to populate field only one time.
			if (myEmail.Incoming == false && 
				mapAttachmentsPerCaseId.get(parentCase.Id) != null &&
				mapAttachmentsPerCaseId.get(parentCase.Id).Name.contains('Notice of Irregularity') && parentCase.NOI_sent__c == null) 
			{
					parentCase.NOI_sent__c = datetime.now();
					cases2update.add(parentCase);
			}
		}
		
		if (!cases2update.isEmpty()) {
			update cases2update;
		}
		
	}
	
	
	/*
	 * This method prevents the deletion of email messages
	 */
	public static void PreventEmailDeletion(list<EmailMessage> lstTriggerOld) {
		for (EmailMessage em : lstTriggerOld) {
			em.addError('You are not allowed to delete this Email message.');
		}
	}
	
	
}