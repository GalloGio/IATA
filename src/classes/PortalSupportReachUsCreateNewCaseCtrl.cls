public with sharing class PortalSupportReachUsCreateNewCaseCtrl {

private final static Integer MAX_RESULTS = 20;

private static User USER = DAL_ISSP.getUser(Userinfo.getUserId());
private static Contact CONTACT = DAL_ISSP.getContact(DAL_ISSP.getUser(Userinfo.getUserId()).ContactId);

//Searches accounts on user input on the IATA Codes field. MAX RESULTS set to 100 as a Limit for the search (let's NOT destroy salesforce)
@AuraEnabled(Cacheable=true)
public static List<PortalLookupSearchResult> searchAccounts(String searchTerm) {
	// Prepare results
	List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();

	// Extract Accounts & convert them into PortalLookupSearchResult (check this class for more info)
	String accountIcon = 'standard:account';
	for (Account account : searchRelatedAccounts(searchTerm)) {
		if(account.BillingCity == null) {
			PortalLookupSearchResult res = new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account');
			Map<String,String> extraFields = new Map<String,String>();
			extraFields.put('iataCode',account.Site);
			res.setExtraFields(extraFields);
			results.add(res);
		}else{
			PortalLookupSearchResult res = new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ account.BillingCity);
			Map<String,String> extraFields = new Map<String,String>();
			extraFields.put('iataCode',account.Site);
			res.setExtraFields(extraFields);
			results.add(res);
		}
	}

	return results;
}
private static Account getAccount(){
	
	Account currentAccount = [
		Select id, Name, IATAcode__c,
		ParentId,
		Parent.ParentId,
		Parent.Parent.ParentId,
		Parent.Parent.Parent.ParentId,
		Parent.Parent.Parent.Parent.ParentId
		From Account
		Where id = :USER.Contact.AccountId
	];
	return currentAccount;
}


private static String getParentId(){
	Account currentAccount = getAccount();

	// find the top parent
		string parentId = null;
		if (currentAccount.ParentId == null ) {
			parentId = currentAccount.Id;
		} else if (currentAccount.Parent.ParentId == null) {
			parentId = currentAccount.ParentId;
		} else if (currentAccount.Parent.Parent.ParentId == null) {
			parentId = currentAccount.Parent.ParentId;
		} else if (currentAccount.Parent.Parent.Parent.ParentId == null ) {
			parentId = currentAccount.Parent.Parent.ParentId;
		} else if (currentAccount.Parent.Parent.Parent.Parent.ParentId == null ) {
			parentId = currentAccount.Parent.Parent.Parent.ParentId;
		} else {
			parentId = currentAccount.Parent.Parent.Parent.Parent.ParentId;
		}
	return parentId;

}
//Dynamic Query to perform searches on the Account.
private static List<Account> searchRelatedAccounts(String searchTerm) {
//prepare query

	String parentId = getParentId();
	Account currentAccount = getAccount();


	String finalQuery = 'SELECT ID, IATAcode__c, Name, Site, BillingCity FROM Account '
						+ 'WHERE IATAcode__c != null ';

	finalQuery +=
		' AND (Id = \'' + parentId
		+ '\' OR ParentId = \'' + parentId
		+ '\' OR Parent.ParentId = \'' + parentId
		+ '\' OR Parent.Parent.ParentId = \'' + parentId
		+ '\' OR Parent.Parent.Parent.ParentId = \'' + parentId
		+ '\' OR Parent.Parent.Parent.Parent.ParentId = \'' + parentId + '\')';

	if(searchTerm != null) {
		finalQuery +=
			' AND ( IATAcode__c LIKE  \'%' + searchTerm
			+ '%\' OR BillingCity LIKE \'%' + searchTerm
			+ '%\' OR Name LIKE \'%' + searchTerm
			+ '%\') ';
	}

	finalQuery += ' LIMIT ' + MAX_RESULTS;

	List<Account> reorderedCodes = new List<Account>();
	List<Account> allCodes = DAL_WithoutSharing.getRelatedAccounts(finalQuery);

	//place user's Iata code as first element in the list
	if(!allCodes.isEmpty()) {
		for(Account act : allCodes) {
			if(act.id == currentAccount.id && !reorderedCodes.isEmpty()) {
				reorderedCodes.add(0,act);
			}else{
				reorderedCodes.add(act);
			}
		}
	}

	return reorderedCodes;

}

