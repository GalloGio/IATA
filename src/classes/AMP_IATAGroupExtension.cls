public with sharing class AMP_IATAGroupExtension {


	public LocalGovernance__c lg;
	public List<LocalGovernance__c> lsParents;

	public Id recordId {get;set;}

	public AMP_IATAGroupExtension(ApexPages.StandardController stdController) {
		lg = (LocalGovernance__c)stdController.getRecord();
		recordId = lg.Id;
		String reportingTo = ApexPages.currentPage().getParameters().get('ReportingTo');
		if(reportingTo != null ) lg.Reporting_to__c = reportingTo;
	}

	public PageReference MySave(){
		// Boolean errorFound = false;
		// check that one but only of of Region/Division is set
		// if( ((lg.Division__c == null || lg.Division__c == 'N/A') && (lg.Region__c == null || lg.Region__c == 'N/A')) ||
		// 		((lg.Division__c != null && lg.Division__c != 'N/A') && (lg.Region__c != null && lg.Region__c != 'N/A'))) {
		// 	lg.addError('Please select either Division or Region');
		// 	// ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: '));
		// 	// system.debug('----------------  Error saving local group: -');
		// 	errorFound = true;
		// }
		// if(	(lg.Open_to_non_IATA_Airlines_and_Others__c == 'Yes' && lg.Open_to__c == null) ) {
		// 	lg.addError('Please select Open To');
		// 	errorFound = true;
		// }
		// if(	(lg.Restricted_of_Participants__c == 'Yes' && lg.Maximum_Number_of_Participiants__c == null) ) {
		// 	lg.addError('Please specify the maximum number of participants');
		// 	errorFound = true;
		// }
		// if(errorFound) {
		// 	return null;
		// }

		database.UpsertResult sr = database.upsert(lg,false);
		if(!sr.isSuccess()){
			ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, 'Error: '+sr.getErrors()[0].getMessage()));
			system.debug('----------------  Error saving group: '+sr.getErrors()[0].getMessage()+' --------------------');
			return null;
		}
		return new PageReference('/'+sr.getId());

	}

}
