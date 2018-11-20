public with sharing class ANG_AccountHierarchySelectionController {

	public Account newParent{
		get{
			
			if(newParent == null && oscar.New_parent__c != null)
				return [Select Id, ANG_Accreditation_Model__c, Name, IATACode__c from Account where ID = :oscar.New_parent__c];
			else 
				return newParent;
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
					, 'ANG_Type_Of_Change__c'
					, 'New_parent__c'
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

			if(oscar.ANG_Type_Of_Change__c != null){
				
				if(tocList.contains(AMS_Utils.ANG_LEGAL_NAME) || tocList.contains(AMS_Utils.ANG_LEGAL_STATUS) || tocList.contains(AMS_Utils.ANG_MINOR_SHAREHOLDING) || tocList.contains(AMS_Utils.ANG_MAJOR_SHAREHOLDING) || tocList.contains(AMS_Utils.ANG_OWNERSHIP)) notes.add('Change of legal name / legal status / shareholding / ownership can be applied to any agency in the current hierarchy');
				if(tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY) ) notes.add('Change of location type will swap the current agency with the current HE.');				
				if(tocList.contains(AMS_Utils.ANG_LOCATION)) notes.add('Change of location can be applied only to a single agency.');				
				if(tocList.contains(AMS_Utils.ANG_HIERARCHY)) notes.add('Change of hierarchy will move all the selected agencies under the "New parent". The user must select a new parent which should be a HE of another hierarchy or one of the selected AE.');
				if(tocList.contains(AMS_Utils.ANG_HIERARCHY) && oscar.New_parent__c != null && newParent != null){

					if(diffDestination(oscar.New_parent__c)) notes.add('The selected agencies will be transformed into AE and linked to the "New parent: '+newParent.Name+'('+ newParent.IATACode__c+')'+'", therefore they will automatically get the Accreditation type "'+newParent.ANG_Accreditation_Model__c+'".');
					else notes.add('The selected agencies will be grouped into a new hierarchy, having as HE the "New parent: '+newParent.Name+'('+newParent.IATACode__c+')". The new hierarchy will keep the actual accreditation type, unless the User selects also change of "Accreditation type".');
				}
				if(tocList.contains(AMS_Utils.ANG_VMFR)) notes.add('VMFR must be applied to the full hierarchy');
				if(tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE)) notes.add('Change of accreditation type must be applied to the full hierarchy unless you are also selecting change of Hierarchy');
			
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
					AMS_Utils.ANG_LOCATION,
					'Change of location can be applied only to a single agency.'
				);

				errorMessages.put(
					AMS_Utils.LOCATION_TYPE,
					'For change of location type, only one account can be selected.'
				);

				errorMessages.put(
					AMS_Utils.ANG_HIERARCHY,
					'User must select the New parent. This New parent must be an external "HE" or one of the "AE" selected.'
				);

				errorMessages.put(
					AMS_Utils.ANG_VMFR,
					'VMFR must be applied to the full hierarchy.'
				);

				errorMessages.put(
					AMS_Utils.ANG_ACCREDITATION_TYPE,
					'Accreditatin Type must be applied to the full hierarchy.'
				);

				errorMessages.put(
					'Orphan Accounts',
					'You cannot leave an AE account alone in the hierarchy. Please choose all the accounts in the hierarchy or remove the Top Parent from the selected Accounts.'
				);

				errorMessages.put(
					'Top Location Type',
					'You cannot choose an Account as a target for the destination hierarchy which does not have a valid top Location type (HE).'
				);

				errorMessages.put(
					'Location Type Change Detected',
					'Selecting all hierarchy and not selecting a target agency outside of the hierarchy, means you are trying to perform a Change of Location Type. Please choose a valid target agency or change the Type of Change.'
				);

				errorMessages.put(
					'Multiple Hierarchies',
					'The target agency belongs to multiple hierarchies. To prevent inconsistencies please analyse this problem before performing the Change of Hierarchy.'
				);

				errorMessages.put(
					'Must include New Parent',
					'If you are performing a change of Hierarchy and selecting an AE from the current hierarchy as a new parent, you need to also include him in the agencies selected.'
				);

				errorMessages.put(
					'Mixed types of changes',
					'If you are performing a change of Hierarchy and Accreditation Type, you must selected a New Parent from the source hierarchy.'
				);

				errorMessages.put(
					'Terminated Accounts',
					'The destination agency cannot be a terminated account.'
				);

				errorMessages.put(
					'Location Type on TOP Agency',
					'You cannot perform a change of location type on a Top Level Agency.'	
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
			return (oscar.STEP6__c != AMS_Utils.PASSED);
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

	public Map<Id, HierarchyItem> hierarchy{
		get{
			if(hierarchy == null) {
				hierarchy = new Map<Id, HierarchyItem>();

				Set<Id> accountIds = new Set<Id>();
				Map<Id, List<AMS_Agencies_relationhip__c>> relationshipMap = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscar.Account__c});

				//to prevent nullpointer on agencies with no hierarchy
				accountIds.add(oscar.Account__c);
				
				for(AMS_Agencies_relationhip__c r : relationshipMap.get(oscar.Account__c)){
					accountIds.add(r.Child_Account__c);
					accountIds.add(r.Parent_Account__c);
				}
				
				/* Don't know exactly why this is here, but for future issues, we'll just leave it here commented.
				if(oscar.New_parent__c != null)
					accountIds.add(oscar.New_parent__c);
				*/

				for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',')+', CNS_Agency__c FROM Account WHERE Id IN :accountIds AND Status__c not in ( ' +  getInvalidStatus() + ' )')){
					Boolean main = (a.Id == oscar.Account__c);
					hierarchy.put(a.Id, new HierarchyItem(a, main, processDetails.containsKey(a.Id), (a.Location_Type__c == AMS_Utils.HE || a.Location_Type__c == AMS_Utils.GE)));
				}
				selectMain();
			}
			return hierarchy;
		}
		set;
	}

	public String getInvalidStatus(){

		return '\''+AMS_Utils.ACC_S1_NOTACCREDITED + '\'' + ',' + '\'' +  AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING + '\'' + ',' + '\'' + AMS_Utils.ACC_S3_NOTINOPERATION + '\'' + ',' + '\'' + AMS_Utils.ACC_S0_TERMINATED + '\'' + ',' + '\'' + '\'';

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
            System.debug(loggingLevel.Info, '[cls ANG_AccountHierarchySelectionController] hierarchy items lists - ' + hierarchyValuesForDisplay);
            return hierarchyValuesForDisplay;
        }
        set;
    }
    
	// ***********************************
	// ********** constructor ************
	// ***********************************
	public ANG_AccountHierarchySelectionController(ApexPages.StandardController stdController){
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

	@TestVisible private Boolean performValidations(){

		//clear error checks
		errorChecks = null;

		System.debug('Performing validations on the hierarchyValues:'+hierarchyValues);

		if(tocList.contains(AMS_Utils.ANG_LOCATION) && !isJustOneAgencySelected()) errorChecks.put(AMS_Utils.ANG_LOCATION, true);

		if(tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)){
			if(!isJustOneAgencySelected()) errorChecks.put(AMS_Utils.ANG_LOCATION_TYPE, true);
			if(hasTopLocationType(oscar.Account__c)) errorChecks.put('Location Type on TOP Agency', true);				 
		}
		
		if(tocList.contains(AMS_Utils.ANG_VMFR) && !isAllHierarchySelected()) errorChecks.put(AMS_Utils.ANG_VMFR, true);

		if(tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE) && !tocList.contains(AMS_Utils.ANG_HIERARCHY) && !isAllHierarchySelected()) errorChecks.put(AMS_Utils.ANG_ACCREDITATION_TYPE, true);

		if(tocList.contains(AMS_Utils.ANG_HIERARCHY)){
			if(oscar.New_parent__c == null){
				errorChecks.put(AMS_Utils.ANG_HIERARCHY, true);
			}else{
				if(isTerminatedAccount(oscar.New_parent__c)) errorChecks.put('Terminated Accounts', true);
				if(isMovingTopLocationTypeAccount()  && !isAllHierarchySelected()) errorChecks.put('Orphan Accounts', true);
				if(diffDestination(oscar.New_parent__c)  && !hasTopLocationType(oscar.New_parent__c)) errorChecks.put('Top Location Type', true);
				if(!diffDestination(oscar.New_parent__c) && isAllHierarchySelected()) errorChecks.put('Location Type Change Detected', true);
				if(!diffDestination(oscar.New_parent__c) && !newParentIncluded(oscar.New_parent__c)) errorChecks.put('Must include New Parent', true);
				if(diffDestination(oscar.New_parent__c) && !isSingleDestinationHierarchy(oscar.New_parent__c)) errorChecks.put('Multiple Hierarchies', true);

				if(tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE) && diffDestination(oscar.New_parent__c)) errorChecks.put('Mixed types of changes', true);
			}
		}

		//retrieve error messages
		List<String> errors = new List<String>();

		for(String error : errorChecks.keySet()){
			if(errorChecks.get(error)) errors.add(errorMessages.get(error));
		}

		//display error messages and stop execution by short-circuiting the if on the save method
		if(errors.isEmpty()) return true;

		for(String error : errors) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, error));
		return false;
	}

	@TestVisible private Boolean updateRelatedRecords() {
		//DTULLO: Added Record Type
		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');
		List<AMS_Process_Detail__c> newProcessHierarchy = new List<AMS_Process_Detail__c>();
		for(HierarchyItem hi : hierarchyValues){
			if(hi.selected && !hi.main){
				newProcessHierarchy.add(new AMS_Process_Detail__c(Oscar__c = oscarId, Account__c = hi.acc.Id, recordtypeid = rtAgencyInvolved));
			}
		}

		try{

			if(!processDetails.isEmpty()) delete processDetails.values();
			if(!newProcessHierarchy.isEmpty()) insert newProcessHierarchy;
			Id cId = [SELECT Id FROM Case WHERE Oscar__c = :oscarId AND RecordType.Name = 'OSCAR Communication' AND ( ParentId = null or Parent.RecordType.Name != 'OSCAR Communication' OR (Parent.RecordType.Name = 'OSCAR Communication' and Parent.Reason1__c = 'Annual revalidation'))  ].Id;
			update new Case(Id = cId, AccountId = oscar.Account__c);
		}catch(Exception e){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
			return false;
		}

		return true;
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

	public void selectMain() {
		for(HierarchyItem hi : hierarchyValues)	if(hi.main)	oscar.Account__c = hi.acc.Id;
	}

	public PageReference FetchNewParent(){

		if(oscar.New_parent__c != null)	newParent = [Select Id, ANG_Accreditation_Model__c, Name, IATACode__c from Account where ID = :oscar.New_parent__c];

		return null;
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

	public boolean isMovingTopLocationTypeAccount(){

		for(HierarchyItem item:hierarchyValues){
			if( (item.selected && item.isTopParent) || (item.main && item.isTopParent))
				return true;
		}

		return false;

	}


	public boolean isAllHierarchySelected(){

		for(HierarchyItem item:hierarchyValues){
			if(!item.selected && !item.main)
				return false;
		}

		return true;
	}

	public boolean hasTopLocationType(Id acctId){
		
		
		Account a = [Select Id, Location_Type__c from Account where Id = :acctId];

		/*
		for(HierarchyItem item:hierarchyValues){
			if(item.acc.Id == acctId && item.acc.Location_Type__c == AMS_Utils.HE)
				return true;
		}


		return false;
		*/

		return (a.Location_Type__c == AMS_Utils.HE || a.Location_Type__c == AMS_Utils.GE);
	}

	public boolean isTerminatedAccount(Id acctId){

		Account a = [Select Id, Status__c from Account where Id = :acctId];

		return a.Status__c == 'Terminated';

	}

	public boolean isJustOneAgencySelected(){

		Integer selected = 0;

		for(HierarchyItem item:hierarchyValues){
			if(item.selected || item.main)
				selected++;

		}

		return selected == 1;
	}

	public boolean diffDestination(Id newParent){

		for(HierarchyItem item:hierarchyValues){
			if(item.acc.Id == newParent)
				return false;
		}

		return true;
	}

	public boolean newParentIncluded(Id newParent){

		for(HierarchyItem item:hierarchyValues){
			if(item.acc.Id == newParent && (item.selected || item.main))
				return true;
		}

		return false;
	}

	public boolean isSingleDestinationHierarchy(Id accountId){

		Set<Id> hierarchies = new Set<Id>();

		List<AMS_Agencies_relationhip__c> rels = [Select Id, Hierarchy__c from AMS_Agencies_relationhip__c where Parent_Account__c = :accountId];
		
		if(rels.isEmpty())
			return true;
		else{
			
			for(AMS_Agencies_relationhip__c rel : rels){
				hierarchies.add(rel.Hierarchy__c);
			}
		}

		return hierarchies.size() == 1;
	}

	// ***********************************
	// *********** wrappers **************
	// ***********************************
	public class HierarchyItem{

		public Account acc { get; set; }
		public Boolean main { get; set; }
		public Boolean selected { get; set; }
		public Boolean isTopParent { get; set; }

		public HierarchyItem(Account a, Boolean main, Boolean selected, Boolean isTopParent){
			this.acc = a;
			this.main = main;
			this.selected = selected;
			this.isTopParent = isTopParent;
		}
	}
}