//Searches contacts on user input on the Email Recipient field.
@AuraEnabled(Cacheable=true)
public static List<PortalLookupSearchResult> searchContacts(String searchTerm) {
	// Prepare results
	List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();

	// Extract Contacts & convert them into PortalLookupSearchResult (check this class for more info)
	String contactIcon = 'standard:contact';
	for (Contact contact : searchRelatedContacts(searchTerm)) {
		results.add(new PortalLookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Name, contact.Email));
	}

	return results;
}
//Dynamic Query to perform searches on the Contact.
private static List<Contact> searchRelatedContacts(String searchTerm) {
	Account currentAccount = getAccount();
	String parentId = getParentId();
	//prepare query
	String finalQuery = 'SELECT Id, Name, Email FROM Contact WHERE Email != \'' + CONTACT.Email + '\' AND User_Portal_Status__c in (\'Approved Admin\',\'Approved User\') ';

	if(String.isNotEmpty(searchTerm)) {
		finalQuery += ' AND (Email LIKE \'%' + String.escapeSingleQuotes(searchTerm) + '%\' OR Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') AND Status__c = \'Active\' AND (NOT Email LIKE \'%.inactive%\')';
	} else {
		finalQuery += 'AND Status__c = \'Active\' AND (NOT Email LIKE \'%.inactive%\')';
	}
	finalQuery += ' AND (AccountId = \'' + currentAccount.Id + '\' OR Account.ParentId = \'' + parentId + '\')';
	finalQuery += ' LIMIT ' + MAX_RESULTS;
	List<Contact> allContacts = DAL_WithoutSharing.getRelatedContacts(finalQuery);
	return allContacts;

}

//grabs the user profile name
@AuraEnabled(Cacheable=true)
public static String getProfile() {
	return USER.Profile.Name;
}

//grabs the user profile name
@AuraEnabled(Cacheable=true)
public static Contact getContact() {
	return CONTACT;
}

//Creates a Case once the user reaches the page and sends it over to the JS for further editting.
@AuraEnabled(Cacheable=true)
public static Case createCase(String countryiso, Boolean isConcernCase, String topic) {
	Case newCase = new Case();
	Map<String,String> recordTypeCountry = PortalSupportReachUsCtrl.getCaseTypeAndCountry(CONTACT, countryiso.toUpperCase());
	topic = topic + '__c';

	if(countryiso == null || countryiso == '') {
		newCase.IFAP_Country_ISO__c = CONTACT.Account.Country_ISO_Code__c;
		countryiso = CONTACT.Account.Country_ISO_Code__c;
	}else{ 
		newCase.IFAP_Country_ISO__c = countryiso;
	}

	if(recordTypeCountry != null) {
		
		//fetch recordtype
		ISSP_FAQ2Case_Record_Type__c rtSelected = setRecordType('%' + countryiso.toUpperCase() + '%', topic, isConcernCase);
		
		if(rtSelected != null){ 
			newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', rtSelected.recordtype__C);
		}
		
		newCase.Region__c = recordTypeCountry.get('Region');
		newCase.BSPCountry__c = recordTypeCountry.get('Country') == null ? '' : recordTypeCountry.get('Country');
		newCase.Country_concerned_by_the_query__c = recordTypeCountry.get('Country') == null ? '' : recordTypeCountry.get('Country');
	}else{
		throw new System.AuraHandledException('Error. No Record Type detected. Case cannot be created');
	}

	newCase.Status = 'Open';
	newCase.CaseArea__c = 'Customer Portal';
	newCase.Origin = 'Portal';



	return newCase;

}

@AuraEnabled(cacheable=true)
public static Case createCaseTreasuryDashboard(String recordTypeId) {

	Case newCase = new Case();

	newCase.RecordTypeId = recordTypeId;
	newCase.Status = 'Open';
	newCase.CaseArea__c = 'Customer Portal';
	newCase.Origin = 'Portal';

	return newCase;

}

//Inserts the Case. But sets a savepoint in case the Emails do not exist.
@AuraEnabled
public static Case insertCase(Case caseToInsert, List<String> recipientsToAdd) {
	try{
		insert caseToInsert;

		if(!recipientsToAdd.isEmpty()) {

			Set<String> setRecipients = new Set<String>(recipientsToAdd);

			list<Contact> listContact = [SELECT Id, Email FROM Contact WHERE Email IN :setRecipients];

			createCaseTeamMemberList(caseToInsert, listContact);

			caseToInsert.E2CP__AdditionalCC__c = String.join(recipientsToAdd, ',');

			update caseToInsert;

		}
	}
	catch(DmlException e) {
		throw new AuraHandledException(e.getMessage());
	}
	return [SELECT Id, CaseNumber FROM Case WHERE id =: caseToInsert.Id LIMIT 1];
}

private static ISSP_FAQ2Case_Record_Type__c setRecordType (String country, String topic, Boolean isComplaint){

	Map<String, ISSP_FAQ2Case_Record_Type__c> mapRecordType = new Map<String, ISSP_FAQ2Case_Record_Type__c>();
	ISSP_FAQ2Case_Record_Type__c finalRecordType = new ISSP_FAQ2Case_Record_Type__c();
	List<ISSP_FAQ2Case_Record_Type__c> lstRecordType = [SELECT RecordType__c, OwnerId__c,Topic__c,SubTopic__c,Complaint__c,Country_concerned_by_the_query__c,
														Country_concerned_by_the_query2__c, Country_concerned_by_the_query3__c,Flag_Assignment_Rules__c
														FROM ISSP_FAQ2Case_Record_Type__c
														WHERE Complaint__c =: isComplaint
																				AND ( Country_concerned_by_the_query__c like: country
																					OR Country_concerned_by_the_query2__c like: country
																					OR Country_concerned_by_the_query3__c like: country)];
	for(ISSP_FAQ2Case_Record_Type__c rt : lstRecordType){
		
		String keymap=((rt.Topic__c==null?'': rt.Topic__c)+'#');
		mapRecordType.put(keymap, rt);
		
	}

	if(mapRecordType.containsKey(topic + '#')) {
		finalRecordType=mapRecordType.get(topic + '#');
		return finalRecordType;
	}
	else{
		return mapRecordType.get('#');
	}
	
}

