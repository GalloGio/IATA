public class AMS_OSCAR_ProcessViewerController {

	public class HideOptionStepWrapper {
		public String stepName;
		public String process;
		public String optToHide;

		public HideOptionStepWrapper(String stepName, String process, String optToHide){
			this.stepName = stepName;
			this.process = process;
			this.optToHide = optToHide;
		}
	}

	private static Map<String, List<HideOptionStepWrapper>> hideOptsByStepMap = new Map<String, List<HideOptionStepWrapper>>{
		'STEP45__c' =>
			new List<HideOptionStepWrapper>{
				new HideOptionStepWrapper('STEP45__c', AMS_Utils.NGCONVERSIONTOMULTICOUNTRY, AMS_Utils.NOT_APPLICABLE),
				new HideOptionStepWrapper('STEP45__c', AMS_Utils.NEWGESTANDARD, AMS_Utils.NOT_APPLICABLE)
			}
	};

	private static final String CLASS_BLACK = '';
	private static final String CLASS_RED = 'red';
	private static final String CLASS_GREEN = 'green';
	private static final String CLASS_BLUE = 'blue';

	public AMS_OSCAR__c oscar {
		get{
			if(this.oscar == null)
				return new AMS_OSCAR__c();
			else return this.oscar;
		}
		set;}

	public Case oscarCase{get;set;}

	public Id oscarId{get;set;}

	public Id caseId{get;set;}

	public AMS_OSCAR_JSON accreditationProcesses {get;set;}
	public Map<String, AMS_OSCAR_JSON.Process> process {get;set;}

	public Map<String,String> flowColors {get;set;}
	public Map<String,Boolean> collapsibleMap {get;set;}
	public Map<String,String> statusIcons {get;set;}
	public Map<String,String> statusLabel {get;set;}
	public Map<String,Boolean> ddBlock {get;set;}
	public Map<String,StepFieldsDataWrapper> stepFieldsData {get;set;}

	public static Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('AMS_OSCAR__c').getDescribe().fields.getMap();

	private static Set<String> analystProfiles = new Set<String>{'FDS Hub Analyst ARM'};

	public String NGCONVERSIONMCTOSTANDARD {
		get { return AMS_Utils.NGCONVERSIONMCTOST; }
	}

	public String NGCONVERSIONTOMULTICOUNTRY {
		get {return AMS_Utils.NGCONVERSIONTOMULTICOUNTRY; }
	}

	public String CONFIRM_MC_CONVERSION_MSG {
		get { return 'By clicking OK you confirm that you want to proceed with changing the accreditation type of the entire hierarchy to GoStandard.'; }
	}

	public boolean isParentOscar {
		get {
			return this.oscar.Parent_OSCAR__c == null;
		}
	}
	
	public String cannotProceedConversionToStandardMessage {
		get {
			if(this.oscar.Account__r.Location_Type__c == AMS_Utils.GE && 
				(String.isNotBlank(this.oscar.Account__r.Bulletin_Headquarter__c) ||
				this.oscar.Account__r.Identify_as_Multicountry_Key_Hierarchy__c))
			{
				return 'Please uncheck the "Identify as key multicountry hierarchy" and delete the "eBulletin Multicountry Headquarter" fields on the GE account in order to proceed';	
			}
			return null;
		}
	}

	public Boolean showRequiredOverlay{
		get{
			if(this.oscar.Account__c == null)
				return false;

			if(this.oscar.AMS_Online_Accreditation__c == null)
				return false;

			// NG Processes specific conditions
			If(AMS_Utils.oscarNewGenProcesses.contains(oscar.Process__c) && oscar.Process__c != AMS_Utils.NEWHELITE && oscar.Process__c != AMS_Utils.NEWHESTANDARD && oscar.Process__c != AMS_Utils.NEWGESTANDARD) {
				return (
					oscar != null
					&& ( oscar.AMS_Online_Accreditation__r.Remittance_frequency__c == null
						//NEWGEN-4850
						&& oscar.Process__c != AMS_Utils.MCAE

						|| !oscar.AMS_Online_Accreditation__r.Ready_for_Accreditation__c )
				);
			}
			return (
				oscar != null
				&& oscar.Process__c != AMS_Utils.VOLRELINQUISH
				&& oscar.Process__c != AMS_Utils.VOLRELINQUISH_CA
				&& oscar.Process__c != AMS_Utils.CERTIFICATION
				&& oscar.Process__c != AMS_Utils.CERTIFICATE
				&& (!(oscar.Process__c == AMS_Utils.BANKACCCHANGES && oscar.Account__r.ANG_IsNewGenAgency__c))
				&& oscar.Process__c != AMS_Utils.IEPBANKACCOUNTSETUP
				&& !oscar.AMS_Online_Accreditation__r.Ready_for_Accreditation__c
			) || isAMSCheckRemittance; //AMSU-125
		}
	}

	public Boolean isGEwithNoHierarchy{
		get{
			// NG Processes specific conditions
			If(oscar.Process__c <> AMS_Utils.NGGE){
				return false;
				}

			return oscarCase.Origin <> 'Portal' && oscar.STEP45__C == 'Not Started' && !oscar.ANG_Hierarchy_Created__c;
		}
	}

	//AMSU-125
	public Boolean isAMSCheckRemittance {
		get {
			return oscar != null && checkAMSRemittance(oscar);
		}
		set;
	}

	public Boolean checkAMSRemittance(AMS_OSCAR__c oscar) {
		List<AMS_Settlement_System__c> operations =  ANG_AgencyChangesHelper.fetchOperationConfiguration(RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c','BSP'),
		 oscar.AMS_Online_Accreditation__r.Branch_Office_Country__c, oscar.AMS_Online_Accreditation__r.Location_Class__c);
		Set<String> locationsClass = new Set<String> {'P', 'D'};

		if(!String.isBlank(oscar.Process__c) && locationsClass.contains(oscar.AMS_Online_Accreditation__r.Location_Class__c) && (oscar.Process__c == AMS_Utils.AGENCYCHANGES  && oscar.Type_of_change__c == AMS_Utils.VFMR) && !operations.isEmpty()) {
			return String.isBlank(oscar.AMS_Online_Accreditation__r.Remittance_frequency__c);
		}
		return false;
	}

	public Boolean isNotNewGenProcess{
		get{
			return (
				oscar != null
				&& !AMS_Utils.oscarNewGenProcesses.contains(oscar.Process__c)
		&& !(oscar.Process__c == AMS_Utils.BANKACCCHANGES && oscar.AMS_Online_Accreditation__c == null)
				//&& oscar.Process__c != AMS_Utils.NEWHELITE
				&& !oscar.AMS_Online_Accreditation__r.Ready_for_Accreditation__c
			);
		}
	}

	public Boolean getIsGDIWithNoParentCase(){

		// NG Processes specific conditions
		if(oscar.Process__c <> AMS_Utils.NGGDI) return false;
		case c = [SELECT parentid FROM CASE WHERE OSCAR__c = :oscar.id];
		return (c.parentid == null);

	}

	public Boolean isNewGenHEProcess{
		get{
			return (
				oscar != null
				&& (oscar.Process__c == AMS_Utils.NEWHELITE || oscar.Process__c == AMS_Utils.NEWHESTANDARD || oscar.Process__c == AMS_Utils.NEWGESTANDARD || oscar.Process__c == AMS_Utils.MCAE)
			);
		}
	}

	public boolean isNewGEConversion{
		get{
			return (oscar != null && oscar.Process__c == AMS_Utils.NGCONVERSIONTOMULTICOUNTRY);
		}
	}

	private Boolean dueDiligenceBlocked {
		get{
			return (
				oscar != null
				&& ((oscar.STEP17__c == AMS_Utils.IN_PROGRESS && oscar.Process__c != AMS_Utils.new_TIDS) || (oscar.Process__c == AMS_Utils.IEPBANKACCOUNTSETUP && (oscar.STEP17__c <> AMS_Utils.PASSED && oscar.STEP17__c <> AMS_Utils.FAILED)))
			);
		}
	}

	public boolean isNewGE{
		get{
			return (oscar != null && oscar.Process__c == AMS_Utils.NEWGESTANDARD);
		}
	}

	private Set<String> alwaysOnSteps{
		get{
			return new Set<String>{
				'STEP6__c',
				'STEP8__c',
				'STEP9__c',
				'STEP10__c',
				'STEP17__c',
				'STEP26__c',
				'STEP27__c',
				'STEP28__c',
				'STEP29__c'
			};
		}
	}

	/*** AMSU-113 Start ***/
	public Set<String> processToRemoveFields {
		get{
			return new Set<String> {AMS_Utils.new_HO, AMS_Utils.new_BR};
		}
		set;
	}

	public Boolean isToRemoveFieldsUI {
		get {
			return oscar != null && oscar.Location_Class__c != AMS_Utils.LC_PASSENGER && processToRemoveFields.contains(oscar.Process__c);
		}
		set;
	}

	public Boolean isPCICompliant {
		get {
			return oscar.Process__c == AMS_Utils.PCI_COMPLIANT;
		}
		set;
	}
	/*** AMSU-113 End ***/

	public Boolean isAnalystProfile{
		get{
			List<Profile> analystProfileLst = [select id from profile where Name IN :analystProfiles];
			Set<Id> analystProfileIds = new Set<Id>();
			for(Profile p :analystProfileLst)
				analystProfileIds.add(p.Id);

			return analystProfileIds.contains(UserInfo.getProfileId());
		}
	}

	private Boolean isStepBlocked(String stepApiName){
		if(oscar != null && oscar.STEP45__c != AMS_Utils.PASSED && (oscar.Process__c == AMS_Utils.NEWGESTANDARD || oscar.Process__c == AMS_Utils.NGCONVERSIONTOMULTICOUNTRY) && stepApiName != 'STEP45__c') return true;
		return alwaysOnSteps.contains(stepApiName) ? false : dueDiligenceBlocked;
	}

	public String getEffectiveDate(){
		return oscar.Change_effective_as_of__c.format();
	}
	public boolean getIsAgencyChange(){
		return oscar.RecordType.DeveloperName == 'CHANGE';
	}

	public Boolean isValidationCompleted {
		get{
			return (
				oscar != null
				&& (oscar.STEP15__c == AMS_Utils.PASSED || oscar.STEP15__c == AMS_Utils.FAILED
				||oscar.STEP25__c == AMS_Utils.PASSED || oscar.STEP25__c == AMS_Utils.FAILED)
			);
		}
	}

	public boolean isNewgenRT{
		get{
			return (oscar.RecordTypeID == AMS_Utils.RECTYPE_NEWHE && oscar.Process__c == AMS_Utils.NEWHESTANDARD) || (oscar.RecordTypeID == AMS_Utils.RECTYPE_NEWGE && oscar.Process__c == AMS_Utils.NEWGESTANDARD);
		}
	}

	public Boolean blockFAoptOut{
		get{
			if(oscar.Process__c == AMS_Utils.NEWHESTANDARD){ return true; }
			return (oscar.ANG_Type_Of_Change__c != null && oscar.ANG_Type_Of_Change__c.contains(AMS_Utils.ANG_ACCREDITATION_TYPE));
		}
	}

	public Boolean hideFAoptOut{
		get{
			if(oscar.Process__c == AMS_Utils.NEWHESTANDARD){ return false; }
			return !ANG_AgencyChangesHelper.containsChange(new List<String>(AMS_Utils.ANG_OSCAR_MAJOR_CHANGES_PROCESSES), oscar.ANG_Type_Of_Change__c);
		}
	}

	public String selectedTab{get;set;}

	public AMS_OSCAR_ProcessViewerController() {



		Id objectId = ApexPages.currentPage().getParameters().get('id');

		if(objectId == null)
			return;

		if(isObjectCase(objectId)){

			this.oscarCase = fetchCaseFields(objectId,false);
			this.caseId = this.oscarCase.Id;

			if(this.oscarCase.OSCAR__c != null){

				this.oscar = fetchOscarFields(this.oscarCase.OSCAR__c);
				this.oscarId = this.oscar.Id;

				loadJsonFile();
			}


		}else{

			this.oscar = fetchOscarFields(objectId);
			this.oscarId = this.oscar.Id;

			loadJsonFile();

			this.oscarCase = fetchCaseFields(objectId,true);
			this.caseId = this.oscarCase.Id;

		}

	selectedTab = 'tab1';

	}

	public String convertToString(Blob value){
		return EncodingUtil.urlDecode(value.toString(), 'UTF-8');
	}

	/**
	 *  Get the
	 */
	public void getDisplayFieldsPickValues(AMS_OSCAR_JSON.Process process){

		for(AMS_OSCAR_JSON.Flow flow: process.flows){
			for(AMS_OSCAR_JSON.Step step: flow.steps){
				for(String stepFieldName: step.displayFields){
					//check if the field is already in the map
					if(stepFieldsData.get(stepFieldName) == null){

						Schema.DescribeFieldResult fr = fieldMap.get(stepFieldName).getDescribe();
						List<SelectOption> pickValues;
						String fieldLabel = fr.getLabel();

						if(stepFieldName.startsWithIgnoreCase('STEP'))
							fieldLabel = 'Stage status';

						Schema.DisplayType fieldType = fr.getType();
						//remove "--None--" from picklists
						if(fieldType == Schema.DisplayType.PICKLIST)
							pickValues = getPicklistValues(fr);

						StepFieldsDataWrapper wrapper = new StepFieldsDataWrapper(stepFieldName, fieldLabel, pickValues);

						stepFieldsData.put(stepFieldName, wrapper);
					}
				}

				step.label = 'AMS_OSCAR_' + step.name;
			}
		}

	}

	/**
	 *  Get the status of all the steps in the Process
	 */
	public void getStatus(AMS_OSCAR_JSON.Process process){
		Boolean firstExpanded = false;

		for(AMS_OSCAR_JSON.Flow flow: process.flows) {
			flowColors.put(process.name + flow.name, CLASS_GREEN);
			collapsibleMap.put(process.name + flow.name, true);

			for(AMS_OSCAR_JSON.Step step: flow.steps){

				String stepApiName = step.name + '__c';

				system.debug('MAC name ' + stepApiName);
				String stepValue = (String)this.oscar.get(stepApiName);
				system.debug('MAC value ' + stepValue);
				String iconFileName = (stepValue+'.png').replace(' ', '_').toLowerCase();

				statusIcons.put(step.name,iconFileName);
				statusLabel.put(step.name, stepValue);
				ddBlock.put(flow.name, isStepBlocked(stepApiName));

				if (stepValue == AMS_Utils.FAILED) {
					flowColors.put(process.name + flow.name, CLASS_RED);
				} else if (stepValue == AMS_Utils.IN_PROGRESS && flowColors.get(process.name + flow.name) != CLASS_RED) {
					flowColors.put(process.name + flow.name, CLASS_BLUE);
				} else if (stepValue == 'Not Started' && flowColors.get(process.name + flow.name) != CLASS_RED) {
					flowColors.put(process.name + flow.name, CLASS_BLACK);
				}

				if (!firstExpanded && (String.isBlank(stepValue) || stepValue == 'Not Started' || stepValue == AMS_Utils.IN_PROGRESS)) {
					collapsibleMap.put(process.name + flow.name, false);
					firstExpanded = true;
				}

			}

		}
	}

	public List<SelectOption> getPicklistValues(Schema.DescribeFieldResult fr){

		Set<String> dependentPicklistValues = new  Set<String> ();

		if(fr.isDependentPicklist())
		{

			Map<String,List<String>> dependentPicklistMap = AMS_Utils.GetDependentOptions('AMS_OSCAR__c',fr.getController().getDescribe().getName(),fr.getName());
			if(!dependentPicklistMap.isEmpty())
				dependentPicklistValues.addAll(dependentPicklistMap.get(String.valueOf(oscar.Process__c)));
		}

		List<SelectOption> picklistValues = new List<SelectOption>();

		List<Schema.PicklistEntry> ple = fr.getPicklistValues();

		String fieldName = fr.getName();

		String currentPickValue = String.valueOf(oscar.get(fieldName));

		if(currentPickValue == null && (AMS_Utils.oscarNewGenProcesses.contains(oscar.Process__c) || oscar.Process__c == AMS_Utils.PCI_COMPLIANT))
			picklistValues.add(new SelectOption('', '--None--'));

		if(currentPickValue != null){
			picklistValues.add(new SelectOption(currentPickValue, currentPickValue));
		}

		Set<String> optsToHideSet = fetchOptsToHideByFieldName(fr.getName());

		for( Schema.PicklistEntry f : ple) {
			if(optsToHideSet.contains(f.getValue())){
				//Discard this picklist value
				continue;
			}
			//this is a workaround to make the current value of the field the default value of the picklist
			if(currentPickValue != f.getValue()
				&& (dependentPicklistValues.isEmpty() ||  dependentPicklistValues.contains(f.getValue()))
				){
			/* Commented as per NEWGEN-3301
			if(canBeDisplayed(fieldName,oscar.Process__c,f.getValue()))
				picklistValues.add(new SelectOption(f.getValue(), f.getLabel()));
			*/
				picklistValues.add(new SelectOption(f.getValue(), f.getLabel()));
			}
		}
		//NEWGEN-5707 - Add the 'empty'(--None--) value to the picklist
		if(fieldName == 'ANG_GFA_Change_Assessment__c' && currentPickValue != null) picklistValues.add(new SelectOption('', '--None--'));

		return picklistValues;
	}

	public class StepFieldsDataWrapper{
		public String fieldApiName{get;set;}
		public String fieldLabel{get;set;}
		public List<SelectOption> picklistValues{get;set;}

		public StepFieldsDataWrapper(String fieldApiName, String fieldLabel, List<SelectOption> picklistValues){
			this.fieldApiName = fieldApiName;
			this.fieldLabel = fieldLabel;
			this.picklistValues = picklistValues;
		}
	}

	private boolean isObjectCase(Id objectToFind){

		return AMS_Utils.findObjectNameFromRecordIdPrefix(objectToFind).equalsIgnoreCase('CASE');

	}

	private Case fetchCaseFields(ID objectId, Boolean isIdFromOscar){

		Case toReturn = null;

		List<Case> cases = new List<Case>();

		if(isIdFromOscar){

			ID oSCARCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

			cases =  [SELECT Id, OSCAR__c, Origin FROM Case WHERE OSCAR__c =: objectId AND RecordTypeID =: oSCARCaseRecordTypeID AND ParentId = null LIMIT 1 ];

		}
		else{

			cases = [SELECT Id, OSCAR__c, Origin FROM Case WHERE id = :objectId LIMIT 1];

		}

		if(!cases.isEmpty())
			return cases.get(0);

		 return toReturn;

	}

	public String getAllFieldQuery() {

		String fields = ' ';

		Map<String, Schema.SObjectField> fMap = Schema.sObjectType.AMS_OSCAR__c.fields.getMap();

		for(Schema.SObjectField field : fMap.values()){

			Schema.DescribeFieldResult fd = field.getDescribe();
			if(fd.isAccessible() || Test.isRunningTest()) fields += fd.getName() + ', ';
		}
		fields = fields.substring(0,fields.lastIndexOf(','));

		return 'SELECT ' + fields + ', AMS_Online_Accreditation__r.Ready_for_Accreditation__c , RecordType.Name, RecordType.DeveloperName, Account__r.Name, Account__r.Remittance_frequency__c, Account__r.IATA_ISO_Country__r.AMS_Settlement_System__r.Remittance_Frequency_per_State__c, AMS_Online_Accreditation__r.ANG_IsNewGenAgency__c, AMS_Online_Accreditation__r.Remittance_Frequency__c, Account__r.ANG_IsNewGenAgency__c, AMS_Online_Accreditation__r.Branch_Office_Country__c, AMS_Online_Accreditation__r.Location_Class__c, Account__r.Region_formula__c, Account__r.Location_Type__c, Account__r.Bulletin_Headquarter__c, Account__r.Identify_as_Multicountry_Key_Hierarchy__c FROM AMS_OSCAR__c where Id =: oscarId LIMIT 1';
	}

	private AMS_OSCAR__c fetchOscarFields(ID oscarId){

		AMS_OSCAR__c toReturn = null;

		List<AMS_OSCAR__c> oscars = new List<AMS_OSCAR__c>();

		oscars = Database.query(getAllFieldQuery());

		if(!oscars.isEmpty())
			return oscars.get(0);

		 return toReturn;

	}


	private void loadJsonFile(){


		/*
		 *  LOAD JSON TO OBJECT
		 */
		StaticResource jsonFile = [select Id , Name , Body from StaticResource where Name = 'JSON_OSCAR_Process'];

		String JSONContent = convertToString(jsonFile.Body);

		JSONParser parser = JSON.createParser(JSONContent);

		parser.nextToken();
		parser.nextToken();
		parser.nextToken();

		accreditationProcesses = (AMS_OSCAR_JSON)parser.readValueAs(AMS_OSCAR_JSON.class);
		List<AMS_OSCAR_JSON.Process> pr = accreditationProcesses.processes;

		process = new Map<String, AMS_OSCAR_JSON.Process>();

		stepFieldsData = new Map<String,StepFieldsDataWrapper>();

		flowColors = new Map<String,String>();
		collapsibleMap = new Map<String,Boolean>();
		statusIcons = new Map<String,String>();
		statusLabel = new Map<String,String>();
		ddBlock = new Map<String,Boolean>();

		for(AMS_OSCAR_JSON.Process p: pr){
			process.put(p.Name, p);
			getStatus(p);
			getDisplayFieldsPickValues(p);
		}

	}

	private Set<String> fetchOptsToHideByFieldName(String fieldName){
		Set<String> optsToHideSet = new Set<String>();

		List<HideOptionStepWrapper> stepWrapperLst = hideOptsByStepMap.get(fieldName);

		if(stepWrapperLst != NULL){
			for(HideOptionStepWrapper hosw : stepWrapperLst){
				if(oscar.Process__c == hosw.process){
					optsToHideSet.add(hosw.optToHide);
				}
			}
		}

		return optsToHideSet;
	}

}
