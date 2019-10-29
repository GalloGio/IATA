/*
 * This class is the controller for the AirlineSuspensionChildCases VF page. 
 */
 
public with sharing class AirlineSuspensionChildCasesController {
	public Id caseId {public get; private set;}
	public String strSortField {get; set;}
	public String strPreviousSortField {get; set;}
	public Boolean isSortASC {get; set;}
	public List<ChildCaseWrapper> caseList {
		get {
			List<ChildCaseWrapper> tmpCaseList = new List<ChildCaseWrapper>();
        	
        	String query = 'SELECT Id, CaseNumber, Subject, Status, Region__c, BSPCountry__c, CaseArea__c, Owner.Name, ' +
					'(SELECT Id, ParentId, CommentBody FROM CaseComments ORDER BY CreatedDate DESC LIMIT 1) ' +   
					'FROM Case ' +  
					'WHERE ParentId =\'' + caseId + '\' ' + 
					'ORDER BY ' + strSortField + ' ' + (isSortASC ? 'ASC' : 'DESC');

        	
        	List<Case> lstChildSuspensionCases = (List<Case>)Database.query(query);
        	
        	for (Case c : lstChildSuspensionCases) {
        		ChildCaseWrapper ccw = new ChildCaseWrapper();
        		ccw.caseRecord = c;
        		
        		for(CaseComment comm : c.CaseComments) {
			        ccw.LastComment = comm.CommentBody.left(100) + (comm.CommentBody.length() > 100 ? '(...)' : '');
			    }
			    
			    tmpCaseList.add(ccw);
        	}
			    
		    return tmpCaseList;
		} set;}
	
    public AirlineSuspensionChildCasesController (ApexPages.StandardController controller) {
    	if (controller.getRecord().Id != null ) {
        	caseId = controller.getRecord().Id;
        	
        	caseList = new List<ChildCaseWrapper>();
        	
        	strSortField = 'CaseNumber';
        	strPreviousSortField = 'CaseNumber';
        	isSortASC = true;
        	
    	} else {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid Case'));
    	}
    }
    
    public void SortTable() {
    	// Check to see if the same header was clicked twice in a row, which means the user want to sort in the opposite order
    	if (strSortField == strPreviousSortField) {	isSortASC = !isSortASC; } 
        else {
    		// if not, just take note of the new "previous field"
    		strPreviousSortField = strSortField;
    		isSortASC = true;
    	}
    	
    }
    
    public class ChildCaseWrapper {
    	public Id caseId {get; set;}
    	public Case caseRecord {get; set;}
    	public String LastComment {get; set;}
    }
}