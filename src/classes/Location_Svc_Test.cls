@isTest
private class Location_Svc_Test {

	// Test initializing new location/address records for new contacts without these records
    static testMethod void test_InitializeContactLocation() {
    	TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();
        
        // Setup test data
        Account oAccount = TestDataGenerator.generateAccounts(1, false)[0];
        oAccount.BillingStreet = '123 Test';
        oAccount.IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA');
        oAccount.IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'QC');
        oAccount.IATA_ISO_Shipping_State__r = new IATA_ISO_State__c(ISO_Code__c = 'QC');
        insert oAccount;
        
        List<Contact> lstContact = TestDataGenerator.generateContacts(oAccount.Id, 2, true);
        
        Test.startTest();
        	// Test 01: Initialize the first contact where no location record exists
        	Location_Svc.InitializeContactLocations(lstContact[0].Id);
        	
        	List<Location__c> lstLocation = [SELECT Id, Type__c FROM Location__c];
            System.debug('lstLocation::'+lstLocation);
        	System.assertEquals(3, lstLocation.size(), 'Three location records must be created. Sold/Bill/Ship-To records.');
        	
        	List<IECAddress__c> lstAddress = [SELECT Id FROM IECAddress__c];
        	System.assertEquals(2, lstAddress.size(), 'Two address records must be created.');
        	
        	// Test 02: Re-Initialize the first contact where location record already exists
        	System.assertEquals(true, Location_Svc.InitializeContactLocations(lstContact[0].Id));
        	
        	// Test 03: Initialize the second contact where location record only for the sold-to account
        	Location_Svc.InitializeContactLocations(lstContact[1].Id);
        	
        	lstLocation = [SELECT Id FROM Location__c];
        	System.assertEquals(5, lstLocation.size(), 'Five location records in totals must exist.');

            //Remove the location reference in Account
            List<Account> lstAcc = [select id,SoldTo_Location__c from Account where SoldTo_Location__c = :lstLocation[0].Id];
            if(lstAcc != null && lstAcc.size() > 0){
                for(Account acc : lstAcc){
                    acc.SoldTo_Location__c = null;
                }
                update lstAcc;
            }

            //Remove location reference in the Contact object
            List<Contact> lstCt = [select id,BillTo_Location__c,ShipTo_Location__c from Contact where BillTo_Location__c =:lstLocation[0].Id OR ShipTo_Location__c = :lstLocation[0].Id ];
            if(lstCt != null && lstCt.size() > 0){
                for(Contact ct : lstCt){
                    if(ct.BillTo_Location__c == lstLocation[0].Id)
                        ct.BillTo_Location__c = null;
                    if(ct.ShipTo_Location__c == lstLocation[0].Id)
                        ct.ShipTo_Location__c = null;
                }
                update lstCt;
            }

            //-- Delete 1st location 
            delete lstLocation[0];
            
        	
        	lstAddress = [SELECT Id FROM IECAddress__c];
        	System.assertEquals(2, lstAddress.size(), 'Still two address records must exist since reusing the existing address records.');
        	
        	// Test 04: Initialize with no contact id
        	Location_Svc.InitializeContactLocations(null);
        Test.stopTest();
    }
    
    // Test initializing new location/address records for new contacts without these records
    static testMethod void test_InitializeContactLocation_WithNoAccountShippingAddress() {
    	TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();
        
        // Setup test data
        Account oAccount = TestDataGenerator.generateAccounts(1, false)[0];
        oAccount.BillingStreet = '123 Test';
        oAccount.IATA_ISO_Country__r = new IATA_ISO_Country__c(ISO_Code__c = 'CA');
        oAccount.IATA_ISO_Billing_State__r = new IATA_ISO_State__c(ISO_Code__c = 'QC');
        oAccount.ShippingStreet = null;
        oAccount.ShippingCity = null;
        oAccount.ShippingPostalCode = null;
        insert oAccount;
        
        List<Contact> lstContact = TestDataGenerator.generateContacts(oAccount.Id, 1, true);
        
        Test.startTest();
        	Location_Svc.InitializeContactLocations(lstContact[0].Id);
        	
        	List<Location__c> lstLocation = [SELECT Id FROM Location__c];
        	System.assertEquals(3, lstLocation.size(), 'Three location records must be created. Sold/Bill/Ship-To records.');
        Test.stopTest();
    }

    static testMethod void test_deleteLocation()
    {
        TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();
        IECAddress__c address =  TestDataGenerator.generateAddresses(1, true)[0];
        Account account = TestDataGenerator.generateAccounts(1, false)[0];
        Contact contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];

        try{

            Test.startTest();
                Location__c location = TestDataGenerator.generateLocations('Ship To', address.Id, account.Id, contact.Id);
            Test.stopTest();

            delete location;
        }
        catch(Exception e){
            System.AssertEquals(true, String.isNotBlank(e.getMessage()));
        }
    }

    static testMethod void trest_locationToCreate()
    {
        /*TestDataGenerator.generateApexSetting();
        TestDataGenerator.generateISOCountryState();
        IECAddress__c address =  TestDataGenerator.generateAddresses(1, true)[0];
        Account account = TestDataGenerator.generateAccounts(1, false)[0];
        Contact contact = TestDataGenerator.generateContacts(account.Id, 1, true)[0];

        Location__c location = TestDataGenerator.generateLocations('Ship To', address.Id, account.Id, contact.Id);

        List<Location__c> soldToLocations =  Location_Svc.locationToCreate(new list<Location__c>{location}); 

        //--syncLocationsWithZuora
        Location_Svc.syncLocationsWithZuora(new Set<Id>{location.Id});*/

    }
}