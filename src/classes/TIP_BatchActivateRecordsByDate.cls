global class TIP_BatchActivateRecordsByDate implements  Database.Batchable<sObject>, Database.Stateful, Schedulable {

	public static final Integer BATCH_SIZE = 200;

	public final static Integer PROVIDER_TYPE       = 0;
	public final static Integer PRODUCT_TYPE        = 1;
	public final static Integer BIN_RANGE_TYPE      = 2;
	public final static Integer PRODUCT_CONFIG_TYPE = 3;

	//Date position
	public final static Integer DATE_STATUS_IN_PROGRESS = 0;
	public final static Integer DATE_STATUS_ACTIVE      = 1;
	public final static Integer DATE_STATUS_INACTIVE    = 2;

	//Field Keys
	public final static Integer FIELD_START_DATE = 0;
	public final static Integer FIELD_END_DATE   = 1;
	public final static Integer FIELD_STATUS     = 2;
	public final static Integer FIELD_START_DATE_TO_UPDATE = 4;

	//MAPs
	private final static Map <Integer,Map<Integer,String>> sObjectsFields = new Map <Integer,Map<Integer,String>> {
		PROVIDER_TYPE => new Map<Integer,String> {
			FIELD_START_DATE           => 'Effective_From_Date__c',
			FIELD_END_DATE             => 'Effective_To_Date__c',
			FIELD_STATUS               => 'Status__c',
			FIELD_START_DATE_TO_UPDATE => 'Effective_From_Date__c'
		},
		PRODUCT_TYPE => new Map<Integer,String> {
			FIELD_START_DATE           => 'PP_Effective_from_Date__c',
			FIELD_END_DATE             => 'PP_Effective_to_Date__c',
			FIELD_STATUS               => 'PP_status__c',
			FIELD_START_DATE_TO_UPDATE => 'PP_Effective_from_Date__c'
		},
		BIN_RANGE_TYPE => new Map<Integer,String> {
			FIELD_START_DATE           => 'TIP_Effective_From_Date_To_Show__c',
			FIELD_END_DATE             => 'TIP_Effective_To_Date__c',
			FIELD_STATUS               => 'TIP_Status__c',
			FIELD_START_DATE_TO_UPDATE => 'TIP_Effective_From_Date__c'
		},
		PRODUCT_CONFIG_TYPE => new Map<Integer,String> {
			FIELD_START_DATE           => 'TIP_Effective_From_Date_To_Show__c',
			FIELD_END_DATE             => 'TIP_Effective_To_Date__c',
			FIELD_STATUS               => 'TIP_Status__c',
			FIELD_START_DATE_TO_UPDATE => 'TIP_Effective_From_Date__c'
		}
	};

	private final static Map <Integer,Map<Integer,String>> sObjectsStatus = new Map <Integer,Map<Integer,String>> {
		PROVIDER_TYPE => new Map<Integer,String> {
			DATE_STATUS_IN_PROGRESS => TIP_UTils.PARTNER_STATUS_IN_PROGRESS,
			DATE_STATUS_ACTIVE      => TIP_UTils.PARTNER_STATUS_ACTIVE,
			DATE_STATUS_INACTIVE    => TIP_UTils.PARTNER_STATUS_INACTIVE
		},
		PRODUCT_TYPE => new Map<Integer,String> {
			DATE_STATUS_IN_PROGRESS => TIP_UTils.PARTNER_PRODUCT_STATUS_IN_PROGRESS,
			DATE_STATUS_ACTIVE      => TIP_UTils.PARTNER_PRODUCT_STATUS_ACTIVE,
			DATE_STATUS_INACTIVE    => TIP_UTils.PARTNER_PRODUCT_STATUS_INACTIVE
		},
		BIN_RANGE_TYPE => new Map<Integer,String> {
			DATE_STATUS_IN_PROGRESS => TIP_UTils.BIN_RANGE_STATUS_IN_PROGRESS,
			DATE_STATUS_ACTIVE      => TIP_UTils.BIN_RANGE_STATUS_ACTIVE,
			DATE_STATUS_INACTIVE    => TIP_UTils.BIN_RANGE_STATUS_INACTIVE
		},
		PRODUCT_CONFIG_TYPE => new Map<Integer,String> {
			DATE_STATUS_IN_PROGRESS => TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS,
			DATE_STATUS_ACTIVE      => TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE,
			DATE_STATUS_INACTIVE    => TIP_UTils.PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE
		}
	};

	//Queries
	/*public final static String QUERY_PROVIDERS = 'SELECT ID, Status__c, Accreditation_date__c, Expiry_Date__c FROM Account WHERE recordtypeid = \'' + TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID +'\' AND ('
			+    '(Accreditation_date__c > '  + system.now().format('yyyy-MM-dd') +' AND Status__c <> \''+ TIP_Utils.PARTNER_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (Accreditation_date__c <= '  + system.now().format('yyyy-MM-dd') +' AND Status__c <> \''+TIP_Utils.PARTNER_STATUS_ACTIVE+'\' ))';*/
	public final static String QUERY_PROVIDERS = 'SELECT ID, Status__c, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE Status__c != \'' + TIP_Utils.PARTNER_STATUS_TERMINATED + '\' AND recordtypeid = \'' + TIP_Utils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID +'\' AND ('
			+    '(Effective_From_Date__c > TODAY AND Status__c <> \''+ TIP_Utils.PARTNER_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (Effective_From_Date__c <= TODAY AND Status__c <> \''+TIP_Utils.PARTNER_STATUS_ACTIVE+'\' AND (Effective_To_Date__c = NULL OR Effective_To_Date__c > TODAY)) '
				+ 'OR (Effective_To_Date__c <= TODAY AND Status__c <> \''+ TIP_Utils.PARTNER_STATUS_INACTIVE +'\')'
				+ 'OR (Status__c = \''+ TIP_Utils.PARTNER_STATUS_INACTIVE +'\'))';

	public final static String QUERY_PRODUCTS = 'SELECT ID, PP_status__c, PP_Effective_from_Date__c, PP_Effective_to_Date__c FROM Partner_products__c WHERE PP_status__c != \'' + TIP_Utils.PARTNER_PRODUCT_STATUS_TERMINATED + '\' AND BIN_Conflict_Count__c = 0 AND PP_Payment_Product_Code__c <> NULL AND recordtypeid = \'' + TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID +'\' AND '
			+	 'PP_Status__c <> \''+TIP_Utils.PARTNER_PRODUCT_STATUS_REJECTED+ '\' AND ((Payment_Provider_Account_Role__r.Status__c = \''+TIP_Utils.PARTNER_STATUS_ACTIVE+ '\' AND  ('
			+    '(PP_Effective_from_Date__c > TODAY AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (PP_Effective_from_Date__c <= TODAY AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE +'\' AND (PP_Effective_to_Date__c = NULL OR PP_Effective_to_Date__c > TODAY)))) '
			+ 'OR (PP_Effective_to_Date__c <= TODAY AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE +'\')'
			+ 'OR (PP_status__c = \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE +'\'))';

	public final static String QUERY_BIN_RANGES = 'SELECT ID, TIP_Status__c, TIP_Effective_From_Date_To_Show__c, TIP_Effective_To_Date__c FROM TIP_BIN_Range__c WHERE (TIP_Payment_Provider_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+ '\' AND ('
			+    '(TIP_Effective_From_Date_To_Show__c > TODAY AND TIP_Status__c <> \''+ TIP_Utils.BIN_RANGE_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (TIP_Effective_From_Date_To_Show__c <= TODAY AND TIP_Status__c <> \''+TIP_Utils.BIN_RANGE_STATUS_ACTIVE+'\' AND (TIP_Effective_To_Date__c = NULL OR TIP_Effective_To_Date__c > TODAY)))) '
			+ 'OR (TIP_Effective_To_Date__c <= TODAY AND TIP_Status__c <> \''+ TIP_Utils.BIN_RANGE_STATUS_INACTIVE +'\')';	//ACAMBAS - TIP-161

	public final static String QUERY_PRODUCT_CONFIGS = 'SELECT ID, TIP_Status__c, TIP_Effective_From_Date_To_Show__c, TIP_Effective_To_Date__c FROM TIP_Pay_Prov_Prod_Country_Config__c WHERE (TIP_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+ '\' AND ('
			+    '(TIP_Effective_From_Date_To_Show__c > TODAY AND TIP_Status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (TIP_Effective_From_Date_To_Show__c <= TODAY  AND TIP_Status__c <> \''+TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE+'\' AND (TIP_Effective_To_Date__c = NULL OR TIP_Effective_To_Date__c > TODAY)))) '
			+ 'OR (TIP_Effective_To_Date__c <= TODAY AND TIP_Status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE +'\')';	//ACAMBAS - TIP-161



	/*public final static String QUERY_PRODUCTS = 'SELECT ID, PP_status__c, PP_Effective_from_Date__c, PP_Effective_to_Date__c FROM Partner_products__c WHERE BIN_Conflict_Count__c = 0 AND PP_Payment_Product_Code__c <> NULL AND recordtypeid = \'' + TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID +'\' AND '
		+'Provider__r.Status__c = \''+TIP_Utils.PARTNER_STATUS_ACTIVE+ '\' AND PP_Status__c <> \''+TIP_Utils.PARTNER_PRODUCT_STATUS_REJECTED+ '\' AND ( '
			+    '(PP_Effective_from_Date__c > '  + system.now().format('yyyy-MM-dd') +' AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (PP_Effective_to_Date__c < '  + system.now().format('yyyy-MM-dd') +' AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE +'\' ) '
			+ 'OR (PP_Effective_from_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND PP_Effective_to_Date__c >= '  + system.now().format('yyyy-MM-dd') +' AND PP_status__c <> \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+'\' ))';
 	public final static String QUERY_BIN_RANGES = 'SELECT ID, TIP_Status__c, TIP_Effective_From_Date__c, TIP_Effective_To_Date__c FROM TIP_BIN_Range__c WHERE TIP_Payment_Provider_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+ '\' AND ( '
			+    '(TIP_Effective_From_Date__c > '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.BIN_RANGE_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (TIP_Effective_To_Date__c < '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.BIN_RANGE_STATUS_INACTIVE +'\' ) '
			+ 'OR (TIP_Effective_From_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Effective_To_Date__c >= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+TIP_Utils.BIN_RANGE_STATUS_ACTIVE+'\' ))';

	public final static String QUERY_PRODUCT_CONFIGS = 'SELECT ID, TIP_Status__c, TIP_Effective_From_Date_To_Show__c, TIP_Effective_To_Date__c FROM TIP_Pay_Prov_Prod_Country_Config__c WHERE TIP_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+ '\' AND ( '
			+    '(TIP_Effective_From_Date_To_Show__c > '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (TIP_Effective_To_Date__c < '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE +'\' ) '
			+ 'OR (TIP_Effective_From_Date_To_Show__c <= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Effective_To_Date__c >= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE+'\' ))';

*/

	String query;
	Integer sObjectType;
	List<sObject> regsToUpdate;

	global TIP_BatchActivateRecordsByDate(Integer chosenType) {
		this.sObjectType = chosenType;

		if(sObjectType == PROVIDER_TYPE)             query = QUERY_PROVIDERS;
		else if (sObjectType == PRODUCT_TYPE)        query = QUERY_PRODUCTS;
		else if (sObjectType == BIN_RANGE_TYPE)      query = QUERY_BIN_RANGES;
		else if (sObjectType == PRODUCT_CONFIG_TYPE) query = QUERY_PRODUCT_CONFIGS;
		regsToUpdate = new List<sObject>();
	}

		public static id scheduleJob(Time runningTime){
				TIP_BatchActivateRecordsByDate bat= new TIP_BatchActivateRecordsByDate(PROVIDER_TYPE);
				string format='ss mm HH * * ? *';
				string sch=Datetime.newInstance(system.Today(),runningTime).format(format);
				return system.schedule('TIP_BatchActivateRecordsByDate for TIP Job '+sch, sch, bat);
		}

		public void execute(SchedulableContext context){
				Database.executeBatch(this);
		}



	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('PF Query: ' + query);
		return Database.getQueryLocator(query);
	}

	 	global void execute(Database.BatchableContext BC, List<sObject> scope) {
	 		Integer result;
	 		system.debug('PF scope'+scope);
	 		for (sObject o : scope){

	 			String startDate = sObjectsFields.get(sObjectType).get(FIELD_START_DATE);
	 			String endDate = sObjectsFields.get(sObjectType).get(FIELD_END_DATE);
	 			String status = sObjectsFields.get(sObjectType).get(FIELD_STATUS);
	 			String dateToUpdate = sObjectsFields.get(sObjectType).get(FIELD_START_DATE_TO_UPDATE);

			String auxStatus = checkStatus(sObjectType, ((String)o.get(status)));

	 			if(auxStatus == '') {
		 			result = dateCompare((Date) o.get(startDate), (Date) o.get(endDate));
		 			o.put(status, sObjectsStatus.get(sObjectType).get(result));

		 			if(o.get(dateToUpdate) == null) o.put(dateToUpdate, o.get(startDate));
	 			} else {
	 				o.put(status, auxStatus);
	 			}

	 			regsToUpdate.add(o);
	 		}
	 		system.debug('PF regsToUpdate'+regsToUpdate);
	}

	public static Integer dateCompare(Date startDate, Date endDate){
		integer stat=DATE_STATUS_IN_PROGRESS;
		if(startDate > System.Today()) stat=DATE_STATUS_IN_PROGRESS;
		if(startDate <=System.Today()) stat=DATE_STATUS_ACTIVE;
		if(endDate <= System.Today()) stat=DATE_STATUS_INACTIVE; //ACAMBAS - TIP-161
		return stat ;
	}

	public static String checkStatus(Integer sObjectType, String status){
		String stat = '';

	 		if (sObjectType == PRODUCT_TYPE || sObjectType == PROVIDER_TYPE) {
			if(status == TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE || status == TIP_Utils.PARTNER_STATUS_INACTIVE) {
				if(sObjectType == PRODUCT_TYPE) {
					stat = TIP_Utils.PARTNER_PRODUCT_STATUS_TERMINATED;
				} else {
					stat = TIP_Utils.PARTNER_STATUS_TERMINATED;
				}
			}
	 		}

		return stat ;
	}

	global void finish(Database.BatchableContext BC) {

		Database.update(regsToUpdate, false);
		system.debug('##type: ' + sObjectType);
		system.debug('##regsToUpdate: ' + regsToUpdate);

		if(sObjectType == PROVIDER_TYPE){
			Database.executeBatch(new TIP_BatchActivateRecordsByDate(PRODUCT_TYPE), BATCH_SIZE);
		}

		else if(sObjectType == PRODUCT_TYPE){
			Database.executeBatch(new TIP_BatchActivateRecordsByDate(BIN_RANGE_TYPE), BATCH_SIZE);
			Database.executeBatch(new TIP_BatchActivateRecordsByDate(PRODUCT_CONFIG_TYPE), BATCH_SIZE);
		}
	}

}
