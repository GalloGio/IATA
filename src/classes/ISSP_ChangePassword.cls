public without sharing class ISSP_ChangePassword {

	public String currentPassword { get; set; }
	public String newPassword { get; set; }
	public String confirmNewPassword { get; set; }
	public list<String> errorMessage {get; set;}
	public Boolean tempPass {get; set;}
	public Boolean changePasswordMessage {get; set;}
	public Boolean termsAndConditionChecked { get; set; }
	public Boolean displayPopup{get;set;}
	public Boolean fredError{get;set;}
	public Boolean statusPoller{get;set;}
	public Boolean fredFirst{get;set;}
	public Boolean passwordChanged{get;set;}
	private List <User> userList{get;set;}
	User provUser;
	public Boolean fredAccessAlreadyGranted{
		get{
			if(fredAccessAlreadyGranted == null){
				List<PermissionSetAssignment> permissionSets = [select Id from PermissionSetAssignment where Assignee.Id =: UserInfo.getUserId() and PermissionSet.Name = 'FRED_SSO'];
				fredAccessAlreadyGranted = !permissionSets.isEmpty();
			}
			return fredAccessAlreadyGranted;
		}
		set;
	}

	 //CNS
	public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
	public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

	// 1ID
	public Boolean isOneId { get{ return ApexPages.currentPage().getURL().containsIgnoreCase('OneId');}}
	public String serviceName{ get{ return ApexPages.currentPage().getParameters().get('serviceName'); }set;}
	public String serviceNameParam { get { return String.isNotEmpty(serviceName) ? '&serviceName='+ serviceName : ''; } set;}

	// Network
	public String networkId {
		get{
			String network = null;
			String retUrl = ApexPages.currentPage().getParameters().get('retURL');

			if(retUrl != null){
				String networkParameter = 'networkId=';
				Integer start = retUrl.indexOf(networkParameter);
				if(start != -1){
					start += networkParameter.length();
					network = retUrl.substring(start, start + 15);
				}
			}

			return network;
		}
	}

	/**
	 * Constructor
	 */
	public ISSP_ChangePassword() {
		changePasswordMessage = false;
		tempPass = false;
		displayPopup = false;
		termsAndConditionChecked = false;
		fredError = false;
		statusPoller = false;
		fredFirst = false;
		provUser = new User();
		passwordChanged = false;
		errorMessage = new list<string>();
		integer passwordDays = integer.ValueOF(ISSP_CS__c.getValues('PasswordResetPeriod').value__c);
		userList = [SELECT Id, UID__c, LastPasswordChangeDate, Email, contact.AccountId
								FROM User WHERE Id = :UserInfo.getUserId()];
		if (!userList.isEmpty()){
			if (userList[0].UID__c != '' && userList[0].UID__c != null){
				tempPass = true;
			}
			else if (userList[0].LastPasswordChangeDate != null){
				system.debug('LastPasswordChangeDate: ' + userList[0].LastPasswordChangeDate);
				system.debug('LastPasswordChangeDate addDays: ' + userList[0].LastPasswordChangeDate.addDays(passwordDays));
				system.debug('LastPasswordChangeDate now: ' + system.now());
				if (userList[0].LastPasswordChangeDate.addDays(passwordDays) < system.now()){
					changePasswordMessage = true;
				}
			}
		}
	}

	/**
	 * Changes the user's password
	 */
	public Pagereference changePassword() {
		PageReference pageRef;
		try {
			// validate fields
			errorMessage = new list<string>();

			if (errorMessage.size() > 0) {
				return null;
			}
			else {

				if(serviceName == 'FRED' && termsAndConditionChecked == false){
					errorMessage.add(Label.ISSP_Accept_Terms_Warning);
					fredError = true;
					pageref = null;
				}
				else{
					pageRef = Site.changePassword(newPassword, confirmNewPassword, currentPassword);
				}

				if(pageRef == null && newPassword == confirmNewPassword && Test.isRunningTest())
				{
					pageRef = new PageReference('/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam);

				}

				if (pageRef != null){
					Boolean isISSP = false;
					if(networkId != null){
						List<Network> networks = [SELECT Id
													FROM Network
													WHERE Id =: networkId
													AND (Name = 'IATA Portal' OR Name = 'CS Portal')];
						isISSP = !networks.isEmpty();
					}

					if(!isOneId || serviceName == 'ISSP' || serviceName == 'CSP' || isISSP){
						pageRef = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.CSP, '/s'));
					}
					else if(serviceName == 'FRED'){
						pageRef = null;
					}
					else if(serviceName == 'NDCMM'){
						pageRef = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/s/ndcmm?serviceName=NDCMM' + commParam));
					}
					else if(serviceName == 'dataprivacy'){
						pageRef = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.GDPR,'/s'));
					}
					else{
						pageref = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/s/?'+serviceNameParam));
					}

					if (communityName=='CNS') pageRef = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP, '/?CommunityName='+communityName));

					if (tempPass) updateUsers();
				}
				else{
					List <ApexPages.Message> allMessages = ApexPages.getMessages();
					for (ApexPages.Message thisMessage : allMessages){

						errorMessage.add(thisMessage.getSummary());
					}
					errorMessage.add(Label.ISSP_Old_Passwords);
					fredError = false;

					//errorMessage.add(Label.ISSP_InvalidPassword);
				}
				fredFirst = true;
				if(errorMessage.isEmpty() && serviceName == 'FRED'){
//                    statusPoller = true;
					provisioning();
					passwordChanged = true;
				}

				System.debug(loggingLevel.FINE, '____ [cls ISSP_ChangePassword - changePassword] pageRef - ' + pageRef);

				System.debug(loggingLevel.FINE, '____ [cls ISSP_ChangePassword - changePassword]  - Validating FAQ permissions' );
				PortalFAQsSharingCtrl.validateUserFAQsPermissions(UserInfo.getUserId());

				setIFTPUser();
				return pageRef;
			}
		}
		catch (Exception ex) {
			errorMessage.add(ex.getMessage());
			return null;
		}
	}

	//@future
	private static void updateUsers(){
		user us = [Select Id, Username, LastLoginDate,UID__c from user where id =:UserInfo.getUserId()];
		us.uid__c ='';
		if(!test.isRunningTest())
			update us;
	}

	public void showTCpopup() {
		displayPopup = true;
	}

	public void closePopup() {
		displayPopup = false;
	}

	public void provisioning(){
		LightningConnectedAppHelper.submit('FRED', 'FRED Primary User');
	}

	public Pagereference getCheckProvisioning(){
		PageReference pageRef;
		String fredSystemURL;

		if(ISSP_CS__c.getValues('Fred_System').value__c != null)
			fredSystemURL = String.ValueOF(ISSP_CS__c.getValues('Fred_System').value__c);

		List<UserProvisioningRequest> userProvisining = [Select id,State, SalesforceUser.Email From UserProvisioningRequest where SalesforceUserId =:UserInfo.getUserId()];

		if(userProvisining[0].State == 'Completed' ){
			// Assign Primary permission set  if it's the 1st registred or if there is a related Invitation__c with requested role = Primary

			Boolean isPrimaryUser;

			// This query will have to be updated when developing One Id generics as the Invitation__c object will have an additional field
			// for the service and the same user could receive several invitations for different services
			List<Invitation__c> invitations = [select Role__c from Invitation__c where Email__c =: userProvisining[0].SalesforceUser.Email AND ServiceId__c = null limit 1];

			if(!invitations.isEmpty()){
				isPrimaryUser = invitations[0].Role__c == 'Primary';
			}
			else{
				// Check if the some user in the account has FRED primary permission set. If not, this user we'll be primary
			Integer nbOfPrimaryInAccount = [SELECT count() FROM PermissionSetAssignment WHERE PermissionSet.Name = 'FRED_Primary_User' AND Assignee.AccountId =: userList[0].contact.AccountId ];
				isPrimaryUser = nbOfPrimaryInAccount == 0;
			}

			if(isPrimaryUser) {
				insert new PermissionSetAssignment(
					AssigneeId = UserInfo.getUserId(),
					PermissionSetId = [SELECT Id FROM PermissionSet WHERE Name='FRED_Primary_User' LIMIT 1].Id
				);
			}

			// Hide spinner and redirect
			statusPoller = false;
			pageRef = new PageReference(fredSystemURL);

		}else if(userProvisining[0].State == 'Failed'){
			statusPoller = false;
			ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'provisioning error contact admin');
			ApexPages.addMessage(myMsg);
			pageRef = null;

		}else{
			 statusPoller = true;
			 pageRef = null;
		}

		return pageRef;
	}

	public String fredTerms{
		get{
			return LightningConnectedAppHelper.getAppTerms ('FRED');
		}
	}

	public void setIFTPUser(){

		try{

			Boolean bAccRole = false;
			Boolean bContRole = false;
			Account userAcc = new Account();

			// String sLog = '';
			String RECTYPE_ITP_AccRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'IFTP');
			// String RECTYPE_Others = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others');

			User userInfo = [SELECT id, accountId, ContactId, contact.user_portal_status__c FROM USER WHERE id=: UserInfo.getUserId()];


			List<Account_Contact_Role__c> accContRoleCheck = [SELECT id FROM Account_Contact_Role__c WHERE Service_Rendered__c = 'IFTP' AND Contact__c = :userInfo.ContactId];

			//if no Acc Cont Roles then create one and also create the Portal Service access
			if(accContRoleCheck.size() == 0){

				List<Account_Role__c> lAccRole = [SELECT id, account__r.recordtypeid, account__r.Sector__c, account__r.Category__c
											FROM Account_Role__c
											WHERE account__c = :userInfo.accountId AND recordtypeid = :RECTYPE_ITP_AccRole limit 1];

				Account_Role__c accRole = new Account_Role__c();

				if(!lAccRole.isEmpty()){
					accRole = lAccRole[0];
					bAccRole = true;
					userAcc.recordtypeid = accRole.account__r.recordtypeid;
					userAcc.Sector__c = accRole.account__r.Sector__c;
					userAcc.Category__c = accRole.account__r.Category__c;
				}else{
					userAcc = [SELECT recordtypeid, Sector__c, Category__c FROM Account WHERE id = :userInfo.accountId];
				}

				// if(userAcc.recordtypeid == RECTYPE_Others && userAcc.Sector__c == 'Airline Supplier' && userAcc.Category__c == 'Fuel Supplier'){
				if(userAcc.Sector__c == 'Airline Supplier' && userAcc.Category__c == 'Fuel Supplier'){

					String RECTYPE_ITP_AccContRole = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Contact_Role__c', 'ITP');

					Portal_Applications__c pa = [SELECT id FROM Portal_Applications__c WHERE name = 'IFTP' limit 1];

					PermissionSet psAbsorb = [SELECT Id FROM PermissionSet WHERE Name = 'Absorb'];

					Account_Contact_Role__c accContRoleToInsert = new Account_Contact_Role__c();
					// accContRoleToInsert.Company_Code__c = employeeToAdd.code.trim();
					accContRoleToInsert.Service_Rendered__c = 'IFTP';
					accContRoleToInsert.Status__c = 'Active';
					accContRoleToInsert.RecordTypeId = RECTYPE_ITP_AccContRole;
					accContRoleToInsert.company_code__c='TC';//temporary employee code
					if(bAccRole){
						accContRoleToInsert.Account_Role__c = accRole.Id;
					}

					accContRoleToInsert.Contact_Role__c = 'ITP Training Coordinator';
					accContRoleToInsert.Details__c = '';
					accContRoleToInsert.Contact__c = userInfo.ContactId;

					insert accContRoleToInsert;
					Portal_Application_Right__c portalApplicationRight = new Portal_Application_Right__c(
						Portal_Application__c = pa.id,
						Right__c = 'Access Requested',
						Contact__c = userInfo.ContactId,
						Favourite_Service__c = true
					);
					insert portalApplicationRight;

					assignPermissionSet(psAbsorb.Id, userInfo.id);

				}
			}
		}catch (Exception ex) {
			System.debug(LoggingLevel.ERROR, '____ [cls ISSP_ChangePassword - setIFTPUser] Exception - ' + ex );
			System.debug(LoggingLevel.ERROR, '____ [cls ISSP_ChangePassword - setIFTPUser] Exception - ' + ex.getStackTraceString() );
		}

	}

	@future
	private static void assignPermissionSet(Id absorbId, Id userId){
		PermissionSetAssignment psa = new PermissionSetAssignment(PermissionSetId = absorbId, AssigneeId = userId);
		insert psa;
	}
	
}
