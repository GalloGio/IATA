@isTest
private class OneId_AddressDoctorTest {

    @isTest
    public static void testAddressDoctor() {
        
        // Prepare test data
        String userInput = 'Avenue avant-poste 5; 1005; Lausanne';
        String countryCode = 'CH';
        
        // Start the test
        Test.startTest();
        
        // Set mock callout class 
        Test.setMock(HttpCalloutMock.class, new OneId_AddressDoctorMockImpl());
        List<OneId_AddressDoctor.AddressInfo> ADaddresses = OneId_AddressDoctor.quickSearch(userInput, countryCode);
        ADaddresses[0].countryCode = countryCode;
        OneId_AddressDoctor.validate(ADaddresses[0]);
        
        // Stop the test
        Test.stopTest();
        
        // Check that we have data
        System.assertNotEquals(ADaddresses, null);
        
    }

}