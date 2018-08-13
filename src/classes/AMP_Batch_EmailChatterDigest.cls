global class AMP_Batch_EmailChatterDigest implements Database.Batchable<sObject>, Database.Stateful {

	public String query;

	// variables
	public List<Account> lsHQAccounts;
	public Map<Id, Account> mpAccountId2Account;
	private String dailyOrWeekly;
	public List<FeedItem> lsAllFeedItems;
	public List<Topic> lsBroadcastTopics;
	public List<TopicAssignment> lsTopicAssignments;
	public User currentUser;

	global AMP_Batch_EmailChatterDigest(String dayOrWeek) {
		dailyOrWeekly = dayOrWeek;
		if(dailyOrWeekly == null ) { dailyOrWeekly = 'daily';}
		System.debug(dailyOrWeekly);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		lsHQAccounts = AMP_ChatterTopicSubscribeController.getHQAccounts();
		// System.debug(dailyOrWeekly);
		query = 'SELECT Id, FirstName, LastName, Email, AMP_Digest_Topics__c, '+
				'AMP_Digest_Daily_or_Weekly__c FROM User WHERE AMP_Digest_Daily_or_Weekly__c=\'Daily\'';
		if(dailyOrWeekly == 'weekly') {
			query += ' OR AMP_Digest_Daily_or_Weekly__c=\'Weekly\'';
			lsAllFeedItems = AMP_ChatterTopicSubscribeController.getFeedItems(lsHQAccounts);
		} else {
			lsAllFeedItems = AMP_ChatterTopicSubscribeController.getDailyFeedItems(lsHQAccounts);
		}
		if(Test.isRunningTest() ) { query += ' LIMIT 100 ';}
		System.debug(query);

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> lsUsers) {
		System.debug('execute');
		System.debug(dailyOrWeekly);
		System.debug(lsUsers);
		System.debug(lsHQAccounts);
		Map<Id, Account> mpAccountId2Account = new Map<Id,Account>();
		for(Account a: lsHQAccounts) {
			mpAccountId2Account.put(a.Id,a);
		}
		System.debug(mpAccountId2Account);
		//List<FeedItem> lsAllFeedItems = AMP_ChatterTopicSubscribeController.getFeedItems(lsHQAccounts);

		// Send an email
		List<Messaging.SingleEmailMessage> lsEmails = new List<Messaging.SingleEmailMessage>();
		List<TopicAssignment> lsTopicAssignments = AMP_ChatterTopicSubscribeController.getTopicAssignments(lsAllFeedItems);
		// Use Organization Wide Address
		OrgWideEmailAddress owa = [select id, Address from OrgWideEmailAddress WHERE Address='noreply@iata.org'];
		for(User u : lsUsers) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			mail.setOrgWideEmailAddressId(owa.id);
			String[] toAddresses = new String[] {u.Email};
			mail.setToAddresses(toAddresses);
			if(dailyOrWeekly == 'weekly')
				mail.setSubject('Your Weekly Digest by Topic(s)');
			else
				mail.setSubject('Your Daily Digest by Topic(s)');
			String emailBody = AMP_ChatterTopicSubscribeController.getEmailBody(u, lsAllFeedItems, lsTopicAssignments, mpAccountId2Account);
			mail.setHtmlBody(emailBody);
			// System.debug(getEmailBody(u));
			if (emailBody != '') lsEmails.add(mail);

		}
		if(!Test.isRunningTest()) Messaging.sendEmail(lsEmails);
	}

	global void finish(Database.BatchableContext BC) {

	}

}
