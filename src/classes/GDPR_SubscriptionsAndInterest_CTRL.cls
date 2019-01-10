public without sharing class GDPR_SubscriptionsAndInterest_CTRL {
	@AuraEnabled
    public static list<GDPR_Pardot_Interest_List__mdt> getSubscriptionList() {
		
		return [SELECT label FROM GDPR_Pardot_Interest_List__mdt];
	}

}