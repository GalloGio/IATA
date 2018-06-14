@isTest
private class ANG_ContactHandlerTest {
	
	//insert 2 accounts and 1 contact
	//change account on contact and update. should not be possible to do

	@isTest static void checkAccountHierarchyTest() {
		AMS_HierarchyHelperTest.initHierarchy(1,0);
		Account a1 = AMS_HierarchyHelperTest.HO; // new Account(Name = 'A1',Sector__c = 'Accommodation',Category__c = 'Hotel');
		//accs.add(a1);
		Account a2 = new Account(Name = 'A2',Sector__c = 'Accommodation',Category__c = 'Hotel');
		insert a2;

		Contact c = new Contact(accountId = a1.id, FirstName = 'Test' , LastName = 'test 1');
		insert c;

		Portal_Applications__c ps = new Portal_Applications__c ( ANG_Cannot_move_contact_between_Agencies__c = true);
		insert ps;
		Portal_Application_Right__c pa = new Portal_Application_Right__c(Contact__c = c.id,Portal_Application__c = ps.id,Right__c = 'Access Requested');
		insert pa;

		c.accountId = a2.id;

		try{
			update c;
		}catch(Exception e){

		}

		

	}
	

}