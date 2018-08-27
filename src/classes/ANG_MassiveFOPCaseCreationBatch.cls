global class ANG_MassiveFOPCaseCreationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {
	
	String query;
	
	global Set<Id> accountIds;

	global List<ANG_ConversionHelper.ConversionBatchItem> resultItems;

	global List<String> fieldListContact;

	private String errorMessages;

	global ANG_MassiveFOPCaseCreationBatch(Set<Id> accountIdsIn) {
		errorMessages = '';
		resultItems = new List<ANG_ConversionHelper.ConversionBatchItem>();

		List<String> fieldListAcct = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapAccounts.keySet()){
			fieldListAcct.add(field);
		}

		fieldListContact = new List<String>();

		Map<String, Schema.SObjectField> schemaFieldMapContacts = Contact.sObjectType.getDescribe().fields.getMap();

		for (String field : schemaFieldMapContacts.keySet()){
			fieldListContact.add(field);
		}

		this.query = 'SELECT '+ String.join(fieldListAcct, ', ') + ' FROM Account WHERE Id in:accountIds';

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

			String queryContacts;

			if(acct.ParentId == null)
	            queryContacts = 'SELECT ' +String.join(fieldListContact, ', ') + ' FROM Contact where Email <> null AND Email <> \'\' AND Status__c = \'Active\' and accountId = \''+acct.Id+'\'';
			else
				queryContacts = 'SELECT ' +String.join(fieldListContact, ', ') + ' FROM Contact where Email <> null AND Email <> \'\' AND Status__c = \'Active\' and accountId in (\''+acct.Id+'\',\''+acct.ParentId+'\')';

        	System.debug('Query is:'+queryContacts);
        
			List<Contact> contacts = Database.query(queryContacts);

			if(contacts.isEmpty()){

				
				ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), true, 'No contacts were found in the Account Hierarchy.');

				resultItems.add(item);

				return;

			}
			System.debug('Creating Oscar for Manage Forms of Payment for account ' + acct.Id + '('+acct.IATACode__c+')');

			Id caseIdCreate = ANG_OscarProcessHelper.createPCIComplianceOscars(new List<Account>{acct}, new Map<Id,List<Contact>>{acct.Id => contacts}, new Set<Id>{acct.Id}).get(0).Id;

			System.debug('Case created with Id : ' + caseIdCreate );
			
			ANG_ConversionHelper.ConversionBatchItem item = new ANG_ConversionHelper.ConversionBatchItem(new ANG_ConversionHelper.HierarchyStructure(acct), 1, BC.getJobId(), false, null);
			resultItems.add(item);

		}catch(Exception e){
            System.debug('Exception processing account ' + acct.Id + ':' + e.getStackTraceString());
            
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
		mail.setSenderDisplayName('Apex Newgen Forms Of Payment  Module');
		mail.setSubject('Batch Processing '+a.Status);

		String toReturnBody = 'The Batch Apex job ('+BC.getJobId()+')processed  '+a.TotalJobItems+' batches.'+' Job Item processed are'+a.JobItemsProcessed+'\n\n';
		
		toReturnBody+= ':: Execution Summay ::'+'\n';
	
		toReturnBody+= ':: Errors Found ::'+'\n';

		for(ANG_ConversionHelper.ConversionBatchItem item:resultItems) 
			if(item.isError){
				toReturnBody+=item+'\n';
            	errorMessages = (String.isEmpty(errorMessages) ?  '[{"iataCode":"' + item.iataCode + '", "errorMessage":"' + item.errorMessage + '"}' : errorMessages + ', {"iataCode":"' + item.iataCode + '", "errorMessage":"' + item.errorMessage + '"}');         
            }
		
		toReturnBody+= '\n\n';
		toReturnBody+= ':: Accounts Processed ::'+'\n'; 

		for(ANG_ConversionHelper.ConversionBatchItem item:resultItems)
			if(!item.isError)
				toReturnBody+=item+'\n';

		mail.setPlainTextBody(toReturnBody);
		if(!String.isEmpty(errorMessages)) EventBus.publish(new Batch_Notification__e(Batch_id__c = BC.getJobId(), message__c = errorMessages + ']'));
		
		 if(Test.isRunningTest()){
		 	return;
		 }

		Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});

	}
	
}