@isTest
private class ISSP_AddComment_Test {
	
	@isTest static void test_method_one() {
		Case newCase = new Case();
		newCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope'); //ACAMBAS - WMO-395
		insert newcase;

		//ACAMBAS - WMO-395: Begin
		Case_RTs_for_Auto_Reply_Email__c cs = new Case_RTs_for_Auto_Reply_Email__c();
		cs.Name = 'CasesEurope';
		cs.Record_Type_Name__c = 'Cases - Europe';
		insert cs;
		//ACAMBAS - WMO-395: End

		Apexpages.currentPage().getParameters().put('Caseid', newcase.Id);
		ISSP_AddComment controller = new ISSP_AddComment();
        controller.upload();

        controller.getAdditionalCC(); //ACAMBAS - WMO-395
	}
}