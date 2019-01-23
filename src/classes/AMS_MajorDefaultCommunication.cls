global class AMS_MajorDefaultCommunication implements Database.Batchable<sObject>, Database.Stateful {
	global Map<String,Set<Id>> accountIdsByCountry {get;set;}
	global Map<Id,Case> caseByAccounts {get;set;}
	global Set<Id> contactIds {get;set;}
	global Map<Id,List<Id>> mapContactToCase {get;set;}
	global Map<Id,EmailTemplate> mapContactToTemplate {get;set;}
	global List<Case> casesForInternalNotification {get;set;} //WMO-398

	public AMS_MajorDefaultCommunication(List<Agency_Applied_Change_code__c> changeCodes) {
		this.contactIds = new Set<Id>();
		this.mapContactToCase = new Map<Id,List<Id>>();
		this.mapContactToTemplate = new Map<Id,EmailTemplate>();
		this.casesForInternalNotification = new List<Case>();

		Set<Id> caseIds = new Set<Id>();
		for(Agency_Applied_Change_code__c ccode : changeCodes) {
			if(ccode.SIDRA_Case__c != null) {
				caseIds.add(ccode.SIDRA_Case__c);
			}
		}

		List<Case> cases = [SELECT Id, AccountId, Account.IATA_ISO_Country__r.ISO_Code__c, Short_Payment_Amount_USD__c, 
								Account.Name, BSPCountry__c, ContactId
							FROM Case
							WHERE Id IN :caseIds AND BSP_CASS__c = 'BSP'];

		Map<String,Default_Agency_Payment__mdt> countriesDefaults = new Map<String,Default_Agency_Payment__mdt>();
		List<Default_Agency_Payment__mdt> defaults = [SELECT MasterLabel, Country_Codes__c, Default_Amount__c, Visibility__c
													  FROM Default_Agency_Payment__mdt
													  WHERE Active__c = true];													  
		for(Default_Agency_Payment__mdt def : defaults) {
			if(def.MasterLabel != 'All') {
				List<String> countryCodes = def.Country_Codes__c.split(';');
				for(String countryCode : countryCodes) {
					countriesDefaults.put(countryCode, def);
				}
			} else {
				countriesDefaults.put('All', def);
			}
		}

		this.accountIdsByCountry = new Map<String,Set<Id>>();
		this.caseByAccounts = new Map<Id,Case>();
		for(Case cse : cases) {
			caseByAccounts.put(cse.AccountId, cse);
			Default_Agency_Payment__mdt countryDefault = countriesDefaults.get(cse.Account.IATA_ISO_Country__r.ISO_Code__c);
			if(countryDefault == null) {
				countryDefault = countriesDefaults.get('All');
			}

			if(cse.Short_Payment_Amount_USD__c >= countryDefault.Default_Amount__c) {
				if(countryDefault.Visibility__c == 'Internal') {
					casesForInternalNotification.add(cse);
				} else {
				Set<Id> accountIds = accountIdsByCountry.get(cse.Account.IATA_ISO_Country__r.ISO_Code__c);
				if(accountIds == null) {
					accountIds = new Set<Id>();
					accountIdsByCountry.put(cse.Account.IATA_ISO_Country__r.ISO_Code__c, accountIds);
				}
				accountIds.add(cse.AccountId);
			}
		}
	}
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		Set<String> countryCodes = this.accountIdsByCountry.keySet();
		Set<Id> airlineRTIds = new Set<Id>();
		airlineRTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId());
		airlineRTIds.add(Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Branch').getRecordTypeId());
		System.debug('countryCodes: ' + countryCodes);
		String queryStr = 'SELECT Services_Rendered_to_Airline__c, Services_Rendered_to_Airline__r.ParentId, ISO_Country_Code__c ';
		queryStr += 'FROM Services_Rendered__c WHERE Services_Rendered_to_Airline__r.RecordTypeId IN :airlineRTIds AND Services_Rendered_Type__c LIKE \'%BSP%\' AND ISO_Country_Code__c IN :countryCodes AND Services_Rendered_Status__c = \'Active\'';
		return Database.getQueryLocator(queryStr);
	}

	global void execute(Database.BatchableContext BC, List<Services_Rendered__c> scope) {
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
		Map<String,EmailTemplate> templates = getEmailTemplatesId();
		List<Messaging.SingleEmailMessage> notifications = new List<Messaging.SingleEmailMessage>();

		System.debug('airlinesByCountry: ' + airlinesByCountry);
		System.debug('executiveContacts: ' + executiveContacts);
		System.debug('templates: ' + templates);

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
						EmailTemplate templateId = templates.get(con.Preferred_Language__c);
						List<Id> caseIds = mapContactToCase.get(con.Id);
						if(caseIds == null) {
							caseIds = new List<Id>();
							mapContactToCase.put(con.Id, caseIds);
						}
						caseIds.add(cse.Id);

						if(templateId == null) {
							templateId = templates.get('Default');
						}
						mapContactToTemplate.put(con.Id, templateId);
						contactIds.add(con.Id);						
					}
				}
			}
		}
	}

	private static Map<String,EmailTemplate> getEmailTemplatesId() {
		Map<String,EmailTemplate> res = new Map<String,EmailTemplate>();
		List<EmailTemplate> templates = [SELECT Id, DeveloperName FROM EmailTemplate WHERE DeveloperName LIKE 'Major_Default_Communication%'];
		for(EmailTemplate template : templates) {
			List<String> nameSplit = template.DeveloperName.split('_');
			String lang = nameSplit[nameSplit.size() - 1];
			res.put(lang, template);
			if(lang == 'English') {
				res.put('Default', template);
			}
		}
		return res;
	}

	private static Map<Id,Set<Contact>> getExecutiveContacts(Set<Id> accountIds) {
		Id rtHeadquarter = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();
		Map<Id,Set<Contact>> mapContacts = new Map<Id,Set<Contact>>();
		List<Contact> contacts = [SELECT Id, AccountId, Name, Preferred_Language__c
								  FROM Contact 
								  WHERE AccountId IN :accountIds AND 
								  	(
								  		(PSG_Member__c = true OR PaConf_Representative__c = true) OR  
								  		((Airline_Credit_Risk_Manager__c = true OR APJC_Participant__c = true OR BSP_CASS_Payment_contact__c = true) AND Account.RecordTypeId = :rtHeadquarter)
								  	)
								  	AND Status__c = 'Active' AND Email <> null];

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
		if(!contactIds.isEmpty()) {
			Database.executeBatch(new AMS_MajorDefaultCommunicationEmailSender(contactIds, mapContactToCase, mapContactToTemplate), 25);
		}

		if(!casesForInternalNotification.isEmpty()) {
			sendInternalTemplates(casesForInternalNotification);
		}
	}

	public static void sendInternalTemplates(List<Case> cases) {
		List<User> users = [SELECT Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE Group.DeveloperName  = 'AMS_Agency_Default_Notification')];
		EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = 'Internal_Major_default_notification'];
		List<Messaging.SingleEmailMessage> mailsToSend = new List<Messaging.SingleEmailMessage>();

		for(Case cse : cases) {
			for(User u : users) {
				Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(template.Id, cse.Id, cse.ContactId);
				mail.setTargetObjectId(u.Id);
				mail.setSaveAsActivity(false);
				mailsToSend.add(mail);
			}
		}

		if(!mailsToSend.isEmpty()) {
			Messaging.sendEmail(mailsToSend);
		}
	}
}