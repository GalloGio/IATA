/*
	Class Name: ISSP_AMC_Home
	Related Classes:

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_Home.page

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	João Ferreira		25-10-2018   	INITIAL DEVELOPMENT
*/
public with sharing class ISSP_AMC_Home {
    public String displayLanguage {get; set;}
   
    public Contact con {get; set;}

    
    //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

    public string UserLanguage { get { return UserInfo.getLanguage(); }}

    public ISSP_AMC_Home() {

        popContact();  //Get the contact details of currently logged in user

        displayLanguage = UserInfo.getLanguage();
    }

    private void popContact() {
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        system.debug('user.ContactId ' + user.ContactId);
        con = DAL_ISSP.getContact(user.ContactId);
    }
}