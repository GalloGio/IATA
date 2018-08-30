public without sharing class ISSP_ICCS_CasesController extends ISSP_ICCS_ComponentController{

	// Indicates if only the user's cases should be displayed
	public Boolean userCasesOnly {get;set;}

	// Indicates if only the opened cases should be displayed
	public Boolean openedCasesOnly {get;set;}
	
	public Boolean isCasesTableExpanded {get;set;}
	
	// List of cases to be displayed
	public List<Case> cases {
        get{
        	List<Case> cases = new List<Case>();
        	
        	Integer i = 0;
        	
        	for(Case cse : [
				        	select Id,
				                CaseNumber,
				                Contact.Name,
				                Contact.Id,
				                Status,
				                Subject,
				                CreatedDate
				            from Case 
				            where Origin = 'Portal'
				                and AccountId =: pageController.topAccount.Id
				                and RecordTypeId in : ISSP_ICCS_Utils.CASE_RECORD_TYPES
				            order by CreatedDate desc
						]){
				if((!openedCasesOnly || (cse.Status != 'Closed' && cse.Status != 'Abandoned'))  && (!userCasesOnly || (pageController.portalUserContact.Id == cse.Contact.Id))){
					cases.add(cse);
					i++;
					if(!isCasesTableExpanded && i == ISSP_ICCS_Utils.COLLAPSED_TABLE_ROWS){
						break;
					}
				}
			}
			return cases;
        }
	}
    
	// Size of the cases list
	public Integer casesSize {get{ return cases.size(); }}
	
	
	/* CONSTRUCTOR */
	
	public ISSP_ICCS_CasesController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.CASES;
	}

	// Called when the page is accessed through page controller navigation methods
	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		System.debug('ISSP_ICCS_CasesController.resetController(ISSP_ICCS_ServiceController pageController) : increment ' + ++ISSP_ICCS_ServiceController.increment);

		userCasesOnly = userCasesOnly == null ? false : userCasesOnly;
		openedCasesOnly = openedCasesOnly == null ? true : openedCasesOnly;
		isCasesTableExpanded = isCasesTableExpanded == null ? false : isCasesTableExpanded;
		
		return true;
	}
	
	// Called when the page is left through page controller navigation methods
	public override void cleanController(){
		System.debug('ISSP_ICCS_CasesController.cleanController() : increment ' + ++ISSP_ICCS_ServiceController.increment);
	}
	
	public void expandCollapseCasesTable(){
		isCasesTableExpanded = !isCasesTableExpanded;
	}
}