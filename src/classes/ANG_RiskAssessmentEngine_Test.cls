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

        Id OSCARCommunication_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

        list<Case> caseList = new list<Case>();

        Case c1 = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case1', Status = 'Open',
                        AccountId = acc.Id, Description='desc');
        caseList.add(c1);

        Case c2 = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case2', Status = 'Open',
                        AccountId = acc.Id, Description='desc');
        caseList.add(c2);

        Case c3 = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case3', Status = 'Open',
                        AccountId = acc.Id, Description='desc');
        caseList.add(c3);

        insert caseList;
    }
    
    private static void generateRiskEvent(id accId, set<id> riskEventTypeId, Date reDate, List<Case> caseId){
    	String randomInt = String.valueOf(math.rint(math.random()*10));
    	List<ANG_Agency_Risk_Event__c> risksList = new List<ANG_Agency_Risk_Event__c>();
    	Integer i=0;
    	for(id riskType : riskEventTypeId){
    		ANG_Agency_Risk_Event__c are = new ANG_Agency_Risk_Event__c(
	    		ANG_AccountId__c=accId,
	    		ANG_HE_AccountId__c=accId,
	    		ANG_Risk_Type__c=riskType,
	    		ANG_Issued_Date__c = reDate,
	    		ANG_CaseId__c = caseId.get(i).id,
	    		ANG_UniqueKey__c = randomInt
			);
			if(caseId.size()>i){
				i++;
			}
	    	risksList.add(are);
    	}

    	System.debug('Risk event list result : ' + risksList);
		insert risksList;

    }

    TestMethod static void testFailAssessmentOneOccurence(){
    	//Fails agency risk assessment with one occurence
    	account acc= [select id from account where name ='acc1' limit 1];
    	List<case> casetest = [select id from case where AccountId = :acc.id limit 1];	
    	system.debug('susana query testFailAssessmentOneOccurence >> '+[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1']);
		Test.startTest();
			generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1']).keySet() , system.Today(), casetest);
		Test.stopTest();
		system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
    }

    TestMethod static void testPassAssessmentOneOccurence(){
    	//Passes agency risk assessment with one occurence that needs more to fail
    	account acc= [select id from account where name ='acc1' limit 1];    	
    	List<case> casetest = [select id from case where AccountId = :acc.id limit 1];
    	Test.startTest();
    		generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2']).keySet(), system.Today(), casetest);
		Test.stopTest();
		system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
    }


    TestMethod static void testFailAssessmentTwoOccurence(){
    	//Fails agency risk assessment with two occurence needed to fail
    	account acc= [select id from account where name ='acc1' limit 1];
    	List<case> casetest = [select id from case where AccountId = :acc.id];
		Test.startTest();
			generateRiskEvent(acc.id,  new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1' OR name= 'Risk Type 2']).keySet() , system.Today(), new List<Case>(casetest));
    	Test.stopTest();
		system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
	
    }

    TestMethod static void testPassAssessmentTwoOccurence(){
    	//Passes agency risk assessment with one occurence that needs more occurences to fail and a mixed RE
    	account acc= [select id from account where name ='acc1' limit 1];
    	List<case> casetest = [select id from case where AccountId = :acc.id];
    	Test.startTest();
    		generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2' OR name= 'Risk Type 3 Mixed']).keySet(), system.Today(), new List<Case>(casetest));
		Test.stopTest();
		system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
    }

    TestMethod static void testFailAssessmentTwoOccurencePlusOneAdjusted(){
    	//fails agency risk assessment due with an adjusted risk event failing a mixed risk event
    	account acc= [select id from account where name ='acc1' limit 1];   
    	List<case> casetest = [select id from case where AccountId = :acc.id]; 	
		Test.startTest();
			generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2' OR name= 'Risk Type 4 Adjusted' OR name= 'Risk Type 3 Mixed']).keySet(), system.Today(), new List<Case>(casetest));	    	
		Test.stopTest();
		system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
    }

    TestMethod static void testFailAssessmentOneOccurenceWithAdjusted(){
    	//fails agency risk assessment due an adjusted risk event
    	account acc= [select id from account where name ='acc1' limit 1]; 	
    	List<case> casetest = [select id from case where AccountId = :acc.id]; 
		Test.startTest();
			system.debug('let\'s generateRiskEvent');
			generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1' OR name= 'Risk Type 4 Adjusted']).keySet(), system.Today(), new List<Case>(casetest));
		Test.stopTest();
		system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
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

        list<Case> caseList = new list<Case>(); 
        Id OSCARCommunication_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        Case c1 = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case1', Status = 'Open',
                        AccountId = acc2.Id, Description='desc');
        caseList.add(c1);
        Case c2 = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case2', Status = 'Open',
                        AccountId = acc3.Id, Description='desc');
    	caseList.add(c2);
        insert caseList;

    	list<ANG_Agency_Risk_Event__c> areList= new list<ANG_Agency_Risk_Event__c>();
    	ANG_Agency_Risk_Event__c are1 = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c=acc2.id,
    		ANG_HE_AccountId__c=acc2.id,
    		ANG_Risk_Type__c=[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1'].id,
    		ANG_CaseId__c = c1.Id,
    		ANG_Issued_Date__c = System.Today()
		);

		areList.add(are1);
		ANG_Agency_Risk_Event__c are2 = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c=acc3.id,
    		ANG_HE_AccountId__c=acc3.id,
    		ANG_Risk_Type__c=[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id,
    		ANG_CaseId__c = c2.Id,
    		ANG_Issued_Date__c = System.Today()
		);

		areList.add(are2);

		insert areList;

		Test.startTest();
			//system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc2' limit 1].ANG_HE_RiskHistoryAssessment__c);
			//system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc3' limit 1].ANG_HE_RiskHistoryAssessment__c);
		Test.stopTest();
		system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc2' limit 1].ANG_HE_RiskHistoryAssessment__c);
		system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc3' limit 1].ANG_HE_RiskHistoryAssessment__c);
			
    }

    TestMethod static void testUpdateRiskEventAndFailAssessment(){
    	//Fails agency risk assessment with one occurence, after updating RE assessement Passes
    	account acc= [select id from account where name ='acc1' limit 1];	
    	List<Case> casetest = [select id from case where AccountId = :acc.id limit 1]; 	
		Test.startTest();
			generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1']).keySet(), system.Today(), casetest);
		Test.stopTest();

		system.assertEquals(ANG_Risk_Helper.RISK_ASSESSMENT_FAILED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
    }

    TestMethod static void testUpdateRiskEventAndPassAssessment(){
    	//Fails agency risk assessment with one occurence, after updating RE assessement Passes
    	account acc= [select id from account where name ='acc1' limit 1];	

    	Id OSCARCommunication_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');

        Case c1 = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case1', Status = 'Open',
                        AccountId = acc.Id, Description='desc');
        insert c1;

        ANG_Agency_Risk_Event__c are2 = new ANG_Agency_Risk_Event__c(
    		ANG_AccountId__c=acc.id,
    		ANG_HE_AccountId__c=acc.id,
    		ANG_Risk_Type__c=[select id from ANG_Risk_Event_Type__c where name= 'Risk Type 2'].id,
    		ANG_CaseId__c = c1.Id,
    		ANG_Issued_Date__c = System.Today(),
    		ANG_Event_Status__c= ANG_Risk_Helper.STATUS_WITHDRAWN
		);

		insert are2;

		Test.startTest();
		Test.stopTest();
		system.assertEquals(AMS_Utils.PASSED,[select ANG_HE_RiskHistoryAssessment__c from account where name ='acc1' limit 1].ANG_HE_RiskHistoryAssessment__c);
		
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

        Id OSCARCommunication_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        Case cs = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case4', Status = 'Open',
                        AccountId = acc.Id, Description='desc');
        List<Case> c4 = new List<Case>();
        c4.add(cs);
    	insert c4;

		Test.startTest();
			generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1']).keySet(), system.Today(), c4);
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
        	recordtypeId=RecordTypeSingleton.getInstance().getRecordTypeID('Account', 'IATA_Agency'),
			IATA_ISO_Country__c = country.Id
        	);	

        insert acc;	

        Id OSCARCommunication_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
        Case cs = new Case(RecordTypeId = OSCARCommunication_RT_Id, Subject = 'Case4', Status = 'Open',
                        AccountId = acc.Id, Description='desc');
        List<Case> c4 = new List<Case>();
        c4.add(cs);
    	insert c4;

		Test.startTest();
			generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>([select id from ANG_Risk_Event_Type__c where name= 'Risk Type 1']).keySet(), system.Today(), c4);
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
        list<case> casetest = [select id from case where AccountId = :acc.id]; 

        List<ANG_Risk_Event_Type__c> ret=[select id,Limit_Cash_conditions__c from ANG_Risk_Event_Type__c where name= 'Risk Type 2'];
        generateRiskEvent(acc.id, new Map<Id,ANG_Risk_Event_Type__c>(ret).keySet() , system.Today(), casetest);

        list<ANG_Agency_Risk_Event__c> areList = [select ANG_Risk_Type__c,ANG_Limit_Cash_Conditions__c from ANG_Agency_Risk_Event__c where ANG_AccountId__c=:acc.id];

        areList.add(
                new ANG_Agency_Risk_Event__c(
                    ANG_Risk_Type__c= ret.get(0).id,
                    ANG_Limit_Cash_Conditions__c = ret.get(0).Limit_Cash_conditions__c
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
        list<case> casetest = [select id from case where AccountId = :acc.id]; 

        list<ANG_Risk_Event_Type__c> retList=[select id,Limit_Cash_conditions__c from ANG_Risk_Event_Type__c where name in('Risk Type 2','Risk Type 4 Adjusted') order by name asc];
        generateRiskEvent(acc.id,  (new Map<Id,ANG_Risk_Event_Type__c>(retList)).keySet(), system.Today(), casetest);
        
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
