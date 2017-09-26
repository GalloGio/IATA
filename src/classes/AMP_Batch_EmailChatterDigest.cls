global class AMP_Batch_EmailChatterDigest implements Database.Batchable<sObject>, Database.Stateful {

	public String query;

	// variables
	public List<Account> lsHQAccounts;
	public Map<Id,Account> mpAccountId2Account;
	public Map<Id,String> mpUserId2PictureURL;
	// public List<AMP_ChatterTopicSubscribeController.TopicFeedItems> lsTopicFeedItems;
	// List<AMP_ChatterTopicSubscribeController.TopicWrapper> lsTopicWrappers;
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
		// // get the number for the day of the Week: Sunday 0, Monday 1..
		// Integer dayOfWeek = Integer.valueOf(System.now().format('u'));
		lsHQAccounts = AMP_ChatterTopicSubscribeController.getHQAccounts();
		mpAccountId2Account = new Map<Id,Account>();
		for(Account a : lsHQAccounts) {
			mpAccountId2Account.put(a.Id, a);
		}
		System.debug(dailyOrWeekly);
		query = 'SELECT Id, FirstName, LastName, Email, AMP_Digest_Topics__c, '+
				'AMP_Digest_Daily_or_Weekly__c FROM User WHERE AMP_Digest_Daily_or_Weekly__c=\'Daily\'';
		if(dailyOrWeekly == 'weekly') {
			query += ' OR AMP_Digest_Daily_or_Weekly__c=\'Weekly\'';
			lsAllFeedItems = AMP_ChatterTopicSubscribeController.getFeedItems(lsHQAccounts);
		} else {
			lsAllFeedItems = AMP_ChatterTopicSubscribeController.getDailyFeedItems(lsHQAccounts);
		}
		System.debug(query);
		lsBroadcastTopics = AMP_ChatterTopicSubscribeController.getBroadCastTopics();
		lsTopicAssignments = [SELECT Id, TopicId, EntityId FROM TopicAssignment WHERE EntityId IN :lsAllFeedItems AND TopicId IN :lsBroadcastTopics];
		List<User> lsUsers = AMP_ChatterTopicSubscribeController.getPosters(lsAllFeedItems);
		mpUserId2PictureURL = new Map<Id,String>();
		for(User u : lsUsers) {
			mpUserId2PictureURL.put(u.Id, u.SmallPhotoUrl);
		}
		// System.debug(lsAllFeedItems);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<User> lsUsers) {
		// System.debug(lsHQAccounts);
		System.debug('execute');
		System.debug(dailyOrWeekly);
		// Send an email
		List<Messaging.SingleEmailMessage> lsEmails = new List<Messaging.SingleEmailMessage>();
		// User u = [SELECT Id, FirstName, LastName, Name, Email, AMP_Digest_Topics__c, AMP_Digest_Daily_or_Weekly__c FROM User WHERE Id='005w0000003Pu27'];
		for(User u : lsUsers) {
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			String[] toAddresses = new String[] {u.Email};
			mail.setToAddresses(toAddresses);
			mail.setSubject('Chatter digest ');
			String emailBody = getEmailBody(u);
			mail.setHtmlBody(emailBody);
			System.debug(getEmailBody(u));
			if (emailBody != '') lsEmails.add(mail);

		}
		Messaging.sendEmail(lsEmails);
	}

	private String getEmailBody(User currentUser) {
		// get the number for the day of the Week: Sunday 0, Monday 1..
		Integer dayOfWeek = Integer.valueOf(System.now().format('u'));
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

		List<String> lsFavouriteTopics = new List<String>();
		Set<String> stFavouriteTopics = new Set<String>();

		// blue line on top
		emailBody +='<TABLE style="COLOR: #2a94d6; BACKGROUND-COLOR: #2a94d6" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
					'<TR><TD style="FONT-SIZE: 6px; LINE-HEIGHT: 6px" bgColor=#2a94d6 height=6>&nbsp;</TD></TR></TBODY></TABLE>';


		emailBody +='<TABLE style="COLOR: #f2f2f2; BACKGROUND-COLOR: #f2f2f2" cellSpacing=0 cellPadding=0 width="100%" border=0><TBODY>'+
					'<TR> <TD style="FONT-SIZE: 25px; LINE-HEIGHT: 25px" bgColor=#f2f2f2 height=25>&nbsp;</TD></TR></TBODY></TABLE>';

		// we take the user setting and convert it to a Set of Strings
		// to avoid problems of just string.contains()
		if(currentUser.AMP_Digest_Topics__c != null) {
			lsFavouriteTopics = currentUser.AMP_Digest_Topics__c.split(',');
		}
		String dayOrWeek = 'day';
		if(currentUser.AMP_Digest_Daily_or_Weekly__c == 'Weekly') dayOrWeek = 'week';
		List<Id> lsAccountIds = new List<Id>();

		emailBody += '<TABLE class=backgroundTable cellSpacing=0 cellPadding=0 width="100%" align=center bgColor=#f2f2f2 border=0><TBODY> <TR> <TD align=center>\n';
		emailBody += '<TABLE  width=600 style="BACKGROUND-COLOR: #f2f2f2" cellSpacing=0 cellPadding=0 align=center bgColor=#f2f2f2 border=0> <TBODY> \n';
		emailBody += '<tr>\n ';

		// emailBody += '<TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD>   <td style="font-family: ' + fonts + '" >';
		emailBody += '<td rowSpan="1" colSpan="1">';
		// emailBody += '<TABLE class=container style="MAX-WIDTH: 600px; BACKGROUND-COLOR: #ffffff" cellSpacing=0 cellPadding=0 align=center bgColor=#ffffff border=0>';
		// emailBody += '<TR> <TD align=left><!-- Start Body --> <TABLE style="box-shadow: 0px 2px 3px 0px rgba(0,0,0,0.14)" cellSpacing=0 cellPadding=0 width="100%" border=0> <TBODY>';
		// emailBody += '    <div style="padding-left: 0; padding-right: 0; padding-top: 0; padding-bottom: 0; margin-left: 0; margin-right: 0; margin-top: 0; margin-bottom: 0; font-size: 14px; font-family: '+fonts+';" class="text">  <span style="font-size: 24px;font-weight:light;text-align:center">';
		emailBody += '<span emloc="_salutation_"><center>Hi '+currentUser.FirstName +', catch up on activity from the past '+dayOrWeek+'.</center></span></span> </div> </td> </tr>';
		emailBody += '<tr><td>';

		String topicBody = '';
		for(String t : lsFavouriteTopics) {
			topicBody += getTopicBody(currentUser, t, lsAccountIds);
		}
		emailBody += topicBody;
		emailBody += '</td><TD class=defaultIndentation bgColor=#ffffff width=20>&nbsp;</TD> </tr></TBODY></table></TBODY></table>\n';
		emailBody +='</body></html>';

		if(topicBody == '') { emailBody = ''; }
		return emailBody;
	}

	private String getTopicBody(User currentUser, String topicName, List<Id> lsAccountIds) {
		String emailBody = '';
		Integer amountOfFeedItems = 0;
		// get a count of how many chatter posts mention this topic
		for(FeedItem fi : lsAllFeedItems) {
			if(currentUser.AMP_Digest_Daily_or_Weekly__c == 'Daily' && fi.CreatedDate < System.now().addDays(-1) ) {
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
			 				'<th  style="background-color: #eeeeee; height: 3em; font-size: 130%; margin-bottom: 1em;" align="left">' + topicName +'</th>';
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
							emailBody += getFeedItemBody(fi,  lsAccountIds,  lsFITopics);
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

	private String getFeedItemBody(FeedItem fi, List<Id> lsAccountIds, List<Topic> lsTopics) {
		String emailBody = '';
		emailBody +='<table cellSpacing=0 cellPadding=0 width="100%" border=0><tbody>\n<tr>'+

			'<td rowspan="2" style="width:10%;background-color: #ffffff">'+
				'<img src="'+ getUserPhotoURL(fi.CreatedById) +'"  width="50" />'+
			'</td>'+
			'<td style="background-color: #ffffff"><SPAN style="TEXT-DECORATION: none; COLOR: #015ba7"><FONT color=#015ba7>'+
				fi.CreatedBy.FirstName + ' ' + fi.CreatedBy.LastName + '</FONT></SPAN></td></tr>';
		emailBody +='<tr><td style="background-color: #ffffff"><SPAN style="TEXT-DECORATION: none; COLOR: #4f6a92"><FONT color=#4f6a92>' + fi.CreatedDate.format('EEEE MMMM d,  yyyy HH:mm') +'</FONT></SPAN></td>'+
					'</tr>';
		emailBody += '<tr><td colspan="2" style="background-color: #ffffff">' + fi.Body + '</td></tr>\n';
		List<Topic> lsFITopics = new List<Topic>();
		for(Topic to : lsBroadcastTopics) {
			for(TopicAssignment ta : lsTopicAssignments) {
				if(to.Id == ta.TopicId && ta.EntityId == fi.Id) {
					lsFITopics.add(to);
				}
			}
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

	private String feeditemSeparator() {
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

	public String getUserPhotoURL(String UserId) {
	    ConnectApi.Photo ph =  ConnectApi.UserProfiles.getPhoto(null, UserId);
	    return ph.fullEmailPhotoUrl;
	}

	global void finish(Database.BatchableContext BC) {

	}

}
