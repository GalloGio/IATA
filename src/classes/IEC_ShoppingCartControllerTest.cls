@isTest
private class IEC_ShoppingCartControllerTest
{
	static void testSetupNewShoppingCart() {
		List<IEC_Functionality__c> l = IEC_Functionality__c.getAll().values();

		if (l.isEmpty() == false) {
			delete l;
		}

		IEC_Functionality__c f = new IEC_Functionality__c(
			Order__c = 0,
			Name='Test New Shopping Cart',
			Functionality_Name__c = 'New Shopping Cart',
			Is_Active__c = true,
			Audience__c = 'all=true'
		);

		insert f;
	}


}