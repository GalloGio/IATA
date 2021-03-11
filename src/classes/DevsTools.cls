public with sharing class DevsTools {
	 /**
	 *
	 * return information about curernt environment
	 */
	 public static Boolean isRunningInSandbox() {
			String s  =  System.URL.getSalesforceBaseUrl().getHost();
			return (Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com',s));
	}


	private static List<User> receivers = new List<User>();

	/**
	* Send an Alert Alert email to devs
	*
	*/
	public static void sendSFDevsAlertMessage(String title, String message){

			if(receivers.size()==0){
				receivers = [SELECT Id, Email, ProfileId FROM User WHERE IsActive = true AND Receive_Apex_emails__c = true];
			}
			if(receivers.size()>0){
				List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
				for(User u: receivers) {
					Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
					mail.setSubject(title);
					mail.setTargetObjectId(u.Id) ;
					mail.setPlainTextBody(message);
					mail.setSaveAsActivity(false);
					emails.add(mail);
				}
				Messaging.sendEmail(emails);				
			}
	}
}
