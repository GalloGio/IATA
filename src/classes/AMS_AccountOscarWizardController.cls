public class AMS_AccountOscarWizardController {

    public Flow.Interview.OSCAR_Wizard_SIMPLEX myFlow { get; set; }
    public Flow.Interview.NewGen_OSCAR_Wizard_SIMPLEX myFlowNG { get; set; }
    public Flow.Interview.NewGen_Pilot_OSCAR_Wizard_China myFlowNGPilot { get; set; }

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
        if (myFlow==null && myFlowNG==null && myFlowNGPilot==null) 
            return '';
        else if(myFlow!=null)
            return myFlow.OscarId;
        else if(myFlowNG!=null)
            return myFlowNG.OscarId;
        else
            return myFlowNGPilot.OscarId;
    }

    public String getoscarName(){
        if (myFlow==null && myFlowNG==null && myFlowNGPilot==null) 
            return '';
        else if(myFlow!=null)
            return myFlow.createdOscarName;
        else if(myFlowNG!=null)
            return myFlowNG.createdOscarName;
        else
            return myFlowNGPilot.createdOscarName;
    }

    public String getcaseId(){
        if (myFlow==null && myFlowNG==null && myFlowNGPilot==null) 
            return '';
        else if(myFlow!=null)
            return myFlow.OscarCaseId;
        else if(myFlowNG!=null)
            return myFlowNG.OscarCaseId;
        else
            return myFlowNGPilot.OscarCaseId;
    }

    public String geterrorMessage(){
        if(myFlow != null){
            System.debug('UPS !! something went wrong: ' + (String)myFlow.getVariableValue('ErrorMessage'));      

        }
        return null;
    }


}