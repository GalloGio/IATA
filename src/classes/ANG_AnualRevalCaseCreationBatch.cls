global class ANG_AnualRevalCaseCreationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	
	global Set<Id> accountIds;

	global List<ANG_ConversionHelper.ConversionBatchItem> resultItems;


	global ANG_AnualRevalCaseCreationBatch(Set<Id> accountIdsIn) {
		
		resultItems = new List<ANG_ConversionHelper.ConversionBatchItem>();

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

		System.SavePoint sp;

		Account acct = (Account) scope.get(0);

		try{
	
			sp = Database.setSavePoint();

			System.debug('Creating Oscar for Reval process for account ' + acct.Id + '('+acct.IATACode__c+')');

			Id caseIdCreate = ANG_OscarProcessHelper.createRevalidationOscar(acct, acct.Contacts, true);

			System.debug('Case created with Id : ' + caseIdCreate );
			
			//resultItems.add(acct.IATACode__c + ' - Success:'+caseIdCreate);
			
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), false, null);
			resultItems.add(item);

		}catch(Exception e){
			
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), true, e.getMessage());

			System.debug(item);resultItems.add(item);Database.rollback(sp);//throw e;

			//Database.rollback(sp);resultItems.add(acct.IATACode__c + ' - Error:' + e.getMessage());throw e;
		}
	}
	
	global void finish(Database.BatchableContext BC) {
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		//Below code will fetch the job Id
		AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];

		String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = : userName limit 1];
		String userEmail = activeUser.Email;

		//below code will send an email to User about the status
		mail.setToAddresses( new String[] {userEmail} );
		mail.setSenderDisplayName('Apex Newgen Anual Revalidation Module');
		mail.setSubject('Batch Processing '+a.Status);

		String toReturnBody = 'The Batch Apex job ('+BC.getJobId()+')processed  '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are'+a.JobItemsProcessed+'\n\n';
		
		toReturnBody+= ':: Execution Summay ::'+'\n';
	
		toReturnBody+= ':: Errors Found ::'+'\n';

		for(ANG_ConversionHelper.ConversionBatchItem item:resultItems) 
			if(item.isError)
				toReturnBody+=item+'\n';
		
		toReturnBody+= '\n\n';
		toReturnBody+= ':: Accounts Processed ::'+'\n';

		for(ANG_ConversionHelper.ConversionBatchItem item:resultItems)
			if(!item.isError)
				toReturnBody+=item+'\n';

		mail.setPlainTextBody(toReturnBody);

		 if(Test.isRunningTest()){
		 	return;
		 }

		Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});
	}
	
}