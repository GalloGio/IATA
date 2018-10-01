@isTest
public class ANG_RiskAssessmentEngine_Test{
    @testSetup static void testSetup(){
    
        //setup ANG_Risk_Event_Type__c

        //Rules 	
		list<ANG_Agency_Risk_Calculation__c> ruleList = new list<ANG_Agency_Risk_Calculation__c>();
		ANG_Agency_Risk_Calculation__c arc1= new ANG_Agency_Risk_Calculation__c( // risk event that fails with 1 occ
			ANG_Order__c=1,
			ANG_Occurrence_Num__c=1,
			ANG_Adjusted__c= ANG_Risk_Helper.ADJ_NO,
			ANG_Accreditation_Model__c= AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=ANG_Risk_Helper.RECTYPE_RULES
			
			);
		ruleList.add(arc1);

		ANG_Agency_Risk_Calculation__c arc2= new ANG_Agency_Risk_Calculation__c( // risk event that fails with 2 occ
			ANG_Order__c=2,
			ANG_Occurrence_Num__c=2,
			ANG_Adjusted__c= ANG_Risk_Helper.ADJ_NO,
			ANG_Accreditation_Model__c=AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=ANG_Risk_Helper.RECTYPE_RULES
			);
		ruleList.add(arc2);
		
		ANG_Agency_Risk_Calculation__c arc3= new ANG_Agency_Risk_Calculation__c( // risk event that fails with 2 occ or adjusments
			ANG_Order__c=3,
			ANG_Occurrence_Num__c=2,
			ANG_Adjusted__c= ANG_Risk_Helper.ADJ_MIXED,
			ANG_Accreditation_Model__c=AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=ANG_Risk_Helper.RECTYPE_RULES
			);
		ruleList.add(arc3);
		ANG_Agency_Risk_Calculation__c arc4= new ANG_Agency_Risk_Calculation__c( // risk event that fails according  the adjustments
			ANG_Order__c=4,
			ANG_Occurrence_Num__c=0,
			ANG_Adjusted__c= ANG_Risk_Helper.ADJ_YES,
			ANG_Accreditation_Model__c=AMS_Utils.ACCREDITATIONMODEL_CASH,
			recordtypeId=ANG_Risk_Helper.RECTYPE_RULES
			);
		ruleList.add(arc4);

		insert ruleList;

		//adjustment	
		list<ANG_Agency_Risk_Calculation__c> adjustmentList = new list<ANG_Agency_Risk_Calculation__c>();
		ANG_Agency_Risk_Calculation__c adj1= new ANG_Agency_Risk_Calculation__c( // risk event that fails with 1 adjusted occ and 1 partent occ for monthly
			ANG_Remittance_Frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Occurrence_Num__c=1,
			ANG_Parent_Occurences__c=1,
			ANG_Calculation_Rule__c=arc3.id,	
			recordtypeId=ANG_Risk_Helper.RECTYPE_ADJUSTMENT
			);
		adjustmentList.add(adj1);

		ANG_Agency_Risk_Calculation__c adj2= new ANG_Agency_Risk_Calculation__c( // risk event that fails with 1 adjusted occ for daily 
			ANG_Remittance_Frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_DAILY,
			ANG_Occurrence_Num__c=1,
			ANG_Parent_Occurences__c=0,
			ANG_Calculation_Rule__c=arc3.id,
			recordtypeId=ANG_Risk_Helper.RECTYPE_ADJUSTMENT		
			);
		adjustmentList.add(adj2);

		ANG_Agency_Risk_Calculation__c adj3= new ANG_Agency_Risk_Calculation__c( // risk event that fails with 1 adjusted occ  fpr monthly 
			ANG_Remittance_Frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
			ANG_Occurrence_Num__c=2,
			ANG_Parent_Occurences__c=0,
			ANG_Calculation_Rule__c=arc4.id,
			recordtypeId=ANG_Risk_Helper.RECTYPE_ADJUSTMENT			
			);
		adjustmentList.add(adj3);

		insert adjustmentList;

		list<ANG_Risk_Event_Type__c> retpList = new list<ANG_Risk_Event_Type__c>();

		ANG_Risk_Event_Type__c ret1= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 1',
			ANG_Risk_ID__c='1',
			ANG_Expiration__c=12,
			ANG_Agency_Risk_Calculation__c=arc1.id
			);
		retpList.add(ret1);
		ANG_Risk_Event_Type__c ret2= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 2',
			ANG_Risk_ID__c='2',
			ANG_Expiration__c=12,
			ANG_Agency_Risk_Calculation__c=arc2.id
			);
		retpList.add(ret2);
		ANG_Risk_Event_Type__c ret3= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 3 Mixed',
			ANG_Risk_ID__c='3',
			ANG_Expiration__c=12,
			ANG_Agency_Risk_Calculation__c=arc3.id
			);
		retpList.add(ret3);
		ANG_Risk_Event_Type__c ret4= new ANG_Risk_Event_Type__c(
			name= 'Risk Type 4 Adjusted',
			ANG_Risk_ID__c='4',
			ANG_Expiration__c=12,
			ANG_Agency_Risk_Calculation__c=arc4.id
			);
		retpList.add(ret4);

		insert retpList;

        //setup iso_country
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(
        	name='Portugal',
        	ISO_Code__c= 'PT',
        	ISO_Code_Numeric__c=123,
        	ANG_Enable_NewGen__c=true
    		);

        insert isoCountry;

        //setup account
        Account acc = new Account(
        	name='acc1',
        	Location_Type__c=AMS_Utils.HE,
        	Location_Class__c= AMS_Utils.LC_PASSENGER,
        	Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
        	ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
        	recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
            IATA_ISO_Country__c = isoCountry.Id
        	);
        insert acc;
    }
    
    private static void generateRiskEvent(id accId, id riskEventTypeId, Date reDate){
    	ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c=accId,
    		ANG_HE_AccountId__c=accId,
    		ANG_Risk_Type__c=riskEventTypeId,
    		ANG_Issued_Date__c = reDate
		);

		insert are;

    }

    TestMethod static void testFailAssessmentOneOccurence(){
    	//Fails agency risk assessment with one occurence
    	account acc= [select id from account where name ='acc1' limit 1];		
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.Today());
			system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }

    TestMethod static void testPassAssessmentOneOccurence(){
    	//Passes agency risk assessment with one occurence that needs more to fail
    	account acc= [select id from account where name ='acc1' limit 1];    	
    	Test.startTest();
    		generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id, system.Today());
			system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }


    TestMethod static void testFailAssessmentTwoOccurence(){
    	//Fails agency risk assessment with two occurence needed to fail
    	account acc= [select id from account where name ='acc1' limit 1];
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id, system.Today());
    		generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id, system.Today());
			system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }

    TestMethod static void testPassAssessmentTwoOccurence(){
    	//Passes agency risk assessment with one occurence that needs more occurences to fail and a mixed RE
    	account acc= [select id from account where name ='acc1' limit 1];
    	Test.startTest();
    		generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id, system.Today());
    		generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 3 Mixed'].id, system.Today());
			system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }

    TestMethod static void testFailAssessmentTwoOccurencePlusOneAdjusted(){
    	//fails agency risk assessment due with an adjusted risk event failing a mixed risk event
    	account acc= [select id from account where name ='acc1' limit 1];    	
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id, system.Today());
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 4 Adjusted'].id, system.Today());
	    	generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 3 Mixed'].id, system.Today());	    	
			system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }

    TestMethod static void testFailAssessmentOneOccurenceWithAdjusted(){
    	//fails agency risk assessment due an adjusted risk event
    	account acc= [select id from account where name ='acc1' limit 1]; 	
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 4 Adjusted'].id, system.Today());
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 4 Adjusted'].id, system.Today());
			system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }

    TestMethod static void testFailAssessmentOneAccountPassOther(){
    	//tests assessments for two different accounts in the same process

		IATA_ISO_Country__c country = [Select Id from IATA_ISO_Country__c];

    	list<account> accList = new list<account>();
    	Account acc2 = new Account(
        	name='acc2',
        	Location_Type__c=AMS_Utils.HE,
        	Location_Class__c= AMS_Utils.LC_PASSENGER,
        	Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
        	ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
        	recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = country.Id
        	);
        accList.add(acc2);

        Account acc3 = new Account(
        	name='acc3',
        	Location_Type__c=AMS_Utils.HE,
        	Location_Class__c= AMS_Utils.LC_PASSENGER,
        	Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
        	ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
        	recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = country.Id
        	);
        accList.add(acc3);
    	
        insert accList;

    	list<ANG_Agency_Risk_Event__c> areList= new list<ANG_Agency_Risk_Event__c>();
    	ANG_Agency_Risk_Event__c are1 = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c=acc2.id,
    		ANG_HE_AccountId__c=acc2.id,
    		ANG_Risk_Type__c=[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id,
    		ANG_Issued_Date__c = System.Today()
		);

		areList.add(are1);
		ANG_Agency_Risk_Event__c are2 = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c=acc3.id,
    		ANG_HE_AccountId__c=acc3.id,
    		ANG_Risk_Type__c=[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id,
    		ANG_Issued_Date__c = System.Today()
		);

		areList.add(are2);

		insert areList;

		Test.startTest();
			system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc2' limit 1].ANG_HE_RiskHistoryAssessment__c);
			system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc3' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
    }

    TestMethod static void testUpdateRiskEventAndPassAssessment(){
    	//Fails agency risk assessment with one occurence, after updating RE assessement Passes
    	account acc= [select id from account where name ='acc1' limit 1];		
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.Today());
			system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
			
			ANG_Agency_Risk_Event__c are= [select id,ANG_Event_Status__c from ANG_Agency_Risk_Event__c where ANG_HE_AccountId__c=:acc.id];
			are.ANG_Event_Status__c= ANG_Risk_Helper.STATUS_WITHDRAWN;
			update are;
			system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);

		Test.stopTest();
    }
    TestMethod static void testInsertREnotTriggeringAssessment(){
    	//Passes agency risk assessment with one occurence because assessment shouldnt be runned

		IATA_ISO_Country__c country = [Select Id from IATA_ISO_Country__c];

    	Account acc = new Account(
        	name='acc4',
        	Location_Type__c=AMS_Utils.HE,
        	Location_Class__c= AMS_Utils.LC_PASSENGER,
        	Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
        	ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASHLESS,
        	ANG_HE_RiskHistoryAssessment__c=AMS_Utils.PASSED,
        	recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = country.Id
        	);	

        insert acc;	 
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.Today());
			system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc4' limit 1].ANG_HE_RiskHistoryAssessment__c);
			
		Test.stopTest();
    }

    TestMethod static void testIgnoreAssessmentForTerminatedAccounts(){

		IATA_ISO_Country__c country = [Select Id from IATA_ISO_Country__c];

    	//Ignores assessment for terminated Accounts
    	   	Account acc = new Account(
        	name='acc4',
        	Location_Type__c='HE',
        	Location_Class__c='P',
        	Remittance_frequency__c='M',
        	ANG_Accreditation_Model__c ='Cash',
        	Status__c='Terminated',
        	ANG_HE_RiskHistoryAssessment__c='Passed',
        	recordtypeId=RecordTypeSingleton.getInstance().getRecordTypeID('Account', 'IATA_Agency')
        	);	

        insert acc;	
		Test.startTest();
			generateRiskEvent(acc.id, [select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id, system.Today());
			system.assertEquals('Passed',[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc4' limit 1].ANG_HE_RiskHistoryAssessment__c);
			
		Test.stopTest();
    }

    TestMethod static void testPassForecastAssessment(){
        //Passes agency risk forecast
        account acc= [select id,Remittance_frequency__c,Financial_Review_Result__c,ANG_Accreditation_Model__c, Status__c,ANG_Limit_Cash_Condition__c from account where name ='acc1' limit 1];
     
        map<account,list<ANG_Agency_Risk_Event__c>> forecastMap  = new map<account,list<ANG_Agency_Risk_Event__c>>{acc =>[select ANG_Risk_Type__c,ANG_Limit_Cash_Conditions__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c=:acc.id]};
        Test.startTest();
            system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,new ANG_RiskAssessmentEngine(forecastMap).forecastAssessment().get(0).ANG_HE_RiskHistoryAssessment__c);
        Test.stopTest();
    }

   TestMethod static void testFailedForecastAssessment(){
        //Fails agency risk forecast
        account acc= [select id,Remittance_frequency__c,Financial_Review_Result__c,ANG_Accreditation_Model__c, Status__c,ANG_Limit_Cash_Condition__c from account where name ='acc1' limit 1];
        
        ANG_Risk_Event_Type__c ret=[select id,Limit_Cash_conditions__c from ANG_Risk_Event_Type__c where name= 'Risk Type 2'];
        generateRiskEvent(acc.id,ret.id , system.Today());

        list<ANG_Agency_Risk_Event__c> areList = [select ANG_Risk_Type__c,ANG_Limit_Cash_Conditions__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c=:acc.id];

        areList.add(
                new ANG_Agency_Risk_Event__c(
                    ANG_Risk_Type__c=ret.id,
                    ANG_Limit_Cash_Conditions__c =ret.Limit_Cash_conditions__c
                )
            );

        map<account,list<ANG_Agency_Risk_Event__c>> forecastMap  = new map<account,list<ANG_Agency_Risk_Event__c>>{acc =>areList};
        Test.startTest();
            system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,new ANG_RiskAssessmentEngine(forecastMap).forecastAssessment().get(0).ANG_HE_RiskHistoryAssessment__c);
        Test.stopTest();
    }

    TestMethod static void testFailedForecastAssessmentWithAdjusted(){
        // fails agency risk forecast with adjusted RE
        account acc= [select id,Remittance_frequency__c,Financial_Review_Result__c,ANG_Accreditation_Model__c, Status__c,ANG_Limit_Cash_Condition__c from account where name ='acc1' limit 1];
        
        list<ANG_Risk_Event_Type__c> retList=[select id,Limit_Cash_conditions__c from ANG_Risk_Event_Type__c where name in('Risk Type 2','Risk Type 4 Adjusted') order by name asc];
        generateRiskEvent(acc.id, retList.get(0).id, system.Today());
        generateRiskEvent(acc.id, retList.get(1).id, system.Today());
        generateRiskEvent(acc.id, retList.get(1).id, system.Today());

        list<ANG_Agency_Risk_Event__c> areList =[select ANG_Risk_Type__c,ANG_Limit_Cash_Conditions__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c=:acc.id];
      
        areList.add(
                new ANG_Agency_Risk_Event__c(
                    ANG_Risk_Type__c=retList.get(1).id,
                    ANG_Limit_Cash_Conditions__c =retList.get(1).Limit_Cash_conditions__c
                )
            );
        areList.add(
                new ANG_Agency_Risk_Event__c(
                    ANG_Risk_Type__c=retList.get(1).id,
                    ANG_Limit_Cash_Conditions__c =retList.get(1).Limit_Cash_conditions__c
                )
            );
        map<account,list<ANG_Agency_Risk_Event__c>> forecastMap  = new map<account,list<ANG_Agency_Risk_Event__c>>{acc =>areList};
        Test.startTest();
            system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,new ANG_RiskAssessmentEngine(forecastMap).forecastAssessment().get(0).ANG_HE_RiskHistoryAssessment__c);
        Test.stopTest();
    }
}
