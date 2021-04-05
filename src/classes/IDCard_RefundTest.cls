@isTest
public class IDCard_RefundTest {
	@IsTest
	static void IDCard_RefundTestPage(){
		case c = new case();
		insert c;
		PageReference pageRef = Page.IDCard_Refund;
		Test.setCurrentPageReference(pageRef);

		Test.startTest();
		IDCard_Refund ctrl = new IDCard_Refund(new Apexpages.Standardcontroller(c));
		ctrl.save();
		Test.stopTest();
		
	}
}
