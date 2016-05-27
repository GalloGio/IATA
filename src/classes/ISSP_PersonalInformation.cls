public with sharing class ISSP_PersonalInformation {
    public Contact con {get;set;}
    public string noirr {get;private set;}
    public boolean showIrregularities {get;private set;}    
    public String cardDate {get; set;}
    public String cardNumber {get; set;}
    public String myFunction {get; set;}
    public boolean isIATAAgencyAcct {get;set;}
    public boolean isIATAAirlineAcct {get;set;}
    public String FinSubmission{get; set;}
    public Boolean isEditMode {get; set;}
    public String OpenDebts{get; set;}
    public String accountCountryISOCode {get; set;}
    //If the user is admin and already opt-out, optin option will be visible
    public boolean bIsAdmin				{get; set;}		//identify if a user is administrator or not
    public boolean bIsOSCARenabled {get; set;} 
    public boolean bIsMinorChangeEnabled {get; set;} //Hide edit buttons on Company Info page if Country for Agencies is not pointing to OSCAR
    public boolean bBlockTradeNameChange {get; set;}
    public boolean isHOAccredited {get;set;}
    
	//Global Variables
	public String UserPortalStatus {get;set;}
	public String UserPortalAccountSector {get;set;}
	public boolean isValidatedAirlineUser {get;set;}
	public String ValidatedAirlineUser_Str {get;set;}
	
	public Boolean hasIdCard {get;set;}
    
    public List<AccountTeamMember> portalAdmins { 
        get {
            if(null == portalAdmins)
                portalAdmins = new list<AccountTeamMember>();
            return portalAdmins;
        }
        set;
    }
    public map<ID, AccountTeamMember> portalAdminMap { 
        get{
            if(null == portalAdminMap)
                portalAdminMap = new map<ID, AccountTeamMember>();
            return portalAdminMap;
        }
        set;
    }
    
    public string iataCode {get;set;}
    public string accountType {get;private set;}
    public list<String> errorMessage {get; set;}
    
    
    public ISSP_PersonalInformation(){ 
    	hasIdCard = false;
    	bIsAdmin = false;
        bIsOSCARenabled = false;
        bIsMinorChangeEnabled = false;
        bBlockTradeNameChange = false;
        isHOAccredited = false;
        
    	String confirmParameter = ApexPages.currentPage().getParameters().get('confirm');
    	system.debug('confirmParameter: ' + confirmParameter);
    	if (confirmParameter == 'yes'){
    		isEditMode = true;
    	}
    	else{
    		isEditMode = false;
    	}
    	system.debug('isEditMode: ' + isEditMode);
        
        errorMessage = new list<string>();  
        popContact();
        accountType=' Company ';

        if (con.Account.Top_Parent__c == null) { //User is from HQ  Account
            if(con.Account.IATACode__c!=null && con.Account.Location_Type__c=='HO' && con.Account.RecordType.DeveloperName=='IATA_Agency' && con.Account.Status__c=='Approved')
                isHOAccredited = true; //This is an accredited  Agency Account    
        } else { //Get Id for HQ Account when user's Account is a branch office
             if(con.Account.Top_Parent__r.IATACode__c!=null && con.Account.Top_Parent__r.Location_Type__c=='HO' && con.Account.RecordType.DeveloperName=='IATA_Agency' && con.Account.Status__c=='Approved')
                isHOAccredited = true; //This is an accredited  Agency Account
        }
        
        OpenDebts = string.valueof(con.Account.Overdue_Invoices_Indicator__c );
        
        noirr = string.valueof(con.Account.Accumulated_Irregularities__c);
        FinSubmission  = string.valueof(con.Account.Fin_statements_submission_deadline__c);
        
        if ( (con.Account.Sector__c=='Cargo Agent' || con.Account.Sector__c=='Travel Agent') && (con.User_Portal_Status__c=='Approved Admin' || con.BSP_CASS_Payment_contact__c || con.Financial_Assessment_Contact__c)) {
                showIrregularities = True;
        }
        else {
                showIrregularities = False;
        }
        
        if (con.Account.Sector__c=='Cargo Agent' || con.Account.Sector__c=='Travel Agent')
            isIATAAgencyAcct = true;
        
        if (con.Account.Sector__c=='Airline')
            isIATAAirlineAcct = true;
        system.debug('Sfi con2 ==>  '+con);
        
        //AS - SP11
        accountCountryISOCode = con.Account.IATA_ISO_Country__r.ISO_Code__c;

		UserPortalStatus          = con.User_Portal_Status__c ;
		UserPortalAccountSector   = con.Account.sector__c;
		isValidatedAirlineUser = false ;
		setValidatedAirlineUser();
		if (UserPortalAccountSector == 'Airline' && (UserPortalStatus == 'Approved User' || UserPortalStatus == 'Approved Admin'))
		{
			isValidatedAirlineUser = true ;
		}
       
        //AEF: portalAdmins is filled in extensions controller ISSP_PersonalInformationWithoutSharing 
    }
    
    private void popContact(){
        User user = DAL_ISSP.getUser(Userinfo.getUserId());
        con = DAL_ISSP.getContact(user.ContactId);
        if (con.ID_Card_Holder__c){
        	hasIdCard = true;
        }
        system.debug('Sfi con ==>  '+con);
        List <ID_Card__c> cardList = [SELECT Id, VER_Number__c, Valid_To_Date__c FROM
                                    ID_Card__c WHERE Related_Contact__c = :user.ContactId
                                    AND Is_Active_Card__c = :true
                                    ORDER BY Valid_To_Date__c DESC];
        if (!cardList.isEmpty()){
            cardNumber = cardList[0].VER_Number__c;
            cardDate = cardList[0].Valid_To_Date__c.format();
        }
        if (con.Membership_Function__c != '' && con.Membership_Function__c != null){
            myFunction = con.Membership_Function__c.replace(';', '<br/>');  
        }
        
        //DDS
        if(con.User_Portal_Status__c == 'Administrator' || con.User_Portal_Status__c == 'Approved Admin' || con.User_Portal_Status__c == 'Regional Administrator' || con.User_Portal_Status__c == 'R. Administrator' )
        	bIsAdmin = true;
        
        bIsOSCARenabled = con.Account.IATA_ISO_Country__r.OSCAR_enabled__c;
        bIsMinorChangeEnabled = con.Account.IATA_ISO_Country__r.Enable_Minor_Changes_from_Portal__c;
        bBlockTradeNameChange = con.Account.IATA_ISO_Country__r.Prevent_Portal_Trade_Name_Change__c;
    }
    
    /*public void save(){
        try {
        	isEditMode = false;
        	update con;  
        	popContact();    
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);   

        }
    }*/

    public List<ISSP_AMS_Accreditation.AccountChanges> getAccountChangesList(){
        List<ISSP_AMS_Accreditation.AccountChanges> accChanges_List = new List<ISSP_AMS_Accreditation.AccountChanges>();

        Account acc = [Select Phone,PhoneNational__c,Fax,FaxNational__c,Email__c,TradeName__c,WebSite From Account Where id=:con.Account.Id limit 1];

        if(acc.Phone != con.Account.Phone)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('Phone',acc.Phone,con.Account.Phone));

        if(acc.PhoneNational__c != con.Account.PhoneNational__c)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('PhoneNational__c',acc.PhoneNational__c,con.Account.PhoneNational__c));

        if(acc.Fax != con.Account.Fax)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('Fax',acc.Fax,con.Account.Fax));

        if(acc.FaxNational__c != con.Account.FaxNational__c)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('FaxNational__c',acc.FaxNational__c,con.Account.FaxNational__c));

        if(acc.Email__c != con.Account.Email__c)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('Email__c',acc.Email__c,con.Account.Email__c));

        if(acc.TradeName__c != con.Account.TradeName__c)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('TradeName__c',acc.TradeName__c,con.Account.TradeName__c));
        
        if(acc.WebSite != con.Account.WebSite)
            accChanges_List.add(new ISSP_AMS_Accreditation.AccountChanges('WebSite',acc.WebSite,con.Account.WebSite));
        
        return accChanges_List;
    }
	
	public Pagereference saveContact(){
        try {
        	isEditMode = false;
        	update con;
        	popContact();  
        	Pagereference homePage = Page.ISSP_Homepage;
        	homePage.setRedirect(true); 
        	return homePage;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            return null;   
        }
    }

    public Pagereference saveAccount(){
        try {
            isEditMode = false;
            if(isHOAccredited && bIsMinorChangeEnabled){
                ISSP_AMS_Accreditation.callToMinorChangesWS(ISSP_AMS_Accreditation.getWSInstance(),con.Account.Id,getAccountChangesList());
            }
            update con.Account;
            popContact();  
            Pagereference homePage = Page.ISSP_Homepage;
            homePage.setRedirect(true); 
            return homePage;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            return null;   
        }
    }
    
    public Pagereference saveNewCompanyName(){
        errorMessage.clear();
        list<Account> accList = [select Id,IATACode__c from Account where IATACode__c=:iataCode];
        if(accList.size()>0){
            con.AccountId = accList.get(0).Id;
            update con;
            popContact();
        }else{
            errorMessage.add('IATA Code Not Exists');
        }
        return null;
    }
    public map<string,string> getPicklistValues(){
      map<string,string> options = new map<string,string>();
      map<String, Schema.SObjectField> fieldMap = Schema.SObjectType.Contact.fields.getMap();
      // Get the list of picklist values for this field.
      list<Schema.PicklistEntry> values =
         fieldMap.get('Membership_Function__c').getDescribe().getPickListValues();
      // Add these values to the selectoption list.
      for (Schema.PicklistEntry a : values)
      { 
         if(a.isActive() )options.put(a.getLabel(), a.getValue()); 
      }
      return options;
    }
    
    public Pagereference AssignIFAPContact(){
        Pagereference p  = new Pagereference ('/ISSP_AssignFinancialContact?id='+ con.AccountId + '&MainNav=Services&subNav=Access&mid=M4S2');
        p.setredirect(true);
        return p;
      return null;
    }

	private void setValidatedAirlineUser (){
		ValidatedAirlineUser_Str = '' ;
		List<Contact> Contact_List = new List<Contact>([select Id ,Name ,Airline_Credit_Risk_Manager__c From Contact Where AccountId =: con.AccountId]);

		if (Contact_List != null & !Contact_List.isEmpty())
		{
			for (Contact con : Contact_List)
			{
				if (con.Airline_Credit_Risk_Manager__c == true)
				{
					ValidatedAirlineUser_Str += con.Name +' ,';
				}
			}
			ValidatedAirlineUser_Str = ValidatedAirlineUser_Str != '' ? ValidatedAirlineUser_Str.substring(0,ValidatedAirlineUser_Str.length()-1) : '';
		}
	}
}