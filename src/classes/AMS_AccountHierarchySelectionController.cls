public class AMS_AccountHierarchySelectionController {

	// ***********************************
	// ******* private variables *********
	// ***********************************

	private final Id ANALYST_PROFILE_ID = [SELECT Id, Name FROM Profile WHERE Name = 'FDS Hub Analyst ARM'].Id;

	private Account mainAccount{
		get{
			if(mainAccount == null) System.debug(loggingLevel.Info, '____ [cls AMS_AccountHierarchySelectionController - getMainAccount] hierarchy ready? - ' + (hierarchy.size() > 0));
			return mainAccount;
		}
		set;
	}

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
					, 'STEP6__c'
				};
			}
			return oscarFields;
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
				
				if(tocList.contains(AMS_Utils.LEGAL_STATUS) || tocList.contains(AMS_Utils.NAME) || tocList.contains(AMS_Utils.VFMR)) notes.add('Change of name/ legal status / vmfr will be applied to all the agencies selected');
				if(tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) notes.add('The change of location will be applied only to the main agency. If the change is for an SA, the OSCAR opened for HO or BR, will also change the address for SAs associated to it, please make sure to select the SA Account also.');
				//if(tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) notes.add('The change of location will be applied only to the main agency. If the change is for an SA, it is possible to select the HO or a BR as target agency. In this case the SA will be moved in the hierarchy to be placed under the selected agency');
				if(tocList.contains(AMS_Utils.LOCATION_TYPE)) notes.add('Change of location type support only the selection of the main agency. It will be swapped with its parent or moved to the same level as the parent, according to the behavior selected');
				if(tocList.contains(AMS_Utils.OWNERSHIP_IATA)) notes.add('Change of ownership to IATA will move all the agencies selected under the target agency');
				if(tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) notes.add('Change of ownership to non IATA will transform the main agency into the new HO. All the other agencies will keep their location type and will be put under the new HO');
				if(tocList.contains(AMS_Utils.MAJ_SHAREHOLDING) || tocList.contains(AMS_Utils.MIN_SHAREHOLDING)) notes.add('Change of shareholding must be applied to all the hierarchy');
			}

			return notes;
		}
		set;
	}



	private Map<String, String> errorMessages{
		get{
			if(errorMessages == null){
				errorMessages = new Map<String, String>();

				errorMessages.put(
					AMS_Utils.LOCATION,
					'For change of location, the field '+Schema.AMS_OSCAR__c.fields.AMS_Target_Agency__c.getDescribe().getLabel()+', if filled, should contain a link to the HO or a BR in the current hierarchy'
				);

				errorMessages.put(
					AMS_Utils.LOCATION_TYPE,
					'For change of location type, only one account can be selected'
				);

				errorMessages.put(
					AMS_Utils.OWNERSHIP_IATA,
					'For change of ownership to IATA, a target agency must be filled. It must contain an agency with location type HO which cannot be part of this hierarchy'
				);

				errorMessages.put(
					AMS_Utils.MAJ_SHAREHOLDING,
					'For change of shareholding, all the hierarchy must be selected'
				);

				errorMessages.put(
					AMS_Utils.MIN_SHAREHOLDING,
					'For change of shareholding, all the hierarchy must be selected'
				);

				errorMessages.put(
					'Partial Migration With HO',
					'For change of ownership (to IATA and non IATA), the analyst cannot select HO and only part of the active agencies'
				);
			}
			return errorMessages;
		}
		set;
	}

	private Map<String, Boolean> errorChecks{
		get{
			if(errorChecks == null){
				errorChecks = new Map<String, Boolean>();
			}
			return errorChecks;
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

	private Set<String> tocList{
		get{
			tocList = new Set<String>();

			if(oscar.Type_of_Change__c != null) tocList.addAll(oscar.Type_of_change__c.split(';'));

			return tocList;
		}
		set;
	}

	private Set<Id> hierarchyAccounts{
		get{
			if(hierarchyAccounts == null) hierarchyAccounts = new Set<Id>();
			return hierarchyAccounts;
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
			return (UserInfo.getProfileId() != ANALYST_PROFILE_ID || oscar.STEP6__c != AMS_Utils.PASSED);
		}
		set;
	}

	public Boolean showTargetAgency{
		get{
			if(oscar.Type_of_Change__c != null){

				if(tocList.contains(AMS_Utils.OWNERSHIP_IATA)) return true;
				if((tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) && mainAccount.Location_Type__c == AMS_Utils.SA) return true;
			}
			
			oscar.AMS_Target_Agency__c = null;
			return false;
		}
		set;
	}
	
	public Boolean showLocationTypeBehavior{
		get{
			if(oscar.Type_of_Change__c != null && tocList.contains(AMS_Utils.LOCATION_TYPE)){

				if(oscar.Change_of_location_type_behavior__c == null) oscar.Change_of_location_type_behavior__c = AMS_Utils.CHLOCTYPEBEHAVIOR_STANDARD;
				return true;
			}
			oscar.Change_of_location_type_behavior__c = null;
			return false;
		}
		set;
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

	public List<HierarchyItem> hierarchy{
		get{
			if(hierarchy == null) {
				hierarchy = new List<HierarchyItem>();

				Set<Id> accountIds = new Set<Id>();
				Map<Id, List<AMS_Agencies_relationhip__c>> relationshipMap = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c});
				for(AMS_Agencies_relationhip__c r : relationshipMap.get(oscar.Account__c)){
					accountIds.add(r.Child_Account__c);
					accountIds.add(r.Parent_Account__c);
				}

				//to prevent nullpointer on agencies with no hierarchy
				accountIds.add(oscar.Account__c);

				for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',')+' FROM Account WHERE Id IN :accountIds AND Status__c != \''+AMS_Utils.ACC_S0_TERMINATED+'\'')){
					Boolean main = (a.Id == oscar.Account__c);
					hierarchy.add(new HierarchyItem(a, main, processDetails.containsKey(a.Id)));
					hierarchyAccounts.add(a.Id);
				}
				selectMain();
			}
			return hierarchy;
		}
		set;
	}

	// ***********************************
	// ********** constructor ************
	// ***********************************
	public AMS_AccountHierarchySelectionController(ApexPages.StandardController stdController){
		if(!Test.isRunningTest()) stdController.addFields(new List<String>(oscarFields));

		oscarId = stdController.getId();
		oscar = (AMS_OSCAR__c)stdController.getRecord();
	}


	// ***********************************
	// ********* helper methods **********
	// ***********************************

	public void doSelectAll(){
		for(HierarchyItem hi : hierarchy){
			if(!hi.main) hi.selected = selectAll;
		}
	}

	private Boolean performValidations(){

		//clear error checks
		errorChecks = null;

		//loop through all hierarchy checking for errors (or clearing them)

		Boolean ownershipMainHO;
		Boolean ownershipAgenciesNotSelected;

		if(tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_IATA)){
			ownershipMainHO = false;
			ownershipAgenciesNotSelected = false;
		}

		if(oscar.AMS_Target_Agency__c != null && (tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION))) errorChecks.put(AMS_Utils.LOCATION, true);

		for(HierarchyItem hi : hierarchy){
			
			if(tocList.contains(AMS_Utils.LOCATION_TYPE) && hi.selected){
				errorChecks.put(AMS_Utils.LOCATION_TYPE, true);
			}

			if(oscar.AMS_Target_Agency__c == hi.acc.Id){
				if(tocList.contains(AMS_Utils.OWNERSHIP_IATA)) errorChecks.put(AMS_Utils.OWNERSHIP_IATA, true);
				if(hi.acc.Location_Type__c == AMS_Utils.BR || hi.acc.Location_Type__c == AMS_Utils.HO){
					errorChecks.put(AMS_Utils.LOCATION, false);
				}
			}

			if(tocList.contains(AMS_Utils.MAJ_SHAREHOLDING) && !hi.selected && !hi.main){
				errorChecks.put(AMS_Utils.MAJ_SHAREHOLDING, true);
			}

			if(tocList.contains(AMS_Utils.MIN_SHAREHOLDING) && !hi.selected && !hi.main){
				errorChecks.put(AMS_Utils.MIN_SHAREHOLDING, true);
			}

			if(tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_IATA)){
				if((hi.main || hi.selected) && hi.acc.Location_Type__c == AMS_Utils.HO) ownershipMainHO = true;
				if(!hi.selected && !hi.main) ownershipAgenciesNotSelected = true;
			}
			
		}

		if(tocList.contains(AMS_Utils.OWNERSHIP_IATA) && !errorChecks.containsKey(AMS_Utils.OWNERSHIP_IATA)){
			if(oscar.AMS_Target_Agency__c == null) errorChecks.put(AMS_Utils.OWNERSHIP_IATA, true);
			else{
				String targetLocationType = [SELECT Id, Location_Type__c FROM Account WHERE Id = :oscar.AMS_Target_Agency__c].Location_Type__c;
				if(targetLocationType != AMS_Utils.HO) errorChecks.put(AMS_Utils.OWNERSHIP_IATA, true);
			}
		}

		if(
			(tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_IATA))
			&& ownershipMainHO && ownershipAgenciesNotSelected
		){
			errorChecks.put('Partial Migration With HO', true);
		}

		//retrieve error messages
		List<String> errors = new List<String>();

		for(String error : errorChecks.keySet()){
			if(errorChecks.get(error)) errors.add(errorMessages.get(error));
		}

		//display error messages and stop execution by short-circuiting the if on the save method
		if(!errors.isEmpty()){
			for(String error : errors) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, error));
			return false;
		}

		return true;
	}

	private Boolean updateRelatedRecords() {

		List<AMS_Process_Detail__c> newProcessHierarchy = new List<AMS_Process_Detail__c>();
		for(HierarchyItem hi : hierarchy){
			if(hi.selected && !hi.main){
				newProcessHierarchy.add(new AMS_Process_Detail__c(Oscar__c = oscarId, Account__c = hi.acc.Id));
			}
		}

		try{

			if(!processDetails.isEmpty()) delete processDetails.values();
			if(!newProcessHierarchy.isEmpty()) insert newProcessHierarchy;
			Id cId = [SELECT Id FROM Case WHERE Oscar__c = :oscarId AND RecordType.Name = 'OSCAR Communication' AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) ].Id;
			update new Case(Id = cId, AccountId = oscar.Account__c);
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
			return false;
		}

		return true;
	}


	// ***********************************
	// ********* action methods **********
	// ***********************************

	public void selectMain() {
		for(HierarchyItem hi : hierarchy){
			if(hi.main){
				mainAccount = hi.acc;
				oscar.Account__c = hi.acc.Id;
			}
			System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] hi.acc.Name - ' + hi.acc.Name);
			System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] hi.main - ' + hi.main);
			System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] hi.selected - ' + hi.selected);
		}
		System.debug(loggingLevel.Debug, '____ [cls AMS_AccountHierarchySelectionController - selectMain] mainAccount.Name - ' + mainAccount.Name);
	}

	public void save(){
		if(performValidations()){

			Savepoint sp = Database.setSavepoint();
			try {
				update oscar;

				//must be after save, to pass validations on the details
				if(updateRelatedRecords()) closeTab = true;
			} catch(Exception e) {
				Database.rollback(sp);
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
			}
		}
	}

	// ***********************************
	// *********** wrappers **************
	// ***********************************
	public class HierarchyItem{

		public Account acc { get; set; }
		public Boolean main { get; set; }
		public Boolean selected { get; set; }

		public HierarchyItem(Account a, Boolean main, Boolean selected){
			this.acc = a;
			this.main = main;
			this.selected = selected;
		}
	}
}