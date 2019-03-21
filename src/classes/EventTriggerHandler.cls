/**
 * @description This Class aims to implement a handler for eventTrigger
 *
 *
 * @creation  2019-01-23
 * @author    José Cardoso
 */
public class EventTriggerHandler {


	/* Called After Insert/Update
		Checks if the events are related to Country_Profile__c and sends email notification to subscrivers
	*/
	public static void handleCountryProfileEvents(List<Event> events){
		List<Event> countryProfileRelatedEvents = new List<Event>();

		List<Id> lsWhatIds = new List<Id>();
		for(Event t : events) {
			// check if it is Country_Profile__c
			if(t.WhatId != null && t.WhatId.getsobjecttype().getDescribe().getName() == 'Country_Profile__c'){
				countryProfileRelatedEvents.add(t);
				lsWhatIds.add(t.WhatId);
			}
		}

		System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents countryProfileRelatedEvents: ' + countryProfileRelatedEvents);
		System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents lsWhatIds: ' + lsWhatIds);

		System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents getEmailInvocations: ' + Limits.getEmailInvocations());
		System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents getLimitEmailInvocations: ' + Limits.getLimitEmailInvocations());

		if(!lsWhatIds.isEmpty()){
			List<EntitySubscription> lstSubscriptions = [SELECT Id, ParentId, SubscriberId FROM EntitySubscription WHERE ParentId in :lsWhatIds];
			System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents lstSubscriptions: ' + lstSubscriptions);

			List<Country_Profile__c> lstCountryProfile = [SELECT Id, Name FROM Country_Profile__c WHERE Id in:lsWhatIds];
			Map<Id, Country_Profile__c> countryProfilesMap = new Map<Id, Country_Profile__c>(lstCountryProfile);

			// subscrivers per country: Map<CountryProfileId,Set<SubscriverId>>
			Map<String,Set<String>> subscrivers = new Map<String, Set<String>>();
			for (EntitySubscription es : lstSubscriptions) {
				Set<String> tmpCountrySubscrivers = new Set<String>();
				if(subscrivers.containsKey(es.ParentId)){
					tmpCountrySubscrivers = subscrivers.get(es.ParentId);
				}
				tmpCountrySubscrivers.add(es.SubscriberId);
				subscrivers.put(es.ParentId, tmpCountrySubscrivers);
			}
			System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents subscrivers: ' + subscrivers);

			List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = 'IATA Noreply' LIMIT 1];
			List<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = 'Currency_Center_Event_Notification' LIMIT 1];
			Messaging.Email[] mailMsgs = new Messaging.Email[]{};
			List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();

			if(!owa.isEmpty() && !et.isEmpty()){
				for(Event e:countryProfileRelatedEvents){

					if(subscrivers.containsKey(e.WhatId)){
						for(String to: subscrivers.get(e.WhatId)){
							Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
							mailMsg.setOrgWideEmailAddressId(owa[0].Id);
							mailMsg.setTargetObjectId(to);
							mailMsg.setTemplateID(et[0].Id);
							mailMsg.setSaveAsActivity(false);
							//mailMsg.setWhatId(e.Id);
							mailMsgs.add(mailMsg);
						}
					}
				}

				if(!mailMsgs.isEmpty()){
					try {
						sendEmailResults = Messaging.sendEmail(mailMsgs);
						for(Messaging.SendEmailResult ser: sendEmailResults){
							if(!ser.isSuccess()){
								System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents errorMessage: ' + ser.getErrors()[0].getMessage() + ' - TargetObjectId:' + ser.getErrors()[0].getTargetObjectId());
							}
						}
					}
					catch (Exception ex){
						System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents error: ' + ex.getMessage());
					}
				}
			}
			else{
				System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents errorMessage: Missing OrgWideEmailAddress \'IATA Noreply\' or EmailTemplate \'Currency_Center_Event_Notification\'');
			}
		}

		System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents getEmailInvocations: ' + Limits.getEmailInvocations());
		System.debug('jmc - EventTriggerHandler.handleCountryProfileEvents getLimitEmailInvocations: ' + Limits.getLimitEmailInvocations());
	}

}