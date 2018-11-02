@isTest
private class AMS_InspectionHelperTest {

    @isTest static void test_setStatusCodeOnAccountForDOM(){
        Id StandardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234568',Name='Test2 Agency',Short_Name__c='Test2 Agency');
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234569',Name='Test3 Agency',Short_Name__c='Test3 Agency');
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234560',Name='Test4 Agency',Short_Name__c='Test4 Agency');
        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234561',Name='Test5 Agency',Short_Name__c='Test5 Agency');


        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        agencylist.add(a5);

        insert agencylist;

        AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'DOM');
        insert ao;

        Test.startTest();
        List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c ins1 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
        AMS_Inspection__c ins2 = new AMS_Inspection__c(Account__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '1');
        AMS_Inspection__c ins3 = new AMS_Inspection__c(Account__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '2');
        AMS_Inspection__c ins4 = new AMS_Inspection__c(Account__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '3');
        AMS_Inspection__c ins5 = new AMS_Inspection__c(Account__c=a5.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '8');


        agencyInspectionList.add(ins1);
        agencyInspectionList.add(ins2);
        agencyInspectionList.add(ins3);
        agencyInspectionList.add(ins4);
        agencyInspectionList.add(ins5);
        insert agencyInspectionList;

        List<AMS_Inspection__c> inspections = [select Accreditation_Endorsement_Status_code__c, Account__r.Status__c from AMS_Inspection__c insp where insp.Account__r.Main_Accreditation_Organization__c = 'DOM'];
        for(AMS_Inspection__c i:inspections)
        {
            if(i.Accreditation_Endorsement_Status_code__c == '0')
                System.assertEquals('Terminated', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '1')
                System.assertEquals('Not accreditated', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '2')
                System.assertEquals('New application pending', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '3')
                System.assertEquals('Not in operation', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '4')
                System.assertEquals('Not accreditated', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '5')
                System.assertEquals('Cash basis/no commission', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '6')
                System.assertEquals('Cash basis/with commission', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '7')
                System.assertEquals('Under review', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '8')
                System.assertEquals('Changes processed', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '9')
                System.assertEquals('Approved', i.Account__r.Status__c);
        }

        ins1.Accreditation_Endorsement_Status_code__c='0';
        ins2.Accreditation_Endorsement_Status_code__c='4';
        ins3.Accreditation_Endorsement_Status_code__c='5';
        ins4.Accreditation_Endorsement_Status_code__c='6';
        ins5.Accreditation_Endorsement_Status_code__c='9';


        List<SObject> updateAll = new List<SObject>();
        updateAll.add(ins1);
        updateAll.add(ins2);
        updateAll.add(ins3);
        updateAll.add(ins4);
        updateAll.add(ins5);

        update updateAll;

