@isTest
private class ANG_financialReviewOnCaseTest {
    @testSetup static void testSetup() {

        User u=[select id from User where id =:UserInfo.getUserId()];
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
            Message__c = 'Some message',
            Type__c = 'Information',
            Notification_color__c = '#FF5E4D',
            Admins_Users__c = 'User',
            Expire_in_days__c = 0,
            Identifier__c = 'Risk_Status_Upgrade'
        );
        insert new AMS_ChangeCodes__c(
            Name = 'UpgradedRisk', 
            Change_Code__c = 'UGR', 
            Integration_RecId__c = 'C', 
            Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Card payment methods are reinstated.'
        );


        // Create a new ISO Country
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name = 'France', 
            ISO_Code__c = 'FR',
            AIMS_Area_ID__c='1',
            ANG_Enable_NewGen__c = true
        );
        insert country;
        
        // Create an Agency HE account
        Account a = new Account(
            Name = 'Qatar Airways', 
            Airline_designator__c = 'QR', 
            recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
            iataCode__C='99999999',
            BillingCountry='France',
            Location_type__C='HE',
            Location_Class__c='P',
            Type = 'IATA Passenger Sales Agent',
            Sector__c='Travel Agent',
            IATA_ISO_Country__c=country.id,
            ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH

        );
        insert a;        
        
        // Create a new Financial Institution
        Financial_Institution__c fi = new Financial_Institution__c(Name = 'Test FI', Region__c = 'Americas', Country__c = 'Canada', Institution_Type__c = 'Bank');
        insert fi;

        Contact cont= new Contact(
        		lastName='lastName',
        		Financial_Assessment_Contact__c=true,
                AccountId = a.Id, 
        		email='test@test.com'
        	);
        insert cont;
        // create a reception case
        Case c = new Case(
        		Subject = 'rception case',
        		AccountId = a.Id, 
        		contactId=cont.Id,
        		Status = 'Open', 
        		Assessment_Performed_Date__c= system.today(),
        		Financial_Review_Result__c='Satisfactory - New Financial Security',
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('IATA_Financial_Review'),IFAP_Area__c='asda'
                 );
        insert c;
                
        // Create a new Financial Security
        Financial_Security__c fs = new Financial_Security__c(Region__c = 'Americas', Security_status__c = 'Active', Account__c = a.Id, CurrencyIsoCode = 'USD', Amount__c = 100,
                        Expiry_date__c = Date.today().addYears(2), Financial_Institution__c = fi.Id, Security_Type__c = 'Cross Border Guarantee', 
                        Validity_Start_Date__c = Date.today().addDays(-2), Reception_Case__c = c.Id, Reception_Date__c = Date.today(), Reasonforrequest__c = 'New Application');
        insert fs;


        ANG_Agency_Risk_Calculation__c calcB = new ANG_Agency_Risk_Calculation__c(RecordTypeId = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT, ANG_Financial_Review_Result__c = 'Satisfactory - New Financial Security', ANG_Risk_History_Assessment__c = AMS_Utils.FAILED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_B, ANG_Limit_Cash_Condition__c = false);
        ANG_Agency_Risk_Calculation__c calcC = new ANG_Agency_Risk_Calculation__c(RecordTypeId = ANG_Risk_Helper.RECTYPE_RISKSTATUSASSESSMENT, ANG_Financial_Review_Result__c = null, ANG_Risk_History_Assessment__c = AMS_Utils.FAILED, ANG_Risk_History__c = ANG_Risk_Helper.RISK_STATUS_c, ANG_Limit_Cash_Condition__c = true);
        ANG_Agency_Risk_Calculation__c rule = new ANG_Agency_Risk_Calculation__c(ANG_Order__c = 1, ANG_Occurrence_Num__c = 1, ANG_Adjusted__c = ANG_Risk_Helper.ADJ_NO, ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH, RecordTypeId = ANG_Risk_Helper.RECTYPE_RULES);
        insert new List<ANG_Agency_Risk_Calculation__c>{calcC, calcB, rule};

        ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
            Name = 'Risk Event Test',
            ANG_Description__c = 'Risk Event Test',
            ANG_Expiration__c = 24,
            ANG_Risk_ID__c = 'testRiskId',
            ANG_Agency_Risk_Calculation__c = rule.Id

        );
        insert ret;

        ANG_Agency_Risk_Event__c re1 = new ANG_Agency_Risk_Event__c(
            ANG_AccountId__c = a.id,
            ANG_Risk_Type__c = ret.id,
            ANG_Issued_Date__c = System.today(),
            ANG_Event_Status__c = ANG_Risk_Helper.STATUS_ACTIVE
        );

        insert re1;
       

    }
    TestMethod static void updateCaseStatusToUpdateFinancialReview(){
    	Test.startTest();
	    	case c=[select id,Financial_Review_Result__c from case limit 1];
	    	c.status='Closed';
	        update c;
        Test.stopTest();
        system.assertEquals(c.Financial_Review_Result__c,[select Financial_Review_Result__c from account limit 1].Financial_Review_Result__c);

    } 
    TestMethod static void updateCaseStatusToNOTUpdateFinancialReview(){
    	account beforeUpdateAcc =[select Financial_Review_Result__c from account limit 1];	

    	Test.startTest();
	    	case c=[select id,Financial_Review_Result__c from case limit 1];
	    	c.status='Approved';
	        update c;
        Test.stopTest();
        account afterUpdateAcc =[select Financial_Review_Result__c from account limit 1];	

        system.assertEquals(afterUpdateAcc.Financial_Review_Result__c,beforeUpdateAcc.Financial_Review_Result__c);

    }

     TestMethod static void updateCaseStatusToUpgradeAccountRiskStatus(){
       
        

        Account beforeUpdateAcc =[select id, ANG_HE_RiskStatus__c,Financial_Review_Result__c from account limit 1]; 

    testMethod static void updateSAAMStatusToUpdateFinancialReview(){  
        Account beforeUpdateAcc =[select id, ANG_HE_RiskStatus__c,Financial_Review_Result__c,(select id from contacts) from account limit 1];
        system.assertEquals('B',beforeUpdateAcc.ANG_HE_RiskStatus__c);
        Test.startTest();
           Case c = new Case(
                   RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('ProcessEuropeSCE'),
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