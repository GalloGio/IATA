public class ContentVersionTriggerHandler {

	/* */
	public static Set<Id> getAllActiveCurrencyCenterContactIds() {

		Set<Id> setOfContacts = new Set<Id>();

		Map<Id, Account> airlineMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, IATA_ISO_Country__c, IATA_ISO_Country__r.ISO_Code__c FROM Account WHERE recordType.developerName = 'iata_airline']);
		System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> airlineMap = ' + airlineMap);
        
        List<Contact> accountsContacts = [SELECT Id, Name, AccountId FROM Contact WHERE Status__c = 'Active' AND AccountId in :(airlineMap.keySet())];
        System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> accountsContacts = ' + accountsContacts);

        List<Portal_Application_Right__c> parList = [SELECT Id, Name, Contact__c FROM Portal_Application_Right__c WHERE Contact__c in : accountsContacts AND Right__c = 'Access Granted' AND Application_Start_URL__c = '/ISSP_CurrencyCenterHome'];
        System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> parList ' + parList);

        if(!parList.isEmpty()) {
            for(Portal_Application_Right__c par: parList) {
                setOfContacts.add(par.Contact__c);
            }
        }

        System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> setOfContacts ' + setOfContacts);
        return setOfContacts;

	}

    /*All the logic for after insert should go into this*/
    public static void afterInsertContentVersionTriggerHandler() {

    	String orgWideEmail = 'IATA Noreply';

		List<ContentVersion> newReportList = (List<ContentVersion>) trigger.New;

		for (ContentVersion cv: newReportList) {

			String emailReportTemplate = '';
			if (cv.Title.contains('CurrencyCenterCurrencyRepatriation')) { 
				emailReportTemplate = 'Currency_Center_New_Monthly_Report_Notification';
			} 
			else if (cv.Title.contains('CurrencyCenterAnnualRBF')) {
				emailReportTemplate = 'Currency_Center_New_Annual_Report_Notification';
			} 

        	if (emailReportTemplate.equals('Currency_Center_New_Monthly_Report_Notification') || emailReportTemplate.equals('Currency_Center_New_Annual_Report_Notification')) {

        		Set<Id> setOfContactIds = getAllActiveCurrencyCenterContactIds(); 

        		if(!setOfContactIds.isEmpty()) {

        			List<OrgWideEmailAddress> owa = [SELECT id, DisplayName, Address FROM OrgWideEmailAddress WHERE DisplayName = :orgWideEmail LIMIT 1];
        			List<EmailTemplate> et = [SELECT Id, Name FROM EmailTemplate WHERE DeveloperName = :emailReportTemplate LIMIT 1];

        			if(!owa.isEmpty() && !et.isEmpty()) {
        			 	Messaging.Email[] mailMsgs = new Messaging.Email[]{};
        			 	List<Messaging.SendEmailResult> sendEmailResults = new List<Messaging.SendEmailResult>();

                        for(Id cid : setOfContactIds) {
                            Messaging.SingleEmailMessage mailMsg = new Messaging.SingleEmailMessage();
                            mailMsg.setOrgWideEmailAddressId(owa[0].Id);
                            mailMsg.setTargetObjectId(cid);
                            mailMsg.setTemplateID(et[0].Id);
                            mailMsg.setSaveAsActivity(false);
                            mailMsgs.add(mailMsg);
                        }

                        if(!mailMsgs.isEmpty()){
		                    try {
	    	                    sendEmailResults = Messaging.sendEmail(mailMsgs);
	        	                for(Messaging.SendEmailResult ser: sendEmailResults) {
	                            	if(!ser.isSuccess()) {
	                                	System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> errorMessage: ' + ser.getErrors()[0].getMessage() + ' - TargetObjectId:' + ser.getErrors()[0].getTargetObjectId());
	                            	}
	                        	}
	                    	}
	                    	catch (Exception ex){
	                        	System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> error: ' + ex.getMessage());
	                    	}
		                }

        			}
        			else if (owa.isEmpty()){
                    	System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> Couldn\'t find OrgWideEmailAddress \'IATA Noreply\'');
                	}
                	else if(et.isEmpty()){
                    	System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> Couldn\'t find EmailTemplate \'Currency_Center_Annual_Survey_Initial_Notification\'');
                	}
        		}
        		else{
		            System.debug('ContentVersionTriggerHandler.afterInsertContentVersionTriggerHandler> No contacts with access to Currency Center service');
		        }
        	}
        }
	}

}