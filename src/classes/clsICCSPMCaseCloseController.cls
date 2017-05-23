/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This class is the controller for the ICCSProductManagementCaseClose VF page. It handles the closing of cases with the FDS ICCS Product Management record type and sends 
 *      the email notification to the related contacts.
 *      
 */

public with sharing class clsICCSPMCaseCloseController {
	public Case pmCase {get; set;}
	public String strCaseComments {get; set;}
	public String status {get; set;}
	
	private List<String> lstCaseClosedStatuses = new List<String>{'Closed', 'Abandoned'};
	
	// Options for the Status picklist
	public List<SelectOption> getStatusItems() {
 	 	List<SelectOption> options = new List<SelectOption>();
 	 	options.add(new SelectOption('','--None--'));
 	 	options.add(new SelectOption('Closed','Closed'));
 	 	options.add(new SelectOption('Abandoned','Abandoned'));
 	 	return options;
  	}
	
	public clsICCSPMCaseCloseController(ApexPages.StandardController stdController) {
		if(!Test.isRunningTest()) {
			stdController.addFields(new List<String>{'ICCS_Case_Notification_Status__c', 'AccountId', 'ContactId', 'CaseArea__c', 'Status'});
		}
		
        pmCase = (Case)stdController.getRecord();
    }
    
    public PageReference SaveCase () {
    	String errorMessage = '';
    	Boolean errorsFound = false;
    	
    	if (strCaseComments == null || strCaseComments == '') {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please fill in the Internal Comments field.'));
    		errorsFound = true;
    	}
    	
    	if (status == null || status == '') {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Status.'));
    		errorsFound = true;
    	}
    	
    	if (! errorsFound)  {
    		
    		pmCase.Status = status;
    		
    		try {
    				
    			
    			CaseComment cc = new CaseComment(CommentBody = strCaseComments, ParentId = pmCase.Id);
    			insert cc;
                
                pmCase.ICCS_Case_Notification_Status__c = ' ';
                update pmCase;
    		} catch (Exception e) {
    			ApexPages.addMessages(e);
    			errorsFound = true;
    		}
    		//return new PageReference('/' + pmCase.Id);	
    	}
    	
    	if (errorsFound) {
    		return null;
    	} else {
    		return new PageReference('/apex/ICCSProductManagementCaseClose?id=' + pmCase.Id + '&sendNotif=1');
    	}
    }
    
    
    public PageReference SendNotif () {
    	String send = ApexPages.currentPage().getParameters().get('sendNotif');
    		
    		if (pmCase.Status == 'Closed' && send == '1') {
    			// Send the Notifications
    			
    			// Get the contact on the case, check if it is set to receive notifications
	            Contact con = [SELECT Id, Contact_on_Close_Case__c FROM Contact WHERE Id = :pmCase.ContactId];
	            Account a = [SELECT Id FROM Account WHERE Id = :pmCase.AccountId];
	            
	            if (con.Contact_on_Close_Case__c) {
	            	ApexPages.StandardController std = new ApexPages.StandardController(a);
	                cslICCSPdfPAGeneratorController pdfGen = new cslICCSPdfPAGeneratorController(std);
	                
	                if (pmCase.CaseArea__c == 'ICCS – Assign Product') {
	                    pdfGen.sendPDF('Notification_to_ICCS_Contact_PA',pmCase.ContactId, pmCase.Id);
	                    pmCase.ICCS_Case_Notification_Status__c = 'Notification sent';
	                } else if (pmCase.CaseArea__c == 'ICCS – Remove Product') {
	                    pdfGen.sendPDF('Notification_to_ICCS_Contact_PR',pmCase.ContactId, pmCase.Id);
	                    pmCase.ICCS_Case_Notification_Status__c = 'Notification sent';
	                } else if (pmCase.CaseArea__c == 'ICCS – Update Payment Instructions') {
	                    pdfGen.sendPDF('Notification_to_ICCS_Contact_PIU',pmCase.ContactId, pmCase.Id);
	                    pmCase.ICCS_Case_Notification_Status__c = 'Notification sent';
	                } else {
	                    pmCase.ICCS_Case_Notification_Status__c = 'Not applicable for Case Area';
	                }
	            } else {
	                pmCase.ICCS_Case_Notification_Status__c = 'Contact on Close Case unchecked';
	            }
	            
	            update pmCase;
	            
	            return new PageReference('/' + pmCase.Id);
	            
    		} else {
    			// Stay on the case close VF page 
    			
    			return null;
    		}
    		
    }
}