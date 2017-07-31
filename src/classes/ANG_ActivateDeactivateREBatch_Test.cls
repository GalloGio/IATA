@isTest
	public class ANG_ActivateDeactivateREBatch_Test{

		@testSetup static void testSetup(){

			//isoCountry
			list<IATA_ISO_Country__c> isoCntrList = new list<IATA_ISO_Country__c>();
			IATA_ISO_Country__c isoCntr = new IATA_ISO_Country__c(
					name='Portugal',
					Region__c='Europe', 
					ISO_Code__c='PT'
				);
			isoCntrList.add(isoCntr);
			IATA_ISO_Country__c isoCntr2 = new IATA_ISO_Country__c(
					name='China',
					Region__c='Asia',
					ISO_Code__c='CN'
				);
			isoCntrList.add(isoCntr2);	

			IATA_ISO_Country__c isoCntr3 = new IATA_ISO_Country__c(
					name='United States',
					Region__c='Americas',
					ISO_Code__c='US'
				);
			isoCntrList.add(isoCntr3);

			insert isoCntrList;

			//Account
			list<account> accountList = new list<account>();
			Account acc1= new Account(
				name='Acc1',
				IATA_ISO_Country__c=isoCntr.id,
				Location_Type__c='HE'
				);
			accountList.add(acc1);

			Account acc2= new Account(
				name='Acc2',
				IATA_ISO_Country__c=isoCntr2.id,
				Location_Type__c='HE'
				);
			accountList.add(acc2);

			Account acc3= new Account(
				name='Acc3',
				IATA_ISO_Country__c=isoCntr3.id,
				Location_Type__c='HE'
				);
			accountList.add(acc3);
			
			insert accountList;

			ANG_Risk_Event_Type__c ret = new ANG_Risk_Event_Type__c(
				name='Risk Event Test',
				ANG_Description__c='Risk Event Test',
				ANG_Expiration__c=24,
				ANG_Risk_ID__c='testRiskId'
			);
			insert ret;

			List<ANG_Agency_Risk_Event__c> listAREs = new list<ANG_Agency_Risk_Event__c>();

			ANG_Agency_Risk_Event__c are1= new ANG_Agency_Risk_Event__c(
				ANG_AccountId__c=acc1.id,
				ANG_Risk_Type__c=ret.id,
				ANG_Issued_Date__c =System.today(),
				ANG_Event_Status__c='Inactive'
			);
			listAREs.add(are1); // ARE to be activated

			
			ANG_Agency_Risk_Event__c are2= new ANG_Agency_Risk_Event__c(
				ANG_AccountId__c=acc2.id,
				ANG_Risk_Type__c=ret.id,
				ANG_Issued_Date__c =System.today().addMonths(-1*Integer.ValueOf(ret.ANG_Expiration__c)),
				ANG_Expiration_Date__c =System.today(),
				ANG_Event_Status__c='Active'
			);	
			listAREs.add(are2);// ARE to be deactivated

			ANG_Agency_Risk_Event__c are3= new ANG_Agency_Risk_Event__c(
				ANG_AccountId__c=acc3.id,
				ANG_Risk_Type__c=ret.id, 
				ANG_Issued_Date__c =System.today().addDays(5),
				ANG_Event_Status__c='Inactive'
			);	 
			listAREs.add(are3);// ARE to be ignored

			ANG_RiskEventGenerator.skipStatusAssignment = true;
			insert listAREs;
			ANG_RiskEventGenerator.skipStatusAssignment = false;

		}

	    TestMethod static void testBatch(){ // testing batch 3 records(one to be set active, one to be set inactive, one to ignore)
			
			Test.startTest();
		     	ANG_ActivateDeactivateRiskEventsBatch bat= new ANG_ActivateDeactivateRiskEventsBatch(new list<string>{'\'Europe\'','\'Americas\'','\'Asia\''});
				bat.execute(null);
			test.StopTest();

			ANG_Agency_Risk_Event__c resultRe1 = [select id,ANG_Event_Status__c from ANG_Agency_Risk_Event__c where ANG_AccountId__r.IATA_ISO_Country__r.Region__c='Europe' limit 1].get(0);
			System.assertEquals(resultRe1.ANG_Event_Status__c,'Active','RE1 should be activate');

			ANG_Agency_Risk_Event__c resultRe3 = [select id,ANG_Event_Status__c from ANG_Agency_Risk_Event__c where ANG_AccountId__r.IATA_ISO_Country__r.Region__c='Asia' limit 1].get(0);
			System.assertEquals(resultRe3.ANG_Event_Status__c,'Inactive','RE2 should be inactive');

			ANG_Agency_Risk_Event__c resultRe2 = [select id,ANG_Event_Status__c from ANG_Agency_Risk_Event__c where ANG_AccountId__r.IATA_ISO_Country__r.Region__c='Americas'  limit 1].get(0);
			System.assertEquals(resultRe2.ANG_Event_Status__c,'Inactive','RE3 should be inactive'); 
			
	    }
 
	    TestMethod static void testscheduleEasternRegion(){
	    	//test method to schedule batch for the eastern region to run next week
	    	Test.startTest();
	    	ANG_ActivateDeactivateRiskEventsBatch.scheduleEasternRegion(time.newInstance(18, 0, 0, 0));	
    		test.StopTest();

    		List<AsyncApexJob> joblist =Database.query('select Id from AsyncApexJob where JobType in (\'BatchApexWorker\',\'ScheduledApex\') and status =\'Queued\' and  ApexClass.name =\'ANG_ActivateDeactivateRiskEventsBatch\'');
    		System.assertEquals(1,joblist.size(),'There should be one batch scheduled'); 
			
	    	
	    }

	    TestMethod static void testscheduleWesternRegion(){
	    	//test method to schedule batch for the western region to run on the next day
	    	Test.startTest();
	      	ANG_ActivateDeactivateRiskEventsBatch.scheduleWesternRegion(Null);	   
    		test.StopTest();

    		List<AsyncApexJob> joblist =Database.query('select Id from AsyncApexJob where JobType in (\'BatchApexWorker\',\'ScheduledApex\') and status =\'Queued\' and  ApexClass.name =\'ANG_ActivateDeactivateRiskEventsBatch\'');
    		System.assertEquals(1,joblist.size(),'There should be one batch scheduled'); 
		}	
	    	
	}