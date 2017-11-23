public class ANG_RiskEventHistoryPagination {

	private List<ANG_Agency_Risk_Event__c> allRecords;
	private List<List<RiskEvent>> pages{
		get{
			if(pages == null) pages = new List<List<RiskEvent>>();
			return pages;
		}
		private set;
	}

	public ANG_RiskEventHistoryPagination() {
		pageNumber = 1;
		pageSize = 5;
	}

	public ANG_RiskEventHistoryPagination(List<ANG_Agency_Risk_Event__c> records) {
		this();		

		this.allRecords = records;
		createPages();
	}

	private void createPages(){
		pages = new List<List<RiskEvent>>();
		pages.add(new List<RiskEvent>());

		//add map to check if a risk event needs multiple entries
		Map<String, RiskEvent> riskEvents = new Map<String, RiskEvent>();

		for(ANG_Agency_Risk_Event__c risk : allRecords){
			List<RiskEvent> page = pages[totalPages-1];

			String identifier = risk.ANG_Source_Id__c+risk.ANG_Risk_Type__c;
			if(risk.ANG_Event_Status__c == ANG_Risk_Helper.STATUS_MIGRATED && risk.ANG_Risk_ID__c == '6') identifier = ''+risk.ANG_Issued_Date__c+risk.ANG_Risk_Type__c; //for migrated Risk Events of Major changes, all the hierarchy must be shown on the same level

			System.debug(loggingLevel.FINE, '____ [cls ANG_RiskEventHistoryPagination - createPages] risk.ANG_Event_Status__c ' + risk.ANG_Event_Status__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_RiskEventHistoryPagination - createPages] risk.ANG_Risk_ID__c - ' + risk.ANG_Risk_ID__c);
			System.debug(loggingLevel.FINE, '____ [cls ANG_RiskEventHistoryPagination - createPages] identifier - ' + identifier);

			if(riskEvents.containsKey(identifier)) riskEvents.get(identifier).addAccount(risk.ANG_AccountId__c);
			else{
				RiskEvent newRisk = new RiskEvent(risk);

				page.add(newRisk);
				riskEvents.put(identifier, newRisk);

				totalRecords++;
			}

			//adding a new page once size is reached
			if(page.size() == pageSize)	pages.add(new List<RiskEvent>());
		}

		//remove last page if empty
		if(pages[totalPages-1].isEmpty()) pages.remove(totalPages-1);
	}

	//state variables

	public Integer totalRecords { 
		get{
			if(totalRecords == null) totalRecords = 0;
			return totalRecords;
		}
		private set;
	}
	public Integer pageNumber {
		get;
		set{
			if (value <= 1) pageNumber = 1;
			else if(value > totalPages) pageNumber = totalPages;
			else pageNumber = value;
		}
	}

	public Integer totalPages{
		get{
			return pages.size();
		}
	}
	public Integer pageSize {
		get;
		private set;
	}

	public Boolean hasNext{
		get{
			return pageNumber < totalPages;
		}
	}
	public Boolean hasPrevious{
		get{
			return pageNumber > 1;
		}
	}

	//page methods
	public void first(){
		pageNumber = 1;
	}
	public void next(){
		if(hasNext) pageNumber++;
	}
	public void previous(){
		if(hasPrevious) pageNumber--;
	}
	public void last(){
		pageNumber = totalPages;
	}

	//access methods
	public List<RiskEvent> getRecords(){
		if(pages.isEmpty()) return new List<RiskEvent>();
		return pages[pageNumber-1];
	}

	public void setPageSize(Integer value){
		if (value < 1) pageSize = 1;
		else pageSize = value;

		createPages();
	}

	//Wrapper
	public class RiskEvent {
		public List<Id> accountsInvolved { get; set; }
		public ANG_Agency_Risk_Event__c risk { get; set; }

		public RiskEvent(ANG_Agency_Risk_Event__c risk){
			this.risk = risk;
			accountsInvolved = new List<Id>{risk.ANG_AccountId__c};

			System.debug(loggingLevel.FINEST, '____ [cls ANG_RiskEventHistoryPagination - RiskEvent constructor] risk.Name - ' + risk.Name);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_RiskEventHistoryPagination - RiskEvent constructor] accountsInvolved - ' + accountsInvolved);
		}

		public void addAccount(Id accId){
			accountsInvolved.add(accId);

			System.debug(loggingLevel.FINEST, '____ [cls ANG_RiskEventHistoryPagination - addAccount] risk.Name - ' + risk.Name);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_RiskEventHistoryPagination - addAccount] accountsInvolved - ' + accountsInvolved);
		}
	}
}
