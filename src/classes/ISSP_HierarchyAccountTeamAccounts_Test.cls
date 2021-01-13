@isTest
private class ISSP_HierarchyAccountTeamAccounts_Test {

		public static testMethod void testISSP_HomepageTest() {
			//ISSP_ObjectFactory.fiilIncludedFields();
			//Account parent =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
			Account parent = ISSP_ObjectFactory.createNewAccount();
			parent.BillingCity = 'test';
			parent.Name = 'test';
			insert parent;

			//Account child =  (Account)ISSP_ObjectFactory.createSObject('Account',false,2);
			Account child = ISSP_ObjectFactory.createNewAccount();
			child.ParentId = parent.Id;
			child.BillingCity = 'test2';
			child.Name = 'test2';
			insert child;
			//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
			Contact con = ISSP_ObjectFactory.createNewContact();
			con.AccountId= child.Id;
			insert con;
			User newUser = ISSP_ObjectFactory.createPortalUser(con);

			ISSP_HierarchyAccountTeamAccounts.HierarchyAccountTeamMemberAccounts(new set<ID>{newUser.Id});
		}
}
