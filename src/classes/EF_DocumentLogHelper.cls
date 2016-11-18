public with sharing class EF_DocumentLogHelper
{
	private static final String standardAttachmentUpload_Failure = 'Error in uploading standard attachment: ';
	private static final String standardAttachmentUpload_Success = 'Upload successful: ';

	private static final Set<String> mandatoryFields = new Set<String>
	{
		'Name',
		'FileName__c',
		'Category__c',
		'Document_Date__c',
		'AttachmentId__c',
		'ParentId__c'
	};

	public static void updateLogRecords(List<EF_Document_Log__c> recordList, Map<Id, EF_Document_Log__c> oldMap)
	{

	}

	public static void writeLogLine()
	{

	}

	public static void setStatus()
	{

	}

	public static String getTimeStamp()
	{
		return Datetime.now().format('yyyy-MM-dd HH:MM:ss');
	}

	public static List<EF_Document_Log__c> identifyDocumentsWithCompleteMetadata(List<EF_Document_Log__c> newList, Map<Id, EF_Document_Log__c> oldMap)
	{
		List<EF_Document_Log__c> toAmazonList = new List<EF_Document_Log__c>();
		for(EF_Document_Log__c l : newList)
		{
			if(l.Send_To_Amazon__c && !oldMap.get(l.Id).Send_To_Amazon__c)
			{
				toAmazonList.add(l);
			}
		}
		return toAmazonList;
	}

	public static List<EF_Document_Log__c> identifyDocumentsForAmazonProcessing(List<EF_Document_Log__c> newList, Map<Id, EF_Document_Log__c> oldMap)
	{
		List<EF_Document_Log__c> toAmazonList = new List<EF_Document_Log__c>();
		for(EF_Document_Log__c l : newList)
		{
			if(l.Send_To_Amazon__c && !oldMap.get(l.Id).Send_To_Amazon__c)
			{
				toAmazonList.add(l);
			}
		}
		return toAmazonList;
	}

	public static boolean validateMandatoryFields(EF_Document_Log__c l)
	{
		for(String mandatoryField : mandatoryFields)
		{
			if(l.get(mandatoryField) == null || l.get(mandatoryField).equals(''))
			{
				l.addError('Mandatory field '+mandatoryField+' is not set.');
				return false;
			}
			if(mandatoryField.equals('AttachmentId__c') || mandatoryField.equals('ParentId__c'))
			{
				String value = (String) l.get(mandatoryField);
				if(value.length() != 15 || value.length() != 18)
				{
					l.addError(mandatoryField +' is of wrong length: ' + value + '. The correct ID values are 15 and 18 characters.');
					return false;
				}
			}
		}
		return true;
	}
}