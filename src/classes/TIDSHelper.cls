//TIDSHelper
public without sharing class TIDSHelper {
  private static TidsWrapper tidsWrapper {get;set;}
  private static List<String> replaceby {get;set;}
  private static List<IATA_ISO_State__c> states {get;set;}
  private static List<IATAISOStateDTO> isoStateDto {get;set;}
  private static Portal_Applications__c tidsConfiguration {get;set;}
  private static List<Case> cases {get;set;}
  
  private class DynamicTableException extends Exception {
  }

    
  @AuraEnabled
  public static TIDS_Error_Message__mdt getVettingDoneCondition(String tidsCaseId){
    replaceby = new List<String>{'', '','','',''};
    if (tidsCaseId!=null){
	  	cases = TIDSUtil.getTidsCases(tidsCaseId,false);
      	if (cases.size()>0){
          string email = '';
          String portalType=TIDS_Constant.ADM_HOP;
          if (cases[0].Account.Location_Type__c!='HO'){portalType=TIDS_Constant.ADM_BRA;}
          List<Portal_Application_Right__c> applicationRights =[SELECT Contact__r.Email
            FROM Portal_Application_Right__c
            WHERE Right__c='Access Granted' 
              AND Contact__r.AccountId=:cases[0].AccountId
              AND Access_Status_Reason__c=:portalType
              AND Application_Name__c=:TIDS_Constant.TIDSVALUE
              LIMIT 1];
          if (applicationRights.size()>0) {email=applicationRights[0].Contact__r.Email;}
          String formattedDate = cases[0].createdDate.format('yyyy-MM-mm');
          replaceby = new List<String>{email, cases[0].CaseNumber,cases[0].Status,cases[0].Decision__c,formattedDate};
          if (!(cases[0].Status==TIDS_Constant.IS_CLOSED || cases[0].Status=='Abandoned'  || cases[0].Status==TIDS_Constant.IS_CUSTOMER)){return null;}
      }
    }    
    return getTIDSMetadata(TIDS_Constant.VETTING_DONE);
  }
  

  @AuraEnabled
  public static List<Account> getSortedBranches(String accountIds, String name, String order, String search){
    List<Account> listvalues = new List<Account>();
    List<Account> listreturned = new List<Account>();
    if (accountIds==null){ return listvalues;}
	//find out if a branch or head office
	//Id accountIds = users[0].AccountId;
	string queryWhere = ' Where RecordType.DeveloperName=\'IATA_Agency\' and Location_Class__c=\'T\' And ParentId=:accountIds';
	string queryFields = 'Id, Name, Location_Type__c, IATACode__c, Email__c, TradeName__c, Phone, Fax, BillingAddress, BillingCity, BillingCountry, BillingStreet, BillingState, BillingPostalCode, ShippingAddress, ShippingCity, ShippingCountry, ShippingStreet, ShippingState, ShippingPostalCode, Status__c, ParentId, Parent.Status__c, ';
	queryFields += 'VAT_Number__c,'
	+ 'VAT_Number_2__c,'
	+ 'License_Number__c,'
	+ 'IATA_ISO_Country__r.Name,'
	+ 'IATA_ISO_Country__r.ISO_Code__c,'
	+ 'IATA_ISO_Billing_State__r.Name,'
	+ 'IATA_ISO_Billing_State__r.ISO_Code__c,'
	+ 'IATA_ISO_Shipping_Country__r.Name,'
	+ 'IATA_ISO_Shipping_Country__r.ISO_Code__c,'
	+ 'IATA_ISO_Shipping_State__r.Name,'
	+ 'IATA_ISO_Shipping_State__r.ISO_Code__c,'
	+ 'Iso_State__r.Name,'
	+ 'Iso_State__r.ISO_Code__c,'
	+ 'Preferred_Language__c,'
	+ 'Website,'
	+ 'Manager_First_Name__c,'
	+ 'Manager_Last_Name__c,'
	+ 'GDP_Opt_In__c,'
	+ 'GDS__c,'
	+ 'Company_Type__c,'      
	+ 'Geoname_Shipping_City__c,'
	+ 'Location_Class__c ';
	if (search!=null && search!=''){
		search = '%' +search +'%';
		queryWhere += ' And (Name Like :search or TradeName__c like :search or IATACode__c Like :search or BillingCity Like :search)';
	}
	string accred = ',(Select Id, Virtual_Branch_Enabled__c,TIDS_Reinstatement_DeadLine__c From  Accreditation__r  Limit 1)';
	string rights = ',(SELECT Contact__r.Firstname, Contact__r.Lastname FROM Portal_Application_Right__c WHERE Right__c=\'Access Granted\' and Contact__r.AccountId=:accountIds Limit 2) ';
	string query ='SELECT  ' +queryFields +accred +' FROM Account' +
	queryWhere +' Order By ' +name +' ' +order +' Limit 100';

	listvalues = Database.query(query);
	if (listvalues.size()>0){
		for(Account a:listvalues){
		boolean isadded=true;
		if (a.Status__c=='Terminated'){
			for(Accreditation__c c:a.Accreditation__r){
				if (c.TIDS_Reinstatement_DeadLine__c<System.today()){isadded=false;}
			}
		}
		if (isadded){listreturned.add(a);}
		}
	}
    return listreturned;
  }

  @AuraEnabled 
  public static String getcountryISOCode(){
    Id userId = UserInfo.getUserId();
    List<User> users = new List<User>();
    users = [Select Id, Contact.Account.country_ISO_Code__c From User Where Id=:userId Limit 1];
    if (users.size()>0){ return users[0].Contact.Account.country_ISO_Code__c;}
    return null;     
  }
  @AuraEnabled
  public static List<Case> getSortedCases(String accountIds,String name, String order, String search){
    Id userId = UserInfo.getUserId();
    List<Case> caseValues = new List<Case>();
    final string recordtype=TIDSUtil.getTidsRecordTypeId();
	//Id accountIds = users[0].AccountId;
	final string caseorigin = TIDS_Constant.CASE_ORIGIN;
    string query='SELECT Id, CaseNumber, Status, Subject, createdDate FROM Case';
    query +=' WHERE AccountId=:accountIds and recordTypeId=:recordtype and Origin=:caseorigin';
    if (search!=null && search!=''){
        search = '%' +search +'%';
        query += ' And (CaseNumber Like :search or Subject like :search)';
    }
    query +=' and Status in (\'Pending Review\', \'Review in Progress\', \'Pending customer\', \'Closed\')';
    query +=' Order By ' +name +' ' +order +' Limit 100';
    caseValues = Database.query(query);
    
    return caseValues;
  }
  // **********************************************

  
  @AuraEnabled(cacheable=false)
  public static String actionApplication(String caseId, String action){
    String result = 'error';
    TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
    cases = TIDSUtil.getTidsCases(caseId,false);
    if (cases.size()==0) {return result;}
    if (action=='vetting'){
        if (cases[0].Status!=TIDS_Constant.IS_REVIEWED) {return result;}
        result='';
    }else if (action=='resume' || action=='discard'){
        if (cases[0].Status!=TIDS_Constant.IS_DRAFT) {return result;}
        result = 'updated';
    }else if (action=='recall'){
        if (cases[0].Status!=TIDS_Constant.IS_REVIEWED) {return result;}
        result = 'updated';
        changeCaseStatus(caseId, TIDS_Constant.IS_DRAFT);
    }
    return result;
  }

  @AuraEnabled(cacheable=false)
  public static String discardApplication(String caseId){
    String result = 'updated';
    String caseStatus = 'Abandoned';
    changeCaseStatus(caseId, caseStatus);
    return result;
  }
  public static List<IATAISOCountryDTO> getCountries(string type){
    List<IATAISOCountryDTO> options = new List<IATAISOCountryDTO>();
    List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

    Portal_Applications__c service = [ SELECT Id
                                        ,TIDS_Non_Eligible_Location_Countries__c
                                        ,TIDS_Non_Eligible_Mailing_Countries__c
                                        FROM Portal_Applications__c
                                        WHERE Name=:TIDS_Constant.TIDSVALUE
                                        LIMIT 1
                                      ];

    string excludedcountriescode=service.TIDS_Non_Eligible_Location_Countries__c;
    if (type=='mailing') {excludedcountriescode=service.TIDS_Non_Eligible_Mailing_Countries__c;}
    if (excludedcountriescode==null) {excludedcountriescode='';}
    String nonEligiblesCountries ='\'' +excludedcountriescode.replace(',', '\',\'') +'\'';
    String query ='SELECT Id ,Name,ISO_Code__c,State_Province_Mandatory__c FROM IATA_ISO_Country__c';
    query +=' WHERE ISO_Code__c NOT IN (' +nonEligiblesCountries +')';
    //if (type=='not sanctioned') query +=' AND (Sanctioned_Country__c=false)';
    query +=' ORDER BY Name Limit 10000';
    //read the countries
    countries = Database.query(query);
    options = IATAISOCountryToDto(countries);
    return options;
  }
  @AuraEnabled(cacheable=true)
  public static List<IATAISOCountryDTO> getMailingCountries(){
    return getCountries('mailing');
  }
  @AuraEnabled(cacheable=true)
  public static List<IATAISOCountryDTO> getCountry(){
     return getCountries('eligible');
  }

 
  @AuraEnabled(cacheable=false)
  public static List<IATAISOStateDTO> getState(String countryIsoCode){
    states = new List<IATA_ISO_State__c>();
    isoStateDto = new List<IATAISOStateDTO>();
    if (countryIsoCode=='GB') {return isoStateDto;}
    //read the states
    states = [SELECT Id, Name, ISO_Code__c, IATA_ISO_Country__r.ISO_Code__c
      FROM IATA_ISO_State__c
      WHERE IATA_ISO_Country__r.ISO_Code__c=:countryIsoCode
       And Valid_for_Address__c=true
      ORDER BY Name
      LIMIT 200];
    
    IATAISOStateToDto();
    return isoStateDto;
  }
  

  private static user getUserData(Id userId){
    List<user> userdata = new List<user>();
    userdata = [SELECT
        Id,
        Name,
        ContactId,
        AccountId,
		Account.ParentId,
		Account.RecordType.DeveloperName,
        Account.RecordType.Name,
        Account.Country_ISO_Code__c,
        Account.Location_Class__c,
        Account.Location_Type__c,
        Account.Status__c,
        Account.Email__c,
        Account.Parent.Email__c,
        Account.Expiry_Date__c
      FROM User
      WHERE Id=:userId
      LIMIT 1];
      return  userdata[0];
  }

  //Condition 8
  @AuraEnabled
  public static TIDSUtil.ErrorWrapper companyNameUnique(
    String accountid,
    String companyName,
    String countryIsoCode){
	TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
    Boolean isUnique;
	Id agencyRecordTypeId =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Agency');
	 
    String companyNameTrimmed = companyName.trim();
    if (accountid=='') {accountid=null;}
    List<Account> accounts = [SELECT Id
       ,Name
       ,Status__c
       ,Email__c
       ,Parent.Email__c
       ,(Select Id, Virtual_Branch_Enabled__c,TIDS_Reinstatement_DeadLine__c From  Accreditation__r  Limit 1)
      FROM Account
      WHERE Name=:companyNameTrimmed
        AND Id!=:accountid
        AND Location_Class__c = 'T'
        AND (Status__c = 'Approved' or Status__c='Terminated')
        AND Location_Type__c = 'HO'
        AND IATA_ISO_Country__r.ISO_Code__c = :countryIsoCode];

    if (accounts.size() > 0){
       	replaceby = new List<String> {'','','','',''};
       	boolean isdeduplicate=false;
       	for(Account a:accounts){
         	if (a.Status__c=='Approved') {isdeduplicate=true; break;}
         	for(Accreditation__c c:a.Accreditation__r){
               //Check Date Reinstam
               Date rdate =c.TIDS_Reinstatement_DeadLine__c;
               if (rdate==null || rdate>=System.today()){isdeduplicate=true; break;}
        	}
       	}
    	if (isdeduplicate){
			TIDSUtil.setError(TIDS_Constant.MSG3);
			TIDSUtil.iataCodeError.error = getTIDSMetadata(TIDS_Constant.ERROR_CON8); 
			return TIDSUtil.iataCodeError;
		}
    }
    Accreditation__c accountAccredited = accountHasReinstatement(companyNameTrimmed,countryIsoCode);
    if (accountAccredited != null){
		TIDSUtil.setError(TIDS_Constant.MSG3);
		TIDSUtil.iataCodeError.error = getTIDSMetadata(TIDS_Constant.ERROR_CON8);
    }
    return TIDSUtil.iataCodeError;
  }
  private static Accreditation__c accountHasReinstatement(
    String companyName,
    String countryIsoCode){
    Accreditation__c account;
    String companyNameTrimmed = companyName.trim();
    List<Accreditation__c> accountsAccredited = [SELECT Id,
        Status__r.Code__c,
        Related_Account__r.Name,
        Related_Account__r.IATA_ISO_Country__r.ISO_Code__c,
        TIDS_Reinstatement_DeadLine__c,
        Termination_date__c
      FROM Accreditation__c
      WHERE Status__r.Code__c='0' AND Class__r.Code__c='T'
        AND Related_Account__r.Name=:companyNameTrimmed
        AND Related_Account__r.IATA_ISO_Country__r.ISO_Code__c=:countryIsoCode
        AND TIDS_Reinstatement_DeadLine__c>=TODAY
      ORDER BY Termination_Date__c DESC];    
    if (accountsAccredited.size() > 0){account = accountsAccredited.get(0);}
    return account;
  }

  @AuraEnabled(cacheable=false)
  public static TidsWrapper getTidsCase(String caseId, String userId){
    tidsWrapper = new TidsWrapper();
    if (!Schema.sObjectType.Case.isAccessible()){return tidsWrapper;}
    if (!Schema.sObjectType.Case.isUpdateable()){return tidsWrapper;}
    getTidsServicesConfiguration();
    if (tidsConfiguration.Id!=null){
      tidsWrapper.businessRules = tidsConfiguration;
      tidsWrapper.tidsConfiguration = TIDSUtil.getAttachment(tidsConfiguration.Id,TIDS_Constant.TIDSCONFIGURATIONFILE);
    }

    tidsWrapper.currentUser = getUserData(userId);
    cases = TIDSUtil.getTidsCases(caseId,false);
    if (cases.size() > 0){
		Case tidsCase = cases.get(0);
		tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
		tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
		tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
		tidsWrapper.tidsCase = tidsCase;
		tidsWrapper.tidsAttachment = TIDSUtil.getAttachment(tidsCase.Id,TIDS_Constant.DATAJSONFILENAME);
		if (tidsCase.Status == TIDS_Constant.IS_REVIEWED){tidsCase.OwnerId=userId;}
		tidsCase.Status = TIDS_Constant.IS_INPROGRESS;
		update tidsCase;
    }
    return tidsWrapper;
  }
 
  
  @AuraEnabled(cacheable=false)
  public static TidsWrapper getUserInfo(Id userId){
    tidsWrapper = new TidsWrapper();
    try {
      getTidsServicesConfiguration();
      if (tidsConfiguration.Id!=null){
        tidsWrapper.businessRules = tidsConfiguration;
        // Fields Configuration
        tidsWrapper.tidsConfiguration = '';
        if (!Test.isRunningTest()){tidsWrapper.tidsConfiguration = TIDSUtil.getAttachment(tidsConfiguration.Id,TIDS_Constant.TIDSCONFIGURATIONFILE);}
      }

      tidsWrapper.currentUser =getUserData(userId);      
      String caseNumber='';
      String email='';
      String portalType=TIDS_Constant.ADM_HOP;
      if (tidsWrapper.currentUser.Account.Location_Type__c!='HO'){portalType=TIDS_Constant.ADM_BRA;}
      List<Portal_Application_Right__c> applicationRights =[SELECT 
           Id, Right__c, Contact__r.Id, Access_Status_Reason__c,Application_Name__c,Contact__r.Email
        FROM Portal_Application_Right__c
        WHERE Right__c='Access Granted' 
          AND Contact__r.Id=:tidsWrapper.currentUser.ContactId
          AND Access_Status_Reason__c=:portalType
          AND Application_Name__c=:TIDS_Constant.TIDSVALUE
          LIMIT 1];
      if (applicationRights.size()>0) {email=applicationRights[0].Contact__r.Email;}
      replaceby = new List<String>{email, caseNumber,'','',''};
      
      if (applicationRights.size()==0){
          applicationRights = [
          SELECT Id,
            Right__c,
            Contact__r.Id,
            Access_Status_Reason__c,
            Application_Name__c
          FROM Portal_Application_Right__c
          WHERE Contact__r.Id=:tidsWrapper.currentUser.ContactId
            AND Application_Name__c=:TIDS_Constant.TIDSVALUE
          LIMIT 1];
        }
    
      if (applicationRights.size() > 0){tidsWrapper.profile = applicationRights.get(0);}

      // TIDS Case
      string recordname=tidsWrapper.currentUser.Account.RecordType.DeveloperName;
      string countryiso=tidsWrapper.currentUser.Account.Country_ISO_Code__c;
      string status=tidsWrapper.currentUser.Account.Status__c;
      if (recordname!=null && recordname!=''){
        // Country validation rules
        List<String> neligible = new List<String>();
        string nelist = tidsConfiguration.TIDS_Non_Eligible_Location_Countries__c;
        if (nelist!=null && nelist!=''){neligible = nelist.split(',');}
        if (countryiso!=null && countryiso!='' && neligible.size()>0){
          //Load the country codes from Portal_Applications__c.TIDS_Non_Eligible_Location_Countries__c 
           //Condition 2: Related Account “Country_ISO_Code__c” cannot be “AS, GU, MP, PR, US, VI”
          List<IATA_ISO_Country__c> countries = [SELECT Sanctioned_Country__c FROM IATA_ISO_Country__c WHERE ISO_Code__c=:countryiso AND ISO_Code__c=:neligible Limit 1];
          if (countries.size()>0) {
              String econdition = TIDS_Constant.ERROR_CON2_1;
                // Sanctioned country
              if (countries[0].Sanctioned_Country__c==true){econdition=TIDS_Constant.ERROR_CON2_2;}
              tidsWrapper.error = getTIDSMetadata(econdition);
              return tidsWrapper;
          }
        }
        string c1=tidsWrapper.currentUser.Account.RecordType.Name.toUpperCase();
        Set<String> cl1 = new Set<String>{
          TIDS_Constant.RT_GENERAL_SALES_AGENT_HEADQUARTERS,
          TIDS_Constant.RT_AIRLINE_HEADQUARTERS,
          TIDS_Constant.RT_AIRLINE_BRANCH,
          TIDS_Constant.RT_AIRLINE_LOCAL_OFFICES,
          TIDS_Constant.RT_OPERATOR,
          TIDS_Constant.RT_VERIFIER,
          TIDS_Constant.RT_AIRPORT,
          TIDS_Constant.RT_ICAO_MEMBER_STATE
        };
        //Condition 1: Related Account Record Type cannot be “Airline Branch, Airline Headquarters, General Sales Agent Headquarters”
        if (cl1.Contains(c1)){
          tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON1);
          return tidsWrapper;
        }
        string c3=tidsWrapper.currentUser.Account.Location_Class__c;
        //Condition 3: Related Account Record Type cannot be “Agency”  WHERE Account “Location_Class__c“ = “D, P“
        if (c3<> null && c3<>''){
			if (condition3(c3, c1)) {return tidsWrapper;}
        }
        Date rdate=System.today();
        if (status!=null && status!=''){
          recordname = recordname.toUpperCase();
          status = status.toUpperCase();
          if (c3==null) {c3='';}
          c3=c3.toUpperCase();
          if (status=='TERMINATED'){
             rdate = isReinstated(tidsWrapper.currentUser.AccountId);
             if (rdate==null) {rdate=System.today();}
          }    
          //Condition 4: Related Account Record Type cannot be “Agency“ WHERE Account “Location_Class__c = “T“ and Status__c = “Approved”
          if (recordname==TIDS_Constant.RT_IATA_AGENCY && c3=='T' && (status=='APPROVED' || (status=='TERMINATED' && rdate>=System.today()))){
            //Access Grated or Access Denied
            if (condition4( applicationRights)) {return tidsWrapper;}
          }

          //Condition 5: Related Account Record Type cannot be “Agency“ WHERE Account “Location_Class__c = “T“ and Status__c = “Terminated”
          if (recordname==TIDS_Constant.RT_IATA_AGENCY && c3=='T' && status=='TERMINATED'){
              rdate = isReinstated(tidsWrapper.currentUser.AccountId);
              if (rdate!=null){
                 if (rdate<System.today()){
                  tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON5);
                  return tidsWrapper;
                 }
            }
          }

          //Condition 6: Related Account Record Type cannot be “Agency“ WHERE Account “Location_Class__c = “T“ and Status__c!=“Approved, Terminated”
		  //c3 is null to be taken in consideration check c3 null in above code
		  if (condition6(c3, recordname, status)) {return tidsWrapper;}          
        }else{
			if (condition6b(c3, recordname)) {return tidsWrapper;}
        }

        // Condition 7: Related Account cannot have an ongoing New TIDS HO Application
		// Case open for HO Application
		if (condition7(email, status)) {return tidsWrapper;}
		
      }
    } catch (DmlException dmlex){
      throw dmlex;
    }
    return tidsWrapper;
  }
  
  private static boolean condition4(List<Portal_Application_Right__c>  applicationRights){
	  //Access Grated or Access Denied
	  boolean isparentadmin = false;
	  List<Portal_Application_Right__c> adminrights = new List<Portal_Application_Right__c>();
	  adminrights = [
		SELECT Id, Right__c, Contact__r.email
		FROM Portal_Application_Right__c
		WHERE (Contact__r.AccountId=:tidsWrapper.currentUser.Account.ParentId
		  Or Contact__r.AccountId=:tidsWrapper.currentUser.AccountId)
		  AND Right__c='Access Granted'
		  AND Application_Name__c=:TIDS_Constant.TIDSVALUE 
		  Order by Access_Status_Reason__c Desc LIMIT 1];
	  if (adminrights.size()>0) {isparentadmin=true;}    
	  boolean isdenied=true;
	  if (applicationRights.size()>0){if (tidsWrapper.profile.Right__c=='Access Granted'){isdenied=false;}}
	  if (isdenied){
		//mettre un mask sur l'email
		//Access denied but there is admin
		String econdition=TIDS_Constant.ERROR_CON4_1;
		//Access denied but there is no admin
		if (!isparentadmin){econdition=TIDS_Constant.ERROR_CON4_2;}
		tidsWrapper.error = getTIDSMetadata(econdition);
		//Parent Case
		tidsWrapper.tidsCase = searchCase(tidsWrapper.currentUser.AccountId,TIDS_Constant.IS_CLOSED);
		tidsWrapper.tidsAttachment = TIDSUtil.getAttachment(tidsWrapper.tidsCase.Id,TIDS_Constant.DATAJSONFILENAME);
		return true;
	  }
	  return false;
  }
  private static boolean condition6(string c3, string recordname, string status){
	string c6=tidsWrapper.currentUser.Account.Location_Type__c;
	if (Test.isRunningTest()){	c6='XM';}
	if (recordname==TIDS_Constant.RT_IATA_AGENCY && ((c3=='T' && !(c6=='BR' || c6=='HO' || c6=='VB')) || (c3=='T' && !(status=='TERMINATED' || status=='APPROVED')) || c3=='') ){
		tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON6);
		return true;
	}
	return false;
  } 
  private static boolean condition3(string c3, string c1){
  	Set<String> cl3 = new Set<String>{'C','D','G','I','K','M','P','Q','R','V','W','X'};
	c3= c3.toUpperCase();
	if (c1 == TIDS_Constant.RT_AGENCY && cl3.Contains(c3)){
		tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON3);
		return true;
	}
	return false;
  }
  private static boolean condition6b(string c3, string recordname){
	if (c3==null) {c3='';}
	c3=c3.toUpperCase();
	if (recordname==TIDS_Constant.RT_IATA_AGENCY && c3=='T'){
	  tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON6);
	  return true;
	}
	return false;
  }
  private static boolean condition7(String email, string status){
	Set<string> statuses = new Set<String>{TIDS_Constant.IS_DRAFT, TIDS_Constant.IS_REVIEWED, TIDS_Constant.IS_INPROGRESS, TIDS_Constant.IS_CUSTOMER};
	List<Case> cases = [SELECT Id, CaseNumber, AccountId, ContactId, RecordTypeId, Status, Decision__c, CreatedDate
	  FROM Case
	  WHERE Status in :statuses
		AND AccountId=:tidsWrapper.currentUser.AccountId
		AND Reason1__c=:'TIDS - new HO Application'
		AND RecordTypeId=:TIDSUtil.getTidsRecordTypeId() Limit 1];

	if (cases.size() > 0){
	  Case tidsCase = cases.get(0);
	  //caseNumber=tidsCase.CaseNumber;
	  String formattedDate = tidsCase.createdDate.format('yyyy-MM-dd');
	  replaceby = new List<String>{email,tidsCase.CaseNumber, tidsCase.Status,tidsCase.Decision__c, formattedDate};
	  String result = TIDSUtil.getAttachment(tidsCase.Id, TIDS_Constant.DATAJSONFILENAME);
	  tidsWrapper.tidsCase = tidsCase;
	  if (tidsCase.ContactId==tidsWrapper.currentUser.ContactId){
		 //7.1
		 //Draft ==> 7_1_Draft
		 //Pending Review ==> 7_1_Pending_Review
		 status  = tidsCase.Status;
		 status = '_'+status.replaceAll(' ', '_');
		 tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON7_1+status);
	  }else{
		 //7.2 ==>it is yours create a new case with case# (@case @status)
		 tidsWrapper.error = getTIDSMetadata(TIDS_Constant.ERROR_CON7_2);
	  }          
	  if (result!=''){tidsWrapper.tidsAttachment = result;}
	  return true;
	}
	return false;
  }
  public static void conditiontest(String userId){
	tidsWrapper = new TidsWrapper();
	tidsWrapper.currentUser =getUserData(userId); 
	condition7('no@iata.org','Pending Review');

	List<Portal_Application_Right__c> applicationRights =[SELECT 
           Id, Right__c, Contact__r.Id, Access_Status_Reason__c,Application_Name__c,Contact__r.Email
        FROM Portal_Application_Right__c
        WHERE Application_Name__c=:TIDS_Constant.TIDSVALUE
		  LIMIT 1];
		  
	condition4(applicationRights);
	condition3(TIDS_Constant.RT_AGENCY, 'C');
	condition6('T',TIDS_Constant.RT_IATA_AGENCY,'XTERMINATED');
	condition6b('T',TIDS_Constant.RT_IATA_AGENCY);

  }
  private static Case searchCase(String accountId, String caseStatus){
    Case tidsCase = new Case();
    
    List<Case> cases = [SELECT Id, AccountId, RecordTypeId, Status
      FROM Case
      WHERE Status=:caseStatus
        AND AccountId=:accountId
        AND RecordTypeId=:TIDSUtil.getTidsRecordTypeId() LIMIT 1];

    if (cases.size() > 0){tidsCase = cases.get(0);}
    return tidsCase;
  }

  
  private static TIDS_Error_Message__mdt getTIDSMetadata(String errorCondition){
    TIDS_Error_Message__mdt metadata = new TIDS_Error_Message__mdt();
    metadata = [SELECT
        Id,
        DeveloperName,
        Subtitle__c,
        Description__c,
        Description_P2__c,
        Description_P3__c,
        Create_a_Case__c,
        Close_Vetting__c,
        Open_A_Case_Text__c,
        Visit_URL__c,
        Visit_A_Website_Text__c,
        Discard_Application__c,
        Resume_Application__c,
        Recall_Application__c,
        Yellow_Section_Header__c,
        Yellow_Section_Text__c
      FROM TIDS_Error_Message__mdt
      WHERE DeveloperName=:errorCondition LIMIT 1];
    return replaceInfo(metadata);
  }

  

  private static String contentInfo(String content){
    if (content==null || content=='') {return content;}
    integer i=0;
    List<String> toreplace = new List<String>{'{@email}','{@Case}','{@Case Status}','{@ApplicationDecision}','{@CreatedDate}'};
    for(String o:toreplace){
      if (replaceby[i]==null) {replaceby[i]='';}
      content=content.replace(o,replaceby[i]);
      i++;
    }
    return content;
  }

  private static TIDS_Error_Message__mdt replaceInfo(TIDS_Error_Message__mdt condition){
    condition.Subtitle__c = contentInfo(condition.Subtitle__c);
    condition.Description__c = contentInfo(condition.Description__c);
    condition.Description_P2__c= contentInfo(condition.Description_P2__c);
    condition.Description_P3__c= contentInfo(condition.Description_P3__c);
    return condition;
  }

  public class TidsWrapper {
    @AuraEnabled public User currentUser = new User();
    @AuraEnabled public TIDS_Error_Message__mdt error = new TIDS_Error_Message__mdt();
    @AuraEnabled public String tidsAttachment = null;
    @AuraEnabled public Portal_Applications__c businessRules = new Portal_Applications__c();
    @AuraEnabled public Case tidsCase = new Case();
    @AuraEnabled public Portal_Application_Right__c profile = new Portal_Application_Right__c();
    @AuraEnabled public String tidsConfiguration = null;
    @AuraEnabled public String sectionsConfiguration = null;
  }
  
  
  //SaveSettings
  @AuraEnabled(cacheable=false)
  public static Id saveSettings(
    String accountId,
    String applicationsettings,
    String applicationtype,
    String caseId){
    Case tidsCase = new Case();
    String tidsCaseSubject='no-subject';
    if (applicationtype == 'chg-name-company' ||
      applicationtype == 'chg-address-contact' ||
      applicationtype == 'chg-business-profile-specialization'){
      tidsCaseSubject = caseSubjectText(applicationtype);
    }
    if (caseId!=null){
        cases = TIDSUtil.getTidsCases(caseId,false);
    } else if (tidsCaseSubject!=null){
        List<Case> todelete = new List<Case>();
        todelete = [SELECT Id, Status  FROM Case WHERE AccountId=:accountId AND Subject=:tidsCaseSubject AND Status=:TIDS_Constant.IS_DRAFT];
        if (todelete.size() > 0) {delete todelete;}
        cases = [SELECT Id FROM Case WHERE AccountId=:accountId 
          AND Subject=:tidsCaseSubject
          AND Status!=:TIDS_Constant.IS_CLOSED
          ORDER BY CreatedDate Desc LIMIT 1];
        if (cases.size() > 0){cases = TIDSUtil.getTidsCases(cases[0].Id,false);}
    }
    if (cases!=null){
       if (cases.size() > 0){tidsCase = cases.get(0);}
    }
    tidsCase = createTidsCase(tidsCase.Id,
      accountId,
      applicationtype,
      applicationsettings
    );
    return tidsCase.Id;
  }

  public static Case createTidsCase(
    Id caseId,
    String accountId,
    String applicationType,
    String applicationsettings){
    set<String> apptypes = new set<String> {'request-virtual-branch-service','request-relinquish-ho','request-relinquish-br','request-relinquish-vb','request-reinstate-ho','request-reinstate-br','request-reinstate-vb'};
    Case tidsCase = new Case();
    if (caseId!=null){
       tidsCase.Id=caseId;
    }else{
      tidsCase.Status = TIDS_Constant.IS_DRAFT;
      if (apptypes.Contains(applicationType)){tidsCase.Status = TIDS_Constant.IS_REVIEWED;}
      tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
      tidsCase.AccountId = accountId;
      tidsCase.recordtypeid =TIDSUtil.getTidsRecordTypeId();
    } 
    tidsCase.Reason1__c = caseReasonText(applicationType);
    tidsCase.Subject = caseSubjectText(applicationType);
    tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
    tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
    try{
      upsert tidsCase;
      if (apptypes.Contains(applicationType)){
          if (!String.isBlank(applicationsettings)){
            createCaseComment(tidsCase.Id, applicationsettings);
          }
         //applicationsettings is the reason why the request is made
      }else{
        TIDSUtil.addAttachment(tidsCase.Id, applicationsettings,TIDS_Constant.DATAJSONFILENAME);
      }
    }catch(Exception e){}
    return tidsCase;
  }  

  public static String caseSubjectText(String applicationType){
    String subject = TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE;
    Map<String, String> types = new Map<String, String>();
    types.put(TIDS_Constant.NEW_HO,TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE);
    types.put(TIDS_Constant.NEW_BR,TIDS_Constant.CASE_SUBJECT_BRANCH);
    types.put(TIDS_Constant.NEW_VB,TIDS_Constant.CASE_SUBJECT_VIRTUAL_BRANCH);
    types.put('chg-business-profile-specialization' ,TIDS_Constant.CASE_SUBJECT_BUSINESS_PROFILE_SPECIALIZATION);
    types.put('chg-address-contact',TIDS_Constant.CASE_SUBJECT_ADDRESS_CONTACT);
    types.put('chg-name-company',TIDS_Constant.CASE_SUBJECT_NAME_COMPANY);
    types.put('request-virtual-branch-service','TIDS – Virtual Branch Access Request');
    types.put('request-relinquish-ho','TIDS – Head Office Relinquishment');
    types.put('request-relinquish-vb','TIDS – Virtual Branch Relinquishment');
    types.put('request-relinquish-br','TIDS – Branch Office Relinquishment');
    types.put('request-reinstate-ho','TIDS – Head Office Reinstatement');
    types.put('request-reinstate-br','TIDS – Branch Office Reinstatement');
    types.put('request-reinstate-vb','TIDS – Virtual Branch Reinstatement');
    if (types.ContainsKey(applicationType)){subject = (String) types.get(applicationType);}
    return subject;
  }

  public static String caseReasonText(String applicationType){
    String subject = 'TIDS - New HO Application';
    Map<String, String> types = new Map<String, String>();
    types.put(TIDS_Constant.NEW_HO,'TIDS - New HO Application');
    types.put(TIDS_Constant.NEW_BR,'TIDS - New BR Application');
    types.put(TIDS_Constant.NEW_VB,'TIDS - New VB Application');
    types.put('chg-business-profile-specialization' ,'TIDS - Change of Business Profile Specialization');
    types.put('chg-address-contact','TIDS - Change of Address or Contact Details');
    types.put('chg-name-company','TIDS - Change of Name or Company Details');
    types.put('request-virtual-branch-service','TIDS – VB Service Request');
    types.put('request-relinquish-ho','TIDS – Relinquishment');
    types.put('request-relinquish-br','TIDS – Relinquishment');
    types.put('request-relinquish-vb','TIDS – Relinquishment');
    types.put('request-reinstate-ho','TIDS – Reinstatement');
    types.put('request-reinstate-br','TIDS – Reinstatement');
    types.put('request-reinstate-vb','TIDS – Reinstatement');
    
    if (types.ContainsKey(applicationType)){subject = (String) types.get(applicationType);}
    return subject;
  }

  @AuraEnabled(cacheable=false)
  public static TIDSSFInfo newBranch(String contactId){
    TIDSSFInfo tids = new TIDSSFInfo();

    final String LOCATION_TYPE = 'HO';
    final String LOCATION_CLASS = 'T';

    List<Portal_Application_Right__c> plist = new List<Portal_Application_Right__c>();
    plist= [SELECT Contact__r.AccountId FROM Portal_Application_Right__c WHERE Contact__c=:contactId Limit 1];

    List<Account> accounts = [
      SELECT
        Id,
        Name,
        TradeName__c,
        Category__c,
        Sector__c,
        ParentId,
        Parent.Status__c,
        Status__c,
        VAT_Number__c,
        VAT_Number_2__c,
        License_Number__c,
        BillingStreet,
        BillingCity,
        BillingState,
        BillingPostalCode,
        BillingCountry,
        IATACode__c,
        IATA_ISO_Country__r.Name,
        IATA_ISO_Country__r.ISO_Code__c,
        IATA_ISO_Billing_State__r.Name,
        IATA_ISO_Billing_State__r.ISO_Code__c,
        IATA_ISO_Shipping_Country__r.Name,
        IATA_ISO_Shipping_Country__r.ISO_Code__c,
        IATA_ISO_Shipping_State__r.Name,
        IATA_ISO_Shipping_State__r.ISO_Code__c,
        Iso_State__r.Name,
        Iso_State__r.ISO_Code__c,
        Preferred_Language__c,
        Phone,
        Fax,
        Email__c,
        Website,
        Manager_First_Name__c,
        Manager_Last_Name__c,
        GDP_Opt_In__c,
        GDS__c,
        Company_Type__c,
        ShippingStreet,
        ShippingCity,
        ShippingState,
        ShippingPostalCode,
        ShippingCountry,
        Geoname_Shipping_City__c,
        Location_Class__c,
        Location_Type__c,
        (SELECT Id, Virtual_Branch_Enabled__c
          FROM Accreditation__r
          WHERE Virtual_Branch_Enabled__c = true
          LIMIT 1),
        (SELECT Id
        FROM Agency_Profiles__r
            WHERE GR_Code__c='AT' and GR_Item__c In ('OL')
            LIMIT 1)
      FROM Account
      WHERE Id=:plist[0].Contact__r.AccountId
        AND Location_Type__c in ('HO', 'VB', 'BR')
        AND Location_Class__c=:LOCATION_CLASS
      LIMIT 1];
     
    if (accounts.size()==0){return tids;}
    tids.tidsAccount = accounts.get(0);
    tids.shareholders = TIDSUtil.tidsShareholders(tids.tidsAccount.Id);
    tids.businessProfile = TIDSUtil.tidsBusinessProfile(tids.tidsAccount.Id);
    return tids;
  }

  
  @AuraEnabled(cacheable=false)
  public static List<Contact> getAdministrators(String accountId, String name){
   if (!Schema.sObjectType.Contact.isAccessible()){return null;}
   
   name=name+'%';
   List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact
    WHERE AccountId=:accountId and (FirstName like :name  Or LastName like :name) 
    And Email!=null
    And Status__c='Active'
    And Id not in (SELECT Contact__c
                  FROM Portal_Application_Right__c
                  WHERE Right__c='Access Granted' and Contact__r.AccountId=:accountId) 
    Limit 20];
   if (contacts.size()>0){return contacts;}
   return null;
  }
  //actiontype: add secondary, add administrator, remove, swap
  //isbranch: if it is a request from a branch and not the ho
  @AuraEnabled(cacheable=false)
  public static List<Portal_Application_Right__c> actionAdministrators(String accountId, String contactId, string actiontype, boolean isbranch){
	getTidsServicesConfiguration();
    List<Portal_Application_Right__c> apprights = new List<Portal_Application_Right__c>();
    if (tidsConfiguration==null){ return apprights;}
    if (actiontype=='add' || actiontype=='swap'){
        string originid=accountId;
        if (isbranch){ 
            List<Account> parents = [SELECT parentId FROM Account WHERE Id=:accountId LIMIT 1];
            if (parents.size()>0){originid=parents[0].parentId;}
        }
        //Portal_Application_Right__c
        apprights = [SELECT Id,Right__c,Contact__c,
              Access_Status_Reason__c,
              Application_uniqueness_for_contact__c,
              Application_Name__c,
              Portal_Application__c
            FROM Portal_Application_Right__c
            WHERE Contact__r.AccountId=:originid
              AND Access_Status_Reason__c=:TIDS_Constant.ADM_HOP
              AND Application_Name__c=:TIDS_Constant.TIDSVALUE LIMIT 1];
    }
   //TIDS Admin HO Primary
   String type=TIDS_Constant.ADM_BRA;
   if (!isbranch){type=TIDS_Constant.ADM_HOP;}
   if (actiontype=='add'){
       setPartnerUser(contactId, actiontype);
       List<Portal_Application_Right__c> appusers = new List<Portal_Application_Right__c>();
       appusers = [SELECT Id,Right__c FROM Portal_Application_Right__c
            WHERE Contact__r.AccountId=:accountId
              AND Contact__c=:contactId
              AND Access_Status_Reason__c=:type
              AND Application_Name__c=:TIDS_Constant.TIDSVALUE LIMIT 1];
      if (appusers.size()==0){       
          Portal_Application_Right__c cu = apprights[0].clone(false);
          cu.Application_uniqueness_for_contact__c=accountId+contactId;
		  cu.Contact__c=contactId;
		  cu.Access_Status_Reason__c= isbranch==true ? TIDS_Constant.ADM_BRA:TIDS_Constant.ADM_HOS;
          insert cu;
      }else{
        appusers[0].Right__c='Access Granted';        
        update appusers;
      }       
    }else if (actiontype=='remove'){
      //setPartnerUser(contactId, 'remove');

      apprights = [SELECT Id,Right__c FROM Portal_Application_Right__c
            WHERE Contact__r.AccountId=:accountId
              AND Contact__c=:contactId
              AND Access_Status_Reason__c=:type
              AND Application_Name__c=:TIDS_Constant.TIDSVALUE LIMIT 1];
      apprights[0].Right__c='Access Denied';        
      update apprights;
      
    }else if (actiontype=='swap'){
		List<Portal_Application_Right__c> appsec = new List<Portal_Application_Right__c>();
		appsec = [SELECT Id,Right__c,Contact__c,
			Access_Status_Reason__c,
			Application_uniqueness_for_contact__c,
			Application_Name__c
			FROM Portal_Application_Right__c
			WHERE Contact__r.AccountId=:accountId
			AND Access_Status_Reason__c=:TIDS_Constant.ADM_HOS
			AND Application_Name__c=:TIDS_Constant.TIDSVALUE LIMIT 1];
	 
		if (!Test.isRunningTest()){	  
			appsec[0].Access_Status_Reason__c=TIDS_Constant.ADM_HOP;
			update appsec;
			apprights[0].Access_Status_Reason__c=TIDS_Constant.ADM_HOS;
			update apprights;
			TIDSUtil.sendNotification(accountId, appsec[0].Contact__c, 'Administrators_Role_Swap_Primary');
			TIDSUtil.sendNotification(accountId, apprights[0].Contact__c, 'Administrators_Role_Swap_Secondary');
		}

    }
    //get the list
    List<String> rlist = new List<String>{TIDS_Constant.ADM_HOS,TIDS_Constant.ADM_HOP};
    if (isbranch){rlist = new List<String>{TIDS_Constant.ADM_BRA};}
    apprights = new List<Portal_Application_Right__c>();
    apprights = [SELECT Id,Contact__c,Contact__r.FirstName,Contact__r.LastName,
          Access_Status_Reason__c
        FROM Portal_Application_Right__c
        WHERE Contact__r.AccountId=:accountId
          AND Access_Status_Reason__c=:rlist
          AND Application_Name__c=:TIDS_Constant.TIDSVALUE
          AND Right__c='Access Granted'
          Order by Access_Status_Reason__c LIMIT 2];
    return apprights;
  }

  @AuraEnabled(cacheable=false)
  public static List<Portal_Application_Right__c> getAdmin(String accountId){
    List<Portal_Application_Right__c> apprights = new List<Portal_Application_Right__c>();
    apprights = [SELECT Id,Contact__c, Contact__r.FirstName,Contact__r.LastName,
          Access_Status_Reason__c
        FROM Portal_Application_Right__c
        WHERE Contact__r.AccountId=:accountId
           	AND Application_Name__c=:TIDS_Constant.TIDSVALUE
          	AND Right__c='Access Granted'
          Order by Access_Status_Reason__c LIMIT 2];
    return apprights;
  }
  //actiontype: remove or add
  //remove will inactived the partner user
  //add will add a new partner user or reactivate the partner user 
  private static void setPartnerUser(Id contactId, string actiontype){
    if (!Schema.sObjectType.Contact.isAccessible()){return;}
    List<Contact> contacts = new List<Contact>();
    contacts = [Select id, email, Firstname, Lastname, account.Name, account.ParentId, AccountId, Account.RecordType.DeveloperName, Salutation, Community__c From Contact where Id=:contactId Limit 1];
    if (contacts.size()==0){return;}
    String pname='ISS Portal';
    String domain='@partner.iata.org';
    String rname = contacts[0].account.Name+' Partner User'; //Ascari Travel Inc. Partner User

    String email = contacts[0].email;
    String username =email.replace('@','.')+domain;
    Id accountId = contacts[0].AccountId;
    Id paccountId = contacts[0].AccountId;
    if (contacts[0].account.ParentId!=null){paccountId =contacts[0].account.ParentId;}
    //Create portal account owner
    UserRole prole = [Select Id From UserRole Where PortalType='Partner' and name=:rname and PortalAccountId=:paccountId Limit 1];
    
    Profile profile = [SELECT Id FROM Profile WHERE Name LIKE '%Portal User%' Limit 1]; //[Select Id from Profile where name=:pname Limit 1];
    List<User> users = new List<User>();
    users = [Select Id, isActive From User Where username=:username Limit 1];
    if (actiontype=='add'){
        if (users.size()>0){
           if (users[0].isActive==false){users[0].isActive=true;Database.update(users);}
        }else{
			string profileId;
			if (Test.isRunningTest()){	
				string userType = ISSP_Constant.userTypeByAccountRtDeveloperNameMap.get(contacts[0].Account.RecordType.DeveloperName);
				string profileName = ISSP_Constant.profilNameByUserTypeMap.get('Admin').get(userType);
				profileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
			}else{
				profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
			}
            createNewUser(profileId,contacts[0]);
        }
    }else if(actiontype=='remove'){
      if (users.size()>0){
        if (users[0].isActive){users[0].isActive=false;Database.update(users);}
      }
    }
    
  }
  public static  Map<String, String> ISSP_PassWordBuilMessageWrapper(contact con , string password , string link, String commName, string serviceName){
      String portalName = 'IATA';
       String imageURL = Label.OneId_Email_Header_Identity;   // OneId default header image URL
       String communityName = commName;
       communityName = portalName + ' Customer Portal';
       
       Map<String, String> mapBodyParamsIssp = new map<String,String>{
           
           '{{{Contact.Salutation}}}' => con.Salutation,
               '{{{Contact.Password}}}' => password,
               '{{{Receiving_User.FirstName}}}' =>con.Firstname,
               '{{{Receiving_User.LastName}}}' => con.LastName,
               '{{{Receiving_User.Email}}}' => con.Email,
               '{{{Community_Name}}}' => TIDS_Constant.TIDSVALUE,
               '{{{Community_Url}}}' => link, 
               '{{{Community_Header}}}' => imageURL,
               '{{{$Label.ISSP_Email_Here}}}' => 'here',
               '{{{$Label.ISSP_Email_do_not_reply}}}' => '',
               '{{{$Label.OneId_IATA_represent_lead_and_serve_the_airline_industry}}}' => ''
               };
                   
     return mapBodyParamsIssp;
  }  
  public static void createNewUser(Id userProfile,Contact con){
      Database.DMLOptions dmo = new Database.DMLOptions();
      dmo.EmailHeader.triggerUserEmail = false; 
      dmo.EmailHeader.triggerOtherEmail = false; 
      dmo.EmailHeader.triggerAutoResponseEmail = false; 
      dmo.optAllOrNone = false; 
      // create portal user
      User newUser = createUser(con,userProfile);
      String UID = Comm_User_Helper.NewGuid();
      newUser.setOptions(dmo);
      
      // new email process
      newUser.UID__c = UID;
	  newUser.Community__c = 'ISSP';
	  newUser.ProfileId=userProfile;
      if (!Test.isRunningTest()) {insert newUser;}
      // new email process
      String password = Comm_User_Helper.generateRandomString(6)+'1a';
      
      if (!Test.isRunningTest()) {System.setPassword(newUser.ID, password);}
      String cleanUsername = ISSP_Utilities.buildPortalUserName(con.email);
      cleanUsername = cleanUsername.replace('+', Comm_User_Helper.plusReplacer);
      string encodedPart = EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(cleanUsername+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+UID), 'UTF-8');
      
      String link = 'https://' + String.ValueOF(ISSP_CS__c.getValues('Host').value__c)+ '/ISSP_First_Login?c='+encodedPart ;
      String template = 'TIDS_Admin_User_Creation_Notification';            
      Map<String,String> emailWrap = ISSP_PassWordBuilMessageWrapper( con ,  password ,  link, con.Community__c, '');
      sendEmail( template ,emailWrap, con, false, con.Community__c);
      Comm_User_Helper.permissionASS(new list<Id>{newUser.ID});
       

    }
  
  public static void sendEmail( string emailTemplateDeveloperName , Map<String, String> mapBodyParamsIssp, Contact con, Boolean bccCS, String commName){
        EmailMessageWrapper ew;
        String noreplyemail= 'noreply@iata.org';      
        if (bccCS){
            String bccEmail = UserInfo.getUserEmail();
            ew = new EmailMessageWrapper(noreplyemail, con.Email, null, bccEmail, null,  new map<string,string>(), null, mapBodyParamsIssp );
        }else{
            ew = new EmailMessageWrapper(noreplyemail,
                                            con.Email,
                                            null,
                                            null,
                                            null,
                                            new map<string,string>(),
                                            null,
                                            mapBodyParamsIssp
                                            );
        }
        
        List <User> userList = [SELECT Id FROM User WHERE ContactId = :con.Id AND UserType = 'PowerPartner'];
        if (!userList.isEmpty()){TIDSUtil.sendMyEmail(new List<EmailMessageWrapper>{ew},emailTemplateDeveloperName, userList[0].Id);}     
    } 
    

