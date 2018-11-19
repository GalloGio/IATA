@isTest
private class ANG_financialReviewOnCaseTest {
    @testSetup static void testSetup() {

        User u = [SELECT Id FROM User WHERE Id =:UserInfo.getUserId()];
        System.runAs(u){
            insert new EmailTemplate(
                isActive = true,
                Name = 'Risk_Status_Upgrade',
                DeveloperName = 'Risk_Status_Upgrade',
                TemplateType = 'text',
                FolderId = UserInfo.getUserId()
            );
        }

        insert new Notification_template__c (
            Subject__c = 'Some subject',
            Message__c = 'Some message: #RISK_STATUS# / #CASH_CONDITION#',
            Type__c = 'Information',
            Notification_color__c = '#FF5E4D',
            Admins_Users__c = 'User',
            Expire_in_days__c = 0,
            Identifier__c = 'Risk_Status_Upgrade'
        );
        insert new AMS_ChangeCodes__c(
            Name = 'UpgradedRisk', 
            Change_Code__c = 'UGR', 
            Integration_RecId__c = 'C'
        );


        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'France', 
            ISO_Code__c = 'FR',
            AIMS_Area_ID__c = '1',
            ANG_Enable_NewGen__c = true
        );
        insert country;

        ANG_Agency_Risk_Calculation__c calcA = new ANG_Agency_Risk_Calculation__c(RecordTypeId = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT, ANG_Financial_Review_Result__c = 'Satisfactory - New Financial Security', ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_A, ANG_Limit_Cash_Condition__c = false);
        ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(RecordTypeId = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT, ANG_Financial_Review_Result__c = null, ANG_Risk_History_Assessment__c = AMS_Utils.PASSED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_B, ANG_Limit_Cash_Condition__c = true);
        insert new List<ANG_Agency_Risk_Calculation__c>{calcB, calcA};
        
        // Create an Agency HE Account
        Account a = new Account(
            Name = 'Qatar Airways', 
            Airline_designator__c = 'QR', 
            RecordtypeId = AMS_Utils.RECTYPE_IATAAGENCY,
            IATACode__c = '99999999',
            BillingCountry = 'France',
            Location_type__c = 'HE',
            Location_Class__c = 'P',
            Type = 'IATA Passenger Sales Agent',
            Sector__c = 'Travel Agent',
            IATA_ISO_Country__c = country.Id,
            ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
            ANG_HE_RiskHistoryAssessment__c = AMS_Utils.PASSED,
            ANG_HE_RiskStatus__c = ANG_Risk_Helper.RISK_STATUS_B,
            ANG_Limit_Cash_Condition__c = true,
            ANG_HE_CashCondition__c = true
        );
        insert a;  

        Contact cont= new Contact(
                lastName = 'lastName',
                Financial_Assessment_Contact__c = true,
                AccountId = [SELECT Id FROM Account][0].Id, 
                email = 'test@test.com'
            );
        insert cont;      
        
        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
        insert fi;

