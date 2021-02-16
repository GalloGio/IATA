public with sharing  class IDCard_CheckoutSingleApplication   extends IDCardAbstractController  {

	private ID_Card_Application__c idCardApplication;

	private Account account = null;

	private List<Contact> keyContact {get; set;}

	public String applicationId  {get; set;}

	public String keyContactEmail {get; set;}

	public IDCard_CheckoutSingleApplication() {
		initialize();
		keyContact = new List<Contact>();
		if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID) == null) {
			system.debug('[IDCard_CheckoutSingleApplication] failed to load applicationId');
			throw new IDCardApplicationException('Missing parameter ' + IDCardUtil.PARAM_APPID);
		}

		system.debug('[IDCard_CheckoutSingleApplication] ');
		applicationId = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_APPID));
		system.debug('[IDCard_CheckoutSingleApplication] applicationId =' + applicationId);
		// retreive error msg if any (coming from CheckoutConfirmation)
		if (System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG) != null) {
			String errMsg = IDCardUtil.DecodeDecryptParameter(System.currentPageReference().getParameters().get(IDCardUtil.PARAM_ERRMSG));
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, errMsg));
		}


	}

	public Pagereference updateRecord() {
		try {
			// get ID Card Application
			idCardApplication = IDCardUtilWithoutSharing.retrieveCommittedICA(applicationId);
			//set the Id Card as available for Key Contact:
			idCardApplication.Application_Status__c = 'Pending' ;
			//update idCardApplication;
			IDCardUtilWithoutSharing.saveCommittedICA(idCardApplication, applicationId);


			account = [ Select BillingState, BillingCountry , Id from Account where IATACode__c = : idCardApplication.IATA_Code__c limit 1];
			system.debug('[IDCard_CheckoutSingleApplication]Acocunt Id   ' + account.Id);
			alertKeyContactForNewApplication();
		} catch (Exception ex) {
			system.debug('[IDCard_CheckoutSingleApplication] ERROR ' + ex.getMessage());
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
		}
		return null;
	}

	private void alertKeyContactForNewApplication() {
		//keyContact = [select ID, Name, Email from Contact where AccountId = :account.Id and IDCardContactType__c like   '%Key Contact %'];
		List<Managed_agency__c> managedAccountList = [select m.Id, m.Account__c, m.Contact__r.Email, m.Contact__r.IDcard_Email__c, m.Contact__r.IsEmailBounced,
								m.Contact__r.Id,  m.Account__r.IATACode__c , m.delegate__c from Managed_agency__c m where m.Account__c = :account.Id ];
		if (managedAccountList.size() == 0) {
			DevsTools.sendSFDevsAlertMessage('ID Card purchase alert', 'No Key contact for account ' + account.Id + ' Id card application womn t be process: ' + idCardApplication.Id);
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'We failed to contact your manager. Please contact IATA or your manager to validate your application1 '));
			return ;
		}

		String language = getSelectedLanguage();
		List<EmailTemplate> ets = new List<EmailTemplate>();
		if (language == 'fr') ets = [select ID from EmailTemplate where DeveloperName = 'KeyAccount_New_ApplicationFRv2'];
		if (language == 'es') ets = [select ID from EmailTemplate where DeveloperName = 'KeyAccount_New_ApplicationESv2'];
		if (language == 'en_US') ets = [select ID from EmailTemplate where DeveloperName = 'KeyAccount_New_Applicationv2'];
		
		if ( ets.size() > 0 ) {
			EmailTemplate et = ets.get(0);
			List<Messaging.SingleEmailMessage> lstEmails = new List<Messaging.SingleEmailMessage>();
			Set<String> setEmails = new Set<String>();
			system.debug('[IDCard_CheckoutSingleApplication]Emailing');

			for (Managed_agency__c c : managedAccountList ) {
				if (!c.Delegate__c && String.isNotBlank(c.Contact__r.IDCard_Email__c)) {
					keyContactEmail = c.Contact__r.IDCard_Email__c;
				}

				if (String.isNotBlank(c.Contact__r.IDCard_Email__c) && !c.Contact__r.IsEmailBounced && String.isNotBlank(c.Contact__r.Email) && !c.Contact__r.Email.endsWithIgnoreCase('.inactive') && !setEmails.contains(c.Contact__r.IDcard_Email__c)) {
					Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
					email.setTargetObjectId(c.Contact__r.Id);
					email.setToAddresses(new List<String>{c.Contact__r.IDcard_Email__c});
					email.setWhatId(idCardApplication.Id);
					email.setTreatTargetObjectAsRecipient(false);
					email.setTemplateId(et.Id);
					lstEmails.add(email);
					setEmails.add(c.Contact__r.IDcard_Email__c);
				}
			}
			
			try {
				Messaging.sendEmail(lstEmails);
				system.debug('[IDCard_CheckoutSingleApplication]Send email OK');
				return;
			} catch (EmailException e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'We failed to contact your manager. Please contact IATA or your manager to validate your application2 '));
				//throw new UtilException('[U-02] sendTemplatedEmail error. ' + e.getMessage());
			}
		} else {
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'We failed to contact your manager. Please contact IATA or your manager to validate your application3 '));
			return ;
		}
	}


	public Pagereference terminate () {
		PageReference ref = new PageReference('http://www.iata.org');
		ref.setRedirect(true);
		return ref;
	}

}
