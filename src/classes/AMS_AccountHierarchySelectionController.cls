public class AMS_AccountHierarchySelectionController {

	// ***********************************
	// ******* private variables *********
	// ***********************************

	//private final Id ANALYST_PROFILE_ID = [SELECT Id, Name FROM Profile WHERE Name = 'FDS Hub Analyst ARM'].Id;

	@TestVisible
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

	private Boolean isVoluntaryRelinquishment{
		get{
			return (oscar.Process__c == AMS_Utils.VOLRELINQUISH || oscar.Process__c == AMS_Utils.VOLRELINQUISH_CA);
		}
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
					, 'Process__c'
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
					, 'Is_Branch_Abroad__c'
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

			//FM AMSU-1 27-09-2017 - On Correction Process we don't show notes!
			if(!isCorrection){

				if(isVoluntaryRelinquishment) notes.add('Voluntary relinquishment: select from the below list all the agencies listed in the pdf form received as attachment of the OSCAR. All the selected Agencies will be processed in the same way, there is no distinction between Main Agency and the other ones.');
	
				else if(oscar.Type_of_Change__c != null){
					
					if(tocList.contains(AMS_Utils.LEGAL_STATUS) || tocList.contains(AMS_Utils.NAME)) notes.add('Change of name/ legal status / vmfr will be applied to all the agencies selected');
					if(tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) notes.add('The change of location will be applied only to the main agency. If the change is for an SA, the OSCAR opened for HO or BR, will also change the address for SAs associated to it, please make sure to select the SA Account also.');
					//if(tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) notes.add('The change of location will be applied only to the main agency. If the change is for an SA, it is possible to select the HO or a BR as target agency. In this case the SA will be moved in the hierarchy to be placed under the selected agency');
					if(tocList.contains(AMS_Utils.LOCATION_TYPE)) notes.add('Change of location type support only the selection of the main agency. It will be swapped with its parent or moved to the same level as the parent, according to the behavior selected');
					if(tocList.contains(AMS_Utils.OWNERSHIP_IATA)) notes.add('Change of ownership to IATA will move all the agencies selected under the target agency');
					if(tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)) notes.add('Change of ownership to non IATA will transform the main agency into the new HO. All the other agencies will keep their location type and will be put under the new HO');
					if(tocList.contains(AMS_Utils.MAJ_SHAREHOLDING) || tocList.contains(AMS_Utils.MIN_SHAREHOLDING)) notes.add('Change of shareholding must be applied to all the hierarchy');
					if(tocList.contains(AMS_Utils.VFMR)) notes.add('Change of remittance frequency must be applied to all the hierarchy (except for branches abroad)');
					if(tocList.contains(AMS_Utils.REMOVALTRADENAME)) notes.add('The removal of trade name can be used only for CNS Agencies.');
				}
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
					'For change of ownership to IATA, a target agency must be filled. It must contain an agency with location type HO or AO which cannot be part of this hierarchy'
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
					AMS_Utils.VFMR,
					'For change of remittance frequency, all the hierarchy must be selected'
				);

				errorMessages.put(
					'Partial Migration With HO',
					'For change of ownership (to IATA and non IATA), the analyst cannot select HO and only part of the active agencies'
				);

				errorMessages.put(
					'Partial VR selection',
					'For Voluntary Relinquishment, the analyst cannot select a parent account without its children'
				);
				errorMessages.put(
					AMS_Utils.REMOVALTRADENAME,
					'The removal of trade name can be used only for CNS Agencies.'
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
				//DTULLO: Added check on recordtype
				//for(AMS_Process_Detail__c pd : [SELECT Id, Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :oscarId]){
				for(AMS_Process_Detail__c pd : [SELECT Id, Account__c FROM AMS_Process_Detail__c WHERE Oscar__c = :oscarId and recordtype.developername='Agency_Involved']){
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

	//FM 01-03-2017 - Add Correction Process Check
	public Boolean isCorrection{
		get{
			return (oscar.Process__c == AMS_Utils.COR);
		}
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
			//return (UserInfo.getProfileId() != ANALYST_PROFILE_ID || oscar.STEP6__c != AMS_Utils.PASSED);
			return (oscar.STEP6__c != AMS_Utils.PASSED);
		}
		set;
	}

	public Boolean showTargetAgency{
		get{
			if(oscar.Type_of_Change__c != null){

				if((tocList.contains(AMS_Utils.LOCATION) || tocList.contains(AMS_Utils.LOCATION_INSPECTION)) && mainAccount.Location_Type__c == AMS_Utils.SA) return true;
				if(tocList.contains(AMS_Utils.OWNERSHIP_IATA)) return true;
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

	public Boolean showTopPanel{
		get{
			//FM 01-03-2017 - Add Correction Process validation, adding to the existing Voluntary Relinquishment condition
			boolean bRes = true;
			if(isVoluntaryRelinquishment || isCorrection)
			//if(isVoluntaryRelinquishment )
				bRes = false;

			return bRes;
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

	public Map<Id, HierarchyItem> hierarchy{
		get{
			if(hierarchy == null) {
				hierarchy = new Map<Id, HierarchyItem>();

				Set<Id> accountIds = new Set<Id>();
				Map<Id, List<AMS_Agencies_relationhip__c>> relationshipMap = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c});
				Map<Id, Set<Id>> childAccounts = new Map<Id, Set<Id>>();

				//to prevent nullpointer on agencies with no hierarchy
				accountIds.add(oscar.Account__c);
				childAccounts.put(oscar.Account__c, new Set<Id>());
				
				for(AMS_Agencies_relationhip__c r : relationshipMap.get(oscar.Account__c)){
					accountIds.add(r.Child_Account__c);
					accountIds.add(r.Parent_Account__c);

					if(!childAccounts.containsKey(r.Parent_Account__c)) childAccounts.put(r.Parent_Account__c, new Set<Id>());
					if(!childAccounts.containsKey(r.Child_Account__c)) childAccounts.put(r.Child_Account__c, new Set<Id>());

					if(r.Child_Account__r.Status__c != null && r.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && r.Child_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED) childAccounts.get(r.Parent_Account__c).add(r.Child_Account__c);
				}

				for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',')+', CNS_Agency__c FROM Account WHERE Id IN :accountIds AND Status__c != \''+AMS_Utils.ACC_S0_TERMINATED+'\'' + ' AND Status__c != \''+AMS_Utils.ACC_S1_NOTACCREDITED+'\'' + ' AND Status__c != \'\'')){
					Boolean main = (a.Id == oscar.Account__c);
					hierarchy.put(a.Id, new HierarchyItem(a, main, processDetails.containsKey(a.Id), childAccounts.get(a.Id)));
				}
				selectMain();
			}
			return hierarchy;
		}
		set;
	}

	public List<HierarchyItem> hierarchyValues{
		get{
			return hierarchy.values();
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
                for(Integer i = 0; i <= (hierarchy.values().size()-1)/rowsPerPage; i++){
                    hierarchyValuesForDisplay.add(new List<HierarchyItem>());
                }

                // fill HierarchyItems in the sub-lists
                Integer itemNumber = 0;
                for(HierarchyItem item : hierarchy.values()){
                    hierarchyValuesForDisplay.get(itemNumber++/rowsPerPage).add(item);
                }
            }
            System.debug(loggingLevel.Info, '[cls AMS_AccountHierarchySelectionController] hierarchy items lists - ' + hierarchyValuesForDisplay);
            return hierarchyValuesForDisplay;
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
		for(HierarchyItem hi : hierarchyValues){
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

		if(oscar.AMS_Target_Agency__c != null && ((tocList.contains(AMS_Utils.LOCATION) && !(tocList.contains(AMS_Utils.OWNERSHIP_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)))  || (tocList.contains(AMS_Utils.LOCATION_INSPECTION) && !(tocList.contains(AMS_Utils.OWNERSHIP_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA)))))
			errorChecks.put(AMS_Utils.LOCATION, true);

		for(HierarchyItem hi : hierarchyValues){
			
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

			
			if(tocList.contains(AMS_Utils.VFMR) && !hi.selected && !hi.main && hi.acc.Is_Branch_Abroad__c!='Yes'){
				errorChecks.put(AMS_Utils.VFMR, true);
			}

			if(tocList.contains(AMS_Utils.OWNERSHIP_NON_IATA) || tocList.contains(AMS_Utils.OWNERSHIP_IATA)){
				if((hi.main || hi.selected) && (hi.acc.Location_Type__c == AMS_Utils.HO || hi.acc.Location_Type__c == AMS_Utils.AO)) ownershipMainHO = true;
				if(!hi.selected && !hi.main) ownershipAgenciesNotSelected = true;
			}

			if(isVoluntaryRelinquishment && isPartialHierarchy(hi)) errorChecks.put('Partial VR selection', true);
			
			if(tocList.contains(AMS_Utils.REMOVALTRADENAME)){
				if(hi.acc.CNS_Agency__c!=true)
					errorChecks.put(AMS_Utils.REMOVALTRADENAME, true);				
			}
			
		}

		//Second check for VMFR. If only BR abroad are selected, the system should allow to save
		if(tocList.contains(AMS_Utils.VFMR)){
			boolean onlyBRabroadAreSelected = true;
			for(HierarchyItem hi : hierarchyValues){
				if((hi.selected || hi.main) && hi.acc.Is_Branch_Abroad__c!='Yes'){
					onlyBRabroadAreSelected = false;
					break;
				}
			}
			if(onlyBRabroadAreSelected)
				errorChecks.remove(AMS_Utils.VFMR);
		}


		if(tocList.contains(AMS_Utils.OWNERSHIP_IATA) && !errorChecks.containsKey(AMS_Utils.OWNERSHIP_IATA)){
			if(oscar.AMS_Target_Agency__c == null) errorChecks.put(AMS_Utils.OWNERSHIP_IATA, true);
			else{
				String targetLocationType = [SELECT Id, Location_Type__c FROM Account WHERE Id = :oscar.AMS_Target_Agency__c].Location_Type__c;
				if(targetLocationType != AMS_Utils.HO && targetLocationType != AMS_Utils.AO) errorChecks.put(AMS_Utils.OWNERSHIP_IATA, true);
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
		//DTULLO: Added Record Type
		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');
		List<AMS_Process_Detail__c> newProcessHierarchy = new List<AMS_Process_Detail__c>();
		for(HierarchyItem hi : hierarchyValues){
			if(hi.selected && !hi.main){
				//DTULLO: Added Record Type
				newProcessHierarchy.add(new AMS_Process_Detail__c(Oscar__c = oscarId, Account__c = hi.acc.Id, recordtypeid = rtAgencyInvolved));
			}
		}

		try{

			if(!processDetails.isEmpty()) delete processDetails.values();
			if(!newProcessHierarchy.isEmpty()) insert newProcessHierarchy;
			List<Case> lstCases = [SELECT Id FROM Case WHERE Oscar__c = :oscarId AND RecordType.Name = 'OSCAR Communication' AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' ) ];
			if(!lstCases.isEmpty()) {
				update new Case(Id = lstCases[0].Id, AccountId = oscar.Account__c);
			}			
		}catch(Exception e){
			System.debug('updateRelatedRecords exception: ' + e + ' -- ' + e.getStackTraceString() );
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
			return false;
		}

		return true;
	}

	@TestVisible
	private Boolean isPartialHierarchy(HierarchyItem hi){
		if(hi.selected || hi.main){
			for(Id child : hi.childAccounts){
				if(!hierarchy.get(child).selected && !hierarchy.get(child).main) return true;
			}
		}
		return false;
	}

	public Boolean getDisablePrevious() { 
		//this will disable the previous and beginning buttons
		return (currentPage <= 0);
	}

	public Boolean getDisableNext() { //this will disable the next and end buttons
		return (currentPage >= hierarchyValuesForDisplay.size()-1);
	}


	// ***********************************
	// ********* action methods **********
	// ***********************************

	//AMSU-1
	public void checkCorrectionProcess(){
		
		if(isCorrection){
			//Check if all selected or not
			Boolean allSelected = true;
			for(HierarchyItem hi : hierarchyValues){
				if(!hi.main && !hi.selected){
					allSelected = false;
					break;
				}
			}
			//if all selected we want to deselect them and if only 1 selected we want to select all!
			selectAll = !allSelected;
			
			doSelectAll();

			//save();
			Savepoint sp = Database.setSavepoint();
			try {
				//must be after save, to pass validations on the details
				if(updateRelatedRecords()) closeTab = true;
			} catch(Exception e) {
				Database.rollback(sp);
				//DML Exceptions are sometimes displayed on the page
				if(e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
				System.debug('____ [cls AMS_AccountHierarchySelectionController - save] error - ' + e.getMessage());
			}
		}
	}

	public void selectMain() {
		for(HierarchyItem hi : hierarchyValues){
			if(hi.main){
				mainAccount = hi.acc;
				oscar.Account__c = hi.acc.Id;
			}
		}
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

	public void save(){
		if(performValidations()){

			Savepoint sp = Database.setSavepoint();
			try {
				update oscar;

				//must be after save, to pass validations on the details
				if(updateRelatedRecords()) closeTab = true;
			} catch(Exception e) {
				Database.rollback(sp);
				//DML Exceptions are sometimes displayed on the page
				if(e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
				System.debug(loggingLevel.ERROR, '____ [cls AMS_AccountHierarchySelectionController - save] error - ' + e.getMessage());
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

		private Set<Id> childAccounts;

		public HierarchyItem(Account a, Boolean main, Boolean selected, Set<Id> childAccounts){
			this.acc = a;
			this.main = main;
			this.selected = selected;
			this.childAccounts = childAccounts;
		}
	}
}