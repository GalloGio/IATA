public without sharing class PortalRegistrationSecondLevelCtrl {
	@AuraEnabled(cacheable=true)
	public static GCS_Customer_Type_For_Registration__mdt getMetadataCustomerTypeForL2(String customerTypeKey) {
		if(customerTypeKey == null){
			return null;
		}
		return GCS_CustomerType.getCustomerTypesMap().get(customerTypeKey).metadataCustomerType;
	}

	@AuraEnabled
	public static Account getAccountInfo(String accountId){
		list<Account> accounts = [SELECT Id, Name, Sector__c, Category__c, BillingStreet, IATA_ISO_Country__r.Name
									FROM Account
									WHERE Id =: accountId];

		if(!accounts.isEmpty()){
			return accounts[0];
		}
		return null;
	}

	@AuraEnabled
	public static Contact getContactInfo() {
		User loggedUser = CSP_Utils.getLoggedUser();

		List<Contact> con = [SELECT Id, FirstName, LastName, Salutation, Birthdate, Date_of_Birth__c, Title, Membership_Function__c, Function__c, User_Portal_Status__c, AccountId, Account.Name, Account.IATA_ISO_Country__r.Id, Account.IATA_ISO_Country__r.Name, Account.Sector__c, Account.Category__c, Account.Is_General_Public_Account__c
		FROM Contact
		WHERE Id = :loggedUser.contactId];

		if(con.isEmpty()){
			return null;
		}

		return con[0];
	}

	@AuraEnabled
	public static String saveContactInfo(Contact con){
		try{
			update con;
			return 'success';
		}
		catch(Exception e){
			return e.getMessage();
		}
	}

	@AuraEnabled
	public static List<PortalFAQs__mdt> getL2Topics(){
		List<PortalFAQs__mdt> topics = [SELECT Id, DataTopicName__c
										FROM PortalFAQs__mdt
										WHERE DataCategoryName__c <> ''
										AND DataTopicName__c <> ''
										AND DataSubtopicName__c = ''
										AND Requires_Level2_Registration__c = true];

		return topics;
	}

	@AuraEnabled
	public static String createIsoCity(String name, String stateId, Boolean isPoBox){
		IATA_ISO_City__c isoCity = new IATA_ISO_City__c(
			Name = name,
			IATA_ISO_State__c = stateId,
			Is_PO_Box_City__c = isPoBox,
			Status__c = 'Pending'
		);

		insert isoCity;

		return isoCity.Id;
	}

	@AuraEnabled
	public static Boolean registrationWithNewAccount(Account acc, Contact con){
		Boolean success = OneId_RegistrationProcessController.registration(acc,con, 'ISSP', new Map<String, String>(), true);

		if(!success){
			return false;
		}

		try{
			Contact updatedContact = [SELECT Id, Name, Email, AccountId, Account.TradeName__c, Account.Legal_name__c, Account.Billing_Address_formated__c, Account.Phone, Account.Sector__c, Account.Category__c FROM Contact WHERE Id =: con.Id];

			sendEmailNotification(updatedContact);
		}
		catch(Exception e){
			return false;
		}
		return true;
	}

	@AuraEnabled
	public static Boolean registrationWithExistingAccount(Account acc, Contact con){
		try{
			Account acc2 = [SELECT Id, RecordType.DeveloperName, Sector__c, Category__c, IsPartner FROM Account WHERE Id =: acc.Id];
			
			// Ensure that the existing account is a partner account
			if(!acc2.IsPartner){
				acc2.IsPartner = true;
				update acc2;
			}

			con.AccountId = acc2.Id;
			con.User_Portal_Status__c = 'Pending Approval';
			update con;

			OneId_RegistrationProcessController.updateUserProfile(con, acc2, false);

			OneId_RegistrationProcessController.addDefaultAppRights(con.Id, null);
			
			ISSP_CreateNotification.SendEmailToPortalAdminNewContact(new List<Contact>{con});

			return true;
		}
		catch(Exception e){
			System.debug(e);
			return false;
		}
	}

	public static string sendEmailNotification(Contact contact){
		String errorMessage = '';

		List<GCS_Customer_Type_For_Registration__mdt> customerTypeList = [Select Send_Email_Notification__c from GCS_Customer_Type_For_Registration__mdt
																		   where Type__c =: 'Category' and Created_Account_Sector__c =: contact.account.sector__c
																			 and Created_Account_Category__c =: contact.account.category__c and Send_Email_Notification__c =: true];
		if(!customerTypeList.isEmpty()) {
			try {
				EmailTemplate emailTemplate = [SELECT Id, Subject, HtmlValue, Body FROM EmailTemplate WHERE DeveloperName = :'CSP_New_Account_Notification' Limit 1];

				List<Messaging.SendEmailResult> listEmailResult = null;
				List<Messaging.SingleEmailmessage> listSingleEmailMessages = new List<Messaging.SingleEmailmessage>();

				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				OrgWideEmailAddress orgWideEmail = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org' Limit 1];

				if (orgWideEmail != null) {
					mail.setOrgWideEmailAddressId(orgWideEmail.Id);
				} else {
					mail.setSenderDisplayName('IATA Noreply');
				}

				mail.toAddresses = new String[]{Label.CSP_New_Account_To_Address};
				mail.setReplyTo('noreply@iata.org');
				mail.setSubject(emailTemplate.Subject + ' ' + contact.account.TradeName__c + ' ' + system.today().day() + '-' + system.today().month() + '-' + system.today().year());

				//Map email fields
				Map<String, String> mapBodyParams = new map<String, String>{
						'{!accountUrl}' => URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' ) + '/' + contact.accountId,
						'{!contactName}' => contact.name,
						'{!contactEmail}' => contact.email,
						'{!tradeName}' => contact.account.TradeName__c,
						'{!legalName}' => contact.account.Legal_name__c,
						'{!address}' => contact.account.Billing_Address_formated__c,
						'{!phoneNumber}' => contact.account.Phone
				};

				String htmlBody = emailTemplate.HtmlValue;
				String plainBody = emailTemplate.Body;
				for (String key : mapBodyParams.keySet()) {
					if (htmlBody <> null && mapBodyParams <> null) {
						htmlBody = htmlBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
						plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
					}
				}

				if (htmlBody <> null) mail.setHtmlBody(htmlBody);

				mail.setSaveAsActivity(false);
				mail.setPlainTextBody(plainBody);
				listSingleEmailMessages.add(mail);

				if (!Test.isRunningTest()) listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
			} catch (Exception ex) {
				errorMessage = ex.getMessage();
			}
		}

		return errorMessage;
	}

	@AuraEnabled(cacheable=true)
	public static List<GCS_AccountCreation.CustomerTypePicklist> getCustomerTypePicklistsForL2(String leaf){
		List<GCS_AccountCreation.CustomerTypePicklist> picklists = new List<GCS_AccountCreation.CustomerTypePicklist>();

		String selectedItem;

		Boolean keepLooping = true;

		String currentCustomerType = leaf;
		String previousCustomerType = null;

		Map<String,GCS_CustomerType> customerTypeMap = GCS_CustomerType.getCustomerTypesMap();

		while(keepLooping){
			// Top level
			if(currentCustomerType == null){
				// need to retrieve the records without parents
				GCS_AccountCreation.CustomerTypePicklist picklist = new GCS_AccountCreation.CustomerTypePicklist(GCS_CustomerType.customLabels.get('Sector'));

				picklist.picklistOptions.add(new GCS_AccountCreation.CustomerTypePicklistOption(null, GCS_CustomerType.customLabels.get('Select'), previousCustomerType == null));

				for(GCS_CustomerType child : GCS_CustomerType.getCustomerTypesList()){
					// For L2, we don't want the General Public sector
					if(child.metadataCustomerType.DeveloperName != 'General_Public_Sector'){
						picklist.picklistOptions.add(new GCS_AccountCreation.CustomerTypePicklistOption(child.metadataCustomerType.DeveloperName, child.label, child.metadataCustomerType.DeveloperName == previousCustomerType));
					}
				}

				picklists.add(picklist);

				keepLooping = false;
			}
			else {
				GCS_CustomerType customerType = customerTypeMap.get(currentCustomerType);

				if (!customerType.children.isEmpty()) {
					GCS_AccountCreation.CustomerTypePicklist picklist = new GCS_AccountCreation.CustomerTypePicklist(customerType.subCategorizationLabel);

					picklist.picklistOptions.add(new GCS_AccountCreation.CustomerTypePicklistOption(customerType.metadataCustomerType.DeveloperName, customerType.subCategorizationPlaceholder, previousCustomerType == null));

					for (GCS_CustomerType child : customerType.children) {
						picklist.picklistOptions.add(new GCS_AccountCreation.CustomerTypePicklistOption(child.metadataCustomerType.DeveloperName, child.label, child.metadataCustomerType.DeveloperName == previousCustomerType));
					}

					picklists.add(picklist);
				}

				previousCustomerType = currentCustomerType;
				currentCustomerType = customerType.parent != null ? customerType.parent.metadataCustomerType.DeveloperName : null;
			}
		}

		List<GCS_AccountCreation.CustomerTypePicklist> orderedPicklists = new List<GCS_AccountCreation.CustomerTypePicklist>();

		for(Integer i = picklists.size()- 1 ; i >= 0; i--){
			orderedPicklists.add(picklists[i]);
		}

		return orderedPicklists;
	}

	@AuraEnabled
	public static List<OneId_AddressDoctor.AddressInfo> checkAddress(String info) {
		return OneId_AddressDoctor.validate((OneId_AddressDoctor.AddressInfo)JSON.deserialize(info, OneId_AddressDoctor.AddressInfo.class));
	}
}