        // create a reception Case
        Case c = new Case(
                Subject = 'rception Case',
                AccountId = a.Id, 
                contactId = cont.Id,
                Status = 'Open', 
                Assessment_Performed_Date__c= System.today(),
                Financial_Review_Result__c = 'Satisfactory - New Financial Security',
                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'IATA_Financial_Review'),
                IFAP_Area__c = 'asda'
                 );
        insert c;
                
        // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = a.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
                        Expiry_date__c = Date.today().addYears(2), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee', 
                        ValIdity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = c.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
        insert fs;
       

    }

    static testMethod void updateCaseStatusToNOTUpdateFinancialReview(){
        Account beforeUpdateAcc =[SELECT Financial_Review_Result__c FROM Account LIMIT 1];
        Case c = [SELECT Id,Financial_Review_Result__c FROM Case LIMIT 1];  

        Test.startTest();
            c.status = 'Approved';
            update c;
        Test.stopTest();
        Account afterUpdateAcc =[SELECT Financial_Review_Result__c FROM Account LIMIT 1];   

        System.assertEquals(afterUpdateAcc.Financial_Review_Result__c,beforeUpdateAcc.Financial_Review_Result__c);

    }
 
     static testMethod void updateCaseStatusToUpgradeAccountRiskStatus(){
        ANG_RME_Alert_Service_Test.createRMEMappings();

        System.assertEquals('B', [SELECT Id, ANG_HE_RiskStatus__c,Financial_Review_Result__c FROM Account LIMIT 1].ANG_HE_RiskStatus__c);
        System.debug(loggingLevel.FINE, '____ [cls ANG_financialReviewOnCaseTest - updateCaseStatusToUpgradeAccountRiskStatus] Notifications - ' + [SELECT Id, Subject__c FROM Notification__c]);

        Test.startTest();
            Case c = [SELECT Id,Financial_Review_Result__c, ContactId FROM Case LIMIT 1];

            Portal_Applications__c par = new Portal_Applications__c (Name = ANG_RHCHelper.RISK_PROFILE_AND_RHC_PORTAL_SERVICE);
            insert par;

            insert new Portal_Application_Right__c(Portal_Application__c = par.Id, Right__c = 'Access Granted', Contact__c = c.ContactId);

            System.debug(loggingLevel.FINE, '____ [cls ANG_financialReviewOnCaseTest - updateCaseStatusToUpgradeAccountRiskStatus] Limits - ' + Limits.getQueries());

            c.status = 'Closed';
            update c;

            System.debug(loggingLevel.FINE, '____ [cls ANG_financialReviewOnCaseTest - updateCaseStatusToUpgradeAccountRiskStatus] Limits - ' + Limits.getQueries());
        Test.stopTest();


        System.debug(loggingLevel.FINE, '____ [cls ANG_financialReviewOnCaseTest - updateCaseStatusToUpgradeAccountRiskStatus] Limits - ' + Limits.getQueries());

        Account updatedAcc =[SELECT ANG_HE_RiskStatus__c,Financial_Review_Result__c, (SELECT Id FROM Agencies_Applied_Change_codes__r) FROM Account LIMIT 1];   


        System.debug(loggingLevel.FINE, '____ [cls ANG_financialReviewOnCaseTest - updateCaseStatusToUpgradeAccountRiskStatus] Notifications - ' + [SELECT Id, Subject__c FROM Notification__c]);

        System.assertEquals(c.Financial_Review_Result__c,updatedAcc.Financial_Review_Result__c);
        System.assertEquals('A',updatedAcc.ANG_HE_RiskStatus__c);
        System.assertEquals(1, [SELECT Id, Subject__c FROM Notification__c].size(), 'Notification was not created'); 
        System.assertEquals(1, updatedAcc.Agencies_Applied_Change_codes__r.size(), 'Change Code was not created');
    }

    testMethod static void updateSAAMStatusToUpdateFinancialReview(){  
        Account beforeUpdateAcc =[select id, ANG_HE_RiskStatus__c,Financial_Review_Result__c,(select id from contacts) from account limit 1];
        system.assertEquals('B',beforeUpdateAcc.ANG_HE_RiskStatus__c);
        Test.startTest();
           Case c = new Case(
                   RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE'),
                   AccountId = beforeUpdateAcc.Id, 
                   Subject = 'rception case2',
                   contactId=beforeUpdateAcc.contacts.get(0).Id,
                   Status = 'Closed', 
                   Assessment_Performed_Date__c= system.today(),
                   Financial_Review_Result__c='Satisfactory - New Financial Security',
                   CaseArea__c = ANG_Risk_Helper.CASE_AREA_RISK_MANAGEMENT_PROCESS,
                   Reason1__c='Adhoc Review'
                    );
           insert c;
        Test.stopTest();
        account afterUpdateAcc =[select ANG_HE_RiskStatus__c,Financial_Review_Result__c, (select id from Agencies_Applied_Change_codes__r) from account limit 1];   

        system.assertEquals(c.Financial_Review_Result__c,afterUpdateAcc.Financial_Review_Result__c);
        system.assertEquals('A',afterUpdateAcc.ANG_HE_RiskStatus__c);
        System.assertEquals(1, afterUpdateAcc.Agencies_Applied_Change_codes__r.size(), 'Change Code was not created');
    }

}
