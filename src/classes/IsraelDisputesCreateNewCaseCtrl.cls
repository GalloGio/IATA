public without sharing class IsraelDisputesCreateNewCaseCtrl {

	private final static Integer MAX_RESULTS = 20;

	private static User USER = DAL_ISSP.getUser(Userinfo.getUserId());

	@AuraEnabled(Cacheable=true)
	public static Boolean isBeforeFifteenth() {
		Datetime now = Datetime.now();
		Timezone tz = Timezone.getTimeZone('Asia/Jerusalem');
		Integer offset = tz.getOffset(now);
		Datetime israelTime = now.addSeconds(offset/1000);
		//the time is 01:00:01 and not 00:00:01 since the Datetime.valueOf method seems to detract an hour
		String fifteenthString = israelTime.year() + '-' + israelTime.month() + '-16 01:00:01';
		Datetime fifteenth = Datetime.valueOf(fifteenthString);
		return fifteenth > israelTime ? true : false;
	}

	//Searches accounts on user input on the IATA Codes field. MAX RESULTS set to 100 as a Limit for the search (let's NOT destroy salesforce)
	@AuraEnabled(Cacheable=true)
	public static List<PortalLookupSearchResult> searchAccounts(String searchTerm) {
		// Prepare results
		List<PortalLookupSearchResult> results = new List<PortalLookupSearchResult>();

		// Extract Accounts & convert them into PortalLookupSearchResult (check this class for more info)
		String accountIcon = 'standard:account';
		for (Account account : searchRelatedAccounts(searchTerm)) {
			PortalLookupSearchResult res = new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.Name + '', '(' + account.Airline_Designator__c + ' ' + account.Airline_Prefix__c + ')');
			Map<String,String> extraFields = new Map<String,String>();
			extraFields.put('airlineCode',account.Airline_Prefix__c);
			res.setExtraFields(extraFields);
			results.add(res);
		}

		return results;
	}
	
	private static List<Account> searchRelatedAccounts(String searchTerm) {
		//prepare query
		Account currentAccount = [
			Select id
			From Account
			Where id = :USER.Contact.AccountId
		];

		String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();

		String finalQuery = 'SELECT ID, Airline_Prefix__c, Name, Airline_Designator__c, Site FROM Account '
							+ 'WHERE RecordTypeId = \'' + recordTypeId + '\' ' 
							+ 'AND Sector__c = \'Airline\' '
							+ 'AND (Category__c = \'Passenger and Cargo\' OR Category__c = \'Passenger only\') '
							+ 'AND Membership_status__c = \'IATA Member\' '
							+ 'AND ACLI_Status__c = \'Active Company\'';

		if(searchTerm != null) {
			finalQuery +=
				' AND (Airline_Prefix__c LIKE  \'%' + searchTerm
				+ '%\' OR Airline_Designator__c LIKE \'%' + searchTerm
				+ '%\' OR Name LIKE \'%' + searchTerm
				+ '%\') ';
		}

		finalQuery += 'ORDER BY NAME LIMIT ' + MAX_RESULTS;

		List<Account> allAccts = DAL_WithoutSharing.getRelatedAccounts(finalQuery);

		return allAccts;

	}

	//Inserts the Case
	@AuraEnabled
	public static Case insertCase(Case caseToInsert, List<String> recipientsToAdd) {
		try{
			if(!recipientsToAdd.isEmpty()) {
				caseToInsert.E2CP__AdditionalCC__c = String.join(recipientsToAdd, ',');
			}
			insert caseToInsert;
		}
		catch(DmlException e) {
			throw new AuraHandledException(e.getMessage());
		}
		return [SELECT Id, CaseNumber FROM Case WHERE id =: caseToInsert.Id LIMIT 1];
	}

	@future
	public static void airlineEmailNotification(List<Id> cIdList) {
		List<Case> cList = [SELECT Id, Airline_E_mail__c, E2CP__AdditionalCC__c FROM Case WHERE Id =: cIdList];
		EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE Name = 'GCS Dispute Notification Agent Israel VF' LIMIT 1];
		OrgWideEmailAddress[] fromAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
		ISSP_CS__c customSetting = ISSP_CS__c.getValues('No Notification Email Contact Id');

		List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();

		for(Case aCase : cList){
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

			mail.setSaveAsActivity(false);
			mail.setTemplateId(template.Id);
			mail.setTargetObjectId(customSetting.Value__c);
			mail.setWhatId(aCase.Id);
			mail.setToAddresses(new String[] { aCase.Airline_E_mail__c });
			if(aCase.E2CP__AdditionalCC__c != null){
				List<String> items = aCase.E2CP__AdditionalCC__c.split('\\s*,\\s*');
				mail.setBccAddresses(items);
			}
			mail.setOrgWideEmailAddressId(fromAddress.get(0).Id);

			emails.add(mail);
		}
		Messaging.sendEmail(emails); 
	}
}
