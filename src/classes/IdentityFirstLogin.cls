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
            
            list<User> us;
            system.debug('IN FIRST LOGIN');
            PageReference pageRef = new PageReference(data);
            system.debug('ApexPages.currentPage() ' + ApexPages.currentPage());
            String parameters = pageRef.getParameters().get('c');
            system.debug('PARAMETERS 1: ' + parameters);
            parameters =  Encodingutil.urlDecode( Comm_User_Helper.DecryptString(parameters),'UTF-8') ;
            system.debug('PARAMETERS 2: ' + parameters);
            list<string> paramList =  parameters.split(Comm_User_Helper.SEPARATOR,-1);
            userName = paramList[0];
            userName = userName.replace(Comm_User_Helper.plusReplacer, '+');
            passWord = paramList[1];
            string UID = paramList[2];
            system.debug('userName: ' + userName);
            system.debug('passWord: ' + passWord);
            system.debug('UID: ' + UID);
            
            if (!String.isEmpty(userName)) {
                
                us = [Select Id, Username, LastLoginDate,UID__c from user where username =:userName OR email =:userName  ];               
                
                if(us<> null && us.size()>0){
                    system.debug('USER NOT NULL: ' + us[0].UID__c);
                    if(us[0].UID__c == UID){
                        system.debug('SAME AS UID');
                        ids = us[0].id;
                        
                        updateUsers(ids);
                        
                        if(!test.isRunningTest()){
                            //ApexPages.PageReference lgn = Site.login(userName, passWord, '/identity/s/changePassword');
                            aura.redirect(Site.login(userName, passWord, (String.isEmpty(OneIdUtils.getCommunityUrlName()) ? '' :'/' + OneIdUtils.getCommunityUrlName()) + '/s/changePassword'));
                        }
                    } else {
                        if(!test.isRunningTest()){
                            //ApexPages.PageReference lgn = new PageReference('/identity/s');
                        	aura.redirect(new PageReference((String.isEmpty(OneIdUtils.getCommunityUrlName()) ? '' :'/' + OneIdUtils.getCommunityUrlName()) + '/s'));
                        }
                    }
                }
            }
            
        }catch(Exception ex){
            return 'ERROR!';
        }
        return 'finish';
    }
    
    @TestVisible
    @future
    private static void updateUsers(id UsersID){
        user us = [Select Id, Username, LastLoginDate,UID__c from user where id =:UsersID  ];     
        us.uid__c ='';
        if(!test.isRunningTest())update us;  
    }
}