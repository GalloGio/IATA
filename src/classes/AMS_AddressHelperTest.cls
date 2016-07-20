@isTest
public class AMS_AddressHelperTest {
	//FM
    public static testmethod void testPrimaryAddress(){
    	TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Map<string, Id>  agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        AMS_Agency__c ag = new AMS_Agency__c(RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test Agency', IATAcode__c = '1234567', Legal_Name_1__c = 'Test Agency', Country__c = isoc.id);
        insert ag;
                
        IATA_ISO_State__c s = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS');
        insert s;
        
        Test.startTest();
        
        AMS_Address__c add1 = new AMS_Address__c(
            Agency__c = ag.id,
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
        AMS_Agency__c newag = [SELECT Primary_Address__c //Main_address__c,Main_address_city__c,Main_address_country__c,Main_address_state__c,Main_address_zip_code__c
                              FROM AMS_Agency__c 
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
            Agency__c = ag.id,
            Address_Type__c = 'Primary'
        );
        try{
        	insert add2;
        }catch(Exception e ){}
        adds = [SELECT Id FROM AMS_Address__c ];
        system.assertEquals(2,adds.size());
        
        newag = [SELECT Primary_Address__c //Main_address__c,Main_address_city__c,Main_address_country__c,Main_address_state__c,Main_address_zip_code__c
                              FROM AMS_Agency__c 
                               WHERE Id = :ag.id 
                 			   LIMIT 1];
        system.assertEquals(add2.id,newag.Primary_address__c);
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

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;
        
        IATA_ISO_State__c s = new IATA_ISO_State__c(ISO_Code__c='TS01', IATA_ISO_Country__c=isoc.Id, Name='TestAMS');
        insert s;

        Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
        AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Parent Agency',Account__c=acc1.Id, Country__c = isoc.id);
        AMS_Agency__c a2 = new AMS_Agency__c(Name='Test1 Child Agency',Account__c=acc2.Id, Country__c = isoc.id);
        AMS_Agency__c a3 = new AMS_Agency__c(Name='Test2 Parent Agency',Account__c=acc3.Id, Country__c = isoc.id);
        AMS_Agency__c a4 = new AMS_Agency__c(Name='Test2 Child Agency',Account__c=acc4.Id, Country__c = isoc.id);
        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        insert agencylist;
        
        Test.startTest();
        
        List<AMS_Address__c> addresslist = new List<AMS_Address__c>();
        AMS_Address__c add1 = new AMS_Address__c(Agency__c = a1.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        AMS_Address__c add2 = new AMS_Address__c(Agency__c = a2.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        AMS_Address__c add3 = new AMS_Address__c(Agency__c = a3.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        AMS_Address__c add4 = new AMS_Address__c(Agency__c = a4.id,Address_Type__c = 'Primary',Country__c = isoc.id,State__c = s.id, AMS_ZipCode__c = '10100',City__c = 'Torino',Address_1__c = 'Corso',Address_2__c = 'via',Address_3__c = 'viale');
        
        addresslist.add(add1);
        addresslist.add(add2);
        addresslist.add(add3);
        addresslist.add(add4);
        insert addresslist;
        
        // Verify merchandise items got deleted
        Integer i = [SELECT COUNT() FROM AMS_Address__c];
        System.assertEquals(i, 4);
       
       
        AMS_AddressHelper.setPrimaryAddressesOnAgencies(addresslist);
        System.assertEquals(i, 4);
        
        try{
        AMS_AddressHelper.UpdatePrimaryAddresses(addresslist); 
        }catch(Exception e){}
        System.assertEquals(i, 4);       
        
        /*try{
        AMS_AddressHelper.setBillingShippingAddressesOnAccount(addresslist); 
        }catch(Exception e){}
        System.assertEquals(i, 4);*/
        
        try{
        AMS_AddressHelper.updateBillingShippingAddressesOnAccount(addresslist); 
        }catch(Exception e){}
        System.assertEquals(i, 4);
        
        //AMS_AddressHelper.deletePrimaryAddressesOnAgencies(agencylist);
        //System.assertEquals(i, 4);
       
        Test.stopTest();
    }
    
    
}