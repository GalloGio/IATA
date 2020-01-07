public with sharing class DevsTools {


		/**
		* Returns the class name of a Sobject (or sobject subclass) instance
		*
		* @param anObject The object for which the class name is requested
		* @return the class name
		*/
		public static String getClassName(Sobject anObject) {
				if (anObject == null)
						return null;
				String value = String.valueOf(anObject);
				return value.split(':')[0];
		}

	 /**
	 *
	 * return information about curernt environment
	 */
	 public static Boolean isRunningInSandbox() {
			String s  =  System.URL.getSalesforceBaseUrl().getHost();
			return (Pattern.matches('(.*\\.)?cs[0-9]*(-api)?\\..*force.com',s));
	}


	 private static String[] receivers = new List<String>();

		/**
		* Send an Alert Alert email to devs
		*
		*/
		public static void sendSFDevsAlertMessage(String title, String message){
					try{
						if(receivers.size()==0){
							List<User> users = [SELECT Email, ProfileId FROM User where IsActive = true and Receive_Apex_emails__c = true];
							for(User u:users)
								receivers.add(u.Email);
					}
						if(receivers.size()>0){
							//if(URL.getSalesforceBaseUrl().getHost().contains('cs'))receiver = 'jfonteray@gmail.com';
							List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
							Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
							mail.setSubject(title);
							mail.setToAddresses(receivers) ;
							mail.setPlainTextBody(message);
							emails.add( mail);
							Messaging.sendEmail(emails);
						}else {
							system.debug('no user with request SELECT Email, ProfileId FROM User where IsActive = true and Receive_Apex_emails__c = true');
						}
				}catch(Exception  e){
						system.debug('Failed to send email to webdev'+e.getMessage());
				}
		}
}
