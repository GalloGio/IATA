public without sharing class portalIftpEmployeeCtrl {

	public static Id userId = UserInfo.getUserId();
	public static Boolean isAdmin;
	public static Boolean seeAllRecords;
	public static String currentListViewName;
	public static Boolean apUser;
	public static String selectedList;
	public static String soqlOrder;
	public static Id myAccountId;
	private static ISSP_PermissionFilterFactory.PermissionSetFilter     thePermissionSetFilter;
	private static ISSP_PermissionFilterFactory.ProfilePermissionFilter theProfilePermissionFilter;
	private static List<ISSPCaseListView__c> csCaseListViews;
	public static Map<String, ISSPCaseListView__c> caseListViewMap;

	/*
	* @description Main method that returns a list of cases
	* @params
	* @return List<Case>
	*/
	@AuraEnabled(cacheable=true)
	public static PagedResult searchEmployeeRecords(Boolean seeAll) {
		seeAllRecords = seeAll;

		initialization();

		return getTrainingRecordsPagination();
	}

	/*
	* @description Initialize and populate properties related to user logged
	* @params
	* @return
	*/
	private static void initialization() {
		try {

			apUser = false;
			User myUser = [
				SELECT Id, ContactId, Contact.AccountId
				FROM User
				WHERE Id = :userId
			];

			if(myUser.ContactId != null) {
				List <Portal_Application_Right__c> appRightList = [
					SELECT Id
					FROM Portal_Application_Right__c
					WHERE Contact__c = :myUser.ContactId
					AND Right__c = 'Access Granted'
					AND Portal_Application__r.Name = 'IFTP'
				];

				myAccountId = myUser.Contact.AccountId;
			}

		} catch(Exception exp) {
				ISSP_Utilities.exceptionDump(exp);
		}
	}

	@AuraEnabled (cacheable=false)
	public static List<EmployeeRecordsWrapper> getEmployeeRecords(List<String> searchValues, Id accountId){
		String firstNameValue = String.isnotblank(searchValues[0])? searchValues[0].trim(): '';
		String lastNameValue = String.isnotblank(searchValues[1])? searchValues[1].trim(): '';
		String emailValue = String.isnotblank(searchValues[2])? searchValues[2].trim(): '';
		String employeeCodeValue = String.isnotblank(searchValues[3])? searchValues[3].trim(): '';
		String stationCode = String.isnotblank(searchValues[4])? searchValues[4].trim(): '';

		String sQuery = 'SELECT Id, Name, First_Name__c, Last_Name__c, ';
		sQuery += 'Company_Code__c , Email__c ';
		sQuery += ', (SELECT Address__c, Address__r.City__c, Address__r.Code__c, Address__r.Description__c FROM Role_Addresses__r)';
		sQuery += 'FROM Account_Contact_Role__c ';

		String conditions = '';
		List<String> lConditions = new List<String>();


		lConditions.add('Status__c <> \'Inactive\'');
		lConditions.add('Contact__r.accountid = :accountId');
		if(String.isnotblank(firstNameValue)){
			firstNameValue = firstNameValue + '%';
			lConditions.add('First_Name__c like :firstNameValue');
		}
		if(String.isnotblank(lastNameValue)){
			lastNameValue = lastNameValue + '%';
			lConditions.add('Last_Name__c like :lastNameValue');
		}
		if(String.isnotblank(employeeCodeValue)){
			lConditions.add('Company_Code__c = :employeeCodeValue');
		}
		if(String.isnotblank(emailValue)){
			lConditions.add('Email__c = :emailValue');
		}

		for(String sCond : lConditions){
			if(conditions == ''){
				conditions += ' WHERE ' + sCond;
			}else{
				conditions += ' AND ' + sCond;
			}

		}
		sQuery += conditions;

		List<Account_Contact_Role__c> employees =  Database.query(sQuery);

		List<EmployeeRecordsWrapper> lEmpWrapper = new List<EmployeeRecordsWrapper>();

		//Create Compose List to return
		for(Account_Contact_Role__c emp : employees){

			EmployeeRecordsWrapper trw = new EmployeeRecordsWrapper(
				emp.Id,
				emp.First_Name__c,
				emp.Last_Name__c,
				emp.Email__c,
				emp.Company_Code__c );

			if(!emp.Role_Addresses__r.isEmpty()){
				for(Role_Address__c rec: emp.Role_Addresses__r){
					trw.stationsCodesListAsString += rec.Address__r.Code__c + '; ';
				}
				trw.stationsCodesListAsString.removeEnd('; ');
			}
			trw.name = emp.Name;

			if(String.isBlank(stationCode) || trw.stationsCodesListAsString.containsIgnoreCase(stationCode)){
				lEmpWrapper.add(trw);
			}

		}

		return lEmpWrapper;
	}

	@AuraEnabled (cacheable=false)
	public static Boolean updateCertificationProficiency(List<Object> dataToSave){
		List<Contact_Role_Certification__c> certToUpdate = new List<Contact_Role_Certification__c>();

		for(Object rec : dataToSave){
			Contact_Role_Certification__c auxCert = (Contact_Role_Certification__c)JSON.deserialize(JSON.serialize(rec ), Contact_Role_Certification__c.class);
			certToUpdate.add(auxCert);
		}
		update certToUpdate;

		return true;
	}


	 /*
	* @description Return the list of Cases using fields of a Case Field Set and filtered by "ISSPCaseListView__c" Custom Setting using SOQL Filter field.
	* @params
	* @return List<Case>
	*/
	private static PagedResult getTrainingRecordsPagination() {
		String queryString;

		String query = ' Name, Account_Contact_Role__c, Certification__c, CreatedDate ';
		Boolean hasStatus = false;

		queryString = 'SELECT ' + query.substring(1) + ' FROM Contact_Role_Certification__c ORDER BY LastModifiedDate DESC ';

		PagedResult result =  new PagedResult();
		result.totalItemCount = Database.countQuery('SELECT count() FROM Contact_Role_Certification__c ');
		result.records = Database.query(queryString);

		System.debug(LoggingLevel.FINE, '____ [cls PortalCasesCtrl - getCases] queryString - ' + queryString);

		return result;
	}

	public class PagedResult {
		@AuraEnabled
		public Integer totalItemCount { get;set; }
		@AuraEnabled
		public Object[] records { get;set; }
	}

	public class EmployeeRecordsWrapper {

		@AuraEnabled
		public String uniqueRowId {get;set;}
		@AuraEnabled
		public String Id {get;set;}
		@AuraEnabled
		public String firstName {get;set;}
		@AuraEnabled
		public String lastName {get;set;}
		@AuraEnabled
		public String email {get;set;}
		@AuraEnabled
		public String companyNumber {get;set;}
		@AuraEnabled
		public String stationsCodesListAsString {get;set;}
		@AuraEnabled
		public String name {get;set;}


		public EmployeeRecordsWrapper(Id employeeId, String firstName, String lastName,
										String email, String companyNumber ){
			this.uniqueRowId = employeeId;
			this.Id = employeeId;
			this.firstName = firstName;
			this.lastName = lastName;
			this.email = email;
			this.companyNumber =companyNumber;
			this.stationsCodesListAsString = '';
		}

	}
}