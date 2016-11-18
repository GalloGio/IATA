public class AMS_AccountOscarWizardController {

    public Flow.Interview.OSCAR_Wizard_SIMPLEX myFlow { get; set; }

    ApexPages.StandardController controller;

    public String oscarId;

    public String caseId;

    public String oscarName;

    public String errorMessage{set;}

    public AMS_AccountOscarWizardController(ApexPages.StandardController stdController) {

        this.controller  = stdController;
        
    }

    public String getoscarId(){
        if (myFlow==null) 
            return '';
        else
         return myFlow.OscarId;
    }

    public String getoscarName(){
        if (myFlow==null) 
            return '';
        else
         return myFlow.createdOscarName;
    }

    public String getcaseId(){
        if (myFlow==null) 
            return '';
        else
         return myFlow.OscarCaseId;
    }

    public String geterrorMessage(){
        if(myFlow != null){
            System.debug('UPS !! something went wrong: ' + (String)myFlow.getVariableValue('ErrorMessage'));      

        }
        return null;
    }


}