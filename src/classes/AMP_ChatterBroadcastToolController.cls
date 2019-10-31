public with sharing class AMP_ChatterBroadcastToolController {

	public Boolean showNotApplicableMsg {get; set;}

	public Integer step {get; set;}

	public String message {get; set;}

	public String accountId {get; set;}

	public String strAcctList {get{
			String tmpStr = '';
			numberOfAccounts = 0;
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

			// make a list of regions, fetch existing and create missing topics
			List<String> lsBroadcastTopicNames =
			new List<String>{'Broadcast All Regions',
			'Broadcast Africa & Middle East',
			'Broadcast Americas',
			'Broadcast Asia & Pacific',
			'Broadcast China & North Asia',
			'Broadcast Europe'};
			List<Topic> lsBroadcastTopics = [SELECT Id,Name FROM Topic WHERE Name IN :lsBroadcastTopicNames];

			SavePoint sp = Database.setSavepoint();
			
			try {

				insert lstItemsToPost;

				// after inserting the actual feeditems create and insert the broadcast topic assignments
				List<TopicAssignment> lsTopicAssignments = new List<TopicAssignment>();
				for(FeedItem fi : lstItemsToPost) {
					if(fi.Id != null && selectWholeRegion) {
						if(strRegion == null || strRegion == '') {
							strRegion = 'All Regions';
						}
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

				if(!lsTopicAssignments.isEmpty()) { 
					insert lsTopicAssignments; 
				}

				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'The message was successfully broadcasted.'));
					step = 3;

			} catch (Exception e) {
				System.debug(LoggingLevel.FINE, '____ [cls AMP_ChatterBroadcastToolController - broadcastMessage] Exception: ' + e.getMessage());
				
				if(!ApexPages.hasMessages(ApexPages.Severity.ERROR)){
					//Only exhibits the message if it was not thrown an error before (e.g. trigger addError)
					ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'The message failed to be broadcasted.'));
				}
				
				Database.rollback(sp);
				
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
