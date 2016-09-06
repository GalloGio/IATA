/** 
EBulletin helper methods

EBulletin is a CSV dispatch 3 main informatory activities about IATA agencies:
1.	New applications & Approved/Disapproved applications
2.	Changes like ownership, location, etc...
3.	Non-compliance like default, irregularity
	*/

public class AMS_EBulletinReportHelper {

	private static List<AMS_EBulletin_Setting__mdt> EBulletinSettingsList{get;set;}
	public static String fieldsQuery{get;set;}
	public static String headerCSV{get;set;}
	
	public static List<String> fieldsList{
		get{ 
			if(fieldsList == null) fieldsList = new List<String>();return fieldsList;
		}
		set;}	
	
	public static List<String> headersList{
		get{ 
			if(headersList == null) headersList = new List<String>();return headersList;
		}
		set;}


	/** 
		 Get EBulletin Settings with the Account / Oscar / Change Codes fields to be recovered 
	*/
	private static void getEBulletinSettings()
	{

		EBulletinSettingsList = Database.query(AMS_QueryUtils.getAllFieldQuery('AMS_EBulletin_Setting__mdt','In_Use__c=true ORDER BY Number_Order__c',false));

		System.debug('E Bulletin Settings to recover: ' + EBulletinSettingsList);
	}

	/** 
		 Generate CSV Header with the recovered metadata records 
	*/
	public static void getEBulletinFields(String csvFormat , String objectBaseQuery)
	{
		getEBulletinSettings();

		Map<String, Schema.SObjectField> fieldMap  = Schema.getGlobalDescribe().get(objectBaseQuery).getDescribe().Fields.getMap();

		List<wrapperLabel> wLList = new List<wrapperLabel>();

		Set<String> uniqueObj = new set <String>{objectBaseQuery};


		for (AMS_EBulletin_Setting__mdt EBulletinSetting : EBulletinSettingsList)
		{
			fieldsList.add(EBulletinSetting.Label);
				
			system.debug('EBulletinSetting.Label: ' + EBulletinSetting.Label);

			wrapperLabel wL = new wrapperLabel(objectBaseQuery,EBulletinSetting.Label,fieldMap);

			wLList.add(wL);

			//Objects to Recover Field Mapping
			uniqueObj.add(wL.sObjName); 

			//headersList.add(fieldMap.get(EBulletinSetting.Label).getDescribe().getLabel());
			
		}

		// Object , FieldMap

		for(wrapperLabel wL : processFieldMaps(wLList,uniqueObj)) headersList.add(wL.fieldLabel);

		system.debug('wdList: ' + wLList);
		

		fieldsQuery = convertToCSV(fieldsList, ',');
		headerCSV   = convertToCSV(headersList, csvFormat);

		system.debug('headerCSV: ' + headerCSV);
	
	}

	/** 
		 process EBulletin Records 
	*/
	public String processEBulletinRecords(String objectBaseQuery ,String csvFormat)
	{
		system.debug('query: ' + AMS_QueryUtils.getFieldsQuery(objectBaseQuery,fieldsQuery, ''));

		List <Agency_Applied_Change_code__c> ccHistList = Database.query(AMS_QueryUtils.getFieldsQuery(objectBaseQuery,fieldsQuery, ''));


		String recordsCSV = '';	

		for (Agency_Applied_Change_code__c ccHist : ccHistList) 
		{
			List<String> recordList = processParentDependecies(fieldsList,ccHist);
			
			recordsCSV += convertToCSV(recordList, csvFormat) + '\n';

		}

		recordsCSV.removeEnd('\n');

		System.debug('CSV Records: ' + recordsCSV);

		return recordsCSV;

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
		 Process Parent Objects fields (up to 5 Parents?)
	*/
	private List<String> processParentDependecies(List<String> fieldsListToProcess,Agency_Applied_Change_code__c ccHist)
	{
		List<String> recordList = new List <String>();

		for (String field : fieldsListToProcess)
		{	
			//if(	Schema.getGlobalDescribe().get(objectBaseQuery).getDescribe().Fields.getMap().get(field).getDescribe().getType() == Schema.DisplayType.Reference)
			sObject sObj = ccHist;

			if(field.contains('.'))
			{
				wrapperData wDObj = new wrapperData(sObj,field);
				
				recordList.add(
					String.valueOf(
						(wDObj.sObj == null || wDObj.sObj.get(wDObj.fieldName) == null ) ? '' :wDObj.sObj.get(wDObj.fieldName)
						)
					);
			}
			else
				recordList.add(
					String.valueOf(
						(ccHist.get(field) == null) ? '' : ccHist.get(field)
						)
					);

		}
		return recordList;
	}
/** 
		 Process Field Maps
	*/
	private static List<wrapperLabel> processFieldMaps(List<wrapperLabel> wLList, Set<String> uniqueObj)
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


	/** 
	 Wrapper Object for Mapping the Entity for Field 
	 Example : change_code__r.Account__r.name 

	*/
	private class wrapperData {
		
		private sObject sObj{get;set;}
        private String fieldName{get;set;}
  	/** 
		 Get Object for the Field  (up to 5 Parents?)
	*/
        private wrapperData(SObject sObjParent, String field){

           	List <String> strList = field.split('\\.');
			integer lastPos = strList.size() -1;
		
			sObject sObj = sObjParent;

			for(integer i = 0 ; i < lastPos ; i++) //avoid last element
			{				
				sObj = sObj.getSObject(strList.get(i));
			}

			this.sObj   = sObj;
			this.fieldName = strList.get(lastPos); 

        }

	}

	/** 
	 Wrapper Object for Mapping the Labels for Entities  
	 Example : change_code__r.Account__r.name 

	*/
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
				if(strList.get(lastPos -1 ) == 'Parent')
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



}