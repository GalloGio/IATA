public with sharing class Term_And_Condition_Svc
{
	public static void validateTnC(Map<Id, Term_And_Condition__c> oldTerms, List<Term_And_Condition__c> newTerms)
	{
		Attachment_sel attachmentSelector = new Attachment_sel();

		for(Term_And_Condition__c term : newTerms)
		{
			//-- Effective Date must not be in the past (onInsert) or change to past date(onUpdate)
			if(oldTerms == null)
			{
				//-- onInsert
				if(term.Effective_Start_Date__c < Date.today()) term.addError('Effective Date cannot be in the past');
				if(term.Status__c == 'Final') term.addError('Status cannot be Final unless the T&C has an attachment');
			}
			else
			{
				//-- onUpdate
				Term_And_Condition__c oldTerm = oldTerms.get(term.Id);

				if(term.Effective_Start_Date__c < Date.today() && (term.Effective_Start_Date__c != oldTerm.Effective_Start_Date__c)) term.addError('Effective Date cannot be in the past');

				Map<Id, List<Attachment>> attachmentsByParent =  attachmentSelector.getAttachments(oldTerms.keySet());

				//-- Has no Attachment
				if(!attachmentsByParent.containsKey(term.Id) && term.Status__c == 'Final') term.addError('Status cannot be Final unless the T&C has an attachment');

				//-- If New Version then flag Notify Customer On T&C Changed checkbox
				if(term.Version_Number__c > 1)
					term.Attachment_Changed__c = true;
			}
		}
	}

	/****************************************************************************************************
		Created by David D 02/2016
			Notify customers for changes in the T&C if they have auto renew on
	****************************************************************************************************/
	public static void notifyAutoRenewCustomers(List<Term_And_Condition__c> newTerms)
	{
		OrderItem_Sel oiSelector = new OrderItem_Sel();
		Attachment_sel aSelector = new Attachment_sel();
		Term_And_Condition_Sel tcSelector = new Term_And_Condition_Sel();


		Set<Id> termIds = new Set<Id>();
		Set<String> termNames = new Set<String>();
		for(Term_And_Condition__c t : newTerms)
		{
			termIds.add(t.Id);
			termNames.add(t.Name);
		}

		SYstem.debug('termIds::'+termIds);
		SYstem.debug('termNames::'+termNames);

		//-- If T&C is the latest version then update Accepted_T&C in OrderItem
		Map<String, Term_and_Condition__c> termLastVersion = tcSelector.getTermLastVersion(termNames);
		List<OrderItem> items2Update = [
			SELECT Accepted_Term_Condition__r.Name, Accepted_Term_Condition__c
			FROM OrderItem
			WHERE Auto_Renew__c = true
				AND Accepted_Term_Condition__r.Name IN :termNames
				AND Subscription_End_Date__c >= :Date.today()
		];

		System.debug('termLastVersion::'+termLastVersion);
		System.debug('items2Update::'+items2Update);

		for(OrderItem item : items2Update)
		{
			if(termLastVersion.containsKey(item.Accepted_Term_Condition__r.Name))
			{
				Term_and_Condition__c lastVersion = termLastVersion.get(item.Accepted_Term_Condition__r.Name);
				item.Accepted_Term_Condition__c = 	lastVersion.Id;
			}
		}
		update items2Update;


		//-- Find customers who buy products with these T&C in auto-renew mode
		Map<Id, List<Id>> contactsByTerm =  oiSelector.getCustomersWhoBuyProductsOnAutoRenew(termIds);
		System.debug('contactsByTerm::'+contactsByTerm);

		//-- T&C attachments
		Map<Id, List<Attachment>> attachmentsByTerm = aSelector.getAttachments(termIds);
		System.debug('attachmentsByTerm::'+attachmentsByTerm);

		//-- Customers by Attachment
		Map<Id, List<Id>> customersByAttachment = new Map<Id, List<Id>>(); // ATTACH_ID => LIST_CONTACT_ID
		Set<Id> contactIdsForEmail = new Set<Id>();

		if(contactsByTerm != null && contactsByTerm.size() > 0)
		{
			for(Id termId : contactsByTerm.keySet())
			{
				if(attachmentsByTerm.containsKey(termId))
				{
					List<Id> contactsId = contactsByTerm.get(termId);

					//T&C has only  one attachment
					List<Attachment> attachments = attachmentsByTerm.get(termId);

					//-- Build Map
					Set<Id> tmp = (customersByAttachment.containsKey(attachments[0].Id))
						? 	new Set<Id>(customersByAttachment.get(attachments[0].Id))
						:	new Set<Id>();
					tmp.addAll(contactsId);
					contactIdsForEmail.addAll(contactsId);

					customersByAttachment.put(attachments[0].Id, new List<Id>(tmp));
				}
			}

			if(!customersByAttachment.isEmpty())
			{
				Map<Id,Contact> cons = new Map<Id,Contact>([SELECT Id FROM Contact WHERE Id IN: contactIdsForEmail AND IsEmailBounced = false AND (NOT Email LIKE '%.inactive')]);
				
				Id templateId = (Id) Utility.getTextSetting('TPL_TnC_CHANGED');
				List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
				Map<Id, Attachment> attachmentById = new Map<Id, Attachment>([SELECT Id, Name, Body FROM Attachment WHERE Id IN :customersByAttachment.keySet()]);

				for(Id attachId : customersByAttachment.keySet())
				{
					//Email attachment
					Attachment attach = attachmentById.get(attachId);
					Messaging.EmailFileAttachment eAttachment = new Messaging.EmailFileAttachment();
						eAttachment.setFileName(attach.Name);
						eAttachment.setBody(attach.Body);

					for(ID contactId : customersByAttachment.get(attachId))
					{
						if(!cons.containsKey(contactId)) continue;
						Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
							email.setTemplateId(templateId);
							email.setFileAttachments(new List<Messaging.EmailFileAttachment>{eAttachment});
							email.setTargetObjectId(contactId);

						emails.add(email);
					}
				}

				if(emails.size() > 0)
				{
					Messaging.sendEmail(emails);
				}
			}
		}

	}

	/****************************************************************************************************
		Created by David D 02/2016
			return T&C which becomes final
	****************************************************************************************************/
	public static List<Term_And_Condition__c> getFinalTerms(Map<Id, Term_And_Condition__c> oldTerms, List<Term_And_Condition__c> newTerms)
	{
		List<Term_And_Condition__c> ret = new List<Term_And_Condition__c>();

		for(Term_And_Condition__c term : newTerms)
		{
			Term_And_Condition__c oldTerm = oldTerms.get(term.Id);

			//-- If Status became Final
			if(oldTerm.Status__c != term.Status__c && term.Status__c == 'Final' && term.Attachment_Changed__c == true)
			{
				ret.add(term);
			}
		}

		return ret;
	}

}
