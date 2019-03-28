/**
 * Base class for all page controller of the IEC project
 */
public virtual class IECPageController {
	public Boolean hasError { get; protected set; }
	public IECCustomer loggedCustomer { get; set; }
	public Boolean hasLoadedCustomer;
	
	private IECComponentControllerBase myComponentController;
	private Map<String, IECComponentControllerBase> componentControllerMap;

	public String language { get{
        if(language == null){
            language = UserInfo.getLanguage().split('_')[0];
        }
        return language;
    } set; }

    public IEC_User_Utils userDetails {get;set;}

	/**
	 * Constructor
	 */
	public IECPageController() {
		try {
			hasError = false;
			if (hasLoadedCustomer != true) {
				loggedCustomer = IECCustomer.getCurrentIECCustomer();
				hasLoadedCustomer = true;
			}
			userDetails = IEC_User_Utils.getInstance();
		}
		catch (Exception ex) {
			addErrorMessage(ex.getMessage() + '<br/>' + ex.getStackTraceString());
		}
	}
	
	public virtual void validUserProfile() {
		if (IECUserManager.isUserLoggedIn()) {
			String sOldPortalStatus = loggedCustomer.RelatedContact.User_IECPortal_Status__c;
			// Only run the validation if the status is null or user was pending login after a change of email/username
			if (String.isBlank(loggedCustomer.RelatedContact.User_IECPortal_Status__c) || loggedCustomer.RelatedContact.User_IECPortal_Status__c == IECConstants.PENDING_LOGIN_STATUS) {
				//Check for domain validation
				IECUtil.DomainValidation domValidation = IECUtil.validateContactEmailDomain(loggedCustomer.RelatedContact.Email, loggedCustomer.RelatedContact.AccountId);
			
				if (domValidation == IECUtil.DomainValidation.MATCHINGDOMAIN) {
				//Hanldes the case of email valid for account domain list
					loggedCustomer.RelatedContact.User_IECPortal_Status__c = IECConstants.APPROVED_CONTACT_STATUS;
				}
				else {
					//Handles email domain not valid for account domain list: set status to pending approval
					loggedCustomer.RelatedContact.User_IECPortal_Status__c = IECConstants.PENDING_APPROVAL_STATUS;
				}
			
				//update loggedCustomer.RelatedContact;
				IECUserManager.updateContactViaWebService(loggedCustomer.RelatedContact);

				// only assign the permission set if the initial User_IECPortal_Status__c was null
				if (String.isBlank(sOldPortalStatus))
					AssignPortalPermissionSet(loggedCustomer.RelatedUser.Id);
			}			
		}
	}
	
	@future
	public static void AssignPortalPermissionSet(Id idUser) {
		// Determine first if the permission set is already there
		Id permissionSetId = IECUserManager.getCustomerPermissionSetId();
		if (permissionSetId != null) {
			List<PermissionSetAssignment> lstPS =
				[SELECT Id
				FROM PermissionSetAssignment
				WHERE AssigneeId = :idUser
					AND PermissionSetId = :permissionSetId];
					
			if (lstPS.isEmpty()) {
				// assign Permission Set to provide access to objects
				insert new PermissionSetAssignment (
					AssigneeId = idUser
					, PermissionSetId = permissionSetId
				);
			}
		}
	}

	/**
	 * Adds an error message to the current page
	 */
	public virtual void addErrorMessage(String message) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, message));
    	hasError = true;
  	}
  	
  	/**
	 * Adds a list of error messages to the current page
	 */
  	public virtual void addErrorMessages(List<String> messages) {
    	for (String msg : messages) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg));
    	}
    	hasError = true;
  	}
  	
  	/**
	 * Adds a list of error messages to the current page
	 */
  	public virtual void addErrorMessage(Exception ex) {
   		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage() + '\r\n' + ex.getStackTraceString()));
    	hasError = true;
  	}
  	
  	/**
	 * Adds an information message to the current page
	 */
  	public virtual void addInfoMessage(String message) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, message));
  	}
  	
  	/**
	 * Adds a list of information messages to the current page
	 */
  	public virtual void addInfoMessage(List<String> messages) {
    	for (String msg : messages) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, msg));
    	}
  	}
  	
  	/**
	 * Adds an information message to the current page
	 */
  	public virtual void addConfirmMessage(String message) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
  	}
  	
  	/**
	 * Adds a list of information messages to the current page
	 */
  	public virtual void addConfirmMessage(List<String> messages) {
    	for (String msg : messages) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, msg));
    	}
  	}
  	
  	/**
	 * Adds a warning message to the current page
	 */
  	public virtual void addWarningMessage(String message) {
    	ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, message));
  	}

	/**
	 * Adds a list of warning messages to the current page
	 */
  	public virtual void addWarningMessages(List<String> messages) {
    	for (String msg : messages) {
    		ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, msg));
    	}
  	}
  	
  	//////////////////////////////////////////////////////////////////////////////////////////////////////////
  	// below code is to implement the communication to multiple component controller from the page controller
  	// based on: http://wiki.developerforce.com/page/Controller_Component_Communication
	
	public virtual IECComponentControllerBase getMyComponentController() {
		return myComponentController;
	}
	
	public virtual Map<String, IECComponentControllerBase> getComponentControllerMap(){
		return componentControllerMap;
	}
	
	public virtual void setComponentControllerMap(String key, IECComponentControllerBase compController){
		if(componentControllerMap == null)
			componentControllerMap = new Map<String, IECComponentControllerBase>();
		componentControllerMap.put(key,compController); 
	}
	
	public virtual void setComponentController(IECComponentControllerBase compController) {
		myComponentController = compController;
	}
	
	public IECPageController getThis() {
		return this;
	}
}