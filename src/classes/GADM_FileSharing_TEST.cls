@isTest
public class GADM_FileSharing_TEST {
	@TestSetup
	private static void setup() {
		List<Group> internalUsersGroup = [SELECT Id FROM Group WHERE DeveloperName = 'GADM_Internal_Users'];
		Id intUsersGroupId = null;
		if(internalUsersGroup.size() == 0){
			Group group1 = new Group();
			group1.DeveloperName = 'GADM_Internal_Users';
			group1.Name = 'GADM_Internal_Users';
			group1.Type = 'Regular';
			insert group1;
			intUsersGroupId = group1.Id;
		} else {
			intUsersGroupId = internalUsersGroup[0].Id;
		}

		List<GroupMember> internalUsersGroupMember = [SELECT Id FROM GroupMember WHERE UserOrGroupId =: UserInfo.getUserId() AND GroupId =: intUsersGroupId];
		if (internalUsersGroupMember.size() == 0){
			GroupMember groupMember1 = new GroupMember();
			groupMember1.UserOrGroupId = UserInfo.getUserId();
			groupMember1.GroupId = intUsersGroupId;
			insert groupMember1;
		}
	}

	@IsTest
	private static void shareServiceNotification() {
		Portal_Applications__c portalApplications = new Portal_Applications__c();
		portalApplications.Name = 'GADM';
		insert portalApplications;

		Service_Notification__c message = new Service_Notification__c();
		message.Header__c = 'header';
		message.Body__c = 'head';
		message.Valid_From__c = Date.Today();
		message.Valid_To__c = Date.Today();
		message.Service__c = portalApplications.Id;
		insert message;

		Id gadmRT = RecordTypeSingleton.getInstance().getRecordTypeId('ContentVersion', 'GADM');
		ContentVersion contentVersion = new ContentVersion(
		  Title = 'testFile',
		  PathOnClient = 'testFile.jpg',
		  VersionData = Blob.valueOf('Test Content'),
		  RecordTypeId = gadmRT,
		  IsMajorVersion = true,
		  Valid_From__c = Date.today().addDays(-2),
		  Valid_To__c = Date.today().addDays(2)
		);
		insert contentVersion;
		
        ContentVersion testContent = [SELECT ContentDocumentId FROM ContentVersion where Id = :contentVersion.Id]; 
        GADM_FileSharing.assignGadmRecordType([SELECT Id, CreatedById, RecordTypeId FROM ContentVersion WHERE id =: contentVersion.Id]);
        
        ContentDocumentLink contentlink=new ContentDocumentLink();
        contentlink.LinkedEntityId=message.id;
        contentlink.ShareType= 'C'; 
        contentlink.ContentDocumentId=testContent.ContentDocumentId;
        contentlink.Visibility = 'AllUsers'; 
        insert contentlink;        
        
		List<ContentVersion> cvs = [SELECT Id, RecordTypeId FROM ContentVersion WHERE Id =: contentVersion.Id];
		system.assertEquals(gadmRT, cvs[0].RecordTypeId);

	}
}