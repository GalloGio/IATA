global class AMS_EBulletinBatch implements Database.Batchable<sObject> {
	
	String query;
	public final String typeEBulletin;	
	public String networkComponent = '';
	EmailTemplate emailTemplate; 

	global AMS_EBulletinBatch(String typeEBulletin) {
		this.typeEBulletin = typeEBulletin;

		//String fieldsToRecover  = 'id,Last_Run__c,User__r.email,RecordTypeId,Name,CountriesList__c,RecordType.Name,Area_1__c,Area_2__c,Area_3__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c';
		
		//String filters = 'where recordType.name = :typeEBulletin and Opt_out_Bulletin__c = FALSE and Opt_in__c = TRUE ';

		//this.query = 'select ' + fieldsToRecover + ' from AMS_eBulletin_Profile__c ' + filters;
		

		this.query = AMS_QueryUtils.getAllFieldQuery('AMS_eBulletin_Profile__c',new List<String>{'User__r.email','User__r.name'},
										'recordType.name = :typeEBulletin and Opt_out_Bulletin__c = FALSE and Opt_in__c = TRUE', 
										FALSE);

		
		system.debug('this.query: ' + this.query);	
		
		List<Network> myCommunity = new List<Network>([SELECT Id FROM Network WHERE Name = 'IATA Portal']);

		if(myCommunity.size() > 0) this.networkComponent = Network.getLoginUrl(myCommunity[0].id).substringBeforeLast('/') + '/ISSP_AMS_EBulletin';
    
		System.debug(networkComponent);

		String developerName = 'AMS_EBulletin_'+this.typeEBulletin+'_Notification';

		this.emailTemplate = [Select id, Body, HtmlValue, Encoding, Subject from EmailTemplate where DeveloperName = :developerName];

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<AMS_eBulletin_Profile__c> scope) {
		
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

		system.debug('scope: ' + scope);

		for(AMS_eBulletin_Profile__c eBprof : scope){
			
			AMS_EBulletinReportWebservice.recordTypeName =Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosById.get(eBprof.RecordTypeId).Name;

			AMS_EBulletinReportWebservice.AMSEBulletinFilters filters = new AMS_EBulletinReportWebservice.AMSEBulletinFilters(eBprof, eBprof.Last_Run__c , system.now() );


			//Recover Ebulletin Sections
			AMS_EBulletinReportHelper.getChangeCodesForExtraction(filters);

		
			Set <String> ccNamesToRecover = AMS_CustomSettingsUtils.ccNameSectionMap.keyset();

			for (String cc : ccNamesToRecover) system.debug('cc: ' + cc);


			List<String> countriesToRecover = filters.countriesList;
			List<String> programsToRecover = filters.programsList;

			system.debug('ccNamesToRecover: ' + ccNamesToRecover);
			system.debug('filters.countriesList: ' + countriesToRecover);
			system.debug('filters.programsList: ' + programsToRecover);
			system.debug('filters.fromCCDate: ' + filters.fromCCDate);
			system.debug('filters.toCCDate: ' + filters.toCCDate);
			
			Integer count = 0;
			if(this.typeEBulletin == 'Daily'){	

				String baseq 			= 'SELECT count() FROM Agency_Applied_Change_code__c WHERE Change_Code__c ';
				String filtersCC 		= 'IN :ccNamesToRecover ';   
				String filtersPublished = 'and Published_on_EBulletin__c = TRUE ';
				String filtersCountries = 'and Account__r.IATA_ISO_Country__r.ISO_Code__c IN :countriesToRecover ';
				String filtersLC 		= 'and Account__r.Location_Class__c IN :programsToRecover ';
				String filtersDates		= 'and Created_Date_To_Show__c > ' + (filters.fromCCDate != null ? filters.fromCCDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'') : filters.toCCDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')) + ' and Created_Date_To_Show__c < ' + filters.toCCDate.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
				
				count = Database.countQuery(baseq + filtersCC + filtersPublished + filtersCountries + filtersLC + filtersDates) ;

				system.debug('Count Query: ' + baseq + filtersCC + filtersPublished + filtersCountries + filtersLC + filtersDates);
			}
			else if (this.typeEBulletin == 'Weekly'){
				count = 1;
			}


			system.debug('Change Codes count: ' + count);

			if(count > 0) mailsToSend.add(setEmailContents(eBprof));
		}

		if(!Test.isRunningTest())  Messaging.sendEmail(mailsToSend);

	}
	
	global void finish(Database.BatchableContext BC) {
		
		//FINISH
	}

	private Messaging.SingleEmailMessage setEmailContents(AMS_eBulletin_Profile__c eBprof)
	{

		//TODO Create an Email template
		//
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setToAddresses(new List<String>{eBprof.User__r.email});
    	
        mail.setSenderDisplayName('IATA Customer Service');

	    String bodyHTML = emailTemplate.HtmlValue;
        String bodyText = emailTemplate.Body;

        bodyHTML = bodyHTML.replace('##USERNAME##',eBprof.User__r.name);
        bodyHTML = bodyHTML.replace('##URL##',networkComponent);

       	mail.setHtmlBody(bodyHTML);
        mail.setPlainTextBody(bodyText);

        mail.setCharset(emailTemplate.Encoding);
        mail.setSubject(emailTemplate.Subject);
       	mail.saveAsActivity = false;
    	
		return mail;
	}
	
}