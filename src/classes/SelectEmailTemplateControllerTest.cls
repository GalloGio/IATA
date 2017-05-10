@isTest
public class SelectEmailTemplateControllerTest {

	static testMethod void testController_OK() {

		Test.startTest();
		SelectEmailTemplateController controller = new SelectEmailTemplateController();
		System.debug(controller.selectedFolderId);
		System.assert(controller.selectedFolderId!=null);

		list<SelectOption> listFolders = controller.getListFolder();
		System.assert(listFolders!=null);
		System.assert(listFolders.size()>0);

		String url = controller.getCurrentURL();
		System.assert(url == '/apex/sendsingletrackedemail');
		Test.stopTest();
	}

}