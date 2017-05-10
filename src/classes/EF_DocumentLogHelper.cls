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

    public static AmazonFile__c createAmazonFileRecord(String fileName, String amazonKey, Long filesize, String parentId, String recordType, EF_Document_Log__c dl)
    {
    	AmazonFile__c amazonFile;
        try {
              amazonFile = new AmazonFile__c(
                Name = fileName.substring(0,80),
                sObject_Id__c = parentId,
                Full_Name_Unique__c = amazonKey,
                Category__c = dl.Category__c,
                Subcategory__c = dl.SubCategory__c,
                Document_Date__c = Date.newInstance(dl.Created_On__c.year(), dl.Created_On__c.month(), dl.Created_On__c.day()),
                Expired__c = dl.Expired__c,
                Expiry_Date__c = dl.Expiry_Date__c,
                SAP_Number__c = dl.SAP_Reference__c,
                Additional_Information__c = dl.Additional_Information__c,
                EF_Private__c = dl.EF_Private__c,
                Size_MB__c = filesize* 0.000001,
                RecordTypeId = recordType,
                EF_Created_By__c = dl.Created_By__c, 
                EF_Created_On__c = dl.Created_On__c, 
                EF_Enterprise_Keywords__c = dl.Enterprise_Keywords__c, 
                EF_Modified_By__c = dl.Modified_By__c,
				EF_Modified_On__c = dl.Modified_On__c
            );
            return amazonFile;
        } catch(Exception e) {
            System.debug('******** Error creating an AmazonFile__c object: ' + e.getMessage());
        }

        return null;
    }

	@Future(callout=true)
	public static void createAmazonAttachmentsFromAttachments(Set<Id> lsAttachmentIds)
	{	
		Map<Id, EF_Document_Log__c> logsToUpdate = getLogRecordsToUpdateMap(lsAttachmentIds);		
		List<EF_Document_Log__c> toUpdateList = new List<EF_Document_Log__c>();
		List<AmazonFile__c> attachmentsToInsert = new List<AmazonFile__c>();
		AmazonFile__c af;
		EF_Document_Log__c dl;
		Id efFileRtId = AMS_Utils.getId('AmazonFile__c', 'EF_File');

		List<Attachment> lsAttachments = [SELECT Id, Name, ParentId, ContentType, BodyLength, Body FROM Attachment WHERE Id IN :lsAttachmentIds];
		EF_AttachmentListController c = new EF_AttachmentListController();
if(!Test.isRunningTest()) {

		for(Attachment a: lsAttachments)
		{
			String folder =  WrapperAttach.getAmazonFolder(a.ParentId);
			String credentialName = c.credentialName;
			EF_AttachmentListController.UploadFile credentialNames = EF_AttachmentListController.createUploadFile(a.ParentId,  a.Name, a.contentType, a.BodyLength, folder, credentialName);

			String  amazonFilePath = credentialNames.endpoint+credentialNames.bucketName+'/'+credentialNames.fullFileNameEncoded;
			Http h = new Http();
			HttpRequest xhr = new HttpRequest();
			xhr.setEndpoint(amazonFilePath);
			xhr.setMethod('PUT');
			xhr.setHeader('Cache-Control', 'no-cache');
			xhr.setHeader('Authorization',credentialNames.authorization);
			xhr.setHeader('X-Amz-Date',credentialNames.timestamp);
			xhr.setHeader('Content-Type',a.contentType+';charset=UTF-8');

			xhr.setBodyAsBlob(a.Body);

			HttpResponse res1 = null;
			res1 = h.send(xhr);
			Integer StatusCode = res1.getStatusCode();
			if(StatusCode == 200)
			{
				if(logsToUpdate.get(a.Id) != null)
				{
					dl = logsToUpdate.get(a.Id);
					setStatus(dl, 'Amazon - Upload Successful', 'File uploaded successfully to Amazon WS.');
					toUpdateList.add(dl);
				}
				if(logsToUpdate.get(a.Id) != null)
				{
					dl = logsToUpdate.get(a.Id);
					List<String> splitFullFileName = credentialNames.fullFileName.split('/');
					String filename = splitFullFileName.isEmpty()? '': splitFullFileName.get(splitFullFileName.size()-1);

					af = createAmazonFileRecord(fileName, credentialNames.fullFileName, a.BodyLength, a.ParentId, efFileRtId, dl);
					if(af != null)
						attachmentsToInsert.add(af);
				}
			}
			else
			{
				if(logsToUpdate.get(a.Id) != null)
				{
					dl = logsToUpdate.get(a.Id);
					setStatus(logsToUpdate.get(a.Id), 'Amazon - Upload Error', 'Error occurred during Amazon WS upload: '+res1.toString());
					toUpdateList.add(dl);
				}
			}
		}

		if(toUpdateList.size() > 0)
			update toUpdateList;
		if(attachmentsToInsert.size() > 0)
			insert attachmentsToInsert;
	}
	}

	public static Map<Id, EF_Document_Log__c> getLogRecordsToUpdateMap(Set<Id> attachmentIds)
	{
		List<EF_Document_Log__c> dls = [select Id, AttachmentId__c, Status__c, Log__c, Additional_Information__c, Category__c, SubCategory__c, 
				EF_Private__c, SAP_Reference__c, Expired__c, Expiry_Date__c, Created_By__c, Created_On__c, Enterprise_Keywords__c, Modified_By__c,
				Modified_On__c from EF_Document_Log__c where AttachmentId__c in :attachmentIds];
		Map<Id, EF_Document_Log__c> attIdDlMap = new Map<Id, EF_Document_Log__c>();
		for(EF_Document_Log__c dl : dls)
		{
			attIdDlMap.put(dl.AttachmentId__c, dl);
		}

		return attIdDlMap;
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
			if(dl.Status__c.contains('Attachment'))
			{
				if(validateMandatoryFields(dl))
				{
					setStatus(dl, 'Metadata Updated', 'Mandatory metadata fields are filled in. Starting the Amazon upload process.');
					dl.Send_to_Amazon__c = true;
				}
				else
				{
					setStatus(dl, 'Attachment - Failure', 'Mandatory metadata fields missing. Unable to start Amazon upload process.');
					System.debug('************ dl fail: '+dl);
				}
			}
		}
	}

	public static Set<Id> identifyDocumentsForAmazonProcessing(List<EF_Document_Log__c> newList, Map<Id, EF_Document_Log__c> oldMap)
	{
		Set<Id> toAmazonList = new Set<Id>();
		for(EF_Document_Log__c dl : newList)
		{
			if(dl.Send_To_Amazon__c && !oldMap.get(dl.Id).Send_To_Amazon__c)
			{
				toAmazonList.add(dl.AttachmentId__c);
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

			if( (mandatoryField.equals('AttachmentId__c') || mandatoryField.equals('ParentId__c')) 
				 	&& (!dl.Status__c.equalsIgnoreCase('Attachment - Delete Error') && !dl.Status__c.equalsIgnoreCase('Process Completed')) ) 
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