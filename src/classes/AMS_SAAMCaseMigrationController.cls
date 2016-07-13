public class AMS_SAAMCaseMigrationController {

	private String SPECIFIC_CASES = 'Specific Cases';
	private String ALL_CASES = 'All SAAM Cases';
	private String ALL_FROM_PORTAL = 'All SAAM Cases from Portal';
	private String ALL_NOT_FROM_PORTAL = 'All SAAM Cases not from Portal';

	private final Integer PAGE_SIZE = 100; //max size: 1000
	private final Id SAAMCaseRecType = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SAAM').getRecordTypeId();

	public String caseNumbers	{ get; set; }
	public String searchOption	{ get; set; }
	public Boolean selectAll	{ get; set; }

	private Map<String, String> pageQueriesOption {
		get {
			return new Map<String, String> {
				'Specific Cases' => 'SPECIFIC_CASES',
				'All SAAM Cases' => 'ALL_CASES',
				'All SAAM Cases from Portal' => 'ALL_FROM_PORTAL',
				'All SAAM Cases not from Portal' => 'ALL_NOT_FROM_PORTAL'
			};
		}
		set;
	}

	private Map<String, String> pageQueries {
		get {
			if(pageQueries == null){
				pageQueries = new Map<String, String> {
					'SPECIFIC_CASES_QUERY' => 'SELECT Id, CaseNumber ' + caseFieldsStr + ' FROM CASE WHERE OSCAR__c = \'\' and CaseNumber In :caseNumberList and RecordTypeId = :SAAMCaseRecType and isCLosed = false',

					'ALL_FROM_PORTAL_QUERY' => 'SELECT Id, CaseNumber ' + caseFieldsStr + ' FROM CASE WHERE Id IN ( SELECT SAAM_Case__c from AMS_Pax_Accreditation_Form__c where SAAM_Case__r.RecordTypeId = :SAAMCaseRecType AND SAAM_Case__r.isCLosed = false and SAAM_Case__r.OSCAR__c = \'\' )',
				
					'ALL_NOT_FROM_PORTAL_QUERY' => 'SELECT Id, CaseNumber' +  caseFieldsStr + ' FROM CASE WHERE OSCAR__c = \'\' and RecordTypeId = :SAAMCaseRecType and isCLosed = false and Id not in ( SELECT SAAM_Case__c from AMS_Pax_Accreditation_Form__c where SAAM_Case__r.RecordTypeId = :SAAMCaseRecType AND SAAM_Case__r.isCLosed = false and SAAM_Case__r.OSCAR__c = \'\' )'
				};

				System.debug(loggingLevel.INFO, '____ [cls AMS_SAAMCaseMigrationController - pageQueries] pageQueries - ' + pageQueries);
			}
			return pageQueries;
		}
		set;
	}

	private List<String> caseNumberList{
		get{
			return caseNumbers.split('\\s*[,\\n\\r]\\s*');
		}
	}

	private List<Schema.SObjectField> caseFields{
		get{
			return new List<Schema.SObjectField>{
				Case.OwnerId,
				Case.Status,
				Case.RecordType__c,
				Case.Reason1__c,
				Case.AccountId
			};
		}
	}

	private String caseFieldsStr{
		get{
			caseFieldsStr = '';			
			for(String field : caseFieldNames) caseFieldsStr += ', '+field;
			return caseFieldsStr;
		}
		set;
	}


	//************************************
	//********** contructor **************
	//************************************

	public AMS_SAAMCaseMigrationController() { }


	//************************************
	//******** public getters ************
	//************************************


	public List<List<AMS_MigrationToolHelper.CaseContainer>> saamCases{
		get{
			if(saamCases == null) saamCases = new List<List<AMS_MigrationToolHelper.CaseContainer>>();
			return saamCases;
		}
		set;
	}

	public List<String> getEmptyList(){
		return new List<String>{ 'No records found'};
	}

	public List<SelectOption> searchOptions {
		get{
			if(searchOptions == null){
				searchOptions = new List<SelectOption>{
					new SelectOption(ALL_CASES, ALL_CASES),
					new SelectOption(ALL_FROM_PORTAL, ALL_FROM_PORTAL),
					new SelectOption(ALL_NOT_FROM_PORTAL, ALL_NOT_FROM_PORTAL),
					new SelectOption(SPECIFIC_CASES, SPECIFIC_CASES)
				};
			}
			return searchOptions;
		}
		set;
	}

	public List<String> caseFieldNames {
		get{
			if(caseFieldNames == null){
				caseFieldNames = new List<String>();
				for(Schema.SObjectField field : caseFields) caseFieldNames.add(field.getDescribe().getName());
			}
			return caseFieldNames;
		}
		set;
	}

	public Integer pageNumber{
		get{
			if(pageNumber == null) pageNumber = 1;
			return pageNumber;
		}
		set;
	}

	public Boolean searched{
		get{
			if(searched == null) searched = false;
			return searched;
		}
		set;
	}

	public Boolean processing{
		get{
			if(processing == null) processing = false;
			return processing;
		}
		set;
	}

	public Boolean showTextArea{
		get{
			return searchOption == SPECIFIC_CASES;
		}
		set;
	}

	public List<AMS_MigrationToolHelper.CaseContainer> casesOnPage {
		get{
			return saamCases[pageNumber-1];
		}
		set;
	}


	//************************************
	//*********** actions ****************
	//************************************

	public PageReference cancel() {
		return new PageReference(ApexPages.currentPage().getParameters().get('retURL'));
	}

	public void doSelectAll() {
		for(AMS_MigrationToolHelper.CaseContainer cc : casesOnPage) if(!cc.migrated) cc.selected = selectAll;
	}

	public void search() {

		if(!(searchOption == SPECIFIC_CASES || searchOption == ALL_FROM_PORTAL || searchOption == ALL_NOT_FROM_PORTAL || searchOption == ALL_CASES)){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Not a valid option, please choose a valid option.'));
			return;
		}

		saamCases = new List<List<AMS_MigrationToolHelper.CaseContainer>>();
		List<AMS_MigrationToolHelper.CaseContainer> cases = new List<AMS_MigrationToolHelper.CaseContainer>();

		if(searchOption == SPECIFIC_CASES || searchOption == ALL_FROM_PORTAL || searchOption == ALL_NOT_FROM_PORTAL){

			System.debug('Search option is:' + pageQueriesOption.get(searchOption) + '_QUERY');

			for(Case c : Database.query(pageQueries.get(pageQueriesOption.get(searchOption) + '_QUERY'))){

				cases.add(new AMS_MigrationToolHelper.CaseContainer(c,searchOption == ALL_FROM_PORTAL));
			}
		}

		if(searchOption == ALL_CASES){

			for(Case c : Database.query(pageQueries.get('ALL_FROM_PORTAL' + '_QUERY'))){

				cases.add(new AMS_MigrationToolHelper.CaseContainer(c,true));
			}

			for(Case c : Database.query(pageQueries.get('ALL_NOT_FROM_PORTAL' + '_QUERY'))){

				cases.add(new AMS_MigrationToolHelper.CaseContainer(c,false));
			}
		}

		List<AMS_MigrationToolHelper.CaseContainer> page = new List<AMS_MigrationToolHelper.CaseContainer>();
		for(AMS_MigrationToolHelper.CaseContainer container : cases){

			page.add(container);

			if(page.size() == PAGE_SIZE){
				saamCases.add(new List<AMS_MigrationToolHelper.CaseContainer>(page));
				page.clear();
			}
		}
		if(!page.isEmpty()) saamCases.add(page);

		searched = true;
	}

	public void first() {
		pageNumber = 1;
	}

	public void previous() {
		pageNumber = pageNumber - 1; 
	}

	public void next() {
		pageNumber = pageNumber + 1; 
	}

	public void last() {
		pageNumber = saamCases.size(); 
	}

	public void convert() {
		List<AMS_MigrationToolHelper.CaseContainer> caseContainers = new List<AMS_MigrationToolHelper.CaseContainer>();

		for(List<AMS_MigrationToolHelper.CaseContainer> page : saamCases){
			for(AMS_MigrationToolHelper.CaseContainer container : page){
				if(container.selected){
					processing = true;
					if(AMS_MigrationToolHelper.alternate) container.fromPortal = true;
				}
			}
		}

		if(!processing) ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, 'No case selected '));	
	}

	public void migrateCases() {
		for(List<AMS_MigrationToolHelper.CaseContainer> page : saamCases){
			for(AMS_MigrationToolHelper.CaseContainer container : page){
				if(container.selected && container.processing){
					return;
				}else if(container.selected && !container.migrated){

					try{
						container.processing = true;
						container = AMS_MigrationToolHelper.migratecases(container);
						
					}catch(Exception e){
						ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, e.getMessage()));		
					}

					return;	
				}
			}
		}
		processing = false;
	}
}