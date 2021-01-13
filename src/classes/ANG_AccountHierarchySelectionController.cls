public with sharing class ANG_AccountHierarchySelectionController {

	public Contact contact {get;set;} // new account to create

	public List<Account> results{get;set;} // search results

	public Account newParent{
		get{
			if(newParent == null && oscar.New_parent__c != null){
				FetchNewParent();
			}
			return newParent;
		}
		set;
	}

	@TestVisible private Account currentGE {get; set;}

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
					, 'HE_per_BSP_Mapping__c'
					, 'RecordTypeId'
					, 'AMS_Online_Accreditation__c'
				};
			}
			return oscarFields;
		}
		set;
	}

	// To avoid having a huge view state we opt to specify all the necessary fields
	// instead of using the getDescribe call to list all the account fields
	// Ideally should be fetched from a field set
	private static final Set<String> accountFields = new Set<String> {
		// DO NOT include Id on this Set
		'Name', 'Location_Type__c', 'Location_Class__c', 'Is_Branch_Abroad__c', 'IATACode__c', 'Status__c', 'BillingCity',
		'Category__c', 'IATA_ISO_Country__r.AMS_Settlement_System__c', 'IATA_ISO_Country__r.AMS_Settlement_System__r.Name',
		'IATA_ISO_Country__r.Name', 'CNS_Agency__c', 'ANG_Accreditation_Model__c', 'Remittance_Frequency__c', 'Abbreviated_address__c',
		'Abbreviated_name__c', 'Short_Name__c', 'TradeName__c', 'Solicitation_Flag__c', 'VAT_Number_2__c', 'Website', 'Email__c',
		'Fax', 'Phone', 'Company_Type__c', 'License_Number__c', 'VAT_Number__c', 'Mobile__c', 'Operation__c', 'Iso_State__c',
		'IATA_ISO_Country__c', 'BillingState', 'BillingPostalCode', 'BillingStreet', 'ShippingCity', 'ShippingCountry', 'IATA_ISO_Shipping_Country__c',
		'IATA_ISO_Shipping_State__c', 'ShippingPostalCode', 'ShippingState', 'ShippingStreet'
	};

	private Set<String> notes{
		get{
			notes = new Set<String>();

			if (oscar.ANG_Type_Of_Change__c != null) {
				notes.add('If you wish to correct any value on PCI status through this type of OSCAR, please note that those values will be applied to all accounts selected. The FoP will remain unchanged and no ebulletin message will be sent.');
				
				if (tocList.contains(AMS_Utils.ANG_LEGAL_NAME) || tocList.contains(AMS_Utils.ANG_LEGAL_STATUS)
					|| tocList.contains(AMS_Utils.ANG_MINOR_SHAREHOLDING)
					|| tocList.contains(AMS_Utils.ANG_MAJOR_SHAREHOLDING) || tocList.contains(AMS_Utils.ANG_OWNERSHIP)) {
					notes.add('Change of legal name / legal status / shareholding / ownership can be applied to any agency in the current hierarchy');
				}

				if (isMulticountry
					&& (tocList.contains(AMS_Utils.ANG_LOCATION_TYPE)
						|| tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY))) {
							notes.add('Change of location type will swap the selected agencies.');
				} else if (tocList.contains(AMS_Utils.ANG_LOCATION_TYPE)
					|| tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)) {
						notes.add('Change of location type will swap the current agency with the current HE.');
					}

				if (tocList.contains(AMS_Utils.ANG_LOCATION)) {
					notes.add('Change of location can be applied only to a single agency.');
				}

				if (tocList.contains(AMS_Utils.ANG_HIERARCHY)) {
					notes.add('Change of hierarchy will move all the selected agencies under the "New parent". The user must select a new parent which should be a HE or GE of another hierarchy or one of the selected AE.');
				}

				if (tocList.contains(AMS_Utils.ANG_HIERARCHY) && oscar.New_parent__c != null && newParent != null) {
					Boolean diffDestination = diffDestination(oscar.New_parent__c);
					// NEWGEN-5008 - TEST SCENARIO 2/A AND 2/B
					if (this.isMulticountry) {
						if (diffDestination) {
							notes.add('The selected agencies will be linked to the new parent: ' + newParent.Name + '('
								+ newParent.IATACode__c + ')');
						} else {
							if (isSingleBSPSelected) {
								notes.add('You selected locations in only one BSP. This change of hierarchy will result in a change of Accreditation Model from GoGlobal to GoStandard');
							} else {
								notes.add('The selected agencies will be grouped into a new hierarchy, having as GE the new parent: ' + newParent.Name + '(' + newParent.IATACode__c + ')');
							}
						}
						if (isOnlyGeBspLeft()) {
							notes.add('A conversion case from GoGlobal to GoStandard has been created, please proceed to that case to complete the process of the remaining locations.');
						}
					} else if (diffDestination) {
						notes.add('The selected agencies will be transformed into AE and linked to the "New parent: ' + newParent.Name
							+ '(' + newParent.IATACode__c + ')' + '", therefore they will automatically get the Accreditation type "'
							+ newParent.ANG_Accreditation_Model__c + '".');
					} else {
						notes.add('The selected agencies will be grouped into a new hierarchy, having as HE the "New parent: '
							+ newParent.Name + '(' + newParent.IATACode__c + ')". The new hierarchy will keep the actual accreditation type, unless the User selects also change of "Accreditation type".');
					}
				}

				if (isMulticountry && tocList.contains(AMS_Utils.ANG_VMFR)) {
					notes.add('VMFR must be applied to all agencies in the same BSP');
				} else if (tocList.contains(AMS_Utils.ANG_VMFR)) {
					notes.add('VMFR must be applied to the full hierarchy');
				}

				if (tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE)) {
					notes.add('Change of accreditation type must be applied to the full hierarchy unless you are also selecting change of Hierarchy');
				}

				if (tocList.contains(AMS_Utils.CONVERTTONEWGENPILOT)) {
					notes.add('The conversion to GoLite must be applied to the full hierarchy');
				} else if (tocList.contains(AMS_Utils.CONVERTTOLEGACY)) {
					notes.add('The conversion to Domestic with Cash must be applied to the full hierarchy');
				} else if (tocList.contains(AMS_Utils.CONVERTTOINTERNATIONAL)) {
					notes.add('The conversion to International must be applied to the full hierarchy');
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
					'You cannot choose an Account as a target for the destination hierarchy which does not have a valid top Location type (HE for cash and cashless, GE for multicountry).'
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
					'Only two agents selected with different location types',
					'For change of location type, only two accounts can be selected with different location type'
				);

				errorMessages.put(
					'Different BSP selected',
					'For change of location type to different legan entity, it is not possible to swap an AE with a HE from different BSP'
				);

				errorMessages.put(
					'Multicountry to Lite hierarchy',
					'You cannot select a Lite hierarchy as the New Parent.'
				);

				errorMessages.put(
					'Multicountry AE account alone in a BSP',
					'You cannot leave an AE account alone in a BSP. Please choose all the accounts in that BSP or perform a change of Location Type.'
				);

				errorMessages.put(
					'All selected locations are in the same BSP',
					'All the selected locations are in the same BSP, please process a Conversion or select additional locations.'
				);

				errorMessages.put(
					'missing HE for new bsp',
					'You need to select an account to be HE in all the new BSP\'s.'
				);

				errorMessages.put(
					'Multicountry GE selected performing change of hierarchy',
					'You cannot leave an HE or AE account alone in a multicountry hierarchy. Please choose all the accounts from the hierarchy.'
				);

				errorMessages.put(
					'Invalid Changes Combination',
					'You cannot select the change of hierarchy in combination with any other agency change for a multicountry hierarchy.'
				);

				errorMessages.put(
					'Standard Acquisition of MC Hierarchy Wrong BSP',
					'The New parent has accreditation model Cash, therefore all the selected locations must be in the same BSP of the New parent.'
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
			if(oscar == null && oscarId != null) oscar = Database.query('SELECT Id, '+String.join(oscarFieldList, ',')+'  FROM AMS_OSCAR__c WHERE Id = :oscarId');
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
	public Boolean isMulticountry{get;set;}
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

				integer nbrOfPendingCases = 0;

				for(Account a : Database.query('SELECT Id, '+String.join(accountFieldList, ',') + getOscarCaseSubQuery() + ' FROM Account WHERE Id IN :accountIds' + getInvalidStatusCondition())){
					Boolean main = (a.Id == oscar.Account__c);
					Boolean isSelected = (processDetails.containsKey(a.Id) || oscar.Process__c == AMS_Utils.NGCHINACONVERSION);
					hierarchy.put(a.Id, new HierarchyItem(a, main, isSelected,(a.Location_Type__c == AMS_Utils.HE || a.Location_Type__c == AMS_Utils.GE)));
					if(a.Location_Type__c == AMS_Utils.GE) currentGE = a;

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

				selectMainAccount();

				if(oscar.Process__c == AMS_Utils.NGCHINACONVERSION){
					selectAll = true;
					selectAllAccounts();
				}

			}
			return hierarchy;
		}
		set;
	}

	private Boolean isSingleBSPSelected {
		get {
			return (isSingleBSPSelected == null) ? checkSingleBSPSelected() : isSingleBSPSelected;
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
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, Label.ANG_OnGoing_OSCAR_Warning));
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

	public Boolean showBSPPanel{
		get{
			if(newParent != null && tocList.contains(AMS_Utils.ANG_HIERARCHY) && newParent.Location_Type__c == AMS_Utils.GE){
				for(HEPerBSP hePerBsp : hesPerBSPs.values()){
					if(hePerBsp.needsUserToChoose()){
						return true;
					}
				}
			}
			return false;
		}
		set;
	}

	public Map<Id,HEPerBSP> hesPerBSPs{
		get
		{
			if(hesPerBSPs == null) hesPerBSPs = new Map<Id,HEPerBSP>();
			return hesPerBSPs;
		}
		set;
	}

	public String JSONHEsPerBSPs{
		get
		{
			return JSON.serialize(hesPerBSPs);
		}
	}

	private Set<Id> newParentHierarchyBSPs{
		get{
			if(newParentHierarchyBSPs == null) newParentHierarchyBSPs = new Set<Id>();
			return newParentHierarchyBSPs;
		}

	set;}

	public List<List<HEPerBSP>> hesPerBSPsForDisplay{
		get{
			hesPerBSPsForDisplay = new List<List<HEPerBSP>>();

			//count the number of elements to display
			Integer itemsToShow = 0;
			for(HEPerBSP item : hesPerBSPs.values()) if(item.needsUserToChoose()) itemsToShow++;
			// create as many sub-lists as necessary

			for(Integer i = 0; i <= (itemsToShow-1)/rowsPerPage; i++){
				hesPerBSPsForDisplay.add(new List<HEPerBSP>());
			}

			// fill HierarchyItems in the sub-lists
			Integer itemNumber = 0;
			for(HEPerBSP item : hesPerBSPs.values()){
				if(item.needsUserToChoose()) hesPerBSPsForDisplay.get(itemNumber++/rowsPerPage).add(item);
			}

			System.debug(LoggingLevel.Info, '[cls ANG_AccountHierarchySelectionController] hesPerBSPsForDisplay: ' + hesPerBSPsForDisplay);

			return hesPerBSPsForDisplay;
		}
		set;
	}

	public Integer totalPagesForHEPerBSP{
		get{
			return hesPerBSPsForDisplay.size();
		}
	}


	// ***********************************
	// ********** constructor ************
	// ***********************************
	public ANG_AccountHierarchySelectionController(ApexPages.StandardController stdController){
		if(!Test.isRunningTest()) stdController.addFields(new List<String>(oscarFields));

		oscarId = stdController.getId();
		oscar = (AMS_OSCAR__c)stdController.getRecord();

		if(Test.isRunningTest()){
			oscar = (AMS_OSCAR__c) Database.query('SELECT ' + String.join(new List<String>(oscarFields), ', ') + ' FROM AMS_OSCAR__c WHERE Id = :oscarId');
		}

		this.isMulticountry = oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		this.isCashOrCashless = (oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH || oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS);

		if(String.isNotBlank(oscar.HE_per_BSP_Mapping__c)){
			Map<Id, Id> savedHEPerBSP = (Map<Id, Id>) JSON.deserialize(oscar.HE_per_BSP_Mapping__c, Map<Id, Id>.class);
			for(Id bspId : savedHEPerBsp.keySet()){
				hesPerBSPs.put(bspId, new HEPerBSP(bspId, savedHEPerBsp.get(bspId)));
			}
		}

		oscar.HE_per_BSP_Mapping__c = null;
	}

	// ***********************************
	// ********* helper methods **********
	// ***********************************

	public void singleSelect(){
		handleSelection();
	}

	public void doSelectAll(){
		selectAllAccounts();
		handleSelection();
	}

	public void selectAllAccounts(){
		for(HierarchyItem hi : hierarchyValues){
			if(!hi.main) hi.selected = selectAll;
		}
	}

	@TestVisible 
	private Boolean performValidations(){
		//clear error checks
		errorChecks = null;

		if (this.isMulticountry) { 
			runMulticountryAgencyChangesValidations();
		} else {
			if (tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)) {
				if (!isJustOneAgencySelected()) {
					errorChecks.put(AMS_Utils.ANG_LOCATION_TYPE, true);
				}
	
				if (hasTopLocationType(oscar.Account__c)) {
					errorChecks.put('Location Type on TOP Agency', true);
				}
			}

			if (tocList.contains(AMS_Utils.ANG_VMFR) && !isAllHierarchySelected()) {
				errorChecks.put(AMS_Utils.ANG_VMFR, true);
			}
		}

		if (tocList.contains(AMS_Utils.ANG_LOCATION) && !isJustOneAgencySelected()) {
			errorChecks.put(AMS_Utils.ANG_LOCATION, true);
		}

		if (tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE) && !tocList.contains(AMS_Utils.ANG_HIERARCHY) && !isAllHierarchySelected()) {
			errorChecks.put(AMS_Utils.ANG_ACCREDITATION_TYPE, true);
		}

		if(tocList.contains(AMS_Utils.ANG_HIERARCHY)){
			if(oscar.New_parent__c == null){
				errorChecks.put(AMS_Utils.ANG_HIERARCHY, true);
			}else{
				if (isTerminatedAccount(oscar.New_parent__c)) {
					errorChecks.put('Terminated Accounts', true);
				}

				if (diffDestination(oscar.New_parent__c)) {
					if (tocList.contains(AMS_Utils.ANG_ACCREDITATION_TYPE)) {
						errorChecks.put('Mixed types of changes', true);
					}

					if (!isSingleDestinationHierarchy(oscar.New_parent__c)) {
						errorChecks.put('Multiple Hierarchies', true);
					}

					if (!hasTopLocationType(oscar.New_parent__c)) {
						errorChecks.put('Top Location Type', true);
					}
				} else {
					if (isAllHierarchySelected()) {
						errorChecks.put('Location Type Change Detected', true);
					}

					if (!newParentIncluded(oscar.New_parent__c)) {
						errorChecks.put('Must include New Parent', true);
					}
				}

				if (this.isMulticountry) {
					runValidationChangeHierarchyforMulticountry();
				} else if (isMovingTopLocationTypeAccount() && !isAllHierarchySelected()) {
					errorChecks.put('Orphan Accounts', true);
				}

				if(newParent.Location_Type__c == AMS_Utils.GE){
					//validate and store in OSCAR
					Map<ID,ID> resultHEPerBSP = new Map<ID,ID>();
					for(HEPerBSP tt:  hesPerBSPs.values()){
						if(tt.p.ParentId == null && tt.possibleAccounts.size() > 1){
							errorChecks.put('missing HE for new bsp', true);
						}
						else {
							resultHEPerBSP.put(tt.bspId,tt.p.ParentId);
						}
					}

					oscar.HE_per_BSP_Mapping__c = JSON.serialize(resultHEPerBSP);
				}
			}
		}

		Boolean pilotTypeOfChange = (tocList.contains(AMS_Utils.CONVERTTONEWGENPILOT) || tocList.contains(AMS_Utils.CONVERTTOLEGACY) || tocList.contains(AMS_Utils.CONVERTTOINTERNATIONAL));

		if(pilotTypeOfChange && existsLocClassDomesticError){
			errorChecks.put('Require Location Class Domestic', true);
		}

		//retrieve error messages
		List<String> errors = new List<String>();

		for(String error : errorChecks.keySet()){
			if(errorChecks.get(error)) errors.add(errorMessages.get(error));
		}

		ANG_AgencyChangesConfigHelper.ChangesConfig changesConfig = null;

		if(oscar.Process__c == AMS_Utils.NGCHANGES){
			changesConfig = ANG_AgencyChangesConfigHelper.getConfig(oscar,oscar.Account__r.ANG_Accreditation_Model__c);
		}

		Boolean validChangeCombination = (changesConfig != null || oscar.Process__c != AMS_Utils.NGCHANGES);

		//display error messages and stop execution by short-circuiting the if on the save method
		if(errors.isEmpty() && validChangeCombination){
			return true;
		}

		for(String error : errors) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, error));
		return false;
	}

	@TestVisible private Boolean updateRelatedRecords() {

		Account oscarAcct = null;

		//DTULLO: Added Record Type
		ID rtAgencyInvolved = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Agency_Involved');
		List<AMS_Process_Detail__c> newProcessHierarchy = new List<AMS_Process_Detail__c>();
		for(HierarchyItem hi : hierarchyValues){
			if(hi.selected && !hi.main){
				newProcessHierarchy.add(new AMS_Process_Detail__c(Oscar__c = oscarId, Account__c = hi.acc.Id, recordtypeid = rtAgencyInvolved));
			}
			else if(hi.main){
				oscarAcct = hi.acc; 
			}
		}

		try{

			if(!processDetails.isEmpty()){
				delete processDetails.values();
			}

			if(!newProcessHierarchy.isEmpty()){
				insert newProcessHierarchy;
			}
			
			Id cId = [SELECT Id
					  FROM Case
					  WHERE Oscar__c = :oscarId
						  AND RecordType.Name = 'OSCAR Communication'
						  AND (ParentId = null
							   OR Parent.RecordType.Name != 'OSCAR Communication'
							   OR (Parent.RecordType.Name = 'OSCAR Communication'
								   AND Parent.Reason1__c = 'Annual revalidation'))].Id;

			update new Case(Id = cId, AccountId = oscar.Account__c);

			if(oscar.Process__c == AMS_Utils.NGCORRECTION && oscarAcct.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY){
				Map<String,Object> fieldsOfObject = ANG_MulticountryHelper.buildStagingAreaFieldsObject(oscarAcct);
				AMS_PAX_Accreditation_Form__c accreditationForm = new AMS_PAX_Accreditation_Form__c(Id = oscar.AMS_Online_Accreditation__c);
				accreditationForm = (AMS_Pax_Accreditation_Form__c) ANG_EntityCreator.addFieldsToObject((sObject)accreditationForm, fieldsOfObject);
				accreditationForm.HO_Account__c = null;
				accreditationForm.Account_Name__c = oscarAcct.Name;
				accreditationForm.Remittance_Frequency__c = oscarAcct.Remittance_Frequency__c;
				accreditationForm.ANG_Accreditation_type__c = oscarAcct.ANG_Accreditation_Model__c;
				update accreditationForm;
			}

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
		selectMainAccount();
		handleSelection();
	}

	public void selectMainAccount(){
		for(HierarchyItem hi : hierarchyValues) if(hi.main) oscar.Account__c = hi.acc.Id;
	}

	public void handleSelection(){

		if(newParent != null && tocList.contains(AMS_Utils.ANG_HIERARCHY) && newParent.Location_Type__c == AMS_Utils.GE){

			Map<Id,HEPerBSP> tempHesPerBSPs = new Map<Id,HEPerBSP>();

			List<HierarchyItem> hierarchyItemsSorted = hierarchy.values().clone();
			hierarchyItemsSorted.sort();

			for (HierarchyItem i : hierarchyItemsSorted){

				Id currentBSP = i.acc.IATA_ISO_Country__r.AMS_Settlement_System__c;

				if((i.selected || i.main) && !newParentHierarchyBSPs.contains(currentBSP)){

					if(!tempHesPerBSPs.containsKey(currentBSP)){
						tempHesPerBSPs.put(currentBSP, new HEPerBSP(currentBSP, i.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name, i.acc.IATA_ISO_Country__r.name));
					}

					HEPerBSP hePerBspItem = tempHesPerBSPs.get(currentBSP);

					hePerBspItem.addPossibleAccount(i.acc);

					if(hePerBspItem.p.ParentId == null){
						hePerBspItem.p.parentid = i.acc.id;
					}

					tempHesPerBSPs.put(currentBSP, hePerBspItem);

				}
			}

			for(HEPerBSP oldItem : hesPerBSPs.values()){
				HEPerBSP newItem = tempHesPerBSPs.get(oldItem.bspId);
				if(newItem != null && newItem.possibleAccounts.containsKey(oldItem.p.Parentid) && newItem.possibleAccounts.get(newItem.p.parentId).locationType == AMS_Utils.AE){
					newItem.p.parentId = oldItem.p.ParentId;
				}
			}

			hesPerBSPs = tempHesPerBSPs;

		}
	}

	public PageReference FetchNewParent(){

		if(oscar.New_parent__c != null){
			newParent =
				[SELECT
					Id,
					Name,
					IATACode__c,
					Location_Type__c,
					Parent.Location_Type__c,
					ANG_Accreditation_Model__c,
					Top_Parent__r.Location_Type__c,
					IATA_ISO_Country__r.AMS_Settlement_System__c,
					(SELECT Id, IATA_ISO_Country__r.AMS_Settlement_System__c FROM ChildAccounts)
				 FROM Account
				 WHERE Id = :oscar.New_parent__c
				];
		}

		if(newParent != null && tocList.contains(AMS_Utils.ANG_HIERARCHY) && newParent.Location_Type__c == AMS_Utils.GE){

			newParentHierarchyBSPs = null;
			newParentHierarchyBSPs.add(newParent.IATA_ISO_Country__r.AMS_Settlement_System__c);

			if(newParent.ChildAccounts != null){
				for(Account acc : newParent.ChildAccounts){
					newParentHierarchyBSPs.add(acc.IATA_ISO_Country__r.AMS_Settlement_System__c);
				}
			}

			handleSelection();

		}

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

		//Make sure that the proper main account is selected
		selectMainAccount();

		if(performValidations()){

			Savepoint sp = Database.setSavepoint();
			try {
				
				//Flag the oscar in case we are facing a specific scenario for a change of hierarchy
				//E.g. single standard hierarchy being acquired by a multicountry one
				oscar.Change_of_Hierarchy_Scenario__c = appendGeLeftStandaloneOptTo(fetchChangeOfHierarchyScenario());
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

	public boolean hasTopLocationType(Id acctId) {
		Account a = [SELECT Id, Location_Type__c, ANG_Accreditation_Model__c FROM Account WHERE Id = :acctId];

		return ((a.Location_Type__c == AMS_Utils.HE
			&& (a.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH
				|| a.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS))
			|| a.Location_Type__c == AMS_Utils.GE);
	}

	public boolean isTerminatedAccount(Id acctId){
		Account a = [Select Id, Status__c from Account where Id = :acctId];

		return a.Status__c == 'Terminated';
	}

	public boolean isJustOneAgencySelected(){
		Integer selected = 0;

		for(HierarchyItem item:hierarchyValues){
			if(item.selected || item.main) {
				selected++;
			}
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

	private Boolean checkSingleBSPSelected() {
		Id firstItemBSP = null;

		for (HierarchyItem item : hierarchyValues) {
			if (item.selected || item.main) {
				if (firstItemBSP == null) {
					firstItemBSP = item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c;
				} else if (firstItemBSP != item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c) {
					return false;
				}
			}
		}

		return true;
	}

	/**
	* Runs several validations necessary for
	* multicountry agency changes
	*
	*/
	private void runMulticountryAgencyChangesValidations(){
		Boolean onlyTwoAgenciesSelected = false;
		Boolean diffLocationTypesSelected = false;
		Boolean allAgenciesFromSameBSPSelected = false;
		isSingleBSPSelected = null;

		Set<String> locationTypeSet = new Set<String>();

		Id firstItemBSP = null;

		integer selectedCount = 0;
		integer hierarchySize = hierarchyValues.size();

		Integer selectedAE = 0;
		Integer selectedHE = 0;

		for(HierarchyItem item : hierarchyValues){

			if(item.selected || item.main){

				selectedCount++;
				//Store all the selected location types
				//to check if different types were selected
				locationTypeSet.add(item.acc.Location_Type__c);

				//Assigns the BSP related to the first selected account
				if(firstItemBSP == null){
					firstItemBSP = item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c;
				}

				if (item.acc.Location_Type__c == AMS_Utils.HE)
					selectedHE++;
				else if (item.acc.Location_Type__c == AMS_Utils.AE)
					selectedAE++;
			}

		}

		onlyTwoAgenciesSelected = (selectedCount == 2);
		diffLocationTypesSelected = (locationTypeSet.size() > 1);

		allAgenciesFromSameBSPSelected = (firstItemBSP != null && bspCountMap.get(firstItemBSP) == selectedCount);

		if((tocList.contains(AMS_Utils.ANG_LEGAL_NAME) || tocList.contains(AMS_Utils.ANG_LEGAL_STATUS) ||
				tocList.contains(AMS_Utils.ANG_MINOR_SHAREHOLDING) || tocList.contains(AMS_Utils.ANG_MAJOR_SHAREHOLDING) ||
				tocList.contains(AMS_Utils.ANG_OWNERSHIP) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) ||
			tocList.contains(AMS_Utils.ANG_TRADE_NAME) || tocList.contains(AMS_Utils.ANG_VMFR)) && !isSingleBSPSelected) {
				errorChecks.put('Agents must be in the same BSP', true);
		}

		if(tocList.contains(AMS_Utils.ANG_LOCATION_TYPE) || tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY)){
			if(!onlyTwoAgenciesSelected || !diffLocationTypesSelected){
				errorChecks.put('Only two agents selected with different location types', true);
			}
		}

		if (tocList.contains(AMS_Utils.ANG_LOCATION_TYPE_DIFFLEGALENTITY) && !isSingleBSPSelected && selectedHE == 1 && selectedAE == 1) {
			errorChecks.put('Different BSP selected', true);
		}

		if(tocList.contains(AMS_Utils.ANG_VMFR) && !allAgenciesFromSameBSPSelected){
			errorChecks.put('All agents from the same BSP not selected', true);
		}

		//If a GE location is selected when performing a change of hierarchy the user has to select the entire hierarchy
		//since it is not allowed to leave HE or AE accounts alone in the hierarchy
		if(tocList.contains(AMS_Utils.ANG_HIERARCHY) && locationTypeSet.contains(AMS_Utils.GE) && selectedCount != hierarchySize){
			errorChecks.put('Multicountry GE selected performing change of hierarchy', true);
		}
	}

	/**
	 * Run validation for Multicountry change of hiearchy
	 * NEWGEN-5008
	 */
	private void runValidationChangeHierarchyforMulticountry(){

		//TEST SCENARIO 1
		if (newParent.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASHLESS) {
			errorChecks.put('Multicountry to Lite hierarchy', true);
		}

		//TEST SCENARIO 3
		Set<ID> selectBSPGeHE = new Set<ID>();
		Set<ID> notSelectBSPAE = new Set<ID>();

		for (HierarchyItem item : hierarchyValues) {
			
			if ((item.selected || item.main)
				&& (item.acc.Location_Type__c == AMS_Utils.GE || item.acc.Location_Type__c == AMS_Utils.HE)) {
				selectBSPGeHE.add(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c);
			} else if (!(item.selected || item.main) && item.acc.Location_Type__c == AMS_Utils.AE) {
				notSelectBSPAE.add(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c);
			}
		}

		for(ID bsp : selectBSPGeHE){
			if(notSelectBSPAE.contains(bsp)){
				errorChecks.put('Multicountry AE account alone in a BSP', true);
			}
		}

		if (newParent.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH) {
			for (HierarchyItem item: hierarchyValues) {
				if ((item.selected || item.main) && item.acc.IATA_ISO_Country__r.AMS_Settlement_System__c != newParent.IATA_ISO_Country__r.AMS_Settlement_System__c) {
					errorChecks.put('Standard Acquisition of MC Hierarchy Wrong BSP', true);
					break;
				}
			}
		}
	}

	private boolean isOnlyGeBspLeft() {
		Set<Id> bsp = new Set<Id>();
		
		for (HierarchyItem i : hierarchy.values()) {
			if (!i.selected && !i.main)
				bsp.add(i.acc.IATA_ISO_Country__r.AMS_Settlement_System__c);
		}
		
		return bsp.size() == 1;
	}

	private String appendGeLeftStandaloneOptTo(String changeOfHierarchyScenario) {
		if (this.isMulticountry && oscar.ANG_Type_Of_Change__c != null && tocList.contains(AMS_Utils.ANG_HIERARCHY) && isOnlyGeBspLeft()) {
			return (String.isNotBlank(changeOfHierarchyScenario) ? 
				changeOfHierarchyScenario + ';' : '') + 
				AMS_Utils.MULTICOUNTRY_GE_ACCOUNT_LEFT_AS_STANDALONE;
		}
		return changeOfHierarchyScenario;
	}

	private String fetchChangeOfHierarchyScenario(){
		if(oscar.ANG_Type_Of_Change__c != null && tocList.contains(AMS_Utils.ANG_HIERARCHY)) {

			if(newParent.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY){

				if(oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH){
					return AMS_Utils.STANDARD_HIERARCHY_BEING_ACQUIRED_BY_MULTICOUNTRY;
				}

				if (newParentIncluded(newParent.Id)) {
					if (isSingleBSPSelected){
						return AMS_Utils.MULTICOUNTRY_BSP_SPLIT;
					} else {
						return AMS_Utils.MULTICOUNTRY_HIERARCHY_SPLIT;
					}
				}
			}

			if (newParent.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH) {
				if (oscar.Account__r.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY) {
					return AMS_Utils.MULTICOUNTRY_LOCATIONS_ACQUIRED_BY_STANDARD;
				}
			}
		}

		return null;
	}

	// ***********************************
	// *********** wrappers **************
	// ***********************************
	public class HierarchyItem implements Comparable {

		public Account acc { get; set; }
		public Boolean main { get; set; }
		public Boolean selected { get; set; }
		public Boolean isTopParent { get; set; }
		public String compareKey {get; set;}

		public HierarchyItem(Account a, Boolean main, Boolean selected, Boolean isTopParent){
			this.acc = a;
			this.main = main;
			this.selected = selected;
			this.isTopParent = isTopParent;
			this.compareKey = a.IATA_ISO_Country__r.AMS_Settlement_System__c + (a.Location_Type__c == AMS_Utils.GE ? 'A' : (a.Location_Type__c == AMS_Utils.HE ? 'B' : 'C'));
		}

		public Integer compareTo(Object compareTo){
			HierarchyItem hi = (HierarchyItem) compareTo;
			return this.compareKey.compareTo(hi.compareKey);
		}
	}

	private class AccountMinifyWrapper {
		public Id accountId;
		public String iataCode;
		public String locationType;
		public AccountMinifyWrapper(Id acctId, String iataCode, String locationType){
			this.accountId = acctId;
			this.iataCode = iataCode;
			this.locationType = locationType;
		}
	}

	public class HEPerBSP {

		public String name { get; set; }
		public Id bspId { get; set; }
		public String country { get; set; }
		public Account p { get; set; }
		public Map<ID, AccountMinifyWrapper> possibleAccounts { get; private set; }
		public boolean needsUserToChoose() {
				return (possibleAccounts.size() > 1 && (p.Parentid == null || (possibleAccounts.containsKey(p.ParentId) && possibleAccounts.get(p.Parentid).locationType == AMS_Utils.AE)));
		}

		public String iataCode {
			get {
				if(possibleAccounts.containsKey(p.ParentId)){
					return possibleAccounts.get(p.ParentId).iataCode;
				}
				return null;
			} 
			set;
		}

		public HEPerBSP(Id bspId, Id acctId){
			this.bspId = bspId;
			p = new Account();
			p.parentid = acctId;
			possibleAccounts = new Map<Id, AccountMinifyWrapper>();
		}

		public HEPerBSP(Id bspId, String name, String country){
			this.bspId = bspId;
			this.name = name;
			this.country = country;
			possibleAccounts = new Map<Id, AccountMinifyWrapper>();
			p = new Account();

		}

		public void addPossibleAccount(Account acct){
			possibleAccounts.put(acct.Id, new AccountMinifyWrapper(acct.Id, acct.IATACode__c, acct.Location_Type__c));
		}

	}
}