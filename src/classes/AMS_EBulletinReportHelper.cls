/** 
EBulletin helper methods

EBulletin is a CSV dispatch 3 main informatory activities about IATA agencies:
1.	New applications & Approved/Disapproved applications
2.	Changes like ownership, location, etc...
3.	Non-compliance like default, irregularity
	*/

public without sharing class AMS_EBulletinReportHelper {


	private static final Map <String,String>  TYPEEBULLETINMAP = 
					 new Map <String,String> { 'D' => 'Daily__c', 
					 						   'W' => 'Weekly__c' };

	// Countries to override value with State Account__r.IATA_ISO_Country__c
	// 
	private static final Set <String> COUNTRYOVERRIDESET =  new Set< String>{ 'US', 'AU', 'CA' };


	//Map fields from Custom Setting AMSEBulletinSettings

	public static final String SECTION			= 	'0-Section';

	public static final String IATACODE			= 	'2-Agency Code';
	public static final String LEGALSTATUS		= 	'5-Legal Status';
    public static final String ACCREDITATIONTYPE	= 	'6-Accreditation Type';
    public static final String CASHCONDITION    = '9-Cash Condition equal to FS';
	public static final String LOCATIONCLASS	= 	'10-Program';
	
	public static final String HIERARCHY		= 	'11-Hierarchy';

	public static final String STATE  	        = 	'14-Country or State';
	public static final String COUNTRY  	    =	'15-Country or State';

	public static final String STATUS			= 	'23-Status';
	public static final String REASON			= 	'27-Reason';

	public static final String CHANGECODE       = 	'1-Change Code';

	public static final String OWNERS 	   	 	   =	'34-Owner1';
	public static final String OWNERAPINAME 	   =	'Account__r.Owners';
	public static final String OWNERSTOTALAPINAME  =	'OwnersTotal';

	// position in the owner name, example: 22-Owner1 will be recovering the value 1
	public static final Integer OWNERPOS 			=	8;
	public static final Integer NEWOWNERPOS 		=	12;

	public static final String NEWLEGALSTATUS	    = 	'53-New Legal Status';
	public static final String NEWHIERARCHY	        = 	'54-New Hierarchy';
    public static final String NEWACCREDITATIONTYPE	= 	'56-New Accreditation Type';

	public static final String NEWSTATE 	    =	'58-New Country or State';
	public static final String NEWCOUNTRY 		= 	'59-New Country or State';

	public static final String IRRREASON 		=	'85-IRR: Reason';
	public static final String IRRPERIODSD 		= 	'86-IRR: Period';
	public static final String IRRPERIODED		= 	'87-IRR: Period';

	public static final String IRRCHANGECODE = 'IRR';
	public static final Set<String> NEWCHANGECODESET = new Set<String> {'NEW','NWD','REC'};

	private static final String NOTAPPLICABLE = 'Not Applicable'; 
	private static final String ADDITIONALQUERYFIELDS = ',Account__r.ANG_IsNewGenAgency__c';
 
	private static Decimal ownersTotalPercentage = 0;

	public static String fieldsQuery;
	public static String filterCCQuery = '';
	public static String headerCSV;

	public static String recordTypeName = '';
    
    public static Integer remarkPosition;
    public static Map<string, Integer> ownersByType;

	//Contains values for the CSV to be recovered by a query in the main object
	//
	public static List<String> fieldsList{
		get{ 
			if(fieldsList == null) fieldsList = new List<String>();return fieldsList;
		}
		set;}	

	public static List<String> nameFieldsList{
		get{ 
			if(nameFieldsList == null) nameFieldsList = new List<String>();return nameFieldsList;
		}
		set;}
	//Contains the label headers for the CSV
	//
	public static List<String> headersList{
		get{ 
			if(headersList == null) headersList = new List<String>();return headersList;
		}
		set;}	
	

	public static WrapperCustomFields customFields = new WrapperCustomFields();

	@TestVisible private static List<AMS_CustomSettingsUtils.AMS_EBulletinSetting> eBulletinSettingsList{
		get{ 
			if(eBulletinSettingsList == null) eBulletinSettingsList = new List<AMS_CustomSettingsUtils.AMS_EBulletinSetting>();return eBulletinSettingsList;
		}
		set;}	


	public static List<AMS_CustomSettingsUtils.AMS_EBulletinCCSection> eBulletinCCSectionsList{
		get{ 
			if(eBulletinCCSectionsList == null) eBulletinCCSectionsList = new List<AMS_CustomSettingsUtils.AMS_EBulletinCCSection>();return eBulletinCCSectionsList;
		}
		set;}

	private static Map <String,String> nameApiNameMap{
		get{ 
			if(nameApiNameMap == null) nameApiNameMap = new Map <String,String>();return nameApiNameMap;
		}
		set;}
	
	private static Set <String> irrSet{
		get{ 
			if(irrSet == null) irrSet = new Set <String>();return irrSet;
		}
		set;}

	private static Map<ID,String> countryIsoCodeMap{
		get{ 
			if(countryIsoCodeMap == null) countryIsoCodeMap = new Map <ID,String>();return countryIsoCodeMap;
		}
		set;}
		


	private static List<AMS_AccountRoleCreator.OwnerFieldsEntity> newOwners{
		get{ 
			if(newOwners == null) newOwners = new List<AMS_AccountRoleCreator.OwnerFieldsEntity>();return newOwners;
		}
		set;}

	private static List<AMS_AccountRoleCreator.OwnerFieldsEntity> oldOwners{
		get{ 
			if(oldOwners == null) oldOwners = new List<AMS_AccountRoleCreator.OwnerFieldsEntity>();return oldOwners;
		}
		set;}
	
	/** 
		 Generates: 
		 CSV Header with the recovered metadata records
		 Fields Query to recover the Records
		 Change Codes to Process maped on the change set AMSEBulletinCCExtration__c
	*/
	public static void getEBulletinFields(AMSEBulletinFilters filters, String objectBaseQuery,String csvFormat )
	{
		String typeEBulletinField = TYPEEBULLETINMAP.get(filters.typeEBulletin);

		//system.debug('filters.typeEBulletin: ' + filters.typeEBulletin);
		getEBulletinSettings(typeEBulletinField);

		/****** INI1 Alternative method to recover directly the field labels to use has columns headers ****
		
		Map<String, Schema.SObjectField> fieldMap  = Schema.getGlobalDescribe().get(objectBaseQuery).getDescribe().Fields.getMap();
		
		List<wrapperLabel> wLList = new List<wrapperLabel>();

		Set<String> uniqueObj = new set <String>{objectBaseQuery};
		
		****** FIN1 Alternative method to recover directly the field labels to use has columns headers ****/


		Integer position = 0;


		for (AMS_CustomSettingsUtils.AMS_EBulletinSetting eBulletinSettingG : eBulletinSettingsList)
		{
			//system.debug('eBulletinSettingG: ' + eBulletinSettingG);

			if((Boolean)eBulletinSettingG.eBulletinSetting.get(typeEBulletinField))
			{
				if(!eBulletinSettingG.eBulletinSetting.Do_not_show__c)
					headersList.add(eBulletinSettingG.eBulletinSetting.Label__c);

				if(eBulletinSettingG.eBulletinSetting.IRR_field__c)
					irrSet.add(eBulletinSettingG.eBulletinSetting.API_Name__c.touppercase());

				if(!eBulletinSettingG.eBulletinSetting.Do_not_query__c) 
				{
					fieldsList.add(eBulletinSettingG.eBulletinSetting.API_Name__c.touppercase());
					nameFieldsList.add(eBulletinSettingG.eBulletinSetting.Name);
				}
				else
					customFields.setWrapperCustomField(position,eBulletinSettingG);					

			
				nameApiNameMap.put(eBulletinSettingG.eBulletinSetting.Name, eBulletinSettingG.eBulletinSetting.API_Name__c);

				position++;

			}

			
			/****** INI2 Alternative method to recover directly the field labels to use has columns headers ****
			wrapperLabel wL = new wrapperLabel(objectBaseQuery,EBulletinSetting.API_Name__c,fieldMap);


			wLList.add(wL);

			Objects to Recover Field Mapping
			uniqueObj.add(wL.sObjName); 
		
			****** FIN2 Alternative method to recover directly the field labels to use has columns headers ****/
	
			
		}

		/******* INI3 Alternative method to recover directly the field labels to use has columns headers ****
	
		 Object , FieldMap
		for(wrapperLabel wL : processFieldMaps(wLList,uniqueObj)) headersList.add(wL.fieldLabel);
	
		
		system.debug('wdList: ' + wLList);
		****** FIN3 Alternative method to recover directly the field labels to use has columns headers ****/
	

		fieldsQuery = convertToCSV(fieldsList, ',');
		headerCSV   = convertToCSV(headersList, csvFormat);

		//system.debug('headerCSV: ' + headerCSV);


		//Filter query with values from change set AMSEBulletinCCExtration__c
		
	
	}


	/** 
		 process EBulletin Records 
	*/
	public static String getEBulletinRecordsQuery(AMSEBulletinFilters filters, String objectBaseQuery, String csvFormat, Boolean isCNS)
	{

		getChangeCodesForExtraction(filters);

		//Recover EBulletin Countries
		List<String> countriesFilter = filters.countriesList;
		
		//Recover EBulletin Location Classes
		
		List<String> locClsList = filters.programsList;



		//system.debug('Records query: ' + AMS_QueryUtils.getFieldsQuery(objectBaseQuery,fieldsQuery, ' Change_Code__c in ( ' + convertToCSV(new List<String>(AMS_CustomSettingsUtils.ccNameSectionMap.keyset()), '\',\'') + ') '));

		

		List<String> ccFieldToReturn = new List <String>();
		//FIX TO QUERY THESE EXTRA FIELDS CHANGECODE,STATE,COUNTRY
		for(String header : new List<String> {STATE,COUNTRY,IRRPERIODSD,IRRPERIODED})
		{
			if(customFields.isHeaderCustomField(header)){
				ccFieldToReturn.add(customFields.getAPIFieldValue(header));
				}
		}
		
		//system.debug('ccFieldToReturn:' + ccFieldToReturn);
						

		//*********************************************************************************************************************
		//****************************** BASE QUERY for the Extraction: Changes codes to Query ********************************
		//*********************************************************************************************************************
		
		//TODO Map contains CC name => Section
				
		Set <String> ccNamesToRecover = AMS_CustomSettingsUtils.ccNameSectionMap.keyset();
		
		String filter1 		 = ' Change_Code__c IN :ccNamesToRecover';
		String filter2 		 = ' and Published_on_EBulletin__c = TRUE'; 
		String filter3 		 = ' and Account__r.IATA_ISO_Country__r.ISO_Code__c IN :countriesFilter';		
		String filter4 		 = ' and Account__r.Location_Class__c IN :locClsList';
		String filter5 		 = ' and Created_Date_To_Show__c > ' + filters.fromCCDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')  + ' and Created_Date_To_Show__c < ' + filters.toCCDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		String orderByFilter = ' order by Account__r.IATA_ISO_Country__r.Name,Created_Date_To_Show__c';		

		String filterCC  = filter1 + 
						   filter2 + 
						   filter3 + 
						   filter4 + 
						   filter5 + 
						   orderByFilter;

		//system.debug('filterCC: ' + filterCC);


		String query = AMS_QueryUtils.getFieldsQuery(objectBaseQuery, 
													fieldsQuery + ADDITIONALQUERYFIELDS + ( ccFieldToReturn.isEmpty() ? '' : ',') + convertToCSV(ccFieldToReturn,','), 
												 	filterCC);

		if(!isCNS) {

			ISSP_AMS_EBulletin.updateQueryVariables(ccNamesToRecover, countriesFilter, locClsList);

		} else {

			CNS_EBulletin.updateQueryVariables(ccNamesToRecover, countriesFilter, locClsList);
		}

		

		return query;

	}


	public static String processEBulletinRecords(List<Agency_Applied_Change_code__c> ccList, AMS_EBulletinReportHelper.AMSEBulletinFilters filters, String objectHistBaseQuery, String objectBaseQuery, String csvFormat){

		System.debug('AMS_EBulletinReportHelper - processEBulletinRecords - filters: ' + filters);
		System.debug('AMS_EBulletinReportHelper - processEBulletinRecords - objectBaseQuery: ' + objectBaseQuery);
		System.debug('AMS_EBulletinReportHelper - processEBulletinRecords - csvFormat: ' + csvFormat);

		getChangeCodesForExtraction(filters);

		getEBulletinFields(filters, objectBaseQuery, csvFormat);

		if(customFields.isHeaderCustomField(OWNERS)) customFields.ownersMap = getOwnersfromAACCAccounts(ccList);

		//Changes codes History Objects to print
		//Map representing  Change Code ID => List<ChangeCodeChanges> from the AMS_Agency_A_Change_code_History__c
		
		Map<ID,List<AMS_ChangeCodesHelper.ObjectChange>> ccHistChangesMap = new Map <ID, List<AMS_ChangeCodesHelper.ObjectChange>>();	

		//Countries IDs
		Set<ID> countrySetIDs = new Set<ID>();
		String countryObjVal;

		
		// Recover agency change codes history

		for(AMS_Agency_A_Change_code_History__c ccHist : Database.query( AMS_QueryUtils.getAllFieldQuery(objectHistBaseQuery,null, objectBaseQuery + ' IN :ccList', false) )){

			if(ccHistChangesMap.containsKey(ccHist.Agency_Applied_Change_Code__c))

				ccHistChangesMap.get(ccHist.Agency_Applied_Change_Code__c).add(
					new AMS_ChangeCodesHelper.ObjectChange(ccHist.Object_API_Name__c, ccHist.Field_API_Name__c, ccHist.Field_Old_Value__c, ccHist.Field_New_Value__c,ccHist.Field_Lookup_Old_Value__c,ccHist.Field_Lookup_New_Value__c));

			else

				ccHistChangesMap.put(ccHist.Agency_Applied_Change_Code__c,new List<AMS_ChangeCodesHelper.ObjectChange>{
					new AMS_ChangeCodesHelper.ObjectChange(ccHist.Object_API_Name__c, ccHist.Field_API_Name__c, ccHist.Field_Old_Value__c, ccHist.Field_New_Value__c,ccHist.Field_Lookup_Old_Value__c,ccHist.Field_Lookup_New_Value__c)
					});

			String apiNameToRecover = 
					ccHist.Object_API_Name__c.replace('__c','')  + '__r.' + ccHist.Field_API_Name__c.replace('__c','__r.Name');
			

			if(nameApiNameMap.containsKey(COUNTRY) && nameApiNameMap.get(COUNTRY).split(',').get(0) == apiNameToRecover)
			{
				countrySetIDs.add(ccHist.Field_Lookup_Old_Value__c);
				countrySetIDs.add(ccHist.Field_Lookup_New_Value__c);
				countryObjVal = ccHist.Field_API_Name__c;
			}
		}




		if(countryObjVal != null)
		{
			
			List<String> fielsToRecover = nameApiNameMap.get(COUNTRY).split(',');

			String toRecover = '';

			for(String field : fielsToRecover)
				toRecover = toRecover + field.substring(field.lastIndexOf('.') + 1) + ',' ;
			
			toRecover = toRecover.substring(0,toRecover.length() -1);

			List <SObject> countriesList = Database.query( AMS_QueryUtils.getFieldsQuery(countryObjVal,toRecover, ' ID IN :countrySetIDs'));
		
			//Country Iso Code
			//
			String isoCodeAPIVal = toRecover.split(',').get(1);


			for(SObject countryObj :countriesList)
				countryIsoCodeMap.put(countryObj.ID,String.valueOf(countryObj.get(isoCodeAPIVal)));
			
		}

		
		//Map<String,Boolean> trackChangePerSectionMap = getCCSectionsWithHistory(eBulletinCCSectionsList);

		//Map change Codes (Values) by Section (Key)
		Map<String,List<String>> recordsCSVMap = new Map <String,List<String>>();	

		for (Agency_Applied_Change_code__c ccRecord : ccList) 
		{
			System.debug('AMS_EBulletinReportHelper - processEBulletinRecords - nameApiNameMap: ' + nameApiNameMap);
			System.debug('AMS_EBulletinReportHelper - processEBulletinRecords - nameApiNameMap.get(CHANGECODE): ' + nameApiNameMap.get(CHANGECODE));
			System.debug('AMS_EBulletinReportHelper - processEBulletinRecords - ccRecord.get(nameApiNameMap.get(CHANGECODE)): ' + ccRecord.get(nameApiNameMap.get(CHANGECODE)));
			String ccRecordSection = AMS_CustomSettingsUtils.ccNameSectionMap.get((String) ccRecord.get(nameApiNameMap.get(CHANGECODE)));
			//system.debug('ccRecordSection: ' + ccRecordSection);

			//if(trackChangePerSectionMap.containsKey(ccRecordSection))
			List<String> recordList = getRecordsFromAACCHist(ccRecordSection,ccRecord,ccHistChangesMap.get(ccRecord.Id));			
			//else
			//	recordList = getRecordsFromAACC(ccRecord);


			if(recordsCSVMap.containsKey(ccRecordSection))
				recordsCSVMap.get(ccRecordSection).add(convertToCSV(recordList, csvFormat) + '\n');
			else
				recordsCSVMap.put(ccRecordSection,new List<String>{convertToCSV(recordList, csvFormat) + '\n'});

			oldOwners.clear();
			newOwners.clear();
		}

		String recordsCSV = '';	
		
		//List With sorted sections 
		for (AMS_CustomSettingsUtils.AMS_EBulletinCCSection sectionEntry :  eBulletinCCSectionsList)
		{
			if(recordsCSVMap.containsKey(sectionEntry.eBulletinCCSection.Name)) recordsCSV += String.join(recordsCSVMap.get(sectionEntry.eBulletinCCSection.Name),'');	
		}

		return recordsCSV;

	}




	/** 
		 Get EBulletin Change to be extracted considering also the sections they belong
	*/

	public static void getChangeCodesForExtraction(AMSEBulletinFilters filters){
				//Recover Ebulletin Sections
		getEBulletinCCSections();

		//Get Sections to be extracted depending on Agency Information from the Portal
		Map<String,Boolean> trackAgencyInfoSectionMap = new Map<String,Boolean>();

		trackAgencyInfoSectionMap = getAgencyInfoPerSection(eBulletinCCSectionsList,filters.eBulletinProfile);

		//system.debug('agencyInfoSectionMap:  ' + trackAgencyInfoSectionMap);
		// Recover EBulletin Type
		getEBulletinCCExtraction(TYPEEBULLETINMAP.get(filters.typeEBulletin),trackAgencyInfoSectionMap);
		
	}

	/** 
		 Get EBulletin Settings with the Account / Oscar / Change Codes fields to be recovered 
	*/
	private static void getEBulletinSettings(String typeEBulletin)
	{
		//Condition to get the fiels for EBulletin Daily our Weekly

		for(AMSEBulletinSettings__c setting : AMSEBulletinSettings__c.getAll().values()){

			if( (Boolean) setting.get(typeEBulletin))
				eBulletinSettingsList.add( new AMS_CustomSettingsUtils.AMS_EBulletinSetting(setting,'Number_Order__c'));

		}
		eBulletinSettingsList.sort();

		//eBulletinSettingsList = Database.query(AMS_QueryUtils.getAllFieldQuery('AMSEBulletinSettings__c',TYPEEBULLETINMAP.get(typeEBulletin)+'=true ORDER BY Number_Order__c',false));



		//System.debug('EBulletin Settings to recover: ' + eBulletinSettingsList);
	}

	/** 
		 Get EBulletin Change Codes To process depending on the EBulletin Type 
	*/
	public static void  getEBulletinCCExtraction(String typeEBulletin, Map<String,Boolean> trackAgencyInfoSectionMap)
	{

		for(AMSEBulletinCCExtration__c setting : AMSEBulletinCCExtration__c.getAll().values()){

			if( (Boolean) setting.get(typeEBulletin) && trackAgencyInfoSectionMap.containsKey(setting.Section__c) && trackAgencyInfoSectionMap.get(setting.Section__c)) 
				new AMS_CustomSettingsUtils.AMS_EBulletinCCExtraction(setting);
		}

	}

	/** 
		 Get EBulletin Settings with the Account / Oscar / Change Codes fields to be recovered 
	*/
	public static void getEBulletinCCSections()
	{

		for(AMSEBulletinCCSections__c setting : AMSEBulletinCCSections__c.getAll().values()){
			eBulletinCCSectionsList.add( new AMS_CustomSettingsUtils.AMS_EBulletinCCSection(setting,'Order__c'));

		}
		eBulletinCCSectionsList.sort();


		//System.debug('EBulletin Sections to recover: ' + eBulletinCCSectionsList);
	}

	/** 
		 recover the field Track_CC_History__c from the List of EBulletin Sections (list recovered from the Custom Setting AMSEBulletinCCSections) 
	*/
	/*
	private static Map<String,Boolean> getCCSectionsWithHistory(List<AMS_CustomSettingsUtils.AMS_EBulletinCCSection> sectionsList)
	{
		Map<String,Boolean> trackChangePerSectionMap = new Map<String,Boolean>();

		for (AMS_CustomSettingsUtils.AMS_EBulletinCCSection sectionObj : sectionsList)
			trackChangePerSectionMap.put(sectionObj.eBulletinCCSection.name,sectionObj.eBulletinCCSection.Track_CC_History__c);

		return trackChangePerSectionMap;
	}

	*/
	/** 
		 recover the field Agency_Information__c from the List of EBulletin Sections (list recovered from the Custom Setting AMSEBulletinCCSections) 
	*/
	public static Map<String,Boolean> getAgencyInfoPerSection(List<AMS_CustomSettingsUtils.AMS_EBulletinCCSection> sectionsList, AMS_eBulletin_Profile__c eBulletinProfile)
	{
		Map<String,Boolean> trackAgencyInfoPerSectionMap = new Map<String,Boolean>();

		for (AMS_CustomSettingsUtils.AMS_EBulletinCCSection sectionObj : sectionsList)
			trackAgencyInfoPerSectionMap.put(sectionObj.eBulletinCCSection.name,(Boolean) eBulletinProfile.get(sectionObj.eBulletinCCSection.Agency_Information__c));

		//system.debug('trackAgencyInfoPerSectionMap: ' + trackAgencyInfoPerSectionMap);

		return trackAgencyInfoPerSectionMap;
	}

	/** 
		 Get Account IDs from Change Codes recovered 
	*/
	private static Set<ID> getAccountIdsFromCC(List <Agency_Applied_Change_code__c> ccList)
	{
		Set<ID> acctIDSet = new Set<ID>();
		for (Agency_Applied_Change_code__c cc : ccList)
		{	
			acctIDSet.add(cc.Account__c);
		}
		
		return acctIDSet;
	}

	/** 
		 Get EBulletin Settings with the Account / Oscar / Change Codes fields to be recovered 
	*/
    private static Map<ID,List<AMS_AccountRoleCreator.OwnerFieldsEntity>> getOwnersfromAACCAccounts(List <Agency_Applied_Change_code__c> ccList)
    {
        Set<ID> acctIDSet = getAccountIdsFromCC(ccList);
        
        List<AMS_Account_Role__c> ownersList = 
            Database.query(
                AMS_QueryUtils.getFieldsQuery('AMS_Account_Role__c',' Account__c,Owner_Name__c,Owner_Account__r.Name,Percentage__c ',' Account__c IN :acctIDSet and Active__c = TRUE order by Account__c')
            );
        
        return getOwnersByAccountID(ownersList);	
    }


	/** 
		 Transform the Owners <AMS_Account_Role__c> List recovered into a Map <ID> Account.ID => <String> "Owner Name,Percentage"
	*/
	private static Map<ID,List<AMS_AccountRoleCreator.OwnerFieldsEntity>> getOwnersByAccountID(List <AMS_Account_Role__c> ownersList)
	{

		//Column Owner1,Owner1p
		//
		Map<ID,List<AMS_AccountRoleCreator.OwnerFieldsEntity>> wrapperOwnersMap = new Map<ID,List<AMS_AccountRoleCreator.OwnerFieldsEntity>>();

		for (AMS_Account_Role__c owner : ownersList)
		{
			 
			 AMS_AccountRoleCreator.OwnerFieldsEntity ownerRow = 
			 			new AMS_AccountRoleCreator.OwnerFieldsEntity( ( owner.Owner_Account__r.Name == null ? owner.Owner_Name__c : owner.Owner_Account__r.Name),String.valueOf(owner.Percentage__c));

		
			if(wrapperOwnersMap.containsKey(owner.Account__c))
			{
				List<AMS_AccountRoleCreator.OwnerFieldsEntity> currentOwners = wrapperOwnersMap.get(owner.Account__c);
				currentOwners.add(ownerRow);
				wrapperOwnersMap.put(owner.Account__c, currentOwners );
			}
			else
				wrapperOwnersMap.put(owner.Account__c, new List<AMS_AccountRoleCreator.OwnerFieldsEntity>{ownerRow});

		}
		//system.debug('wrapperOwnersMap: ' + wrapperOwnersMap);

		return wrapperOwnersMap;

	}


	

	/** 
		 convert a list of strings to a string with a custom pattern 
	*/
	private static String convertToCSV(List<String> fieldsListToConvert, String pattern)
	{
		String csvStruct = '';

		for (String field : fieldsListToConvert)
			csvStruct += field + pattern;
		
		csvStruct = (pattern.length()  == 1) ? csvStruct.removeEnd(pattern) : pattern.substring(0,1) + csvStruct.removeEnd(pattern.substring(1));

		return csvStruct;
	}


	/** 
		  Get Record Value from change Codes
	*/
/*
	private List<String> getRecordsFromAACC(Agency_Applied_Change_code__c cc)
	{
		system.debug('change code: ' + cc.Change_Code__c);

		List<String> recordsList = new List <String>();

		Integer customFieldsCounter = 0, positionMax = headersList.size();

		for (Integer position = 0 ; position < positionMax ; position++)
		{	

			if(customFields.headersCustomMap.containsKey(position))
			{
				AMSEBulletinSettings__c headerVal = customFields.headersCustomMap.get(position).eBulletinSetting;
				
				if(!headerVal.Do_not_show__c) 
					recordsList.add(processCustomHeader(headerVal.name,cc));
				else
					positionMax++;

				customFieldsCounter++;
			}
			else
				recordsList.add(AMS_Utils.processParentDependecies(fieldsList.get(position - customFieldsCounter),cc));

		}

		return recordsList;
	}
*/

	/** 
		  Get Record Value
	*/
	private static List<String> getRecordsFromAACCHist(String ccRecordSection, Agency_Applied_Change_code__c cc, List<AMS_ChangeCodesHelper.ObjectChange> ccHistChangesList)
	{
		//Map with API Value as key to cross with AMSEBulletinSetting
		//		
		ownersByType = new Map<string, Integer>();
		Map<String,AMS_ChangeCodesHelper.ObjectChange> ccHistChangesPerAPIValMap = new Map<String,AMS_ChangeCodesHelper.ObjectChange>(); 
		if(ccHistChangesList != null && !ccHistChangesList.isEmpty())
			ccHistChangesPerAPIValMap = getChangesPerAPIValue(ccHistChangesList); 

		//system.debug('cc: ' + cc.change_code__c+ '  ccHistChangesPerAPIValMap: ' + ccHistChangesPerAPIValMap);
		//system.debug('customFields.headersCustomMap: ' +  customFields.headersCustomMap);
		//for(AMS_ChangeCodesHelper.ObjectChangeccHistChangesList)
		List<String> recordsList = new List <String>();

		Integer customFieldsCounter = 0, positionMax = headersList.size();
		
		system.debug('DDD CC: ' + cc.change_Code__c);
		
		system.debug('DDD ccHistChangesPerAPIValMap: ' + ccHistChangesPerAPIValMap);


		for (Integer position = 0 ; position < positionMax ; position++)
		{
			//Fields recovered without querying
			if(customFields.headersCustomMap.containsKey(position))
			{
				AMSEBulletinSettings__c headerVal = customFields.headersCustomMap.get(position).eBulletinSetting;

				if(!headerVal.Do_not_show__c)
					recordsList.add(getRecordFromHeaderAPIValue(ccRecordSection,cc , headerVal, ccHistChangesPerAPIValMap));
				else
					positionMax++;

				customFieldsCounter++;
			}
			//Fields recovered from the Change Code query
			else if(ccHistChangesPerAPIValMap.containsKey(fieldsList.get(position - customFieldsCounter))){

				String strVal = getRecordFromFieldsList(cc , fieldsList.get(position - customFieldsCounter), ccHistChangesPerAPIValMap);
				
				if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(LEGALSTATUS)) strVal = AMS_Utils.transformLegalStatus(strVal);
				
				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(LOCATIONCLASS)) strVal = AMS_Utils.getLocationClassDescr(strVal);

				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(HIERARCHY) || fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(NEWHIERARCHY)) strVal = '=""' + strVal + '""';
                
                else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(ACCREDITATIONTYPE) || fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(NEWACCREDITATIONTYPE)) strVal = AMS_Utils.transformAccreditationType(strVal);

				recordsList.add(strVal);
			}
			else if(  NEWCHANGECODESET.contains(cc.change_code__c) && fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(IATACODE)){
				recordsList.add('');
			}
			else if(cc.change_code__c != IRRCHANGECODE && irrSet.contains(fieldsList.get(position - customFieldsCounter)) && nameFieldsList.get(position - customFieldsCounter) != REASON){
				recordsList.add('');
			}
			else {
				String strVal = checkForDateValue(AMS_Utils.processParentDependecies(fieldsList.get(position - customFieldsCounter),cc));

				if(strVal == null || strVal == '') strVal = '';
				
				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(CHANGECODE)) strVal = getChangeCodeDescr(strVal);

				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(LEGALSTATUS)) strVal = AMS_Utils.transformLegalStatus(strVal);
				
				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(LOCATIONCLASS)) strVal = AMS_Utils.getLocationClassDescr(strVal);

				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(STATUS)) strVal = AMS_Utils.getIATANumericStatus(strVal) + '/' + AMS_Utils.overrideEBulletinStatusDescr(strVal);

				else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(IATACODE) || fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(HIERARCHY)) strVal = '=""' + strVal + '""';
                
                else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(ACCREDITATIONTYPE) || fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(NEWACCREDITATIONTYPE)) strVal = AMS_Utils.transformAccreditationType(strVal);

                else if(fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(CASHCONDITION) || fieldsList.get(position - customFieldsCounter) == nameApiNameMap.get(CASHCONDITION)) strVal = (cc.Account__r.ANG_IsNewGenAgency__c ? strVal : NOTAPPLICABLE);

				recordsList.add(strVal);
                if (fieldsList.get(position - customFieldsCounter) == 'BULLETIN_INFORMATION__C') {
                    remarkPosition = recordsList.size() - 1;
                }
                
			}
			
		}
        if (ownersByType.get('old') > 8 || ownersByType.get('new') > 8) {
            recordsList.set(remarkPosition, recordsList.get(remarkPosition) + Label.EBulletin_More_than_8_owners_message);
        } 
        
		return recordsList;
	}

	/** 
		 Get Record Value from header using AMSEBulletinSettings__c
	*/
	private static String getRecordFromHeaderAPIValue(String ccRecordSection, Agency_Applied_Change_code__c cc, AMSEBulletinSettings__c headerVal, Map<String,AMS_ChangeCodesHelper.ObjectChange> ccHistChangesPerAPIValMap)
	{

		String recordValue;	
		String apiNameUpper = (headerVal.API_Name__c).split(',').get(0).touppercase();
		
		
		//system.debug('headerVal.API_Name__c : ' + headerVal.API_Name__c );
		
		//system.debug('diogo ccHistChangesPerAPIValMap: ' + ccHistChangesPerAPIValMap);

		//system.debug(cc.change_code__c + ': ' + apiNameUpper +  ' ccHistChangesPerAPIValMap.containsKey(apiNameUpper) : ' + ccHistChangesPerAPIValMap.containsKey(apiNameUpper.split(',').get(0)));
		
		//SPECIAL CONDITIONS
		//
		if(headerVal.Name == STATE || headerVal.Name == NEWSTATE) apiNameUpper = apiNameUpper.replace('__R.NAME','__C');
				
		if(headerVal.Name == SECTION) recordValue = ccRecordSection;
		
		// for OLD vs NEW fields
		else if(ccHistChangesPerAPIValMap.containsKey(apiNameUpper))	
		{
			AMS_ChangeCodesHelper.ObjectChange objVal = ccHistChangesPerAPIValMap.get(apiNameUpper);

			if(headerVal.Name == STATE || headerVal.Name == NEWSTATE)
			{
				List<String> countryStateList =  customFields.getAPIPairFieldValuesForCC(COUNTRY,STATE);
				
				AMS_ChangeCodesHelper.ObjectChange objValCountry = ccHistChangesPerAPIValMap.get(countryStateList.get(0).split(',').get(0).touppercase().replace('__R.NAME','__C'));


				recordValue = processCountryOrStateCCHist( headerVal, cc, objVal, objValCountry,countryStateList);
			}			
			
			else if(apiNameUpper == OWNERAPINAME)
			{
				//Recover Owner Info
				//
                
				if(headerVal.Name == OWNERS) {

					newOwners = decodeOwnersInfo(objVal.newValue.split('\n'));
					oldOwners = decodeOwnersInfo(objVal.oldValue.split('\n'));
				}

					
				if(headerVal.is_Field_New__c)
					recordValue = processOwners(headerVal , newOwners , NEWOWNERPOS);
				else
					recordValue = processOwners(headerVal , oldOwners , OWNERPOS);
				
			}
			else if(apiNameUpper == OWNERSTOTALAPINAME)
			{
				recordValue = String.valueOf(ownersTotalPercentage);
				ownersTotalPercentage = 0;
			
			}
			else if (headerVal.Name == NEWLEGALSTATUS)
			{
				recordValue = AMS_Utils.transformLegalStatus(objVal.newValue);
			}
            else if (headerVal.Name == NEWACCREDITATIONTYPE)
			{
				recordValue = AMS_Utils.transformAccreditationType(objVal.newValue);
			}
			else
			{
				recordValue = headerVal.is_Field_New__c ? objVal.newValue : objVal.oldValue;
			}
		}
		else if(!headerVal.IRR_field__c || (headerVal.IRR_field__c && cc.change_code__c == IRRCHANGECODE))
		{
			recordValue = processCustomHeader(headerVal,cc);
		}
		
		return recordValue == null ? '' : recordValue;
	}



	/** 
		 Process Owners Info
	*/
	private static  List<AMS_AccountRoleCreator.OwnerFieldsEntity> decodeOwnersInfo(List<String> objValues)
	{
					
		Boolean removeHeader = true;
		List<AMS_AccountRoleCreator.OwnerFieldsEntity> ownersList = new List<AMS_AccountRoleCreator.OwnerFieldsEntity>();

		for(String row : objValues)
		{
			AMS_AccountRoleCreator.OwnerFieldsEntity ownerEntity = new AMS_AccountRoleCreator.OwnerFieldsEntity();	
			if(removeHeader)
				removeHeader = false;
			else{
				ownerEntity.decodeFromCSV(row);
				ownersList.add(ownerEntity);
			}
		}	
		return ownersList;
	}


	/** 
		 Get Record Value from header using directly API Value
	*/
	private static String getRecordFromFieldsList( Agency_Applied_Change_code__c cc, String headerVal, Map<String,AMS_ChangeCodesHelper.ObjectChange> ccHistChangesPerAPIValMap)
	{	

		AMS_ChangeCodesHelper.ObjectChange objVal = ccHistChangesPerAPIValMap.get(headerVal.split(',').get(0).touppercase());
		return objVal.oldValue == null ? '' : objVal.oldValue;
		

	}


	/** 
		 Get Record Value from the Objects Change Code History linked to the Change Code 
	*/
	private static String processCountryOrStateCCHist(AMSEBulletinSettings__c headerVal, Agency_Applied_Change_code__c cc, AMS_ChangeCodesHelper.ObjectChange objVal,AMS_ChangeCodesHelper.ObjectChange objValCountry, List<String> countryStateList)
	{
		
		String countryIsoCode;
		//Country ISO Code 
		// if Country is not changed we have to recover the country from the Change Code Account
		if(objValCountry != null)
			countryIsoCode = headerVal.is_Field_New__c ? countryIsoCodeMap.get(objValCountry.newValueLookupID) : countryIsoCodeMap.get(objValCountry.oldValueLookupID) ;
		else
			countryIsoCode = String.valueOf(AMS_Utils.processParentDependecies(countryStateList.get(0).split(',').get(1),cc));

		//return State if country in COUNTRYOVERRIDESET
		if (COUNTRYOVERRIDESET.contains(countryIsoCode))
			return headerVal.is_Field_New__c ? objVal.newValue : objVal.oldValue;
		//else return country if its changed
		else if (objValCountry != null)
			return headerVal.is_Field_New__c ? objValCountry.newValue : objValCountry.oldValue;
		//else return country from account
		else
			return headerVal.is_Field_New__c ? '' :String.valueOf(AMS_Utils.processParentDependecies(countryStateList.get(0).split(',').get(0),cc));
		
	}
	

	/** 
		 Get Map with API Value as key to cross with AMSEBulletinSetting API Field
	*/
	private static Map<String,AMS_ChangeCodesHelper.ObjectChange> getChangesPerAPIValue(List<AMS_ChangeCodesHelper.ObjectChange> ccHistChangesList)
	{

		Map<String,AMS_ChangeCodesHelper.ObjectChange> ccHistChangesPerAPIValMap = new Map<String,AMS_ChangeCodesHelper.ObjectChange>();

		
		for( AMS_ChangeCodesHelper.ObjectChange  objChange : ccHistChangesList)
		{
			ccHistChangesPerAPIValMap.put((objChange.objectAPI + '__r.' + objChange.fieldAPI).touppercase(),objChange);
			
			//system.debug('objChange.objectAPI: ' + (objChange.objectAPI + '__r.' + objChange.fieldAPI).touppercase());
			//system.debug('objChange: ' + objChange);
			
		}

		return ccHistChangesPerAPIValMap;
	}

	/**  
		 Get Record Value from Custom Fields (fields that cannot be retrieved directly from the base Object used)
	*/
	private static String processCustomHeader(AMSEBulletinSettings__c headerVal,Agency_Applied_Change_code__c cc)
	{
		
        if(headerVal.Api_Name__c == OWNERAPINAME ){
            return processOwners( headerVal, customFields.ownersMap.get(cc.Account__c),(headerVal.is_Field_New__c ? NEWOWNERPOS:OWNERPOS));
        } else if(headerVal.Api_Name__c == OWNERSTOTALAPINAME){
			
			if(ownersTotalPercentage == 0) return '';

			String recordValue = String.valueOf(ownersTotalPercentage);
			
			ownersTotalPercentage = 0;

			return	recordValue;
		}
		if (headerVal.name == STATE){
			List<String> values =  customFields.getAPIPairFieldValuesForCC(COUNTRY,STATE);
			return processCountryOrState(cc,values);

		}
		else if (headerVal.name == IRRPERIODSD){
			List<String> values =  customFields.getAPIPairFieldValuesForCC(IRRPERIODSD,IRRPERIODED);
			String startDate = cc.get(values.get(0)) == null ? '': String.valueOf(cc.get(values.get(0)));
			String endDate   = cc.get(values.get(1)) == null ? '': String.valueOf(cc.get(values.get(1)));

			return (startDate == null && endDate == null) ? '' : convertToCSV(new List<String>{ startDate, endDate}, ' : ');

		}
		else if (headerVal.name == IRRREASON){
			String ccReasonVal =cc.get(nameApiNameMap.get(IRRREASON)) == null ? '': String.valueOf(cc.get(nameApiNameMap.get(IRRREASON)));

			return ccReasonVal;

		}

		return '';
	}		

	/** 
		 Process Change code Description
	*/
	private static String getChangeCodeDescr(String ccVal)
	{

		String ccReasonVal = AMS_CustomSettingsUtils.ccNameDescrMap.containsKey(ccVal) ? AMS_CustomSettingsUtils.ccNameDescrMap.get(ccVal) : '';

		return ccVal + ' - ' + ccReasonVal;

	}


	/** 
		 Process Owners

	*/
	private static String processOwners(AMSEBulletinSettings__c headerVal , List<AMS_AccountRoleCreator.OwnerFieldsEntity> ownersList, Integer pos)
	{

		if(ownersList == null || integer.valueof(headerVal.name.substring(pos,pos + 1)) > ownersList.size() )
			return '';
		//Percentage of Ownership
		else if (headerVal.name.indexOf('%') > -1)
		{
			String financialInterest = ownersList.get(integer.valueof(headerVal.name.substring(pos , pos + 1)) - 1).financialInterest;
			
			
			try {
  				ownersTotalPercentage = ownersTotalPercentage + Decimal.valueOf(financialInterest);
			}
			catch (exception e) {
 			 	// it's not an Dounble, try something else
 			 	system.debug('Exception: This owner financialInterest is not convertible to String.' );
			}
			

			return financialInterest;
		}
		//Name of the Owner
        else {
            String typeOwner = headerVal.is_Field_New__c ? 'new' : 'old';
            if (!ownersByType.containsKey(typeOwner)) {
                ownersByType.put(typeOwner, ownersList.size());
            }
			return ownersList.get(integer.valueof(headerVal.name.substring(pos , pos + 1)) - 1).name;
        }

	}

	/** 
		 Process Country or State from a List<String> with 2 rows (Country Info, State Info) :
			List{'Account__r.IATA_ISO_Country__r.name,Account__r.IATA_ISO_Country__r.ISO_Code__c'
				,'Account__r.IATA_ISO_Billing_State__r.name,Account__r.IATA_ISO_Billing_State__r.ISO_Code__c'}

	*/
	private static String processCountryOrState(Agency_Applied_Change_code__c cc, List<String> countryStateList)
	{
		//Country ISO Code
		//
		String countryIsoCode = String.valueOf(AMS_Utils.processParentDependecies(countryStateList.get(0).split(',').get(1),cc));

		//return State if
		if (COUNTRYOVERRIDESET.contains(countryIsoCode))
			return String.valueOf(AMS_Utils.processParentDependecies(countryStateList.get(1).split(',').get(0),cc));

		return String.valueOf(AMS_Utils.processParentDependecies(countryStateList.get(0).split(',').get(0),cc));
	}


	/** 
		 Process Field Maps
	*/
	/*
	private List<wrapperLabel> processFieldMaps(List<wrapperLabel> wLList, Set<String> uniqueObj)
	{
		Map<String,Map<String, Schema.SObjectField>> usedFieldMaps = new Map<String,Map<String, Schema.SObjectField>> ();

		for(String obj : uniqueObj){
			system.debug('obj:' + obj);
			usedFieldMaps.put(obj,Schema.getGlobalDescribe().get(obj).getDescribe().Fields.getMap());
		}		

		for(wrapperLabel wL: wLList) 
		{
			system.debug('wL.sObjName:' + wL.sObjName);
			system.debug('wL.fieldName:' + wL.fieldName);
			system.debug('wL.fieldLabel:' + wL.fieldLabel);
			wL.setFieldLabel(usedFieldMaps.get(wL.sObjName).get(wL.fieldName).getDescribe().getLabel());
		}
		return wLList;
	}

	*/

	/** 
	 Wrapper Object for representing the fiels that will not be queried or showed

	*/
	private class WrapperCustomFields {

		private Map<Integer,AMS_CustomSettingsUtils.AMS_EBulletinSetting> headersCustomMap {
		get{ 
			if(headersCustomMap == null) headersCustomMap = new Map<Integer,AMS_CustomSettingsUtils.AMS_EBulletinSetting>();return headersCustomMap;
		}
		set;}

		private Map<ID,List<AMS_AccountRoleCreator.OwnerFieldsEntity>> ownersMap = new Map<ID,List<AMS_AccountRoleCreator.OwnerFieldsEntity>>();

		private WrapperCustomFields(){
        }

        private void setWrapperCustomField(Integer position, AMS_CustomSettingsUtils.AMS_EBulletinSetting fieldSetting){
        	headersCustomMap.put(position,fieldSetting);
        }

        private Boolean isHeaderCustomField(String customField){

        	for (AMS_CustomSettingsUtils.AMS_EBulletinSetting ebSetting : headersCustomMap.values()){
        		if(ebSetting.eBulletinSetting.name == customField) return true;
        	}

        	return false;
        }
        
        private String getAPIFieldValue(String customField){

        	for (AMS_CustomSettingsUtils.AMS_EBulletinSetting ebSetting : headersCustomMap.values()){
        		if(ebSetting.eBulletinSetting.name == customField) return ebSetting.eBulletinSetting.API_Name__c;
        	}

        	return null;
        }
        private List<String> getAPIPairFieldValuesForCC(String value1, String value2){

			String value1AN = '', value2AN = '';

        	for (AMS_CustomSettingsUtils.AMS_EBulletinSetting ebSetting : headersCustomMap.values()){

        		if(ebSetting.eBulletinSetting.name == value1)
        			 value1AN = ebSetting.eBulletinSetting.API_Name__c;

        		else if(ebSetting.eBulletinSetting.name == value2) 
        			value2AN = ebSetting.eBulletinSetting.API_Name__c;
        	}

        	return new List <String> {value1AN,value2AN};
        }

        /*
        private String getCountryOrState(){
        	
        	String countryOrState = '';

        	for (AMS_CustomSettingsUtils.AMS_EBulletinSetting ebSetting : headersCustomMap.values()){
				if(ebSetting.eBulletinSetting.name.equals(COUNTRY))
        			 countryOrState = ebSetting.eBulletinSetting.API_Name__c;				        		


        	}
        	return countryOrState;
        }
		*/
	}

	/** 
	 Wrapper Object for Mapping the Labels for Entities  
	 Example : change_code__r.Account__r.name 

	*/
	/*
	private class wrapperLabel {
		
		private String sObjName{get;set;}
        private String fieldName{get;set;}
  		private String fieldLabel{get;set;}

        private wrapperLabel(String sObjParentName, String field, Map<String, Schema.SObjectField> fieldMap){

           	List <String> strList = field.split('\\.');
			integer lastPos = strList.size() -1;

			String sObjName = sObjParentName;


			if (lastPos>0) 
			{
				if(strList.get(lastPos -1 ).equals('Parent'))
					lastPos--;

				sObjName  = fieldMap.get(strList.get(lastPos -1 ).replace('__r','__c')).getDescribe().getReferenceTo()[0].getDescribe().Name;
				system.debug('strList.get(lastPos -1 ): ' + strList.get(lastPos -1 ));
			}

			system.debug('sObjName: ' + sObjName);
			this.sObjName   = sObjName;
			this.fieldName = strList.get(strList.size() -1); 

        }

        private void setFieldLabel(String fieldLabel){
        	this.fieldLabel = fieldLabel;
        }

	}
	*/
	/** 
		 Get Date Value from current field beeing extracted
	*/
	public static String checkForDateValue(Object potencialDate)
	{
		Date dateVal;
		
		if(potencialDate instanceof Date) dateVal = (Date) potencialDate;
		else if(potencialDate instanceof Datetime) 
		{
			Datetime dateTimeVal = (Datetime) potencialDate;
			dateVal = dateTimeVal.date();
		}


		return (dateVal == null) ? String.valueOf(potencialDate) : generateDateForBulletin(dateVal);
	}
	
	//Format the date in the eBulletin Format (dd-mmm-yyyy)
	public static String generateDateForBulletin(Date dValue){
		if(dValue==null) return '';
		list<string> lsMonthName = new list<string>{'-','JAN','FEB','MAR','APR','MAY','JUN','JUL','AUG','SEP','OCT','NOV','DEC'};
		return string.valueOf(dValue.day() + '-' + lsMonthName.get(dValue.month()) + '-' + dValue.year());
	}


	@future
	 public static void updateEbulletinProfile(Datetime dateLastRun, ID ebProfileID, ID attachmentID) {

		//Set the last run time
		AMS_eBulletin_Profile__c ebProfile = [select Last_Run__c from AMS_eBulletin_Profile__c where id = :ebProfileID ];

	 	ebProfile.Last_Run__c = dateLastRun;

		update ebProfile;

	    Datetime limitDate = system.now().addDays(-5);
		delete [select id from attachment where parentid = :ebProfileID and id <> :attachmentID and createdDate < :limitDate ];
	}

		/** 
	Exceptions handling for E Bulletin	
	*/	

	public class AMS_EBulletinException extends Exception {}

	/** 
	 Wrapper Object with the filters from the Portal

	*/
	public class AMSEBulletinFilters {
		
		public String typeEBulletin;
        public List <String> areaList = new List <String>();
  		public List <String> programsList = new List <String>();
  		public List <String> countriesList = new List <String>();
  		public Datetime fromCCDate;
        public Datetime toCCDate;
       	public AMS_eBulletin_Profile__c eBulletinProfile;

        public AMSEBulletinFilters(AMS_eBulletin_Profile__c eBulletinProfile, Datetime fromCCDate, Datetime toCCDate){
        		//Daily or Weekly by record type
			
			recordTypeName =Schema.SObjectType.AMS_eBulletin_Profile__c.RecordTypeInfosById.get(eBulletinProfile.RecordTypeId).Name;

			this.typeEBulletin = recordTypeName.substring(0, 1).ToUpperCase();
			
			
			// map with field Account__r.IATA_ISO_Country__r.IATA_Regional_Office__c
			List <String> areaList = new List<String>();

			if(eBulletinProfile.Area_1__c ) areaList.add('MIA');
			if(eBulletinProfile.Area_2__c ) areaList.addAll(new List <String>{'MAD','AMM'});
			if(eBulletinProfile.Area_3__c ) areaList.addAll(new List <String>{'SIN','BJS'});

			this.areaList = areaList;

			// Program = Location_Class__c. C = Cargo. P = Passenger. (R = CassAssociate. I = Import. Q = Courier). D = Domestic.

			List <String> programsList = new List<String>();
			
			if(eBulletinProfile.Program_Cargo__c)			programsList.add('C');		
			if(eBulletinProfile.Program_CASS_Associates__c)	programsList.addAll(new List <String>{'R','I','Q'});	
			if(eBulletinProfile.Program_Passage__c)			programsList.add('P');
			if(eBulletinProfile.Program_Domestic__c)		programsList.add('D');
			
			
			this.programsList = programsList;

			//map countries List
			
			this.countriesList = eBulletinProfile.CountriesList__c.split(';');

			// filter by Date

			this.fromCCDate = fromCCDate;
			this.toCCDate   = toCCDate;

			// Agency Information Mapping --- for this case the profile must be passed (mapped in the Custom Setting AMSEBulletinCCSections)
			
			this.eBulletinProfile = eBulletinProfile;
		/*eBulletinProfile.Agency_Info_Defaults__c;
			eBulletinProfile.Agency_Info_Reviews__c;
			eBulletinProfile.Agency_Info_New_Aplication_Processes__c;
			eBulletinProfile.Agency_Info_Agency_Changes__c;
			eBulletinProfile.Agency_Info_Irregularities__c;
			eBulletinProfile.Agency_Info_Termination_Closures__c;
			*/
        }


	}

}
