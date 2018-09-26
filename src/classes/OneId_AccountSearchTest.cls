@isTest
private class OneId_AccountSearchTest {

    @isTest
    public static void testSearchAccounts() {
        
        // Prepare test data
        String search = 'Air';
        String customerType = 'Agency';
        String fieldToQuery = 'Name';
        List<String> fieldsToQuery = new List<String>();
        fieldsToQuery.add(fieldToQuery);
        String fieldToSearch = 'Name';
        List<String> fieldsToSearch = new List<String>();
        fieldsToSearch.add(fieldToSearch);
        Map<String, String> filters = new Map<String, String>();
        filters.put('Sector__c', 'Travel Agent');
        
        // Start the test
        Test.startTest();
        
        // Call the search method
        OneId_AccountSearch.SearchWrapper searchWrapper = OneId_AccountSearch.searchAccounts(search, customerType, fieldsToQuery, fieldsToSearch, filters);
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(searchWrapper, null);
        
    }
    
}