@isTest
private  class ISSP_UtilitiesTest {
	static testMethod void ISSP_UtilitiesTest() {
	    	//ISSP_ObjectFactory.fiilIncludedFields();
	    	//Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
	    	Account acc = ISSP_ObjectFactory.createNewAccount();
	        insert acc;
			//Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
			Contact con = ISSP_ObjectFactory.createNewContact();
			con.AccountId= acc.Id;
			insert con;
	    	Case testCase = ISSP_ObjectFactory.createNewCase();
	            //(Case)ISSP_ObjectFactory.createSObject('Case',false,3);
	         insert testCase;
	    	ISSP_Utilities.SendErrorNotificationEMail('test');
	    	ISSP_Utilities.getContactTypeById(con.Id);
	    	ISSP_Utilities.sendEmailToAdmins(Con.Id);
	    	ISSP_Utilities.DMLOpt(new set<string>{testCase.Id});
	    }
}