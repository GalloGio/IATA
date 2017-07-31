@isTest
private class ISSP_ObjectFactoryTest {

    static testMethod void testAll() {
        
        Account a = ISSP_ObjectFactory.createNewAccount();
        Contact b = ISSP_ObjectFactory.createNewContact();
        Case c = ISSP_ObjectFactory.createNewCase();
        
        ISSP_ObjectFactory.fiilIncludedFields();
        ISSP_ObjectFactory.FillAllFields = true;
        list<Account> accList = (list<Account>)ISSP_ObjectFactory.createSObjectList('Account',false,1);
		Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc1 =  (Account)ISSP_ObjectFactory.createSObject('Account');
        Account acc2 =  (Account)ISSP_ObjectFactory.createSObject('Account', false);
    }
} 