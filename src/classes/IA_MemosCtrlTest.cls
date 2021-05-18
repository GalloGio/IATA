@isTest
public class IA_MemosCtrlTest {

	@TestSetup
	public static void setup(){
		insert new ISSP_CS__c(
			Name = 'Interline Memorandums Library Name',
			Value__c = 'Memo folder'
		);
		System.assertEquals('Memo folder', IA_util.LIBRARY_CS);

		User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(user) {
			ContentWorkspace workspace = new ContentWorkspace(
				Name = IA_util.LIBRARY_CS
			);
			insert workspace;

			ContentVersion content = new ContentVersion(
				Title = 'Interline Agreement memorandum',
				User_status_access__c = 'Approved User;Approved Admin',
				PathOnClient = 'test',
				versiondata = EncodingUtil.base64Decode('test')
			);
			insert content;
	
			content = [select id,contentDocumentId from contentversion where id=:content.id];
	
			ContentWorkspaceDoc cwd= new ContentWorkspaceDoc(
				ContentWorkspaceId=workspace.id,
				ContentDocumentId=content.contentDocumentId
			);
			insert cwd;
		}
	}

	static testMethod void testController(){
		Test.StartTest();
		IA_MemosController ctrl = new IA_MemosController();
		System.assert(ctrl.listDocuments!=null);
		System.assertEquals(1,ctrl.listDocuments.size());
		Test.stopTest();
	}

}
