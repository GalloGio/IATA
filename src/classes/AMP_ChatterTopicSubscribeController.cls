public with sharing class AMP_ChatterTopicSubscribeController {
	public Boolean showPreview {get;set;}
	public List<Account> lsHQAccounts {get;set;}
	public Map<Id,Account> mpAccountId2Account {get;set;}
	public Map<Id,String> mpUserId2PictureURL {get;set;}
	public List<TopicFeedItems> lsTopicFeedItems {get;set;}
	List<TopicWrapper> lsTopicWrappers {get;set;}
	public String dailyOrWeekly {get;set;}
	public List<FeedItem> lsAllFeedItems {get;set;}
	public List<Topic> lsBroadcastTopics {get;set;}
	public List<TopicAssignment> lsTopicAssignments {get;set;}
	public User currentUser {get;set;}

	public string preview {get;set;}

	// public String broadcastTopicNames {get;set;}

	public AMP_ChatterTopicSubscribeController() {
		showPreview = false;
		if(ApexPages.currentPage().getParameters().get('showPreview') == '1') showPreview = true;
		lsHQAccounts = getHQAccounts();
		mpAccountId2Account = new Map<Id,Account>();
		for(Account a: lsHQAccounts) {
			mpAccountId2Account.put(a.Id,a);
		}
		currentUser = [SELECT Id, FirstName, LastName, SmallPhotoUrl, AMP_Digest_Topics__c, AMP_Digest_Daily_or_Weekly__c FROM User WHERE Id = :UserInfo.getUserId()];

		// broadcastTopicNames = '';
		lsBroadcastTopics = getBroadCastTopics();

		lsAllFeedItems = getFeedItems(lsHQAccounts);
		Set<Id> stUserIds = new Set<Id>();
		mpUserId2PictureURL = new Map<Id,String>();
		for(FeedItem fi: lsAllFeedItems) {
			stUserIds.add(fi.CreatedById);
		}
		List<User> lsUsers = [SELECT Id, Name, SmallPhotoUrl, FullPhotoURL FROM User WHERE Id IN :stUserIds];
		for(User u : lsUsers) {
			mpUserId2PictureURL.put(u.Id, u.SmallPhotoUrl);
		}
		lsTopicAssignments = [SELECT Id, TopicId, EntityId FROM TopicAssignment WHERE EntityId IN :lsAllFeedItems AND TopicId IN :lsBroadcastTopics];
		lsTopicWrappers = getTopicWrappers();
		dailyOrWeekly = 'Daily';
		if(currentUser.AMP_Digest_Daily_or_Weekly__c != null && currentUser.AMP_Digest_Daily_or_Weekly__c == 'Weekly') {dailyOrWeekly = 'Weekly';}
		lsTopicFeedItems = getTopicFeedItems();

		// for(Topic c : lsBroadcastTopics) {
		// 	broadcastTopicNames +=c.name;
		// }
		// preview = getEmailBody(currentUser);
	}

	public PageReference savePreferences() {
		currentUser.AMP_Digest_Daily_or_Weekly__c = dailyOrWeekly;
		String favouriteTopics = '';
		for(TopicWrapper tw : getTopicWrappers()) {
			if(tw.active) { favouriteTopics += tw.topic +','; }
		}
		if(favouriteTopics.endsWith(',')) {favouriteTopics = favouriteTopics.substring(0,favouriteTopics.length()-1); }
		currentUser.AMP_Digest_Topics__c = favouriteTopics;
		try {
			update currentUser;
		} catch(Exception e) {
			System.debug(e);
		}
		return null;
	}
	public PageReference unsubscribe() {
		currentUser.AMP_Digest_Daily_or_Weekly__c = '';

		try {
			update currentUser;
		} catch(Exception e) {
			System.debug(e);
		}
		return null;
	}

	public List<SelectOption> getDailyOrWeeklyOptions() {
		List<SelectOption> lsOptions = new List<SelectOption>();
		lsOptions.add(new SelectOption('Daily','Daily'));
		lsOptions.add(new SelectOption('Weekly','Weekly'));
		return lsOptions;
	}

	public List<String> getTopics() {
		List<String> lsTopics = new List<String>();
		List<AMP_Account_Topics__c> lsAMPTopics = AMP_Account_Topics__c.getAll().Values();
		lsAMPTopics.sort();
		Boolean otherFound = false;
		for (AMP_Account_Topics__c at : lsAMPTopics) {
			if(at.Name != 'Other') { lsTopics.add(at.Name); }
			else { otherFound = true; }
		}
		if(otherFound) lsTopics.add('Other');
		return lsTopics;
	}

	public PageReference filterTopicFeedItems() {
      lsTopicFeedItems = getTopicFeedItems();
	  System.debug(lsTopicFeedItems);
      return null;
	}

	public List<TopicFeedItems> getTopicFeedItems() {
		List<TopicFeedItems> lsTopicFeedItems = new List<TopicFeedItems>();
		List<String> lsTopics = getTopics();
		List<FeedItem> lsAllFeedItems = lsAllFeedItems;
		// List<TopicWrapper> lsTopicWrappers = getTopicWrappers();
		for(String topic : lsTopics ) {
			TopicFeedItems tfi = new TopicFeedItems();
			tfi.topic = topic;
			for(TopicWrapper tw : lsTopicWrappers ) {
				if(tw.topic == topic) {
					tfi.active = tw.active;
					break;
				}
			}
			List<FeedItemWrapper> lsFeedItemWrappers = new List<FeedItemWrapper>();
			List<Topic> lsFITopics = new List<Topic>();
			Integer feeditemCounter = 0;
			List<Account> tmpAccounts = new List<Account>();
			for(FeedItem fi : lsAllFeedItems) {
				lsFITopics = new List<Topic>();
				FeedItemWrapper fiw = new FeedItemWrapper();
				fiw.userPhotoURL = mpUserId2PictureURL.get(fi.CreatedById);
				if(dailyOrWeekly == 'Daily' && fi.CreatedDate < System.now().addDays(-1)) continue;
				if(fi.body != null && fi.body.toLowerCase().contains('#'+topic.toLowerCase())) {
					fiw.feeditm = fi;
					// System.debug(lsBroadcastTopics);
					// System.debug(lsTopicAssignments);
					for(Topic t : lsBroadcastTopics) {
						for(TopicAssignment ta : lsTopicAssignments) {
							if(t.Id == ta.TopicId && ta.EntityId == fi.Id) {
								lsFITopics.add(t);
							}
						}
					}
					FeedItemWrapper previous = new FeedItemWrapper();
					if(feeditemCounter > 0) {
						previous = lsFeedItemWrappers[feedItemCounter-1];
					}
					System.debug(previous.feeditm);
					System.debug(fi);
					if(previous.feeditm.CreatedDate == fi.CreatedDate && previous.feeditm.Body == fi.Body) {
						previous.lsAccounts.add(mpAccountId2Account.get(fi.ParentId));
						System.debug('mätch' + previous);
					} else {
						tmpAccounts.clear();
						tmpAccounts.add(mpAccountId2Account.get(fi.ParentId));
						fiw.lsAccounts = tmpAccounts;
						fiw.lsTopics = lsFITopics;
						lsFeedItemWrappers.add(fiw);
						feeditemCounter++;
					}
					// // List<Account> lsAccounts = new List<Account>();
					// if(previous.)
					// else {
					// }
					// System.debug(fiw);
				}
			}
			tfi.lsFeedItems = lsFeedItemWrappers;
			lsTopicFeedItems.add(tfi);
		}
		return lsTopicFeedItems;
	}

	public List<TopicWrapper> getTopicWrappers() {
		if(lsTopicWrappers != null ) return lsTopicWrappers;
		List<TopicWrapper> lsTopics = new List<TopicWrapper>();
		List<String> lsFavouriteTopics = new List<String>();
		Set<String> stFavouriteTopics = new Set<String>();

		// we take the user setting and convert it to a Set of Strings
		// to avoid problems of just string.contains()
		if(currentUser.AMP_Digest_Topics__c != null) {
			lsFavouriteTopics = currentUser.AMP_Digest_Topics__c.split(',');
		}
		for(String s :lsFavouriteTopics) {stFavouriteTopics.add(s);}

		for (String s : getTopics()) {
			Boolean b = false;
			TopicWrapper tw = new TopicWrapper();
			tw.topic = s;
			if(stFavouriteTopics.contains(s)) { b = true; }
			tw.active = b;
			lsTopics.add(tw);

		}
		return lsTopics;
	}

	class TopicWrapper {
		public Boolean active {get;set;}
		public String topic {get;set;}
	}

	class TopicFeedItems {
		public Boolean active {get;set;}
		public String topic {get;set;}
		public List<FeedItemWrapper> lsFeedItems {get;set;}
	}

	class FeedItemWrapper {
		public FeedItem feeditm {get;set;}
		public String userPhotoURL {get;set;}
		public List<Topic> lsTopics {get;set;}
		public List<Account> lsAccounts {get;set;}
	}

	public static List<Account> getHQAccounts() {
		List<Account> lsAccounts = [SELECT Id,Name FROM Account WHERE Recordtype.DeveloperName='IATA_Airline'];
		return lsAccounts;
	}

	public static List<FeedItem> getFeedItems(List<Account> lsAccounts) {
		// get the list of last week of Chatter messages to the list of accounts

		List<FeedItem> lsFeedItem =
			[SELECT Id, Body, ParentId, Type, CreatedDate, CreatedById,
				CreatedBy.FirstName, CreatedBy.LastName
			FROM FeedItem
			WHERE Type='TextPost' AND ParentId IN :lsAccounts AND CreatedDate > LAST_WEEK
			ORDER By CreatedDate Desc, Body
			LIMIT 100];

		return lsFeedItem;
	}

	public static List<FeedItem> getDailyFeedItems(List<Account> lsAccounts) {
		// get the list of last week of Chatter messages to the list of accounts

		List<FeedItem> lsFeedItem =
			[SELECT Id, Body, ParentId, Type, CreatedDate, CreatedById,
				CreatedBy.FirstName, CreatedBy.LastName
			FROM FeedItem
			WHERE Type='TextPost' AND ParentId IN :lsAccounts AND CreatedDate > YESTERDAY
			ORDER By CreatedDate Desc, Body
			LIMIT 100];

		return lsFeedItem;
	}

	public static List<User> getPosters(List<FeedItem> lsFeedItems) {
		List<Id> lsIds = new List<Id>();
		for(FeedItem fi : lsFeedItems) {
			lsIds.add(fi.CreatedById);
		}
		return [SELECT Id, Name, FirstName, LastName, SmallPhotoUrl, FullPhotoURL FROM User WHERE Id IN :lsIds];
	}

	public static List<Topic> getBroadCastTopics() {
		List<String> lsBroadcastTopicNames =
			new List<String>{	'broadcastAll Regions',
								'broadcastAfrica & Middle East',
								'broadcastAmericas',
								'broadcastAsia & Pacific',
								'broadcastChina & North Asia',
								'broadcastEurope'};
		return [SELECT Id,Name FROM Topic WHERE Name IN :lsBroadcastTopicNames];
	}

}
