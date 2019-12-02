public with sharing class ANG_MulticountryHierarchySelectionCrtl {

    @TestVisible
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
		get{
			if(accountFields == null){
				accountFields = new Set<String>();
				Map<String, Schema.SObjectField> schemaFieldMapAccounts = Account.sObjectType.getDescribe().fields.getMap();
				for (String field : schemaFieldMapAccounts.keySet()){
					accountFields.add(field);
				}
				accountFields.add('IATA_ISO_Country__r.Name');
				accountFields.add('IATA_ISO_Country__r.ISO_Code__c');
				accountFields.add('IATA_ISO_Country__r.Region__c');
				accountFields.add('IATA_ISO_Country__r.AMS_Settlement_System__r.Name'); 
			}
			return accountFields;
		}
		set;
	}

	private Set<String> notes{
		get{
			Set<String> toReturn = new Set<String>();
			if(isConversionProcess){
				toReturn.add('This page will allow the user to define the Multicountry hierarchy.');
				toReturn.add('The following rules will be applied:');
				toReturn.add('There are no active AE locations alone in any BSP');
				toReturn.add('There is 1 and only 1 GE in the hierarchy');
				toReturn.add('In every BSP there is 1 and only 1 HE or GE');
				toReturn.add('There are at least 2 BSPs involved');
				toReturn.add('You cannot proceed if the agencies selected are not in Approved status');
				toReturn.add('You cannot proceed if the agencies selected do not have the same Remittance Frequency per BSP');
			}else{
				toReturn.add('This page will allow the user to select the Hierarchy of the multi-country hierarchy.');
				toReturn.add('The following rules must be implemented:');
				toReturn.add('There are not AEs alone in any BSP.');
				toReturn.add('There is 1 and only 1 GE');
				toReturn.add('In each BSP there is 1 and only 1 HE');
				toReturn.add('There are at least 2 BSPs involved');
			}
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

	public Map<Id, AMS_Process_Detail__c> mapHierarchyProcessDetail{
		get{
			if(isConversionProcess && mapHierarchyProcessDetail == null){
				mapHierarchyProcessDetail = new Map<Id, AMS_Process_Detail__c>();
				Id oscarId = oscar.Id;
				for(AMS_Process_Detail__c detail : [SELECT id, Account__c, OSCAR__c, ANG_Location_Type_Conversion__c FROM AMS_Process_Detail__c WHERE OSCAR__c = :oscarId]) {
					mapHierarchyProcessDetail.put(detail.Account__c, detail);
				}
			}
			return mapHierarchyProcessDetail;
		}
		set;
	}

	public Map<Id, Account> mapHierarchyAccounts{
		get{
			if(mapHierarchyAccounts == null){
				String condition = 'WHERE Id in (';
				//Load accounts from AMS_Proccess_Detail if is a ConvertionProcess
				if(isConversionProcess){
					for(Id id : mapHierarchyProcessDetail.keySet()){
						condition += ' \'' + id + '\',';
					}
					condition += '\''+oscar.Account__c+'\') ORDER BY IATA_ISO_Country__r.Name'; //Oscar account id (Should be the GE at this point)
				}else{
					Id accountId = oscar.Account__c;
					condition = ' WHERE ( Top_Parent__c = :accountId or Id = :accountId ) AND Status__c not in ( ' +  getInvalidStatus() + ' ) ORDER BY IATA_ISO_Country__r.Name';
				}
				mapHierarchyAccounts = new Map<Id, Account>((List<Account>)Database.query('SELECT ' + String.join(accountFieldList, ',') + ' FROM Account ' + condition));
			}
			return mapHierarchyAccounts;
		}
		set;
	}

	public Map<String, List<HierarchyItem>> hierarchy{
		get{
			if(hierarchy == null) {
				hierarchy = new Map<String, List<HierarchyItem>>();

				for(Account a : mapHierarchyAccounts.values()){
					Boolean main = (a.Id == oscar.Account__c);

					if(a.Location_Type__c == null) a.Location_Type__c = AMS_Utils.AE;
					
					else if(isConversionProcess && main) a.Location_Type__c = AMS_Utils.GE;

					else if(isConversionProcess && mapHierarchyProcessDetail.get(a.id).ANG_Location_Type_Conversion__c != null)
						a.Location_Type__c = mapHierarchyProcessDetail.get(a.id).ANG_Location_Type_Conversion__c;

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

    @TestVisible
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

	private static Id oscarMainAccount;

	public Boolean isConversionProcess{
		get{
			if(isConversionProcess == null){
				isConversionProcess = oscar.RecordTypeId == AMS_Utils.RECTYPE_NGCONVERSIONTOMULTICOUNTRY ? true : false;
			}
			return isConversionProcess;
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

		if(Test.isRunningTest()) oscar =  [Select Id, RecordTypeId, Account__c, Process__c, Step6__c, ANG_Type_Of_Change__c, STEP45__c, ANG_Hierarchy_Created__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Id =:oscarId];
	
	}




	// ***********************************
	// ********* action methods **********
	// ***********************************

	public void selectMain() {
		for(HierarchyItem hi : hierarchyValues){
			if(hi.main)	{

				if(oscar.Account__c <> hi.acc.Id){
					oscar.Account__c = hi.acc.Id;
					oscarMainAccount = oscar.Account__c;
				}
				
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
					AMS_AgencyRelationshipTriggerHandler.AMS_HierarchyProcess = true;
					update accountsToUpdate;
					createHierarchy(accountsToUpdate);
				}

				oscar.Step45__c = AMS_Utils.PASSED;
								
				selectMain();

				if(oscarMainAccount != null){
					oscar.Account__c = oscarMainAccount;
				}

				Account mainAccount = mapHierarchyAccounts.get(oscar.Account__c);

				Id oscarCaseId = null;
				if(String.isNotBlank(oscar.Oscar_Communication_Case_Id__c)){
					oscarCaseId = Id.valueOf(oscar.Oscar_Communication_Case_Id__c);
				}
				else{
					oscarCaseId = [SELECT Id FROM Case WHERE OSCAR__c = :oscar.Id].Id;
				}

				List<AMS_Pax_Accreditation_Form__c> accreditationFormsLst = new List<AMS_Pax_Accreditation_Form__c>(
					[SELECT
						Id,
						SAAM_Case__c,
						HO_Account__c,
						SAAM_Case__r.Origin,
						ISSP_Branch_AccountId__c
					FROM AMS_Pax_Accreditation_Form__c
					WHERE SAAM_Case__c = :oscarCaseId
					]
				);
					
				//Assuming that we always have several staging records 
				//when the oscar is created from the portal 
				//and a single record when created internally
				if(accreditationFormsLst.size() == 1 && oscarMainAccount != null){

					AMS_Pax_Accreditation_Form__c accreditationForm = accreditationFormsLst.get(0);

					Map<String,Object> fieldsOfObject = ANG_MulticountryHelper.buildStagingAreaFieldsObject(mainAccount);
					accreditationForm.Account_Name__c = mainAccount.Name;
					accreditationForm = (AMS_Pax_Accreditation_Form__c)ANG_EntityCreator.addFieldsToObject((sObject)accreditationForm, fieldsOfObject);

				}
				else if(accreditationFormsLst.size() > 1 && oscarMainAccount != null){
					
					Map<Id, AMS_Pax_Accreditation_Form__c> accreditationFormsMap = new Map<Id, AMS_Pax_Accreditation_Form__c>();

					for(AMS_Pax_Accreditation_Form__c form : accreditationFormsLst){
						Id acctId = form.HO_Account__c != null ? form.HO_Account__c : Id.valueOf(form.ISSP_Branch_AccountId__c);
						accreditationFormsMap.put(acctId, form);
					} 

					for(Account acct : accountsToUpdate){
						AMS_PAX_Accreditation_Form__c form = accreditationFormsMap.get(acct.Id);

						form.ISSP_Branch_AccountId__c = acct.Location_Type__c != AMS_Utils.GE ? String.valueOf(acct.Id) : '';
						form.HO_Account__c = acct.Location_Type__c == AMS_Utils.GE ? acct.Id : null; 
						form.ANG_Accreditation_type__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
						form.Location_Type__c = acct.Location_Type__c;
						form.Same_Legal_Entity_Agency_Form__c = null;
						form.Same_Legal_Entity_Agency_Id__c = null;
						form.AE_separate_Legal_Entity__c = null;
						form.ANG_AE_SameLegal__c = null;
						
						if(acct.Id == oscar.Account__c){
							oscar.AMS_Online_Accreditation__c = form.Id;
						}

					}

				}

				update oscar;

				if(oscarMainAccount != null){
					update new Case(
						Id = oscarCaseId,
						AccountId = oscar.Account__c,
						BSPCountry__c = mainAccount.IATA_ISO_Country__r.Name,
						Region__c = mainAccount.IATA_ISO_Country__r.Region__c,
						Country_concerned_by_the_query__c = mainAccount.IATA_ISO_Country__r.Name,
						IFAP_Country_ISO__c = mainAccount.IATA_ISO_Country__r.ISO_Code__c
					);
					update accreditationFormsLst;
				}

				Set<Id> acctId = new Set<Id>();
				
				for(Account a: accountsToUpdate){
					if(a.Location_Type__c != AMS_Utils.GE){
						acctId.add(a.id);
					}
				}

				if(Test.isRunningTest()){
					Id accountIdToTest =  (new list<ID>(acctId))[0];
					acctId = new Set<Id>{accountIdToTest};
				}

				ANG_MulticountryOscarCreatorBatch myBatchObject = new ANG_MulticountryOscarCreatorBatch(oscarCaseId, AcctId); 
				Id batchId = Database.executeBatch(myBatchObject,1);

				closeTab = true;

			} catch(Exception e) {
				closeTab = false;
				Database.rollback(sp);
				//DML Exceptions are sometimes displayed on the page
				if(e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes: '+ e.getMessage()));
				System.debug(loggingLevel.ERROR, '____ [cls AMS_AccountHierarchySelectionController - save] error - ' + e.getMessage());
			}
		}
	}

	
	public void saveConversion(){

		//Check which account were changed
		checkChangesOnConversionHierarchy();
	
		if(performValidations()){

			Savepoint sp = Database.setSavepoint();
			try {
	
				AMS_Pax_Accreditation_Form__c accreditationForm = [Select Id, SAAM_Case__c, Location_Type__c from AMS_Pax_Accreditation_Form__c where Id =:oscar.AMS_Online_Accreditation__c];
				Account account = mapHierarchyAccounts.get(oscar.Account__c);
				selectMain();

				//if main account changed change update the stagging area
				if(oscarMainAccount != null){
					oscar.Account__c = oscarMainAccount;
					Case caseToUpdate = new Case(Id = accreditationForm.SAAM_Case__c);
					caseToUpdate.AccountId = oscar.Account__c;
					account = mapHierarchyAccounts.get(oscar.Account__c);
					Map<String,Object> fieldsOfObject = ANG_MulticountryHelper.buildStagingAreaFieldsObject(account);
					accreditationForm = (AMS_Pax_Accreditation_Form__c)ANG_EntityCreator.addFieldsToObject((sObject)accreditationForm, fieldsOfObject);
					accreditationForm.HO_Account__c = oscar.Account__c;
					accreditationForm.Account_Name__c = account.Name;
					accreditationForm.Remittance_Frequency__c = account.Remittance_Frequency__c;
					accreditationForm.ANG_Accreditation_type__c = account.ANG_Accreditation_Model__c;

					update oscar;
					update caseToUpdate;
					update accreditationForm;
				}
				else if(accreditationForm.Location_Type__c != account.Location_type__c) {
					accreditationForm.Location_Type__c = account.Location_type__c;
					update accreditationForm; //enforce the new location type 
				}

				List<AMS_Process_Detail__c> processDetails = new List<AMS_Process_Detail__c>();

				for(HierarchyItem item : hierarchyValues){
					if(mapHierarchyProcessDetail.get(item.acc.ID) != null) 
						processDetails.add(mapHierarchyProcessDetail.get(item.acc.ID));
				}

				System.debug(loggingLevel.DEBUG, '____ [cls AMS_AccountHierarchySelectionController - saveConversion] Process Details to update: ' + processDetails);

				update processDetails;

				//Close Tab
				closeTab = true;

			}catch(Exception e) {
				Database.rollback(sp);
				//DML Exceptions are sometimes displayed on the page
				if(e.getTypeName() != 'System.DmlException' || !ApexPages.hasMessages()) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Couldn\'t save changes '+ e.getMessage()));
				System.debug(loggingLevel.ERROR, '____ [cls AMS_AccountHierarchySelectionController - saveConversion] error - ' + e.getMessage());
			}
		}
	} 

	private void createHierarchy(List<Account> acctLst){

		Id accountGEId;
		for(Account acct: acctLst){
			if(acct.Location_type__c == AMS_Utils.GE)
				accountGEId = acct.Id;
		}

		Set<String> alreadyCreatedRelations = new Set<String>();

		for(AMS_Agencies_relationhip__c ar : [Select Id, Parent_Account__c, Child_Account__c from AMS_Agencies_relationhip__c where Child_Account__r.Top_Parent__c = :oscar.account__c])
			alreadyCreatedRelations.add(String.valueof(ar.Child_Account__c)+String.valueOf(ar.Parent_Account__c));

		if(acctLst.size() < 2){
			if(acctLst.size() == 1 && acctLst.get(0).location_type__C == AMS_Utils.GE){
				AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy', Main_Account__c = accountGEId);
				insert hierarchy;
			}
			return;
		}

		AMS_Agencies_Hierarchy__c hierarchy = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy', Main_account__c = accountGEId);
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
		} else
			delete hierarchy;

	}


	private List<Account> fetchAccounts(){

		Set<Account> toReturn = new Set<Account>();

		for(List<HierarchyItem> itemsList: hierarchy.values()){
			for(HierarchyItem item: itemsList)
				if(item.wasChanged)
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
				}else{
					item.acc.Top_Parent__c = null;
					item.acc.ParentId = null;						
					item.wasChanged = true;
				}

			}

		}

	}

	@TestVisible private void adjustHierarchy(){

		for(HierarchyItem item: hierarchyValues){

			if(item.isHE){
				item.acc.Location_type__c = AMS_Utils.HE;
				item.wasChanged = true;
				item.isTopParent = false;
			}
			if(item.isAE){
				item.acc.Location_type__c = AMS_Utils.AE;
				item.wasChanged = true;
				item.isTopParent = false;
			
			}
			if(!item.isHE && !item.isAE){
				item.acc.Location_type__c = AMS_Utils.GE;
				item.wasChanged = true;
				item.isTopParent = true;
			}
		}
	}


	@TestVisible private void checkChangesOnConversionHierarchy(){

		AMS_Process_Detail__c cloneProcess;
		Account oldMainAccount;
		
		List<AMS_Process_Detail__c> pdLst = mapHierarchyProcessDetail.values();

		mapHierarchyProcessDetail.clear();

		integer i=0;

		for(HierarchyItem item: hierarchyValues){
			
			if(!item.isHE && !item.isAE){
				item.acc.Location_type__c = AMS_Utils.GE;
				continue;
			}

			AMS_Process_Detail__c currentPD = pdLst.get(i);
			
			currentPD.account__c = item.acc.Id;

			if(item.isHE){
				currentPD.ANG_Location_Type_Conversion__c = AMS_Utils.HE;
				item.acc.Location_type__c = AMS_Utils.HE;
			} 
			else {
				currentPD.ANG_Location_Type_Conversion__c = AMS_Utils.AE;
				item.acc.Location_type__c = AMS_Utils.AE;
			}

			mapHierarchyProcessDetail.put(currentPD.account__c, currentPD);
			
			i++;

		}

	}

	@TestVisible private boolean performValidations(){

		boolean toReturn = true;

		Set<String> invalidAgencyStatus = new Set<String>{AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S7_UNDERREVIEW, AMS_Utils.ACC_S8_CHANGESPROCESSED};

		Map<String,BSPAttributes> bspMap = new Map<String,BSPAttributes>();

		for( HierarchyItem item: hierarchyValues){

			if(bspMap.get(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name) == null)
				bspMap.put(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name,new BSPAttributes(item.acc));
			else
				bspMap.get(item.acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name).addCount(item.acc);

			if(isConversionProcess && invalidAgencyStatus.contains(item.acc.Status__c)){
				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'You have selected locations that have change or suspension processes in progress. Please finalize the process and then proceed with the multicountry conversion'));
				return false;
			}
		}

		if(bspMap.values().size() < 2){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There should be at least 2 BSPs involved in the hierarchy.'));
			return false;
		}
        
		for(BSPAttributes bspAtt: bspMap.values()){

			if(isConversionProcess){
				if(!bspAtt.rfIsAlignInBSP){
					ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please align the Remittance Frequencies in the same BSP and then proceed with the multicountry conversion'));
					toReturn = false;
				}

				if(bspAtt.numberOfHE > 0 && bspAtt.isGE){
					ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'There cannot be an HE account in the same BSP of the GE account.'));
					toReturn = false;
				}
			}
					
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
			
		Set<String> agencyStatusToBeAlone = new Set<String>{AMS_Utils.ACC_S0_TERMINATED, AMS_Utils.ACC_S4_LISTED, AMS_Utils.ACC_S3_NOTINOPERATION, AMS_Utils.ACC_S1_NOTACCREDITED, ''};

		public Integer numberOfHE;
		public Integer numberOfAE;
		public String remittanceFrequency;
		public Boolean rfIsAlignInBSP;
		public Boolean isGE;

		public BSPAttributes(Account a){

			numberOfHE = 0;
			numberOfAE = 0;
			rfIsAlignInBSP = true;
			remittanceFrequency = a.Remittance_Frequency__c;
			isGE = false;

			if(a.Location_Type__c == AMS_Utils.HE)
				this.numberOfHE = 1;
			if(a.Location_Type__c == AMS_Utils.AE)
				this.numberOfAE = 1;
			if(a.Location_Type__c == AMS_Utils.GE)
				this.isGE = true;
		}

		public void addCount(Account a){
			if(this.remittanceFrequency != a.Remittance_Frequency__c)
				rfIsAlignInBSP = false;
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