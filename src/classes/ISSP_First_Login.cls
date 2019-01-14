public without sharing class  ISSP_First_Login{

   	private string userName {get;set;}
   	private string passWord {get;set;}
   	private boolean logMeIn {get;set;}
   	private User u {get;set;}
	public string ids = '';

     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

	public ISSP_First_Login(){
           
   // u = new User();        
    logMeIn = false;
            
    try{
    	
    	ISSP_Login theCtrl = new ISSP_Login();
    	theCtrl.findLocation(false);
    	if (theCtrl.sanctionCountry){
    		logMeIn = false;
    	}
    	else{
    	
			list<User> us;
			system.debug('IN FIRST LOGIN');
			String parameters = ApexPages.currentPage().getParameters().get('c');
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
						logMeIn = true;  
						ids = us[0].id;
					}
				}
			}
    	}


         }catch(Exception ex){
         	system.debug('ERROR!');
         //   throw new transformationException('' + ex.getMessage());
              logMeIn = false;
         
         }
        
    }
    
    
    
    public PageReference DoNext(){
    	system.debug('START DONEXT');

        if(logMeIn){
        	system.debug('IS LOGMEIN');
        	return this.changePassword();
        }
        
        return this.home();

    }
    
        
	private PageReference home(){
        system.debug('GOING HOME');
	    //Pagereference pr = Page.ISSP_Login;
        //pr.setRedirect(true);
        PageReference pr = new PageReference(OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/s/login/?serviceName=ISSP'));

    	return pr;   

    }
   
    
    @TestVisible
    private PageReference changePassword(){
		system.debug('CHANGING PASS');
        //updateUsers(ids);
        Pagereference pr =  !test.isRunningTest() ? site.login(userName,passWord,OneIdUtils.getCommunityRedirection(OneIdUtils.Mode.IDENTITY,'/OneId_ChangePassword?serviceName=ISSP')): Page.ISSP_ChangePassword;
        if(CommunityName=='CNS'){
           pr =  !test.isRunningTest() ? site.login(userName,passWord,'/ISSP_ChangePassword?CommunityName=CNS'): Page.ISSP_ChangePassword; 
        }
        pr.setRedirect(true);
        return pr;   
         
	}

	@TestVisible
	@future
	private static void updateUsers(id UsersID){
            user us = [Select Id, Username, LastLoginDate,UID__c from user where id =:UsersID  ];     
            us.uid__c ='';
            if(!test.isRunningTest())update us;  
	}
    
}