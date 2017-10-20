@isTest
private class AMS_OSCAR_AutomationTest {
	
	static {
		//initilize static variables
	}

	@testSetup static void createData() {
		AMS_OSCAR_TestDataFactory.createOSCARtestData();

		// Added for Step 6 validation
		AMS_Oscar__c oscar = [SELECT Id, Account__c FROM AMS_Oscar__c LIMIT 1];
		Case oscarCase = [SELECT Id, AccountId, Account.Name FROM Case WHERE OSCAR__c = :oscar.Id];
		IATA_ISO_State__c stt = [SELECT Id FROM IATA_ISO_State__c LIMIT 1];
		IATA_ISO_Country__c ctry = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1];

        AMS_Pax_Accreditation_Form__c  accreditationForm = new AMS_Pax_Accreditation_Form__c();
        accreditationForm.RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Pax_Accreditation_Form__c'}).get('AMS_Pax_Accreditation_Form__c').get('GeneralOnlineAccreditation');//accreditationRT.Id;
        accreditationForm.SAAM_Case__c = oscarCase.Id;
        accreditationForm.Account_Name__c = oscarCase.Account.Name;
        accreditationForm.Location_Class__c = 'M';
        accreditationForm.Location_Type__c = 'HO';
        accreditationForm.IATA_ISO_State__c = stt.Id;
        accreditationForm.Branch_Office_Country__c = ctry.Id;
        accreditationForm.Agent_Type__c = 'IATA Cargo Agent';
        insert accreditationForm;

        oscar.AMS_Online_Accreditation__c = accreditationForm.Id;
        oscar.Process__c = AMS_Utils.new_HO;
        update oscar;

        list<AMS_Accreditation_Contact__c> lstAccContacts = new list<AMS_Accreditation_Contact__c>();
        lstAccContacts.add(new AMS_Accreditation_Contact__c());
        lstAccContacts[0].AMS_Pax_Accreditation_Form__c = accreditationForm.Id;
        lstAccContacts[0].RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Accreditation_Contact__c'}).get('AMS_Accreditation_Contact__c').get('Current_Owner');
        lstAccContacts[0].Financial_interest__c = 100;
        lstAccContacts[0].Last_name__c = 'LastName';

        lstAccContacts.add(new AMS_Accreditation_Contact__c());
        lstAccContacts[1].AMS_Pax_Accreditation_Form__c = accreditationForm.Id;
        lstAccContacts[1].RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Accreditation_Contact__c'}).get('AMS_Accreditation_Contact__c').get('Trained_Staff');
        lstAccContacts[1].Financial_interest__c = 100;
        lstAccContacts[1].Last_name__c = 'LastName';
        lstAccContacts[1].Training_dangerous_goods_completed__c = 'Yes';

        lstAccContacts.add(new AMS_Accreditation_Contact__c());
        lstAccContacts[2].AMS_Pax_Accreditation_Form__c = accreditationForm.Id;
        lstAccContacts[2].RecordTypeId = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Accreditation_Contact__c'}).get('AMS_Accreditation_Contact__c').get('Trained_Staff');
        lstAccContacts[2].Financial_interest__c = 100;
        lstAccContacts[2].Last_name__c = 'LastName';
        lstAccContacts[2].Training_dangerous_goods_completed__c = 'Yes';

        insert lstAccContacts;

        // / Step 6 validation
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


		Test.stopTest();

	}

	static testMethod void test_AMS_OSCAR_Automation_increase_coverage() { 
		AMS_Oscar__c oscar = [SELECT Id, Account__c FROM AMS_Oscar__c LIMIT 1];
		AMS_OSCAR_Event__c event = new AMS_OSCAR_Event__c();
		AMS_OSCAR_AutomationManager manager = new AMS_OSCAR_AutomationManager();
		AMS_OSCAR_Automation.IClassFactory factory;

		Test.startTest();


			/*
				Step 07
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step7_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step7_failed');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 205
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step25_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step25_failed');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 16
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step16_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step16_failed');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 29
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step29_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 30
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step30_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step30_failed');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 31
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step31_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step31_failed');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 32
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step32_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step32_failed');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step32_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));


			/*
				Step 35
			*/
			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step35_succeeded');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step35_failed');
			System.assertEquals(true, factory.processWork(event, oscar));

			factory = manager.newClassInstance('AMS_OSCAR_Automation.AMS_OSCAR_Step35_notApplicable');
			System.assertEquals(true, factory.processWork(event, oscar));


		Test.stopTest();

	}
	
}