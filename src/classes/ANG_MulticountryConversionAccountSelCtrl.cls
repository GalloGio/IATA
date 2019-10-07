public class ANG_MulticountryConversionAccountSelCtrl {

	@TestVisible
	private static final String CANNOT_REMOVE_HE_ERROR = 'You cannot remove the HE associated with the OSCAR'; 

	@TestVisible
	private static final String COUNTRY_NOT_MULTICOUNTRY = '{0} is not enabled for Multicountry. Please remove the accounts in this country';
    
	public class SelectedAccountWrapper implements Comparable {
		
		public Account acct {get; set;}
		public String compareKey; 

		public SelectedAccountWrapper(Account acct){
			this.acct = acct;
			this.compareKey = 
				acct.IATA_ISO_Country__r.AMS_Settlement_System__r.Name + 
				(acct.Top_Parent__c == null ? acct.Id + 'A' : acct.Top_Parent__c + 'B');
		}

		public Integer compareTo(Object compareTo){
			SelectedAccountWrapper saw = (SelectedAccountWrapper) compareTo;
			return this.compareKey.compareTo(saw.compareKey);
		}

	}

	public List<String> noteList {
		get{
			noteList = new List<String>{
				'Terminated hierarchies cannot be added',
				'Please select agencies from at least 2 BSPs',
				'Please select Cash HE accounts in multicountry-enabled countries'
			};
			return noteList;
		}
		set;
	}
	
	public Boolean closeTab {
		get{
			if(closeTab == null){
				closeTab = false;
			}
			return closeTab;
		}
		set;
	}

	private List<List<SelectedAccountWrapper>> accountSelectionBucketLst {
		get {

			if(accountSelectionBucketLst == null){
				accountSelectionBucketLst = new List<List<SelectedAccountWrapper>>();

				for(Integer i = 0; i <= (allAccountsSelectionLst.size()-1)/rowsPerPage; i++){
					accountSelectionBucketLst.add(new List<SelectedAccountWrapper>());
				}

				Integer itemNumber = 0;
				for(SelectedAccountWrapper saw : allAccountsSelectionLst){
					accountSelectionBucketLst.get(itemNumber++/rowsPerPage).add(saw);
				}
			}

			return accountSelectionBucketLst;

		}
		set;
	}
	
	public List<SelectedAccountWrapper> accountSelectionLst {
		get {
			if(accountSelectionBucketLst.size() > 0){
				return accountSelectionBucketLst.get(currentPage);
			}
			return new List<SelectedAccountWrapper>();
		}
	}

	public List<SelectedAccountWrapper> heAccountSelectionLst {
		get {
			if(heAccountSelectionLst == NULL){
				heAccountSelectionLst = new List<SelectedAccountWrapper>();
			}
			return heAccountSelectionLst;
		}
		set;    
	}

	public Boolean readOnly {
		get {
			if(readOnly == null){
				readOnly = false;
			}
			return readOnly;
		}
		set;
	}

	public Integer totalPages {
		get {
			return accountSelectionBucketLst.size();
		}
		set;
	}

	public Integer currentPage {
		get{
			if(currentPage == null){
				currentPage = 0;
			}
			return currentPage;
		}
		set;
	}
	
	private Map<Id, AMS_Process_Detail__c> processDetailsMap {
		get {
			
			if(processDetailsMap == null){

				processDetailsMap = new Map<Id, AMS_Process_Detail__c>();

				for(AMS_Process_Detail__c pd : 
					[SELECT
						Id,
						Account__c,
						Account__r.Name,
						Account__r.Status__c,
						Account__r.IATACode__c,
						Account__r.Top_Parent__c,
						Account__r.Location_Type__c,
						Account__r.IATA_ISO_Country__r.Name,
						Account__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Name
					FROM
						AMS_Process_Detail__c
					WHERE
						OSCAR__c = :this.oscar.Id
					AND
						RecordType.DeveloperName = 'Agency_Involved'
					]
				){
					processDetailsMap.put(pd.Account__c, pd);
				}

			}

			return processDetailsMap;

		}
		
		set;

	}

	@TestVisible
	private Integer rowsPerPage = 100;

	public AMS_OSCAR__c oscar {get; set;}
	public Integer heAccountIndex {get; set;}

	private Set<Id> alreadyAddedAccounts = new Set<Id>();
	private List<SelectedAccountWrapper> allAccountsSelectionLst = new List<SelectedAccountWrapper>();

	public ANG_MulticountryConversionAccountSelCtrl(ApexPages.StandardController controller){
		
		if(Test.isRunningTest()){
			Id oscarId = controller.getId();
			this.oscar = [SELECT Id, Account__c, New_parent__c, STEP45__c FROM AMS_OSCAR__c WHERE Id = :oscarId];
		}
		else {
			controller.addFields(new List<String>{'Account__c', 'New_parent__c', 'STEP45__c'});
			this.oscar = (AMS_OSCAR__c) controller.getRecord();
		}

		if(this.oscar.STEP45__c == AMS_Utils.PASSED){
			readOnly = true;
            return;
		}
		
		for(Id acctId : processDetailsMap.keySet()){
			AMS_Process_Detail__c pd = processDetailsMap.get(acctId);

			Account acct = (Account) pd.getSObject('Account__r');

			SelectedAccountWrapper saw = new SelectedAccountWrapper(acct);

			if(acct.Location_Type__c == AMS_Utils.HE){
				this.heAccountSelectionLst.add(saw);
			}

			this.allAccountsSelectionLst.add(saw);
			this.alreadyAddedAccounts.add(acct.Id);
		}

		addHierarchyFromHE(this.oscar.Account__c);

		sortLists();

	}

	public Boolean getDisablePrevious(){ 
		return (currentPage <= 0);
	}

	public Boolean getDisableNext(){
		return (currentPage >= accountSelectionBucketLst.size()-1);
	}

	public PageReference beginning(){
		currentPage = 0;
		return null;
	}

	public PageReference previous(){ 
		currentPage--;
		return null;
	}

	public PageReference next(){ 
		currentPage++;
		return null;
	}

	public PageReference end(){
		currentPage = accountSelectionBucketLst.size()-1;
		return null;
	}

	private void sortLists(){
		this.heAccountSelectionLst.sort();
		this.allAccountsSelectionLst.sort();
	}

	/**
	 * Adds the selected HE and the related hierarchy
	 * @param  selectedHE: receives Id of the selected HE 
	 */
	private void addHierarchyFromHE(Id selectedHE){

		List<Account> accountLst = new List<Account>(
			[SELECT
				Id,
				Name,
				Status__c,
				IATACode__c,
				Top_Parent__c,
				Location_Type__c,
				IATA_ISO_Country__r.Name,
				IATA_ISO_Country__r.AMS_Settlement_System__r.Name
			 FROM 
				Account
			 WHERE
				(Id = :selectedHE OR Top_Parent__c = :selectedHE)
			 AND
				Location_Type__c IN (:AMS_Utils.HE, :AMS_Utils.AE)
			 AND
				Status__c NOT IN (
					'',
					NULL,
					:AMS_Utils.ACC_S4_LISTED,
					:AMS_Utils.ACC_S0_TERMINATED, 
					:AMS_Utils.ACC_S1_NOTACCREDITED, 
					:AMS_Utils.ACC_S3_NOTINOPERATION
				)
			]
		);

		for(Account acct : accountLst){

			if(!alreadyAddedAccounts.contains(acct.Id)){
				SelectedAccountWrapper saw = new SelectedAccountWrapper(acct);
				
				this.allAccountsSelectionLst.add(saw);
				this.alreadyAddedAccounts.add(acct.Id);
				
				if(acct.Location_Type__c == AMS_Utils.HE){
					this.heAccountSelectionLst.add(saw);
				}
			}
			
		}

	}

	/**
	 * Adds the selected HE and 
	 * the related hierarchy to the accounts table 
	 * @return null
	 */ 
	public PageReference addHierarchyFromHE(){
		//Using the oscar field as auxiliary to fetch the accounts
		//We won't save any value on the field
		Id selectedHE = this.oscar.New_Parent__c;
		
		if (selectedHE != null)
		{
			// validate if it is a multicountry enabled country
			IATA_ISO_Country__c country = ANG_MulticountryHelper.getAccountCountry(selectedHE);
			if (! ANG_MulticountryHelper.isMulticountryCountry(country))
			{
				String message = String.format(COUNTRY_NOT_MULTICOUNTRY,
					new List<Object> { (country == null ? 'unknown' : country.Name) });

				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, message));
				return null;
			}

			addHierarchyFromHE(selectedHE);
		
			this.oscar.New_Parent__c = null;

			//Reset account buckets for pagination
			currentPage = null;
			accountSelectionBucketLst = null;

			sortLists();
		}

		return null;
	}

	/**
	 * Removes the intended HE and the related hierarchy
	 * @return null 
	 */
	public PageReference removeHeAccount(){
		
		SelectedAccountWrapper heToRemove = this.heAccountSelectionLst.get(heAccountIndex);

		//Block the HE account associated with the oscar to be removed 
		if(heToRemove.acct.Id == this.oscar.Account__c){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, CANNOT_REMOVE_HE_ERROR));
			return null;
		}

		heToRemove = this.heAccountSelectionLst.remove(heAccountIndex);

		integer i=0;

		while(i < this.allAccountsSelectionLst.size()){
			SelectedAccountWrapper saw = this.allAccountsSelectionLst.get(i);

			if(saw.acct.Id == heToRemove.acct.Id || saw.acct.Top_Parent__c == heToRemove.acct.Id){
				this.allAccountsSelectionLst.remove(i);
				this.alreadyAddedAccounts.remove(saw.acct.Id);
				continue;
			}

			i++;
		}

		//Reset account buckets for pagination
		currentPage = null;
		accountSelectionBucketLst = null;

		sortLists();

		return null;

	}

	/**
	 * Save method that creates and 
	 * inserts the AMS Process Detail records 
	 * @return null 
	 */
	public PageReference save(){

		Id rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');

		List<AMS_Process_Detail__c> processDetailLst = new List<AMS_Process_Detail__c>();

		for(SelectedAccountWrapper saw : this.allAccountsSelectionLst){
			if(this.oscar.Account__c != saw.acct.Id){
				AMS_Process_Detail__c pd = new AMS_Process_Detail__c();
				pd.Oscar__c = this.oscar.Id;
				pd.Account__c = saw.acct.Id;
				pd.RecordTypeId = rtAgencyInvolved;
				processDetailLst.add(pd);
			}
		}

		SavePoint sp = Database.setSavepoint();

		try {

			if(!processDetailsMap.isEmpty()){
				delete processDetailsMap.values();
			}

			if(!processDetailLst.isEmpty()){
				insert processDetailLst;
			}

			closeTab = true;

		}
		catch(Exception e){
			Database.rollback(sp);
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Could not save changes '+ e.getMessage()));
		}

		return null;

	}

}