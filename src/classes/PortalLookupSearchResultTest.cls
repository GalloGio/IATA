@isTest
public class PortalLookupSearchResultTest {
    
    static testMethod void search_should_return_Account() {
        String accountIcon = 'standard:account';
        Account account = createTestAccount('Account');
        
        PortalLookupSearchResult test = new PortalLookupSearchResult(account.Id, 'Account', accountIcon, account.IATAcode__c + '', 'Account • '+ 'Lisbon');
        
        ID testId = test.getId();
        String testSObjectType = test.getSObjectType();
        String testIcon = test.getIcon();
        String testTitle = test.getTitle();
        String testSubtitle = test.getSubtitle();
        
    }
    
    private static Account createTestAccount(String name) {
        Account account = new Account(Name = name);
        account.IATAcode__c = '1234567';
        insert account;
        return account;
    }
}