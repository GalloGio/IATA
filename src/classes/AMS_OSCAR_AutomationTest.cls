@isTest
private class AMS_OSCAR_AutomationTest {
	
	static {
		//initilize static variables
	}

	@testSetup static void createData() {
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
	}
	
	static testMethod void test_AMS_OSCAR_Automation() {
		AMS_Oscar__c oscar = [SELECT Id, Account__c FROM AMS_Oscar__c LIMIT 1];
		AMS_OSCAR_Event__c event = new AMS_OSCAR_Event__c();
		AMS_OSCAR_AutomationManager manager = new AMS_OSCAR_AutomationManager();
		AMS_OSCAR_Automation.IClassFactory factory;

		Test.startTest();


			/*
				Step 06
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step6_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Sanity_check_results__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step6_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Sanity_check_results__c);


			/*
				Step 08
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step8_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('In Progress', oscar.STEP9__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step8_inProgress');
			System.assertEquals(true, factory.processWork(event, oscar));
     

			/*
				Step 09
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step9_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Paid', oscar.Invoice_status__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step9_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Outstanding', oscar.Invoice_status__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step9_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Invoice_status__c);


			/*
				Step 11
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step11_inProgress');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals(Date.today(), oscar.Financial_Assessment_requested__c);


			/*
				Step 12
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step12_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Valid', oscar.Financial_security_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step12_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Rejected', oscar.Financial_security_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step12_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Financial_security_result__c);


			/*
				Step 13
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step13_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Local_Inspection_compliant__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step13_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Local_Inspection_compliant__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step13_inProgress');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals(Date.today(), oscar.Local_Inspection_requested__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step13_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Local_Inspection_compliant__c);


			/*
				Step 14
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step14_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Agreement_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step14_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Agreement_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step14_inProgress');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals(Date.today(), oscar.Agreement_requested__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step14_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Agreement_result__c);


			/*
				Step 10
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step10_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals(DateTime.now(), oscar.AIMS_updated__c);


			/*
				Step 15
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step15_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Validation_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step15_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Validation_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step15_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Validation_result__c);


			/*
				Step 02
			*/
			oscar.STEP15__c = 'Passed';
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step2_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('On Hold_Internal', oscar.Status__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step2_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('On Hold_Internal', oscar.Status__c);


			/*
				Step 01
			*/
			oscar.STEP2__c = 'Passed';
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step1_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Finalization_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step1_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Finalization_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step1_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Finalization_result__c);


			/*
				Step 03
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step3_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Disapproval_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step3_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Disapproval_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step3_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Disapproval_result__c);


			/*
				Step 04
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step4_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Withdrawal_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step4_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Withdrawal_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step4_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Withdrawal_result__c);


			/*
				Step 05
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step5_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Reconsideration_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step5_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Reconsideration_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step5_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Reconsideration_result__c);


			/*
				Step 20
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step20_inProgress');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals(Date.today(), oscar.Fees_refund_requested__c);


			/*
				Step 23
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step23_inProgress');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals(Date.today(), oscar.Fees_refund_requested__c);


			/*
				Step 21
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step21_succeeded');
			System.assertEquals(false, factory.processWork(event, oscar));


			/*
				Step 17
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step17_succeeded');
			System.assertEquals(false, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.AML_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step17_failed');
			System.assertEquals(false, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.AML_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step17_inProgress');
			System.assertEquals(false, factory.processWork(event, oscar));
			System.assertEquals(Date.today(), oscar.AML_requested__c);


			/*
				Step 18
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step18_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Rejection_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step18_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Rejection_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step18_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Rejection_result__c);
        
        
        	/*
        		Step 16
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step16_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Finalization_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step16_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Finalization_result__c);

			/*
				Step 41
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step41_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.IRIS_update_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step41_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.IRIS_update_result__c);

			/*
				Step 42
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step42_failed');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Finalization_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step42_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Finalization_result__c);



			/*
        		Step 07
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step7_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.IRIS_update_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step7_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.IRIS_update_result__c);


			/*
        		Step 30
        	*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step30_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Suspension_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step30_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Suspension_result__c);


			/*
        		Step 31
        	*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step31_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Termination_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step31_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Termination_result__c);


			/*
        		Step 32
        	*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step32_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Passed', oscar.Withdrawal_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step32_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Withdrawal_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step32_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Withdrawal_result__c);


			/*
        		Step 35
        	*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step35_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Valid', oscar.Financial_security_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step35_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Rejected', oscar.Financial_security_result__c);

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step35_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('N/A', oscar.Financial_security_result__c);


        	/*
        		Step 25
        	*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step25_succeeded');
        	oscar.STEP12__c = AMS_Utils.PASSED;
        	System.assertEquals(true, factory.processWork(event, oscar));	
        	System.assertEquals('Passed', oscar.Validation_result__c);
        	System.assertEquals('Pending Approval', oscar.Status__c);
        	oscar.STEP12__c = AMS_Utils.NOT_APPLICABLE;
        	System.assertEquals(true, factory.processWork(event, oscar));	
       		System.assertEquals('Passed', oscar.Validation_result__c);
        	System.assertEquals('Pending Approval', oscar.Status__c);
            try{
                oscar.STEP12__c = AMS_Utils.FAILED;
                System.assertEquals(false, factory.processWork(event, oscar));
                oscar.STEP12__c = AMS_Utils.IN_PROGRESS;
                System.assertEquals(false, factory.processWork(event, oscar));
            }
            catch(Exception ex){
                Boolean exceptionThrown;
                if(oscar.STEP12__c == AMS_Utils.FAILED)
            		exceptionThrown =  ex.getMessage().contains('Validation can\'t be Passed when Manage Financial Security step is Failed.') ? true : false;
				else if(oscar.STEP12__c == AMS_Utils.IN_PROGRESS)
                    exceptionThrown =  ex.getMessage().contains('Validation can only be Passed if Manage Financial Security step is Not Applicable or Passed.') ? true : false;
                System.assertEquals(exceptionThrown, true);
        	}

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step25_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
			System.assertEquals('Failed', oscar.Validation_result__c);
        	System.assertEquals('On Hold_Internal', oscar.Status__c);
        
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step25_inProgress');
        	System.assertEquals(true, factory.processWork(event, oscar));
			try{
                oscar.STEP12__c = AMS_Utils.FAILED;
                System.assertEquals(false, factory.processWork(event, oscar));
            }
            catch(Exception ex){
                Boolean exceptionThrown =  ex.getMessage().contains('Validation can only be Failed when Manage Financial Security step is Failed.') ? true : false; 
				oscar.Apply_Penalty_Fee__c = false;
                System.assertEquals(exceptionThrown, true);
                oscar.Apply_Penalty_Fee__c = true;
                System.assertEquals(exceptionThrown, false);
        	}
        	
        
        	/*
        	 	Step 29 
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step29_succeeded');
        	System.assertEquals(true, factory.processWork(event, oscar));
        	oscar.Apply_Penalty_Fee__c = true;
        	System.assertEquals(false, factory.processWork(event, oscar));

        
        	/*
        	 	Step 46 
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step46_passed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        
        	
        	/*
        	 	Step 47
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step47_passed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        	System.assertEquals(AMS_Utils.IN_PROGRESS, oscar.STEP48__c);
        
        
        	/*
        	 	Step 48
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step48_passed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        	System.assertEquals('Paid', oscar.Invoice_status__c);
        
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step48_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        	System.assertEquals('Outstanding', oscar.Invoice_status__c);
        
       		factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step48_notApplicable');
        	System.assertEquals(true, factory.processWork(event, oscar));
        	System.assertEquals('N/A', oscar.Invoice_status__c);
        
        
        	/*
        	 	Step 49
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step49_passed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        
        
        	/*
        	 	Step 50
        	*/
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step50_passed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        
        	factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step50_failed');
        	System.assertEquals(true, factory.processWork(event, oscar));
        
		Test.stopTest();

	}
	
}
