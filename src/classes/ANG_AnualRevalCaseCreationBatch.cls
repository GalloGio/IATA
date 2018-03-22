global class ANG_AnualRevalCaseCreationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	
	global Set<Id> accountIds;

	global ANG_AnualRevalCaseCreationBatch(Set<Id> accountIdsIn) {
		
		List<String> fieldListAcct = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
					fieldListAcct.add(field);
		}

		List<String> fieldListContact = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapContacts = Contact.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapContacts.keySet()){
					fieldListContact.add(field);
		}

		this.query = 'SELECT '+ String.join(fieldListAcct, ', ') + ' , ( SELECT ' +String.join(fieldListContact, ', ') + ' FROM Contacts) FROM Account WHERE Id in:accountIds';

		this.accountIds = accountIdsIn;
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		Account acct = (Account) scope.get(0);

		System.debug('Creating Oscar for Reval process for account ' + acct.Id + '('+acct.IATACode__c+')');

		Id caseIdCreate = ANG_OscarProcessHelper.createRevalidationOscar(acct, acct.Contacts, true);

		System.debug('Case created with Id : ' + caseIdCreate );
	}
	
	global void finish(Database.BatchableContext BC) {
		
		// send an email to the user ?!
	}
	
}