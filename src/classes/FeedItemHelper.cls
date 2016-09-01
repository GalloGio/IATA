public with sharing class FeedItemHelper {
	
	/*
	 *  This method checks that hashtags exist in the feed items attached to Accounts, to ensure that topics have
	 *  been used. Otherwise, an error is thrown.
	 *  Validation put in place for the Account Management project.
	 */
	public static void CheckPostTopics(list<FeedItem> lstTriggerNew) {
		
		String strAcceptedValues = '';

		for (AMP_Account_Topics__c at : AMP_Account_Topics__c.getAll().Values()) {
			strAcceptedValues += (strAcceptedValues == '' ? '' : ', ') + at.Name;
		}

		for (FeedItem fi : lstTriggerNew) {
 	   		if (String.valueOf(fi.ParentId).startsWith('001') && !fi.Body.contains('#') && fi.Type == 'TextPost') {
 	   			fi.addError ('Please use hashtags (#) to define the topic(s) of your post.\r\nYou can choose one or more of the following topics:\r\n' + strAcceptedValues);
 	   		}
 	   	}

	}

}