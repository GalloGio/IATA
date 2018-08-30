public without sharing class ISSP_ICCS_ProfileController extends ISSP_ICCS_ComponentController{

	// Used for display purpose only
	public Boolean getReportsNotifications {
		get{ return userReportPreference.Subscribed__c; }
		// Keep the set because we are using a inputCheckbox to display
		set;
	}
	
	// Portal user preference about ICCS reports notifications
	public Portal_Service_User_Preference__c userReportPreference {
		get{
			if(userReportPreference == null){
				List<Portal_Service_User_Preference__c> userReportPreferences = [select id, Subscribed__c from Portal_Service_User_Preference__c where Portal_Service_Access__c =: pageController.userRights.Id and Category__c = 'Notification' and Name = 'ICCS Report Notifications'];
	
				if(userReportPreferences.isEmpty()){
					userReportPreference = new Portal_Service_User_Preference__c(Portal_Service_Access__c = pageController.userRights.Id, Category__c = 'Notification', Name = 'ICCS Report Notifications', Subscribed__c = false);
				}
				else{
					userReportPreference = userReportPreferences[0];
				}
			}
			return userReportPreference;
		}
		set;
	}
	
	// Roles that can be set a Signatory user
	public List<SelectOption> serviceRoles {
		get{
			return new List<SelectOption>{
						new SelectOption(ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION, ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION), 
						new SelectOption(ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY, ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY), 
						new SelectOption(ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1, ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1)};
		}
	}
	
	// Roles that can be set by a Level 1user
	public List<SelectOption> restrictedServiceRoles {
		get{
			return new List<SelectOption>{
						new SelectOption(ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION, ISSP_ICCS_Utils.ICCS_ROLE_REGISTRATION), 
						new SelectOption(ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY, ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY)};
		}
	}
	
	// ICCS Service access statuses that can be set to a portal user
	public List<SelectOption> accessStatusesIncludingRequested {
		get{
			return new List<SelectOption>{
						new SelectOption(ISSP_ICCS_Utils.ACCESS_REQUESTED, ISSP_ICCS_Utils.ACCESS_REQUESTED), 
						new SelectOption(ISSP_ICCS_Utils.ACCESS_GRANTED, ISSP_ICCS_Utils.ACCESS_GRANTED), 
						new SelectOption(ISSP_ICCS_Utils.ACCESS_DENIED, ISSP_ICCS_Utils.ACCESS_DENIED)};
		}
	}

	// Lists of users that are displayed on the Profile page
	public List<UserWrapper> wrappedUsersList {
		get{
			if(wrappedUsersList == null){
				wrappedUsersList = new List<UserWrapper>();
				
				String topAccountId = (String) pageController.topAccount.Id;
				topAccountId = topAccountId.substring(0,15);
				
				// List of ICCS portal user rights of the related top account
				List<Portal_Application_Right__c> portalUsers = [select Contact__c, Contact__r.Id, Contact__r.FirstName, Contact__r.LastName, Contact__r.Email, ANG_Portal_Service_Role__c, New_Role_Requested__c, Right__c
																from Portal_Application_Right__c 
																where Application_Name__c = : ISSP_ICCS_Utils.ICCS_PORTAL_APPLICATION_NAME
																and (Right__c =: ISSP_ICCS_Utils.ACCESS_GRANTED or Right__c =: ISSP_ICCS_Utils.ACCESS_REQUESTED)
																and Top_Account__c=: topAccountId];
				
				// Retrieve Portal Users access to ICCS Service
				for(Portal_Application_Right__c usr : portalUsers){
					wrappedUsersList.add(new UserWrapper(this, usr));
				}
			}
			return wrappedUsersList;
		}
		set;
	}

	
	/* CONSTRUCTOR */

	public ISSP_ICCS_ProfileController(){}


	public override ISSP_ICCS_Utils.Page getComponentType(){
		return ISSP_ICCS_Utils.Page.PROFILE;
	}

	// Called when loading the Profile page
	public override Boolean resetController(ISSP_ICCS_ServiceController pageController){
		return true;
	}

	public override void cleanController(){
		userReportPreference = null;
		
		wrappedUsersList = null;
	}

	public void requestLevel1Access(){
    	pageController.resetMessage();
		pageController.newRoleRequested = ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1;
    	ISSP_ICCS_Utils.requestRole(pageController.userRights, ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1, false);		
	}
    
    public void updateReportsNotificationChoice(){
    	pageController.resetMessage();
		userReportPreference.Subscribed__c = !userReportPreference.Subscribed__c;
		upsert userReportPreference;
    }

    public void updateASP(){
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.ASP_UPD);
    }

    public void deactivateService(){
        pageController.navigateToCaseProcess(ISSP_ICCS_Utils.CaseProcessType.DEACTIVATION);
    }


	/* INNER CLASSES */

	public class UserWrapper {
		public ISSP_ICCS_ProfileController ctrl {get;set;}
		public Portal_Application_Right__c usr {get;set;}
		
		public Boolean isSignatory	{ get{ return role == ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY; }}
		public Boolean isLevel1		{ get{ return role == ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1; }}
		public Boolean isReadOnly	{ get{ return role == ISSP_ICCS_Utils.ICCS_ROLE_READ_ONLY; }}
		
		public Boolean userRequestedAccess { get{ return usr.Right__c == ISSP_ICCS_Utils.ACCESS_REQUESTED; }}
		public Boolean userRequestedRoleUpgrade { get{ return usr.Right__c == ISSP_ICCS_Utils.ACCESS_GRANTED && usr.New_Role_Requested__c != null && usr.New_Role_Requested__c != ''; }}

		// Role of the Portal user in ICCS Service
		public String role {get;set;}
		
		// Access status of Portal user to ICCS Service
		public String accessStatus {get;set;}

		// Indicates if the user line is in edit mode in the UserWrapper table
		public Boolean editMode {get;set;}

		// If current user has the Signatory role, he can modify the role of another user which has Registration, Read-only or Level 1 role
		// If current user has the Level 1 role, he can modify the role of another user which has Registration or Read-only role
		public Boolean canUserModifyRole {
			get{ 
				return role != ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY
								&& (ctrl.pageController.isSignatoryUser
									|| (ctrl.pageController.isLevel1User && role != ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1));
			}
		}
		
		public Boolean canUserHandleRoleUpgradeRequest {
			get{
				return 	usr.New_Role_Requested__c != null 
						&& usr.New_Role_Requested__c != '' 
						&& (ctrl.pageController.isSignatoryUser 
							|| (ctrl.pageController.isLevel1User && usr.New_Role_Requested__c != ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1));
			}
		}

		public Boolean canUserGiveLevel1Access { get{ return ctrl.pageController.isSignatoryUser; }}
		public Boolean canUserGiveReadOnlyAccess { get{ return ctrl.pageController.isSignatoryUser || ctrl.pageController.isLevel1User; }}
		
		// Current user can modify the Access status of another user:
		// - Signatory can modify access status for Registration, Read-only or Level 1 users
		// - Level 1 can modify access status for Registration or Read-only users
		public Boolean canUserModifyAccess{
			get{
				return (ctrl.pageController.isSignatoryUser && role != ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY)
						|| (ctrl.pageController.isLevel1User && role != ISSP_ICCS_Utils.ICCS_ROLE_SIGNATORY &&  role != ISSP_ICCS_Utils.ICCS_ROLE_LEVEL1);
			}
		}
		
		public UserWrapper(ISSP_ICCS_ProfileController ctrl, Portal_Application_Right__c usr){
			this.ctrl = ctrl;
			this.usr = usr;
			this.role = usr.ANG_Portal_Service_Role__c;
			this.accessStatus = usr.Right__c;
			this.editMode = false;
		}
		
		public void updateUser(){
			role = usr.ANG_Portal_Service_Role__c;
			accessStatus = usr.Right__c;
			editMode = true;
		}
		
		public void grantAccess(){
			accessStatus = ISSP_ICCS_Utils.ACCESS_GRANTED;
			save();
		}
		
		public void denyAccess(){
			accessStatus = ISSP_ICCS_Utils.ACCESS_DENIED;
			save();
		}
		
		public void acceptRoleUpgrade(){
	    	ctrl.pageController.resetMessage();
			usr.ANG_Portal_Service_Role__c = usr.New_Role_Requested__c;
			usr.New_Role_Requested__c = null;
			update usr;

			String replaceStr = '%FIRST_NAME%!' + usr.Contact__r.FirstName + '|' +
								'%LAST_NAME%!' + usr.Contact__r.LastName + '|' +
								'%ICCS_ROLE%!' + usr.ANG_Portal_Service_Role__c;

			ISSP_ICCS_Utils.createNotification(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_UPGRADE_ACCEPTED), replaceStr, new List<Portal_Application_Right__c>{usr});
			ctrl.wrappedUsersList = null;
		}
		
		public void rejectRoleUpgrade(){
	    	ctrl.pageController.resetMessage();
			usr.New_Role_Requested__c = null;
			update usr;
						
			String replaceStr = '%FIRST_NAME%!' + usr.Contact__r.FirstName + '|' +
								'%LAST_NAME%!' + usr.Contact__r.LastName;

			ISSP_ICCS_Utils.createNotification(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_UPGRADE_DENIED), replaceStr, new List<Portal_Application_Right__c>{usr});
			ctrl.wrappedUsersList = null;
		}
		
		public void cancel(){
			role = usr.ANG_Portal_Service_Role__c;
			accessStatus = usr.Right__c;			
			editMode = false;
		}
		
		public void save(){
	    	ctrl.pageController.resetMessage();
			String templateName = '';

			String replaceStr = '%FIRST_NAME%!' + usr.Contact__r.FirstName + '|' +
								'%LAST_NAME%!' + usr.Contact__r.LastName + '|' +
								'%ICCS_ROLE%!' + usr.ANG_Portal_Service_Role__c;

			// Check what has changed to determinate the notification template to use
			
			System.debug('accessStatus : ' + accessStatus);
			System.debug('usr.Right__c : ' + usr.Right__c);
			
			// Case 1 : Access updated
			if(usr.Right__c != accessStatus){
				if(accessStatus == ISSP_ICCS_Utils.ACCESS_GRANTED){
					templateName = ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_ACCESS_GRANTED);
				}
				else if(accessStatus == ISSP_ICCS_Utils.ACCESS_DENIED && usr.Right__c == ISSP_ICCS_Utils.ACCESS_GRANTED){
					templateName = ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_ACCESS_REVOKED);
				}
				else if(accessStatus == ISSP_ICCS_Utils.ACCESS_DENIED && usr.Right__c == ISSP_ICCS_Utils.ACCESS_REQUESTED){
					templateName = ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_ACCESS_DENIED);
				}
			}
			// Case 2 : Only role was updated. A notification is sent only if the access status is 'Access Granted'
			else if(usr.ANG_Portal_Service_Role__c != role && usr.Right__c == ISSP_ICCS_Utils.ACCESS_GRANTED){
				templateName = ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_NAMES_MAP.get(ISSP_ICCS_Utils.ICCS_NOTIFICATION_TEMPLATE_UPGRADE_ACCEPTED);
			}

			// Update the Portal user Access record
			usr.ANG_Portal_Service_Role__c = role;
			usr.Right__c = accessStatus;
			if(usr.New_Role_Requested__c == role){
				usr.New_Role_Requested__c = null;
			}
			update usr;
				
			// If a notification has to be sent, do it
			if(templateName != ''){
				ISSP_ICCS_Utils.createNotification(templateName, replaceStr, new List<Portal_Application_Right__c>{usr});
			}			

			editMode = false;

			ctrl.wrappedUsersList = null;
		}
	}
}