//Creates a CaseTeamMember with the contacts (related to the emails of course)
private static void createCaseTeamMemberList(Case cse, list<Contact> listContact) {
	list<CaseTeamMember > listCaseTeam = new list<CaseTeamMember>();
	list<String> listEmail = new list<String>();
	String IdTeamRole = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role' LIMIT 1].Id;
	set<string> emailAddressesLst = new set<string>();
	map<string, Contact> mapContacts = new map<string, Contact>();

	for (Contact contact: listContact) {
		mapContacts.put(contact.Email, contact);
		emailAddressesLst.add(contact.Email);
		listCaseTeam.add(new CaseTeamMember(
					 ParentId = cse.Id,
					 MemberId = contact.Id,
					 TeamRoleId = IdTeamRole
					 ));
		listEmail.add(contact.Email);
	}
	if(!emailAddressesLst.isEmpty()){
		wrapFilterContactsAndUsers listContactAndUsers = new wrapFilterContactsAndUsers(emailAddressesLst, mapContacts);
		sendEmailToAdditionalRecipients(listContactAndUsers, cse);
	}
	insert listCaseTeam;
}


// Send a notification email to users or contacts added on the podotal contact us page.
public static void sendEmailToAdditionalRecipients(wrapFilterContactsAndUsers listContacts, Case cse) {
	List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
	Map<String, Id> emailTemplateByDevName = new Map<String, Id>();
	for(EmailTemplate em: [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName = 'IATA_CS_Portal_Case_Addittional_Rec_CC' OR DeveloperName = 'IATA_CS_Portal_Case_Addittional_Rec_Us']){
		emailTemplateByDevName.put(em.DeveloperName, em.Id);
	}
	OrgWideEmailAddress orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = : Label.ISSP_CaseCommentEmail];

	try {
		for (ID userId : listContacts.setTargetObjectIdUsers) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(orgAddress.Id);
			mail.setTargetObjectId(userId);
			mail.setSaveAsActivity(false);
			mail.setTemplateId(emailTemplateByDevName.get('IATA_CS_Portal_Case_Addittional_Rec_Us'));
			mail.setWhatId(cse.Id);
			emailsToSend.add(mail);
		}
		if(!emailsToSend.isEmpty()){
			if (!Test.isRunningTest() ) Messaging.sendEmail(emailsToSend);
		}
		emailsToSend = new List<Messaging.SingleEmailMessage>();
		for (String cc : listContacts.setToAddressesContacts) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(orgAddress.Id);
			mail.setTargetObjectId(cc);
			mail.setToAddresses(listContacts.setToAddressesContacts) ;
			mail.setTemplateId(emailTemplateByDevName.get('IATA_CS_Portal_Case_Addittional_Rec_CC'));
			mail.setWhatId(cse.Id);
			emailsToSend.add(mail);
		}
		if(!emailsToSend.isEmpty()){
			if (!Test.isRunningTest() ) Messaging.sendEmail(emailsToSend);
		}


	} catch (Exception  e) {
		TransformationHelper.sendEmailSupport( 'PortalSupportReachUsCreateNewCaseCtrl sendEmailUsers() Exception', 'Exception: ' + e + ' || StackTrace: ' + e.getStackTraceString());
	}

}

//This wrapper aims to validate whether an email has a user or just a contact.
//If you have a user, the email will be sent to that same user, making that email not count towards the limits.
//If there is no user, send it to the contact
public without sharing class wrapFilterContactsAndUsers {
	public List<Id> setTargetObjectIdUsers {get; set;}
	public List<String> setToAddressesContacts {get; set;}

	public wrapFilterContactsAndUsers(set<string> emailAddressesLst, map<string, Contact> mapContacts) {
		this.setTargetObjectIdUsers = new List<Id>();
		this.setToAddressesContacts = new List<String>();
		map<string, user> mapUsers = new map<string, user>();
		List<User> usList = [SELECT Id, Email FROM User WHERE IsActive = true AND Email IN :emailAddressesLst];
		for(user u: usList){
			mapUsers.put(u.Email, u);
		}
		for(string sEmailAddr : emailAddressesLst){
			if(mapUsers.containsKey(sEmailAddr)){
				this.setTargetObjectIdUsers.add(mapUsers.get(sEmailAddr).id);
			}else{
				if(mapContacts.containsKey(sEmailAddr)){
					this.setToAddressesContacts.add(mapContacts.get(sEmailAddr).id);
				}
			}
		}
	}
}




	//Checks if user is a level 1 user (haven't completed level 2 registration)
	@AuraEnabled
	public static Boolean isUserLevelOne(Id userId){
		return  [SELECT Contact.Account.Is_General_Public_Account__c  FROM User WHERE Id = :userId].Contact.Account.Is_General_Public_Account__c;
	}
}
