public class AMS_AccountHierarchySelectionController {

	// ***********************************
	// ******* private variables *********
	// ***********************************

	private ApexPages.StandardController stdController;

	private String oscarId{
		get{
			if(String.isEmpty(oscarId)) oscarId = ApexPages.currentPage().getParameters().get('Id');
			return oscarId;
		}
		set;
	}

	private Set<String> oscarFields{
		get{
			if(oscarFields == null){
				oscarFields = new Set<String>{
					'Account__c'
					, 'Type_of_change__c'
					, 'AMS_Target_Agency__c'
					, 'Change_of_location_type_behavior__c'
				};
			}
			return oscarFields;
		}
		set;
	}

	private List<String> oscarFieldList{
		get{
			return new List<String>(oscarFields);
		}
		set;
	}

	private Set<String> accountFields{
		//DO NOT include Id on this Set
		get{
			if(accountFields == null){
				accountFields = new Set<String>{
					'Name'
					, 'Location_Type__c'
					, 'IATACode__c'
					, 'Status__c'
					, 'BillingCity'
					, 'Category__c'
				};
			}
			return accountFields;
		}
		set;
	}

	private Set<String> notes{
		get{
			notes = new Set<String>();

			if(oscar.Type_of_Change__c != null){
				//can't use contains() because 'Location' is found on 'Location type'
				for(String value : oscar.Type_of_Change__c.split(';')){
					String v = value.trim();
					if(v == 'Legal status' || v == 'Name' || v == 'VMFR') notes.add('Change of name/ legal status / vmfr will be applied to all the agencies selected');
					if(v == 'Location' || v == 'Location with inspection') notes.add('The change of location will be applied only to the main agency. If the change is for an SA, it is possible to select the HO or a BR as target agency. In this case the SA will be moved in the hierarchy to be placed under the selected agency');
					if(v == 'Location type') notes.add('Change of location type support only the selection of the main agency. It will be swapped with its parent or moved to the same level as the parent, according to the behavior selected');
					if(v == 'Ownership to IATA Agent') notes.add('Change of ownership to IATA will move all the agencies selected under the target agency');
					if(v == 'Ownership to non-IATA Agent') notes.add('Change of ownership to non IATA will transform the main agency into the new HO. All the other agencies will keep their location type and will be put under the new HO');
					if(v == 'Major Shareholding' || v == 'Minor Shareholding') notes.add('Change of shareholding must be applied to all the hierarchy');
				}
			}

			return notes;
		}
		set;
	}

	private Map<Id, AMS_Process_Detail__c> processDetails{
		get{
			if(processDetails == null){
				processDetails = new Map<Id, AMS_Process_Detail__c>();
				for(AMS_Process_Detail__c pd : [SELECT Id, Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :oscarId]){
					processDetails.put(pd.Account__c, pd);
				}
			}
			return processDetails;
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

	public Boolean hasError{
		get{
			if(hasError == null) hasError = false;
			return hasError;
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
	public Boolean showTargetAgency{
		get{
			if(oscar.Type_of_Change__c != null){

				//can't use contains() because 'Location' is found on 'Location type'
				for(String value : oscar.Type_of_Change__c.split(';')){
					if(value.trim() == 'Location' || value.trim() == 'Ownership to IATA Agent') return true;
				}
			}
			
			oscar.AMS_Target_Agency__c = null;
			return false;
		}
		set;
	}
	
	public Boolean showLocationTypeBehavior{
		get{
			if(oscar.Type_of_Change__c != null){

				//can't use contains() because 'Location' is found on 'Location type'
				for(String value : oscar.Type_of_Change__c.split(';')){
					if(value.trim() == 'Location type') return true;
				}
			}
			oscar.Change_of_location_type_behavior__c = null;
			return false;
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

	public List<HierarchyItem> hierarchy{
		get{
			if(hierarchy == null){
				hierarchy = fetchHierarchy();
			}
			return hierarchy;
		}
		set;
	}

	// ***********************************
	// ********** constructor ************
	// ***********************************
	public AMS_AccountHierarchySelectionController(ApexPages.StandardController stdController){
		//hasError = true;
		//ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'Page in maintenance. Come back later '));
		this.stdController = stdController;
		this.stdController.addFields(new List<String>(oscarFields));

		oscarId = this.stdController.getId();
		oscar = (AMS_OSCAR__c)this.stdController.getRecord();
	}


	// ***********************************
	// ********* helper methods **********
	// ***********************************

	public void doSelectAll(){
		for(HierarchyItem hi : hierarchy){
			if(!hi.main) hi.selected = selectAll;
		}
	}

	private List<HierarchyItem> fetchHierarchy(){
		Set<Id> accountIds = new Set<Id>();
		for(AMS_Agencies_relationhip__c r : AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c}).get(oscar.Account__c)){
			accountIds.add(r.Child_Account__c);
			accountIds.add(r.Parent_Account__c);
		}

		List<HierarchyItem> result = new List<HierarchyItem>();
		for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',')+' FROM Account WHERE Id IN :accountIds')){
			result.add(new HierarchyItem(this, a));
		}
		return result;
	}

	public Boolean performValidations(){
		//do something
		ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.INFO, 'something happened '));

		return true;
	}


	// ***********************************
	// ********* action methods **********
	// ***********************************

	public void save(){
		if(performValidations()){
			stdController.save();
			closeTab = true;
		}
	}

	public void cancel(){
		closeTab = true;
	}

	// ***********************************
	// *********** wrappers **************
	// ***********************************
	public class HierarchyItem{
		private AMS_AccountHierarchySelectionController controller;

		public Account acc { get; set; }
		public Boolean selected { get; set; }

		public Boolean main { get; set; }

		public void selectMain(){
			System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] this.acc.Name - ' + this.acc.Name);
			System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] this.main - ' + this.main);
			if(this.main){
				for(HierarchyItem hi : controller.hierarchy){
					System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] (this == hi) - ' + (this == hi));
					if(hi != this) hi.main = false;
				}
				this.selected = true;
				controller.oscar.Account__c = this.acc.Id;
			}
		}

		public HierarchyItem(AMS_AccountHierarchySelectionController c, Account a){
			this.controller = c;
			this.acc = a;

			this.main = false;
			this.selected = false;

			if(a.Id == c.oscar.Account__c) this.main = true;
			else if (c.processDetails.containsKey(a.Id)) {
				this.main = false;
			}
		}
	}
}