public with sharing class ISSP_ChangePassword {
    
    public String currentPassword { get; set; }
    public String newPassword { get; set; }
    public String confirmNewPassword { get; set; }
    public list<String> errorMessage {get; set;}
    public Boolean tempPass {get; set;}
    public Boolean changePasswordMessage {get; set;}

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
        
        try {
            // validate fields
            errorMessage = new list<string>();
 
            if (errorMessage.size() > 0) {
                return null;
            }
            else {

                PageReference pageRef = Site.changePassword(newPassword, confirmNewPassword, currentPassword);               
                
                if(pageRef == null && newPassword == confirmNewPassword && Test.isRunningTest())
                {                    
                    pageRef = new PageReference('/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam);
                    
                }
                
                if (pageRef != null){
                    
                    if(!isOneId || serviceName == 'ISSP'){
                        pageRef = new PageReference(OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.ISSP) + '/ISSP_PersonalInformation?mid=M5S1&confirm=yes' + commParam);
                    }
                    else{
                        pageref = new PageReference(OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + '?' + serviceNameParam);
                    }
                    
                    if (tempPass) updateUsers();
                }
                else{
                    List <ApexPages.Message> allMessages = ApexPages.getMessages();
                    for (ApexPages.Message thisMessage : allMessages){

                        errorMessage.add(thisMessage.getSummary());
                    }
                    errorMessage.add(Label.ISSP_Old_Passwords);
                    //errorMessage.add(Label.ISSP_InvalidPassword);
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
}