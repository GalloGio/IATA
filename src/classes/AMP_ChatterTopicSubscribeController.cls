public without sharing class AMP_ChatterTopicSubscribeController {
	public Boolean showPreview {get;set;}
	public List<Account> lsHQAccounts {get;set;}
	public Map<Id,Account> mpAccountId2Account {get;set;}
	public Map<Id,String> mpUserId2PictureURL {get;set;}
	// public List<TopicFeedItems> lsTopicFeedItems {get;set;}
	List<TopicWrapper> lsTopicWrappers {get;set;}
	public String dailyOrWeekly {get;set;}
	public List<FeedItem> lsAllFeedItems {get;set;}
	public List<Topic> lsBroadcastTopics {get;set;}
	public List<TopicAssignment> lsTopicAssignments {get;set;}
	public User currentUser {get;set;}

	public string preview {get;set;}

	public AMP_ChatterTopicSubscribeController() {
		showPreview = false;
		if(ApexPages.currentPage().getParameters().get('showPreview') == '1') showPreview = true;

		currentUser = [SELECT Id, FirstName, LastName, SmallPhotoUrl, AMP_Digest_Topics__c, AMP_Digest_Daily_or_Weekly__c FROM User WHERE Id = :UserInfo.getUserId()];

		lsHQAccounts = getHQAccounts() ;
		lsAllFeedItems = getFeedItems(lsHQAccounts);

		lsTopicWrappers = getTopicWrappers();
		dailyOrWeekly = 'Daily';
		if(currentUser.AMP_Digest_Daily_or_Weekly__c != null && currentUser.AMP_Digest_Daily_or_Weekly__c == 'Weekly') {dailyOrWeekly = 'Weekly';}
		preview = getEmailBody(currentUser, lsAllFeedItems);
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
		List<String> favouriteTopics = new List<String>();
		// get the selected topics
		for(TopicWrapper tw : lsTopicWrappers) {
			if(tw.active) favouriteTopics.add(tw.topic);
		}
		// set the greeting to be either day or week
		String dayOrWeek = 'day';
		if(dailyOrWeekly == 'Weekly') {
			dayOrWeek = 'week';
			// lsAllFeedItems = getAllFeedItems(lsHQAccounts);
		}
		preview = getEmailBody(currentUser, lsAllFeedItems, favouriteTopics, dayOrWeek);

		return null;
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


	public static String getEmailBody(User currentUser, List<FeedItem> lsAllFeedItems) {

		String emailBody = '';
		// set the greeting to be either day or week
		String dayOrWeek = 'day';
		if(currentUser.AMP_Digest_Daily_or_Weekly__c == 'Weekly') dayOrWeek = 'week';
		emailBody += getEmailHeader(currentUser, dayOrWeek);
		List<String> lsFavouriteTopics = new List<String>();
		Set<String> stFavouriteTopics = new Set<String>();


		emailBody += '<tr><td>';
		// we take the user setting and convert it to a Set of Strings
		// to avoid problems of just string.contains()
		if(currentUser.AMP_Digest_Topics__c != null) {
			lsFavouriteTopics = currentUser.AMP_Digest_Topics__c.split(',');
		}
		List<Topic> lsBroadcastTopics = getBroadCastTopics();
		List<TopicAssignment> lsTopicAssignments = [SELECT Id, TopicId, EntityId FROM TopicAssignment WHERE EntityId IN :lsAllFeedItems AND TopicId IN :lsBroadcastTopics];
		String topicBody = '';
		for(String t : lsFavouriteTopics) {
			topicBody += getTopicBody(currentUser, t, lsAllFeedItems,lsTopicAssignments, dayOrWeek);
		}
		emailBody += topicBody;
		emailBody += '</td></tr>';

		emailBody += getEmailFooter();

		// if we didn't get anything uder the favouriteTopics return empty
		if(topicBody == '') { emailBody = ''; }
		return emailBody;
	}

	public static String getEmailBody(User currentUser, List<FeedItem> lsAllFeedItems, List<String> lsFavouriteTopics, String dayOrWeek) {

		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';
		emailBody += getEmailHeader(currentUser, dayOrWeek);

		emailBody += '<tr><td>';

		List<Topic> lsBroadcastTopics = getBroadCastTopics();
		List<TopicAssignment> lsTopicAssignments = [SELECT Id, TopicId, EntityId FROM TopicAssignment WHERE EntityId IN :lsAllFeedItems AND TopicId IN :lsBroadcastTopics];
		String topicBody = '';
		for(String t : lsFavouriteTopics) {
			topicBody += getTopicBody(currentUser, t, lsAllFeedItems,lsTopicAssignments, dayOrWeek);
		}
		emailBody += topicBody;
		emailBody += '</td></tr>';

		emailBody += getEmailFooter();

		// if we didn't get anything uder the favouriteTopics return empty
		if(topicBody == '') { emailBody = ''; }
		return emailBody;
	}

	public static String getEmailHeader(user currentUser, String dayOrWeek) {
		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';
		emailBody +='<html>';
		emailBody +='<body style="margin-left: 0; margin-right: 0; margin-top: 0; margin-bottom: 0; padding-left: 0; padding-right: 0; padding-top: 0; padding-bottom: 0; background-color: #F2F2F2;" bgcolor="#F2F2F2">';
		emailBody +='<style type="text/css">'+
						'.defaultIndentation { width: 10 !important; }'+
						'table {'+
							'border-collapse: collapse;'+
							'mso-table-lspace: 0px;'+
							'mso-table-rspace: 0px;'+
						'}'+
					' </style>\n\n';

		// blue line on top
		emailBody +='<TABLE style="COLOR: #2a94d6; BACKGROUND-COLOR: #2a94d6" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
					'<TR><TD style="FONT-SIZE: 6px; LINE-HEIGHT: 6px" bgColor=#2a94d6 height=6>&nbsp;</TD></TR></TBODY></TABLE>';


		emailBody +='<TABLE style="COLOR: #f2f2f2; BACKGROUND-COLOR: #f2f2f2" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
					'<TR> <TD style="FONT-SIZE: 25px; LINE-HEIGHT: 25px" bgColor=#f2f2f2 height=25>&nbsp;</TD></TR></TBODY></TABLE>';


		emailBody += '<TABLE class=backgroundTable cellSpacing=0 cellPadding=0 width="100%" align=center bgColor=#f2f2f2 border=0><TBODY> <TR> <TD align=center>\n';

		// // white horizontal space
		// emailBody += '<TABLE style="COLOR: #ffffff; BACKGROUND-COLOR: #ffffff" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
		// 			'<TR> <TD style="FONT-SIZE: 28px; LINE-HEIGHT: 28px" bgColor=#ffffff height=28>&nbsp;</TD></TR></TBODY></TABLE>';

		// // white horizontal space
		// emailBody += '<TABLE style="COLOR: #ffffff; BACKGROUND-COLOR: #ffffff" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
		// '<TR> <TD style="FONT-SIZE: 28px; LINE-HEIGHT: 28px" bgColor=#ffffff height=28>&nbsp;</TD></TR></TBODY></TABLE>';
		emailBody += '<TABLE  width=600 style="BACKGROUND-COLOR: #f2f2f2" cellSpacing=0 cellPadding=0 align=center bgColor=#f2f2f2 border=0> <TBODY> \n';
		emailBody += '<tr>\n ';
		emailBody +='<TR> <TD style="FONT-SIZE: 28px; LINE-HEIGHT: 28px" bgColor=#ffffff height=28>&nbsp;</TD></TR>';
		emailBody += '<td rowSpan="1" colSpan="1" style="font-family:' + fonts + '">';
		emailBody += '<TABLE class=container style="MAX-WIDTH: 600px; BACKGROUND-COLOR: #ffffff" cellSpacing=0 cellPadding=0 width="100%" border=0><tbody>';
		// white margin
		emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>';


		emailBody += '<td style="vertical-align:middle">'+
					'<span style="font-size:22px; font-family:'+fonts+'; font-weight:light">Hi '+currentUser.FirstName +', catch up on activity from the past '+dayOrWeek+'.</span></td>';

		// white margin
		emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>';

		emailBody += ' </tr></tbody></table></td></tr>';

		// emailBody +='<TR> <TD style="FONT-SIZE: 28px; LINE-HEIGHT: 28px" bgColor=#ffffff height=28>&nbsp;</TD></TR>';
		emailBody += '<td rowSpan="1" colSpan="1" style="font-family:' + fonts + '">';
		emailBody += '<TABLE class=container style="MAX-WIDTH: 600px; BACKGROUND-COLOR: #ffffff" cellSpacing=0 cellPadding=0 width="100%" border=0><tbody>';
		// white margin
		emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>';


		emailBody += '<td style="vertical-align:middle">'+
					'<span style="font-size:18px; font-family:'+fonts+'; font-weight:light">What I Follow</span></td>';

		// white margin
		emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>';

		emailBody += ' </tr></tbody></table></td></tr>';
		return emailBody;
	}

	public static String getEmailFooter() {
		String emailBody = '';
		emailBody +='<TR> <TD style="FONT-SIZE: 28px; LINE-HEIGHT: 28px" bgColor=#ffffff height=28>&nbsp;</TD></TR>';
		emailBody +='</TBODY></table></TBODY></table>\n</body></html>';
		return emailBody;
	}

	public static String getTopicBody(User currentUser, String topicName,  List<FeedItem> lsAllFeedItems, List<TopicAssignment> lsTopicAssignments, String dayOrWeek) {

		List<Id> lsAccountIds = new List<Id>();
		// List<TopicFeedItems> lsTopicAssignments = getTopicFeedItems();
		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';
		Integer amountOfFeedItems = 0;
		// lsBroadcastTopics = getBroadCastTopics();
		List<Topic> lsBroadcastTopics = getBroadCastTopics();

		// get a count of how many chatter posts mention this topic
		for(FeedItem fi : lsAllFeedItems) {
			if(dayOrWeek == 'day' && fi.CreatedDate < System.now().addDays(-1) ) {
				continue;
			}
			if(fi.Body.toLowerCase().contains('#'+topicName.toLowerCase())) {
				amountOfFeedItems++;
			}
		}
		// only add topic if it has chatter posts
		if(amountOfFeedItems>0) {
			Integer topicFeedItemCounter = 0;

			emailBody += '<table cellSpacing=0 cellPadding=0 width="100%" border=0><tbody><tr>';
			emailBody += '<TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>'+
			 				'<th  style="background-color: #eeeeee; height: 3em; font-size: 16px; padding: 1em; font-family:'+fonts+';" align="left">Topic:' + topicName +'</th>';
			emailBody += '<TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>';
			emailBody += '</tr>';
			Integer feedItemCounter = 0;
			for(FeedItem fi : lsAllFeedItems) {
				// for daily digest ignore older posts
				if(currentUser.AMP_Digest_Daily_or_Weekly__c == 'Daily' && fi.CreatedDate < System.now().addDays(-1) ) {
					continue;
				}
				if(fi.Body.toLowerCase().contains('#'+topicName.toLowerCase())) {
					topicFeedItemCounter++;
					lsAccountIds.add(fi.ParentId);
					// System.debug('this: '+ fi.Body + ' ' + fi.CreatedDate + ' ' + feedItemCounter);
					// System.debug('yes: '+  System.now().addDays(-1));
					if(feedItemCounter<lsAllFeedItems.size()-1) System.debug('next: '+ lsAllFeedItems[feedItemCounter+1].Body + ' ' + lsAllFeedItems[feedItemCounter+1].CreatedDate + ' ' + feedItemCounter);
						// see if the next post is the same for different parent
						if(	feedItemCounter < lsAllFeedItems.size()-1 &&
							fi.CreatedDate == lsAllFeedItems[feedItemCounter+1].CreatedDate &&
							fi.Body ==  lsAllFeedItems[feedItemCounter+1].Body) {
						}
						// only add post if the next one is not the same
						else {
							List<Topic> lsFITopics = new List<Topic>();
							for(Topic to : lsBroadcastTopics) {
								for(TopicAssignment ta : lsTopicAssignments) {
									if(to.Id == ta.TopicId && ta.EntityId == fi.Id) {
										lsFITopics.add(to);
									}
								}
							}
							emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD><td>';
							emailBody += getFeedItemBody(fi,  lsAccountIds,  lsFITopics, lsTopicAssignments);
							emailBody += '</td><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD></tr>';

							// add the separator if this was not the last feeditem uder the topic
							if(topicFeedItemCounter < amountOfFeedItems) {
								emailBody += feeditemSeparator();
							}


							lsAccountIds.clear();
						}
					}
					feedItemCounter++;
				}
			emailBody += '</tbody></table>';
		}
		return emailBody;
	}

	public static String getFeedItemBody(FeedItem fi, List<Id> lsAccountIds, List<Topic> lsTopics, List<TopicAssignment> lsTopicAssignments) {
		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';
		emailBody +='<table cellSpacing=0 cellPadding=0 width="100%" border=0><tbody>\n<tr>'+

			'<td rowspan="2" style="width:10%;background-color: #ffffff">'+
				'<img src="'+ getUserPhotoURL(fi.CreatedById) +'"  width="50" />'+
			'</td>'+
			'<td style="background-color: #ffffff; font-size=14px; font-family='+fonts+';vertical-align=middle"><SPAN style="TEXT-DECORATION: none; COLOR: #015ba7"><FONT color=#015ba7>'+
				fi.CreatedBy.FirstName + ' ' + fi.CreatedBy.LastName + '</FONT></SPAN></td></tr>';
		emailBody +='<tr><td style="background-color: #ffffff;font-size:12px; font-family:'+fonts+'"><SPAN style="TEXT-DECORATION: none; COLOR: #4f6a92"><FONT color=#4f6a92>' + fi.CreatedDate.format('EEEE MMMM d,  yyyy HH:mm') +'</FONT></SPAN></td>'+
					'</tr>';
		emailBody += '<tr><td colspan="2" style="background-color: #ffffff;font-size:12px; font-family:'+fonts+'">' + fi.Body + '</td></tr>\n';
		List<Topic> lsFITopics = new List<Topic>();
		List<Topic> lsBroadcastTopics = getBroadCastTopics();
		for(Topic to : lsBroadcastTopics) {
			for(TopicAssignment ta : lsTopicAssignments) {
				if(to.Id == ta.TopicId && ta.EntityId == fi.Id) {
					lsFITopics.add(to);
				}
			}
		}
		List<Account> lsHQAccounts = getHQAccounts();
		Map<Id, Account> mpAccountId2Account = new Map<Id,Account>();
		for(Account a: lsHQAccounts) {
			mpAccountId2Account.put(a.Id,a);
		}
		if(lsAccountIds.size()>0 && lsFITopics.isEmpty()) {
			emailBody += '<tr><td style="font-weight:bold;background-color: #ffffff">Accounts:</td><td style="background-color: #ffffff"> ';
			for(Id i : lsAccountIds) {
				emailBody += mpAccountId2Account.get(i).Name + ' ';
			}
			emailBody += '</td></tr>\n ';
		}
		if(lsFITopics.size()>0) {
			emailBody +='<tr>';
			emailBody += '<td style="font-weight:bold;background-color: #ffffff">Broadcast:</td><td style="background-color: #ffffff"> ';
			for(Topic to : lsFITopics) {
				emailBody += to.Name + ' ';
			}
			emailBody += '</td></tr>\n ';
		}
		emailBody +='</tbody></table>\n';
		return emailBody;
	}

	// this is the thin grey separator between feeditems under the same header
	public static String feeditemSeparator() {
		String emailBody = '';

		emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD><td >\n';

		emailBody += '<TABLE style="FONT-SIZE: 1px; LINE-HEIGHT: 1px" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>';
		emailBody += '<TR> <TD colspan="3" style="FONT-SIZE: 7px; LINE-HEIGHT: 7px; background-color: #ffffff"   bgColor=#ffffff height=7>&nbsp;</TD></TR>';
		emailBody += '<TR>\n';
		emailBody += '<TD style="background-color: #ffffff" class=defaultIndentation bgColor=#ffffff height=1 width=20>&nbsp;</TD>\n';
		emailBody += '<TD style="BORDER-TOP: #e0e5ee 1px solid" height=1>&nbsp;</TD>\n';
		emailBody += '<TD style="background-color: #ffffff" class=defaultIndentation bgColor=#ffffff height=1 width=20>&nbsp;</TD></TR>\n';
		emailBody += '<TR>\n';
		emailBody += '<TD colspan="3" style="FONT-SIZE: 15px; LINE-HEIGHT: 15px; background-color: #ffffff" bgColor=#ffffff height=15>&nbsp;</TD></TR></TBODY></TABLE>\n';

		emailBody += '</td><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD></tr>\n';
		return emailBody;
	}

	public static String getUserPhotoURL(String UserId) {
	    ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto(null, UserId);
	    return ph.fullEmailPhotoUrl;
	}

}
