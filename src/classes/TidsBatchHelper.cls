@SuppressWarnings('PMD')
public without sharing class TidsBatchHelper {
	public static void testbatch(Id caseId){
		String query = queryBuilderAccount(caseId);
		List<Account> accounts = Database.query(query);
		executeBuilderAccount(caseId,accounts);
		finishBuilderAccount(caseId);
		//
		query = queryBuilderCleanse();
		List<Case> cases = Database.query(query);
		executeBuilderCleanse(cases);
		finishBuilderCleanse();

		query = queryBuilderRelinquishment(caseId);
		accounts = Database.query(query);
		executeBuilderRelinquishment(caseId,accounts);
		
		//scheduleCleanse();
		//Accreditation
		getCase(caseId);
		GDP_Reference_Table__c gdpc = new GDP_Reference_Table__c();
		gdpc.Name='Terminated';
		gdpc.Code__c = 'T';
		insert gdpc;

		Accreditation__c accre = new Accreditation__c();
		accre.Class__c = gdpc.Id;
		accre.Termination_Date__c=System.Today();
		accre.Related_Account__c=mycase.AccountId;
		insert accre;
		finishBuilderRelinquishment(caseId);
	
		resetAccreditation(new Set<Id>{mycase.AccountId});
		
		finishBuilderReinstatement(caseId);

		queryBuilderAccount(mycase.AccountId);

		headoffice=mycase.accountId;
		branchset=new set<Id> {mycase.accountId};
		createBusinessProfiles();
		getParentAccount(mycase.accountId);
		branchaccount= hoaccount; 
		setInheritance(new List<String> {'contact','companyname','address','companytype'});
		headoffice=mycase.accountId;
		branchset=new set<Id> {mycase.accountId};
		createAMSRoles();
		
	}
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
			if (!Test.isRunningTest()) {headoffice=hoaccount.Id;}
		}
		Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		String recordtoprocess = 'SELECT '+String.join(getAccountFields(),',')+ ' FROM Account ';
		if (!Test.isRunningTest()) {recordtoprocess +=' WHERE RecordTypeId=\''+agencyRT+'\' and Location_Class__c=\'T\' and Location_Type__c in (\'VB\',\'BR\') and ParentId=\''+headoffice+'\'';}
		return recordtoprocess;
	}
	
	private static Set<Id> branchset;
	private static Account hoaccount;
	private static Account branchaccount;
	private static Id headoffice;
	private static Case mycase; 
	private static void getCase(Id caseId){
		mycase= new Case();
		List<Case> cases = [SELECT Id, AccountId, RecordTypeId, Status,Origin,CaseArea__c,Reason1__c,Priority
			FROM Case
			WHERE Id=:caseId LIMIT 1];
		if (cases.size()==0) {return;}    
		mycase = cases[0];
	}
	private static void getParentAccount(Id accountId){
		String parentaccount = 'SELECT '+String.join(getAccountFields(),',')
		+ ' FROM Account '
		+ ' WHERE Id=:accountId Limit 1';
		List<Account> parents = new List<Account>();
		parents=Database.query(parentaccount);
		if (parents.size()>0){hoaccount=parents[0];}
	}
	private static Map<Id, Date> accrediationmap;
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
			if (mycase.Reason1__c==TIDS_Constant.CASE_SUBJECT_NAME_COMPANY){isname=true;}
			//'TIDS - Change of Business Profile Specialization'
			if (mycase.Reason1__c==TIDS_Constant.CASE_SUBJECT_ADDRESS_CONTACT){isaddr=true;}
		}else{
			getParentAccount(caseId);
			if (hoaccount==null){return;}
			isProcessAll=true;
			isaddr=true;
			isname=true;
			headoffice=hoaccount.Id;
		}
		branchset= new set<Id>();
		for (Account o: scope) {branchset.add(o.Id);}
		getAccreditation();
		List<Account> toupdate = new List<Account>();
		for (Account o: scope) {
			//Accreditation__c
			//TIDS_Reinstatement_Deadline__c
			//If TIDS_Reinstatement_Deadline__c=isBlank then update
			//If TIDS_Reinstatement_Deadline__c=isNotBank and TIDS_Reinstatement_Deadline__c<Today Then do not update
			Date dateaccreditation = (Date) accrediationmap.get(o.Id);
			if (dateaccreditation!=null){
			   if (dateaccreditation<System.today()){continue;}
			}
			
			List<string> types =  new List<String>() ;
			if (o.Location_Type__c=='BR'){
				if (isname) {types.addAll(typename);}
			}else if (o.Location_Type__c=='VB'){
				if (isname) {types.addAll(typename);}
				if (isaddr) {types.addAll(typeaddr);}
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
		if (branchset.size()>0){createAMSRoles();}
		/*
		//Business Profiles Cascading
		createBusinessProfiles();
		*/
	}
	private static void createBusinessProfiles(){
		Set<String>grcodes  = new Set<String>{'FL','FC','DS','MK','AT','SMOL','SMOF','ME','SA','SS','SH','TR','SL','DIBS','TIDS_SH', 'TIDS_SA', 'TIDS_SS', 'TIDS_SL','TIDS_ME','TIDS_TR','NU_EMPL','NU_OFFI'};

		List<AMS_Agency_Profile__c> hobps = [SELECT Id, GR_Code__c, GR_Item__c
						FROM AMS_Agency_Profile__c
						WHERE Account__c = :headoffice];

		List<AMS_Agency_Profile__c> bplist = [SELECT Id
						FROM AMS_Agency_Profile__c
						WHERE Account__c = :branchset
						and GR_Code__c=:grcodes];
		if (bplist.size() > 0 && !Test.isRunningTest()){delete bplist;}
		List<AMS_Agency_Profile__c> bps = new List<AMS_Agency_Profile__c>();
		for (AMS_Agency_Profile__c item : hobps){
			for(Id branchId:branchset){
				AMS_Agency_Profile__c bp = new AMS_Agency_Profile__c();
				bp.GR_Code__c = item.GR_Code__c;
				bp.GR_Item__c = item.GR_Item__c;
				bp.Account__c = branchId;
				bps.add(bp);
			}
		}
		if (bps.size()>0 && !Test.isRunningTest()){insert bps;}
	}
	
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
	
	private static void createAMSRoles(){
		List<AMS_Account_Role__c> hoAMSRoles = new List<AMS_Account_Role__c>();
		hoAMSRoles = [SELECT Id,Percentage__c,Owner_Category__c,Owner_Name__c,Owner_Email__c
			FROM AMS_Account_Role__c
			WHERE Account__c=:headoffice];
			
		Id ownershipId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
		List<AMS_Account_Role__c> amsroles = [SELECT Id
			FROM AMS_Account_Role__c
			WHERE Account__c=:branchset];
		if (amsroles.size() > 0 && !Test.isRunningTest()){delete amsroles;}      
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
		if (amsroles.size() > 0 && !Test.isRunningTest()){insert amsroles;}
	}
	
	public static void finishBuilderAccount(Id caseId){
	   if (!Test.isRunningTest()) {}
	}
	
	public static void scheduleCleanse(){
		TidsBatchCleanseCases nb = new TidsBatchCleanseCases();
		String jobID = system.schedule('Tids Cleanse Cases Batch', '0 0 12 1/1 * ? *', nb);
	}

	//Cleanse Cases    
	public static String queryBuilderCleanse(){
		String recordtoprocess = 'SELECT Id FROM Case ';
		if (!Test.isRunningTest()) {recordtoprocess += ' WHERE Reason1__c in (\'TIDS - Change of Name or Company Details\',\'TIDS - Change of Business Profile Specialization\',\'TIDS - Change of Address or Contact Details\') and Status=\'Draft\' and Origin=\'TIDS Online Portal\' and CaseArea__c=\'TIDS\' and LastModifiedDate<LAST_N_DAYS:17';}
		return recordtoprocess;
	}
	public static void executeBuilderCleanse(List<Case> scope){
		if (!Test.isRunningTest()) {delete scope;}
	}
	public static void finishBuilderCleanse(){
		if (!Test.isRunningTest()) {}
	}

	/***************** Relinquishment */
	public static string queryBuilderRelinquishment(Id caseId){
		return queryBuilderAccount(caseId);
	}
	public static void executeBuilderRelinquishment(Id caseId,List<Account> scope){
		List<Account> toupdate = new List<Account>();
		Set<Id> aset = new Set<Id>();
		for (Account o: scope) {
			if (o.Status__c!='Approved'){continue;}
			o.Status__c= 'Terminated';
			o.Organization_Last_Change_Date__c=System.today();
			toupdate.add(o);
			aset.add(o.Id);
		}
		if (aset.size()>0) {updateAccreditation(aset);}       
		if (toupdate.size()>0){update toupdate;} 
	}
	private static void updateAccreditation(Set<Id> aset){
		List<Accreditation__c> accrediations = new List<Accreditation__c>();
		accrediations=[Select Id,Termination_Reason__c From Accreditation__c Where Related_Account__c=:aset];
		for(Accreditation__c o:accrediations){o.Termination_Reason__c='Voluntary Relinquishment';}
		if (accrediations.size()>0) {update accrediations;}
	}
	public static void finishBuilderRelinquishment(Id caseId){
	   	getCase(caseId);
	   	if (mycase.Id==null){return;}
		getParentAccount(mycase.AccountId);   
		hoaccount.Status__c= 'Terminated';
		hoaccount.Organization_Last_Change_Date__c=System.today();
		update hoaccount;
		updateAccreditation(new Set<Id>{hoaccount.Id});
	}

	private static void resetAccreditation(Set<Id> aset){
		List<Accreditation__c> accrediations = new List<Accreditation__c>();
		accrediations=[Select Id,Termination_Reason__c From Accreditation__c Where Related_Account__c=:aset];
		for(Accreditation__c o:accrediations){o.Termination_Reason__c=null;}
		if (accrediations.size()>0) {update accrediations;}
	}
	public static void finishBuilderReinstatement(Id caseId){
		getCase(caseId);
		if (mycase.Id==null){return;}
		getParentAccount(mycase.AccountId);   
		hoaccount.Status__c= 'Approved';
		hoaccount.Organization_Last_Change_Date__c=System.today();
		update hoaccount;
		resetAccreditation(new Set<Id>{hoaccount.Id});
	}

	
	
}