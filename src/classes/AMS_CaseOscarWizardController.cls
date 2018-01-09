public class AMS_CaseOscarWizardController {

    public Flow.Interview.OscarCaseMigration myFlow { get; set; }

    ApexPages.StandardController controller;

    public String oscarId;

    public String caseId;

    public String oscarName;

    public String errorMessage{set;}

    public AMS_CaseOscarWizardController(ApexPages.StandardController stdController) {

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
         return myFlow.caseNumber;
    }

    public String getcaseId(){
        if (myFlow==null) 
            return '';
        else
         return myFlow.caseId;
    }

    public String geterrorMessage(){
        if(myFlow != null){
            System.debug('UPS !! something went wrong: ' + (String)myFlow.getVariableValue('errorMessage'));      

        }
        return null;
    }


}