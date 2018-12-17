public with sharing class ANG_MulticountryHierarchySelectionCrtl {

	private String oscarId{
		get{
			if(String.isEmpty(oscarId)) oscarId = ApexPages.currentPage().getParameters().get('Id');
			return oscarId;
		}
		set;
	}


	public Set<String> oscarFields{
		get{
			if(oscarFields == null){
				oscarFields = new Set<String>{
					'Account__c'
					, 'Process__c'
					, 'ANG_Type_Of_Change__c'
					, 'Step6__c'
					, 'Step45__c'
					, 'AMS_Online_Accreditation__c'
					, 'Oscar_Communication_Case_Id__c'
				};
			} 
			return oscarFields;
		}
		set;
	}

	public Set<String> accountFields{
		//DO NOT include Id on this Set
		get{
			if(accountFields == null){
				accountFields = new Set<String>{
					 'Name'
					,'IATA_ISO_Country__r.Name'
					,'IATA_ISO_Country__r.AMS_Settlement_System__r.Name'
					,'BillingCity'
					,'BillingAddress'
					,'Location_type__c'
					,'Category__c'
					,'BillingStreet'
					,'BillingPostalCode'
					,'IATACODE__c'
					,'Status__c'


				};
			}
			return accountFields;
		}
		set;
	}

    private Set<String> notes{
		get{
			Set<String> toReturn = new Set<String>();
			toReturn.add('This page will allow the user to select the Hierarchy of the multi-country hierarchy.');
			toReturn.add('The following rules must be implemented:');
			toReturn.add('There are not AEs alone in any BSP.');
			toReturn.add('There is 1 and only 1 GE');
			toReturn.add('In each BSP there is 1 and only 1 HE');
			toReturn.add('There are at least 2 BSPs involved');

			return toReturn;
		}
		set;
	}

	private Map<Id, AMS_Process_Detail__c> processDetails{
		get{
			if(processDetails == null){
				processDetails = new Map<Id, AMS_Process_Detail__c>();
				for(AMS_Process_Detail__c pd : [SELECT Id, Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :oscarId and recordtype.developername='Multicountry_Hierarchy']){
					processDetails.put(pd.Account__c, pd);
				}
			}
			return processDetails;
		}
		set;
	}

	private Set<String> tocList{
		get{
			tocList = new Set<String>();

			if(oscar.ANG_Type_Of_Change__c != null) tocList.addAll(oscar.ANG_Type_Of_Change__c.split(';'));

			return tocList;
		}
		set;
	}

	// ***********************************
	// ******** public variables *********
	// ***********************************

	public AMS_OSCAR__c oscar{
		get{
			if(oscar == null && oscarId != null) oscar = Database.query('SELECT Id, '+String.join(oscarFieldList, ',')+' FROM AMS_OSCAR__c WHERE Id = :oscarId');
			return oscar;
		}
		set;
	}

	public Boolean closeTab{
		get{
			if(closeTab == null) closeTab = false;
			return closeTab;
		}
		set;
	}

	public Boolean selectAll{
		get{
			if(selectAll == null) selectAll = false;
			return selectAll;
		}
		set;
	}

	public Boolean editable {
		get{
			return (oscar.STEP45__c != AMS_Utils.PASSED);
		}
		set;
	}

	public Boolean showTargetAgency{
		get{
			if(oscar.ANG_Type_Of_Change__c != null){

				if(tocList.contains(AMS_Utils.ANG_HIERARCHY)) 
					return true;
			
			}
			
			oscar.New_parent__c = null;
			return false;
		}
		set;
	}
	
	public Boolean showTopPanel{
		get{
			return oscar.RecordTypeId != AMS_Utils.RECTYPE_NEWGENFOP;
		}
		private set;
	}


	//its public so it can be tested
	public List<String> oscarFieldList{
		get{
			return new List<String>(oscarFields);
		}
		set;
	}

	public List<String> accountFieldList{
		get{
			return new List<String>(accountFields);
		}
		set;
	}

	public List<String> noteList{
		get{
			return new List<String>(notes);
		}
		set;
	}

	public Map<String, List<HierarchyItem>> hierarchy{
		get{
			if(hierarchy == null) {
				hierarchy = new Map<String, List<HierarchyItem>>();

				Id accountId = oscar.Account__c;

				for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',')+', CNS_Agency__c FROM Account WHERE ( Top_Parent__c = :accountId or Id = :accountId ) AND Status__c not in ( ' +  getInvalidStatus() + ' ) ORDER BY IATA_ISO_Country__r.Name')){
					Boolean main = (a.Id == oscar.Account__c);
					if(hierarchy.get(a.IATA_ISO_Country__r.AMS_Settlement_System__r.Name) == null)
						hierarchy.put(a.IATA_ISO_Country__r.AMS_Settlement_System__r.Name, new List<HierarchyItem>{new HierarchyItem(a, main, processDetails.containsKey(a.Id), a.Location_Type__c == AMS_Utils.GE)});
					else
						hierarchy.get(a.IATA_ISO_Country__r.AMS_Settlement_System__r.Name).add(new HierarchyItem(a, main, processDetails.containsKey(a.Id), a.Location_Type__c == AMS_Utils.GE));
				}
				selectMain();
			}

			return hierarchy;
		}
		set;
	}

	public String getInvalidStatus(){

		return '\'' + AMS_Utils.ACC_S3_NOTINOPERATION + '\'' + ',' + '\'' + AMS_Utils.ACC_S0_TERMINATED + '\'' ;

	}

	public List<HierarchyItem> hierarchyValues{
		get{

			if(hierarchyValues != null)
				return hierarchyValues;

			List<HierarchyItem> toReturn = new List<HierarchyItem>();
			
			for(List<HierarchyItem> listItem: hierarchy.values())
				toReturn.addAll(listItem);

			return toReturn;
		}
	}

	private Integer rowsPerPage = 100;

    public Integer currentPage{
        get{
            if(currentPage == null){
                currentPage = 0;
            }
            return currentPage;
        }
        set;
    }
    
	public Integer totalPages{
        get{
            return hierarchyValuesForDisplay.size();
        }
    }
    
    public List<List<HierarchyItem>> hierarchyValuesForDisplay{
        get{
            if(hierarchyValuesForDisplay == null){
                hierarchyValuesForDisplay = new List<List<HierarchyItem>>();

                // create as many sub-lists as necessary
                for(Integer i = 0; i <= (hierarchyValues.size()-1)/rowsPerPage; i++){
                    hierarchyValuesForDisplay.add(new List<HierarchyItem>());
                }

                // fill HierarchyItems in the sub-lists
                Integer itemNumber = 0;
                for(HierarchyItem item : hierarchyValues){
                    hierarchyValuesForDisplay.get(itemNumber++/rowsPerPage).add(item);
                }
            }

            return hierarchyValuesForDisplay;
        }
        set;
    }
    
	// ***********************************
	// ********** constructor ************
	// ***********************************
	public ANG_MulticountryHierarchySelectionCrtl(ApexPages.StandardController stdController){
		if(!Test.isRunningTest()) stdController.addFields(new List<String>(oscarFields));

		oscarId = stdController.getId();
		oscar = (AMS_OSCAR__c)stdController.getRecord();

        if(Test.isRunningTest()) oscar =  [Select Id, Account__c, Process__c, Step6__c, ANG_Type_Of_Change__c, STEP45__c, ANG_Hierarchy_Created__c from AMS_OSCAR__c where Id =:oscarId];
	}




	// ***********************************
	// ********* action methods **********
	// ***********************************

	public void selectMain() {
		for(HierarchyItem hi : hierarchyValues)	if(hi.main)	oscar.Account__c = hi.acc.Id;
	}

    public PageReference Beginning() { //user clicked beginning
		currentPage = 0;
		return null;
	}

	public PageReference Previous() { //user clicked previous button
		currentPage--;
		return null;
	}

	public PageReference Next() { //user clicked next button
		currentPage++;
		return null;
	}

	public PageReference End() { //user clicked end
		currentPage = hierarchyValuesForDisplay.size()-1;
		return null;
	}

    public Boolean getDisablePrevious() { 
		//this will disable the previous and beginning buttons
		return (currentPage <= 0);
	}
    
	public Boolean getDisableNext() { //this will disable the next and end buttons
		return (currentPage >= hierarchyValuesForDisplay.size()-1);
	}
	
	public void save(){

		if([Select Id, STEP45__C from AMS_OSCAR__c where Id = :oscarId].get(0).STEP45__C == AMS_Utils.PASSED){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'The hierarchy structure is already confirmed, you cannot change it.'));
			return;
		}
			

		adjustHierarchy();

		if(performValidations()){

			Savepoint sp = Database.setSavepoint();
			try {
				


				adjustAccountsParentship();

				List<Account> accountsToUpdate = fetchAccounts();

				if(!accountsToUpdate.isEmpty()){
					update accountsToUpdate;
					createHierarchy(accountsToUpdate);
					closeTab = true;
				}

				oscar.Step45__c = AMS_Utils.PASSED;

				update oscar;
				//if(updateRelatedRecords()) closeTab = true;
				
				//setting Set for batch to create case, oscar and staging area for the child accounts
				Set<Id> acctId = new Set<Id>();
				
				for(Account a: accountsToUpdate)
					AcctId.Add(a.id);
				
				ANG_MulticountryOscarCreatorBatch myBatchObject = new ANG_MulticountryOscarCreatorBatch(AcctId); 
				Id batchId = Database.executeBatch(myBatchObject,1);
			
			} catch(Exception e) {
				Database.rollback(sp);
				//DML Exceptions are sometimes displayed on the page
				if(e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
				System.debug(loggingLevel.ERROR, '____ [cls AMS_AccountHierarchySelectionController - save] error - ' + e.getMessage());
			}
		}
	}

	private void createHierarchy(List<Account> acctLst){

		Set<String> alreadyCreatedRelations = new Set<String>();

		For(AMS_Agencies_relationhip__c ar : [Select Id, Parent_Account__c, Child_Account__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__c = :oscar.account__c])
			alreadyCreatedRelations.add(String.valueof(ar.Child_Account__c)+String.valueOf(ar.Parent_Account__c));

		if(acctLst.size() < 2)
			return;

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy');
		insert hierarchy;

		List<AMS_Agencies_relationhip__c> relsToInsert = new List<AMS_Agencies_relationhip__c>();

		for(Account acct: acctLst){
			if(acct.Location_Type__c == AMS_Utils.GE)
				continue;
			
			if(!alreadyCreatedRelations.contains(String.valueof(acct.Id)+String.valueof(acct.ParentId)))
				relsToInsert.add(new AMS_Agencies_relationhip__c(Parent_Account__c = acct.ParentId, Child_Account__c = acct.Id, Hierarchy__c = hierarchy.Id, Is_Newgen_Relation__c = true));
		}

		if(!relsToInsert.isEmpty()){
			insert relsToInsert;
		}else
			delete hierarchy;

	}


	private List<Account> fetchAccounts(){

		Set<Account> toReturn = new Set<Account>();

		for(List<HierarchyItem> itemsList: hierarchy.values()){
			For(HierarchyItem item: itemsList)
				toReturn.add(item.acc);
		}

		return new List<Account>(toReturn);
	}

	private void adjustAccountsParentship(){

			Id acctIdGEinBSP;

			for(HierarchyItem item:hierarchyValues)
				if(item.isTopParent)
					acctIdGEinBSP = item.acc.Id;

			for(List<HierarchyItem> itemsList: hierarchy.values()){

				Id acctIdHEinBSP;

				for(HierarchyItem item: itemsList)
					if(item.isHE)
						acctIdHEinBSP = item.acc.Id;


				for(HierarchyItem item: itemsList){

					if(item.isAE){
						if(acctIdHEinBSP == null){
							item.acc.ParentId = acctIdGEinBSP; 
							item.wasChanged = true;
						}else{
							item.acc.ParentId = acctIdHEinBSP;
							item.wasChanged = true;
						}					
					}else if(item.isHE){
							item.acc.ParentId = acctIdGEinBSP;
							item.wasChanged = true;
					}

					if(!item.isTopParent){
						item.acc.Top_Parent__c = acctIdGEinBSP;						
						item.wasChanged = true;
					}

				}

			}

	}

	@TestVisible private void adjustHierarchy(){

		for(HierarchyItem item: hierarchyValues){

			if(item.acc.Location_Type__c == AMS_Utils.AE && item.isHE){
				item.acc.Location_type__c = AMS_Utils.HE;
				item.wasChanged = true;
			}
			if(item.acc.Location_Type__c == AMS_Utils.HE && item.isAE){
				item.acc.Location_type__c = AMS_Utils.AE;
				item.wasChanged = true;			
			}
		}
	}

	@TestVisible private boolean performValidations(){

		boolean toReturn = true;

		Map<String,BSPAttributes> bspMap = new Map<String,BSPAttributes>();

		for( HierarchyItem item: hierarchyValues){

			if(bspMap.get(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name) == null)
				bspMap.put(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name,new BSPAttributes(item.acc));
			else	
				bspMap.get(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name).addCount(item.acc);

		}

		if(bspMap.values().size() < 2){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There should are at least 2 BSPs involved in the hierarchy.'));
			return false;
		}

		for(BSPAttributes bspAtt: bspMap.values()){
					
			if(bspAtt.numberOfHE > 1){
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There should only be one HE per BSP.'));
				toReturn = false;
			}
			if(bspAtt.numberOfAE > 0)
				if(bspAtt.numberOfHE == 0 && !bspAtt.isGE){
					ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There should not be any AEs alone in any BSP (that is not a GE).'));
					toReturn = false;
				}

		}

		return toReturn;
	}

	public class BSPAttributes{

		public Integer numberOfHE;
		public Integer numberOfAE;
		public Boolean isGE;

		public BSPAttributes(Account a){

			numberOfHE = 0;
			numberOfAE = 0;
			isGE = false;

			if(a.Location_Type__c == AMS_Utils.HE)
				this.numberOfHE = 1;
			if(a.Location_Type__c == AMS_Utils.AE)
				this.numberOfAE = 1;
			if(a.Location_Type__c == AMS_Utils.GE)
				this.isGE = true;
		}

		public void addCount(Account a){
			if(a.Location_Type__c == AMS_Utils.HE)
				this.numberOfHE++;
			if(a.Location_Type__c == AMS_Utils.AE)
				this.numberOfAE++;
			if(a.Location_Type__c == AMS_Utils.GE)
				this.isGE = true;			
		}
	}

	// ***********************************
	// *********** wrappers **************
	// ***********************************
	public class HierarchyItem{

		public Account acc { get; set; }
		public Boolean main { get; set; }
		public Boolean selected { get; set; }
		public Boolean isTopParent { get; set; }
		public Boolean isAE {get;set;}
		public Boolean isHE {get;set;}
		public String bspCountry{get;set;}
		public Boolean wasChanged{get;set;}

		public HierarchyItem(Account a, Boolean main, Boolean selected, Boolean isTopParent){
			this.acc = a;
			this.main = main;
			this.selected = selected;
			this.isTopParent = isTopParent;
			this.isAe = this.acc.Location_Type__c == 'AE';
			this.isHE = this.acc.Location_Type__c == 'HE';
			this.bspCountry = a.IATA_ISO_Country__r.AMS_Settlement_System__r.Name;
		}
	}
}