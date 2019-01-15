public class IdentityFirstLogin {
    
    
    private static string userName {get;set;}
    private static string passWord {get;set;}
    
    
    public class CountryConfigException extends Exception {}
    
    public IdentityFirstLogin(){
    }
    
    @AuraEnabled
    public static string checkLogin(String data){
        string ids = '';
        try{
            
            PageReference pageRef = new PageReference(data);
            String parameters = pageRef.getParameters().get('c');
            String serviceName = pageRef.getParameters().get('serviceName');
            String serviceNameParam = String.isNotEmpty(serviceName) ? 'serviceName='+serviceName : '';
            
            parameters =  Encodingutil.urlDecode( Comm_User_Helper.DecryptString(parameters),'UTF-8') ;
            system.debug('PARAMETERS 2: ' + parameters);
            List<String> paramList =  parameters.split(Comm_User_Helper.SEPARATOR,-1);
            userName = paramList[0];
            userName = userName.replace(Comm_User_Helper.plusReplacer, '+');
            passWord = paramList[1];
            string UID = paramList[2];
            system.debug('userName: ' + userName);
            system.debug('passWord: ' + passWord);
            system.debug('UID: ' + UID);
            
            if (!String.isEmpty(userName)) {
                
                List<User> us = [Select Id, Username, LastLoginDate,UID__c from user where username =:userName OR email =:userName  ];               
                
                if(us<> null && us.size()>0){
                    system.debug('USER NOT NULL: ' + us[0].UID__c);
                    if(us[0].UID__c == UID){
                        system.debug('SAME AS UID');
                        ids = us[0].id;
                        
                        //updateUsers(ids);
                        
                        if(!test.isRunningTest()){
                            //ApexPages.PageReference lgn = Site.login(userName, passWord, '/identity/s/changePassword');
                            aura.redirect(Site.login(userName, passWord, OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/OneId_ChangePassword?'+serviceNameParam)));
                        }
                    } else {
                        if(!test.isRunningTest()){
                            //ApexPages.PageReference lgn = new PageReference('/identity/s');
                            if(serviceName == 'ISSP'){
                                aura.redirect(new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP,'/ISSP_Home')));
                            }else if(serviceName == 'GDPR') {
                                aura.redirect(new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.ISSP,'/gdprportal')));
                            }else{
                                aura.redirect(new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/s/?'+serviceNameParam)));
                            }
                        }
                    }
                }
            }
            
        }catch(Exception ex){
            return 'ERROR!';
        }
        return 'finish';
    }
    
    /*@TestVisible
    @future
    private static void updateUsers(id UsersID){
        user us = [Select Id, Username, LastLoginDate,UID__c from user where id =:UsersID  ];     
        us.uid__c ='';
        if(!test.isRunningTest())update us;  
    }*/
}