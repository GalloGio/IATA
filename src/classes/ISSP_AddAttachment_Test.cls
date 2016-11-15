@isTest
private class ISSP_AddAttachment_Test {
	
	@isTest static void test_method_one() {
 		Case newCase = new Case();
		insert newcase ;

		Apexpages.currentPage().getParameters().put('Caseid', newcase.Id);
		ISSP_AddAttachment controller = new ISSP_AddAttachment();
        controller.upload();
 	}

}