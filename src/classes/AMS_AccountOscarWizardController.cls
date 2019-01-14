public class AMS_AccountOscarWizardController {

    public Flow.Interview.OSCAR_Wizard_SIMPLEX myFlow { get; set; }
    public Flow.Interview.NewGen_OSCAR_Wizard_SIMPLEX myFlowNG { get; set; }

    ApexPages.StandardController controller;

    public String oscarId;

    public String caseId;

    public String oscarName;

    public String errorMessage{set;}

    public AMS_AccountOscarWizardController(ApexPages.StandardController stdController) {

        this.controller = stdController;
       
    }

    public Account getAccount() {
        if(ApexPages.currentPage().getParameters().get('accountId') != null)
            return [select ANG_IsNewGenAgency__c from Account
                    where id = :ApexPages.currentPage().getParameters().get('accountId')];
        return null;
    }

    public String getoscarId(){
        if (myFlow==null && myFlowNG==null) 
            return '';
        else if(myFlow!=null)
            return myFlow.OscarId;
        else
            return myFlowNG.OscarId;
    }

    public String getoscarName(){
        if (myFlow==null && myFlowNG==null) 
            return '';
        else if(myFlow!=null)
            return myFlow.createdOscarName;
        else
            return myFlowNG.createdOscarName;
    }

    public String getcaseId(){
        if (myFlow==null && myFlowNG==null) 
            return '';
        else if(myFlow!=null)
            return myFlow.OscarCaseId;
        else
            return myFlowNG.OscarCaseId;
    }

    public String geterrorMessage(){
        if(myFlow != null){
            System.debug('UPS !! something went wrong: ' + (String)myFlow.getVariableValue('ErrorMessage'));      

        }
        return null;
    }


}