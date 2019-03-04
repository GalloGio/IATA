public with sharing class ANG_AccountHierarchySelectionController {

	public Account newParent{
		get{
			
			if(newParent == null && oscar.New_parent__c != null)
				return [Select Id, ANG_Accreditation_Model__c, Name, IATACode__c, Top_Parent__r.Location_Type__c, Location_Type__c
						from Account where ID = :oscar.New_parent__c];
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
					, 'Account__r.ANG_Accreditation_Model__c'
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
					, 'Location_Class__c'
					, 'Is_Branch_Abroad__c'
					, 'IATACode__c'
					, 'Status__c'
					, 'BillingCity'
					, 'Category__c'
 					, 'IATA_ISO_Country__r.AMS_Settlement_System__c'
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

					//NEWGEN-5008 - TEST SCENARIO 2/A AND 2/B
					if(this.isMulticountry){
						if(diffDestination(oscar.New_parent__c)) notes.add('The selected agencies will be linked to the new parent: ' + newParent.Name + '('+ newParent.IATACode__c +')');
						else notes.add('The selected agencies will be grouped into a new hierarchy, having as GE the new parent: '+ newParent.Name + '('+ newParent.IATACode__c +')');
					}
					else if(diffDestination(oscar.New_parent__c)) notes.add('The selected agencies will be transformed into AE and linked to the "New parent: '+newParent.Name+'('+ newParent.IATACode__c+')'+'", therefore they will automatically get the Accreditation type "'+newParent.ANG_Accreditation_Model__c+'".');
					else notes.add('The selected agencies will be grouped into a new hierarchy, having as HE the "New parent: '+newParent.Name+'('+newParent.IATACode__c+')". The new hierarchy will keep the actual accreditation type, unless the User selects also change of "Accreditation type".');
				}
				if(isMulticountry && tocList.contains(AMS_Utils.ANG_VMFR)) notes.add('VMFR must be applied to all agencies in the same BSP');
				else if(tocList.contains(AMS_Utils.ANG_VMFR)) notes.add('VMFR must be applied to the full hierarchy');

				if(tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE)) notes.add('Change of accreditation type must be applied to the full hierarchy unless you are also selecting change of Hierarchy');
				if(tocList.contains(AMS_Utils.CONVERTTONEWGENPILOT)){ notes.add('The conversion to GoLite must be applied to the full hierarchy'); }
				else if(tocList.contains(AMS_Utils.CONVERTTOLEGACY)){ notes.add('The conversion to Domestic with Cash must be applied to the full hierarchy'); }
				else if(tocList.contains(AMS_Utils.CONVERTTOINTERNATIONAL)){ notes.add('The conversion to International must be applied to the full hierarchy'); }
			
			}

			return notes;
		}
		set;
	}

	private Map<String, String> warningMessages {
		get {
			if(warningMessages == null){

				warningMessages = new Map<String, String>();

				warningMessages.put(
					'On Going OSCAR',
					'Please finalize any ongoing OSCAR process before proceeding with the conversion.'
				);

			}
			return warningMessages;
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
						
				errorMessages.put(
					'Require Location Class Domestic',
					'The conversion must be applied to a hierarchy of Domestic agents. Please proceed with a change of location type before processing the conversion.'
				);

				errorMessages.put(
					'Agents must be in the same BSP',
					'You cannot apply the change to agents in different BSPs at the same time. Please select agents in the same BSP.'
				);

				errorMessages.put(
					'All agents from the same BSP not selected',
					'VMFR must be applied to all agencies in the same BSP'
				);

				errorMessages.put(
					'Standard or Lite to Multicountry hierarchy', 
					'The selected new parent is part of a multicountry hierarchy. Please process a conversion in this scenario.'
				);

				errorMessages.put(
					'Multicountry to Standard or Lite hierarchy',
					'Cannot select a Standard or Lite hierarchy as the "New Parent".'
				);

				errorMessages.put(
					'Multicountry AE account alone in a BSP',
					'You cannot leave an AE account alone in a BSP. Please choose all the accounts in that BSP or perform a change of Location Type.'
				);

				errorMessages.put(
					'Multicountry change hierarchy must select GE',
					'You cannot choose an Account as a target for the destination hierarchy which does not have a valid Location type (GE).'
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

	public Boolean isChinaConversion { 
		get {
			return oscar.Process__c == AMS_Utils.NGCHINACONVERSION;
		}
		set;
	}

	public Boolean showOnGoingOscarWarning {
		get {
			
			if(showOnGoingOscarWarning == null){
				return false;
			}
			
			return showOnGoingOscarWarning;
		
		}
		set;
	}
	
	private Boolean existsLocClassDomesticError = false;
	private Boolean isMulticountry = false;
	private Boolean isCashOrCashless = false;
	private Map<Id, Integer> bspCountMap = new Map<Id, Integer>();
	private Map<ID, Set<Account>> bspAccountMap = new Map<ID, Set<Account>>();
	
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

				integer nbrOfPendingCases = 0;
				
				for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',')+', CNS_Agency__c ' + getOscarCaseSubQuery() + ' FROM Account WHERE Id IN :accountIds' + getInvalidStatusCondition())){
					Boolean main = (a.Id == oscar.Account__c);
					Boolean isSelected = (processDetails.containsKey(a.Id) || oscar.Process__c == AMS_Utils.NGCHINACONVERSION);
					hierarchy.put(a.Id, new HierarchyItem(a, main, isSelected,(a.Location_Type__c == AMS_Utils.HE || a.Location_Type__c == AMS_Utils.GE)));
					
					if(this.isMulticountry){

						integer bspCount = this.bspCountMap.get(a.IATA_ISO_Country__r.AMS_Settlement_System__c);

						if(bspCount == null){ 
							bspCount = 0;
						}

						bspCount++;

						this.bspCountMap.put(a.IATA_ISO_Country__r.AMS_Settlement_System__c, bspCount);

						//NEWGEN-5008 
						if(!bspAccountMap.containsKey(a.IATA_ISO_Country__r.AMS_Settlement_System__c))
							this.bspAccountMap.put(a.IATA_ISO_Country__r.AMS_Settlement_System__c, new Set<Account>());
						this.bspAccountMap.get(a.IATA_ISO_Country__r.AMS_Settlement_System__c).add(a);
					}

					if(oscar.Process__c == AMS_Utils.NGCHINACONVERSION){
						// Requires that every account have location class "D" if the account status 
						// is not one of the following: "Terminated", "Not in Operation", "Not Accredited" (pilotAccStatusNotRequireLocClassD)
						if(a.Location_Class__c != 'D' && !AMS_Utils.pilotAccStatusNotRequireLocClassD.contains(a.Status__c)){
							existsLocClassDomesticError = true;
						}

						List<Case> caseLst = a.getSobjects('Cases');
						if(caseLst != null) { 
							nbrOfPendingCases += caseLst.size(); 
						}
					}

				}

				// Require that at least 2 cases aren't finished
				// since the case associated with the account in context 
				// will not be finished at this point	
				if(oscar.Process__c == AMS_Utils.NGCHINACONVERSION && nbrOfPendingCases > 1){
					showOnGoingOscarWarning = true;
				}
				
				selectMain();
				
				if(oscar.Process__c == AMS_Utils.NGCHINACONVERSION){
					selectAll = true;
					doSelectAll();
				}
				
			}
			return hierarchy;
		}
		set;
	}

	public String getOscarCaseSubQuery(){

		String oscarCaseSubQuery = '';
		
		if(oscar.Process__c == AMS_Utils.NGCHINACONVERSION){
			oscarCaseSubQuery += ', (SELECT Id FROM Cases WHERE RecordType.DeveloperName = \'OSCAR_Communication\' ';
			oscarCaseSubQuery += ' AND Status NOT IN (\'Closed_ Not Accepted\', \'Closed_Rejected\', \'Closed_Withdrawn\', \'Closed\'))';
		}
		
		return oscarCaseSubQuery;

	}

	public String getInvalidStatusCondition(){
		
		String condition = '';
		
		if(oscar.Process__c != AMS_Utils.NGCHINACONVERSION){
			condition += ' AND Status__c NOT IN (';
			condition += getInvalidStatus();
			condition += ')';
		}
		
		return condition;
		
	}
	
	public String getInvalidStatus(){

		return '\''+AMS_Utils.ACC_S1_NOTACCREDITED + '\'' + ',' + '\'' +  AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING + '\'' + ',' + '\'' + AMS_Utils.ACC_S3_NOTINOPERATION + '\'' + ',' + '\'' + AMS_Utils.ACC_S0_TERMINATED + '\'' + ',' + '\'' + '\'';

	}

	public List<HierarchyItem> hierarchyValues{
		get{
			//Making sure that this warning is exhibt after elements rerenders
			if(showOnGoingOscarWarning){
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, warningMessages.get('On Going OSCAR')));
			}
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

		this.isMulticountry = oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		this.isCashOrCashless = (oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH || oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS);

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

		if(this.isMulticountry){ runMulticountryAgencyChangesValidations(); }

		if(tocList.contains(AMS_Utils.ANG_LOCATION) && !isJustOneAgencySelected()) errorChecks.put(AMS_Utils.ANG_LOCATION, true);

		if(tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)){
			if(!isJustOneAgencySelected()) errorChecks.put(AMS_Utils.ANG_LOCATION_TYPE, true);
			if(hasTopLocationType(oscar.Account__c)) errorChecks.put('Location Type on TOP Agency', true);				 
		}
		
		if(!this.isMulticountry && tocList.contains(AMS_Utils.ANG_VMFR) && !isAllHierarchySelected()) errorChecks.put(AMS_Utils.ANG_VMFR, true);

		if(tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE) && !tocList.contains(AMS_Utils.ANG_HIERARCHY) && !isAllHierarchySelected()) errorChecks.put(AMS_Utils.ANG_ACCREDITATION_TYPE, true);

		if(tocList.contains(AMS_Utils.ANG_HIERARCHY)){
			if(oscar.New_parent__c == null){
				errorChecks.put(AMS_Utils.ANG_HIERARCHY, true);
			}else{
				if(isTerminatedAccount(oscar.New_parent__c)) errorChecks.put('Terminated Accounts', true);
				if(!this.isMulticountry && isMovingTopLocationTypeAccount()  && !isAllHierarchySelected()) errorChecks.put('Orphan Accounts', true);
				if(diffDestination(oscar.New_parent__c)  && !hasTopLocationType(oscar.New_parent__c)) errorChecks.put('Top Location Type', true);
				if(!diffDestination(oscar.New_parent__c) && isAllHierarchySelected()) errorChecks.put('Location Type Change Detected', true);
				if(!diffDestination(oscar.New_parent__c) && !newParentIncluded(oscar.New_parent__c)) errorChecks.put('Must include New Parent', true);
				if(diffDestination(oscar.New_parent__c) && !isSingleDestinationHierarchy(oscar.New_parent__c)) errorChecks.put('Multiple Hierarchies', true);

				//NEWGEN-5007 
				if(this.isCashOrCashless && (newParent.Location_Type__c == AMS_Utils.GE || (newParent.Top_Parent__r != null && newParent.Top_Parent__r.Location_Type__c == AMS_Utils.GE))) errorChecks.put('Standard or Lite to Multicountry hierarchy', true);

				if(this.isMulticountry) runValidationChangeHierarchyforMulticountry();

				if(tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE) && diffDestination(oscar.New_parent__c)) errorChecks.put('Mixed types of changes', true);
			}
		}


		if((tocList.contains(AMS_Utils.CONVERTTONEWGENPILOT) || tocList.contains(AMS_Utils.CONVERTTOLEGACY) || tocList.contains(AMS_Utils.CONVERTTOINTERNATIONAL)) && existsLocClassDomesticError){
			errorChecks.put('Require Location Class Domestic', true);
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

		if(oscar.New_parent__c != null)	newParent = [Select Id, ANG_Accreditation_Model__c, Name, IATACode__c, Top_Parent__r.Location_Type__c, Location_Type__c 
													from Account where ID = :oscar.New_parent__c];

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

	/**
	* Runs several validations necessary for
	* multicountry agency changes
	*
	*/
	private void runMulticountryAgencyChangesValidations(){

		Boolean isSingleBSPSelected = true;
		Boolean allAgenciesFromSameBSPSelected = false;

		Id firstItemBSP = null;

		integer selectedCount = 0;

		for(HierarchyItem item : hierarchyValues){

			if(item.selected || item.main){
				selectedCount++;
				//Assigns the BSP related to the first selected account 
				if(firstItemBSP == null){
					firstItemBSP = item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c;
				}
				//If we found a selected account that has a different BSP than the one first found returns false 
				else if(firstItemBSP != item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c){
					isSingleBSPSelected = false;
				}
			}
			
		}
		
		allAgenciesFromSameBSPSelected = 
			firstItemBSP != null && 
			bspCountMap.get(firstItemBSP) == selectedCount;

		if((tocList.contains(AMS_Utils.ANG_LEGAL_NAME) || tocList.contains(AMS_Utils.ANG_LEGAL_STATUS) || 
				tocList.contains(AMS_Utils.ANG_MINOR_SHAREHOLDING) || tocList.contains(AMS_Utils.ANG_MAJOR_SHAREHOLDING) || 
				tocList.contains(AMS_Utils.ANG_OWNERSHIP) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) ||
				tocList.contains(AMS_Utils.ANG_TRADE_NAME) || tocList.contains(AMS_Utils.ANG_VMFR)) && !isSingleBSPSelected 
			){
				errorChecks.put('Agents must be in the same BSP', true);
		}

		if(tocList.contains(AMS_Utils.ANG_VMFR) && !allAgenciesFromSameBSPSelected){
			errorChecks.put('All agents from the same BSP not selected', true);
		}
	}


	/**
	 * Run validation for Multicountry change of hiearchy
	 * NEWGEN-5008
	 */
	private void runValidationChangeHierarchyforMulticountry(){

		System.debug('JR debug newParent:' + newParent.Top_Parent__r.Location_Type__c);

		//TEST SCENARIO 1
		//if(newParent.Location_Type__c != AMS_Utils.GE && (newParent.Top_Parent__r == null || (newParent.Top_Parent__r != null && newParent.Top_Parent__r.Location_Type__c != AMS_Utils.GE)))
		if(newParent.ANG_Accreditation_Model__c != AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY)
			errorChecks.put('Multicountry to Standard or Lite hierarchy', true);


		//TEST SCENARIO 3
		if(newParent.Location_Type__c == AMS_Utils.GE && diffDestination(oscar.New_parent__c)){

			Set<ID> selectBSPGeHE = new Set<ID>();
			Set<ID> notSelectBSPAE = new Set<ID>();

			for(HierarchyItem item : hierarchyValues){

				if((item.selected || item.main) && (item.acc.Location_Type__c == AMS_Utils.GE || item.acc.Location_Type__c == AMS_Utils.HE)){
					selectBSPGeHE.add(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c);
				}else if(!(item.selected || item.main) && item.acc.Location_Type__c == AMS_Utils.AE){
					notSelectBSPAE.add(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c);
				}
			}

			for(ID bsp : selectBSPGeHE){
				if(notSelectBSPAE.contains(bsp)){
					errorChecks.put('Multicountry AE account alone in a BSP', true);
				}
			}
		}

		//TEST SCENARIO 4
		if(newParent.Location_Type__c != AMS_Utils.GE && diffDestination(oscar.New_parent__c) && newParent.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY)
			errorChecks.put('Multicountry change hierarchy must select GE', true);
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