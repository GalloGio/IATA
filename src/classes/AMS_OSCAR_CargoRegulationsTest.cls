@isTest class AMS_OSCAR_CargoRegulationsTest {
    
    @testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createCargoAgencyOSCARtestData();
    }

    @isTest static void testCargoAgencyRegulationsHOClassC() {

        AMS_OSCAR__c oscar = [SELECT Id, STEP6__c, Account__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
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
        	
        	List<AMS_Agency_Regulation__c> aregs = [SELECT Id, Notification_sent__c, Account__c FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
        	system.assertEquals(2, aregs.size());

        	//force DGR renewal oscar creation
        	aregs[0].Notification_sent__c = true;

        	update aregs[0];

            //account should have a certification oscar
            List<AMS_OSCAR__c> certOscars = [SELECT Id, Process__c FROM AMS_OSCAR__c WHERE Process__c = :AMS_Utils.CERTIFICATION AND Account__c = :aregs[0].Account__c];

            system.assertEquals(1, certOscars.size());

        }
        
        Test.stopTest();
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

        	List<AMS_Agency_Regulation__c> aregs = [SELECT Id FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
        	system.assertEquals(2, aregs.size());
        }
        
        Test.stopTest();
    }

    //test DGR for R specific country
    @isTest static void testCargoAgencyRegulationsHOClassR() {

        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP6__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

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

        	List<AMS_Agency_Regulation__c> aregs = [SELECT Id, Account__c FROM AMS_Agency_Regulation__c WHERE Account__c = :oscar.Account__c];
        	system.assertEquals(2, aregs.size());

            //force DGR renewal oscar creation
        	aregs[0].Notification_sent__c = true;

        	update aregs[0];

            //account should have a certification oscar
            List<AMS_OSCAR__c> certOscars = [SELECT Id FROM AMS_OSCAR__c WHERE Process__c = :AMS_Utils.CERTIFICATION AND Account__c = :aregs[0].Account__c];

            system.assertEquals(1, certOscars.size());
        }
        
        Test.stopTest();
    }



}