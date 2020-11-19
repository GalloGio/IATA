public without sharing class TidsBatchHelper {
	private static Set<Id> branchset;
	private static Account hoaccount;
	private static Account branchaccount;
	private static Id headoffice;
	private static Case mycase; 
	private static Map<Id, Date> accrediationmap;

	
	
	//Get the Account Fields
	public static List<String> getAccountFields(){
		List<String> fields = new List<String>{
		'Id',
		'Name',
		'Status__c',
		'TradeName__c',
		'Company_Type__c',
		'VAT_Number__c',
		'VAT_Number_2__c',
		'License_Number__c',
		'BillingAddress',
		'BillingStreet',
		'BillingCity',
		'BillingState',
		'BillingPostalCode',
		'BillingCountry',
		'IATA_ISO_Country__c',
		'IATA_ISO_Country__r.Name',
		'IATA_ISO_Country__r.ISO_Code__c',
		'IATA_ISO_Billing_State__c',
		'IATA_ISO_Billing_State__r.Name',
		'IATA_ISO_Billing_State__r.ISO_Code__c',
		'IATA_ISO_Shipping_Country__c',
		'IATA_ISO_Shipping_Country__r.Name',
		'IATA_ISO_Shipping_Country__r.ISO_Code__c',
		'IATA_ISO_Shipping_State__c',
		'IATA_ISO_Shipping_State__r.Name',
		'IATA_ISO_Shipping_State__r.ISO_Code__c',
		'Iso_State__r.Name',
		'Iso_State__r.ISO_Code__c',
		'ShippingStreet',
		'ShippingCity',
		'ShippingState',
		'ShippingPostalCode',
		'ShippingCountry',
		'Preferred_Language__c',
		'Phone',
		'Fax',
		'Email__c',
		'Website',
		'Manager_First_Name__c',
		'Manager_Last_Name__c',
		'Geoname_Billing_City__c',
		'Geoname_Shipping_City__c',
		'GDS__c',
		'Location_Type__c',
		'Organization_Last_Change_Date__c'
		};
		return fields;
	}
	//Builds the query string
	public static String queryBuilderAccount(Id caseId){
		getCase(caseId);
		if (mycase.Id!=null){
			headoffice=mycase.AccountId;
			/*
			'TIDS - Change of Name or Company Details'
			'TIDS - Change of Business Profile Specialization'
			'TIDS - Change of Address or Contact Details'
			*/
		}else{
			getParentAccount(caseId);
			if (hoaccount!=null) {
				headoffice=hoaccount.Id;
			}
		}
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account',TIDS_Constant.RT_AGENCY);
		String recordtoprocess = 'SELECT '+String.join(getAccountFields(),',')+ ' FROM Account ';
		recordtoprocess +=' WHERE RecordTypeId=\''+agencyRT+
						'\' and Location_Class__c=\''+TIDS_Constant.TIDS_T+
						'\' and Location_Type__c in (\''+TIDS_Constant.TIDS_VB+
						'\',\''+TIDS_Constant.TIDS_BR+
						'\') and ParentId=\''+headoffice+'\'';
		return recordtoprocess;
	}
	//Gets the Case
	private static void getCase(Id caseId){
		TIDSUtil.getTidsCases(caseId, false);
		mycase= new Case();
		if (TIDSUtil.cases.size()==0) {
			return;
		}    
		mycase = TIDSUtil.cases[0];
	}
	//Selects the Account Parent record
	private static void getParentAccount(Id accountId){
		String parentaccount = 'SELECT '+String.join(getAccountFields(),',')
		+ ' FROM Account '
		+ ' WHERE Id=:accountId Limit 1';
		List<Account> parents = new List<Account>();
		parents=Database.query(parentaccount);
		if (parents.size()>0){
			hoaccount=parents[0];
		}
	}
	//Reads the accrediations
	private static void getAccreditation(){
		accrediationmap=new Map<Id, Date>();
		List<Accreditation__c> branchaccr = [SELECT Id,Related_Account__c, TIDS_Reinstatement_DeadLine__c
							FROM Accreditation__c
							WHERE Related_Account__c=:branchset];
		for(Accreditation__c o:branchaccr){
			if (!accrediationmap.ContainsKey(o.Related_Account__c)){
				accrediationmap.put(o.Related_Account__c,o.TIDS_Reinstatement_DeadLine__c);
			}
		}
	}
	//Executes the account list
	public static void executeBuilderAccount(Id caseId,List<Account> scope){
		boolean isProcessAll=false;
		boolean isname=false;
		boolean isaddr=false;
		List<string> typeaddr =  new List<String> {'address'};
		List<string> typename =  new List<String> {'companytype', 'companyname'};
		getCase(caseId);
		if (mycase.Id!=null){
			headoffice=mycase.AccountId;
			getParentAccount(headoffice);   
			if (mycase.Reason1__c==TIDS_Constant.CASE_SUBJECT_NAME_COMPANY){
				isname=true;
			}
			//'TIDS - Change of Business Profile Specialization'
			if (mycase.Reason1__c==TIDS_Constant.CASE_SUBJECT_ADDRESS_CONTACT){
				isaddr=true;
			}
		}else{
			getParentAccount(caseId);
			if (hoaccount==null){
				return;
			}
			isProcessAll=true;
			isaddr=true;
			isname=true;
			headoffice=hoaccount.Id;
		}
		branchset= new set<Id>();
		for (Account o: scope) {
			branchset.add(o.Id);
		}
		getAccreditation();
		List<Account> toupdate = new List<Account>();
		for (Account o: scope) {
			//Accreditation__c
			//TIDS_Reinstatement_Deadline__c
			//If TIDS_Reinstatement_Deadline__c=isBlank then update
			//If TIDS_Reinstatement_Deadline__c=isNotBank and TIDS_Reinstatement_Deadline__c<Today Then do not update
			Date dateaccreditation = (Date) accrediationmap.get(o.Id);
			if (dateaccreditation!=null){
			   	if (dateaccreditation<System.today()){
					continue;
				}
			}
			
			List<string> types =  new List<String>() ;
			if (o.Location_Type__c==TIDS_Constant.TIDS_BR){
				if (isname) {
					types.addAll(typename);
				}
			}else if (o.Location_Type__c==TIDS_Constant.TIDS_VB){
				if (isname) {
					types.addAll(typename);
				}
				if (isaddr) {
					types.addAll(typeaddr);
				}
			}
			if (types.size()>0){
				o.Organization_Last_Change_Date__c=System.Today();
				branchaccount=o;
				setInheritance(types);
				toupdate.add(branchaccount);
			}
		}
		branchset= new set<Id>();
		if (toupdate.size()>0){
			if (isname){
				for (Account o: toupdate) {
					branchset.add(o.Id);
				}
			}
			update toupdate;
		} 
		
		//AMS Role Cascading
		if (branchset.size()>0){
			createAMSRoles();
		}
	}
	
	//set the Inheritance values between Account parent and Branches
	//on different sections
	private static void setInheritance(List<string> types){
		for(string type:types){
		  switch on (type){
			when 'companytype'{
			  branchaccount.Company_Type__c = hoaccount.Company_Type__c;
			}
			when 'companyname'{
				branchaccount.Name = hoaccount.Name;
			}
			when 'address'{
				branchaccount.BillingStreet = hoaccount.BillingStreet;
				branchaccount.BillingCity = hoaccount.BillingCity;
				branchaccount.BillingState = hoaccount.BillingState;
				branchaccount.BillingPostalCode = hoaccount.BillingPostalCode;
				branchaccount.BillingCountry = hoaccount.BillingCountry;
				branchaccount.IATA_ISO_Country__c = hoaccount.IATA_ISO_Country__c;
				branchaccount.IATA_ISO_Billing_State__c = hoaccount.IATA_ISO_Billing_State__c;
				branchaccount.Iso_State__c = hoaccount.Iso_State__c;
				branchaccount.Geoname_Billing_City__c = hoaccount.Geoname_Billing_City__c;
			}
			when 'contact'{
				branchaccount.preferred_Language__c = hoaccount.preferred_Language__c;
				branchaccount.phone = hoaccount.phone;
				branchaccount.fax = hoaccount.fax;
				branchaccount.email__c = hoaccount.email__c;
				branchaccount.website = hoaccount.website;
				branchaccount.Manager_First_Name__c = hoaccount.Manager_First_Name__c;
				branchaccount.Manager_Last_Name__c = hoaccount.Manager_Last_Name__c;
			}
		  }
		}
	}
	//create the AMS Roles
	private static void createAMSRoles(){
		List<AMS_Account_Role__c> hoAMSRoles = new List<AMS_Account_Role__c>();
		hoAMSRoles = [SELECT Id,Percentage__c,Owner_Category__c,Owner_Name__c,Owner_Email__c
			FROM AMS_Account_Role__c
			WHERE Account__c=:headoffice];
			
		Id ownershipId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		List<AMS_Account_Role__c> amsroles = [SELECT Id
			FROM AMS_Account_Role__c
			WHERE Account__c=:branchset];
		if (amsroles.size() > 0){
			delete amsroles;
		}
		amsroles = new List<AMS_Account_Role__c>();
		for (AMS_Account_Role__c item : hoAMSRoles){
			for(Id branchId:branchset){
				AMS_Account_Role__c amsrole = new AMS_Account_Role__c();
				amsrole.RecordTypeId = ownershipId;
				amsrole.Percentage__c = item.Percentage__c;
				amsrole.Owner_Account__c = branchId;
				amsrole.Owner_Category__c = item.Owner_Category__c;
				amsrole.Owner_Name__c = item.Owner_Name__c;
				amsrole.Owner_Email__c = item.Owner_Email__c;
				amsrole.Account__c = branchId;
				amsroles.add(amsrole);
			}
		}
		if (amsroles.size() > 0){
			insert amsroles;
		}
	}
	//Schedules the Case Cleanse
	public static void scheduleCleanse(){
		TidsBatchCleanseCases nb = new TidsBatchCleanseCases();
		String jobID = system.schedule('Tids Cleanse Cases Batch', '0 0 12 1/1 * ? *', nb);
	}

	//Cleanse Cases query builder    
	public static String queryBuilderCleanse(){
		List<Portal_Applications__c> services = new List<Portal_Applications__c>();
		services = [Select Id FROM Portal_Applications__c WHERE Name=:TIDS_Constant.TIDSVALUE Limit 1];
		String recordtoprocess = 'SELECT Id FROM Case ';
		recordtoprocess += ' WHERE Reason1__c in (\''+TIDS_Constant.CASE_SUBJECT_NAME_COMPANY+'\','+
		' \''+TIDS_Constant.CASE_SUBJECT_CHANGE_BUS_PROFILE +'\','+
		' \''+TIDS_Constant.CASE_SUBJECT_ADDRESS_CONTACT +'\') '+
		' and recordtypeid =\''+TIDSUtil.getTidsRecordTypeId()+'\''+
		' and Status=\''+TIDS_Constant.IS_DRAFT +'\' and Origin=\''+TIDS_Constant.CASE_ORIGIN+'\''+ 
		' and CaseArea__c=\''+TIDS_Constant.TIDSVALUE+'\'';
		if (services.size()>0) {
			recordtoprocess += ' and LastModifiedDate<=LAST_N_DAYS:17 ';
		}
		return recordtoprocess;
	}
	//Executes the cleanse
	public static void executeBuilderCleanse(List<Case> scope){
		delete scope;
	}
	
	/***************** Relinquishment */
	//Query builder
	public static string queryBuilderRelinquishment(Id caseId){
		return queryBuilderAccount(caseId);
	}
	//Execute the Relinquishment on the branches
	public static void executeBuilderRelinquishment(Id caseId,List<Account> scope){
		List<Account> toupdate = new List<Account>();
		Set<Id> aset = new Set<Id>();
		for (Account o: scope) {
			if (o.Status__c!=TIDS_Constant.IS_APPROVED){
				continue;
			}
			o.Status__c=TIDS_Constant.IS_TERMINATED;
			o.Organization_Last_Change_Date__c=System.today();
			toupdate.add(o);
			aset.add(o.Id);
		}
		if (aset.size()>0) {
			updateAccreditation(aset,TIDS_Constant.TIDS_VOL);
		}
		if (toupdate.size()>0){
			update toupdate;
		} 
	}
	//updates the accreditations to validate the relinquishment
	private static void updateAccreditation(Set<Id> aset, String updatevalue){
		List<Accreditation__c> accrediations = new List<Accreditation__c>();
		accrediations=[Select Id,Termination_Reason__c From Accreditation__c Where Related_Account__c=:aset];
		for(Accreditation__c o:accrediations){
			o.Termination_Reason__c=updatevalue;
		}
		if (accrediations.size()>0) {
			update accrediations;
		}
	}
	//shared function to either reinstate or relinquish the account
	private static void finishBuilder(Id caseId,String status, String reason){
		getCase(caseId);
		if (mycase.Id==null){
		 	return;
		}
		getParentAccount(mycase.AccountId);   
		hoaccount.Status__c= status;
		hoaccount.Organization_Last_Change_Date__c=System.today();
		update hoaccount;
		updateAccreditation(new Set<Id>{hoaccount.Id},reason);
 	}
	//finishes the relinquishment batch
	public static void finishBuilderRelinquishment(Id caseId){
		finishBuilder(caseId, AMS_Utils.ACC_S0_TERMINATED,TIDS_Constant.TIDS_VOL);
	}	
	//finishes the Reinstatement batch
	public static void finishBuilderReinstatement(Id caseId){
		finishBuilder(caseId,AMS_Utils.ACC_S9_APPROVED, null);
	}
}