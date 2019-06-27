@isTest
private class ANG_RHCCopyRHCForecastBatchTest {

    	@testSetup static void setup(){

            Id devRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'Minimum_RHC_Amount');

            AMS_Settlement_System__c settlement = new AMS_Settlement_System__c (CurrencyIsoCode = 'USD');

            insert settlement;

            IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(ANG_Enable_NewGen__c = true, Name = 'USA', ISO_Code__c = 'US',Region__c = 'Americas', AMS_Settlement_System__c = settlement.id);
            insert ctry;

            AMS_Country_Specific_Attribute__c config = new AMS_Country_Specific_Attribute__c (
                    RecordTypeId = devRecordTypeId,
                    IATA_ISO_Country__c = ctry.id,
                    ANG_Minimum_RHC_Amount__c = 10
                );

            insert config;

            Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

            Map<String,Object> fieldsOfObject;

            fieldsOfObject = new Map<String,Object>();
            fieldsOfObject.put('Name','NewGenAgencyHE');
            fieldsOfObject.put('Short_Name__c','NewGenAgency');
            fieldsOfObject.put('Location_Class__c','P');
            fieldsOfObject.put('Location_Type__c','HE');
            fieldsOfObject.put('Remittance_frequency__c','M');
            fieldsOfObject.put('Sector__C','Travel Agent');
            fieldsOfObject.put('Category__C','IATA Passenger Sales Agent');
            fieldsOfObject.put('Reason_for_creation__c','Account is missing');
            fieldsOfObject.put('Company_Type__c','A');
            fieldsOfObject.put('IATACode__c','1234562');
            fieldsOfObject.put('Status__c','Active');

            Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
            insert acct;
		
            ANG_RHC_Information__c rhcInfo = new ANG_RHC_Information__c(
                ANG_AccountId__c =acct.id,
                CurrencyIsoCode ='USD',
                RecordTypeId = ANG_RHCHelper.RECTYPE_STDRHCINFO,
                ANG_Financial_Security__c=0,
                ANG_RHC_Amount__c = 0,
                ANG_RHC_Amount_Forecasted__c = 100,
                ANG_Forecasted_RHC_Effective_date__c = Date.today(),
                ANG_RME_Amount__c = 500
            );
        
            insert rhcInfo;

            rhcInfo.ANG_RHC_Amount_Forecasted__c = 200;
            update rhcInfo;

        }

	static testMethod void updateRHCTest1() {

        Test.startTest();

		System.assertEquals(0, [Select id, ANG_RHC_Amount__c from ANG_RHC_Information__c].get(0).ANG_RHC_Amount__c);

        Set<String> rhcAccountregionsIn = new Set<String>{'Americas'};

        ANG_RHCCopyRHCForecastBatch rhcForecastBatch = new ANG_RHCCopyRHCForecastBatch(rhcAccountregionsIn);

        Database.executeBatch(rhcForecastBatch,1);

        Test.stopTest();

        System.assertEquals(200, [Select id, ANG_RHC_Amount__c from ANG_RHC_Information__c].get(0).ANG_RHC_Amount__c);

    }

	static testMethod void testscheduleEasternRegion(){
		//test method to schedule batch for the eastern region to run next week
		Test.startTest();
		ANG_RHCCopyRHCForecastBatch.scheduleEasternRegion(time.newInstance(18, 0, 0, 0));	
		test.StopTest();

		List<AsyncApexJob> joblist =Database.query('select Id from AsyncApexJob where JobType in (\'BatchApexWorker\',\'ScheduledApex\') and status =\'Queued\' and  ApexClass.Name =\'ANG_RHCCopyRHCForecastBatch\'');
		System.debug('joblist is:'+joblist);

        System.assertEquals(2,joblist.size(),'There should be just two batches scheduled');
	}

	static testMethod void testscheduleWesternRegion(){
		//test method to schedule batch for the western region to run on the next day
		Test.startTest();
		ANG_RHCCopyRHCForecastBatch.scheduleWesternRegion(null);
		test.StopTest();

		List<AsyncApexJob> joblist =Database.query('select Id from AsyncApexJob where JobType in (\'BatchApexWorker\',\'ScheduledApex\') and status =\'Queued\' and  ApexClass.Name =\'ANG_RHCCopyRHCForecastBatch\'');
        System.debug('joblist is:'+joblist);
        System.assertEquals(2,joblist.size(),'There should be just two batches scheduled');
	}

}