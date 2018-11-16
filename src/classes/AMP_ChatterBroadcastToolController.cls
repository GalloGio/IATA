public with sharing class AMP_ChatterBroadcastToolController {

	public Boolean showNotApplicableMsg {get; set;}

	public Integer step {get; set;}
	
	public String message {get; set;}

	public String accountId {get; set;}

	public String strAcctList {get{
			String tmpStr = '';
			for (AccountWrapper aw : lstAccounts) {
				if (aw.isSelected) {
					tmpStr += (tmpStr != '' ? ', ' : '') + aw.acct.Name;
					numberOfAccounts++;
				}
			}

			return tmpStr;
		} set;}

	public list<AccountWrapper> lstAccounts {get; set;}
	public Integer numberOfAccounts {get; set;}

	public String strRegion {get; set;}

	public String broadCastRegion {get;set;}
	public Boolean selectWholeRegion {get;set;} 

	public List<SelectOption> getlstRegions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','All Regions'));
        options.add(new SelectOption('Africa & Middle East','Africa & Middle East'));
        options.add(new SelectOption('Americas','Americas'));
        options.add(new SelectOption('Asia & Pacific','Asia & Pacific'));
        options.add(new SelectOption('China & North Asia','China & North Asia'));
        options.add(new SelectOption('Europe','Europe'));
        return options;
    }


    public void GoToStep2 () {
    	if (strAcctList == '') {
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least 1 Account from the list.'));

		} else {
			step = 2;
		}    	
    }

    public void GoBackToStep1 () {
    	step = 1;
    }

    public void RestartFromStep1 () {
    	step = 1;
    	message = '';
    	strRegion = '';
    	RefreshAccountsList();
    }

    public void BroadcastMessage () {
    	if (message == null || message == '') {
    		ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please type in the message to broadcast.'));
		} else {

			try {

				list<FeedItem> lstItemsToPost = new list<FeedItem>();

				for (AccountWrapper aw : lstAccounts) {
					if (aw.isSelected) {
						FeedItem newPost = new FeedItem();
						newPost.ParentId = aw.acct.Id;
						newPost.Body = message;
						newPost.Type = 'TextPost';

						lstItemsToPost.add(newPost);
					}
				}

				List<String> lsBroadcastTopicNames = new List<String>{'broadcastAll Regions',
				'broadcastAfrica & Middle East',
				'broadcastAmericas',
				'broadcastAsia & Pacific',
				'broadcastChina & North Asia',
				'broadcastEurope'};
				// broadcastTopicNames = '';
				List<Topic> lsBroadcastTopics = [SELECT Id,Name FROM Topic WHERE Name IN :lsBroadcastTopicNames];


				Database.SaveResult[] srList = Database.insert(lstItemsToPost, false);

				List<TopicAssignment> lsTopicAssignments = new List<TopicAssignment>();
				for(FeedItem fi : lstItemsToPost) {
					if(selectWholeRegion) {
						for(Topic t :lsBroadcastTopics) {
							if(t.Name.contains(strRegion)) {
								TopicAssignment ta = new TopicAssignment();
								ta.TopicId = t.Id;
								ta.EntityId = fi.Id;
								lsTopicAssignments.add(ta);
							}
						}
					}
				}

				if(!lsTopicAssignments.isEmpty()) { insert lsTopicAssignments; }
	    		Integer success = 0;
	    		Integer errors = 0;
	    		for (Database.SaveResult sr : srList) {
	    			if (sr.isSuccess()) {
	    				success ++;
	    			} else {
	    				errors ++;
	    			}
	    		}

	    		if (success > 0) {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The message was successfully broadcasted.')); // to ' + success + ' account(s) out of ' + lstItemsToPost.size() + '. ' + errors + ' error(s) encountered.'));
					step = 3;
				} else {
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The message failed to be broadcasted.'));// with ' + errors + ' error(s) when trying to post.'));
				}


			} catch (Exception e) {
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
			}
		}
    }

    public void RefreshAccountsList () {
    	list<Account> tmpList = new list<Account>();
		
		if (strRegion != null && strRegion != '') {
			tmpList = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'IATA_Airline' AND Membership_status__c = 'IATA Member' AND Region_formula__c = :strRegion ORDER BY Name];
		} else {
			tmpList = [SELECT Id, Name FROM Account WHERE RecordType.DeveloperName = 'IATA_Airline' AND Membership_status__c = 'IATA Member' ORDER BY Name];
		}

		list<AccountWrapper> lstFilteredAccounts = new list<AccountWrapper>();
		for (Account acc : tmpList) {
			AccountWrapper aw = new AccountWrapper();
			aw.acct = acc;
			aw.isSelected = false;

			lstFilteredAccounts.add(aw);
		}
		numberOfAccounts = 0;
		lstAccounts = lstFilteredAccounts;
    }
    
	public AMP_ChatterBroadcastToolController() {
		
		accountId =  ApexPages.currentPage().getParameters().get('accountId');
		
		Account acct = 
			[SELECT 
				Id, 
				Membership_status__c
			 FROM 
			 	Account 
			 WHERE 
			 	Id = :accountId
			];
		
		showNotApplicableMsg = acct.Membership_status__c != 'IATA member';
		
		// Chatter broadcast tool is only available for IATA Members Airlines
		if(!showNotApplicableMsg){
			step = 1;
			numberOfAccounts = 0;
			strRegion = '';
			RefreshAccountsList();
		}
		
	}

	public class AccountWrapper {
		public Account acct {get; set;}
		public Boolean isSelected {get; set;}
	}
}