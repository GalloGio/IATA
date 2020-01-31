public class OscarWizzardFlowController {

	public Flow.Interview.Wizard_OSCAR_Creation_2_0 myFlow { get; set; }

	ApexPages.StandardController controller;

	public String oscarId;

	public String caseId;

	public String oscarName;

	public String errorMessage{set;}

	public OscarWizzardFlowController(ApexPages.StandardController stdController) {

		this.controller  = stdController;

	}

	public String getoscarId(){
		if (myFlow==null)
			return '';
		else
		 return myFlow.OSCARICreatedId;
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
		 return myFlow.OscarCaseCreatedId;
	}

	public String geterrorMessage(){
		if(myFlow != null){
			System.debug('UPS !! something went wrong: ' + (String)myFlow.getVariableValue('ErrorMessage'));

			//if (myFlow.ObjectsCreated != null )
				//System.debug('Objects created are ' + myFlow.ObjectsCreated);

//            return (String)myFlow.getVariableValue('ErrorMessage');
		}
		return null;
	}


}
