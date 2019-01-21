public with sharing class ISSP_PersonalInformation {
    public Contact con {get;set;}
    public Account branchOffice{get;set;}
    public string noirr {get;private set;}
    public boolean showIrregularities {get;private set;}    
    public String cardDate {get; set;}
    public String cardNumber {get; set;}
    public String myFunction {get; set;}
    public boolean isIATAAgencyAcct {get;set;}
    public boolean isIATAAirlineAcct {get;set;}
    public boolean isIATAAgencyAcctBR {get;set;}
    public boolean isIATAAirlineAcctBR {get;set;}
    public String FinSubmission{get; set;}
    public Boolean isEditMode {get; set;}
    public Boolean isEditModeBR {get; set;}
    public String OpenDebts{get; set;}
    public String accountCountryISOCode {get; set;}
    public String accountCountryISOCodeBR {get; set;}
    public Id selectedBranchAccount {get; set;}
    //If the user is admin and already opt-out, optin option will be visible
    public boolean bIsAdmin				{get; set;}		//identify if a user is administrator or not
    public boolean bUserHO             {get; set;}     //identify if a Account is HO or not
    public boolean bIsOSCARenabled {get; set;} 
    public boolean bIsMinorChangeEnabled {get; set;} //Hide edit buttons on Company Info page if Country for Agencies is not pointing to OSCAR
    public boolean bBlockTradeNameChange {get; set;}

    public boolean bIsOSCARenabledBR {get; set;} 
    public boolean bIsMinorChangeEnabledBR {get; set;} //Hide edit buttons on Company Info page if Country for Agencies is not pointing to OSCAR
    public boolean bBlockTradeNameChangeBR {get; set;}

    public boolean isHOAccredited {get;set;}
    public boolean isTerminatedAgent {get; set;}
    public boolean isTerminatedAgentBR {get; set;}
    public boolean isCNSAccount {get; set;}
    public boolean isLegalNamePopulated {get; set;}
    private Id vHQAccountId;

     //CNS
    public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}
    public String commParam { get { if(communityName=='CNS'){ return '&CommunityName='+ communityName;} return ''; } set;}

    
	//Global Variables
	public String UserPortalStatus {get;set;}
	public String UserPortalAccountSector {get;set;}
	public boolean isValidatedAirlineUser {get;set;}
	public String ValidatedAirlineUser_Str {get;set;}
	
	public Boolean hasIdCard {get;set;}
    public boolean showIEPStatus {get;set;}
    public Boolean flagCashOptedOutFinReview {get;set;}

    public Boolean canChangeTradeName {get; private set;}
    public Boolean isNAMEnabled {get; private set;}
    public boolean isIATAAgencyCargo {get; private set;}
    public boolean isIATAAgencyTravel {get; private set;}

    public Boolean canChangeTradeNameBR {get; private set;}
    public Boolean isNAMEnabledBR {get; private set;}
    public boolean isIATAAgencyCargoBR {get; private set;}
    public boolean isIATAAgencyTravelBR {get; private set;}

    
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
    public List<Account_Domain__c> validEmailDomains {
        get {
            return AccountDomainHandler.getAccountDomains(this.con.AccountId);
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
        bUserHO = false;

        canChangeTradeName = false;
        isNAMEnabled = false;
        isIATAAgencyCargo = false;
        isIATAAgencyTravel = false;

        canChangeTradeNameBR = false;
        isNAMEnabledBR = false;
        isIATAAgencyCargoBR = false;
        isIATAAgencyTravelBR = false;

        bIsOSCARenabledBR = false;
        bIsMinorChangeEnabledBR = false;
        bBlockTradeNameChangeBR = false;
        isIATAAgencyAcctBR = false;
        isTerminatedAgent = false;
        isTerminatedAgentBR = false;
        showIEPStatus = false;
        isCNSAccount = false;
        isLegalNamePopulated = false;
        
    	String confirmParameter = ApexPages.currentPage().getParameters().get('confirm');
    	system.debug('confirmParameter: ' + confirmParameter);
    	if (confirmParameter == 'yes'){
    		isEditMode = true;
            isEditModeBR = true;
    	}
    	else{
    		isEditMode = false;
            isEditModeBR = false;
    	}
    	system.debug('isEditMode: ' + isEditMode);
        
        errorMessage = new list<string>();  
        popContact();
        accountType=' Company ';
        
        if (con.Account.Top_Parent__c == null) { //User is from HQ Account
            vHQAccountId = con.AccountId;
            bUserHO = true;
        } else {
            vHQAccountId = con.Account.Top_Parent__c;
        }

        if (communityName=='CNS') { //It is a CNS contact
            isCNSAccount = true;
        }

        //Is this user's account accredited
        if(con.Account.IATACode__c!=null && con.Account.RecordType.DeveloperName=='IATA_Agency' && con.Account.Status__c != 'Terminated' && con.Account.Status__c != 'Not accreditated' && con.Account.Status__c != 'New application pending' && con.Account.Status__c != 'No longer a customer')
        	isHOAccredited = true; //This is an accredited Agency Account    

        if(con.Account.Status__c == 'Terminated' || con.Account.Status__c == 'Not accreditated' 
                    || con.Account.Status__c == 'No longer a customer' || con.Account.Status__c == 'New application pending')
            isTerminatedAgent = true;
        
        OpenDebts = string.valueof(con.Account.Overdue_Invoices_Indicator__c );
        
        noirr = string.valueof(con.Account.Accumulated_Irregularities__c);
        FinSubmission  = string.valueof(con.Account.Fin_statements_submission_deadline__c);
        
        if ( (con.Account.Sector__c=='Cargo Agent' || con.Account.Sector__c=='Travel Agent') && (con.User_Portal_Status__c=='Approved Admin' || con.BSP_CASS_Payment_contact__c || con.Financial_Assessment_Contact__c) && getPermissionForStandardAccount() == false && (!con.Account.CNS_Account__c) && !con.Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c) {
                showIrregularities = True;
        }
        else {
                showIrregularities = False;
        }
        
        if (con.Account.Sector__c=='Cargo Agent' || con.Account.Sector__c=='Travel Agent')
            isIATAAgencyAcct = true;

        if (con.Account.Sector__c == 'Cargo Agent') isIATAAgencyCargo = true;
        if (con.Account.Sector__c == 'Travel Agent') isIATAAgencyTravel = true;
        
        if (con.Account.Sector__c=='Airline')
            isIATAAirlineAcct = true;
        system.debug('Sfi con2 ==>  '+con);

        if (con.Account.Top_Parent__r.Legal_name__c != null) {
            isLegalNamePopulated = true;
        }
        
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
        
        if(con.Account.Sector__c == AMS_UTILS.CATEGORY_TRAVEL_AGENT && (con.Account.Category__c == AMS_UTILS.CATEGORY_PASSENGER_SALES_AGENT || con.Account.Category__c == AMS_UTILS.CATEGORY_DOMESTIC_AGENT) && con.Account.IATA_ISO_Country__r.ANG_Portal_Service__c != null){
            showIEPStatus = true;
        }
       
        flagCashOptedOutFinReview = (con.Account.ANG_Accreditation_Model__c == AMS_Utils.ACCREDITATIONMODEL_CASH && con.Account.ANG_FA_Opt_out__c);

        //AEF: portalAdmins is filled in extensions controller ISSP_PersonalInformationWithoutSharing

        canChangeTradeName = (bIsAdmin && bIsMinorChangeEnabled && !isTerminatedAgent && ((!isNAMEnabled && isIATAAgencyTravel && !bBlockTradeNameChange) || (!bBlockTradeNameChange && isIATAAgencyCargo) || (!isHOAccredited)));
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
        isNAMEnabled = con.Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c;
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

    public void cancelAccount() {
        con.Account = [SELECT Id, Name, TradeName__c, IATACode__c, Phone, PhoneNational__c, Fax, FAXNational__c, Email__c,
                            IATA_ISO_Country__r.Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry,Sector__c,
                            Category__c,Location_Type__c, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Country__r.OSCAR_enabled__c, 
                            IATA_ISO_Country__r.Enable_Minor_Changes_from_Portal__c, IATA_ISO_Country__r.Prevent_Portal_Trade_Name_Change__c,
                            Website, Status__c, IATA_ISO_Country__r.ANG_Enable_NewGen__c, RecordTypeId, RecordType.DeveloperName, DDS_Status__c,
                            Top_Parent__r.Name_on_AOC__c, Top_Parent__r.Legal_name__c
                        FROM Account 
                        WHERE Id=:con.Account.Id LIMIT 1];
    }

    public Pagereference saveAccount(){
        try {
            isEditMode = false;

            update con.Account;
            popContact();  

            return null;
        } catch (DmlException ex) {
            ApexPages.addMessages(ex);
            return null;   
        }
    }

    public Pagereference saveAccountBR(){
        try {
            isEditMode = false;
            
            update branchOffice;
            popContact();  

            return null;
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
        Pagereference p  = new Pagereference ('/ISSP_AssignFinancialContact?id='+ con.AccountId + '&MainNav=Services&subNav=Access&mid=M4S2' + commParam);
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

    /**
    * Navigate to page email domain validation (management)
    */
    public Pagereference goToEmaDomVal() {

        // Create new url
        Pagereference pageReference = new Pagereference('/ISSP_CompanyInformation_emadomval');

        // And return it
        return pageReference;

    }

    /**
        Check if current Account RT is allowed to show the Account Domain Section
    **/
    public Boolean getAccountDomainValidRT() {
        return ISSP_AccountDomainPermission__c.getInstance(this.con.Account.RecordType.DeveloperName) != null;
    }

    public List<SelectOption> getPAXBranches() {
        
        System.DeBUG('vHQAccountId for BR Accounts: ' + vHQAccountId);
        
        List<SelectOption> options = new List<SelectOption>();

        List <Account> accountList = [SELECT Id, Name, IATA_ISO_Country__r.Name, Sector__c, IATACode__c,Location_Type__c, BillingCity, BillingState, BillingCountry
                                      FROM Account
                                      WHERE Top_Parent__c = :vHQAccountId AND RecordType.DeveloperName IN ('IATA_Agency') 
                                      AND (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer', 'New application pending'))
                                              ORDER BY Name, IATACode__c
                                     ];
       
        SYSTEM.DEBUG('ALL Branch Size: ' + accountList.size());
        
        options.add(new SelectOption('', '- Select Branch Office -'));    
        for (Account thisAccount : accountList) {
            String theLabel;

            String sBillingAddress = null;

            if(thisAccount.BillingCity != null || thisAccount.BillingState != null){
                sBillingAddress = '(' +  (thisAccount.BillingCity!= null ? thisAccount.BillingCity : '') + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '')+ ')';
            }


            if(thisAccount.IATACode__c != null) {
            	//theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Location_Type__c + ' (' + thisAccount.BillingCity + (thisAccount.BillingState!= null ? ' ' + thisAccount.BillingState : '') + ')';
                
                theLabel = thisAccount.IATACode__c + ' - ' + thisAccount.Location_Type__c + ' ' + (sBillingAddress!= null ? sBillingAddress : '');
            } else {
                theLabel = thisAccount.Location_Type__c + ' ' + (sBillingAddress!= null ? sBillingAddress : '');
            }
            options.add(new SelectOption(thisAccount.Id, theLabel));    
            
        }
        return options;
    }
    
    public void getBranchOffice() {
        isTerminatedAgentBR = false;

        List<Account> bo = [SELECT Id, Name, TradeName__c, IATACode__c, Phone, PhoneNational__c, Fax, FAXNational__c, Email__c,
        					IATA_ISO_Country__r.Name, BillingStreet, BillingCity, BillingPostalCode, BillingState, BillingCountry,Sector__c,
                            Category__c,Location_Type__c, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Country__r.OSCAR_enabled__c, 
                            IATA_ISO_Country__r.Enable_Minor_Changes_from_Portal__c, IATA_ISO_Country__r.Prevent_Portal_Trade_Name_Change__c,
                            Website, Status__c, Top_Parent__r.Name_on_AOC__c, Top_Parent__r.Legal_name__c, IATA_ISO_Country__r.ANG_Enable_NewGen__c
        					FROM Account
                            WHERE Id = :selectedBranchAccount];
        
        if(bo.size() > 0) {
            branchOffice = bo[0];
            accountCountryISOCodeBR = branchOffice.IATA_ISO_Country__r.ISO_Code__c;

            bIsOSCARenabledBR = branchOffice.IATA_ISO_Country__r.OSCAR_enabled__c;
            bIsMinorChangeEnabledBR = branchOffice.IATA_ISO_Country__r.Enable_Minor_Changes_from_Portal__c;
            bBlockTradeNameChangeBR = branchOffice.IATA_ISO_Country__r.Prevent_Portal_Trade_Name_Change__c;
            isNAMEnabledBR = branchOffice.IATA_ISO_Country__r.ANG_Enable_NewGen__c;
    
            if(branchOffice.Status__c == 'Terminated' || branchOffice.Status__c == 'Not accreditated' 
                    || branchOffice.Status__c == 'No longer a customer' || branchOffice.Status__c == 'New application pending')
                isTerminatedAgentBR = true;
        
            if (branchOffice.Sector__c=='Cargo Agent' || branchOffice.Sector__c=='Travel Agent')
                isIATAAgencyAcctBR = true;

            if (branchOffice.Sector__c == 'Cargo Agent') isIATAAgencyCargoBR = true;
            if (branchOffice.Sector__c == 'Travel Agent') isIATAAgencyTravelBR = true;
            
        } else {
            branchOffice = null;
            accountCountryISOCodeBR = null;
        }

        canChangeTradeNameBR = (bIsAdmin && bUserHO && bIsMinorChangeEnabledBR && !isTerminatedAgentBR && ((!isNAMEnabledBR && isIATAAgencyTravelBR && !bBlockTradeNameChangeBR) || (!bBlockTradeNameChangeBR && isIATAAgencyCargo) || (!isHOAccredited)));
    }
    
    /**
        If the account.Quality__c field contains the id of the verfied image then is a verified account
    **/
    public Boolean getIsVerifiedAccount() {
        return this.con.Account!=null && this.con.Account.Quality__c!=null && this.con.Account.Quality__c.contains('015w0000001yCfW');
    }
    
    /**
        Return true if it is a Standard Account
    **/
    public Boolean getIsStandardAccount() {
        return this.con.Account!=null && this.con.Account.RecordType.DeveloperName=='Standard_Account';
    }
    
    /**
        If is admin user, a standard account and non verified, then it has some special permissions in Company Page
    **/
    public Boolean getPermissionForStandardAccount() {
        return this.bIsAdmin && getIsStandardAccount() && !getisVerifiedAccount();
    }
}