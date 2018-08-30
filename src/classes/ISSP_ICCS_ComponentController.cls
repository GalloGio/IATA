public abstract class ISSP_ICCS_ComponentController {

    public ISSP_ICCS_ServiceController pageController {
    	get;
    	set{
			System.debug('ISSP_ICCS_ComponentController setting pageController : increment ' + ++ISSP_ICCS_ServiceController.increment);
            if(value != null && pageController == null){
				System.debug('ISSP_ICCS_ComponentController setting pageController : value != null && pageController == null : increment ' + ++ISSP_ICCS_ServiceController.increment);
				pageController =  value;
                pageController.componentControllersMap.put(getComponentType(), this);
				resetCurrentCleanPrevious(pageController);
            }
		}
    }

	public void resetCurrentCleanPrevious(ISSP_ICCS_ServiceController pageController){
		// Reset current component
		if(resetController(pageController)){
			// clean previous component
			if(pageController.componentControllersMap.get(pageController.previousComponent) != null){
				pageController.componentControllersMap.get(pageController.previousComponent).cleanController();
			}
			
			// Clean pageController
			pageController.caseIdParameter = null;
		}
	}

	public abstract ISSP_ICCS_Utils.Page getComponentType();
	
	// The returned value indicates if we need to clean the previous component
	// will be false for ISSP_ICCS_CaseProcessesController, true for the other ones
	public abstract Boolean resetController(ISSP_ICCS_ServiceController pageController);
	
	public abstract void cleanController();
}