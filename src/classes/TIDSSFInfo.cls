public class TIDSSFInfo {
	@AuraEnabled public Account tidsAccount = new Account();
	@AuraEnabled public List<AMS_Account_Role__c> shareholders = new List<AMS_Account_Role__c>();
	@AuraEnabled public List<AMS_Agency_Profile__c> businessProfile = new List<AMS_Agency_Profile__c>();
}