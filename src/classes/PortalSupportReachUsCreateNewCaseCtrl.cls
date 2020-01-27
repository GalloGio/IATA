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
			results.add(new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account'));
		}else{
			results.add(new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ account.BillingCity));
		}
	}

	return results;
}

//Dynamic Query to perform searches on the Account.
private static List<Account> searchRelatedAccounts(String searchTerm) {
//prepare query

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

// find the top parent
	Id parentId = null;
	if (currentAccount.ParentId == null || currentAccount.ParentId =='' ) {
		parentId = currentAccount.Id;
	} else if (currentAccount.Parent.ParentId == null || currentAccount.Parent.ParentId =='') {
		parentId = currentAccount.ParentId;
	} else if (currentAccount.Parent.Parent.ParentId == null || currentAccount.Parent.Parent.ParentId =='') {
		parentId = currentAccount.Parent.ParentId;
	} else if (currentAccount.Parent.Parent.Parent.ParentId == null || currentAccount.Parent.Parent.Parent.ParentId =='') {
		parentId = currentAccount.Parent.Parent.ParentId;
	} else if (currentAccount.Parent.Parent.Parent.Parent.ParentId == null || currentAccount.Parent.Parent.Parent.Parent.ParentId =='') {
		parentId = currentAccount.Parent.Parent.Parent.ParentId;
	} else {
		parentId = currentAccount.Parent.Parent.Parent.Parent.ParentId;
	}


	String finalQuery = 'SELECT ID, IATAcode__c, Name, BillingCity FROM Account '
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
    
    List<Account> lstAccounts = searchRelatedAccounts('');
	// Prepare results
	List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();
	PortalSupportReachUsCreateNewCaseCtrlWithoutSharing innObj = new PortalSupportReachUsCreateNewCaseCtrlWithoutSharing();

	// Extract Contacts & convert them into PortalLookupSearchResult (check this class for more info)
	String contactIcon = 'standard:contact';
	for (Contact contact : innObj.searchRelatedContacts(searchTerm, lstAccounts)) {
		results.add(new PortalLookupSearchResult(contact.Id, 'Contact', contactIcon, contact.Name, contact.Email));
	}

	return results;
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
public static Case createCase(String countryiso, Boolean isConcernCase, String topic, String subtopic) {
	Case newCase = new Case();
	Map<String,String> recordTypeCountry = PortalSupportReachUsCtrl.getCaseTypeAndCountry(CONTACT, countryiso.toUpperCase());
	topic = topic + '__c';
	subtopic = subtopic + '__c';

	if(countryiso == null || countryiso == '') {
		newCase.IFAP_Country_ISO__c = CONTACT.Account.Country_ISO_Code__c;
		countryiso = CONTACT.Account.Country_ISO_Code__c;
	}else{
		newCase.IFAP_Country_ISO__c = countryiso;
	}

	if(recordTypeCountry != null) {
		if(isConcernCase) {
			List<ISSP_FAQ2Case_Record_Type__c> complaintRecordType = setRecordType('%' + countryiso.toUpperCase() + '%', '%' + topic + '%', '%' + subtopic  + '%', true);
			newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', complaintRecordType[0].RecordType__c);
		}
		else{
			List<ISSP_FAQ2Case_Record_Type__c> caseRecordType = setRecordType('%' + countryiso.toUpperCase() + '%', '%' + topic  + '%', '%' + subtopic + '%', false);
			for(ISSP_FAQ2Case_Record_Type__c rt : caseRecordType) {
				if(rt.Topic__c == topic || rt.SubTopic__c == subtopic) {
					newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', rt.RecordType__c);
				}
			}
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

private static List<ISSP_FAQ2Case_Record_Type__c> setRecordType (String country, String topic, String subtopic, Boolean isComplaint){


	if(isComplaint) {

		Map<String, ISSP_FAQ2Case_Record_Type__c> mapRecordType = new Map<String, ISSP_FAQ2Case_Record_Type__c>();
		List<ISSP_FAQ2Case_Record_Type__c> finalRecordType = new  List<ISSP_FAQ2Case_Record_Type__c>();
		List<ISSP_FAQ2Case_Record_Type__c> lstRecordType = [SELECT RecordType__c, OwnerId__c,Topic__c,SubTopic__c,Complaint__c,Country_concerned_by_the_query__c,
		                                                    Country_concerned_by_the_query2__c, Country_concerned_by_the_query3__c,Flag_Assignment_Rules__c
		                                                    FROM ISSP_FAQ2Case_Record_Type__c
		                                                    WHERE Complaint__c =: isComplaint
		                                                                         AND ( Country_concerned_by_the_query__c like: country
		                                                                               OR Country_concerned_by_the_query2__c like: country
                                                                                       OR Country_concerned_by_the_query3__c like: country)];
        for(ISSP_FAQ2Case_Record_Type__c rt : lstRecordType)
        {
            if(rt.SubTopic__c != null && rt.SubTopic__c.contains(',')){
                List<String> lstSubtopic = rt.SubTopic__c.split(',');
                for(String subT : lstSubtopic){
                    mapRecordType.put(rt.Topic__c + '#' + subT, rt);
                }
            }else{
				String keymap=(rt.Topic__c==null?'': rt.Topic__c)+'#'+(rt.SubTopic__c==null?'': rt.SubTopic__c);
				mapRecordType.put(keymap, rt);
            }
        }

		if(mapRecordType.containsKey(topic + '#' + subtopic)) {
			finalRecordType.add(mapRecordType.get(topic + '#' + subtopic));
			return finalRecordType;
		}
		else if(mapRecordType.containsKey(topic + '#')) {
			finalRecordType.add(mapRecordType.get(topic + '#'));
			return finalRecordType;
		}
		else{
			finalRecordType.add(mapRecordType.get('#'));
			return finalRecordType;
		}

	}else{

		return [SELECT RecordType__c, OwnerId__c,Topic__c,SubTopic__c,Complaint__c,Country_concerned_by_the_query__c,
		        Country_concerned_by_the_query2__c, Country_concerned_by_the_query3__c, Flag_Assignment_Rules__c
		        FROM ISSP_FAQ2Case_Record_Type__c
		        WHERE  (Topic__c =: topic
		                           OR SubTopic__c = : subtopic
		                                            OR Country_concerned_by_the_query__c like: country
		                                            OR Country_concerned_by_the_query2__c like: country
		                                            OR Country_concerned_by_the_query3__c like: country)];
	}
}

//Creates a CaseTeamMember with the contacts (related to the emails of course)
private static void createCaseTeamMemberList(Case cse, list<Contact> listContact) {
	list<CaseTeamMember > listCaseTeam = new list<CaseTeamMember>();
	list<String> listEmail = new list<String>();
	String IdTeamRole = [SELECT id FROM CaseTeamRole WHERE Name = 'Partner User Role' LIMIT 1].Id;
	for (Contact contact: listContact) {

		listCaseTeam.add(new CaseTeamMember(
					 ParentId = cse.Id,
					 MemberId = contact.Id,
					 TeamRoleId = IdTeamRole
					 ));
		listEmail.add(contact.Email);
	}
	insert listCaseTeam;
}

	//Checks if user is a level 1 user (haven't completed level 2 registration)
	@AuraEnabled
	public static Boolean isUserLevelOne(Id userId){
		return  [SELECT Contact.Account.Is_General_Public_Account__c  FROM User WHERE Id = :userId].Contact.Account.Is_General_Public_Account__c;
public without sharing class PortalSupportReachUsCreateNewCaseCtrlWithoutSharing {

	//Dynamic Query to perform searches on the Contact.
public List<Contact> searchRelatedContacts(String searchTerm, List<Account> lstAccounts) { 

	String userId = UserInfo.getUserId();

	//String parentId = [SELECT ParentId FROM Account WHERE Id =: userId].ParentId;
	
    Set<Id> resultIds = (new Map<Id,Account>(lstAccounts)).keySet();

	//prepare query
	String finalQuery = 'SELECT Id, Name, Email FROM Contact '
	                     + ' WHERE AccountId IN :resultIds ';

	if(String.isNotEmpty(searchTerm)) {
		finalQuery += ' AND (Email LIKE \'%' + String.escapeSingleQuotes(searchTerm)
		              + '%\' OR Name like \'%' + String.escapeSingleQuotes(searchTerm) + '%\') ';
	}

	//finalQuery += ' LIMIT ' + MAX_RESULTS;

	return Database.query(finalQuery);

}

}

}