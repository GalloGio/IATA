public without sharing class vfIECSavedFilters {
    public String ProductLine { get; set; }
	public String sErrorMessage {get; set;}
	
	public IECCustomer loggedCustomer { get; set; }
	
	public List<IEC_Application_Filter__c> lstSavedFilters  {get; set;}
    public integer iFilterIndex                 			{get; set;}
	
    public IEC_Application_Filter__c Filter1 {get {return (lstSavedFilters != null && lstSavedFilters.size() > 0) ? lstSavedFilters.get(0) : null;}}
    public IEC_Application_Filter__c Filter2 {get {return (lstSavedFilters != null && lstSavedFilters.size() > 1) ? lstSavedFilters.get(1) : null;}}
    public IEC_Application_Filter__c Filter3 {get {return (lstSavedFilters != null && lstSavedFilters.size() > 2) ? lstSavedFilters.get(2) : null;}}
    public IEC_Application_Filter__c Filter4 {get {return (lstSavedFilters != null && lstSavedFilters.size() > 3) ? lstSavedFilters.get(3) : null;}}
    public IEC_Application_Filter__c Filter5 {get {return (lstSavedFilters != null && lstSavedFilters.size() > 4) ? lstSavedFilters.get(4) : null;}}
    

    /**
     * Constructor Method
     **/
    public vfIECSavedFilters() {
        lstSavedFilters = new List<IEC_Application_Filter__c>();
    }	
    
    public void loadFilters(String iProductLine) {
        ProductLine = iProductLine;
        lstSavedFilters = IECApplicationsManager.LoadFilterByContact(ProductLine, loggedCustomer.RelatedContact.Id, false);      
    }
    public void loadFilters() {
		lstSavedFilters = IECApplicationsManager.LoadFilterByContact(loggedCustomer.RelatedContact.Id, false);   	
    }
    
    public void deleteFilter() {
        try {
        	//String sFilterId = lstSavedFilters.get(iFilterIndex).Id;
        	//String sParam = ApexPages.currentPage().getParameters().get(IECConstants.PARAM_APPFILTER_ID);
            delete lstSavedFilters.get(iFilterIndex);
            if (ProductLine != null) loadFilters(ProductLine);
            else loadFilters();

			/*if (!String.isBlank(sParam)) {
				sParam = IECUtil.DecodeDecryptParameter(sParam);
				if (sParam == sFilterId) {
					return Page.IECGADAdvanced;
				}
			}*/
            //lstSavedFilters = IECApplicationsManager.LoadFilterByContact(loggedCustomer.RelatedContact.Id, false);
        }
        catch (Exception e) {
        	sErrorMessage = 'Could not delete filter with error: ' + e.getMessage() + e.getStackTraceString();
           //addErrorMessage('Could not delete filter with error: ' + e.getMessage() + e.getStackTraceString());
        }
		//return null;
    }
    
    public PageReference runFilter() {
		Pagereference pgRef = Page.IECGADResult;
		IEC_Application_Filter__c filter = lstSavedFilters.get(iFilterIndex);
		pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(filter.Id));
		//pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, filter.Id);
		pgRef.setRedirect(true);
		return pgRef;
    }
 
    public PageReference editFilter() {
		Pagereference pgRef = Page.IECGADAdvanced;
		IEC_Application_Filter__c filter = lstSavedFilters.get(iFilterIndex);
		pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, IECUtil.EncryptEncodeParameter(filter.Id));
		//pgRef.getParameters().put(IECConstants.PARAM_APPFILTER_ID, filter.Id);
		pgRef.setRedirect(true);
		return pgRef;
    }
}