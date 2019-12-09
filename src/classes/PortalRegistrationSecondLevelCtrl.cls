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
			PortalFAQsSharingCtrl.validateUserFAQsPermissions(UserInfo.getUserId());

			Contact updatedContact = [SELECT Id, Name, Email, AccountId, Account.TradeName__c, Account.Legal_name__c, Account.Billing_Address_formated__c, Account.Phone, Account.Sector__c, Account.Category__c FROM Contact WHERE Id =: con.Id];

			sendEmailNotification(updatedContact);
			//IFTP
			setIFTPUser(acc,con,false);
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

			PortalFAQsSharingCtrl.validateUserFAQsPermissions(UserInfo.getUserId());

			OneId_RegistrationProcessController.updateUserProfile(con, acc2, false);

			OneId_RegistrationProcessController.addDefaultAppRights(con.Id, null);

			ISSP_CreateNotification.SendEmailToPortalAdminNewContact(new List<Contact>{con});

			//IFTP
			setIFTPUser(acc,con,true);
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

	public static void setIFTPUser(Account acc, Contact con, Boolean bAccExist){
		/**
		IFTP Accounts - IFTP Service
		only for NEW Accounts
		*/

		acc = [SELECT Id, Name, Sector__c, Category__c FROM Account WHERE Id = :acc.Id];

		if(acc.Sector__c == 'Airline Supplier' && acc.Category__c == 'Fuel Supplier' ){

			String RECTYPE_ITP_AccContRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');
			String RECTYPE_ITP_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'IFTP');
			String RECTYPE_Others = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');

			Account_Roles__c accRoles = [SELECT id FROM Account_Roles__c
									WHERE Name = 'Airline Supplier - ITP' limit 1];

			Account_Role_Services__c accRoleSrvs = [SELECT id FROM Account_Role_Services__c
									WHERE Name = 'IFTP - ITP' limit 1];

			PermissionSet psAbsorb = [SELECT Id FROM PermissionSet WHERE Name = 'Absorb'];

			Portal_Applications__c pa = [SELECT id FROM Portal_Applications__c WHERE name = 'IFTP' limit 1];

			Account_Contact_Role__c accContRoleToInserted = new Account_Contact_Role__c();

			if(bAccExist == false){

				Account_Role__c accRole = new Account_Role__c();
				accRole.Account__c = acc.Id;
				accRole.Account_Roles__c = accRoles.id;
				accRole.RecordTypeId = RECTYPE_ITP_AccRole;
				insert accRole;

				Account_Role_Service__c accRoleSrv = new Account_Role_Service__c();
				accRoleSrv.Account_Role__c = accRole.id;
				accRoleSrv.Account_Role_Services__c = accRoleSrvs.id;
				insert accRoleSrv;

				Account_Contact_Role__c accContRoleToInsert = new Account_Contact_Role__c();
				accContRoleToInsert.Service_Rendered__c = 'IFTP';
				accContRoleToInsert.Status__c = 'Active';
				accContRoleToInsert.RecordTypeId = RECTYPE_ITP_AccContRole;
				accContRoleToInsert.Account_Role__c = accRole.Id;
				accContRoleToInsert.Contact_Role__c = 'ITP Administrator';
				accContRoleToInsert.Details__c = '';
				accContRoleToInsert.Contact__c = con.Id;
				insert accContRoleToInsert;

				accContRoleToInserted.Id = accContRoleToInsert.Id;

			}else{
				Account_Role__c accRole = [SELECT id FROM Account_Role__c WHERE account__c = :acc.id AND recordtypeid = :RECTYPE_ITP_AccRole limit 1];

				Account_Contact_Role__c accContRoleToInsert = new Account_Contact_Role__c();
				accContRoleToInsert.Service_Rendered__c = 'IFTP';
				accContRoleToInsert.Status__c = 'Active';
				accContRoleToInsert.RecordTypeId = RECTYPE_ITP_AccContRole;
				accContRoleToInsert.Account_Role__c = accRole.Id;
				accContRoleToInsert.Contact_Role__c = 'ITP Training Coordinator';
				accContRoleToInsert.Details__c = '';
				accContRoleToInsert.Contact__c = con.Id;
				insert accContRoleToInsert;

				accContRoleToInserted.Id = accContRoleToInsert.Id;

			}

			Portal_Application_Right__c portalApplicationRight = new Portal_Application_Right__c(
					Portal_Application__c = pa.id,
					Right__c = 'Access Requested',
					Contact__c = con.Id,
					Favourite_Service__c = true
				);
				insert portalApplicationRight;

			accContRoleToInserted = [SELECT Id,Name, Company_Code__c FROM Account_Contact_Role__c WHERE id = :accContRoleToInserted.Id LIMIT 1];

			String newEmployeeCode = 'TC-' + accContRoleToInserted.Name.split('-').get(1).replaceFirst('^0+','');
			accContRoleToInserted.Company_Code__c = newEmployeeCode;

			update accContRoleToInserted;

			User cont = [SELECT id, contact.FirstName, contact.LastName, contact.account.name FROM User WHERE ContactId = :con.Id LIMIT 1];

			List<IFTP_History__c> IftpHistoryRecordsToBeInserted = new List<IFTP_History__c>();
			IFTP_History__c ihrec = portalIftpHistoryManagement.createIftpHistoryRecord(portalIftpHistoryManagement.Employee_Start_Working_for_ITP,
																accContRoleToInserted.Company_Code__c,
																cont.contact.account.name,
																cont.contact.FirstName,
																cont.contact.LastName);
			IftpHistoryRecordsToBeInserted.add(ihrec);

			if(IftpHistoryRecordsToBeInserted.size() > 0){
				portalIftpHistoryManagement.insertIntoIftpHistory(IftpHistoryRecordsToBeInserted);
			}

			updatePortalUseProfile(cont.id,'ISS Portal (Partner)');
			assignPermissionSet(psAbsorb.Id, cont.id);
		}
	}

	@future
	public static void updatePortalUseProfile(String userId, String sProfile){
		Profile isspAgentUser = [SELECT Id FROM Profile WHERE Name = :sProfile];
		update new User(Id = userId, ProfileId = isspAgentUser.Id);
	}

	@future
	private static void assignPermissionSet(Id absorbId, Id userId){
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = absorbId, AssigneeId = userId);

		insert psa;
	}

}
