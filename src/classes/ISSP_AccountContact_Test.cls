@isTest
private class ISSP_AccountContact_Test {

	static testMethod void accountTest_1() {
		
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Sector__c = 'Cargo Agent';
		insert acc;
		
		Apexpages.currentPage().getParameters().put('id', acc.Id);
		
		ISSP_Account ctrl = new ISSP_Account();
	}
	
	static testMethod void accountTest_2() {
		
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Sector__c = 'Airline';
		insert acc;
		
		Apexpages.currentPage().getParameters().put('id', acc.Id);
		
		ISSP_Account ctrl = new ISSP_Account();
	}
	
	static testMethod void contactTest_1() {
		
		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Category__c = 'IATA Passenger Sales Agent';
		insert acc;
		
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		insert con;
		
		Apexpages.currentPage().getParameters().put('id', con.Id);
		Apexpages.currentPage().getParameters().put('action', 'Edit');
		
		ISSP_Contact ctrl = new ISSP_Contact();
		
		ctrl.edit();
		ctrl.save();
		ctrl.cancel();
		
		Apexpages.currentPage().getParameters().put('retURL', '/ISSP_Homepage');
		ctrl.cancel();
		
		ctrl.AssignIFAPContact();
		
		ctrl.ChangePortalStatus();
		ctrl.RelocateContact();
	}
}