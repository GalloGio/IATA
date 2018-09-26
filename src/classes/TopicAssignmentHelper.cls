public with sharing class TopicAssignmentHelper {

	/*
	 * Checks that the topic added to account FeedItems is contained in the allowed list of topics.
	 * Applies to items posted to Airline HQ accounts that are IATA Members.
	 */
	public static void AccountTopicValidation(list<TopicAssignment> TriggerNew) {
		// get the list of allowed topics
		set<String> setAccountChatterTopics = new set<String>();
		String strAcceptedValues = '';
		List<AMP_Account_Topics__c> topics = AMP_Account_Topics__c.getAll().Values();
		
		//sort topics by name
		List<String> topicstr = new List<String>();
		for (AMP_Account_Topics__c at : topics){
			topicstr.add(at.Name);
		}
		topicstr.sort();

		for (String at : topicstr) {
			setAccountChatterTopics.add(at);
			strAcceptedValues += (strAcceptedValues == '' ? '' : '; ') + at;
		}

		// only continue if a set of valid topics have been defined; otherwise we would be raising errors for every single topic
		if (!setAccountChatterTopics.isEmpty()) {
			// get list of related Topic that are NOT in the accepted list
			set<Id> setRelatedTopicsIds = new set<Id>();
			set<Id> setParentEntityIds = new set<Id>();

			for (TopicAssignment ta : TriggerNew) {
				setRelatedTopicsIds.add(ta.TopicId);
				setParentEntityIds.add(ta.EntityId);
			}
			setAccountChatterTopics.add('Broadcast All Regions');
			setAccountChatterTopics.add('Broadcast Africa & Middle East');
			setAccountChatterTopics.add('Broadcast Americas');
			setAccountChatterTopics.add('Broadcast Asia & Pacific');
			setAccountChatterTopics.add('Broadcast China & North Asia');
			setAccountChatterTopics.add('Broadcast Europe');

			map<Id,Topic> mapUnacceptableTopicsPerIds = new map<Id,Topic>([SELECT Id, Name FROM Topic WHERE Id IN :setRelatedTopicsIds AND Name NOT IN :setAccountChatterTopics]);

			if (!mapUnacceptableTopicsPerIds.values().isEmpty()) {

				// for all the unacceptable topics, check whether they are attached to a feed item whose parent is an account
				// only apply to text posts (e.g. not to automatic feed tracking)
				map<Id,FeedItem> mapParentFeedItemsPerIds = new map<Id, FeedItem>([SELECT Id, ParentId FROM FeedItem WHERE Id IN :setParentEntityIds AND Type = 'TextPost']);

				// broadcast helper topics
				Set<String> stBroadcastTopics = new Set<String>();

				// get the accounts of interest to which the feed items are linked - we only apply the logic to Airline HQ accounts that are IATA Members
				set<Id> setRelatedAccountIds = new set<Id>();
				for (FeedItem fi : mapParentFeedItemsPerIds.values()) {
					if (String.valueOf(fi.ParentId).startsWith('001')) {
						setRelatedAccountIds.add(fi.ParentId);
					}
				}

				if (!setRelatedAccountIds.isEmpty()) {

					map<Id, Account> mapAccountsPerId = new map<Id, Account>([SELECT Id FROM Account
																				WHERE Id IN :setRelatedAccountIds
																				AND RecordType.DeveloperName = 'IATA_Airline'
																				AND Membership_status__c = 'IATA member']);

					// if there are IATA member Airline HQ accounts that have invalid feeditems posted to them, raise the error
					if (!mapAccountsPerId.values().isEmpty()) {

						for (TopicAssignment ta : TriggerNew) {
							FeedItem fi = mapParentFeedItemsPerIds.get(ta.EntityId);
							System.debug(stBroadcastTopics);
							System.debug(ta);
							System.debug(stBroadcastTopics.contains(ta.Topic.Name));

							if (fi != null && mapAccountsPerId.get(fi.ParentId) != null && mapUnacceptableTopicsPerIds.get(ta.TopicId) != null  ) {
								ta.addError('You have entered an invalid topic for an Account.\r\nPlease choose one or more of the following topics:\r\n' + strAcceptedValues);
								system.debug('Error raised for topic: ' + mapUnacceptableTopicsPerIds.get(ta.TopicId).Name);
							}
						}

					}
				}



			}
		}

	}
}