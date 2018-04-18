@isTest class AMS_OSCAR_CargoRegulationsTest {
    
    @testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createCargoAgencyOSCARtestData();
    }

    @isTest static void testCargoAgencyRegulationsHOClassC() {

        AMS_OSCAR__c oscar = [SELECT Id, STEP6__c, Account__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        List<AMS_Agency_Regulation__c> aregs;
        
        Test.startTest();

        //Location class C without enough DGR
        try {
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('An HO Agency handling dangerous goods must have at least 2 DGR that are not expired.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);

            AMS_Accreditation_Contact__c dgaStaff = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Plitt'];

        	//update dga staff to dgr in order to comply with regulation
        	dgaStaff.Type_Of_Certificate__c = 'DGR';
        	update dgaStaff;

        	update oscar;
        	
        	aregs = [SELECT Id, Notification_sent__c, Account__c, Type_Of_Certificate__c FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
            system.assertEquals(3, aregs.size());

        	//force DGR renewal oscar creation
        	for(AMS_Agency_Regulation__c areg : aregs){
                if(areg.Type_Of_Certificate__c == AMS_Utils.CERT_CATA){
                    areg.Notification_sent__c = true;
                    update areg;
                }
            }

        }
        
        Test.stopTest();

        //account should have a certification oscar
        List<AMS_OSCAR__c> certOscars = [SELECT Id, Process__c FROM AMS_OSCAR__c WHERE Process__c = :AMS_Utils.CERTIFICATION AND Account__c = :aregs[0].Account__c];

        system.assertEquals(1, certOscars.size());
    }

    @isTest static void testCargoAgencyRegulationsBRClassC() {

        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP6__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        //force BR
        AMS_Pax_Accreditation_Form__c stagingBR = [SELECT Id, Location_Type__c FROM AMS_Pax_Accreditation_Form__c WHERE Account_Name__c='Test Cargo HO'];
        stagingBR.Location_Type__c = 'BR';

        update stagingBR;
        Test.startTest();

        AMS_Accreditation_Contact__c dgrStaff = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Bunny'];

       	//update dgr staff to dga in order to fail with regulation
        dgrStaff.Type_Of_Certificate__c = 'DGA';
        update dgrStaff;

        //Location class C without enough DGR
        try {
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('A BR Agency handling dangerous goods must have at least 1 DGR that is not expired.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        Test.stopTest();
    }

    @isTest static void testCargoAgencyRegulationsBRClassC_DGR() {

        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP6__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        //force BR
        AMS_Pax_Accreditation_Form__c stagingBR = [SELECT Id, Location_Type__c FROM AMS_Pax_Accreditation_Form__c WHERE Account_Name__c='Test Cargo HO'];
        stagingBR.Location_Type__c = 'BR';

        update stagingBR;
        Test.startTest();

        AMS_Accreditation_Contact__c dgrStaff = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Bunny'];

        //update dgr staff to dga in order to fail with regulation
        dgrStaff.Type_Of_Certificate__c = 'DGR';
        update dgrStaff;

        //Location class C without enough DGR
        try {
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(true, 'exception NOT expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('A BR Agency handling dangerous goods must have at least 1 DGR that is not expired.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }
        
        List<AMS_Agency_Regulation__c> aregs = [SELECT Id, Account__c, Type_Of_Certificate__c FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
        system.assertEquals(3, aregs.size());

        //force DGR renewal oscar creation
        aregs[0].Notification_sent__c = true;

        //force DGR renewal oscar creation
        for(AMS_Agency_Regulation__c areg : aregs){
            if(areg.Type_Of_Certificate__c == AMS_Utils.CERT_DGR){
                areg.Notification_sent__c = true;
                update areg;
            }
        }

        Test.stopTest();
    }

    //Non handling cargo, test DGAs
    @isTest static void testCargoAgencyRegulationsHOClassCNonHandling() {

        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP6__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        AMS_Pax_Accreditation_Form__c stagingHO = [SELECT Id, Location_Type__c, Is_your_firm_handling_Dangerous_Goods__c FROM AMS_Pax_Accreditation_Form__c WHERE Account_Name__c='Test Cargo HO'];
        stagingHO.Is_your_firm_handling_Dangerous_Goods__c = 'No';

        update stagingHO;
        Test.startTest();

        //Location class C without enough DGA
        try {
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('An HO Agency not handling dangerous goods must have at least 2 DGA that are not expired.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);

             AMS_Accreditation_Contact__c dgrStaff = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Bunny'];

       		//update dga staff to dgr in order to fail with regulation
        	dgrStaff.Type_Of_Certificate__c = 'DGA';
        	update dgrStaff;

        	update oscar;

        	List<AMS_Agency_Regulation__c> aregs = [SELECT Id, Type_Of_Certificate__c FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
            system.assertEquals(3, aregs.size());


            //force DGR renewal oscar creation
            for(AMS_Agency_Regulation__c areg : aregs){
                if(areg.Type_Of_Certificate__c == AMS_Utils.CERT_TSA){
                    areg.Notification_sent__c = true;
                    update areg;
                }
            }
        }
        
        Test.stopTest();
    }

    //test DGR for R specific country
    @isTest static void testCargoAgencyRegulationsHOClassR() {

	/*
        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP6__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        List<AMS_Agency_Regulation__c> aregs;

        IATA_ISO_Country__c argentina = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'AR'];

        AMS_Pax_Accreditation_Form__c stagingHO = [SELECT Id, Location_Type__c, Location_Class__c, Branch_Office_Country__c FROM AMS_Pax_Accreditation_Form__c WHERE Account_Name__c='Test Cargo HO'];
        stagingHO.Branch_Office_Country__c = argentina.Id;
        stagingHO.Location_Class__c = 'R';
        
        update stagingHO;

        Account acc = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'Test Cargo HO'];
        acc.IATA_ISO_Country__c = argentina.Id;
        update acc;

        AMS_Accreditation_Contact__c dgrStaff = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Bunny'];

       	//update dgr staff to dga in order to fail with regulation
        dgrStaff.Type_Of_Certificate__c = 'DGA';
        update dgrStaff;

        Test.startTest();

        try {
            oscar.STEP6__c = AMS_Utils.PASSED;
            update oscar;
            System.assert(false, 'exception expected');
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('This agency must have at least 1 DGR that are not expired.') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);

            AMS_Accreditation_Contact__c dgaStaff = [SELECT Id, Type_Of_Certificate__c FROM AMS_Accreditation_Contact__c WHERE Last_name__c = 'Bunny'];

       		//update dga staff to dgr in order to fail with regulation
        	dgaStaff.Type_Of_Certificate__c = 'DGR';
        	update dgaStaff;

        	update oscar;

        	aregs = [SELECT Id, Account__c, Type_Of_Certificate__c FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
        	system.assertEquals(4, aregs.size());

            //force DGR renewal oscar creation
        	aregs[0].Notification_sent__c = true;

            //force DGR renewal oscar creation
            for(AMS_Agency_Regulation__c areg : aregs){
                if(areg.Type_Of_Certificate__c == AMS_Utils.CERT_DGR){
                    areg.Notification_sent__c = true;
                    update areg;
                }
            }

            //force DGR renewal oscar creation
            aregs[0].Notification_Date__c = Date.today();

            //force DGR renewal oscar creation
            for(AMS_Agency_Regulation__c areg : aregs){
                if(areg.Type_Of_Certificate__c == AMS_Utils.CERT_DGR){
                    areg.Notification_Date__c = Date.today();
                    update areg;
                }
            }
        }
        
        Test.stopTest();
*/
        //account should have a certification oscar
        //List<AMS_OSCAR__c> certOscars = [SELECT Id FROM AMS_OSCAR__c WHERE Process__c = :AMS_Utils.CERTIFICATION AND Account__c = :aregs[0].Account__c];

        //system.assertEquals(1, certOscars.size());
    }

    @isTest
    public static void testRefreshCertificates() {
        Account testAccount = new Account(name='testAccount');
        insert testAccount;
        AMS_Agency_Regulation__c ar = new AMS_Agency_Regulation__c(Expiry_Date__c=System.today(), Type_Of_Certificate__c = 'DGR', Account__c = testAccount.Id, Last_name__c='test');
        insert ar;
        //        Id batchId = Database.executeBatch(new AMS_Refresh_AMS_AgencyRegulations(500));
        Test.startTest();
        AMS_Refresh_AMS_AgencyRegulations.stop();
        AMS_Refresh_AMS_AgencyRegulations.start('0 1 * * * ?',500);

        Test.stopTest();
        
    }
    
    @isTest
    public static void testRefreshCertificates2() {
        Account testAccount = new Account(name='testAccount');
        insert testAccount;
        AMS_Agency_Regulation__c ar = new AMS_Agency_Regulation__c(Expiry_Date__c=System.today(), Type_Of_Certificate__c = 'DGR', Account__c = testAccount.Id, Last_name__c='test');
        insert ar;
        //        Id batchId = Database.executeBatch(new AMS_Refresh_AMS_AgencyRegulations(500));
        Test.startTest();
        AMS_Refresh_AMS_AgencyRegulations.start('0 1 * * * ?',500);
        AMS_Refresh_AMS_AgencyRegulations.stop();
        
        Test.stopTest();
        
    }

}