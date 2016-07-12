public class AMS_SAAMCaseMigrationController {

	private String SPECIFIC_CASES = 'Specific Cases';
	private String ALL_CASES = 'All SAAM Cases (from Portal)';
	private String PORTAL_CASES = 'All SAAM Cases (not from Portal)';
	private String NOTPORTAL_CASES = 'All SAAM Cases';
	private Integer PAGE_SIZE = 100; //max size: 1000
	private Id SAAMCaseRecType = Schema.Case.sObjectType.getDescribe().getRecordTypeInfosByName().get('SAAM').getRecordTypeId();
	
	public String caseNumbers	{ get; set; }
	public String searchOption	{ get; set; }
	public Boolean selectAll	{ get; set; }

	private List<String> caseNumberList{
		get{
			return caseNumbers.split('\\s*[,\\n\\r]\\s*');
		}
	}

	private List<Schema.SObjectField> caseFields{
		get{
			return new List<Schema.SObjectField>{
				Case.OwnerId,
				Case.Status
			};
		}
	}


	//************************************
	//********** contructor **************
	//************************************

	public AMS_SAAMCaseMigrationController() { }


	//************************************
	//*********** getters ****************
	//************************************


	public List<List<CaseContainer>> saamCases{
		get{
			if(saamCases == null) saamCases = new List<List<CaseContainer>>();
			return saamCases;
		}
		set;
	}

	public List<String> getEmptyList(){
		return new List<String>{ 'No records found'};
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

	public Boolean showTextArea{
		get{
			return searchOption == SPECIFIC_CASES;
		}
		set;
	}

	public List<SelectOption> searchOptions {
		get{
			if(searchOptions == null){
				searchOptions = new List<SelectOption>{
					new SelectOption(ALL_CASES, ALL_CASES),
					new SelectOption(PORTAL_CASES, PORTAL_CASES),
					new SelectOption(NOTPORTAL_CASES, NOTPORTAL_CASES),
					new SelectOption(SPECIFIC_CASES, SPECIFIC_CASES)
				};
			}
			return searchOptions;
		}
		set;
	}

	public List<CaseContainer> casesOnPage {
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
		for(CaseContainer cc : casesOnPage) cc.selected = selectAll;
	}

	public void search() {
		saamCases = new List<List<CaseContainer>>();

		String fields = '';
		for(String field : caseFieldNames) fields += ', '+field;

		String query = 'SELECT Id, CaseNumber' + fields + ' FROM CASE WHERE ';
		if(searchOption == SPECIFIC_CASES){
			if(String.isEmpty(caseNumbers)){

				ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please, inform case number'));
				return;
			}else{

				query += 'CaseNumber In :caseNumberList';
			}
		}else if (searchOption == ALL_CASES || searchOption == PORTAL_CASES || searchOption == NOTPORTAL_CASES) {
			query += 'RecordTypeId = :SAAMCaseRecType ';
			//query += 'Id != \'\' '; used for testing

			//if(searchOption == PORTAL_CASES) query += '<add_portal_filter> = true';
			//if(searchOption == NOTPORTAL_CASES) query += '<add_portal_filter> = false';
		}
		else{

			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Please, select type of search'));
			return;
		}

		List<CaseContainer> page = new List<CaseContainer>(); 
		for(Case c : Database.query(query)){
			page.add(new CaseContainer(c));

			if(page.size() == PAGE_SIZE){
				saamCases.add(new List<CaseContainer>(page));
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
		List<Case> cases = new List<Case>();

		for(List<CaseContainer> page : saamCases){
			for(CaseContainer container : page){
				if(container.selected){
					cases.add(container.c);
				}
			}
		}

		if(cases.isEmpty()){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'No case selected '));
			return;
		}

		System.debug(loggingLevel.Debug, '____ [cls AMS_SAAMCaseMigrationController - convert] cases - ' + cases);
		//TODO: call method
	}


	//************************************
	//*********** wrapper ****************
	//************************************

	public class CaseContainer{
		public Case c { get; set; }
		public Boolean selected { get; set; }

		public CaseContainer(Case c){
			this.c = c;
			this.selected = false;
		}
	}
}