        inspections = [select Accreditation_Endorsement_Status_code__c, Account__r.Status__c from AMS_Inspection__c insp where insp.Account__r.Main_Accreditation_Organization__c = 'DOM'];
        for(AMS_Inspection__c i:inspections)
        {

            if(i.Accreditation_Endorsement_Status_code__c == '0')
                System.assertEquals('Terminated', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '4')
                System.assertEquals('Listed', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '5')
                System.assertEquals('Cash basis/no commission', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '6')
                System.assertEquals('Cash basis/with commission', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '7')
                System.assertEquals('Under review', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '8')
                System.assertEquals('Changes processed', i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '9')
                System.assertEquals('Approved', i.Account__r.Status__c);
        }
    }

    @isTest static void test_setStatusCodeOnAccount() {
        Id StandardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt, IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234568',Name='Test2 Agency',Short_Name__c='Test2 Agency');
        Account a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234569',Name='Test3 Agency',Short_Name__c='Test3 Agency');
        Account a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234560',Name='Test4 Agency',Short_Name__c='Test4 Agency');
        Account a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234561',Name='Test5 Agency',Short_Name__c='Test5 Agency');


        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        agencylist.add(a5);

        insert agencylist;

        AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATA');
        insert ao;

        Test.startTest();
        List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c ins1 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
        AMS_Inspection__c ins2 = new AMS_Inspection__c(Account__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '4');
        AMS_Inspection__c ins3 = new AMS_Inspection__c(Account__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '5');
        AMS_Inspection__c ins4 = new AMS_Inspection__c(Account__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '6');
        AMS_Inspection__c ins5 = new AMS_Inspection__c(Account__c=a5.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '7');


        agencyInspectionList.add(ins1);
        agencyInspectionList.add(ins2);
        agencyInspectionList.add(ins3);
        agencyInspectionList.add(ins4);
        agencyInspectionList.add(ins5);

        insert agencyInspectionList;

        List<AMS_Inspection__c> inspections = [select Accreditation_Endorsement_Status_code__c, Account__r.Status__c from AMS_Inspection__c insp where insp.Account__r.Main_Accreditation_Organization__c = 'IATA'];
        for(AMS_Inspection__c i:inspections)
        {
            // IATA appointment is not synchronized with the account!
            System.assertEquals(null, i.Account__r.Status__c);
        }

        ins1.Accreditation_Endorsement_Status_code__c='0';
        ins2.Accreditation_Endorsement_Status_code__c='4';
        ins3.Accreditation_Endorsement_Status_code__c='5';
        ins4.Accreditation_Endorsement_Status_code__c='6';
        ins5.Accreditation_Endorsement_Status_code__c='7';


        List<SObject> updateAll = new List<SObject>();
        updateAll.add(ins1);
        updateAll.add(ins2);
        updateAll.add(ins3);
        updateAll.add(ins4);
        updateAll.add(ins5);

        update updateAll;

        inspections = [select Accreditation_Endorsement_Status_code__c, Account__r.Status__c from AMS_Inspection__c insp where insp.Account__r.Main_Accreditation_Organization__c = 'IATA'];
        for(AMS_Inspection__c i:inspections)
        {
            // IATA appointment is not synchronized with the account!
            System.assertEquals(null, i.Account__r.Status__c);
        }

        agencylist = new List<Account>();
        a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt, IATACode__c='2234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
        a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='2234568',Name='Test2 Agency',Short_Name__c='Test2 Agency');
        a3 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='2234569',Name='Test3 Agency',Short_Name__c='Test3 Agency');
        a4 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='2234560',Name='Test4 Agency',Short_Name__c='Test4 Agency');
        a5 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='2234561',Name='Test5 Agency',Short_Name__c='Test5 Agency');

        agencylist.add(a1);
        agencylist.add(a2);
        agencylist.add(a3);
        agencylist.add(a4);
        agencylist.add(a5);

        insert agencylist;

        ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'IATAN');
        insert ao;

        agencyInspectionList = new List<AMS_Inspection__c>();

        ins1 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '0');
        ins2 = new AMS_Inspection__c(Account__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '4');
        ins3 = new AMS_Inspection__c(Account__c=a3.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '5');
        ins4 = new AMS_Inspection__c(Account__c=a4.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '6');
        ins5 = new AMS_Inspection__c(Account__c=a5.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '7');

        agencyInspectionList.add(ins1);
        agencyInspectionList.add(ins2);
        agencyInspectionList.add(ins3);
        agencyInspectionList.add(ins4);
        agencyInspectionList.add(ins5);

        insert agencyInspectionList;

        inspections = [select Accreditation_Endorsement_Status_code__c, Account__r.Status__c from AMS_Inspection__c insp where insp.Account__c IN :agencyList];
        for(AMS_Inspection__c i:inspections)
        {
            if(i.Accreditation_Endorsement_Status_code__c == '0')
                System.assertEquals(AMS_Utils.getIATANReadableStatus('0'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '4')
                System.assertEquals(AMS_Utils.getIATANReadableStatus('4'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '5')
                System.assertEquals(AMS_Utils.getIATANReadableStatus('5'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '6')
                System.assertEquals(AMS_Utils.getIATANReadableStatus('6'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '7')
                System.assertEquals(AMS_Utils.getIATANReadableStatus('7'), i.Account__r.Status__c);
        }

        ins1.Accreditation_Endorsement_Status_code__c='9';
        ins2.Accreditation_Endorsement_Status_code__c='8';
        ins3.Accreditation_Endorsement_Status_code__c='5';
        ins4.Accreditation_Endorsement_Status_code__c='6';
        ins5.Accreditation_Endorsement_Status_code__c='7';

        updateAll = new List<SObject>();

        updateAll.add(ins1);
        updateAll.add(ins2);
        updateAll.add(ins3);
        updateAll.add(ins4);
        updateAll.add(ins5);
        update updateAll;

        inspections = [select Accreditation_Endorsement_Status_code__c, Account__r.Status__c from AMS_Inspection__c insp where  insp.Account__c IN :agencyList];
        for(AMS_Inspection__c i:inspections)
        {
            if(i.Accreditation_Endorsement_Status_code__c == '0')
               System.assertEquals(AMS_Utils.getIATANReadableStatus('0'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '4')
               System.assertEquals(AMS_Utils.getIATANReadableStatus('4'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '5')
               System.assertEquals(AMS_Utils.getIATANReadableStatus('5'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '6')
               System.assertEquals(AMS_Utils.getIATANReadableStatus('6'), i.Account__r.Status__c);
            if(i.Accreditation_Endorsement_Status_code__c == '7')
               System.assertEquals(AMS_Utils.getIATANReadableStatus('7'), i.Account__r.Status__c);
        }

        Boolean isFalse = AMS_InspectionHelper.compareAmsInspectionRecords_IgnoringLastSyncDate(ins1,ins1);

        System.assertEquals(isFalse,false);

        Boolean isTrue = AMS_InspectionHelper.compareAmsInspectionRecords_IgnoringLastSyncDate(ins1,ins2);

        System.assertEquals(isTrue,true);

        Test.stopTest();
    }


    @isTest static void test_SetStatusCodeToZeroUpdatesRecertExpiryDate(){
        Id StandardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency');
        agencylist.add(a1);
        insert agencylist;

        AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'DOM');
        insert ao;

        Test.startTest();
        List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c ins1 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '7', Date_Organisation_Status_attained__c=System.today());
        agencyInspectionList.add(ins1);
        insert agencyInspectionList;

        a1 = [select Expiry_Date__c from Account where id = :a1.Id];
        System.assertEquals(null, a1.Expiry_Date__c);

        ins1.Accreditation_Endorsement_Status_code__c='0';
        List<SObject> updateAll = new List<SObject>();
        updateAll.add(ins1);
        update updateAll;

        //a1 = [select Expiry_Date__c from Account where id = :a1.Id];
        //System.assertEquals(System.today(), a1.Expiry_Date__c);
    }

    @isTest static void test_1To1RelationshipAppointmentMSO(){
        Id StandardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        Id airlineRT = AMS_Utils.getId('Account', 'IATA_Airline');
        Account airline = new Account();
        airline.Name = 'TestAirline';
        airline.Sector__c = 'Airline';
        airline.IATA_ISO_Country__c = ctry.id;
        airline.RecordTypeId = airlineRT;
        insert airline;

        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c='1234567',Name='Test1 Agency',Short_Name__c='Test1 Agency', Category__c = 'MSO Member Sales Office');
        agencylist.add(a1);
        insert agencylist;


        Test.startTest();
        List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c ins1 = new AMS_Inspection__c(Account__c=a1.id,Airline__c=airline.id);
        insert ins1;

        AMS_Inspection__c ins2 = new AMS_Inspection__c(Account__c=a1.id,Airline__c=airline.id);

        try {
            insert ins2;
        } catch (Exception e) {
            Boolean expectedExceptionThrown =  e.getMessage().contains('An MSO Agency can only have 1 Appointment') ? true : false;
            System.assertEquals(expectedExceptionThrown, true);
        }


    }


    @isTest static void test_checkActiveAppointments(){
        Id StandardAccountRt = AMS_Utils.getId('Account', 'Standard_Account');
        TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US')  ;
        insert ctry ;

        List<Account> agencylist = new List<Account>();
        Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c = '1234567',Name = 'Test1 Agency',Short_Name__c = 'Test1 Agency', Location_Class__c = 'G');
        agencylist.add(a1);
        //AMSU-161
        Account a2 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = StandardAccountRt,IATACode__c = '1234568',Name = 'Test2 Agency',Short_Name__c = 'Test2 Agency', Location_Class__c = 'G');
        agencylist.add(a2);
        insert agencylist;

        //AMSU-161 start - Create the AMS hierarchies for the first group of agencies
        AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
        List<AMS_Agencies_Hierarchy__c> hs = new List<AMS_Agencies_Hierarchy__c>{H1};
        insert hs;
        
        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = a1.Id, Child_Account__c = a2.Id, HO_Flag__c = 'true'));
        insert rels;
        //AMSU-161 end

        AMS_Accreditation_Organization__c ao = new AMS_Accreditation_Organization__c(Air_Code__c = 'DOM');
        insert ao;

        Test.startTest();
        List<AMS_Inspection__c> agencyInspectionList = new List<AMS_Inspection__c>();
        AMS_Inspection__c ins1 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '2', Date_Organisation_Status_attained__c=System.today());
        agencyInspectionList.add(ins1);
        AMS_Inspection__c ins2 = new AMS_Inspection__c(Account__c=a1.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '2', Date_Organisation_Status_attained__c=System.today());
        agencyInspectionList.add(ins2);
        //AMSU-161
        AMS_Inspection__c ins3 = new AMS_Inspection__c(Account__c=a2.id,Accreditation_Endorsement_organisation__c=ao.id,Accreditation_Endorsement_Status_code__c = '2', Date_Organisation_Status_attained__c=System.today());
        agencyInspectionList.add(ins3);

        insert agencyInspectionList;

        /*
        list<Task> acctTasks = [SELECT Id FROM Task WHERE WhatId = :a1.Id];
        System.assertEquals(0, acctTasks.size());
        */

        ins1.Accreditation_Endorsement_Status_code__c='0';
        update ins1;
        /*
        acctTasks = [SELECT Id FROM Task WHERE WhatId = :a1.Id];
        System.assertEquals(0, acctTasks.size());
        */

        ApexPages.StandardController stdController = new ApexPages.StandardController(ins2);
        AMS_InspectionNotificationController ctrl = new AMS_InspectionNotificationController(stdController);
        ctrl.setNotificationMessage();
        system.assertEquals(false, ctrl.hasNoActiveInspections);

        ins2.Accreditation_Endorsement_Status_code__c='0';
        update ins2;

        /*
        acctTasks = [SELECT Id FROM Task WHERE WhatId = :a1.Id];
        System.assertEquals(1, acctTasks.size());
        */

        stdController = new ApexPages.StandardController(ins2);
        ctrl = new AMS_InspectionNotificationController(stdController);
        ctrl.setNotificationMessage();
        
        //AMSU-161 - on the current scenario the account get's terminated and the value becomes false
        //system.assertEquals(true, ctrl.hasNoActiveInspections);
        system.assertEquals(true, ctrl.hasNoActiveInspections);

        //AMSU-161 start
        ins3.Accreditation_Endorsement_Status_code__c='0';
        update ins3;

        stdController = new ApexPages.StandardController(ins3);
        ctrl = new AMS_InspectionNotificationController(stdController);
        ctrl.setNotificationMessage();
        
        system.assertEquals(false, ctrl.hasNoActiveInspections);
        //AMSU-161 end
    }
}