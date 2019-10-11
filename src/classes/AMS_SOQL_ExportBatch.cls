global class AMS_SOQL_ExportBatch implements Database.Batchable<sObject>,  Database.Stateful {

    global Map<Id, String> errorMap {get; set;}
    global AMS_SOQL_Query_Export__c exporter     {get;set;}
    global string               queryString  {get;set;}
    global list<string>         queryFields  {get;set;}
    global string               fileName     {get;set;}
    global string               finalstr     {get;set;}
    global string               recordString {get;set;}
    
    global AMS_SOQL_ExportBatch(String purgeType) 
    {
        //Because the fields of the exporter object are not refernced on the visualforce page we need to explicity tell the controller
        //to include them. Instead of hard coding in the names of the fields I want to reference, I simply describe the exporter object
        //and use the keyset of the fieldMap to include all the existing fields of the exporter object.
        
        //describe object
        System.debug('purgeType:: '+ purgeType);
        exporter = [SELECT Id, Name, fields__c, Limit__c, object_name__c, Order_by__c, Order_Direction__c, where_condition__c FROM AMS_SOQL_Query_Export__c WHERE Name =: purgeType LIMIT 1];

        if(exporter != null) {
            System.debug('exporter:: '+ exporter);
            //create a filename for this exported file
            fileName = exporter.name + ' ' + string.valueOf(dateTime.now());
            queryFields =  exporter.fields__c.split(',');
            finalstr =  exporter.fields__c + '\n';      
            //get the proper SOQL order direction from the order direction on the exporter object (Ascending = asc, Descending = desc)
            string orderDirection = exporter.Order_Direction__c == 'Ascending' ? 'asc' : 'desc';
            
            //create the query string using string appending and some ternary logic
            queryString = 'select ' + exporter.fields__c + ' from ' + exporter.object_name__c;
            queryString += exporter.where_condition__c != null ? ' where ' + exporter.where_condition__c : '';
            queryString += exporter.Order_by__c != null ? ' order by ' + exporter.Order_by__c + ' ' + orderDirection :'';
            queryString += exporter.Limit__c != null ? ' limit ' +string.valueOf(exporter.Limit__c) : '';
        }
    }

    global Database.QueryLocator start(Database.BatchableContext BC) {
        System.debug('queryString:: '+ queryString);
        return Database.getQueryLocator(queryString);
    }

    global void execute(Database.BatchableContext BC, List<Account> scope) {
        //Send an email to the User after your batch completes
        System.debug('scope size:: '+ scope.size());
        System.debug('queryFields:: '+ queryFields);
        
        Map<String, Schema.SObjectField> AccFields = Schema.SObjectType.Account.fields.getMap();
        
		for(Account acc : scope){
            recordString = '"';
            for(String field : queryFields) {
                String accField = '' + acc.get(field);
                recordString += ((String.isNotBlank(accField) && accField != 'null') ? accField : '') + '","';
            }
            recordString = recordString.removeEnd('","') + '"\n';
            
            finalstr = finalstr + recordString;
		}
        
    }

    global void finish(Database.BatchableContext BC) {
        // Define the email
        System.debug('finalstr:: '+ finalstr);
        String body = 'Your batch job '
			+ 'Purge IATA Codes '
			+ 'has finished for Accounts. \n' 
			+ 'Please find the list attached to the Email.';
		String subject = 'Accounts list updated';
		Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 

		// Create the email attachment    
		Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
		efa.setFileName(fileName + '.csv');
        efa.setContentType('text/csv');
		efa.setBody(Blob.valueOf(finalstr));

		// Sets the paramaters of the email
		email.setSubject( subject );
		email.setToAddresses( new String[] {userInfo.getUserEmail()} );
		email.setPlainTextBody( body );
		email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

		if(!Test.isRunningTest()) {

			Messaging.SendEmailResult [] r = 
			Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   
		}
    }
}