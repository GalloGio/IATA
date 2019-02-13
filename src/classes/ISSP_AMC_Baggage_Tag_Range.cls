/*
    Class Name: ISSP_AMC_Airline_Designators
    Related Classes: 

    Copyright @Right IT Services

    Purpose: Controller Class for ISSP_AMC_Airline_Designators.page

    VERSION     AUTHOR              DATE            DETAIL/CHANGE REFERENCE
    1.0         João Ferreira       30-10-2018      INITIAL DEVELOPMENT
    2.0         Miguel              
*/
public without sharing class ISSP_AMC_Baggage_Tag_Range {

    public PageReference init(){
        if(participation.Case__c != null && participation.Case__r.Status != ISSP_AMC_Constants.AMC_CASE_STATUS_OPEN){
            PageReference pr = new PageReference('/ISSP_Case?caseId=' + participation.Case__c + '&mid=M1S2');
            pr.setRedirect(true);
            return pr;
        }
        return null;
    }
    
    /* GENERAL */
    public Participation_Online_Application__c participation {get;set;}
    public String displayLanguage { 
        get { 
                if(displayLanguage == null)
                    return UserInfo.getLanguage(); 
                else
                    return displayLanguage;
            } 
    }
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); } }

    public List <SelectOption> countryList {
        get { 
            
            return ISSP_AMC_DAO.countryList;
        }
    }
    public List <SelectOption> salutationList {
        get {
            if(salutationList == null){
                List <SelectOption> optionList = new List <SelectOption>();
            
                Schema.DescribeFieldResult fieldResult = Contact.Salutation.getDescribe();
                List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

                for( Schema.PicklistEntry f : ple){
                    optionList.add(new SelectOption( f.getValue(),f.getLabel()));
                }
                return optionList;
            }
            return salutationList;
        }
    }

    public Map <String, String> componentByOperation { get;set; }

    /* STEP 1 */
    public String selectedOperationType { get; set; }
    public List <SelectOption> operationTypes { get; set; }
    public Boolean isSaved { get; set; }
    public Boolean displayMessage { get; set; }
    public Boolean hasError { get; set; }
    public String message { get; set; }
    public String severity { get; set; }

    public PageReference saveParticipation(){
        
        displayMessage = true;
        message = '';
        severity = '';
        hasError = false;
        
        ISSP_AMC_DAO.saveForm(participation, appRequirementList, step,ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE);
        

        List <Apexpages.Message> msgs = ApexPages.getMessages();
        if(msgs != null && !msgs.isEmpty()){
            for(Apexpages.Message msg : msgs){
                if(msg.getSeverity() == Apexpages.Severity.CONFIRM){
                    severity = 'success';
                }
                else if(msg.getSeverity() == Apexpages.Severity.ERROR){
                    severity = 'danger';
                    hasError = true;
                }
                else {
                    severity = ('' + msg.getSeverity()).toLowerCase();
                }
            }
            if(severity == 'success'){
                message = '<b>Success!</b><br /><br />';
            }
            else if (severity == 'danger'){
                message = '<b>Error!</b><br /><br />';
            }
            else if (severity == 'warning'){
                message = '<b>Warning!</b><br /><br />';
            }
            else if (severity == 'info'){
                PageReference pr = new PageReference('/ISSP_Case?caseId=' + participation.Case__c + '&mid=M1S2');
                pr.setRedirect(true);
                return pr;
            }

            for(Apexpages.Message msg : msgs){
                message += msg.getDetail() + '<br />';
            }
            displayMessage = true;
        }
        calculateApplicationRequirementsToShow();
            return null;
    }

    public String step { get; set; }
    public Account accountRecord {get;set;}
    public Boolean isSISUser {get;set;}

    public ISSP_AMC_Baggage_Tag_Range() {

        accountRecord = ISSP_AMC_DAO.getAccountInfo();
        if(accountRecord.SIS_Status__c == 'Active'){
            isSISUser = true;
        }

        displayMessage = false;
        String participationId = Apexpages.currentPage().getParameters().get('participationId');
        step = Apexpages.currentPage().getParameters().get('step');
        appRequirementList = new List <ISSP_AMC_DAO.AplicationRequirements>();
        
        if(participationId == null){
            participation = ISSP_AMC_DAO.getCompleteParticipation(ISSP_AMC_Constants.AMC_CASE_REASON_BAGGAGE_FORM);
        }
        else {
            participation = ISSP_AMC_DAO.getCompleteDesignatorCode(participationId);
        }
        calculateApplicationRequirementsToShow();
        //if(participation.Case__c == null){
        //    ISSP_AMC_DAO.saveForm(participation, appRequirementList, step,ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE);
        //}
    }

    /*public boolean validateForm(){
        boolean errorFound = false;
        if (participation.Has_the_airline_been_issued_an_AOC_Pick__c == null) {
            participation.Has_the_airline_been_issued_an_AOC_Pick__c.addError(Label.ISSP_YouMustEnter);
            errorFound = true;
        }
        if (errorFound)
            return false;

        return true;
    }*/

    
    /* STEP 3 */

    public List <ISSP_AMC_DAO.AplicationRequirements> appRequirementList { get; set; }
    public List <String> selectedOperationTypeForRequirements { get; set; }

    public void calculateApplicationRequirementsToShow(){
        //try{

            if(appRequirementList == null){
                appRequirementList = new List <ISSP_AMC_DAO.AplicationRequirements>();
            }
            if(componentByOperation == null){
                componentByOperation = new Map <String, String>();
            }
            
            selectedOperationTypeForRequirements = new List<String>();
            selectedOperationTypeForRequirements.add('\'Baggage\'');
            
            ISSP_AMC_DAO.calculateApplicationRequirementsToShow(this.appRequirementList, selectedOperationTypeForRequirements, componentByOperation, participation, step, ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_BAGGAGE_CODE);
            
    }

}