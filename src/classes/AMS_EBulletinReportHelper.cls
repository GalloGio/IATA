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
	public static void getEBulletinFields(String csvFormat)
	{
		getEBulletinSettings();

		for (AMS_EBulletin_Setting__mdt EBulletinSetting : EBulletinSettingsList)
		{
			fieldsList.add(EBulletinSetting.Field_API_Name__c);
			headersList.add(EBulletinSetting.Label);
		}

		fieldsQuery = convertToCSV(fieldsList, ',');
		headerCSV   = convertToCSV(headersList, csvFormat);
	
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
			
			recordsCSV += AMS_EBulletinReportHelper.convertToCSV(recordList, csvFormat) + '\n';

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
	private static List<String> processParentDependecies(List<String> fieldsListToProcess,Agency_Applied_Change_code__c ccHist)
	{
		List<String> recordList = new List <String>();

		for (String field : fieldsListToProcess)
		{	
			//if(	Schema.getGlobalDescribe().get(objectBaseQuery).getDescribe().Fields.getMap().get(field).getDescribe().getType() == Schema.DisplayType.Reference)
			sObject sObj = ccHist;

			if(field.contains('.'))
			{
				List <String> strList = field.split('\\.');
				integer lastPos = strList.size() -1;

				for(integer i = 0 ; i < lastPos ; i++) //avoid last element
				{				
					sObj = sObj.getSObject(strList.get(i));
					if (sObj == null)
						break;
				}
				
				recordList.add(
					String.valueOf(
						(sObj == null || sObj.get(strList.get(lastPos)) == null ) ? '' :sObj.get(strList.get(lastPos))
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

}