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

	//Regions
	public final static String AFRICA_MIDDLE_EAST = 'Africa & Middle East';
	public final static String ASIA_PACIFIC = 'Asia & Pacific';
	public final static String AMERICAS = 'Americas';
	public final static String CHINA_NORTH_ASIA = 'China & North Asia';
	public final static String EUROPE = 'Europe';


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

	private final static Map<String, Integer> regionsMap = new Map<String, Integer> {
		AFRICA_MIDDLE_EAST => -1,
		ASIA_PACIFIC => -1,
		AMERICAS => -1,
		CHINA_NORTH_ASIA => -1,
		EUROPE => -1
	};


	//Queries

	public final static String QUERY_PROVIDERS = 'SELECT ID, Status__c, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE recordtypeid = \'' + TIP_Utils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID +'\' AND ('
			+    '(Effective_From_Date__c > '  + system.now().format('yyyy-MM-dd') +' AND Status__c <> \''+ TIP_Utils.PARTNER_STATUS_IN_PROGRESS +'\' ) '			
			+ 'OR (Effective_From_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND Status__c <> \''+TIP_Utils.PARTNER_STATUS_ACTIVE+'\' ) '
		    + 'OR (Effective_To_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND Status__c <> \''+ TIP_Utils.PARTNER_STATUS_INACTIVE +'\'))'; //ACAMBAS - TIP-161
	
	public final static String QUERY_PRODUCTS = 'SELECT ID, PP_status__c, PP_Effective_from_Date__c, PP_Effective_to_Date__c FROM Partner_products__c WHERE BIN_Conflict_Count__c = 0 AND PP_Payment_Product_Code__c <> NULL AND recordtypeid = \'' + TIP_Utils.PARTNER_PRODUCT_TIP_PRODUCT_RECORD_TYPE_ID +'\' AND '
			+'PP_Status__c <> \''+TIP_Utils.PARTNER_PRODUCT_STATUS_REJECTED+ '\' AND ((Payment_Provider_Account_Role__r.Status__c = \''+TIP_Utils.PARTNER_STATUS_ACTIVE+ '\' AND  ('
			+    '(PP_Effective_from_Date__c > '  + system.now().format('yyyy-MM-dd') +' AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (PP_Effective_from_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE +'\'))) '	
			+ 'OR (PP_Effective_to_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND PP_status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE +'\'))';	//ACAMBAS - TIP-161

	public final static String QUERY_BIN_RANGES = 'SELECT ID, TIP_Status__c, TIP_Effective_From_Date_To_Show__c, TIP_Effective_To_Date__c FROM TIP_BIN_Range__c WHERE (TIP_Payment_Provider_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+ '\' AND ('
			+    '(TIP_Effective_From_Date_To_Show__c > '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.BIN_RANGE_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (TIP_Effective_From_Date_To_Show__c <= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+TIP_Utils.BIN_RANGE_STATUS_ACTIVE+'\' ))) '
			+ 'OR (TIP_Payment_Provider_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE+ '\' AND TIP_Effective_To_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.BIN_RANGE_STATUS_INACTIVE +'\')';	//ACAMBAS - TIP-161

	public final static String QUERY_PRODUCT_CONFIGS = 'SELECT ID, TIP_Status__c, TIP_Effective_From_Date_To_Show__c, TIP_Effective_To_Date__c FROM TIP_Pay_Prov_Prod_Country_Config__c WHERE ((TIP_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_ACTIVE+ '\' AND ( '
			+    '(TIP_Effective_From_Date_To_Show__c > '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_IN_PROGRESS +'\' ) '
			+ 'OR (TIP_Effective_From_Date_To_Show__c <= '  + system.now().format('yyyy-MM-dd') +'  AND TIP_Status__c <> \''+TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_ACTIVE+'\' ))) '
			+ 'OR (TIP_Product__r.PP_status__c = \''+TIP_Utils.PARTNER_PRODUCT_STATUS_INACTIVE+ '\' AND TIP_Effective_To_Date__c <= '  + system.now().format('yyyy-MM-dd') +' AND TIP_Status__c <> \''+ TIP_Utils.PARTNER_PRODUCT_CONFIG_STATUS_INACTIVE +'\')) AND '	//ACAMBAS - TIP-161
			+ 'TIP_BSP_Country__r.Region__c = \'$REGION$\''; //ACAMBAS - TIP-320


	String query;
	Integer sObjectType;
	List<sObject> regsToUpdate;
	
	global TIP_BatchActivateRecordsByDate(Integer chosenType, String sRegion) {
		this.sObjectType = chosenType;

		if(sObjectType == PROVIDER_TYPE)             query = QUERY_PROVIDERS;
		else if (sObjectType == PRODUCT_TYPE)        query = QUERY_PRODUCTS;
		else if (sObjectType == BIN_RANGE_TYPE)      query = QUERY_BIN_RANGES;
		else if (sObjectType == PRODUCT_CONFIG_TYPE) query = QUERY_PRODUCT_CONFIGS.replace('$REGION$', sRegion);

		regsToUpdate = new List<sObject>();
	}

    public void execute(SchedulableContext context){
        Database.executeBatch(this); 
    }

	global Database.QueryLocator start(Database.BatchableContext BC) {
		system.debug('##PF Query: ' + query);
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

   			result = dateCompare((Date) o.get(startDate), (Date) o.get(endDate));
   			o.put(status, sObjectsStatus.get(sObjectType).get(result));
   			if(o.get(dateToUpdate) == null) o.put(dateToUpdate, o.get(startDate));
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

	public static void scheduleRegion(Integer chosenType, String region, Date runningDate, Time runningTime) {
        TIP_BatchActivateRecordsByDate bat = new TIP_BatchActivateRecordsByDate(chosenType, region);
        String format ='ss mm HH dd MM ? yyyy';
        if(runningDate == null){
            format = 'ss mm HH * * ? *';
            runningDate = System.today();
        }

        DateTime runningDateTime = DateTime.newInstanceGMT(runningDate, runningTime).addHours(regionsMap.get(region)); //creates date on GMT +timezone adjustmnent

        String sch = runningDateTime.format(format);
        String jobID = System.schedule('Batch TIP_BatchActivateRecordsByDate Job '+System.now().format('dd/MM/yyyy hh:MM:ss'), sch, bat);
    }
		
	global void finish(Database.BatchableContext BC) {

		Database.update(regsToUpdate, false); 
		system.debug('##type: ' + sObjectType);
		system.debug('##regsToUpdate: ' + regsToUpdate);

		String defaultRegion = ASIA_PACIFIC;
		
		if(sObjectType == PROVIDER_TYPE) {
			Database.executeBatch(new TIP_BatchActivateRecordsByDate(PRODUCT_TYPE, defaultRegion), BATCH_SIZE);
		}

		else if(sObjectType == PRODUCT_TYPE) {
			Database.executeBatch(new TIP_BatchActivateRecordsByDate(BIN_RANGE_TYPE, defaultRegion), BATCH_SIZE);
			Database.executeBatch(new TIP_BatchActivateRecordsByDate(PRODUCT_CONFIG_TYPE, defaultRegion), BATCH_SIZE);
		}
	}
	
}