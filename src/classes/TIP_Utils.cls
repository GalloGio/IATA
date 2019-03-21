public class TIP_Utils{

	//##=============CONSTANTS=====================###

	//Portal Service Name
	public static String PORTAL_SERVICE_NAME_TIP= 'Transparency in Payments (TIP)';
	//Account RT's
    public static String STANDARD_ACCOUNT_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');  
    //public static String PAYMENT_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'TIP_Payment_Provider');
 //Account Role RT
    public static String ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Account_Role__c', 'TIP_Payment_Provider');
 
	//Account Category
	public static String ACCOUNT_CATEGORY_PAYMENT_PROVIDER = 'Payment Provider';

	//Account Sector
	public static String ACCOUNT_SECTOR_FINANCIAL_INSTITUTION = 'Financial Institution';
	
	//Account service provided
	public static string ACCOUNT_SERVICE_PROVIDED_PAYMENT_PROVIDER = 'Payment Provider';
	
	//Account Contact Role Helper
	public static string ACCOUNT_CONTACT_ROLE_SERVICE_TIP = 'TIP';
	public static string ACCOUNT_CONTACT_ROLE_PRIMARY = 'Primary Contact';

	//Case RT's
	public static String CASE_PROCESS_IDFS_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CS_Process_IDFS_ISS');

	//Case Reason
	public static String CASE_REASON_PAYMENT_PROVIDER_MANAGMENT= 'Payment Provider Management';
	public static String CASE_REASON_PRODUCT_MANAGEMENT= 'Product management';

	//Case Areas
	public static String CASE_AREA_TRANSPARENCY_IN_PAYMENTS= 'Transparency in Payments (TIP)';

	//Case origin
	public static String CASE_ORIGIN_PORTAL = 'Portal';

	//case Description
	public static String CASE_DESC_REQUEST_FOR_ENLISTMENT_PAYMENT_PROVIDER = 'Request for Enlistment as Payment provider';

	//Case Subject
	public static String CASE_SUBJECT_NEW_PRODUCT_ENROLMENT = 'New Product Enrolment';

	//Case Status
	public static String CASE_STATUS_DRAFT = 'Draft';

	//Partner status
	public static String PARTNER_STATUS_ACTIVE='Active';
	public static String PARTNER_STATUS_INACTIVE='Inactive';
	public static String PARTNER_STATUS_IN_PROGRESS='In Progress';
	

	//Partner Product status
	public static String PARTNER_PRODUCT_STATUS_ACTIVE='ACTIVE';
	public static String PARTNER_PRODUCT_STATUS_INACTIVE='INACTIVE';
	public static String PARTNER_PRODUCT_STATUS_IN_PROGRESS='IN_PROGRESS';
	public static String PARTNER_PRODUCT_STATUS_REJECTED='REJECTED';
	public static String PARTNER_PRODUCT_STATUS_DRAFT='DRAFT';
	public static String PARTNER_PRODUCT_STATUS_TERMINATED='TERMINATED';	

	//Partner Product status
	public static String PARTNER_PRODUCT_NETWORK_TYPE_OPEN_LOOP='OPEN_LOOP';

	//BIN Range status
	public static String BIN_RANGE_STATUS_ACTIVE='ACTIVE';
	public static String BIN_RANGE_STATUS_INACTIVE='INACTIVE';
	public static String BIN_RANGE_STATUS_IN_PROGRESS='IN_PROGRESS';
	public static String BIN_RANGE_STATUS_DRAFT='DRAFT';

	//Partner Product Configuration status
	public static String PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE='ACTIVE';
	public static String PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE='INACTIVE';
	public static String PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS='IN_PROGRESS';
	public static String PARTNER_PRODUCT_CONFIG_STATUS_DRAFT='DRAFT';

	//Partner product RT
	public static String PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID= RecordTypeSingleton.getInstance().getRecordTypeId('Partner_products__c', 'TIP_Product');

	//BIN Range RT's
	public static String LISTED_BY_IATA_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('TIP_BIN_Range__c', 'Unenrolled_Known');
	public static String BIN_RANGE_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().getRecordTypeId('TIP_BIN_Range__c', 'Enrolled');

    public static final String REPORT_TYPE_TIP_AUTO_REPORTS  = 'TIP_AUTO_REPORTS';
    public static final String REQUEST_TYPE_TIP_AUTO_REPORTS = 'TIP_AUTO_REPORTS'; 
    
    public static final String REMOTE_INVOCATION_STATUS_COMPLETED    = 'Completed';
    public static final String REMOTE_INVOCATION_STATUS_FAILED       = 'Failed'; 
    public static final String REMOTE_INVOCATION_STATUS_INITIALIZING = 'Initializing';
    public static final String REMOTE_INVOCATION_STATUS_IN_PROGRESS  = 'In Progress';  

	//TIP-49 - validate IATA code is unique for payment providers
  	/*public static void validateUniqueIATACodeForTIP(List<Account> triggerNew,map<id, Account> triggerOld) {
		  
		Map<String,Account> mapIataCodeAccount = new Map<String,Account>(); //map of IATA Codes that should not exist already in the system
		String queryString = 'SELECT ID, IATACode__c FROM Account WHERE ( recordtypeid = \''+TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID + '\' OR (recordtypeid = \''+TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID+'\' AND Category__c = \''+TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER+'\') )';
		String queryStringWhereClause = '';

		if(trigger.isInsert){
			for(Account acc : triggerNew){ 
				if(!String.isBlank(acc.IATACode__c) && (acc.recordtypeid == TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID || (acc.recordtypeid == TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID && acc.Category__c == TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER)) ){ 
					mapIataCodeAccount.put(acc.IATACode__c,acc);
					//queryStringWhereClause += ', \''+ acc.IATACode__c + '\'';
				}
			}
			if(!String.isEmpty(queryStringWhereClause)) queryString += 'AND IATACode__c NOT IN (\'\'' + queryStringWhereClause + ')' ;

		}else{

			for(Account accNew : triggerNew){
				//if iata code changed
				if(!String.isEmpty(accNew.IATACode__c) && triggerOld.get(accNew.id).IATACode__c != accNew.IATACode__c
					 && (accNew.recordtypeid == TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID || (accNew.recordtypeid == TIP_Utils.STANDARD_ACCOUNT_RECORD_TYPE_ID && accNew.Category__c == TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER))){
					mapIataCodeAccount.put(accNew.IATACode__c,accNew);
					queryStringWhereClause += (String.isEmpty(queryStringWhereClause) ? '' : ' OR ') +' (ID <> \''+ accNew.id +'\' AND IATACode__c = \''+ accNew.IATACode__c +'\')' ;
				}
			}		

			if(!String.isEmpty(queryStringWhereClause)) queryString += ' AND ('+ queryStringWhereClause +')';
		}

		system.debug('##Query:'+ queryString) ;    
		List<Account> tempAccs;
		if (!mapIataCodeAccount.isEmpty()) tempAccs = Database.query(queryString);

		system.debug('##results:'+ tempAccs) ;
		if(tempAccs!= null && !tempAccs.isEmpty() && !mapIataCodeAccount.isEmpty()){
			for(Account accWithDuplicatedIATACode : tempAccs){
				if(mapIataCodeAccount.get(accWithDuplicatedIATACode.IATACode__c) != null){
				mapIataCodeAccount.get(accWithDuplicatedIATACode.IATACode__c).addError('Duplicated IATA Code: ' + accWithDuplicatedIATACode.IATACode__c + '. ID: ' + accWithDuplicatedIATACode.id);
				}
			}			
		}
	}*/

	public static void setAssessmentDate(List<Account> triggerNew,map<id, Account> triggerOld) {
		for(Account newAcc : triggerNew) {
			if(newAcc.Account_Role__c != null && newAcc.Account_Role__c.contains('Payment Provider') && triggerOld.get(newAcc.id).recordtypeid != newAcc.recordtypeid) newAcc.Assessment_Performed_Date__c = Date.today();
		}	
	}
	
	//method to manage multi picklist via code
	//sFieldValue is the value of the field on the object
	//sValue is the value to add or remove
	//sAction is the action to perform: "Add" or "Remove"
	public static string ManageMultiPicklist(string sFieldValue, string sValue, string sAction){
		string sToReturn = '';
		set<string> setValues = new set<string>();
		if(string.IsNotBlank(sFieldValue))
			setValues.addAll(sFieldValue.split(';'));
		
		if(setValues.contains(sValue) && sAction=='Remove')
			setValues.remove(sValue);
		
		if(sAction=='Add')
			setValues.add(sValue);
		
		if(!setValues.isEmpty())
			sToReturn = string.join(new list<string>(setValues), ';');
			
		return sToReturn;
	}
	
	//Used to prevent sync between accocunt role and product fired twice
	public static boolean SyncFromAccountRole = false;
	
	//Used to keep in sync Account Role with Partner Product
	//Scenario: a partner product is updated
	public static void SyncAccountRoleOnProduct(list<Partner_products__c> trigNew, map<id, Partner_products__c> trigOld){
		if(TIP_Utils.SyncFromAccountRole) return;
		
		map<id, id> mapAccountRole = new map<id, id>();
		set<id> setAccntId = new set<id>();
		
		for(Partner_products__c pp:trigNew)	setAccntId.add(pp.Provider__c);
		
		for(Account_Role__c acr:[select id, Account__c from Account_Role__c where Account__c in : setAccntID and recordtypeid=:TIP_UTILS.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID])
			mapAccountRole.put(acr.Account__c, acr.Id);
		
		for(Partner_products__c pp:trigNew){
			if(trigOld == null || (trigOld.get(pp.Id).Payment_Provider_Account_Role__c != pp.Payment_Provider_Account_Role__c))
				pp.Payment_Provider_Account_Role__c = mapAccountRole.get(pp.Provider__c);
		}
	}
	
	//Used to keep in sync Account Role with Partner Product
	//Scenario: an account role is created or update. It has to update all existing product related to account
	public static void SyncAccountRoleOnProduct(list<Account_Role__c> trigNew, map<id, Account_Role__c> trigOld){
		TIP_Utils.SyncFromAccountRole = true;
		map<id, id> mapAccountRole = new map<id, id>();
		list<Partner_products__c> prodToUpdate = new list<Partner_products__c>();
		
		for(Account_Role__c acr:trigNew){
			if(acr.recordtypeid == TIP_UTILS.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID)
				if(trigOld == null || (trigOld != null && acr.Account__c != trigOld.get(acr.Id).Account__c))
					mapAccountRole.put(acr.Account__c, acr.Id);
		}
		
		if(!mapAccountRole.isEmpty()){
			for(Partner_products__c pp:[select id, Payment_Provider_Account_Role__c, Provider__c from Partner_products__c where Provider__c in:mapAccountRole.keySet()]){
				if(pp.Payment_Provider_Account_Role__c != mapAccountRole.get(pp.Provider__c))
					prodToUpdate.add(new Partner_products__c(id=pp.Id, Payment_Provider_Account_Role__c = mapAccountRole.get(pp.Provider__c)));
			}
		}
		
		if(!prodToUpdate.isEmpty())	update prodToUpdate;
	}
	
	public static string AccountContactRoleGenerateUniquekey(Account_Contact_Role__c theContactRole){
		return TIP_Utils.ACCOUNT_CONTACT_ROLE_SERVICE_TIP + '_' + string.ValueOf(theContactRole.Account_Role__c).left(15) + '_' + string.ValueOf(theContactRole.Contact__c).left(15);
	}
}
