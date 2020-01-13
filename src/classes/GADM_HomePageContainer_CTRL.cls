/**
 * Created by ppop on 8/8/2019.
 */

public with sharing class GADM_HomePageContainer_CTRL {
	@AuraEnabled
	public static List<Id> getObjects() {
		List<Id> objectVisible = new List<Id>();
		List<Service_Notification__c> serviceNotifications = [SELECT Id FROM Service_Notification__c WHERE Service__r.Name = 'GADM'];
		for (Service_Notification__c sn : serviceNotifications) {
			objectVisible.add(sn.Id);
		}

		return objectVisible;
	}
}
