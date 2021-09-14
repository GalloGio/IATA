//TIDSHelper
public without sharing class TIDSHelper {
	private static TidsWrapper tidsWrapper {get;set;}
	private static List<IATA_ISO_State__c> states {get;set;}
	private static List<IATAISOStateDTO> isoStateDto {get;set;}
	private static Portal_Applications__c tidsConfiguration {get;set;}
	private static Id agencyRecordTypeId {get;set;}
	public static boolean bypass=false;

	//Verify if the account exists and is valid, if the contact exists and is contact under the account
	//Verify if there is or not a valid HO Administrator
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper verifyRole(Id accountId, Id contactId){
		//Account and Contact verification

		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		List<Contact> contacts = new List<Contact>();
		contacts = [SELECT Id, Account.Name, FirstName, LastName 
					FROM Contact 
					WHERE AccountId=:accountId
						AND Id=:contactId
						AND Email!=null
						AND Status__c=:TIDS_Constant.IS_ACTIVE
						AND (account.Location_Type__c=:TIDS_Constant.TIDS_HO 
							and account.RecordType.DeveloperName=:TIDS_Constant.RT_AGENCY
							and account.Status__c=:TIDS_Constant.IS_APPROVED
							and account.Location_Class__c=:TIDS_Constant.TIDS_T)
					Limit 1];
		if (contacts.size()==0){
			TIDSUtil.setError(TIDS_Constant.MSG40,false);
			return TIDSUtil.iataCodeError;
		}
		List<User> users = new List<User>();
		users = [Select Id,contactId 
					From User 
					Where isActive=true 
					and contactId=:contactId
					Limit 1];
		if (users.size()==0){
			TIDSUtil.setError(TIDS_Constant.MSG42,false);
			return TIDSUtil.iataCodeError;
		}
		//Account has already HOP
		List<Portal_Application_Right__c> appusers  =getPortalRight(accountId, 
			' (Access_Status_Reason__c=\''+TIDS_Constant.ADM_HOP+'\')',
			' LIMIT 1');
		if (appusers.size()==1){
			TIDSUtil.setError(TIDS_Constant.MSG41,false);
			return TIDSUtil.iataCodeError;
		}
		TIDSUtil.iataCodeError.info = '{"accountname":"'+contacts[0].Account.Name +'","firstname":"'+contacts[0].FirstName+'","lastname":"'+contacts[0].LastName+'"}';
		return TIDSUtil.iataCodeError;
	}
	// Creates the HO Administrator Role
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper createRole(Id accountId, Id contactId){
		//Account and Contact verification again in case something happen in between
		TIDSUtil.iataCodeError = verifyRole(accountId, contactId);
		if (TIDSUtil.iataCodeError.hasAnError){
			return TIDSUtil.iataCodeError;
		}
		TIDSUtil.grantTIDSPortalAccess(contactId);
		return TIDSUtil.iataCodeError;
	}

	//Verify if the list of accounts (string semi-comma separated) is valid
	//Account must a set of valid HO Accounts
	//The cascading key is incorrect
	//One or All of the Account ids is not compliant with the selection criteria
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper verifyCascading(String accountList, String cascadingkey){
		//Account and Contact verification
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		if (!bypass && cascadingkey!=TIDSUtil.getTIDSMetadataError(TIDS_Constant.CASCADE_PASSWORD)){
			TIDSUtil.setError(TIDS_Constant.MSG45,false);
			return TIDSUtil.iataCodeError;
		}
		List<String> accountIds = accountList.split(';');
		List<Account> accounts = new List<Account>();
		accounts = [SELECT Id
					FROM Account 
					WHERE id=:accountIds
						AND (Location_Type__c=:TIDS_Constant.TIDS_HO 
							and RecordType.DeveloperName=:TIDS_Constant.RT_AGENCY
							and Status__c=:TIDS_Constant.IS_APPROVED
							and Location_Class__c=:TIDS_Constant.TIDS_T)
					Limit 20];
		if (accounts.size()!=accountIds.size()){
			TIDSUtil.setError(TIDS_Constant.MSG40,false);
		}
		return TIDSUtil.iataCodeError;
	}

	// Creates the Cascading bacth Process to replicate HO Administrator Information
	// function will be called multiple times by the interface depending on the number of accounts listed
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper createCascading(String accountList, String cascadingkey){
		//Account and Contact verification again in case something happen in between
		List<String> accountIds = accountList.split(';');
		TIDSUtil.iataCodeError = verifyCascading(accountList, cascadingkey);
		if (TIDSUtil.iataCodeError.hasAnError){
			return TIDSUtil.iataCodeError;
		}
		for(String a:accountIds){
			TidsBatchCascading nb = new TidsBatchCascading();
			nb.caseId=a;
			Database.executeBatch(nb,100);	
		}
		return TIDSUtil.iataCodeError;
	}

	//Checks if the vetting has been completed if true then redirects to the condition page
	//with merged fields
	@AuraEnabled
	public static TIDS_Error_Message__mdt getVettingDoneCondition(String tidsCaseId){
		TIDSUtil.replaceby = new List<String>{'', '','','',''};
		if (tidsCaseId!=null){
			TIDSUtil.getTidsCases(tidsCaseId,false);
			if (TIDSUtil.cases.size()>0){
				Case tidscase =  TIDSUtil.cases[0];
				string email = '';
				final String portalType=(tidscase.Account.Location_Type__c!=TIDS_Constant.TIDS_HO) ? TIDS_Constant.ADM_BRA : TIDS_Constant.ADM_HOP;
				List<Portal_Application_Right__c> applicationRights =[SELECT Contact__r.Email
					FROM Portal_Application_Right__c
					WHERE Right__c=:AMS_Utils.PORTAL_APP_ACCESS_GRANTED 
						AND Contact__r.AccountId=:tidscase.AccountId
						AND Access_Status_Reason__c=:portalType
						AND Application_Name__c=:TIDS_Constant.TIDSVALUE
						LIMIT 1];
				if (applicationRights.size()>0) {
					email=applicationRights[0].Contact__r.Email;
				}
				String formattedDate = tidscase.createdDate.format('yyyy-MM-mm');
				TIDSUtil.replaceby = new List<String>{email, tidscase.CaseNumber,tidscase.Status,tidscase.Decision__c,formattedDate};
				if (!(tidscase.Status==TIDS_Constant.IS_CLOSED || tidscase.Status==TIDS_Constant.IS_ABANDONED  || tidscase.Status==TIDS_Constant.IS_CUSTOMER)){
					return null;
				}
			}
		}    
		return TIDSUtil.getTIDSMetadata(TIDS_Constant.VETTING_DONE);
	}
	

	@AuraEnabled
	public static List<Account> getSortedBranches(String accountIds, String name, String order, String search, Boolean allrecords){
		List<Account> listvalues = new List<Account>();
		List<Account> listreturned = new List<Account>();
		if (accountIds==null){ return listvalues;}
		//find out if a branch or head office
		string queryWhere = ' Where RecordType.DeveloperName=\''+TIDS_Constant.RT_AGENCY+
							'\' and Location_Class__c=\''+TIDS_Constant.TIDS_T+'\' And ParentId=:accountIds';
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

		if (!String.isEmpty(search)){
			search = '%' +search +'%';
			queryWhere += ' And (Name Like :search or TradeName__c like :search or IATACode__c Like :search or BillingCity Like :search)';
		}
		string accred = ',(Select Id, Virtual_Branch_Enabled__c,TIDS_Reinstatement_DeadLine__c From  Accreditation__r  Limit 1)';
		string rights = ',(SELECT Contact__r.Firstname, Contact__r.Lastname FROM Portal_Application_Right__c WHERE Right__c=\''+
						AMS_Utils.PORTAL_APP_ACCESS_GRANTED+
						'\' and Contact__r.AccountId=:accountIds Limit 2) ';
		string query ='SELECT  ' +queryFields +accred +' FROM Account' +
				queryWhere +' Order By ' +
				name +' ' +order;
		if (String.isEmpty(search) && !allrecords){
			query +=' Limit 10';
		}

		listvalues = Database.query(query);
		if (listvalues.size()>0){
			for(Account a:listvalues){
				boolean isadded=true;
				if (a.Status__c==TIDS_Constant.IS_TERMINATED){
					for(Accreditation__c c:a.Accreditation__r){
						if (c.TIDS_Reinstatement_DeadLine__c<System.today()){
							isadded=false;
						}
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
		if (users.size()>0){ 
			return users[0].Contact.Account.country_ISO_Code__c;
		}
		return null;     
	}
	@AuraEnabled
	public static List<Case> getSortedCases(String accountIds,String name, String order, String search, Boolean allrecords){
		List<Case> caseValues = new List<Case>();
		final string recordtype=TIDSUtil.getTidsRecordTypeId();
		final string caseorigin = TIDS_Constant.CASE_ORIGIN;
		string query='SELECT Id, CaseNumber, Status, Subject, createdDate FROM Case';
		query +=' WHERE AccountId=:accountIds and recordTypeId=:recordtype and Origin=:caseorigin';
		if (!String.isEmpty(search)){
			search = '%' +search +'%';
			query += ' And (CaseNumber Like :search or Subject like :search)';
		}
		query +=' and Status in (\'Pending Review\', \'Review in Progress\', \'Pending customer\', \'Closed\')';
		query +=' Order By ' +name +' ' +order;
		if (String.isEmpty(search) && !allrecords){
			query +=' Limit 5';
		} 
		caseValues = Database.query(query);
		
		return caseValues;
	}
	
	//Gets the countries code depending if it is mailing or address
	public static List<IATAISOCountryDTO> getCountries(string type){
		List<IATAISOCountryDTO> options = new List<IATAISOCountryDTO>();
		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

		tidsConfiguration = TIDSUtil.getTIDSService();
		
		string excludedcountriescode=tidsConfiguration.TIDS_Non_Eligible_Location_Countries__c;
		if (type==TIDS_Constant.ACTION_MAILING) {
			excludedcountriescode=tidsConfiguration.TIDS_Non_Eligible_Mailing_Countries__c;
		}
		if (excludedcountriescode==null) {
			excludedcountriescode='';
		}
		final String nonEligiblesCountries ='\'' +excludedcountriescode.replace(',', '\',\'') +'\'';
		String query ='SELECT Id ,Name,ISO_Code__c,State_Province_Mandatory__c FROM IATA_ISO_Country__c';
		query +=' WHERE ISO_Code__c NOT IN (' +nonEligiblesCountries +')';
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

	//get all the states for a given country
	@AuraEnabled(cacheable=false)
	public static List<IATAISOStateDTO> getState(String countryIsoCode){
		states = new List<IATA_ISO_State__c>();
		isoStateDto = new List<IATAISOStateDTO>();
		tidsConfiguration = TIDSUtil.getTIDSService();
		List<String> neligible = new List<String>();
		string nelist = tidsConfiguration.TIDS_Countries_with_Invalid_ISO_States__c;
		if (!String.isEmpty(nelist)){
			neligible = nelist.split(',');
		}
		if (!String.isEmpty(countryIsoCode) && neligible.size()>0){
			for(String c:neligible){
				if (c==countryIsoCode){ 
					return isoStateDto;
				}
			}
		}
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

	//Condition 8
	@AuraEnabled
	public static TIDSUtil.ErrorWrapper companyNameUnique(
		String accountid,
		String companyName,
		String countryIsoCode){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		Boolean isUnique;
		Id agencyRecordTypeId =RecordTypeSingleton.getInstance().getRecordTypeId('Account', TIDS_Constant.RT_AGENCY);
	 
		final String companyNameTrimmed = companyName.trim();
		if (String.isEmpty(accountid)) {
			accountid=null;
		}
		List<Account> accounts = [SELECT Id
			 ,Name
			 ,Status__c
			 ,Email__c
			 ,Parent.Email__c
			 ,(Select Id, Virtual_Branch_Enabled__c,TIDS_Reinstatement_DeadLine__c From  Accreditation__r  Limit 1)
			FROM Account
			WHERE Name=:companyNameTrimmed
				AND Id!=:accountid
				AND Location_Class__c=:TIDS_Constant.TIDS_T
				AND (Status__c=:TIDS_Constant.IS_APPROVED or Status__c=:TIDS_Constant.IS_TERMINATED)
				AND Location_Type__c=:TIDS_Constant.TIDS_HO
				AND IATA_ISO_Country__r.ISO_Code__c=:countryIsoCode];

		if (accounts.size() > 0){
			TIDSUtil.replaceby = new List<String> {'','','','',''};
			boolean isdeduplicate=false;
			for(Account a:accounts){
				if (a.Status__c==TIDS_Constant.IS_APPROVED) {
					isdeduplicate=true;
					break;
				}
				for(Accreditation__c c:a.Accreditation__r){
					//Check Date Reinstam
					Date rdate =c.TIDS_Reinstatement_DeadLine__c;
					if (rdate==null || rdate>=System.today()){
						isdeduplicate=true;
						break;
					}
				}
			}
			if (isdeduplicate){
				TIDSUtil.setError(TIDS_Constant.MSG3,false);
				TIDSUtil.iataCodeError.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON8); 
				return TIDSUtil.iataCodeError;
			}
		}
		Accreditation__c accountAccredited = accountHasReinstatement(companyNameTrimmed,countryIsoCode);
		if (accountAccredited != null){
			TIDSUtil.setError(TIDS_Constant.MSG3,false);
			TIDSUtil.iataCodeError.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON8);
		}
		return TIDSUtil.iataCodeError;
	}
	private static Accreditation__c accountHasReinstatement(
		String companyName,
		String countryIsoCode){
		Accreditation__c account;
		final String companyNameTrimmed = companyName.trim();
		List<Accreditation__c> accountsAccredited = [SELECT Id,
				Status__r.Code__c,
				Related_Account__r.Name,
				Related_Account__r.IATA_ISO_Country__r.ISO_Code__c,
				TIDS_Reinstatement_DeadLine__c,
				Termination_date__c
			FROM Accreditation__c
			WHERE Status__r.Code__c='0' 
				AND Class__r.Code__c=:TIDS_Constant.TIDS_T
				AND Related_Account__r.Name=:companyNameTrimmed
				AND Related_Account__r.IATA_ISO_Country__r.ISO_Code__c=:countryIsoCode
				AND TIDS_Reinstatement_DeadLine__c>=TODAY
			ORDER BY Termination_Date__c DESC];    
		if (accountsAccredited.size() > 0){
			account = accountsAccredited.get(0);
		}
		return account;
	}

	//Returns tidswrapper structure with the tids case record info and service info 
	//and the account info
	@AuraEnabled(cacheable=false)
	public static TidsWrapper getTidsCase(String caseId, String userId){
		tidsWrapper = new TidsWrapper();
		tidsConfiguration = TIDSUtil.getTIDSService();
		if (tidsConfiguration.Id!=null){
			tidsWrapper.businessRules = tidsConfiguration;
			tidsWrapper.tidsConfiguration = TIDSUtil.getAttachment(tidsConfiguration.Id,TIDS_Constant.TIDSCONFIGURATIONFILE);
		}

		tidsWrapper.currentUser = TIDSUtil.getUserData(userId);
		TIDSUtil.getTidsCases(caseId,false);
		if (TIDSUtil.cases.size() > 0){
			tidsWrapper.tidsCase = TIDSUtil.cases[0];
			tidsWrapper.tidsAttachment = TIDSUtil.getAttachment(caseId,TIDS_Constant.DATAJSONFILENAME);
		}
		return tidsWrapper;
	}
	//discard the HO application 
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper setCaseInProgress(String caseId, String userId){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		TIDSUtil.getTidsCases(caseId,false);
	
		Savepoint sp = Database.setSavepoint();
		try {
			TIDSUtil.changeCaseStatus(TIDS_Constant.IS_INPROGRESS, userId);
		}catch(Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSHelper - setCaseInProgress] e.getMessage() - ' + e.getMessage());
			//manage the error
		}
		return TIDSUtil.iataCodeError;
	}
 
	@AuraEnabled(cacheable=false)
	public static TidsWrapper getUserInfo(Id userId){
		agencyRecordTypeId =RecordTypeSingleton.getInstance().getRecordTypeId('Account', TIDS_Constant.RT_AGENCY);  
			
		tidsWrapper = new TidsWrapper();
		try {
			tidsConfiguration = TIDSUtil.getTIDSService();
			if (tidsConfiguration.Id!=null){
				tidsWrapper.businessRules = tidsConfiguration;
				// Fields Configuration
				tidsWrapper.tidsConfiguration = '';
				tidsWrapper.tidsConfiguration = TIDSUtil.getAttachment(tidsConfiguration.Id,TIDS_Constant.TIDSCONFIGURATIONFILE);
			}

			tidsWrapper.currentUser =TIDSUtil.getUserData(userId);      
			String caseNumber='';
			String email='';
			final String portalType1=(tidsWrapper.currentUser.Account.Location_Type__c!=TIDS_Constant.TIDS_HO) ? TIDS_Constant.ADM_BRA : TIDS_Constant.ADM_HOP;
			final String portalType2=(tidsWrapper.currentUser.Account.Location_Type__c!=TIDS_Constant.TIDS_HO) ? TIDS_Constant.ADM_BRA : TIDS_Constant.ADM_HOS;
			List<Portal_Application_Right__c> applicationRights =[SELECT 
					 Id,
					 Right__c,
					 Contact__r.Id, 
					 Access_Status_Reason__c,
					 Application_Name__c,
					 Contact__r.Email
				FROM Portal_Application_Right__c
				WHERE Contact__r.Id=:tidsWrapper.currentUser.ContactId
					AND Application_Name__c=:TIDS_Constant.TIDSVALUE
					LIMIT 1];
			if (applicationRights.size()==0) {		
				//Condition 0: trying to access Tids application
				tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON0_1);
				return tidsWrapper;
			}else{
				if (applicationRights[0].Right__c==AMS_Utils.PORTAL_APP_ACCESS_GRANTED
					&& (applicationRights[0].Access_Status_Reason__c==portalType1
						|| applicationRights[0].Access_Status_Reason__c==portalType2)){
						tidsWrapper.profile = applicationRights.get(0);
				}
				email=applicationRights[0].Contact__r.Email;
			}
			TIDSUtil.replaceby = new List<String>{email, caseNumber,'','',''};
			
			
			string rdevname =tidsWrapper.currentUser.Account.RecordType.DeveloperName;
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
			if (cl1.Contains(rdevname)){
				tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON1);
				return tidsWrapper;
			}
			// TIDS Case
			Id recordname=tidsWrapper.currentUser.Account.RecordType.Id;
			string countryiso=tidsWrapper.currentUser.Account.Country_ISO_Code__c;
			string status=tidsWrapper.currentUser.Account.Status__c;
			if (String.isEmpty(recordname)){return tidsWrapper;}
			// Country validation rules
			List<String> neligible = new List<String>();
			string nelist = tidsConfiguration.TIDS_Non_Eligible_Location_Countries__c;
			if (!String.isEmpty(nelist)){
				neligible = nelist.split(',');
			}
			if (!String.isEmpty(countryiso) && neligible.size()>0){
				//Load the country codes from Portal_Applications__c.TIDS_Non_Eligible_Location_Countries__c 
				//Condition 2: Related Account “Country_ISO_Code__c” cannot be “AS, GU, MP, PR, US, VI”
				List<IATA_ISO_Country__c> countries = [SELECT Sanctioned_Country__c FROM IATA_ISO_Country__c WHERE ISO_Code__c=:countryiso AND ISO_Code__c=:neligible Limit 1];
				if (countries.size()>0) {
					tidsWrapper.error = TIDSUtil.getTIDSMetadata(countries[0].Sanctioned_Country__c ? TIDS_Constant.ERROR_CON2_2 : TIDS_Constant.ERROR_CON2_1);
					return tidsWrapper;
				}
			}
			
			string c3=tidsWrapper.currentUser.Account.Location_Class__c;
			//Condition 3: Related Account Record Type cannot be “Agency”  WHERE Account “Location_Class__c“ = “D, P“
			if (!String.isEmpty(c3)){
				if (condition3(c3, recordname)) {
					return tidsWrapper;
				}
			}
			Date rdate=System.today();
			if (!String.isEmpty(status)){
				if (c3==null) {
					c3='';
				}
				if (status==TIDS_Constant.IS_TERMINATED){
					rdate = isReinstated(tidsWrapper.currentUser.AccountId);
					if (rdate==null) {
						rdate=System.today();
					}
				}
				//Condition 4: Related Account Record Type cannot be “Agency“ WHERE Account “Location_Class__c = “T“ and Status__c = “Approved”
				if (recordname==agencyRecordTypeId 
					&& c3==TIDS_Constant.TIDS_T 
					&& (status==TIDS_Constant.IS_APPROVED 
					|| (status==TIDS_Constant.IS_TERMINATED && rdate>=System.today()))){
					//Access Grated or Access Denied
					if (condition4(applicationRights)) {
						return tidsWrapper;
					}
				}
				//Condition 5: Related Account Record Type cannot be “Agency“ WHERE Account “Location_Class__c = “T“ and Status__c = “Terminated”
				if (recordname==agencyRecordTypeId 
					&& c3==TIDS_Constant.TIDS_T 
					&& status==TIDS_Constant.IS_TERMINATED){
					rdate = isReinstated(tidsWrapper.currentUser.AccountId);
					if (rdate!=null){
						if (rdate<System.today()){
							tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON5);
							return tidsWrapper;
						}
					}
				}
				//Condition 6: Related Account Record Type cannot be “Agency“ WHERE Account “Location_Class__c = “T“ and Status__c!=“Approved, Terminated”
				//c3 is null to be taken in consideration check c3 null in above code
				if (condition6(c3, recordname, status)) {
					return tidsWrapper;
				}          
			}else{
				if (condition6b(c3, recordname)) {
					return tidsWrapper;
				}
			}
			// Condition 7: Related Account cannot have an ongoing New TIDS HO Application
			// Case open for HO Application
			if (condition7(email, status)) {
				return tidsWrapper;
			}
			
		} catch (DmlException e){
			System.debug(loggingLevel.FINE, '____ [TIDSHelper -  getUserInfo] e.getMessage() - ' + e.getMessage());
			throw e;
		}
		return tidsWrapper;
	}
	
	private static boolean condition4(List<Portal_Application_Right__c>  applicationRights){
		//Access Grated or Access Denied
		boolean isparentadmin = false;	
		List<Portal_Application_Right__c> adminrights = new List<Portal_Application_Right__c>();
		adminrights = [SELECT Id, Right__c, Contact__r.email
							FROM Portal_Application_Right__c
							WHERE (Contact__r.AccountId=:tidsWrapper.currentUser.Account.ParentId
								Or Contact__r.AccountId=:tidsWrapper.currentUser.AccountId)
								AND Right__c=:AMS_Utils.PORTAL_APP_ACCESS_GRANTED
								AND Access_Status_Reason__c!=null
								AND Application_Name__c=:TIDS_Constant.TIDSVALUE 
								Order by Access_Status_Reason__c Desc LIMIT 1];
		if (adminrights.size()>0) {
			isparentadmin=true;
		}    
		boolean isdenied=true;
		if (applicationRights.size()>0){
			if (tidsWrapper.profile.Right__c==AMS_Utils.PORTAL_APP_ACCESS_GRANTED && tidsWrapper.profile.Access_Status_Reason__c!=null){
				isdenied=false;
			}
		}
		if (isdenied){
			//mettre un mask sur l'email
			//Access denied but there is admin
			//Parent Case
			tidsWrapper.tidsCase = TIDSUtil.searchCase(tidsWrapper.currentUser.AccountId,TIDS_Constant.IS_CLOSED);
			tidsWrapper.tidsAttachment = TIDSUtil.getAttachment(tidsWrapper.tidsCase.Id,TIDS_Constant.DATAJSONFILENAME);
			//retrieve email
			adminrights = [SELECT Contact__r.email
							FROM Portal_Application_Right__c
							WHERE (Contact__r.AccountId=:tidsWrapper.currentUser.Account.ParentId
								Or Contact__r.AccountId=:tidsWrapper.currentUser.AccountId)
								AND Access_Status_Reason__c=:TIDS_Constant.ADM_HOP
								AND Application_Name__c=:TIDS_Constant.TIDSVALUE 
								LIMIT 1];
			String email = (adminrights.size()>0  ? adminrights[0].Contact__r.Email:'');
			TIDSUtil.replaceby = new List<String>{ email, '','','',''};
			tidsWrapper.error = TIDSUtil.getTIDSMetadata(isparentadmin ?TIDS_Constant.ERROR_CON4_1 : TIDS_Constant.ERROR_CON4_2);
		
			return true;
		}
		return false;
	}
	private static boolean condition6(string c3, Id recordname, string status){
		string c6=tidsWrapper.currentUser.Account.Location_Type__c;
		if (recordname==agencyRecordTypeId && ((c3==TIDS_Constant.TIDS_T 
			&& !(c6==TIDS_Constant.TIDS_BR || c6==TIDS_Constant.TIDS_HO || c6==TIDS_Constant.TIDS_VB)) 
			|| (c3==TIDS_Constant.TIDS_T 
				&& !(status==TIDS_Constant.IS_TERMINATED || status==TIDS_Constant.IS_APPROVED)) || String.isEmpty(c3)) ){
			tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON6);
			return true;
		}
		return false;
	} 
	private static boolean condition3(string c3, Id recordname){
		Set<String> cl3 = new Set<String>{'C','D','G','I','K','M','P','Q','R','V','W','X'};
		c3= c3.toUpperCase();
		if (recordname==agencyRecordTypeId && cl3.Contains(c3)){
			tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON3);
			return true;
		}
		return false;
	}
	private static boolean condition6b(string c3, Id recordname){
		if (c3==null) {
			c3='';
		}
		c3=c3.toUpperCase();
		if (recordname==agencyRecordTypeId && c3==TIDS_Constant.TIDS_T){
			tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON6);
			return true;
		}
		return false;
	}
	private static List<Case> getTidsCaseNewApplication(Id accountId){
		final Set<string> statuses = new Set<String>{TIDS_Constant.IS_DRAFT, TIDS_Constant.IS_REVIEWED, TIDS_Constant.IS_INPROGRESS, TIDS_Constant.IS_CUSTOMER};
		List<Case> cases =[SELECT Id, CaseNumber, AccountId, ContactId, RecordTypeId, Status, Decision__c, CreatedDate
			FROM Case
			WHERE Status in :statuses
			AND AccountId=:accountId 
			AND Reason1__c=:TIDS_Constant.NEW_APP
			AND RecordTypeId=:TIDSUtil.getTidsRecordTypeId() Limit 1];
		return cases;
	}
	private static boolean condition7(String email, string status){		
		List<Case> cases =getTidsCaseNewApplication(tidsWrapper.currentUser.AccountId);
		if (cases.size()==0){
			return false;
		}
		condition7b(cases[0],email, status);
		return true;
	}
	private static boolean condition7b(Case tidscase,String email, string status){		
		final String formattedDate = tidscase.createdDate.format('yyyy-MM-dd');
		TIDSUtil.replaceby = new List<String>{email,tidscase.CaseNumber, tidscase.Status,tidscase.Decision__c, formattedDate};
		tidsWrapper.tidsCase = tidscase;
		if (tidscase.ContactId==tidsWrapper.currentUser.ContactId){
			//7.1
			//Draft ==> 7_1_Draft
			//Pending Review ==> 7_1_Pending_Review
			status  = tidscase.Status;
			status = '_'+status.replaceAll(' ', '_');
			tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON7_1+status);
		}else{
			//7.2 ==>it is yours create a new case with case# (@case @status)
			tidsWrapper.error = TIDSUtil.getTIDSMetadata(TIDS_Constant.ERROR_CON7_2);
		}          
		final String result = TIDSUtil.getAttachment(tidscase.Id, TIDS_Constant.DATAJSONFILENAME);
		if (!String.isEmpty(result)){
			tidsWrapper.tidsAttachment = result;
		}
		return true;
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
	
	//Promotes the case to the vetting application
	//Resumes the case to its last entry form becasue the partner user has not complete the application process
	//Recalls the application after the partner user has completed it
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper  actionApplication(String caseId, String action){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		TIDSUtil.iataCodeError.hasAnError=true;
		TIDSUtil.getTidsCases(caseId,false);
		if (TIDSUtil.cases.size()==0) {
			return TIDSUtil.iataCodeError;
		}
		Case tidscase = TIDSUtil.cases[0];
		Savepoint sp = Database.setSavepoint();
		try {
			if (action==TIDS_Constant.ACTION_VETTING){
				if (tidscase.Status!=TIDS_Constant.IS_REVIEWED) {
					return TIDSUtil.iataCodeError;
				}
			}else if (action==TIDS_Constant.ACTION_RESUME || action==TIDS_Constant.ACTION_DISCARD){
				if (tidscase.Status!=TIDS_Constant.IS_DRAFT) {
					return TIDSUtil.iataCodeError;
				}
			}else if (action==TIDS_Constant.ACTION_RECALL){
				if (tidscase.Status!=TIDS_Constant.IS_REVIEWED) {
					return TIDSUtil.iataCodeError;
				}
				TIDSUtil.changeCaseStatus(TIDS_Constant.IS_DRAFT,null);
			}
			TIDSUtil.iataCodeError.hasAnError=false;
		}catch(Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSHelper -  actionApplication] e.getMessage() - ' + e.getMessage());
			//manage the error
		}
		return TIDSUtil.iataCodeError;
	}

	//discard the HO application 
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper  discardApplication(String caseId){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		TIDSUtil.getTidsCases(caseId,false);
	
		Savepoint sp = Database.setSavepoint();
		try {
			TIDSUtil.changeCaseStatus(TIDS_Constant.IS_ABANDONED,null);
		}catch(Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSHelper -  discardApplication] e.getMessage() - ' + e.getMessage());
			//manage the error
		}
		return TIDSUtil.iataCodeError;
	}

	//Save or create the case and add the data.json as attachment
	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper saveSettings(
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
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		Savepoint sp = Database.setSavepoint();
		try {
			if (caseId!=null){
				TIDSUtil.getTidsCases(caseId,false);
			}else if (tidsCaseSubject!=null){
				List<Case> todelete = new List<Case>();
				todelete = [SELECT Id, Status  
								FROM Case 
								WHERE AccountId=:accountId 
								AND Subject=:tidsCaseSubject 
								AND Status=:TIDS_Constant.IS_DRAFT];
				if (todelete.size() > 0) {
					delete todelete;
				}
				TIDSUtil.cases = [SELECT Id FROM Case WHERE AccountId=:accountId 
					AND Subject=:tidsCaseSubject
					AND Status!=:TIDS_Constant.IS_CLOSED
					ORDER BY CreatedDate Desc LIMIT 1];
				if (TIDSUtil.cases.size() > 0){
					TIDSUtil.getTidsCases(TIDSUtil.cases[0].Id,false);
				}
			}
			if (TIDSUtil.cases!=null){
				if (TIDSUtil.cases.size() > 0){
					tidsCase = TIDSUtil.cases[0];
				}
			}
			tidsCase = createTidsCase(tidsCase.Id,
				accountId,
				applicationtype,
				applicationsettings
			);
			TIDSUtil.iataCodeError.caseId= tidsCase.Id;
		}catch (Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSHelper -  saveSettings] e.getMessage() - ' + e.getMessage());
			//manage the error
		}
		return TIDSUtil.iataCodeError;
	}

	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper assignToCaseOwner(Id caseId){
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		Id userId = UserInfo.getUserId();
		TIDSUtil.getTidsCases(caseId,false);
		if (TIDSUtil.cases.size() == 0){
			TIDSUtil.setError(TIDS_Constant.MSG43,false); 
			return TIDSUtil.iataCodeError;
		}
		if (TIDSUtil.cases[0].status == TIDS_Constant.IS_REVIEWED && userId!=TIDSUtil.cases[0].OwnerId){
			TIDSUtil.setError(TIDS_Constant.MSG44,false); 
			return TIDSUtil.iataCodeError;
		}
		if (TIDSUtil.cases[0].status == TIDS_Constant.IS_REVIEWED){
			return TIDSUtil.iataCodeError;
		}
		TIDSUtil.cases[0].status = TIDS_Constant.IS_REVIEWED;
		TIDSUtil.cases[0].OwnerId = userId;
		Savepoint sp = Database.setSavepoint();
		try {
			update TIDSUtil.cases;
		}catch (Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSHelper -  assignToCaseOwner] e.getMessage() - ' + e.getMessage());
			//manage the error
		}
		return TIDSUtil.iataCodeError;
	}
	

	@AuraEnabled(cacheable=false)
	public static TIDSUtil.ErrorWrapper  contactApplicant(String caseId,
										String caseStatus,
										String applicationsettings){
		Savepoint sp = Database.setSavepoint();
		TIDSUtil.iataCodeError = new TIDSUtil.ErrorWrapper();
		try {
			TIDSUtil.getTidsCases(caseId,false);
			Case tidscase  = new Case();
			tidscase = TIDSUtil.cases[0];
			if (tidsCase.Status!=TIDS_Constant.IS_INPROGRESS){
				TIDSUtil.setError(TIDS_Constant.MSG11,false);
				return TIDSUtil.iataCodeError;
			}
		
			tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
			tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
			tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
			tidsCase.Status = caseStatus;
			TIDSUtil.addAttachment(caseId, applicationsettings,TIDS_Constant.DATAJSONFILENAME);
		
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
			
			if (!String.isBlank(errorsCompilation)){
				TIDSUtil.createCaseComment(true, caseId, errorsCompilation);
			}
			update tidscase;
		
		}catch (Exception e){
			Database.rollback(sp);
			TIDSUtil.setError(e.getMessage(),true);
			System.debug(loggingLevel.FINE, '____ [TIDSHelper -  contactApplicant] e.getMessage() - ' + e.getMessage());
			//manage the error
		}
		return TIDSUtil.iataCodeError;
	}

	//creates the TIDS case
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
			if (apptypes.Contains(applicationType)){
				tidsCase.Status = TIDS_Constant.IS_REVIEWED;
			}
			tidsCase.Origin = TIDS_Constant.CASE_ORIGIN;
			tidsCase.AccountId = accountId;
			tidsCase.recordtypeid =TIDSUtil.getTidsRecordTypeId();
		} 
		tidsCase.Reason1__c = caseReasonText(applicationType);
		tidsCase.Subject = caseSubjectText(applicationType);
		tidsCase.CaseArea__c = TIDS_Constant.CASE_AREA;
		tidsCase.Priority = TIDS_Constant.CASE_PRIORITY;
		upsert tidsCase;
		if (apptypes.Contains(applicationType)){
			if (!String.isBlank(applicationsettings)){
				TIDSUtil.createCaseComment(true,tidsCase.Id, applicationsettings);
			}
			//applicationsettings is the reason why the request is made
		}else{
			TIDSUtil.addAttachment(tidsCase.Id, applicationsettings,TIDS_Constant.DATAJSONFILENAME);
		}
		return tidsCase;
	}  

	public static String caseSubjectText(String applicationType){
		String subject = TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE;
		Map<String, String> types = new Map<String, String>();
		types.put(TIDS_Constant.NEW_HO,TIDS_Constant.CASE_SUBJECT_HEAD_OFFICE);
		types.put(TIDS_Constant.NEW_BR,TIDS_Constant.CASE_SUBJECT_BRANCH);
		types.put(TIDS_Constant.NEW_VB,TIDS_Constant.CASE_SUBJECT_VIRTUAL_BRANCH);
		types.put(TIDS_Constant.CHG_PROFILE,TIDS_Constant.CASE_SUBJECT_BUSINESS_PROFILE_SPECIALIZATION);
		types.put(TIDS_Constant.CHG_ADDRESS,TIDS_Constant.CASE_SUBJECT_ADDRESS_CONTACT);
		types.put(TIDS_Constant.CHG_NAME,TIDS_Constant.CASE_SUBJECT_NAME_COMPANY);
		types.put(TIDS_Constant.RQT_VIRTUALB,'TIDS – Virtual Branch Access Request');
		types.put(TIDS_Constant.RELINQ_HO,'TIDS – Head Office Relinquishment');
		types.put(TIDS_Constant.RELINQ_VB,'TIDS – Virtual Branch Relinquishment');
		types.put(TIDS_Constant.RELINQ_BR,'TIDS – Branch Office Relinquishment');
		types.put(TIDS_Constant.REINSTATE_HO,'TIDS – Head Office Reinstatement');
		types.put(TIDS_Constant.REINSTATE_BR,'TIDS – Branch Office Reinstatement');
		types.put(TIDS_Constant.REINSTATE_VB,'TIDS – Virtual Branch Reinstatement');
		if (types.ContainsKey(applicationType)){
			subject = (String) types.get(applicationType);
		}
		return subject;
	}

	public static String caseReasonText(String applicationType){
		String subject = TIDS_Constant.NEW_APP;
		Map<String, String> types = new Map<String, String>();
		types.put(TIDS_Constant.NEW_HO,TIDS_Constant.NEW_APP);
		types.put(TIDS_Constant.NEW_BR,'TIDS - New BR Application');
		types.put(TIDS_Constant.NEW_VB,'TIDS - New VB Application');
		types.put(TIDS_Constant.CHG_PROFILE ,'TIDS - Change of Business Profile Specialization');
		types.put(TIDS_Constant.CHG_ADDRESS,'TIDS - Change of Address or Contact Details');
		types.put(TIDS_Constant.CHG_NAME,'TIDS - Change of Name or Company Details');
		types.put(TIDS_Constant.RQT_VIRTUALB,'TIDS – VB Service Request');
		types.put(TIDS_Constant.RELINQ_HO,TIDS_Constant.CASE_REASON_RELINQUISH);
		types.put(TIDS_Constant.RELINQ_BR,TIDS_Constant.CASE_REASON_RELINQUISH);
		types.put(TIDS_Constant.RELINQ_VB,TIDS_Constant.CASE_REASON_RELINQUISH);
		types.put(TIDS_Constant.REINSTATE_HO,TIDS_Constant.CASE_REASON_REINSTATEMENT);
		types.put(TIDS_Constant.REINSTATE_BR,TIDS_Constant.CASE_REASON_REINSTATEMENT);
		types.put(TIDS_Constant.REINSTATE_VB,TIDS_Constant.CASE_REASON_REINSTATEMENT);
		if (types.ContainsKey(applicationType)){
			subject = (String) types.get(applicationType);
		}
		return subject;
	}

	//Reads all the branch information 
	@AuraEnabled(cacheable=false)
	public static TIDSSFInfo newBranch(String contactId){
		TIDSSFInfo tids = new TIDSSFInfo();
		
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
				AND Location_Class__c=:TIDS_Constant.TIDS_T
			LIMIT 1];
		 
		if (accounts.size()==0){
			return tids;
		}
		tids.tidsAccount = accounts.get(0);
		tids.shareholders = TIDSUtil.tidsShareholders(tids.tidsAccount.Id,true,true);
		tids.businessProfile = TIDSUtil.tidsBusinessProfile(tids.tidsAccount.Id);
		return tids;
	}

	//List all the contacts that potential to become administrators
	//populate a listview in the front-end
	@AuraEnabled(cacheable=false)
	public static List<Contact> getAdministrators(String accountId, String name){
		name=name+'%';
		List<Contact> contacts = [SELECT Id, FirstName, LastName FROM Contact
		WHERE AccountId=:accountId and (FirstName like :name  Or LastName like :name) 
			And Email!=null
			And Status__c=:TIDS_Constant.IS_ACTIVE
			And Id not in (SELECT Contact__c
										FROM Portal_Application_Right__c
										WHERE Right__c=:AMS_Utils.PORTAL_APP_ACCESS_GRANTED
										AND Access_Status_Reason__c!=null
										AND Application_Name__c=:TIDS_Constant.TIDSVALUE 
										AND Contact__r.AccountId=:accountId) 
			Limit 20];
		if (contacts.size()>0){
			List<Contact> newcontacts = new List<Contact>();
			Map<Id, Contact> contactmap = new Map<Id, Contact>();
			for(Contact con:contacts){contactmap.put(con.Id,con);}
			List<User> users = new List<User>();
			users = [Select Id,contactId 
						From User 
						Where isActive=true 
						and contactId=:contactmap.KeySet()
						Limit 20];
			if (users.size()==0) {
				return null;
			}
			for(User u:users){
				if (contactmap.ContainsKey(u.contactId)){
					newcontacts.add((Contact)contactmap.get(u.contactId));
				}
			}
			return newcontacts;
		}
		return null;
	}

	//Reads and add the administrators using the Access_Status_Reason__c to 
	//uniquely identify the type of administrator
	//HO Admin Primary
	//HO Admin Secondary
	//BR Admin
	//actiontype: add secondary, add administrator, remove, swap
	//isbranch: if it is a request from a branch and not the ho
	@AuraEnabled(cacheable=false)
	public static List<Portal_Application_Right__c> actionAdministrators(String accountId, String contactId, string actiontype, boolean isbranch){
		tidsConfiguration = TIDSUtil.getTIDSService();
		List<Portal_Application_Right__c> myrights = new List<Portal_Application_Right__c>();
		List<Portal_Application_Right__c> apprights = new List<Portal_Application_Right__c>();
		if (tidsConfiguration==null){ 
			return apprights;
		}
		if (actiontype==TIDS_Constant.TIDS_ACTION_ADD
			|| actiontype==TIDS_Constant.TIDS_ACTION_SWAP){
			string originid=accountId;
			if (isbranch){ 
				List<Account> parents = [SELECT parentId FROM Account WHERE Id=:accountId LIMIT 1];
				if (parents.size()>0){
					originid=parents[0].parentId;
				}
			}
			//Portal_Application_Right__c
			apprights =getPortalRight(originid, 
			' (Access_Status_Reason__c=\''+TIDS_Constant.ADM_HOP+'\' Or Access_Status_Reason__c=null)',
			' LIMIT 1');
		}
	 	//TIDS Admin HO Primary
	 	String type=TIDS_Constant.ADM_BRA;
	 	if (!isbranch){
			 type=TIDS_Constant.ADM_HOP;
		}
	 	if (actiontype==TIDS_Constant.TIDS_ACTION_ADD){
			if (apprights.size()>0 && isbranch==false){
				type=TIDS_Constant.ADM_HOS;
			}
			List<Portal_Application_Right__c> appusers  =getPortalRight(accountId, 
			' Contact__c=\''+contactId+'\' AND (Access_Status_Reason__c=\''+type+'\' Or Access_Status_Reason__c=null)',
			' LIMIT 1');
			if (appusers.size()==0){       
				Portal_Application_Right__c cu = apprights[0].clone(false);
				cu.Portal_Application__c = tidsConfiguration.Id; 
				cu.Application_uniqueness_for_contact__c=accountId+contactId;
				cu.Contact__c=contactId;
				cu.Access_Status_Reason__c= isbranch==true ? TIDS_Constant.ADM_BRA:TIDS_Constant.ADM_HOS;
				myrights.add(cu);
			}else{
				appusers[0].Access_Status_Reason__c=type;
				appusers[0].Right__c=AMS_Utils.PORTAL_APP_ACCESS_GRANTED;        
				myrights.add(appusers[0]);
			}       
		}else if (actiontype==TIDS_Constant.TIDS_ACTION_REMOVE){
			if (!isbranch){
				type=TIDS_Constant.ADM_HOS;
			}
			apprights=getPortalRight(accountId, 
			' Contact__c=\''+contactId+'\' AND Access_Status_Reason__c=\''+TIDS_Constant.ADM_HOS+'\'',
			' LIMIT 1');
			apprights[0].Right__c=AMS_Utils.PORTAL_APP_ACCESS_DENIED;       
			myrights.add(apprights[0]);      
		}else if (actiontype==TIDS_Constant.TIDS_ACTION_SWAP){
			List<Portal_Application_Right__c> appsec=getPortalRight(accountId,
			' Access_Status_Reason__c=\''+TIDS_Constant.ADM_HOS+'\'',
		 	'LIMIT 1');
			appsec[0].Access_Status_Reason__c=TIDS_Constant.ADM_HOP;
			myrights.add(appsec[0]);
			apprights[0].Access_Status_Reason__c=TIDS_Constant.ADM_HOS;
			myrights.add(apprights[0]);
		}
		if (myrights.size()>0){ 
			upsert myrights;
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
							AND Right__c=:AMS_Utils.PORTAL_APP_ACCESS_GRANTED
							Order by Access_Status_Reason__c LIMIT 2];
		return apprights;
	}

	//Returns all the administrators with a max of 2
	@AuraEnabled(cacheable=false)
	public static List<Portal_Application_Right__c> getAdmin(String accountId){
		List<Portal_Application_Right__c> apprights = getPortalRight(accountId,' Right__c=\''+AMS_Utils.PORTAL_APP_ACCESS_GRANTED+'\'',
		 'Order by Access_Status_Reason__c LIMIT 2');
		return apprights;
	}

	//Returns the portal Application Right based on dynamic clause
	private static List<Portal_Application_Right__c> getPortalRight(String accountId, String whereSelect, String orderSelect){
		List<Portal_Application_Right__c> apprights = new List<Portal_Application_Right__c>();
		whereSelect = 'WHERE '+whereSelect +' AND Contact__r.AccountId=\''+accountId+'\' AND Application_Name__c=\''+TIDS_Constant.TIDSVALUE+'\''; 
		final String selectClause = 'SELECT Id,Right__c,Application_uniqueness_for_contact__c,Application_Name__c, Contact__c, Contact__r.FirstName,Contact__r.LastName, Access_Status_Reason__c FROM Portal_Application_Right__c ' + whereSelect + orderSelect;
		apprights = Database.query(selectClause);
		return apprights;
	}  
	
	//Create the change request TIDS case
	@AuraEnabled(cacheable=false)
	public static String createTidsRequestReinstate(String accountId,String reason, String applicationType){
		return createBranch(accountId,reason,'request-reinstate-'+applicationType);
	}
	//Create the change request TIDS case
	@AuraEnabled(cacheable=false)
	public static String createTidsRequestRelinquish(String accountId,String reason, String applicationType){
		return createBranch(accountId,reason,'request-relinquish-'+applicationType);
	}
	//Create the change request TIDS case
	@AuraEnabled(cacheable=false)
	public static String createTidsRequestVirtualBranch(String accountId,String payload){
		return createBranch(accountId,payload,TIDS_Constant.RQT_VIRTUALB);
	}

	//Checks if the Case is Pending or has any relinquisment returns blank or
	//the message to display on the toast message
	@AuraEnabled(cacheable=false)
	public static String isTidsRequestPending(String accountId, String type){
		String tidsstatus=TIDS_Constant.IS_REVIEWED;
		id parentId=accountId;
		if (type==TIDS_Constant.CASE_REASON_RELINQUISH || type==TIDS_Constant.CASE_REASON_REINSTATEMENT) { 
			List<Account> accounts = [Select ParentId From Account Where Id=:AccountId Limit 1];
			if (accounts.size()>0){
				parentId=accounts[0].ParentId;
			}
		}else if (type==TIDS_Constant.IS_TERMINATED) {
			//Is it inside the periode of reinstatement
			List<Account> accounts = [Select Id From Account Where Id=:accountId and Status__c=:type Limit 1];
			if (accounts.size()>0){
				final Date rdate = isReinstated(accountId);
				string msgtype = TIDS_Constant.MSG7;
				if (rdate==null) {
					msgtype= TIDS_Constant.MSG5;
				}else if (rdate<System.today()){
					msgtype = TIDS_Constant.MSG6;
				}
				string message= TIDSUtil.getTIDSMetadataError(msgtype);
				if (rdate==null) {
					message = String.format(message, new List<String> {String.ValueOf(rdate)});
				}
				return message;
			}
			return '';
		}
		List<Case> cases = [SELECT Id FROM Case
				WHERE Status=:tidsstatus
					AND (subject=:type or Reason1__c=:type)
					AND (AccountId=:AccountId or AccountId=:parentId)
					AND RecordTypeId=:TIDSUtil.getTidsRecordTypeId() Limit 1];
		if (cases.size()>0){
			return 'exists';
		}
		return '';
	}
	//Returns the account reinstatement date if any
	private static Date isReinstated(Id accountId){
		Date rdate;
		List<Accreditation__c> accreditations = new List<Accreditation__c>();
		accreditations= [SELECT id,TIDS_Reinstatement_DeadLine__c
						FROM Accreditation__c
						WHERE Related_Account__c=:accountId Limit 1];
		if (accreditations.size()>0){
			rdate = accreditations[0].TIDS_Reinstatement_DeadLine__c;
		}
		return rdate;
	}

	//create the Branch TIDS Case
	@AuraEnabled(cacheable=false)
	public static String createTidsCaseNewBranch(String accountId,String payload){
		return createBranch(accountId,payload,TIDS_Constant.NEW_BR);
	}
	//create the Virtual Branch TIDS Case
	@AuraEnabled(cacheable=false)
	public static String createTidsCaseVirtualBranch(String accountId,String payload){    
		return createBranch(accountId,payload,TIDS_Constant.NEW_VB);
	}
	//create the Branch TIDS Case
	private static string createBranch(String accountId,String payload, string type){
		Case tidsCase = new Case();
		tidsCase = createTidsCase(null,accountId,type,payload);
		return tidsCase.Id;
	}

	// Method return only Cases with RecordType TIDS
	@AuraEnabled(cacheable=false)
	public static List<Case> allMyTidsCases(String filter){
		Id userId = UserInfo.getUserId();
		final string recordid=TIDSUtil.getTidsRecordTypeId();
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
		final string queryFields = 'Id,CaseNumber,Subject,Reason1__c,Account.Name,Status,Owner.Name,OwnerId,Previous_case_owner__c,Last_Status_Change__c ';
		final string query ='SELECT ' +queryFields+' FROM Case '+queryWhere
					+' Order By CaseNumber DESC Limit 100';
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
		string urltype=TIDS_Constant.GEONAME_URL_CODEPOSTAL;
		if (fieldtype == 'city'){
			searchValue = EncodingUtil.urlEncode(searchValue, 'UTF-8');
			urltype=TIDS_Constant.GEONAME_URL_CITY;
		}		
		final string url=String.format(TIDSUtil.getTIDSMetadataError(urltype), new List<String>{searchValue,countryIsoCode});
		HttpResponse res;
		HttpRequest req;
		Http h = new Http();
		//create a mock to cover test the code
		req = new HttpRequest();
		req.setEndpoint(url);
		req.setMethod('GET');
		try {
			res = h.send(req);
			return res.getBody();
		}catch(Exception e){
		}
		return '';
	}

	
	//Compiles the error collected during the vetting process to create an unique case comment
	private static String tidsCompileErrors(List<TIDS_Controller.verror> errors, String errorType, boolean isfirst){
		String textErrors = '';
		if (errors==null) {
			return textErrors;
		}
		if (errors.size()==0){
			return textErrors;
		}
		textErrors = (isfirst ? '':'\n') + 'Section Name :' + errorType+'\n';
		for (TIDS_Controller.verror tidsError : errors){
			textErrors +='Field: ' +tidsError.fieldLabel +'\n' +'Description: ' +tidsError.description +'\n';
		}
		return textErrors;
	}

	//Reads the ISO Country Code 
	public static List<IATAISOCountryDTO> IATAISOCountryToDto(
		List<IATA_ISO_Country__c> iataIsoCountries){
		List<IATAISOCountryDTO> result = new List<IATAISOCountryDTO>();
		for (IATA_ISO_Country__c c : iataIsoCountries){
			IATAISOCountryDTO countryDto = new IATAISOCountryDTO(
				c.Name,
				c.ISO_Code__c,
				c.Id
			);
			result.add(countryDto);
		}
		return result;
	}
	//Reads the ISO State Code 
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