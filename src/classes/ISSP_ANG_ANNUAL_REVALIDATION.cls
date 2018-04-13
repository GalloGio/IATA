public with sharing class ISSP_ANG_ANNUAL_REVALIDATION {
	public String communityName { get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public Boolean isStep1 {get; set;}
	public Boolean isStep2 {get; set;}

	public ISSP_ANG_ANNUAL_REVALIDATION() {
		this.isStep1 = true;
		this.isStep1 = false;
	}

   	public PageReference goToStep1() {
		   /*
		system.debug('agencyCodesConcerned ' + newForm.Scope_of_Change__c);
		if(newForm.Scope_of_Change__c == 'HO - All Branches'){
			newForm.Agency_Codes_Concerned__c = null;
			agencyCodesConcerned.clear();
			update newform;
		}

        return new PageReference('/ISSP_ANG_VoluntaryRelinquishment?caseId=' + newCase.Id + '&step=1' + commParam);
		*/
		return null;
    }

	public PageReference save() {

		return null;
	}
}