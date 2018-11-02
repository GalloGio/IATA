global class AMS_EBulletinBatch implements Database.Batchable<sObject> {
	
	String query;
	public final String typeEBulletin;	
	public String networkComponent = '';
	EmailTemplate emailTemplate; 
	Map<Id,Boolean> profBouncedMap;

	global AMS_EBulletinBatch(String typeEBulletin) {
		this.typeEBulletin = typeEBulletin;

		//String fieldsToRecover  = 'id,Last_NotificationBatch_Run__c,User__r.email,RecordTypeId,Name,CountriesList__c,RecordType.Name,Area_1__c,Area_2__c,Area_3__c,Program_Cargo__c,Program_CASS_Associates__c,Program_Passage__c';
		
		//String filters = 'where recordType.name = :typeEBulletin and Opt_out_Bulletin__c = FALSE and Opt_in__c = TRUE ';

		//this.query = 'select ' + fieldsToRecover + ' from AMS_eBulletin_Profile__c ' + filters;
		

		this.query = AMS_QueryUtils.getAllFieldQuery('AMS_eBulletin_Profile__c',new List<String>{'User__r.email','User__r.name','User__r.ContactId'},
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

		List<AMS_eBulletin_Profile__c> profileUpdateDates = new List<AMS_eBulletin_Profile__c>();


		//get the value of email bounced for each profile
		Set<Id> profIds = new Set<Id>();

		for(AMS_eBulletin_Profile__c ebProfile : scope) {

			profIds.add(ebProfile.Id);
		}

		Map<Id, Id> ebprofContactsMap = new Map<Id, Id>();

		List<AMS_eBulletin_Profile__c> eBprofContacts = new List<AMS_eBulletin_Profile__c>();

		eBprofContacts = [SELECT Id, User__r.ContactId FROM AMS_eBulletin_Profile__c WHERE Id IN :profIds AND User__c != null];

		for(AMS_eBulletin_Profile__c prof : eBprofContacts) {

			ebprofContactsMap.put(prof.User__r.ContactId, prof.Id);
		}

		Map<Id, Boolean> conBouncedMap = new Map<Id, Boolean>();

		List<Contact> conBounced = new List<Contact>();

		Set<Id> contacts = ebprofContactsMap.keySet();

		conBounced = [SELECT Id, IsEmailBounced FROM Contact WHERE Id IN :contacts];

		for(Contact con : conBounced) {

			conBouncedMap.put(con.Id, con.IsEmailBounced);
		}

		profBouncedMap = new Map<Id,Boolean>();

		for(Id conId : contacts) {

			profBouncedMap.put(ebprofContactsMap.get(conId), conBouncedMap.get(conId));
		}

		System.debug('AMS_EBulletinBatch - ebulletin profiles and value of IsEmailBounced (Contact field) : ' + profBouncedMap);


		for(AMS_eBulletin_Profile__c eBprof : scope){
			
			AMS_EBulletinReportHelper.recordTypeName =Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosById.get(eBprof.RecordTypeId).Name;

			if(eBprof.Last_NotificationBatch_Run__c == null) eBprof.Last_NotificationBatch_Run__c = Date.today();

			AMS_EBulletinReportHelper.AMSEBulletinFilters filters = new AMS_EBulletinReportHelper.AMSEBulletinFilters(eBprof, eBprof.Last_NotificationBatch_Run__c , system.now() );


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

			Datetime fromCCDate = filters.fromCCDate;
			Datetime toCCDate = filters.toCCDate;
			
			Integer count = 0;
			if(this.typeEBulletin == 'Daily'){	

				String baseq 			= 'SELECT count() FROM Agency_Applied_Change_code__c WHERE Change_Code__c ';
				String filtersCC 		= 'IN :ccNamesToRecover ';   
				String filtersPublished = 'and Published_on_EBulletin__c = TRUE ';
				String filtersCountries = 'and Account__r.IATA_ISO_Country__r.ISO_Code__c IN :countriesToRecover ';
				String filtersLC 		= 'and Account__r.Location_Class__c IN :programsToRecover ';
				String filtersDates		= 'and Created_Date_To_Show__c > :fromCCDate and Created_Date_To_Show__c < :toCCDate';
				

				count = Database.countQuery(baseq + filtersCC + filtersPublished + filtersCountries + filtersLC + filtersDates) ;

				system.debug('Count Query: ' + baseq + filtersCC + filtersPublished + filtersCountries + filtersLC + filtersDates);

			}
			else if (this.typeEBulletin == 'Weekly'){
				count = 1;
			}


			system.debug('Change Codes count: ' + count);

			if(count > 0) {

				Messaging.SingleEmailMessage msg = setEmailContents(eBprof);

				if(msg != null)
					mailsToSend.add(msg);

			} 

			// Update Dates and Times
			eBprof.Last_NotificationBatch_Run__c = system.now();
			profileUpdateDates.add(eBprof);

			AMS_CustomSettingsUtils.resetVariables();
		}

		if(!Test.isRunningTest())  Messaging.sendEmail(mailsToSend);

		update profileUpdateDates;

	}
	
	global void finish(Database.BatchableContext BC) {
		
		//FINISH
	}

	private Messaging.SingleEmailMessage setEmailContents(AMS_eBulletin_Profile__c eBprof)
	{

		// Create an Email template
		//

		//check if the respective email is bounced
		if(profBouncedMap.get(eBprof.Id) == null || profBouncedMap.get(eBprof.Id))
			return null;

		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
    	mail.setToAddresses(new List<String>{eBprof.User__r.email});
    	
    	mail.setReplyTo(ENV.Reply_Email);
		mail.setOrgWideEmailAddressId(PortalServiceAccessTriggerHandler.getStandartReplyUserID(ENV.Reply_Email));

	    String bodyHTML = emailTemplate.HtmlValue;
        String bodyText = emailTemplate.Body;

        bodyHTML = bodyHTML.replace('##ISSPLABEL##',Label.ISSP_Email_do_not_reply);
        bodyHTML = bodyHTML.replace('##USERNAME##',eBprof.User__r.name);
        bodyHTML = bodyHTML.replace('##URL##',networkComponent);

       	mail.setHtmlBody(bodyHTML);
        mail.setPlainTextBody(bodyText);

        mail.setCharset(emailTemplate.Encoding);
        mail.setSubject(emailTemplate.Subject);
    	mail.setTargetObjectId(eBprof.User__r.ContactId);
        mail.setWhatId(eBprof.Id);
        mail.setSaveAsActivity(true);
    	
		return mail;
	}
	
}