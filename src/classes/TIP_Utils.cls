public class TIP_Utils{

	//##=============CONSTANTS=====================###

	//Portal Service Name
	public static String PORTAL_SERVICE_NAME_TIP= 'Transparency in Payments (TIP)';
	//Account RT's
    public static String STANDARD_ACCOUNT_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('Standard_Account');  
    public static String PAYMENT_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('TIP_Payment_Provider');

	//Account Category
	public static String ACCOUNT_CATEGORY_PAYMENT_PROVIDER = 'Payment Provider';

	//Account Sector
	public static String ACCOUNT_SECTOR_FINANCIAL_INSTITUTION = 'Financial Institution';

	//Case RT's
	public static String CASE_PROCESS_IDFS_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('CS_Process_IDFS_ISS');

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
	public static String PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID= RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Partner_products__c').get('TIP_Product');

	//BIN Range RT's
	public static String LISTED_BY_IATA_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('TIP_BIN_Range__c').get('Unenrolled_Known');
	public static String BIN_RANGE_PROVIDER_RECORD_TYPE_ID = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('TIP_BIN_Range__c').get('Enrolled');

	//TIP-49 - validate IATA code is unique for payment providers
  	public static void validateUniqueIATACodeForTIP(List<Account> triggerNew,map<id, Account> triggerOld) {
		  
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
	}

	public static void setAssessmentDate(List<Account> triggerNew,map<id, Account> triggerOld) {
		for(Account newAcc : triggerNew){
			if(newAcc.recordtypeid == PAYMENT_PROVIDER_RECORD_TYPE_ID && triggerOld.get(newAcc.id).recordtypeid != newAcc.recordtypeid) newAcc.Assessment_Performed_Date__c = Date.today();
		}	
	}
}