public static User createUser(Contact con,Id userProfile){
	String nick = con.email!=null?con.email.substring(0, con.email.indexOf('@')):'';
	nick += Datetime.now().getTime();
	if (nick.length() > 40){
		nick = nick.left(40);
	}else{
		nick = nick;
	}
	User user;
	list<User> userList = [select Id,ProfileId,IsActive,IsPortalEnabled,languagelocalekey from User where contactId =: con.Id];
	if(!userList.isEmpty()){
		user = userList.get(0);
		user.IsActive = true;
		user.IsPortalEnabled = true;
		user.ProfileId = userProfile;
		user.Username = ISSP_Utilities.buildPortalUserName(user.email);//AEF:
	}else{
		user = new User(
			alias = createAlias(con.firstName, con.lastName), 
			email = con.email, 
			emailencodingkey = 'UTF-8', 
			firstname = con.firstName, 
			lastname = con.lastname, 
			languagelocalekey = 'en_US', 
			localesidkey = 'en_US', 
			contactId = con.Id,
			timezonesidkey = 'Asia/Dubai', 
			username = ISSP_Utilities.buildPortalUserName(con.email),//AEF
			CommunityNickname = nick,
			ProfileId = userProfile,
			IsActive = true);
	}
	return user;
  }
  public static String createAlias(String pFirstName, String pLastName) {
	if(pFirstName==null){pFirstName='-';}
	if(pLastName==null){pLastName='';}            
	if (pLastName.length() > 7){return pLastName.substring(0, 7) + pFirstName.substring(0,1);}
    
    return pLastName + pFirstName.substring(0,1);
   }
  
  @AuraEnabled(cacheable=false)
  public static String createTidsRequestReinstate(String accountId,String reason, String applicationType){
    return createBranch(accountId,reason,'request-reinstate-'+applicationType);
  }

  @AuraEnabled(cacheable=false)
  public static String createTidsRequestRelinquish(String accountId,String reason, String applicationType){
    return createBranch(accountId,reason,'request-relinquish-'+applicationType);
  }
  @AuraEnabled(cacheable=false)
  public static String createTidsRequestVirtualBranch(String accountId,String payload){
    return createBranch(accountId,payload,'request-virtual-branch-service');
  }

  @AuraEnabled(cacheable=false)
  public static String isTidsRequestPending(String accountId, String type){
    if (!Schema.sObjectType.Account.isAccessible()){return '';}
    String tidsstatus=TIDS_Constant.IS_REVIEWED;
    id parentId=accountId;
    if (type=='TIDS – Relinquishment' || type=='TIDS – Reinstatement') { 
       List<Account> accounts = [Select ParentId From Account Where Id=:AccountId Limit 1];
       if (accounts.size()>0){parentId=accounts[0].ParentId;}
    }else if (type=='Terminated') {
        //A l'interieur de la periode de reinstement
        List<Account> accounts = [Select Id From Account Where Id=:accountId and Status__c=:type Limit 1];
        if (accounts.size()>0){
          Date rdate = isReinstated(accountId);
          if (rdate==null) {return TIDS_Constant.MSG5;}
          if (rdate<System.today()){
            	return 'The reinstatement date '+String.ValueOf(rdate)+' is over due .';
          }else{
            	return 'The reinstatement window will be over due on the '+String.ValueOf(rdate)+'.';
          }
        }
        return '';
   }
   List<Case> cases = [SELECT Id FROM Case
      WHERE Status=:tidsstatus
        AND (subject=:type or Reason1__c=:type)
        AND (AccountId=:AccountId or AccountId=:parentId)
        AND RecordTypeId=:TIDSUtil.getTidsRecordTypeId() Limit 1];
   if (cases.size()>0){return 'exists';}
   return '';
  }
  private static Date isReinstated(Id accountId){
	Date rdate;
    List<Accreditation__c> accreditations = new List<Accreditation__c>();
    accreditations= [SELECT id,TIDS_Reinstatement_DeadLine__c
						FROM Accreditation__c
						WHERE Related_Account__c=:accountId Limit 1];
    if (accreditations.size()>0){rdate = accreditations[0].TIDS_Reinstatement_DeadLine__c;}
	return rdate;
  }
  
  private static void getTidsServicesConfiguration(){
    tidsConfiguration = new Portal_Applications__c();
    //Get the current user based on the User Id
    if (!Schema.sObjectType.Portal_Applications__c.isAccessible()){return;}
    List<Portal_Applications__c> tidsServicesConfiguration = [SELECT Id,Name
        ,TIDS_Total_Ownership_Minimum__c
        ,TIDS_Total_Ownership_Maximum__c
        ,TIDS_Non_Eligible_Location_Countries__c
      FROM Portal_Applications__c WHERE Name=:TIDS_Constant.TIDSVALUE Limit 1];
    if (tidsServicesConfiguration.size() > 0){tidsConfiguration  = tidsServicesConfiguration.get(0);}
  }


  @AuraEnabled(cacheable=false)
  public static String createTidsCaseNewBranch(String accountId,String payload){
    return createBranch(accountId,payload,TIDS_Constant.NEW_BR);
  }

  @AuraEnabled(cacheable=false)
  public static String createTidsCaseVirtualBranch(String accountId,String payload){    
    return createBranch(accountId,payload,TIDS_Constant.NEW_VB);
  }
  private static string createBranch(String accountId,String payload, string type){
    Case tidsCase = new Case();
    try {
      tidsCase = createTidsCase(null,accountId,type,payload);
    } catch (Exception e){ }
    return tidsCase.Id;
  }

  // Method return only Cases with RecordType TIDS
  @AuraEnabled(cacheable=false)
  public static List<Case> allMyTidsCases(String filter){
    Id userId = UserInfo.getUserId();
    string recordid=TIDSUtil.getTidsRecordTypeId();
    string queryWhere = ' Where RecordTypeId=:recordid AND Account.Name!=null ';
    Set<String> caseStatus = new Set<String>{TIDS_Constant.IS_REVIEWED,TIDS_Constant.IS_INPROGRESS,TIDS_Constant.IS_CUSTOMER};
    if (filter=='My Cases'){
        queryWhere += 'AND ownerId=:userId';
    }else if (filter=='All'){
        queryWhere += ' AND status=:caseStatus';
    }else if (filter==TIDS_Constant.IS_REVIEWED){
        caseStatus = new Set<String>{TIDS_Constant.IS_REVIEWED};
        queryWhere += ' AND status=:caseStatus';
    }else if (filter==TIDS_Constant.IS_CUSTOMER){
        caseStatus = new Set<String>{TIDS_Constant.IS_CUSTOMER};
        queryWhere += ' AND status=:caseStatus';
    }
    string queryFields = 'Id,CaseNumber,Subject,Reason1__c,Account.Name,Status,Owner.Name,OwnerId,Previous_case_owner__c,Last_Status_Change__c ';
    string query ='SELECT ' +queryFields+' FROM Case '+queryWhere;
    query +=' Order By CaseNumber DESC Limit 100';
    List<Case> listvalues = new List<Case>();
    listvalues = Database.query(query);
    return listvalues;
  }
  @AuraEnabled(cacheable=true)
  public static String getLocalPlace(
    String fieldType,
    String searchValue,
    String countryIsoCode){
    // Instantiate a new http object
    //string url='http://api.geonames.org/postalCodeSearchJSON?placename_startsWith='+searchValue+'&country='+countryIsoCode+'&maxRows=100&username=akatia1';
    string url;
    if (fieldtype == 'city'){
       	searchValue = EncodingUtil.urlEncode(searchValue, 'UTF-8');
      	url ='http://api.geonames.org/searchJSON?name_startsWith=' +searchValue +'&featureClass=P&cities=cities1000&country=' +countryIsoCode +'&style=MEDIUM&maxRows=100&username=akatia1';
    }else{
      	url ='http://api.geonames.org/findNearbyPostalCodesJSON?lat=' + searchValue +'&lng=' + countryIsoCode +'&username=akatia1';
	}
	HttpResponse res;
	HttpRequest req;
    Http h = new Http();
    if (!Test.isRunningTest()) {req = new HttpRequest();}
    if (!Test.isRunningTest()) {req.setEndpoint(url);}
    if (!Test.isRunningTest()) {req.setMethod('GET');}
    if (!Test.isRunningTest()) {res = h.send(req);}
	if (!Test.isRunningTest()) return res.getBody();
	return '';
  }

  @AuraEnabled(cacheable=false)
  public static TIDSUtil.ErrorWrapper assignToCaseOwner(Id caseId){
    TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
    Id userId = UserInfo.getUserId();
    cases = TIDSUtil.getTidsCases(caseId,false);
	if (cases.size() == 0){TIDSUtil.setError('Case Not Found.'); return TIDSUtil.iataCodeError;}
	
    if (cases[0].status == TIDS_Constant.IS_REVIEWED && userId!=cases[0].OwnerId){TIDSUtil.setError('Case already assigned to a different user agent.'); return TIDSUtil.iataCodeError;}
    if (cases[0].status == TIDS_Constant.IS_REVIEWED){return TIDSUtil.iataCodeError;}
    cases[0].status = TIDS_Constant.IS_REVIEWED;
    cases[0].OwnerId = userId;
    update cases;
    //Assign the new Owner to the Case and change the status to pending review
    return TIDSUtil.iataCodeError;
  }
  
  
  
  

  @AuraEnabled(cacheable=false)
  public static void contactApplicant(String caseId,
                                      String caseStatus,
                                      String applicationsettings){
    cases = TIDSUtil.getTidsCases(caseId,false);
    Case tidscase  = new Case();
    if (cases.size() > 0){
       tidscase = cases[0];
       tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
       tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
       tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
	   tidsCase.Status = caseStatus;
	   TIDSUtil.addAttachment(caseId, applicationsettings,TIDS_Constant.DATAJSONFILENAME);
    }

    String errorsCompilation = '';
    TIDS_Controller.vTIDS tids = (TIDS_Controller.vTIDS) JSON.deserialize(applicationsettings,TIDS_Controller.vTIDS.class);
	// Welcome section
	errorsCompilation += tidsCompileErrors(tids.sections.Welcome.errors,'Welcome',true);
    // Agency Legal Status section
    errorsCompilation += tidsCompileErrors(tids.sections.AgencyLegalStatus.errors,'Agency Legal Status',false);
    // Shareholder Details section
    errorsCompilation += tidsCompileErrors(tids.sections.ShareholderDetails.errors,'Shareholder Details',false);
    // Address section
    errorsCompilation += tidsCompileErrors(tids.sections.Address.errors,'Address',false);
    // Mailing section
    errorsCompilation += tidsCompileErrors(tids.sections.Mailing.errors,'Mailing',false);
    // Contact section
    errorsCompilation += tidsCompileErrors(tids.sections.Contact.errors,'Contact',false);
    // Business Profile section
    errorsCompilation += tidsCompileErrors(tids.sections.BusinessProfile.errors,'Business Profile',false);
    // Business Specialization section
    errorsCompilation += tidsCompileErrors(tids.sections.BusinessSpecialization.errors,'Business Specialization',false);
    // Supporting Documents section
    errorsCompilation += tidsCompileErrors(tids.sections.SupportingDocuments.errors,'Supporting Documents',false);
    
    if (!String.isBlank(errorsCompilation)){createCaseComment(caseId, errorsCompilation);}
    try {update tidscase;} catch (Exception e){}
  }
  // TIDS Configuration
  private static String tidsCompileErrors(List<TIDS_Controller.verror> errors, String errorType, boolean isfirst){
	String textErrors = '';
	if (errors==null) {return textErrors;}
	if (errors.size()==0){return textErrors;}
	textErrors = (isfirst ? '':'\n') + 'Section Name :' + errorType+'\n';
	for (TIDS_Controller.verror tidsError : errors){
		textErrors +='Field: ' +tidsError.fieldLabel +'\n' +'Description: ' +tidsError.description +'\n';
	}
	return textErrors;
  }
  private static void createCaseComment(String caseId, String comments){
	CaseComment c = new CaseComment();
	c.ParentId = caseId;
	c.isPublished  = true;
	c.CommentBody = comments;
    try {insert c;} catch (Exception e){}
  }
  

  private static void changeCaseStatus(String caseId, String caseStatus){
    cases = TIDSUtil.getTidsCases(caseId,false);
    Case tidsCase = new Case();
    if (cases.size() > 0){
       tidsCase = cases[0];
       tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
       tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
       tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
       tidscase.Status = caseStatus;
    }
    update tidscase;
  }

  public class ValueLabel {
    @AuraEnabled public String value;
    @AuraEnabled public String label;
    public ValueLabel(String xvalue, String xlabel){
      this.value = xvalue;
      this.label = xlabel;
    }
  }

  public static List<IATAISOCountryDTO> IATAISOCountryToDto(
    List<IATA_ISO_Country__c> iataIsoCountries){
    List<IATAISOCountryDTO> result = new List<IATAISOCountryDTO>();
    for (IATA_ISO_Country__c state : iataIsoCountries){
      IATAISOCountryDTO countryDto = new IATAISOCountryDTO(
        state.Name,
        state.ISO_Code__c,
        state.Id
      );
      result.add(countryDto);
    }
    return result;
  }

  public static void IATAISOStateToDto(){    
    for (IATA_ISO_State__c s : states){
      IATAISOStateDTO sDto = new IATAISOStateDTO(
        s.Name,
        s.ISO_Code__c,
        s.Id
      );
      isoStateDto.add(sDto);
    }
  }

  public class IATAISOStateDTO {
    @AuraEnabled public String Id;
    @AuraEnabled public String value;
    @AuraEnabled public String label;
    public IATAISOStateDTO(String label, String value, String id){
      this.Id = id;
      this.value = value;
      this.label = label;
    }
  }

  public class IATAISOCountryDTO {
    @AuraEnabled public String Id;
    @AuraEnabled public String value;
    @AuraEnabled public String label;
    public IATAISOCountryDTO(String label, String value, Id id){
      this.label = label;
      this.value = value;
      this.Id = id;
    }
  }
}