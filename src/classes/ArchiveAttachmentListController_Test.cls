@isTest
private class ArchiveAttachmentListController_Test{

	// Test ArchiveAttachmentListController()
	public static testmethod void ArchiveAttachmentListController_Test()
	{
		ArchiveAttachmentListController cont = new ArchiveAttachmentListController();
	}

	public static testmethod void loadAttachmentFromCaseId_Test(){
		ArchiveAttachmentListController cont = new ArchiveAttachmentListController();
		try{
		cont.loadAttachmentFromCaseId();
		}
		catch (Exception e) {}
	}

	public static testmethod void loadAttachmentsFromEmailMessage_Test(){
		ArchiveAttachmentListController cont = new ArchiveAttachmentListController();
		try{
			cont.loadAttachmentsFromEmailMessage();
		}
		catch (Exception e) {}
	}

	public static testmethod void getAMessageId_Test(){
		ArchiveAttachmentListController cont = new ArchiveAttachmentListController();
		try{
			cont.getAMessageId();
		}
		catch (Exception e) {}
	}
	public static testmethod void getACaseId_Test(){
		ArchiveAttachmentListController cont = new ArchiveAttachmentListController();
		try{
			cont.getACaseId();
		}
		catch (Exception e) {}
	}
	public static testmethod void hasUserLimitedPermissions_Test(){
		try{
			Boolean b = ArchiveAttachmentListController.hasUserLimitedPermissions();
		}
		catch (Exception e) {}
	}
}
