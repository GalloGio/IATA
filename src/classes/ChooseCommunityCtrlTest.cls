@istest
private  class ChooseCommunityCtrlTest {
	
	 static testMethod void myUnitTest() {


		PageReference pageRef = Page.ChooseCommunity;
        Test.setCurrentPage(pageRef);

        Contact c = new Contact(firstName = 'Pippo', lastName = 'PLuto', email ='paperino@grmail.com');
        insert c;

		ApexPages.StandardController controller =  new ApexPages.StandardController(c);
		ChooseCommunityCtrl ctrl = new ChooseCommunityCtrl(controller);

		
		for(ApexPages.Message msg :  ApexPages.getMessages()) {
   	 		System.assertEquals('NO ELIGIBLE USER FOUND FOR THIS CONTACT', msg.getSummary());
    		System.assertEquals(ApexPages.Severity.ERROR, msg.getSeverity());
		}

		List<SelectOption>  res = ctrl.getAvalaibleComms();
		system.assertEquals(res.size(), 4);
		ctrl.community = Comm_User_Helper.IEC;
		PageReference returnPage = ctrl.SendEmail();
		system.assertEquals(string.valueOF(controller.view()),string.valueof(returnPage));

	}



}