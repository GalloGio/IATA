public with sharing class ISSP_ANG_ANNUAL_REVALIDATION {
	public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}
	public String step1GoToNumber {get; set;}
	public String stepNumber {get; set;}
	public Boolean isStep1 {get; set;}
	public Boolean isStep2 {get; set;}
	public Case newCase {get; set;}

	public ISSP_ANG_ANNUAL_REVALIDATION() {
		System.debug('alex constructor');

		newCase = [select id, IFAP_Country_ISO__c from case limit 1];

        isStep1 = false;
        isStep2 = false;
        stepNumber = '';

        if (ApexPages.currentPage().getParameters().containsKey('step'))
            stepNumber = ApexPages.currentPage().getParameters().get('step');


		System.debug('alex stepNumber : ' + stepNumber);

        if (stepNumber == '1' || stepNumber == '')
            isStep1 = true;

        system.debug('stepNumber ' + stepNumber);

        if(stepNumber == '2'){
        	//Id caseid  = ApexPages.currentPage().getParameters().get('caseId');
        	//newForm = ISSP_SELECTOR.fetchAMSProcessForm(caseid);
        	//fetchCase(caseid);
        	isStep2 = true;
        }

	}

    public PageReference goToStep1() {

		System.debug('alex goto step 1');



		/*
		system.debug('agencyCodesConcerned ' + newForm.Scope_of_Change__c);
		if(newForm.Scope_of_Change__c == 'HO - All Branches'){
			newForm.Agency_Codes_Concerned__c = null;
			agencyCodesConcerned.clear();
			update newform;
		}
		*/
        return new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + newCase.Id + '&step=1' + commParam);
    }

    public PageReference goToStep2() {

		System.debug('alex goto step 2');

		this.isStep1 = false;
		this.isStep2 = true;
        return new PageReference('/ISSP_ANG_ANNUAL_REVALIDATION?caseId=' + newCase.Id + '&step=2' + commParam);
    }

	public PageReference save() {

		System.debug('alex save');

		return goToStep2();
	}
}