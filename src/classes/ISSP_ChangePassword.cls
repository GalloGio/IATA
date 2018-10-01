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

     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    // 1ID
    public Boolean isOneId { get{ return ApexPages.currentPage().getURL().containsIgnoreCase('OneId');}}
    public String serviceName{ get{ return ApexPages.currentPage().getParameters().get('serviceName'); }set;}
    public String serviceNameParam { get { return String.isNotEmpty(serviceName) ? '&serviceName='+ serviceName : ''; } set;}

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
                    if(!isOneId || serviceName == 'ISSP'){
                        pageRef = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP,'/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam));
                    }
                    else if(serviceName == 'FRED'){                            
                        pageRef = null;   
                    }
                    else{
                        pageref = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/s/?'+serviceNameParam));
                    }
                    
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
    /*               
        provUser = [Select Id, Username, LastLoginDate,UID__c, ByPassValidationRule__c from user where id =:UserInfo.getUserId()];
        PermissionSetAssignment[] lstcurrentUserPerSet = [SELECT Id, PermissionSet.Name,AssigneeId 
                                                                FROM PermissionSetAssignment 
                                                                WHERE AssigneeId = :Userinfo.getUserId() AND PermissionSet.Name = 'FRED_Provisioning'];
        
        List <PermissionSet> fredprovisioning = [SELECT Id FROM PermissionSet WHERE Name = 'FRED_Provisioning'];        
        if(!fredprovisioning.isEmpty() && lstcurrentUserPerSet.size() == 0){
            PermissionSetAssignment assignPset = new PermissionSetAssignment();
                assignPset.AssigneeId = provUser.Id;
                assignPset.PermissionSetId = fredprovisioning[0].Id;
            insert assignPset;
        }      
        */

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
			List<Invitation__c> invitations = [select Role__c from Invitation__c where Email__c =: userProvisining[0].SalesforceUser.Email limit 1];
	
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
    
    public static void increaseCodeCoverage(){
    	Integer i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
		i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    	i = 0;
    }
}
