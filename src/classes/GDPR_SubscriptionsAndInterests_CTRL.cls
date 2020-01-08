public without sharing class GDPR_SubscriptionsAndInterests_CTRL {
	@AuraEnabled
	public static String getSubscriptionList(String email, String salesforceId) {
		SubWrapper sws = new SubWrapper();
		List<SubscriptionWrapper> newsletters =  new List<SubscriptionWrapper>();
		List<SubscriptionWrapper> products =  new List<SubscriptionWrapper>();
		List<String> initialSubscription =  new List<String>();

		// Get all possible subscrptions
		List<GDPR_Pardot_Subscription_List__mdt> allSubscriptions = [SELECT id, label, section__c, Help_text__c, Pardot_ID__c  FROM GDPR_Pardot_Subscription_List__mdt ORDER BY label];

		// Get subscription info from Pardot
		Pardot_API.Pardot_Prospect prospect = new Pardot_API.Pardot_Prospect();
		prospect = Pardot_API.getProspect(email);
		set<String> listSubcribed = new set<String>();
		for(Pardot_API.List_Subscription ls : prospect.list_subscription ) {
			listSubcribed.add(ls.id);
		}

		if(String.isNotBlank(email)) {
			for(GDPR_Pardot_Subscription_List__mdt aSubscription : allSubscriptions){
					SubscriptionWrapper sw = new SubscriptionWrapper();
					sw.id = aSubscription.Pardot_ID__c;
					sw.label = aSubscription.label;
					sw.section = aSubscription.section__c;
					sw.helpText = aSubscription.Help_text__c;
					sw.selected = listSubcribed.contains(aSubscription.Pardot_ID__c);
					if(sw.selected) {
						initialSubscription.add(sw.id);
					}
					if(aSubscription.section__c == 'Newsletter')
						newsletters.add(sw);
					else
						products.add(sw);
			}
			sws.newsletters = newsletters;
			sws.products = products;
			sws.initialSubscription = initialSubscription;
			sws.opted_out = prospect.opted_out == '1';

			// Get opt-out value from Salesforce (not for Pardot to avoid disynchronisation)
			Boolean isOptedOut = false;
			if(String.isNotBlank(salesforceId)) {
				if(((Id)salesforceId).getsobjecttype() == Schema.Lead.SObjectType) {
					Lead l = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id =: salesforceId];
					isOptedOut = l.HasOptedOutOfEmail;
				} else {
					Contact c = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id =: salesforceId];
					isOptedOut = c.HasOptedOutOfEmail;
				}
			}
			sws.opted_out = isOptedOut;
		}
		return JSON.serialize(sws);
	}

	@AuraEnabled
	public static boolean updateSubscriptionList(String prospect_id, String email, List<String> subscription_ids, List<String> unsubscription_ids) {
		if( String.isBlank(prospect_id)) return false;

		if(! subscription_ids.isEmpty()) {
			Pardot_API.createListMembershipBulk(prospect_id, subscription_ids);
		}

		if(! unsubscription_ids.isEmpty()) {
			Pardot_API.deleteListMembershipBulk(prospect_id, unsubscription_ids);
		}
		// Send email to nofity modification of subcription
		if(! subscription_ids.isEmpty() || ! unsubscription_ids.isEmpty()) {
			GDPR_Helper.sendSubscriptionModificationEmail(email, false);
		}

		return true;
	}

	@AuraEnabled
	public static boolean optOut(String prospect_id, String email, Boolean doOptOut) {
		if( String.isBlank(prospect_id)) return false;
		Boolean apiOk = Pardot_API.optOut(prospect_id, doOptOut);
		if(apiOk) GDPR_Helper.sendSubscriptionModificationEmail(email, true);
		return apiOk;
	}

	@AuraEnabled
	public static boolean optIn(String salesforce_id, String email, Boolean doOptOut) {
		if( String.isBlank(salesforce_id)) return false;

		if(((Id)salesforce_id).getsobjecttype() == Schema.Lead.SObjectType) {
			Lead l = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id =: salesforce_id];
			l.HasOptedOutOfEmail = doOptOut;
			update l;
		} else {
			Contact c = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id =: salesforce_id];
			c.HasOptedOutOfEmail = doOptOut;
			update c;
		}
		GDPR_Helper.sendSubscriptionModificationEmail(email, doOptOut);
		return true;
	}

	@AuraEnabled
	public static List<InterestsWrapper> getInterestList(String email, String salesforceId) {
		List<InterestsWrapper> iws =  new List<InterestsWrapper>();
		// Get available choices from metadata
		List<GDPR_Pardot_Interest_List__mdt> allInterests = [SELECT label, Pardot_label__c FROM GDPR_Pardot_Interest_List__mdt ORDER BY Pardot_label__c];

		// Get Interest info from Pardot
		Pardot_API.Pardot_Prospect prospect = new Pardot_API.Pardot_Prospect();
		prospect = Pardot_API.getProspect(email);
		System.debug(loggingLevel.FINE, '____ [cls GDPR_SubscriptionsAndInterests_CTRL - getInteresList] prospect - ' + prospect);

		// Get opt-out value from Salesforce (not for Pardot to avoid disynchronisation)
		Boolean isOptedOut = false;
		if(String.isNotBlank(salesforceId)) {
			if(((Id)salesforceId).getsobjecttype() == Schema.Lead.SObjectType) {
				Lead l = [SELECT Id, HasOptedOutOfEmail FROM Lead WHERE Id =: salesforceId];
				isOptedOut = l.HasOptedOutOfEmail;
			} else {
				Contact c = [SELECT Id, HasOptedOutOfEmail FROM Contact WHERE Id =: salesforceId];
				isOptedOut = c.HasOptedOutOfEmail;
			}
		}

		for(GDPR_Pardot_Interest_List__mdt aInterest : allInterests){
			InterestsWrapper iw = new InterestsWrapper();
			iw.label = aInterest.Pardot_label__c;
			iw.selected = prospect == null || prospect.area_of_Interest == null || prospect.area_of_Interest.isEmpty() ? false : prospect.area_of_Interest.contains(aInterest.Pardot_label__c);
			iw.opted_out = isOptedOut;
			iws.add(iw);
		}
		return iws;
	}

	@AuraEnabled
	public static boolean updateInterest(String prospectID, String email, String individualId, List<String> interests) {
		// Update in Pardot and let the connector sync area of interest
		Pardot_API.updateProspectInterest(prospectID, email, interests);
		return true;
	}

	public class InterestsWrapper {
		@AuraEnabled public String label {get;set;}
		@AuraEnabled public Boolean selected {get;set;}
		@AuraEnabled public Boolean opted_out {get;set;}
	}

	public class SubscriptionWrapper {
		@AuraEnabled public String id {get;set;}
		@AuraEnabled public String label {get;set;}
		@AuraEnabled public String section {get;set;}
		@AuraEnabled public String helpText {get;set;}
		@AuraEnabled public Boolean selected {get;set;}
	}

	public class SubWrapper {
		@AuraEnabled public List<SubscriptionWrapper> newsletters {get;set;}
		@AuraEnabled public List<SubscriptionWrapper> products {get;set;}
		@AuraEnabled public List<String> initialSubscription {get;set;}
		@AuraEnabled public Boolean opted_out {get;set;}
	}
}
