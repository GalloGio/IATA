@isTest
private class ISSP_AddComment_Test {
	
	@isTest static void test_method_one() {
		Case newCase = new Case();
		insert newcase ;

		Apexpages.currentPage().getParameters().put('Caseid', newcase.Id);
		ISSP_AddComment controller = new ISSP_AddComment();
        controller.upload();
	}
}