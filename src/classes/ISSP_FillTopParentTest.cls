@isTest
public class ISSP_FillTopParentTest {
/// 82 %
    public static testMethod void testISSP_FillTopParentTest() {
        
        list<Account> accountsToChange;
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        accountsToChange = ISSP_FillTopParent.getAccountsToInsert(new list<Account>{(Account)parent});
        ISSP_FillTopParent.accountsBeforeInsertTopParent(accountsToChange); 
        insert parent;
       
        Account parent2 = ISSP_ObjectFactory.createNewAccount();
        parent2.BillingCity = 'test4';
        parent2.Name = 'test4';
        accountsToChange = ISSP_FillTopParent.getAccountsToInsert(new list<Account>{(Account)parent2});
        ISSP_FillTopParent.accountsBeforeInsertTopParent(accountsToChange); 
        insert parent2;
        
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.BillingCity = 'test2';
        child.Name = 'test2';
        accountsToChange = ISSP_FillTopParent.getAccountsToInsert(new list<Account>{(Account)child});
        ISSP_FillTopParent.accountsBeforeInsertTopParent(accountsToChange); 
        insert child;
        
        Account grandson = ISSP_ObjectFactory.createNewAccount();
        grandson.ParentId = child.Id;
        grandson.BillingCity = 'test3';
        grandson.Name = 'test3';
        accountsToChange = ISSP_FillTopParent.getAccountsToInsert(new list<Account>{(Account)grandson});
        ISSP_FillTopParent.accountsBeforeInsertTopParent(accountsToChange); 
        insert grandson;
            
        child.ParentId = parent2.Id;
        update child;
       
        ISSP_FillTopParent.accountsAfterDeleteTopParent(new map<Id,Account>(new list<Account>{(Account)child}));
        delete child;
    }
    
    public static testMethod void testISSP_FillTopParentTestBatch() {
        //Account parent5 =  (Account)ISSP_ObjectFactory.createSObject('Account',false,5);
        Account parent5 = ISSP_ObjectFactory.createNewAccount();
        parent5.BillingCity = 'test4';
        parent5.Name = 'test';
        insert parent5;
        ISSP_FindTopParentBatch bc = new ISSP_FindTopParentBatch();
        bc.query = 'Select Id From Account Limit 200';
        
        Test.startTest();
        Database.executeBatch(bc, 200);
        Test.stopTest(); 
     }
}
