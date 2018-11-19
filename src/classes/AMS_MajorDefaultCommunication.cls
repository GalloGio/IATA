global class AMS_MajorDefaultCommunication implements Database.Batchable<sObject>, Database.Stateful {
	global Map<String,Set<Id>> accountIdsByCountry {get;set;}
	global Map<Id,Case> caseByAccounts {get;set;}
	global List<String> errors {get;set;}

	public AMS_MajorDefaultCommunication(List<Agency_Applied_Change_code__c> changeCodes) {
		this.errors = new List<String>();
		Set<Id> caseIds = new Set<Id>();
		for(Agency_Applied_Change_code__c ccode : changeCodes) {
			if(ccode.SIDRA_Case__c != null) {
				caseIds.add(ccode.SIDRA_Case__c);
			}
		}

		List<Case> cases = [SELECT Id, AccountId, Account.IATA_ISO_Country__r.ISO_Code__c, Short_Payment_Amount_USD__c, Account.Name, BSPCountry__c
							FROM Case
							WHERE Id IN :caseIds AND BSP_CASS__c = 'BSP'];

		Map<String,Double> countriesDefaults = new Map<String,Double>();
		List<Default_Agency_Payment__mdt> defaults = [SELECT MasterLabel, Country_Codes__c, Default_Amount__c 
													  FROM Default_Agency_Payment__mdt
													  WHERE Active__c = true];													  
		for(Default_Agency_Payment__mdt def : defaults) {
			if(def.MasterLabel != 'All') {
				List<String> countryCodes = def.Country_Codes__c.split(';');
				for(String countryCode : countryCodes) {
					countriesDefaults.put(countryCode, def.Default_Amount__c);
				}
			} else {
				countriesDefaults.put('All', def.Default_Amount__c);
			}
		}

		this.accountIdsByCountry = new Map<String,Set<Id>>();
		this.caseByAccounts = new Map<Id,Case>();
		for(Case cse : cases) {
			caseByAccounts.put(cse.AccountId, cse);
			Double countryDefault = countriesDefaults.get(cse.Account.IATA_ISO_Country__r.ISO_Code__c);
			if(countryDefault == null) {
				countryDefault = countriesDefaults.get('All');
			}

			if(cse.Short_Payment_Amount_USD__c >= countryDefault) {
				Set<Id> accountIds = accountIdsByCountry.get(cse.Account.IATA_ISO_Country__r.ISO_Code__c);
				if(accountIds == null) {
					accountIds = new Set<Id>();
					accountIdsByCountry.put(cse.Account.IATA_ISO_Country__r.ISO_Code__c, accountIds);
				}
				accountIds.add(cse.AccountId);
			}
		}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Set<String> countryCodes = this.accountIdsByCountry.keySet();
		System.debug('countryCodes: ' + countryCodes);
		String queryStr = 'SELECT Services_Rendered_to_Airline__c, Services_Rendered_to_Airline__r.ParentId, ISO_Country_Code__c ';
		queryStr += 'FROM Services_Rendered__c WHERE Services_Rendered_Type__c LIKE \'%BSP%\' AND ISO_Country_Code__c IN :countryCodes AND Services_Rendered_Status__c = \'Active\'';
		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<Services_Rendered__c> scope) {
		try {
			Map<String, Set<Id>> airlinesByCountry = new Map<String, Set<Id>>(); //Map airlines to notify per country	
			Map<Id,Id> airlinesMap = new Map<Id,Id>(); //Map each airline to his parent (Headquarters are mapped to null)
			for(Services_Rendered__c service : scope) {
				Id airlineId = service.Services_Rendered_to_Airline__c;
				Id airlineParentId = service.Services_Rendered_to_Airline__r.ParentId;
				String country = service.ISO_Country_Code__c;

				airlinesMap.put(airlineId, airlineParentId);
				if(airlineParentId != null) {
					airlinesMap.put(airlineParentId, null);
				}

				Set<Id> countryAirlines = airlinesByCountry.get(country);
				if(countryAirlines == null) {
					countryAirlines = new Set<Id>();
					airlinesByCountry.put(country, countryAirlines);
				}
				countryAirlines.add(airlineId);
			}

			Map<Id,Set<Contact>> executiveContacts = getExecutiveContacts(airlinesMap.keySet());
			Map<String,Id> templates = getEmailTemplatesId();
			List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();

			System.debug('airlinesByCountry: ' + airlinesByCountry);
			System.debug('executiveContacts: ' + executiveContacts);
			System.debug('templates: ' + templates);

			Id orgEmailAddressId = [SELECT Id, Address, DisplayName FROM OrgWideEmailAddress WHERE Address = 'agencymanagement@iata.org'].Id;
			for(String country : airlinesByCountry.keySet()) {
				for(Id airlineId : airlinesByCountry.get(country)) {
					System.debug('AirlineId: ' + airlineId);
					Set<Contact> contacts = executiveContacts.get(airlineId);
					System.debug('Contacts for airline: ' + contacts);
					if(contacts == null) {
						contacts = new Set<Contact>();
					}
					Id parentId = airlinesMap.get(airlineId);
					if(parentId != null) {
						Set<Contact> parentContacts = executiveContacts.get(parentId);
						if(parentContacts != null) {
							contacts.addAll(parentContacts);
						}
					}
					System.debug('Final list of contacts for airline: ' + contacts);
					for(Id agencyId : accountIdsByCountry.get(country)) {
						Case cse = caseByAccounts.get(agencyId);
						for(Contact con : contacts) {
							Id templateId = templates.get(con.Preferred_Language__c);
							if(templateId == null) {
								templateId = templates.get('Default');
							}
							Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
							mail.setTargetObjectId(con.Id);
							mail.setWhatId(cse.Id);
							mail.setToAddresses(new String[] {con.Id});
							mail.setOrgWideEmailAddressId(orgEmailAddressId);
							mail.setSaveAsActivity(true);
							mail.setTemplateId(templateId);	
							notifications.add(mail);
						}
					}
				}
			}

			if(!notifications.isEmpty()) {
				Messaging.sendEmail(notifications);   
			}
		} catch(Exception e) {
			errors.add(e.getMessage());
			errors.add(e.getStackTraceString());
		}
	}

	private static Map<String,Id> getEmailTemplatesId() {
		Map<String,Id> res = new Map<String,Id>();
		List<EmailTemplate> templates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'Major_Default_Communication%'];
		for(EmailTemplate template : templates) {
			List<String> nameSplit = template.DeveloperName.split('_');
			String lang = nameSplit[nameSplit.size() - 1];
			res.put(lang, template.Id);
			if(lang == 'English') {
				res.put('Default', template.Id);
			}
		}
		return res;
	}

	private static Map<Id,Set<Contact>> getExecutiveContacts(Set<Id> accountIds) {
		Map<Id,Set<Contact>> mapContacts = new Map<Id,Set<Contact>>();
		List<Contact> contacts = [SELECT Id, AccountId, Name, Preferred_Language__c
								  FROM Contact 
								  WHERE AccountId IN :accountIds AND (PSG_Member__c = true OR 
								  	PaConf_Representative__c = true) AND Status__c = 'Active' AND Email <> null];

		for(Contact c : contacts) {
			Set<Contact> contactIds = mapContacts.get(c.AccountId);
			if(contactIds == null) {
				contactIds = new Set<Contact>();
				mapContacts.put(c.AccountId, contactIds);
			}
			contactIds.add(c);
		}

		return mapContacts;
	}

	global void finish(Database.BatchableContext BC) {
		UtilityCS__c cs = UtilityCS__c.getInstance('AMS_Notifiy_Errors_To');
		if(!errors.isEmpty() && cs != null && String.isNotBlank(cs.Value__c)) {
			List<String> receivers = cs.Value__c.split(';');
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setSubject('Default Agency Batch Errors');
			mail.setPlainTextBody(String.join(errors, '\n'));
			mail.setToAddresses(receivers);
			Messaging.sendEmail(new List<Messaging.SingleEmailMessage> {mail}); 
		}
	}
}