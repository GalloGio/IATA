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
	
	//time range in minutes to include Feed Item createDate to compensate broadcast time skips
	private static Integer rangeInMinutes = Integer.ValueOf(Account_Management_Settings__c.getInstance().Topic_Digest_Time_Range_Aggregator__c);
	
	public AMP_ChatterTopicSubscribeController() {
		showPreview = false;
		if(ApexPages.currentPage().getParameters().get('showPreview') == '1') showPreview = true;

		currentUser = [SELECT Id, FirstName, LastName, SmallPhotoUrl, AMP_Digest_Topics__c, AMP_Digest_Daily_or_Weekly__c FROM User WHERE Id = :UserInfo.getUserId()];

		lsHQAccounts = getHQAccounts() ;
		lsAllFeedItems = getFeedItems(lsHQAccounts);

		lsTopicWrappers = getTopicWrappers();
		dailyOrWeekly = 'Daily';
		if(currentUser.AMP_Digest_Daily_or_Weekly__c != null && currentUser.AMP_Digest_Daily_or_Weekly__c == 'Weekly') {dailyOrWeekly = 'Weekly';}

		Map<Id, Account> mpAccountId2Account = getAccountId2Account(lsHQAccounts);
		lsTopicAssignments = getTopicAssignments(lsAllFeedItems);
		preview = getEmailBody(currentUser, lsAllFeedItems, lsTopicAssignments, mpAccountId2Account);
	}

	public static List<TopicAssignment> getTopicAssignments(List<FeedItem> lsAllFeedItems) {
		List<Topic> lsBroadcastTopics = getBroadCastTopics();
		return
			[SELECT Id, TopicId, EntityId, Topic.Name
			FROM TopicAssignment
			WHERE EntityId IN :lsAllFeedItems AND TopicId IN :lsBroadcastTopics
			LIMIT 10000];

	}

	public Map<Id, Account> getAccountId2Account(List<Account> lsHQAccounts) {
		Map<Id, Account> mpAccountId2Account = new Map<Id,Account>();
		for(Account a: lsHQAccounts) {
			mpAccountId2Account.put(a.Id,a);
		}
		return mpAccountId2Account;
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
		Map<Id, Account> mpAccountId2Account = getAccountId2Account(lsHQAccounts);
		preview = getEmailBody(currentUser, lsAllFeedItems, lsTopicAssignments, mpAccountId2Account, favouriteTopics, dayOrWeek);

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
			WHERE Type='TextPost' AND ParentId IN :lsAccounts AND CreatedDate = LAST_N_DAYS:7
			ORDER By CreatedDate Desc, Body
			LIMIT 10000];

		return lsFeedItem;
	}

	public static List<FeedItem> getDailyFeedItems(List<Account> lsAccounts) {
		// get the list of last week of Chatter messages to the list of accounts
		List<FeedItem> lsFeedItem =
			[SELECT Id, Body, ParentId, Type, CreatedDate, CreatedById,
				CreatedBy.FirstName, CreatedBy.LastName
			FROM FeedItem
			WHERE Type='TextPost' AND ParentId IN :lsAccounts AND CreatedDate = YESTERDAY
			ORDER By CreatedDate Desc, Body
			LIMIT 10000];

		return lsFeedItem;
	}

	public static List<Topic> getBroadCastTopics() {
		List<String> lsBroadcastTopicNames =
			new List<String>{	'Broadcast All Regions',
								'Broadcast Africa & Middle East',
								'Broadcast Americas',
								'Broadcast Asia & Pacific',
								'Broadcast China & North Asia',
								'Broadcast Europe'};
		return [SELECT Id,Name FROM Topic WHERE Name IN :lsBroadcastTopicNames];
	}

	/**
	Parameters:
	currentUser: the user who's viewing the VF page or being looped in the batch
	lsAllFeedItems: all feeditems that matched the query, not yet filtered for this user
	lsTopicAssignments: all the TopicAssignments for the lsAllFeedItems and Broadcast topics
	mpAccountId2Account: a map to get the Account with the Id
	**/
	public static String getEmailBody(User currentUser, List<FeedItem> lsAllFeedItems, List<TopicAssignment> lsTopicAssignments, Map<Id, Account> mpAccountId2Account) {

		String emailBody = '';
		// set the greeting to be either day or week
		String dayOrWeek = 'day';
		if(currentUser.AMP_Digest_Daily_or_Weekly__c == 'Weekly') dayOrWeek = 'week';
		List<String> lsFavouriteTopics = new List<String>();

		if(currentUser.AMP_Digest_Topics__c != null) {
			lsFavouriteTopics = currentUser.AMP_Digest_Topics__c.split(',');
		}
		emailBody += getEmailBody( currentUser,  lsAllFeedItems, lsTopicAssignments, mpAccountId2Account, lsFavouriteTopics,  dayOrWeek);
		return emailBody;
	}

	/**
	Parameters:
	currentUser: the user who's viewing the VF page or being looped in the batch
	lsAllFeedItems: all feeditems that matched the query, not yet filtered for this user
	lsTopicAssignments: all the TopicAssignments for the lsAllFeedItems and Broadcast topics
	mpAccountId2Account: a map to get the Account with the Id
	lsFavouriteTopics: the selected topics for this user
	dayOrWeek: literally 'day' or 'week'
	**/
	public static String getEmailBody(User currentUser, List<FeedItem> lsAllFeedItems, List<TopicAssignment> lsTopicAssignments, Map<Id,Account> mpAccountId2Account, List<String> lsFavouriteTopics, String dayOrWeek) {

		String emailBody = '';
		emailBody += getEmailHeader(currentUser, dayOrWeek);

		// List<Topic> lsBroadcastTopics = getBroadCastTopics();
		// List<TopicAssignment> lsTopicAssignments = [SELECT Id, TopicId, EntityId, Topic.Name FROM TopicAssignment WHERE EntityId IN :lsAllFeedItems AND TopicId IN :lsBroadcastTopics];
		String topicBody = '';
		for(String topicName : lsFavouriteTopics) {
			topicBody += getTopicBody(currentUser, topicName, lsAllFeedItems, mpAccountId2Account, lsTopicAssignments, dayOrWeek);
		}
		emailBody += topicBody;
		emailBody += getEmailFooter();

		// if we didn't get anything uder the favouriteTopics return empty
		if(topicBody == '') { emailBody = ''; }
		return emailBody;
	}

	public static String getEmailHeader(user currentUser, String dayOrWeek) {
		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';

		emailBody += '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">\n';
		emailBody += '<html xmlns="http://www.w3.org/1999/xhtml" lang="en" xml:lang="en">\n\n'+
						'<head>'+
    					'<meta http-equiv="Content-Type" content="text/html; charset=utf-8">'+
    					'<meta name="viewport" content="width=device-width">'+
    					'<title>layout email</title>';

		emailBody += '<style>'+
        '@media only screen {'+
            'html {'+
                'min-height: 100%;'+
                'background: #f2f2f2'+
            '}'+
						'}'+

        '@media only screen and (max-width:628px) {'+
            'table.body img {'+
                'width: auto;'+
                'height: auto'+
            '}'+
            'table.body center {'+
                'min-width: 0!important'+
            '}'+
            'table.body .container {'+
                'width: 95%!important'+
            '}'+
            'table.body .columns {'+
                'height: auto!important;'+
                '-moz-box-sizing: border-box;'+
                '-webkit-box-sizing: border-box;'+
                'box-sizing: border-box;'+
                'padding-left: 28px!important;'+
                'padding-right: 28px!important'+
            '}'+
            'table.body .columns .columns {'+
                'padding-left: 0!important;'+
                'padding-right: 0!important'+
            '}'+
            'table.body .collapse .columns {'+
                'padding-left: 0!important;'+
                'padding-right: 0!important'+
            '}'+
            'th.small-12 {'+
                'display: inline-block!important;'+
                'width: 100%!important'+
            '}'+
            '.columns th.small-12 {'+
                'display: block!important;'+
                'width: 100%!important'+
            '}'+
            'td.buttonWrapper {'+
		        'width: 98 !important;'+
		        'height: 23 !important;'+
		    '}'+
		    'a.button { width: 96 !important; }'+
		    'a.buttonWide { width: 118 !important; }'+
		    'a.buttonAuto { padding-left:1em !important; padding-right:1em !important;}'+
		    'a.button, a.buttonWide, a.buttonAuto {'+
		    	'height: 23 !important;'+
		        'line-height: 23px !important;'+
		        'border-radius: 4px !important;'+
		        '-webkit-border-radius: 4px !important;'+ 
		        '-moz-border-radius: 4px !important;'+
		    '}'+
		      
        '}'+
    '</style>';
		emailBody +=	'</head>';

		emailBody +=	'<body style="-moz-box-sizing:border-box;-ms-text-size-adjust:100%;'+
							'-webkit-box-sizing:border-box;-webkit-text-size-adjust:100%;Margin:0;'+
							'box-sizing:border-box;color:#000000;font-family:Helvetica,Arial,sans-serif;'+
							'font-size:14px;font-weight:400;line-height:1.3;margin:0;min-width:100%;'+
							'padding:0;text-align:left;width:100%!important">';

		// blue line on top
		emailBody +='<TABLE style="COLOR: #2a94d6; BACKGROUND-COLOR: #2a94d6" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
					'<TR><TD style="FONT-SIZE: 6px; LINE-HEIGHT: 6px" bgColor=#2a94d6 height=6>&nbsp;</TD></TR></TBODY></TABLE>';


		emailBody +='<TABLE style="COLOR: #f2f2f2; BACKGROUND-COLOR: #f2f2f2" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
					'<TR> <TD style="FONT-SIZE: 25px; LINE-HEIGHT: 25px" bgColor=#f2f2f2 height=25>&nbsp;</TD></TR></TBODY></TABLE>';

    	emailBody +='<table class="body" style="Margin:0;background:#f2f2f2;border-collapse:collapse;border-spacing:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;height:100%;line-height:1.3;margin:0;padding:0;text-align:left;vertical-align:top;width:100%">';
        emailBody +='<tr style="padding:0;text-align:left;vertical-align:top">';
        emailBody +=    '<td class="center" align="center" valign="top" style="-moz-hyphens:auto;-webkit-hyphens:auto;'+
			'Margin:0;border-collapse:collapse!important;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;hyphens:auto;line-height:1.3;margin:0;padding:0;text-align:left;vertical-align:top;word-wrap:break-word">';
        emailBody +='        <center data-parsed="" style="min-width:560px;width:100%">';




		emailBody +='<table align="center" class="container float-center" style="Margin:0 auto;background:#fff;border-collapse:collapse;border-spacing:0;float:none;margin:0 auto;padding:0px;text-align:center;vertical-align:top;width:560px">';
        emailBody +='  <tbody>';
        emailBody +='  <tr style="padding:0;text-align:left;vertical-align:top">';
        emailBody +='  <td style="-moz-hyphens:auto;-webkit-hyphens:auto;Margin:0;border-collapse:collapse!important;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;hyphens:auto;line-height:1.3;margin:0;padding:40px 20px;text-align:left;vertical-align:top;word-wrap:break-word">';

		emailBody +='<table class="row collapse collection" style="border-collapse:collapse;border-spacing:0;display:table;padding:0;position:relative;text-align:left;vertical-align:top;width:100%">';
        emailBody +='    <tbody>'+
                '<tr style="padding:0;text-align:left;vertical-align:top">'+
                    '<th class="wrapper small-12 large-12 columns first last" style="Margin:0 auto;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0 auto;padding:0;padding-bottom:0;padding-left:0;padding-right:0;text-align:left;width:560px">'+
                        '<table style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:100%">'+
                            '<tr style="padding:0;text-align:left;vertical-align:top">'+
                                '<th style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0;text-align:left">'+
                                    '<h1 style="Margin:0;Margin-bottom:10px;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:24px;font-weight:400;line-height:1.3;margin:0;margin-bottom:10px;padding:0;text-align:left">'+
										'Hi '+currentUser.FirstName+', catch up on activity for the past '+dayOrWeek+'</h1>'+
                                '</th>'+
                                '<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
                            '</tr>'+
                        '</table>'+
                    '</th>'+
                '</tr>'+
            '</tbody>'+
        '</table>';

		emailBody +='<table class="row collapse collection" style="border-collapse:collapse;border-spacing:0;display:table;padding:0;position:relative;text-align:left;vertical-align:top;width:100%">';
        emailBody +='    <tbody>'+
                '<tr style="padding:0;text-align:left;vertical-align:top">'+
                    '<th class="wrapper small-12 large-12 columns first last" style="Margin:0 auto;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0 auto;padding:0;padding-bottom:0;padding-left:0;padding-right:0;text-align:left;width:560px">'+
                        '<table style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:100%">'+
                            '<tr style="padding:0;text-align:left;vertical-align:top">'+
                                '<th style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0;text-align:left">'+
                                    '<h1 style="Margin:0;Margin-bottom:10px;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:18px;font-weight:400;line-height:1.3;margin:0;margin-bottom:10px;padding:0;text-align:left">'+
										'What I follow</h1>'+
                                '</th>'+
                                '<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
                            '</tr>'+
                        '</table>'+
                    '</th>'+
                '</tr>'+
            '</tbody>'+
        '</table>';
		emailBody += getSpacer(10);
		return emailBody;
	}

	public static String getEmailFooter() {
		String emailBody = '';
		emailBody += getSpacer(10);
		// emailBody +='<TR> <TD style="FONT-SIZE: 28px; LINE-HEIGHT: 28px" bgColor=#ffffff height=28>&nbsp;</TD></TR>';
		// emailBody +='</TBODY></table></TBODY></table>\n</body></html>';
		emailBody += '<table class="spacer" style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:100%">'+
                        '<tbody>'+
                            '<tr style="padding:0;text-align:left;vertical-align:top">'+
                                '<td style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0;text-align:left">'+
									'To change your email settings, click <a href="'+URL.getSalesforceBaseUrl().toExternalForm() + '/apex/AMP_ChatterTopicSubscribe">here</a>'+ // '+URL.getSalesforceBaseUrl().toExternalForm() + '
								'</td>'+
                            '</tr>'+
                        '</tbody>'+
                    '</table>';

		emailBody += getSpacer(10);
		emailBody +='</td>\n </tr></TBODY></table></table>';
		emailBody +='</center>';
		emailBody +='</td>\n </tr> </table>';
    	emailBody +='<!-- prevent Gmail on iOS font size manipulation -->';
    	emailBody +='<div style="display:none;white-space:nowrap;font:15px courier;line-height:0">'+
						'&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;'+
        				'&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;</div>';
		emailBody +='</body> </html>';
		return emailBody;
	}

	public static String getSpacer(Integer height) {
		String emailBody = '';
		emailBody += '<table class="spacer" style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:100%">'+
                        '<tbody>'+
                            '<tr style="padding:0;text-align:left;vertical-align:top">'+
                                '<td height="'+height+'px" style="-moz-hyphens:auto;-webkit-hyphens:auto;'+
									'Margin:0;border-collapse:collapse!important;color:#000000;font-family:Helvetica,Arial,sans-serif;'+
									'font-size:10px;font-weight:400;hyphens:auto;line-height:'+height+'px;margin:0;mso-line-height-rule:exactly;padding:0;'+
									'text-align:left;vertical-align:top;word-wrap:break-word">&#xA0;</td>'+
                            '</tr>'+
                        '</tbody>'+
                    '</table>';
		return emailBody;
	}

	/**
	Parameters:
	currentUser: the user who's viewing the VF page or being looped in the batch
	topicName: the name for the Topic we're building a table for
	lsAllFeedItems: all feeditems that matched the query, not yet filtered for this user
	mpAccountId2Account: a map to get the Account with the Id
	lsTopicAssignments: all the TopicAssignments for the lsAllFeedItems and Broadcast topics
	dayOrWeek: literally 'day' or 'week'
	**/
	public static String getTopicBody(User currentUser, String topicName, List<FeedItem> lsAllFeedItems, Map<Id,Account> mpAccountId2Account, List<TopicAssignment> lsTopicAssignments, String dayOrWeek) {

		List<Id> lsAccountIds = new List<Id>();
		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';
		Integer amountOfFeedItems = 0;
		
		// get a count of how many chatter posts mention this topic
		for(FeedItem fi : lsAllFeedItems) {
			if(dayOrWeek == 'day' && fi.CreatedDate < System.now().addDays(-1) ) {
				continue;
			}
			if(fi.Body.toLowerCase().contains('#'+topicName.toLowerCase())) {
				amountOfFeedItems++;
			}
		}

		if(amountOfFeedItems == 0) return '';
		// only add topic if it has chatter posts
		if(amountOfFeedItems>0) {
			Integer topicFeedItemCounter = 0;

			emailBody += '<table class="row collapse collection" style="border-collapse:collapse;border-spacing:0;display:table;padding:0;position:relative;text-align:left;vertical-align:top;width:100%">'+
                                '<tbody>'+
                                    '<tr style="padding:0;text-align:left;vertical-align:top;background:#f2f2f2;">'+
                                        '<th class="wrapper small-1 large-1 columns first" style="Margin:0 auto;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0 auto;padding-top:10px;padding-bottom:10px;padding-left:10px;padding-right:0;text-align:left;width:50px">'+
                                            '<table style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:430px">'+
                                                '<tr style="padding:0;text-align:left;vertical-align:top">'+
                                                    '<th style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:16px;font-weight:600;line-height:1.3;margin:0;padding:0;text-align:left">Topic: '+topicName+'</th>'+
                                                    '<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
                                                '</tr>'+
                                            '</table>'+
                                        '</th>'+
                                    '</tr>'+
                                '</tbody>'+
                            '</table>';


			Integer feedItemCounter = 0;
			Datetime timeRange = null;
			
			for(FeedItem fi : lsAllFeedItems) {
				// for daily digest ignore older posts
				if(dayOrWeek == 'day' && fi.CreatedDate < System.now().addDays(-1) ) {
					continue;
				}
				if(fi.Body.toLowerCase().contains('#'+topicName.toLowerCase())) {
					
					topicFeedItemCounter++;
					lsAccountIds.add(fi.ParentId);
					
					//aggregates each feed item created in this time range interval
					if(timeRange == null){
						timeRange = fi.CreatedDate;
						timeRange.addMinutes(rangeInMinutes);
					}
					
					// see if the next post is the same for different parent
					if(	feedItemCounter < lsAllFeedItems.size()-1 &&
						fi.CreatedDate <= timeRange &&
						fi.CreatedById == lsAllFeedItems[feedItemCounter+1].CreatedById &&
						fi.Body ==  lsAllFeedItems[feedItemCounter+1].Body) {
					}
					// only add post if the next one is not the same
					else {

						emailBody += getFeedItemBody(fi,  lsAccountIds, mpAccountId2Account, lsTopicAssignments, topicName);

						if(topicFeedItemCounter < amountOfFeedItems) {
							emailBody += feeditemSeparator();
						}

						lsAccountIds.clear();
						timeRange = null;
						
					}
				}
				feedItemCounter++;
			}
		}
		return emailBody;
	}

	/**
	Parameters:
	fi: the FeedItem we're building the line for
	lsAccountIds: the list of Accounts' Ids who received the same FeedItem
	mpAccountId2Account: a map to get the Account with the Id
	lsTopicAssignments: all the TopicAssignments for the lsAllFeedItems and Broadcast topics
	**/
	public static String getFeedItemBody(FeedItem fi, List<Id> lsAccountIds, Map<Id, Account> mpAccountId2Account, List<TopicAssignment> lsTopicAssignments, String topicName) {
		String fonts = '\'Salesforce Sans\', \'Helvetica Neue\', Helvetica, Arial, \'Sans Serif\'';
		String emailBody = '';
		emailBody += '<table class="row collapse collection" style="border-collapse:collapse;border-spacing:0;display:table;padding:0;position:relative;text-align:left;vertical-align:top;width:100%">'+
					'<tbody>'+
						'<tr style="padding:0;text-align:left;vertical-align:middle;">'+
							'<th class="wrapper small-1 large-1 columns first" style="Margin:0 auto;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0 auto;padding-top:10px;padding-bottom:10px;padding-left:10px;padding-right:0;text-align:left;width:50px">'+
								'<table style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:50px">'+
									'<tr style="padding:0;text-align:left;vertical-align:top">'+
										'<th style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0;text-align:left">'+
											'<img class=circle border=0 src="'+getUserPhotoURL(fi.CreatedById)+'" alt="'+fi.CreatedBy.FirstName +' ' + fi.CreatedBy.LastName+'"'+
												'style="-ms-interpolation-mode:bicubic;clear:both;display:block;max-width:100%;outline:0;text-decoration:none;" width=45 height=45></th>'+
										'<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
									'</tr>'+
								'</table>'+
							'</th>'+
							'<th class="wrapper small-11 large-11 columns last" style="Margin:0 auto;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0 auto;padding-top:10px;padding-bottom:10px;padding-left:0;padding-right:10px;text-align:left;width:430px">'+
								'<table id="informacao" style="border-collapse:collapse;border-spacing:0;padding:0;text-align:left;vertical-align:top;width:430px">'+
									'<tr style="padding:0;text-align:left;vertical-align:top">'+
										'<th style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:900;line-height:1.3;margin:0;padding:0;text-align:left">'+
											'<p style="Margin:0;margin-bottom:0px;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;margin-bottom:0px;padding:0 0 0 20px;text-align:left;width:430px;">'+
													+fi.CreatedBy.FirstName + ' ' + fi.CreatedBy.LastName+'</p>'+
											'<p style="Margin:0;margin-bottom:0px;color:#94a4bd;font-family:Helvetica,Arial,sans-serif;font-size:12px;font-weight:400;line-height:1.3;margin:0;margin-bottom:0px;padding:0 0 0 20px;text-align:left;width:430px;">'+
												fi.CreatedDate +
											'</p>'+
										'</th>'+
										'<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:10px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
									'</tr>'+
								'</table>'+
							'</th>'+
						'</tr>'+
						'<tr style="padding:0;text-align:left;vertical-align:top">'+
						// font-size:14px;font-weight:900;line-height:1.3;
							'<td colspan="2" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;margin:0;padding:0;text-align:left;white-space:normal;">'+
							fi.Body +
								// '<p style="Margin:0;margin-bottom:0px;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;margin-bottom:0px;padding:0 0 0 10px;text-align:left;width:430px;">'+
								// '</p>'+
							'</td>'+
							'<td class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:10px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></td>'+
					'</tr>';

		List<String> lsFITopics = new List<String>();
		for(TopicAssignment ta : lsTopicAssignments) {
			if(ta.EntityId == fi.Id) {
				lsFITopics.add(ta.Topic.Name);
			}
		}
		
		String remainingURL = '';
		
		if(lsAccountIds.size()>0 && lsFITopics.isEmpty()) {
			emailBody += '<tr style="padding:0;text-align:left;vertical-align:top">'+
							'<th colspan="2" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:900;line-height:1.3;margin:0;padding:0;text-align:left;white-space:normal;">'+
							'<p style="Margin:0;margin-bottom:0px;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;'+
							'margin:0;margin-bottom:0px;padding:0 0 0 0px;text-align:left;width:430px;">Account(s): ';

			for(Id i : lsAccountIds) {
				emailBody += mpAccountId2Account.get(i).Name + ' ';
			}
			
			emailBody += '</p></th>'+
			'<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:10px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
			'</tr>';

			remainingURL = lsAccountIds.size() > 1 ? ('/apex/AMP_ReplyToPostFromDigestByTopic?topic=' + topicName + '&feedItemId=' + fi.Id) : ('/' + fi.Id);
			
		}
		
		if(lsFITopics.size()>0) {
			emailBody += '<tr style="padding:0;text-align:left;vertical-align:top">'+
							'<th colspan="2" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:900;line-height:1.3;margin:0;padding:0;text-align:left">'+
					'<p style="Margin:0;margin-bottom:0px;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:14px;font-weight:400;line-height:1.3;margin:0;margin-bottom:0px;padding:0 0 0 0px;text-align:left;width:430px;">Broadcast: ';

			for(String to : lsFITopics) {
				emailBody += to + ' ';
			}
			emailBody += '</p></th>'+
			'<th class="expander" style="Margin:0;color:#000000;font-family:Helvetica,Arial,sans-serif;font-size:10px;font-weight:400;line-height:1.3;margin:0;padding:0!important;text-align:left;visibility:hidden;width:0"></th>'+
			'</tr>';
			
			remainingURL = '/apex/AMP_ReplyToPostFromDigestByTopic?topic=' + topicName + '&feedItemId=' + fi.Id;
			
		}
		
		if(String.isNotBlank(remainingURL)){
			emailBody += '  <br/>';
			emailBody +=' 	<tr>';
			emailBody +=' 		<td class="" style="font-family: Salesforce Sans, Helvetica Neue, Helvetica, Arial, Sans Serif; font-size: 14px;" width="116">';
			emailBody +=' 			<span class="">';
			emailBody +=' 				<a href="'+ URL.getSalesforceBaseUrl().toExternalForm() + remainingURL + '" class="" target="_blank"><span class="text" style="white-space: nowrap;"><b>Respond</b></span></a>';
			emailBody +=' 			</span>';
			emailBody +=' 		</td>';
			emailBody +='	</tr>';
		}
		
		emailBody +='</tbody></table>\n';
		return emailBody;
	}

	// this is the thin grey separator between feeditems under the same header
	public static String feeditemSeparator() {
		String emailBody = '';

		// emailBody += '<tr><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD><td >\n';

		emailBody += '<TABLE style="FONT-SIZE: 1px; LINE-HEIGHT: 1px" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>';
		emailBody += '<TR> <TD colspan="3" style="FONT-SIZE: 7px; LINE-HEIGHT: 7px; background-color: #ffffff"   bgColor=#ffffff height=7>&nbsp;</TD></TR>';
		emailBody += '<TR>\n';
		emailBody += '<TD style="background-color: #ffffff" class=defaultIndentation bgColor=#ffffff height=1 width=20>&nbsp;</TD>\n';
		emailBody += '<TD style="BORDER-TOP: #e0e5ee 1px solid" height=1>&nbsp;</TD>\n';
		emailBody += '<TD style="background-color: #ffffff" class=defaultIndentation bgColor=#ffffff height=1 width=20>&nbsp;</TD></TR>\n';
		emailBody += '<TR>\n';
		emailBody += '<TD colspan="3" style="FONT-SIZE: 15px; LINE-HEIGHT: 15px; background-color: #ffffff" bgColor=#ffffff height=15>&nbsp;</TD></TR></TBODY></TABLE>\n';

		// emailBody += '</td><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD></tr>\n';
		return emailBody;
	}

	public static String getUserPhotoURL(String UserId) {
		if(Test.isRunningTest()) return '';
	    ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto(null, UserId);
	    return ph.fullEmailPhotoUrl;
	}

}
