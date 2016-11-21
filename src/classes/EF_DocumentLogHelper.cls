public with sharing class EF_DocumentLogHelper
{
	private static final String standardAttachmentUpload_Failure = 'Error in uploading standard attachment: ';
	private static final String standardAttachmentUpload_Success = 'Upload successful: ';

	private static final Set<String> mandatoryFields = new Set<String>
	{
		'Name',
		'FileName__c',
		'Category__c',
		'Created_On__c',
		'AttachmentId__c',
		'ParentId__c'
	};

	public static void updateLogRecords(List<EF_Document_Log__c> recordList, Map<Id, EF_Document_Log__c> oldMap)
	{

	}

	public static void writeLogLine(EF_Document_Log__c dl, String message)
	{
		if(message != null)
		{
			String currentTime = getTimeStamp();
			String currentUser = UserInfo.getName();
			
			String oldLog = '';
			if(dl.Log__c != null)
			{
				oldLog = dl.Log__c;
			}

			dl.Log__c = currentUser + ' ' + currentTime + ': ' + message + '\n'+oldLog;
		}
	}

	public static void setStatus(EF_Document_Log__c dl, String newStatus, String messageToLog)
	{
		if(newStatus != null)
		{
			dl.Status__c = newStatus;
		}
		if(messageToLog != null)
		{
			writeLogLine(dl, messageToLog);
		}
	}

	public static String getTimeStamp()
	{
		return Datetime.now().format('yyyy-MM-dd HH:mm:ss');
	}

	public static void identifyDocumentsWithCompleteMetadata(List<EF_Document_Log__c> newList, Map<Id, EF_Document_Log__c> oldMap)
	{
		List<EF_Document_Log__c> toAmazonList = new List<EF_Document_Log__c>();
		for(EF_Document_Log__c dl : newList)
		{
			if(validateMandatoryFields(dl))
			{
				setStatus(dl, 'Metadata Updated', 'Mandatory metadata fields are filled in. Starting the Amazon upload process.');
				dl.Send_to_Amazon__c = true;
			}
			else
			{
				// setStatus(dl, 'Attachment - Failure', 'Mandatory metadata fields missing. Unable to start Amazon upload process.');
				System.debug('************ dl fail: '+dl);
			}
		}
	}

	public static AmazonFile__c createAmazonFileRecord(EF_Document_Log__c dl)
	{
		AmazonFile__c af = new AmazonFile__c();
		return af;
	}

	public static List<EF_Document_Log__c> identifyDocumentsForAmazonProcessing(List<EF_Document_Log__c> newList, Map<Id, EF_Document_Log__c> oldMap)
	{
		List<EF_Document_Log__c> toAmazonList = new List<EF_Document_Log__c>();
		for(EF_Document_Log__c dl : newList)
		{
			if(dl.Send_To_Amazon__c && !oldMap.get(dl.Id).Send_To_Amazon__c)
			{
				toAmazonList.add(dl);
			}
		}
		return toAmazonList;
	}

	public static Set<Id> identifyDocumentsWithSuccessfulAmazonProcessing(List<EF_Document_Log__c> newList, Map<Id, EF_Document_Log__c> oldMap)
	{
		Set<Id> toDeleteList = new Set<Id>();
		for(EF_Document_Log__c dl : newList)
		{
			if(dl.Status__c != oldMap.get(dl.Id).Status__c)
			{
				if(dl.Status__c.equalsIgnoreCase('Amazon - Upload Successful'))
				{
					toDeleteList.add(dl.AttachmentId__c);
				}
			}
		}
		return toDeleteList;
	}

	public static boolean validateMandatoryFields(EF_Document_Log__c dl)
	{
		for(String mandatoryField : mandatoryFields)
		{
			if(dl.get(mandatoryField) == null || dl.get(mandatoryField).equals(''))
			{
				// dl.addError('Mandatory field '+mandatoryField+' is not set.');
				setStatus(dl, 'Attachment - Failure', 'Mandatory field '+mandatoryField+' is not set.');
				return false;
			}
			if(mandatoryField.equals('AttachmentId__c') || mandatoryField.equals('ParentId__c'))
			{
				String value = (String) dl.get(mandatoryField);
				if(value.length() != 15 && value.length() != 18)
				{
					// dl.addError(mandatoryField +' is incorrect: ' + value + '. The correct ID field values are 15 or 18 characters.');
					setStatus(dl, 'Attachment - Failure', mandatoryField +' is incorrect: ' + value + '. The correct ID field values are 15 or 18 characters.');
					return false;
				}
			}
		}
		return true;
	}
}