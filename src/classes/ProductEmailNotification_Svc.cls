public with sharing class ProductEmailNotification_Svc {

	//Prevent Internal and External emails entry at the same time
	public static void preventInternalAndExternalEntry(List<Product_Email_Notification__c> lstEmailNotif){
		for(Product_Email_Notification__c en : lstEmailNotif){
			if(en.Internal_user__c != null && en.External_email_address__c != null){
				en.addError(Label.Internal_and_external_emails_error);
				break;
			}
		}
	}

}
