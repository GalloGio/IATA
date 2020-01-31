public with sharing class AuthorizedSignatoriesPackageHandler {
	/*
	 * This is a validation that ensures only one Authorized Signatory Package exists per account, by throwing an error every time the creation of a second package is attempted.
	 */
	public static void AllowOnlyOneASPPerAccount (list<Authorized_Signatories_Package__c> newList) {
		set<Id> setAccountIds = new set<Id>();

		for (Authorized_Signatories_Package__c asp : newList) {
			setAccountIds.add(asp.Account__c);
		}

		if (!setAccountIds.isEmpty()) {
			// get a list of existing ASPs for these accounts and put them into a map, per accountId
			map<Id, Authorized_Signatories_Package__c> mapASPsPerAccountId = new map<Id, Authorized_Signatories_Package__c>();
			for (Authorized_Signatories_Package__c asp : [SELECT Id, Account__c FROM Authorized_Signatories_Package__c WHERE Account__c IN :setAccountIds]) {
				mapASPsPerAccountId.put(asp.Account__c, asp);
			}

			// check for all the new ASPs that there isn't already an ASP linked to the same account
			for (Authorized_Signatories_Package__c asp : newList) {
				if (mapASPsPerAccountId.get(asp.Account__c) != null) {
					asp.addError('An Authorized Signatories Package already exists for this account. Only one package per account is allowed.');
				}
			}
		}

	}


	/*
	 * This is a validation that copies the info FROM the ASP Effective Date field on the ASP record TO the field with the same name on the Parent account
	 * after creation and after every update.
	 */
	public static void UpdateASPEffectiveDate (list<Authorized_Signatories_Package__c> newList) {
		set<Id> setAccountIds = new set<Id>();
		map<Id, Authorized_Signatories_Package__c> mapASPsPerAccountId = new map<Id, Authorized_Signatories_Package__c>();

		for (Authorized_Signatories_Package__c asp : newList) {
			//if (asp.ASP_Effective_Date__c != null) {
				setAccountIds.add(asp.Account__c);
				mapASPsPerAccountId.put(asp.Account__c, asp);
			//}
		}

		if (!setAccountIds.isEmpty()) {
			// get a list of the accounts linked to the ASPs
			list<Account> lstAccountsToUpdate = [SELECT Id, ASP_Effective_Date__c FROM Account WHERE Id IN :setAccountIds];

			// copy the effective date of the ASP
			for (Account acc : lstAccountsToUpdate) {
				acc.ASP_Effective_Date__c = mapASPsPerAccountId.get(acc.Id).ASP_Effective_Date__c; //Date.today();
			}

			// update the accounts
			update lstAccountsToUpdate;
		}

	}


	/*
	 * This method updates the Effective date on the parent ASP record in the case of new attachments linked to an ASP record.
	 */
	public static void UpdateASPEffectiveDateOnASP (list<Attachment> lstNewAttachments) {
		list<Authorized_Signatories_Package__c> lstASPsToUpdate = new list<Authorized_Signatories_Package__c>();

		set<Id> setConcernedASPs = new set<Id>();

		// get the prefix of the Authorized_Signatories_Package__c to compare with the ParentId of the new attachments
		Schema.DescribeSObjectResult dsr = Authorized_Signatories_Package__c.SObjectType.getDescribe();
		String strASPPrefix = dsr.getKeyPrefix();

		for (Attachment att : lstNewAttachments) {
			if (String.valueOf(att.ParentId).startsWith(strASPPrefix)) {
				setConcernedASPs.add(att.ParentId);
			}
		}

		if (!setConcernedASPs.isEmpty()) {
			lstASPsToUpdate = [SELECT Id, ASP_Effective_Date__c FROM Authorized_Signatories_Package__c WHERE Id IN :setConcernedASPs];

			if (! lstASPsToUpdate.isEmpty()) {
				for (Authorized_Signatories_Package__c asp : lstASPsToUpdate) {
					asp.ASP_Effective_Date__c = Date.today();
				}

				update lstASPsToUpdate;
			}
		}
	}


	/*
	 * This method updates the Effective date on the parent Authorized Signatory record in the case of new attachments linked to an AS record
	 * and saves the attachment Id in the Attachment_Link__c field.
	 */
	public static void UpdateASPEffectiveDateOnAS (list<Attachment> lstNewAttachments) {
		list<Authorized_Signatory__c> lstASsToUpdate = new list<Authorized_Signatory__c>();

		set<Id> setConcernedASs = new set<Id>();

		// get the prefix of the Authorized_Signatory__c to compare with the ParentId of the new attachments
		Schema.DescribeSObjectResult dsr = Authorized_Signatory__c.SObjectType.getDescribe();
		String strASPrefix = dsr.getKeyPrefix();

		// map to store the new attachment Id per parent AS Id
		map<Id, Attachment> mapAttachmentPerParentId = new map<Id, Attachment>();

		for (Attachment att : lstNewAttachments) {
			if (String.valueOf(att.ParentId).startsWith(strASPrefix)) {
				setConcernedASs.add(att.ParentId);
				mapAttachmentPerParentId.put(att.ParentId, att);
			}
		}

		if (!setConcernedASs.isEmpty()) {
			lstASsToUpdate = [SELECT Id, ASP_Effective_Date__c, Last_Attachment_Id__c, Image_Attachment_Id__c FROM Authorized_Signatory__c WHERE Id IN :setConcernedASs];

			if (! lstASsToUpdate.isEmpty()) {
				for (Authorized_Signatory__c asg : lstASsToUpdate) {
					asg.ASP_Effective_Date__c = Date.today();

					set<String> lstImageContentType = new set<String>{'image/jpeg', 'image/gif'};
					if (lstImageContentType.contains(mapAttachmentPerParentId.get(asg.Id).ContentType)) {
						asg.Image_Attachment_Id__c = mapAttachmentPerParentId.get(asg.Id).Id;
					} else {
						asg.Last_Attachment_Id__c = mapAttachmentPerParentId.get(asg.Id).Id;
					}
				}

				update lstASsToUpdate;
			}
		}
	}

}
