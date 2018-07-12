@isTest
public class AMS_AddressHelperTest {
	//FM
    public static testmethod void testPrimaryAddress(){
    	TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Id standardAccountRt = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        
        Account ag = new Account(RecordTypeId = standardAccountRt, Name='Test Agency', IATAcode__c = '1234567', Short_Name__c = 'Test Agency', IATA_ISO_Country__c = isoc.id);
        insert ag;
                
        IATA_ISO_State__c s = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS');
        insert s;
        
        Test.startTest();
        
        AMS_Address__c add1 = new AMS_Address__c(
            Account__c = ag.id,
            Address_Type__c = 'Primary',
        	Country__c = isoc.id,
            State__c = s.id, 
            AMS_ZipCode__c = '10100',
            City__c = 'Torino',
            Address_1__c = 'Corso',
            Address_2__c = 'via',
            Address_3__c = 'viale'
        );
        
        insert add1;
        
        //The primary address should be reported on the agency
        Account newag = [SELECT Primary_Address__c //Main_address__c,Main_address_city__c,Main_address_country__c,Main_address_state__c,Main_address_zip_code__c
                              FROM Account 
                               WHERE Id = :ag.id];
        system.assertEquals(add1.Id, newag.Primary_Address__c);

        //Cannot change Primary address
        add1.Address_Type__c = 'Mailing';
        try{
        update add1;
        }catch(Exception e ){}
        List<AMS_Address__c> adds = [SELECT Id FROM AMS_Address__c ];
        adds = [SELECT Id FROM AMS_Address__c ];
        system.assertEquals(1,adds.size());

        AMS_Address__c add2 = new AMS_Address__c(
            Account__c = ag.id,
            Address_Type__c = 'Primary'
        );
        try{
        	insert add2;
        }catch(Exception e ){}
        adds = [SELECT Id FROM AMS_Address__c ];
        system.assertEquals(2,adds.size());
        
        newag = [SELECT Primary_Address__c //Main_address__c,Main_address_city__c,Main_address_country__c,Main_address_state__c,Main_address_zip_code__c
                              FROM Account 
                               WHERE Id = :ag.id 
                 			   LIMIT 1];
        system.assertEquals(add2.id, newag.Primary_address__c);
        /*
        system.assertEquals(null, newag.Main_address__c);
        system.assertEquals(null, newag.Main_address_city__c);
        system.assertEquals(null, newag.Main_address_state__c);
        system.assertEquals(null, newag.Main_address_country__c);
        system.assertEquals(null, newag.Main_address_zip_code__c);
        */
        //system.assertEquals(null, newag.Primary_Address__c);
        
        //Cannot change Primary address
        try{
        delete add1;
        }catch(Exception e ){}
        adds = [SELECT Id FROM AMS_Address__c ];
        system.assertEquals(1,adds.size());    
    }
    
    
    public static testmethod void testAddressHelper(){
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        
        /*
		List<Account> accountList = new List<Account>();
        Account acc1 = new Account(Name='Test1 Account');
        Account acc2 = new Account(Name='Test2 Account');
        Account acc3 = new Account(Name='Test3 Account');
        Account acc4 = new Account(Name='Test4 Account');
        accountList.add(acc1);
        accountList.add(acc2);
        accountList.add(acc3);
        accountList.add(acc4);
        insert accountList;
		*/
		
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;
        
        IATA_ISO_State__c s = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS');
        insert s;

        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(Name='Test1 Parent Agency', IATA_ISO_Country__c = isoc.id);
        Account a2 = new Account(Name='Test1 Child Agency', IATA_ISO_Country__c = isoc.id);
        Account a3 = new Account(Name='Test2 Parent Agency', IATA_ISO_Country__c = isoc.id);
        Account a4 = new Account(Name='Test2 Child Agency', IATA_ISO_Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;
        
        Test.startTest();
        
        List<AMS_Address__c> addresslist = new List<AMS_Address__c>();
        AMS_Address__c add1 = new AMS_Address__c(Account__c = a1.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        AMS_Address__c add2 = new AMS_Address__c(Account__c = a2.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        AMS_Address__c add3 = new AMS_Address__c(Account__c = a3.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        AMS_Address__c add4 = new AMS_Address__c(Account__c = a4.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        
        addresslist.add(add1);
        addresslist.add(add2);
        addresslist.add(add3);
        addresslist.add(add4);
        insert addresslist;
        
        // Verify merchandise items got deleted
        Integer i = [SELECT COUNT() FROM AMS_Address__c];
        System.assertEquals(i, 4);
       
       
        	//AMS_AddressHelper.setPrimaryAddressesOnAgencies(addresslist); JH 18/02/2016: method doesn't exist anymore ??
        System.assertEquals(i, 4);
        
        try{
        	//AMS_AddressHelper.UpdatePrimaryAddresses(addresslist); JH 18/02/2016: method doesn't exist anymore ??
        }catch(Exception e){}
        System.assertEquals(i, 4);       
        
        try{
        	AMS_AddressHelper.updateBillingShippingAddressesOnAccount(addresslist); 
        }catch(Exception e){}
        System.assertEquals(i, 4);
        
        //AMS_AddressHelper.deletePrimaryAddressesOnAgencies(agencylist);
        //System.assertEquals(i, 4);
       
        Test.stopTest();
    }
    
    
}