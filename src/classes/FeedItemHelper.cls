public with sharing class FeedItemHelper {
	
	/*
	 *  This method checks that hashtags exist in the feed items attached to Accounts, to ensure that topics have
	 *  been used. Otherwise, an error is thrown.
	 *  Validation put in place for the Account Management project.
	 */
	public static void CheckPostTopics(list<FeedItem> lstTriggerNew) {
		
		// get the accounts of interest to which the feed items are linked - we only apply the logic to Airline HQ accounts that are IATA Members
		set<Id> setRelatedAccountIds = new set<Id>();		
		for (FeedItem fi : lstTriggerNew) {
			//check apostrophe ' (&#39) RN-INC339011
			if (fi.body != null) {
				String check = fi.body.toUpperCase();
				string finalS = fi.body.toUpperCase();
				if(check.contains('&#39;')){
					finalS = check.remove('&#39;');
				}
				Pattern p = Pattern.compile('.*#\\w+(?s).*');
				Matcher regexMatcher = p.matcher(finalS);
	
				if (String.valueOf(fi.ParentId).startsWith('001') 
					&& !regexMatcher.matches() 
					&& fi.Type == 'TextPost') {
						setRelatedAccountIds.add(fi.ParentId);
				}
			}
 	   	}
 	   	
		if (!setRelatedAccountIds.isEmpty()) {

			Map<Id, Account> mapAccountsPerId = new Map<Id, Account>(
				[SELECT 
					Id 
				 FROM 
				 	Account
				 WHERE 
				 	 Id IN :setRelatedAccountIds
				 AND RecordType.DeveloperName = 'IATA_Airline'
				 AND Sector__c = 'Airline'
				]
			);

			// if there are IATA member Airline HQ accounts that have invalid feeditems posted to them, raise the error
			if (!mapAccountsPerId.values().isEmpty()) {

				TopicHelper.TopicsWrapper topicWrapper = TopicHelper.getTopicsInfo();
				
				String strAcceptedValues = topicWrapper.acceptedTopics;
		
				for (FeedItem fi : lstTriggerNew) {
 	   				fi.addError(Label.Feed_Item_Invalid_Topics + '\r\n' + strAcceptedValues);
				}
 	   		
 	   		}
 	   	}
	}
	
}