public class AMP_ReplyToPostFromDigestByTopic {
	
	public class FeedItemWrapper {
		
		public FeedItem feedItem {get; set;}
		public Boolean isSelected {get; set;}
		
		public FeedItemWrapper(FeedItem feedItem){
			this.feedItem = feedItem;
			this.isSelected = false;
		}
		
	}

	public Integer step {get; set;}
	public String message {get; set;}
	public String acctListStr {get; set;}
	public String createdDate {get; set;}
	public String commentBody {get; set;}
	public String userPhotoURL  {get; set;}
	public String createdByName {get; set;}
	public Integer numberOfAccounts {get; set;}
	public List<FeedItemWrapper> feedItemAccountLst {get; set;}

	private Id mainFeedId;
	private List<FeedItem> feedItemLst;
	private List<FeedItemWrapper> selectedFeedItemAccountLst;

	public AMP_ReplyToPostFromDigestByTopic(){
		
		try {
			
			this.feedItemLst		 		 = new List<FeedItem>();
			this.feedItemAccountLst			 = new List<FeedItemWrapper>();
			this.selectedFeedItemAccountLst	 = new List<FeedItemWrapper>();
			
			this.mainFeedId = Id.valueOf(ApexPages.CurrentPage().getParameters().get('feedItemId'));
			
			init();
			
		}
		catch(Exception e){
			system.debug(LoggingLevel.ERROR, '____ [cls AMP_ReplyToPostFromDigestByTopic - constructor] Exception: ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Unable to fetch Feed Item\'s related Accounts.'));
		}
		
	}
	
	private void init(){
		
		
		//Fetch the "main" feed item record
		FeedItem fi = 
			[SELECT 
				Id, 
				Body,
				CreatedById,
				CreatedDate
			 FROM 
			 	FeedItem 
			 WHERE 
			 	Id = :mainFeedId
			];
			
		Integer rangeInMinutes = Integer.ValueOf(Account_Management_Settings__c.getInstance().Topic_Digest_Time_Range_Aggregator__c);

		DateTime timeRange = fi.CreatedDate.addMinutes(rangeInMinutes);
		
		//Fetch all the feed items that were created 
		//at the same time as the "main" one (fi)
		List<FeedItem> targetItemsLst = new List<FeedItem>(
			[SELECT
				Id,
				Body,
				ParentId,
				Parent.Name,
				CreatedById,
				CreatedDate,
				CreatedBy.Name
			 FROM
			 	FeedItem
			 WHERE
			 	CreatedDate >= :fi.CreatedDate
			 AND
			 	CreatedDate <= :timeRange
			 AND
			 	CreatedById = :fi.CreatedById
			]
		);
		
		//For each feed item checks if the 
		//content of the post is the same
		//as the "main" feed item (fi)
		for(FeedItem item : targetItemsLst){
			
			if(item.Body == fi.Body){
				
				//Assigns the main topic information from the first value found
				if(this.commentBody == null) this.commentBody = item.Body;
				if(this.createdDate == null) this.createdDate = item.CreatedDate.format('yyyy-MM-dd HH:mm:ss');
				if(this.createdByName == null) this.createdByName = item.CreatedBy.Name;
				if(this.userPhotoURL == null) this.userPhotoURL = AMP_ChatterTopicSubscribeController.getUserPhotoURL(item.CreatedById);
				
				this.feedItemLst.add(item);

			}
			
		}
		
		feedItemLst.sort();
		
		reloadFeedItems();

		this.step = 1;
		
	}

	private void reloadFeedItems(){
		
		this.feedItemAccountLst.clear();
		this.selectedFeedItemAccountLst.clear();
		this.numberOfAccounts = 0;
		
		for(FeedItem feedItem : this.feedItemLst){
			FeedItemWrapper aw = new FeedItemWrapper(feedItem);
			this.feedItemAccountLst.add(aw);			
		}
		
	}
	
	public PageReference postReplyMessages(){
		
		if(String.isBlank(message)){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please insert the comment.'));
			return null;
		}
		
		try {
			
			List<FeedComment> feedCommentLst = new List<FeedComment>();
			
			//For each selected account in the page creates a new FeedComment
			for(FeedItemWrapper aw : this.selectedFeedItemAccountLst){
				
				FeedComment feedComment = new FeedComment();
	
				feedComment.CommentBody = this.message;
				feedComment.FeedItemId = aw.feedItem.Id;
				feedComment.CommentType = 'TextComment';
	
				feedCommentLst.add(feedComment);
				
			}
			
			if(!feedCommentLst.isEmpty()){
				insert feedCommentLst;
			}
			
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'The comments were successfully posted.'));

			step = 3;
			
		}
		catch(Exception e){
			System.debug(LoggingLevel.ERROR, '____ [cls AMP_ReplyToPostFromDigestByTopic - postReplyMessages] Exception: ' + e.getMessage());
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'The comments failed to be posted.'));
		}
		
		return null;
	}
	
	public PageReference nextStep(){
		
		this.acctListStr = '';
		this.numberOfAccounts = 0;
		this.selectedFeedItemAccountLst.clear();
		
		//Exhibit the name of the selected accounts 
		//as well as the total number of selected accounts 
		for(FeedItemWrapper acctWrap : this.feedItemAccountLst){
			
			if(acctWrap.isSelected){
				this.acctListStr += ((this.acctListStr != '' ? ', ' : '') + acctWrap.feedItem.Parent.Name);
				selectedFeedItemAccountLst.add(acctWrap);
				numberOfAccounts++;
			}
			
		}
		
		if(this.selectedFeedItemAccountLst.isEmpty()){
			ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR, 'Please select at least one account from the list.'));
			return null;
		}
		
		this.step = 2;
		
		return null;
		
	}

	public PageReference restartFromStep1(){
		this.message = '';
		this.acctListStr = '';
		this.numberOfAccounts = 0;
		reloadFeedItems();
		this.step = 1;
		return null;
	}
	
	public PageReference previousStep(){
		this.step = 1;
		return null;
	}
	
}