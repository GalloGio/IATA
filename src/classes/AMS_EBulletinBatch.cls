global class AMS_EBulletinBatch implements Database.Batchable<sObject> {
	
	String query;
	public final String typeEBulletin;	
	public final Set<String> ccNamesToRecover;

	global AMS_EBulletinBatch(String typeEBulletin,Set <String> ccNamesToRecover) {
		this.ccNamesToRecover = ccNamesToRecover;
		this.typeEBulletin = typeEBulletin;
		
		this.query = 'select id,NAME,CountriesList__c,RecordType.Name,Area_1__c,Area_2__c,Area_3__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c from AMS_eBulletin_Profile__c where recordType.name = :typeEBulletin and Opt_out_Bulletin__c = TRUE';
		
		system.debug(loggingLevel.Debug,'typeEBulletin: ' + typeEBulletin);
		system.debug(loggingLevel.Debug,'ccNamesToRecover: ' + ccNamesToRecover);	
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<AMS_eBulletin_Profile__c> scope) {
		
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

		system.debug(loggingLevel.Debug,'scope: ' + scope);

		for(AMS_eBulletin_Profile__c eBprof : scope){
			
			AMS_EBulletinReportWebservice.AMSEBulletinFilters filters = new AMS_EBulletinReportWebservice.AMSEBulletinFilters(eBprof, date.today() - 365 , date.today() );

			//run the eBulletinReport
			
			//AMS_EBulletinReportWebservice.generateEBulletinReport( eBprof );
			
			system.debug(loggingLevel.Debug,'ccNamesToRecover: ' + ccNamesToRecover);

			Integer count = [SELECT count() FROM Agency_Applied_Change_code__c 
								WHERE Change_Code__c IN :ccNamesToRecover 
									and Published_on_EBulletin__c = TRUE 
									and Account__r.IATA_ISO_Country__r.ISO_Code__c IN :filters.countriesList 
									and Account__r.Location_Class__c IN :filters.programsList
									and CreatedDate > :filters.fromCCDate  and CreatedDate < :filters.toCCDate ];

			system.debug(loggingLevel.Debug,'Change Codes count: ' + count);

			if(count > 0)
			{
				//TODO Create an Email template
            	mailsToSend.add(setEmailContents());

			}
		}

		if(!Test.isRunningTest())  Messaging.sendEmail(mailsToSend);

	}
	
	global void finish(Database.BatchableContext BC) {
		
		//FINISH
	}

	private Messaging.SingleEmailMessage setEmailContents()
	{
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.saveAsActivity = false;
    	mail.setToAddresses(new List<String>{'diogo.roxo@b-i.com'});
    	// Step 3: Set who the email is sent from
			mail.setReplyTo('amsDiogo@Salesforce.com');
	    mail.setSenderDisplayName('EBulletin');

	    
	    // Step 4. Set email contents - you can use variables!
	    mail.setSubject('EBulletin Notification');
	    String body = 'Dear Mr / Mrs , there has been an occurrence within your selection criteria. Please access the Portal <link> for further details.>';
	    mail.setHtmlBody(body);

		return mail;
	}
	
}