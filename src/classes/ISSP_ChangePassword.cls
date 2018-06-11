public with sharing class ISSP_ChangePassword {
    
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
    User provUser;

     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    // 1ID
    public Boolean isOneId { get{ return ApexPages.currentPage().getURL().contains('OneId');}}
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
        provUser = new User();         
        errorMessage = new list<string>();
        integer passwordDays = integer.ValueOF(ISSP_CS__c.getValues('PasswordResetPeriod').value__c);
        List <User> userList = [SELECT Id, UID__c, LastPasswordChangeDate, Email
                                FROM User WHERE Id = :UserInfo.getUserId()];
        if (!userList.isEmpty()){
            if (userList[0].UID__c != '' && userList[0].UID__c != null){
                tempPass = true;
            }
            else if (userList[0].LastPasswordChangeDate != null){
                system.debug('LastPasswordChangeDate: ' + userList[0].LastPasswordChangeDate);
                system.debug('LastPasswordChangeDate addDays: ' + userList[0].LastPasswordChangeDate.addDays(passwordDays));
                system.debug('LastPasswordChangeDate now: ' + system.now());
                //if (userList[0].LastPasswordChangeDate.addMinutes(10) < system.now() && userList[0].Email == 'tiago.ferreira+newportal_01_01@kerensen.com'){
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
            /*
            if (currentPassword == null || currentPassword == '')
                errorMessage.add(Label.ISSP_CurrentPasswordMandatory);
            if (newPassword == null || newPassword == '')
                errorMessage.add(Label.ISSP_NewPasswordMandatory);
            if (confirmNewPassword == null || confirmNewPassword == '')
                errorMessage.add(Label.ISSP_ConfirmPasswordMandatory);
            if (newPassword != confirmNewPassword)
                errorMessage.add(Label.ISSP_PasswordMatch);
              */  
            if (errorMessage.size() > 0) {
                return null;
            }
            else {
                
                if(serviceName == 'FRED' && termsAndConditionChecked == false){
                    errorMessage.add(Label.ISSP_Accept_Terms_Warning);
                    fredError = true;
                }
                
                if(fredError == false){ //this will prevent that the password change when we miss the Accept Terms and Condition
                    pageRef = Site.changePassword(newPassword, confirmNewPassword, currentPassword);               
                }
                else{
                    pageref = null;
                }
                
                if(pageRef == null && newPassword == confirmNewPassword && Test.isRunningTest())
                {                    
                    pageRef = new PageReference('/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam);
                    
                }
                
                if (pageRef != null){
                    if (tempPass){                        
                        updateUsers();
                        if(serviceName == 'ISSP' || !isOneId){
                            pageRef = new PageReference('/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam);
                        }
                        else if(serviceName == 'FRED'){                            
                            pageRef = null;   
                        }
                        else{
                            pageref = new PageReference(OneIdUtils.getSiteCompleteUrl() +'/s?'+serviceNameParam);
                        } 
                    }else if(!isOneId){
                        pageRef = new PageReference('/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam);
                    }
                }
                else{
                    List <ApexPages.Message> allMessages = ApexPages.getMessages();
                    for (ApexPages.Message thisMessage : allMessages){
                        //system.debug('detail message: ' + thisMessage.getDetail());
                        //system.debug('summary message: ' + thisMessage.getSummary());
                        //system.debug('label message: ' + thisMessage.getComponentLabel());
                        //system.debug('severity message: ' + thisMessage.getSeverity());
                        //system.debug('message: ' + thisMessage);
                        errorMessage.add(thisMessage.getSummary());

                    }                    
                    errorMessage.add(Label.ISSP_Old_Passwords);
                    fredError = false;

                    //errorMessage.add(Label.ISSP_InvalidPassword);
                }
                
                if(errorMessage.isEmpty() && serviceName == 'FRED'){
                    statusPoller = true;
                    provisioning();
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
    }

    public Pagereference getCheckProvisioning(){
        
        PageReference pageRef;
        provUser = [Select Id, Username, LastLoginDate,UID__c, ByPassValidationRule__c from user where id =:UserInfo.getUserId()];
        system.debug('aqui provUser.ByPassValidationRule__c ' +provUser.ByPassValidationRule__c + ' statusPoller ' + statusPoller);
        if(provUser.ByPassValidationRule__c == false){
            statusPoller = true;
            pageRef = null;            
        }else{
            statusPoller = false;
            pageRef = new PageReference('https://barney.aws-sword.net/security/sf/login');                        
        }

        return pageRef;
    } 
}
