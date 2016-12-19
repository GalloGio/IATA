public with sharing class EF_AttachmentTriggerHandler
{
    public static boolean isMemberOfMassUploadGroup()
    {
    	List<GroupMember> massUploaders = [SELECT Id, Group.Id FROM GroupMember WHERE Group.DeveloperName = 'EF_Document_Mass_Uploaders' AND UserOrGroupId =:UserInfo.getUserId()];
    	if(!massUploaders.isEmpty())
    		return true;
    	else
    		return false;
	}

	public static EF_Document_Log__c createDocumentLogRecord(Attachment att)
	{
		EF_Document_Log__c newLog = new EF_Document_Log__c();
		newLog.AttachmentId__c = att.Id;
		newLog.FileName__c = att.Name;
		newLog.ParentId__c = att.ParentId;
		return newLog;
	}
}