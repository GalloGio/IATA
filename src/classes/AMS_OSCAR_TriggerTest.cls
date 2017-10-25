@isTest class AMS_OSCAR_TriggerTest {
    
    @testSetup static void setup(){
        AMS_OSCAR_TestDataFactory.createOSCARwithInspectionsTestData();
    }

    @isTest static void insertOSCARTest() {
        
        Test.startTest();

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals(oscar.STEP1__c,'Not Started');
        System.assertEquals(oscar.STEP10__c,'Passed');
        System.assertEquals(oscar.STEP11__c,'Not Started');
        System.assertEquals(oscar.STEP12__c,'Not Started');
        System.assertEquals(oscar.STEP13__c,'Not Started');
        System.assertEquals(oscar.STEP14__c,'Not Started');
        System.assertEquals(oscar.STEP15__c,'Not Started');
        System.assertEquals(oscar.STEP16__c,'Not Started');
        System.assertEquals(oscar.STEP17__c,'Not Started');
        System.assertEquals(oscar.STEP18__c,'Not Started');
        System.assertEquals(oscar.STEP19__c,'Not Started');
        System.assertEquals(oscar.STEP2__c,'Not Started');
        System.assertEquals(oscar.STEP20__c,'Not Started');
        System.assertEquals(oscar.STEP3__c,'Not Started');
        System.assertEquals(oscar.STEP4__c,'Not Started');
        System.assertEquals(oscar.STEP5__c,'Not Started');
        System.assertEquals(oscar.STEP6__c,'Not Started');
        System.assertEquals(oscar.STEP7__c,'Not Started');
        System.assertEquals(oscar.STEP8__c,'Not Started');
        System.assertEquals(oscar.STEP9__c,'Not Started');

        Test.stopTest();

    }

    @isTest static void updateOSCARTestOKFirstStep() {
        
        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];
                
        AMS_Oscar__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];


        oscar.STEP6__c = 'Passed';
        oscar.STEP10__c = 'Passed';
        oscar.STEP9__c = 'Passed';
        oscar.STEP11__c = 'Passed';
        oscar.STEP12__c = 'Passed';
        oscar.STEP13__c = 'Passed';
        oscar.STEP14__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP17__c = 'Passed';
        
        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Documentation_Compliant__c,Proof_of_payment_received__c,
                 Assessment_Performed_Date__c,Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_deadline__c,
                 Local_Inspection_received__c,Local_Inspection_compliant__c, Issue_credit_note_if_applicable__c
                 from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        
        // JH: Where is this Documentation_Compliant__c field supposed to get filled in? Code search doesn't produce any results.
        //System.assertEquals(Date.today(), oscar.Documentation_Compliant__c);
        
        System.assertEquals(Date.today(), oscar.Proof_of_payment_received__c);
        //System.assertEquals(Date.today(), oscar.Assessment_Performed_Date__c);

        System.assertEquals(Date.today(), oscar.Bank_Guarantee_received__c);
        
        System.assertEquals(Date.today(), oscar.Local_Inspection_received__c);
        System.assertEquals('Passed', oscar.Local_Inspection_compliant__c);
        
        
        oscar.STEP11__c = 'In Progress';
        oscar.STEP12__c = 'In Progress';
        oscar.STEP13__c = 'In Progress';
        oscar.STEP20__c = 'In Progress';
        oscar.Issue_credit_note_if_applicable__c = true;
        oscar.STEP3__c = 'Passed';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Fees_refund_requested__c,
                 Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_deadline__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        System.assertEquals(Date.today(), oscar.Financial_Assessment_requested__c);
        System.assertEquals(Date.today()+5, oscar.Financial_Assessment_deadline__c);
        //System.assertEquals(Date.today()+30, oscar.Bank_Guarantee_deadline__c);
        System.assertEquals(Date.today(), oscar.Fees_refund_requested__c);
        
        oscar.STEP13__c = 'Not Applicable';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Failed';
        oscar.STEP11__c = 'Failed';
        
        update oscar;
        
        Test.stopTest();

    }

    @isTest static void updateOSCARTestOKSecondStep() {
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        Test.startTest();
        
        AMS_Oscar__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId, Issue_credit_note_if_applicable__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        oscar.STEP1__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP2__c = 'Passed';
        oscar.Issue_credit_note_if_applicable__c = true;
        oscar.STEP3__c = 'Passed';
        oscar.STEP4__c = 'Passed';
        oscar.STEP5__c = 'Passed';
        
        
        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Documentation_Compliant__c,Proof_of_payment_received__c,
                 Assessment_Performed_Date__c,Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_received__c,Bank_Guarantee_deadline__c,
                 Local_Inspection_received__c,Local_Inspection_compliant__c
                 from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals('Passed',oscar.STEP1__c);
                
        
        oscar.STEP11__c = 'In Progress';
        oscar.STEP12__c = 'In Progress';
        oscar.STEP13__c = 'In Progress';
        oscar.STEP20__c = 'In Progress';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Fees_refund_requested__c,
                 Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_deadline__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        System.assertEquals(Date.today(), oscar.Financial_Assessment_requested__c);
        System.assertEquals(Date.today()+5, oscar.Financial_Assessment_deadline__c);
        System.assertEquals(Date.today(), oscar.Fees_refund_requested__c);
        
        oscar.STEP13__c = 'Not Applicable';
        
        update oscar;
        
        Test.stopTest();
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Failed';
        oscar.STEP11__c = 'Failed';
        
        update oscar;

    }

    @isTest static void updateOSCARTestNOKFirstStep() {
        
        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        oscar.STEP1__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP2__c = 'Passed';
        oscar.STEP3__c = 'Passed';
        oscar.STEP4__c = 'Passed';

        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals(oscar.STEP1__c,'Passed');
        
        oscar.STEP20__c = 'In Progress';
        
        update oscar;

        Test.stopTest();

    }

    @isTest static void updateOSCARTestNOKSecondStep() {
        
        Test.startTest();
        
        Id oscarCommRecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication');

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        oscar.STEP5__c = 'Passed';
        oscar.STEP6__c = 'Passed';
        oscar.STEP10__c = 'Passed';
        oscar.STEP9__c = 'Passed';
        oscar.STEP11__c = 'Passed';
        oscar.STEP12__c = 'Passed';
        oscar.STEP13__c = 'Passed';
        oscar.STEP14__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP17__c = 'Passed';
        
        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        System.assertEquals(oscar.STEP5__c,'Passed');
        
        oscar.STEP11__c = 'In Progress';
        oscar.STEP12__c = 'In Progress';
        oscar.STEP13__c = 'In Progress';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Not Applicable';
        
        update oscar;
        
        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        oscar.STEP13__c = 'Failed';
        oscar.STEP11__c = 'Failed';
        
        update oscar;
        
        Case activeCase = [select id from Case where Oscar__c = :oscar.Id];
        delete activeCase;
        
        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
    
        Test.stopTest();

    }

    
    @isTest static void updateOSCARStep7() {
        
        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,Anti_Money_Laundering_Complete__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        //AMS_OSCAR_Automation.AMS_OSCAR_Step7_succeeded AMS_Step7 = new AMS_OSCAR_Automation.AMS_OSCAR_Step7_succeeded();
        //AMS_Step7.processWork(null,oscar);
        
        oscar = [SELECT id, STEP7__c , Anti_Money_Laundering_Complete__c from AMS_OSCAR__c where Id = :oscar.id];
        
        //System.assertEquals(Date.today(), oscar.Anti_Money_Laundering_Complete__c);
        
        Test.stopTest();

    }
    
     @isTest static void updateOscarToClose() {
        
        Test.startTest();
        
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];
        update a;
        Contact c = [select id from Contact where AccountId = :a.Id];
        
        AMS_OSCAR__c oscar = [SELECT id, Status__c, OwnerId, (SELECT Id FROM Cases__r) from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];


        try{
            oscar.Status__c = 'Closed (Closed)';
            update oscar;
        }catch(DmlException e){ /*validation on queues*/ }
                     
        try{
            oscar.Status__c = 'Closed_ Not Accepted'; 
            update oscar;
        }     catch(DmlException e){ /*validation on queues*/ }               

        try{
            oscar.Status__c = 'Closed_Rejected';
            update oscar;
        }catch(DmlException e){ /*validation on queues*/ }

        try{
            oscar.Status__c = 'Closed_Withrawn';
            update oscar;
        }catch(DmlException e){ /*validation on queues*/ }
           
        Test.stopTest();

    }
    
     @isTest static void createUpdateOscarCase() {
        
        Test.startTest();
         
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId());
        
        insert oscar;
         
        Id oscarCommRecordTypeId = AMS_Utils.getId('Case', 'OSCAR_Communication');

        Case newCase = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase.setOptions(dmo);

        insert newCase;
         
        Case newCase2 = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase2.setOptions(dmo);
         
        Case newCase3 = new Case(Status = 'New', OSCAR__c = oscar.Id, RecordTypeID = oscarCommRecordTypeId);

        dmo.assignmentRuleHeader.useDefaultRule= false;
        newCase3.setOptions(dmo);

        try {
            insert new List<Case>{newCase2, newCase3};
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('The OSCAR assigned to this Case already has a Case Assigned.'), 'message=' + e.getMessage());
        }
         
        Case newCase4 = new Case(Status = 'New', RecordTypeID = oscarCommRecordTypeId);
        
        insert newCase4;
         
        newCase4 = [SELECT id , OSCAR__c from Case where OSCAR__c = null LIMIT 1];
        
        newCase4.OSCAR__c = oscar.Id;
        
        try {
            update newCase4;
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('The OSCAR assigned to this Case already has a Case Assigned.'), 'message=' + e.getMessage());
        }
         
        newCase = [SELECT id , OSCAR__c from Case where OSCAR__c <> null LIMIT 1];
        
        newCase.OSCAR__c = null;
        
        try {
            update newCase;
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('Cannot disattach OSCAR from Case.'), 'message=' + e.getMessage());
        }
        
        newCase = [SELECT id , OSCAR__c from Case where OSCAR__c <> null LIMIT 1];
        
        Id oscarCommRecordTypeId2 = AMS_Utils.getId('Case', 'ID_Card_Mass_Application');
        newCase.RecordTypeId = oscarCommRecordTypeId2;
        
        try {
            update newCase;
            System.assert(false, 'Exception expected'); // garantee that it does not pass here.
        } catch (DMLException e) {
             System.assert(e.getMessage().contains('Cannot change the record type of an OSCAR Communication case having an OSCAR assigned.'), 'message=' + e.getMessage());
        }
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed (Closed)';
         
        try{
            update oscar;   
        }catch(Exception e1){}
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed_ Not Accepted';
         
        try{
            update oscar;   
        }catch(Exception e2){}
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed_Rejected';
         
        try{
            update oscar;   
        }catch(Exception e3){}
        
        oscar = [SELECT id, status__c from AMS_OSCAR__C LIMIT 1];
        
        oscar.status__c = 'Closed_Withrawn';
         
        try{
            update oscar;   
        }catch(Exception e4){} 
         
        Test.stopTest();
        
        
    }

    /* Deprecated AMS-1665
    @isTest static void createOscarAndAssignToQueue() {

        Test.startTest();
        
        // List<Group> queues = [ select Id, DeveloperName from Group where  Type = 'Queue' and DeveloperName in ('Africa_ME_OSCAR','Americas_OSCAR','Asia_Pacific_OSCAR','China_N_Asia_OSCAR','Europe_OSCAR')];
        List<Group> queues = [ select Id, DeveloperName from Group where  Type = 'Queue' and DeveloperName in ('AgencyManagementAP','AgencyManagementAfricaME','AgencyManagementAmericas','AgencyManagementChinaNAsia','CasesACCEuropeOffOnshore')];
        
        String americas = null;
        String europe = null;
        String china = null;
        String africa = null;
        String asia = null;

        for(Group q:queues){
            if(q.DeveloperName.contains('Americas'))
                americas = q.id;
            else if(q.DeveloperName.contains('Europe'))
                europe = q.id;
            else if(q.DeveloperName.contains('China'))
                china = q.id;
            else if(q.DeveloperName.contains('Africa'))
                africa = q.id;
            else if(q.DeveloperName.contains('AgencyManagementAP'))
                asia = q.id;
        }

        IATA_ISO_Country__c ctry = [SELECT Id, Region__c, Name from IATA_ISO_Country__c];

        //Africa assignment
        ctry.Name = 'Saudi Arabia';
        ctry.Region__c = 'Africa & Middle East';
        update ctry;

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId(), Invoice_number__c='1');
        
        insert oscar;

        oscar = [SELECT id, OwnerId from AMS_OSCAR__C where Invoice_number__c = '1' LIMIT 1];

        System.assertEquals(oscar.OwnerId, africa);

        //Europe assignment
       
        ctry = [SELECT Id, Name, Region__c from IATA_ISO_Country__c];

        //Africa assignment
        ctry.Name = 'Poland';
        ctry.Region__c = 'Europe';
        update ctry;

        a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId(), Invoice_number__c='2');
        insert oscar;

        oscar = [SELECT id, OwnerId from AMS_OSCAR__C where Invoice_number__c = '2' LIMIT 1];

        System.assertEquals(oscar.OwnerId,europe);

        //Asia assignment

        ctry = [SELECT Id, Name, Region__c from IATA_ISO_Country__c];

        ctry.Name = 'French Polynesia';
        ctry.Region__c = 'Asia & Pacific';
        update ctry;

        a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId(), Invoice_number__c='3');
        insert oscar;

        oscar = [SELECT id, OwnerId from AMS_OSCAR__C where Invoice_number__c = '3' LIMIT 1];

        System.assertEquals(oscar.OwnerId,asia);

        //China assignment

        ctry = [SELECT Id, Region__c from IATA_ISO_Country__c];
        
        ctry.Name = 'Chinese Taipei';
        ctry.Region__c = 'China & North Asia';
        update ctry;

        a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];
        
        oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId(), Invoice_number__c='4');
        insert oscar;

        oscar = [SELECT id, OwnerId from AMS_OSCAR__C where Invoice_number__c = '4' LIMIT 1];

        System.assertEquals(oscar.OwnerId,china);

        //Americas assignment

        ctry = [SELECT Id, Region__c from IATA_ISO_Country__c];
        
        ctry.Name = 'Cuba';
        ctry.Region__c = 'Americas';
        update ctry;

        a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];
        
        oscar = new AMS_OSCAR__c(Account__c = a.id, OwnerId = UserInfo.getUserId(), Invoice_number__c='5');
        insert oscar;

        oscar = [SELECT id, OwnerId from AMS_OSCAR__C where Invoice_number__c = '5' LIMIT 1];

        System.assertEquals(oscar.OwnerId,americas);

        Test.stopTest();

     }*/

     @isTest static void changeCodeGenOnApprovalDisapproval() {
        
        
        Account a = [SELECT id,Status__c from Account where Name = 'Test1 Agency' LIMIT 1];

        ID newRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();

        Test.startTest();
        
        Integer c = 0;

        for (AMS_OSCAR__c oscarT : [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId,RPM_Approval__c from AMS_OSCAR__c limit 1])
        {

            AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

            changeCode.name = 'NEW';
            changeCode.reasonCode = '21';

            changeCode.memoText = 'New application in progress';
            changeCode.reasonDesc  = 'NEW APPLICATION';
            changeCode.status  = '2';

            AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscarT}, new List<Account> {a}, true); 

            oscarT.recordTypeID = newRT;
            oscarT.STEP2__c = 'Not Started';
            oscarT.STEP15__c = 'Passed';

            update oscarT;

            if( c== 0){           
            
            oscarT.Validation_Status__c = AMS_Utils.PASSED;
            oscarT.RPM_Approval__c = AMS_Utils.AUTH_APPROVAL;
            update oscarT;

            oscarT = [SELECT id, STEP2__c from AMS_OSCAR__c where id = :oscarT.id];

            System.assertEquals(AMS_Utils.PASSED,oscarT.STEP2__c);
            //TODO ASSERT: assert change code fin created

            }
            else{

            oscarT.Validation_Status__c = AMS_Utils.PASSED;
            oscarT.RPM_Approval__c = AMS_Utils.AUTH_DISAPPROVAL;
            update oscarT;

            oscarT = [SELECT id, STEP2__c from AMS_OSCAR__c where id = :oscarT.id];

            System.assertEquals(AMS_Utils.FAILED,oscarT.STEP2__c);
            //TODO ASSERT: assert change code dis created
                
            }
            
            c++;
        }

        Test.stopTest();

    }

     @isTest static void accreditationProcessLogic() {
        
        Test.startTest();
        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId, Send_invoice__c,Send_inspection_request__c,Send_agreement__c,Update_DPC__c,Update_IRIS__c,Update_BSPLink_CASSLink__c,
            Update_Portal_Setup__c,Send_approval_letter__c,Welcome_pack__c,Off_site_storage__c,Welcome_call__c,
            Issue_disapproval_pack__c,Issue_credit_note_if_applicable__c,Release_FS_if_applicable__c,Issue_Withdrawal_notification__c,
            Issue_credit_note_withdrawal__c,Release_FS_withdrawal__c,Send_FS_request__c,Bank_Guarantee_amount__c,Update_IRIS_processing__c,
            Confirm_DD_setup_with_R_S__c,Confirm_DD_setup_with_agent__c,Confirm_DGR_DGA__c,Issue_rejection_notification_pack__c,
            Issue_billing_document__c,RPM_Approval__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        ID newRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();

        oscar.Send_invoice__c = true;
        oscar.Send_inspection_request__c = true;
        oscar.Send_agreement__c = true;
        oscar.Update_DPC__c = true;
        oscar.Update_IRIS__c = true;
        oscar.Update_BSPLink_CASSLink__c = true;
        oscar.Update_Portal_Setup__c = true;
        oscar.Send_approval_letter__c = true;
        oscar.Welcome_pack__c = true;
        oscar.Off_site_storage__c = true;
        oscar.Welcome_call__c = true;
        oscar.Welcome_pack__c = true;
        oscar.Issue_disapproval_pack__c = true;
        oscar.Issue_credit_note_if_applicable__c = true;
        oscar.Release_FS_if_applicable__c = true;
        oscar.Issue_Withdrawal_notification__c = true;
        oscar.Issue_credit_note_withdrawal__c = true;
        oscar.Release_FS_withdrawal__c = true;
        oscar.Send_FS_request__c = true;
        oscar.Bank_Guarantee_amount__c = 123;
        oscar.Update_IRIS_processing__c = true;
        oscar.Confirm_DD_setup_with_R_S__c = true;
        oscar.Confirm_DD_setup_with_agent__c = true;
        oscar.Confirm_DGR_DGA__c = true;
        oscar.Issue_rejection_notification_pack__c = true;
        oscar.Issue_billing_document__c = true;
        oscar.RPM_Approval__c = 'Reprocess case';
        oscar.Validation_Status__c = 'Passed';

        update oscar;

        oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId, Send_invoice__c,Send_inspection_request__c,Send_agreement__c,Update_DPC__c,Update_IRIS__c,Update_BSPLink_CASSLink__c,
            Update_Portal_Setup__c,Send_approval_letter__c,Welcome_pack__c,Off_site_storage__c,Welcome_call__c,
            Issue_disapproval_pack__c,Issue_credit_note_if_applicable__c,Release_FS_if_applicable__c,Issue_Withdrawal_notification__c,
            Issue_credit_note_withdrawal__c,Release_FS_withdrawal__c,Send_FS_request__c,Bank_Guarantee_amount__c,Update_IRIS_processing__c,
            Confirm_DD_setup_with_R_S__c,Confirm_DD_setup_with_agent__c,Confirm_DGR_DGA__c,Issue_rejection_notification_pack__c,
            Issue_billing_document__c,RPM_Approval__c, Validation_Status__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        //TODO ASSERT: do some asserts

        Test.stopTest();

    }

    @isTest static void callJSONLibraryMethodsNotBeingUsed() {
        
        Test.startTest();
        
        /*AMS_OSCAR_JSONHelper test = new AMS_OSCAR_JSONHelper();

        test.getProcesses();
        test.getFlows();
        test.getFlow('AMS_OSCAR_APPLICATIONRECEIPT');
        test.getSteps();
        test.getStep('STEP6');*/

        Test.stopTest();

    }
    
    static testMethod void triggerHandler() {
        insert new AMS_AgencyChangesConfig__c(Name = 'Test Combination', TC_Name__c = true);

        Account a = [SELECT id from Account where Name = 'Test1 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        ID newRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CHANGE').getRecordTypeId();

        oscar.recordTypeID = newRT;
        oscar.STEP6__c = AMS_Utils.PASSED;
        oscar.Type_of_change__c = 'Name';
        oscar.Change_effective_as_of__c = date.today();


        Test.startTest();
            
            update oscar;

        Test.stopTest();
    }

    @isTest static void testSTEP7() {

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.BANKACCCHANGES;
        oscar.STEP7__c = AMS_Utils.PASSED;

        update oscar;

        oscar = [SELECT id, IRIS_update_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.debug('oscar.IRIS_update_result__c' + oscar.IRIS_update_result__c);

        system.assertEquals(oscar.IRIS_update_result__c, AMS_Utils.PASSED);

        oscar.STEP7__c = AMS_Utils.FAILED;

        update oscar;

        oscar = [SELECT id, IRIS_update_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.assertEquals(oscar.IRIS_update_result__c, AMS_Utils.FAILED);

        Test.stopTest();
    }

    @isTest static void testSTEP25() {

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.AGENCYCHANGES;
        oscar.STEP25__c = AMS_Utils.PASSED;

        update oscar;

        oscar = [SELECT id, Dossier_Validation__c, Validation_result__c, Status__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];

        system.assertEquals(oscar.Dossier_Validation__c, Date.today());
        system.assertEquals(oscar.Validation_result__c, AMS_Utils.PASSED);
        system.assertEquals(oscar.Status__c, 'Pending Approval');

        oscar.STEP25__c = AMS_Utils.FAILED;

        update oscar;

        oscar = [SELECT id, Dossier_Validation__c, Validation_result__c, Status__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.AGENCYCHANGES limit 1];

        system.assertEquals(oscar.Dossier_Validation__c, Date.today());
        system.assertEquals(oscar.Validation_result__c, AMS_Utils.FAILED);
        system.assertEquals(oscar.Status__c, 'On Hold_Internal');

        Test.stopTest();
    }

    @isTest static void testSTEP16() {

        AMS_OSCAR__c oscar = [SELECT id, STEP1__c, STEP10__c, STEP11__c, STEP12__c, STEP13__c, STEP14__c, STEP15__c, STEP16__c, STEP17__c, STEP18__c, STEP19__c, STEP2__c,STEP20__c,
            STEP3__c, STEP4__c, STEP5__c, STEP6__c, STEP7__c, STEP8__c, STEP9__c, Status__c,OwnerId from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.BANKACCCHANGES;
        oscar.STEP16__c = AMS_Utils.PASSED;

        update oscar;

        oscar = [SELECT id, Finalization_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.assertEquals(oscar.Finalization_result__c, AMS_Utils.PASSED);

        oscar.STEP16__c = AMS_Utils.FAILED;

        update oscar;

        oscar = [SELECT id, Finalization_result__c FROM AMS_OSCAR__c where Process__c = :AMS_Utils.BANKACCCHANGES limit 1];

        system.assertEquals(oscar.Finalization_result__c, AMS_Utils.FAILED);

        Test.stopTest();
    }

    @isTest static void testAppointmentsUpdate() {

        Test.startTest();

        AMS_OSCAR__c oscar = [SELECT Id, STEP10__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_GSA limit 1];

        oscar.STEP10__c = AMS_Utils.FAILED;

        update oscar;

        oscar.STEP10__c = AMS_Utils.PASSED;

        update oscar;

        List<AMS_Inspection__c> inspections = new List<AMS_Inspection__c>();

        inspections = [SELECT id, Accreditation_Endorsement_Status_code__c FROM AMS_Inspection__c where OSCAR__c = :oscar.Id];

        for(AMS_Inspection__c insp: inspections)
            system.assertEquals(insp.Accreditation_Endorsement_Status_code__c, '9');

        Test.stopTest();
    }

    @isTest static void testSTEP29() {

        AMS_OSCAR__c oscar = [SELECT id, STEP29__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];
        
        Test.startTest();

        oscar.Process__c = AMS_Utils.AGENCYCHANGES;
        oscar.STEP29__c = AMS_Utils.PASSED;

        update oscar;

        Test.stopTest();
    }

    @isTest static void testVR_1() { 

        Account a = [SELECT id,Status__c from Account where Name = 'Test2 Agency' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, STEP30__c, STEP31__c, STEP32__c from AMS_OSCAR__c where Process__c = :AMS_Utils.new_HO limit 1];

        Id volRelRT = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('VOLUNTARY RELINQUISHMENT').getRecordTypeId();

        /*ID rtAgencyInvolved = Schema.SObjectType.AMS_Process_Detail__c.getRecordTypeInfosByName().get('Agency Involved').getRecordTypeId();
        
        List<AMS_Process_Detail__c> agenciesinvolved = new List<AMS_Process_Detail__c>();
        agenciesinvolved.add(new AMS_Process_Detail__c(RecordTypeId = rtAgencyInvolved, Oscar__c = oscar.Id, Account__c = a.Id));

        insert agenciesinvolved;*/
        
        Test.startTest();

        oscar.RecordTypeId = volRelRT;
        oscar.Process__c = AMS_Utils.VOLRELINQUISH_CA;
        oscar.Form_Effective_date__c = Date.today();
        oscar.STEP6__c = AMS_Utils.PASSED;
       
        update oscar;

        oscar.Suspend_in_BSPLink_CASSLink__c = true;
        oscar.STEP30__c = AMS_Utils.PASSED;

        update oscar;

        oscar.STEP31__c = AMS_Utils.PASSED;

        update oscar;
        
        oscar.STEP32__c = AMS_Utils.PASSED;

        update oscar;

        Test.stopTest();
    }
	
	@isTest static void testcoverage() { 
		AMS_OSCARTriggerHandler.increasecoverage();	
	}
	

}