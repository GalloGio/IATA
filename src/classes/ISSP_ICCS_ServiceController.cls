public class ISSP_ICCS_ServiceController{

    public ISSP_ICCS_ServiceController thisCtrl {get{return this;}}
    
    public ISSP_ICCS_CoreRest coreRest;
    
    public static Integer increment = 0;
    
	// Used for comparison in components
	public String NONE { get{ return ISSP_ICCS_Utils.NONE; }}

	// Map of downloadable documents
    public Map<String, Document> downloadableDocumentsMap {
    	get{
    		if(downloadableDocumentsMap == null){
		        Folder ICCSDocumentFolder = [select id from Folder where developername ='ICCS_Portal_Service' limit 1];
		        List<Document> documentList = [select Id, Name, DeveloperName, LastModifiedDate from Document where FolderId =: ICCSDocumentFolder.Id];
		        
		        downloadableDocumentsMap = new Map<String, Document>();
		        for(Document doc : documentList){
		            downloadableDocumentsMap.put(doc.DeveloperName, doc);
		        }
    		}
			return downloadableDocumentsMap;
    	}
    	set;
    }

	/* User and Account data */

	// Top Account of the contact related to the portal user
	public Account topAccount {get;set;}

	// Top Account id in ICCS Core
	public String participantId {
		get{
			if(participantId == null){
				if(isAirline){
					participantId = topAccount.Airline_designator__c + topAccount.IATACode__c;
				}
				if(isAgency){
					participantId = topAccount.IATACode__c;
				}
			}
			/* Needs to be updated if other types of accounts can use ICCS */
			return participantId;
		}
		// set is used for test purposes
		set;
	}
	
	// Contact related to the portal user
    public Contact portalUserContact {get;set;}

	// Portal user
    public User portalUser {get;set;}

	// Rights of the portal user within ICCS Service
	public Portal_Application_Right__c userRights {get;set;}


	/* Navigation variables */

	// Map of component controllers
    public Map<ISSP_ICCS_Utils.Page,ISSP_ICCS_ComponentController> componentControllersMap {
    	get{
    		if(componentControllersMap == null){
    			componentControllersMap = new Map<ISSP_ICCS_Utils.Page,ISSP_ICCS_ComponentController>();
    		}
    		return componentControllersMap;
    	}
    	set;
    }
	
	// Indicates which component is left
    public ISSP_ICCS_Utils.Page previousComponent {get;set;}
	
	// Indicates which is the component currently displayed
    public ISSP_ICCS_Utils.Page currentComponent {get;set;}

	// Indicates which is the case process type component currently displayed (if current component is CaseProcesses)
    public ISSP_ICCS_Utils.CaseProcessType currentCaseProcessType {get;set;}
    
	// Set by different components when navigating to existing cases. Used in the navigateToCase method
	public Id caseIdParameter {get;set;}    
    
    
	/* Messages to the user variables */

	// Message displayed to the user (success or error)
	public String userMessage {get;set;}
	
	// Indicates if message displayed to the user is success or not
	public Boolean isSuccessMessage {get;set;} 

	public Boolean displayCaseSavedMessage {get;set;}
	public Case savedCase {get;set;}


	/* Rendering variables */

    // Portal user Account type
    public Boolean isAgency		{get{return topAccount.RecordTypeId == ISSP_ICCS_Utils.ACCOUNT_RECORD_TYPE_AGENCY;}}
    public Boolean isAirline	{get{return topAccount.RecordTypeId == ISSP_ICCS_Utils.ACCOUNT_RECORD_TYPE_AIRLINE_HQ || topAccount.RecordTypeId == ISSP_ICCS_Utils.ACCOUNT_RECORD_TYPE_AIRLINE_BRANCH;}}
    
    public String pricingPolicyFileUniqueName {
    	get{
    		if(isAgency){
    			return 'ICCS_Pricing_Policy_Agents';
    		}
    		else if(isAirline){
    			return 'ICCS_Pricing_Policy_Airlines';
    		}
    		return '';
    	}
    }
    
    public String fxPolicyFileUniqueName {
    	get{
    		if(isAgency){
    			return 'FX_Policy_Agents';
    		}
    		else if(isAirline){
    			return 'FX_Policy_Airlines';
    		}
    		return '';
    	}
    }
    
	public String registrationZipFileUniqueName {
    	get{
    		if(isAgency){
    			return 'ICCS_Registration_Documents_Agents';
    		}
    		else if(isAirline){
    			return 'ICCS_Registration_Documents_Airlines';
    		}
    		return '';
    	}
    }
    

    // Portal user Account ICCS status
    public Boolean isMembershipNone 		{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_NONE;}}
    public Boolean isMembershipProspect 	{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_PROSPECT;}}
    public Boolean isMembershipActive 		{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_ACTIVE;}}
    public Boolean isMembershipMember 		{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_MEMBER;}}
    public Boolean isMembershipSuspended 	{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_SUSPENDED;}}
    public Boolean isMembershipWithdrawn 	{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_WITHDRAWN;}}
    public Boolean isMembershipInactive 	{get{return topAccount.ICCS_Membership_Status__c == ISSP_ICCS_Utils.ICCS_MEMBERSHIP_INACTIVE;}}	
    
    // Valid portal user status
    public Boolean isPortalStatusApproved	{get{return portalUserContact.User_Portal_Status__c == ISSP_ICCS_Utils.PORTAL_STATUS_APPROVED;}}
    public Boolean isPortalStatusAdmin 		{get{return portalUserContact.User_Portal_Status__c == ISSP_ICCS_Utils.PORTAL_STATUS_ADMIN;}}
    public Boolean isPortalStatusRegAdmin 	{get{return portalUserContact.User_Portal_Status__c == ISSP_ICCS_Utils.PORTAL_STATUS_REG_ADMIN;}}
	public Boolean isActivePortalUser 		{get{return isPortalStatusApproved || isPortalStatusAdmin || isPortalStatusRegAdmin;}}

    // Invalid portal user status
    public Boolean isPortalStatusInactive	{get{return portalUserContact.User_Portal_Status__c == ISSP_ICCS_Utils.PORTAL_STATUS_INACTIVE;}}
    public Boolean isPortalStatusPending 	{get{return portalUserContact.User_Portal_Status__c == ISSP_ICCS_Utils.PORTAL_STATUS_PENDING;}}
    public Boolean isPortalStatusNone 		{get{return portalUserContact.User_Portal_Status__c == ISSP_ICCS_Utils.PORTAL_STATUS_NONE;}}
    
    // Portal user ICCS roles
    public String portalUserRights 		{get;set;}
    public Boolean isSignatoryUser 		{get{return portalUserRights == ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY;}}
    public Boolean isLevel1User 		{get{return portalUserRights == ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1;}}
    public Boolean isReadOnlyUser 		{get{return portalUserRights == ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY;}}
    public Boolean isRegistrationUser 	{get{return portalUserRights == ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION;}}
    public Boolean hasIccsRole 			{get{return isSignatoryUser || isLevel1User || isReadOnlyUser || isRegistrationUser;}}
    public String newRoleRequested 		{get;set;}
    
    // Navigation variables
    public Boolean displayHomepage 		{get{return currentComponent == ISSP_ICCS_Utils.Page.HOMEPAGE;}}
    public Boolean displayServiceMgmt 	{get{return currentComponent == ISSP_ICCS_Utils.Page.SERVICE_MGMT;}}
    public Boolean displayCycleMgmt 	{get{return currentComponent == ISSP_ICCS_Utils.Page.CYCLE_MGMT;}}
    public Boolean displayCases 		{get{return currentComponent == ISSP_ICCS_Utils.Page.CASES;}}
    public Boolean displayReports 		{get{return currentComponent == ISSP_ICCS_Utils.Page.REPORTS;}}
    public Boolean displayProfile 		{get{return currentComponent == ISSP_ICCS_Utils.Page.PROFILE;}}
    public Boolean displayCaseProcesses	{get{return currentComponent == ISSP_ICCS_Utils.Page.CASE_PROCESSES;}}
    public Boolean displaySiEdit		{get{return currentComponent == ISSP_ICCS_Utils.Page.SI_EDIT;}}
    public Boolean displayAccessDenied 	{get{return currentComponent == ISSP_ICCS_Utils.Page.ACCESS_DENIED;}}
            
    public Boolean displayRegistration 	{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.REGISTRATION;}}
    public Boolean displayBankAccount 	{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT;}}
    public Boolean displayPartNew 		{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.PART_NEW;}}
    public Boolean displayPartDel 		{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.PART_DEL;}}
    public Boolean displayDeactivation 	{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.DEACTIVATION;}}
    public Boolean displayAspUpd 		{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.ASP_UPD;}}
    public Boolean displayNoa 			{get{return currentCaseProcessType == ISSP_ICCS_Utils.CaseProcessType.NOA;}}


	// Number of active participations, displayed in Homepage and Profile page
	public Integer activeParticipations {
		get{
			try{
				Integer i = 0;
				for(ISSP_ICCS_CoreRest.Participation participation : coreRest.getParticipations()){
					if(participation.endDate == null){
						i++;
					}
					else{
						List<String> splitedDate = participation.endDate.split('-');
						if(splitedDate.size() == 3){
							try{
								Date endDate = Date.newInstance(Integer.valueOf(splitedDate[0]), Integer.valueOf(splitedDate[1]), Integer.valueOf(splitedDate[2]));
								if(Date.today() < endDate){
									i++;
								}
							}
							catch(Exception e){}
						}
					}
				}
				return i;
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				setMessage(e.getMessage(), false);
				return 0;
			}
		}
	}

	// Number of opportunities, displayed in Homepage and Profile page
	public Integer opportunities {
		get{
			try{
				return coreRest.getCashflows().size() - activeParticipations;
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				setMessage(e.getMessage(), false);
				return 0;
			}
		}
	}

	// Number of bank Accounts, displayed in Homepage and Profile page
	public Integer numberOfBankAccounts {
		get{
			try{
				Set<Integer> distinctBankAccounts = new Set<Integer>();
				for(ISSP_ICCS_CoreRest.BankAccountCode bankAccountCode : coreRest.getBankAccountsCodes()){
					distinctBankAccounts.add(bankAccountCode.bankAccount.id);
				}
				return distinctBankAccounts.size();
			}
			catch(ISSP_ICCS_CoreRest.ICCS_Exception e){
				setMessage(e.getMessage(), false);
				return 0;
			}
		}
	}


	/* CONSTRUCTORS */

    public ISSP_ICCS_ServiceController(){
        this(UserInfo.getUserId(), apexpages.currentpage().getparameters().get('caseId'));
    }
    
    public ISSP_ICCS_ServiceController(Id userId){
        this(userId, null);
    }
    
    public ISSP_ICCS_ServiceController(Id userId, String caseId){
    	// TEMP. Used for testing View State
//    	userId = '0059E000002HvJy';
        
        // Retrieve current User record
        portalUser = [Select Id, ContactId from User where Id =: userId];
        
        // If user is a portal user, retrieve related contact and account
        if(portalUser.ContactId != null){
        	
        	// Set Contact
            portalUserContact = [select Id, FirstName, LastName, Title, Email, User_Portal_Status__c, 
	    							AccountId, Account.Name, Account.ICCS_Membership_Status__c, Account.RecordTypeId, 
	    							Account.Top_Parent__c, Account.Top_Parent__r.Name, Account.Top_Parent__r.ICCS_Membership_Status__c, Account.Top_Parent__r.RecordTypeId 
    							from Contact 
    							where Id =: portalUser.ContactId];

			// Set top account
			Id topAccountId = portalUserContact.Account.Top_Parent__c != null ? portalUserContact.Account.Top_Parent__c : portalUserContact.AccountId;

			topAccount = [	select Id, Name, ICCS_Membership_Status__c, Field_Head_Office__c, Airline_designator__c, duplicate_flag_indicato__c, IATACode__c, Airline_Prefix__c, Key_Customer__c, RecordTypeId 
							from Account 
							where Id =: topAccountId];
							
							System.debug('TOP ACCOUNT ' + topAccount);

            // Check if user has been granted access to the service
            List<Portal_Application_Right__c> userRightsList = [select ANG_Portal_Service_Role__c, New_Role_Requested__c, Top_Account__c, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email 
            													from Portal_Application_Right__c 
            													where Contact__r.Id =: portalUserContact.Id 
            														and Application_Name__c =: ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME 
            														and Right__c =: ISSP_ICCS_Utils.ACCESS_GRANTED];

			if(!userRightsList.isEmpty()){
				userRights = userRightsList[0];
	            portalUserRights = userRights.ANG_Portal_Service_Role__c;
	            newRoleRequested = userRights.New_Role_Requested__c;
			}
			else{
				userRights = null;
	            portalUserRights = '';
			}
        }

		coreRest = new ISSP_ICCS_CoreRest(this);
		
		currentComponent = ISSP_ICCS_Utils.Page.HOMEPAGE;
		
		if(!isActivePortalUser){
			setMessage(Label.ICCS_Homepage_UnapprovedUser, false);
			return;
		}
		
		if(!hasIccsRole){
			setMessage(Label.ICCS_Redirect_to_Services_tab, false);
			return;
		}
		
		// If the page URL contains the caseId parameter, we will navigate to the Case instead of the homepage
		// But we need to ensure that
		// - The ICCS membership of the user's account is Member or Suspended, except if the case is the registration case
		// - The user has the Signatory, Level 1 or Read-only role
		// - The Case is related to the user's account
		// - The Case is an ICCS Case
		if(caseId != null){
			// Retrieve the Case
        	List<Case> cases = [select Id,
			                CaseNumber,
			                Contact.Name,
			                Contact.Id,
			                Origin,
			                AccountId,
			                RecordTypeId,
			                Status,
			                Subject,
			                CreatedDate
			            from Case 
			            where 
			            	id =: caseId];

			// Check that the Case exists
			if(cases.isEmpty()){
				System.debug('Case not found ');
				
				setMessage('Case does not exist', false);
				
				return;
			}
			
			Case cse = cases[0];
			
			// Check if the Case belongs to the user's Top Account
			if(cse.AccountId != topAccount.Id){
				System.debug('Case is not linked to User\'s Top Account : ');
				System.debug('Case account Id : ' + cse.AccountId);
				System.debug('User Top Account Id: ' + topAccount.Id);
				
				setMessage('This Case does not belong to your Account', false);
				
				return;
			}

			// Check if the Case is an ICCS Case
			Set<Id> recordTypesSet = new Set<Id>(ISSP_ICCS_Utils.CASE_RECORD_TYPES);
			if(cse.Origin != 'Portal' || !recordTypesSet.contains(cse.RecordTypeId)){
				System.debug('Case is not an ICCS Case : ');
				System.debug('Case Origin : ' + cse.Origin);
				System.debug('Case Record Type Id : ' + cse.RecordTypeId);
				
				setMessage('This Case is not an ICCS Case', false);
				
				return;
			}


			// Check that the membership Status is Member or Suspended if the case is not a registration case
			if(!(isMembershipMember || isMembershipSuspended) && cse.RecordTypeId != ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP ){
				System.debug('ICCS Membership status prevent seeing this case: ');
				System.debug('Is Member : ' + isMembershipMember);
				System.debug('Is Suspended : ' + isMembershipSuspended);
				System.debug('Case Record Type Id : ' + cse.RecordTypeId);
				
				setMessage('Your Account\'s ICCS Membership Status does not allow you to view this Case', false);
				
				return;
			}
			
			caseIdParameter = caseId;
			navigateToCase();
		}
    }


	/* Message methods */

	public void setMessage(String userMessage, Boolean isSuccessMessage){
		this.userMessage = userMessage;
		this.isSuccessMessage = isSuccessMessage;
	}

	public void resetMessage(){
		setMessage(null, null);
		
		displayCaseSavedMessage = null;
		savedCase = null;
	}


    /* Navigation methods */

    public void navigateToHomepage(){
        navigateTo(ISSP_ICCS_Utils.Page.HOMEPAGE);
    }
    
    public void navigateToServiceMgmt(){
        navigateTo(ISSP_ICCS_Utils.Page.SERVICE_MGMT);
    }
    
    public void navigateToCycleMgmt(){
        navigateTo(ISSP_ICCS_Utils.Page.CYCLE_MGMT);
    }
 
    public void navigateToCases(){
        navigateTo(ISSP_ICCS_Utils.Page.CASES);
    }

    public void navigateToReports(){
        navigateTo(ISSP_ICCS_Utils.Page.REPORTS);
    }
 
    public void navigateToProfile(){
        navigateTo(ISSP_ICCS_Utils.Page.PROFILE);
    }

    public void navigateToSiEdit(){
        navigateTo(ISSP_ICCS_Utils.Page.SI_EDIT);
    }

	public void navigateTo(ISSP_ICCS_Utils.Page destinationPage){
		System.debug('ISSP_ICCS_ServiceController.navigateTo(ISSP_ICCS_Utils.Page destinationPage) : increment ' + ++ISSP_ICCS_ServiceController.increment);

    	resetMessage();
        previousComponent = currentComponent;
        currentComponent = destinationPage;
        
        if(componentControllersMap.get(currentComponent) != null && previousComponent != currentComponent){
	        componentControllersMap.get(currentComponent).resetCurrentCleanPrevious(this);
        }
	}
	
    public void cancel(){
		System.debug('ISSP_ICCS_ServiceController.cancel() : increment ' + ++ISSP_ICCS_ServiceController.increment);

    	resetMessage();

		componentControllersMap.get(currentComponent).cleanController();

        currentComponent = previousComponent;
        previousComponent = ISSP_ICCS_Utils.Page.NONE;
        if(componentControllersMap.get(currentComponent) != null){
			componentControllersMap.get(currentComponent).resetCurrentCleanPrevious(this);
        }
    }
    
	// Called when user clicks on a case link
    public void navigateToCase(){
		// Retrieve the case with the caseIdParameter
        Case cse = [select Id, RecordTypeId, CaseArea__c from Case where Id = : caseIdParameter];
        
        if(cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_MEMBERSHIP){
            if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_JOIN_SERVICE){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.REGISTRATION);
            }
            else if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_LEAVE_SERVICE){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.DEACTIVATION);
            }
        }
        else if(cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_BANK_ACCT){
            if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_ADD_BANK_ACCOUNT){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);
            }
            else if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_UPD_BANK_ACCOUNT){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.BANK_ACCOUNT);
            }
        }
        else if(cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_PARTICIPATION){
            if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_JOIN_PARTICIPATION){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.PART_NEW);
            }
            else if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_LEAVE_PARTICIPATION){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.PART_DEL);
            }
            else if(cse.CaseArea__c == ISSP_ICCS_Utils.CASE_AREA_TERMINATE_NOA){
                navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.NOA);
            }
        }
        else if(cse.RecordTypeId == ISSP_ICCS_Utils.CASE_RECORD_TYPE_ASP){
			navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.ASP_UPD);
        }
    }

	public void navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType caseProcessType){
		System.debug('ISSP_ICCS_ServiceController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType caseProcessType) : increment ' + ++ISSP_ICCS_ServiceController.increment);

    	resetMessage();
        previousComponent = currentComponent;
        currentComponent = ISSP_ICCS_Utils.Page.CASE_PROCESSES;
       	currentCaseProcessType = caseProcessType;

        if(componentControllersMap.get(currentComponent) != null){
	        componentControllersMap.get(currentComponent).resetCurrentCleanPrevious(this);
        }
    }

    public void saveAndClose(Id caseId){
		System.debug('ISSP_ICCS_ServiceController.saveAndClose(Id caseId) : increment ' + ++ISSP_ICCS_ServiceController.increment);
		
		componentControllersMap.get(currentComponent).cleanController();
        currentComponent = previousComponent;
        previousComponent = ISSP_ICCS_Utils.Page.NONE;

        if(componentControllersMap.get(currentComponent) != null){
			componentControllersMap.get(currentComponent).resetCurrentCleanPrevious(this);
        }

		displayCaseSavedMessage = true;
        savedCase = [select Id, CaseNumber, Subject, Status from Case where Id =: caseId];        
    }
    
    public void saveAndClose(String message){
		System.debug('ISSP_ICCS_ServiceController.saveAndClose(String message) : increment ' + ++ISSP_ICCS_ServiceController.increment);
		
		componentControllersMap.get(currentComponent).cleanController();
        currentComponent = previousComponent;
        previousComponent = ISSP_ICCS_Utils.Page.NONE;

        if(componentControllersMap.get(currentComponent) != null){
			componentControllersMap.get(currentComponent).resetCurrentCleanPrevious(this);
        }

		setMessage(message, true);
    }
}