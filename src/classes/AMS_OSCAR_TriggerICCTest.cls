@isTest
private class AMS_OSCAR_TriggerICCTest {
	
	@isTest static void test_ICC_01() {
	    IATA_ISO_Country__c country  = new IATA_ISO_Country__c(
	      Name = 'Portugal',
	      ISO_Code__c = 'PT',
	      AIMS_Area_Name__c = 'Lisboa',
	      Region__c = 'Americas'
	    );

	    insert country;

	    Account account = new Account(
	            Name = 'Test Account',
	            BillingCity = 'Lisboa',
	            Sector__c = 'Travel Agent',
	            Location_Type__c = 'HO',
	            Location_Class__c = 'C',
	            Status__c = 'Approved',
	            Company_Type__c = 'A',
	            IATACode__c = '100',
	            IATA_ISO_Country__c = country.Id,
	            RecordTypeId = Schema.SObjectType.Account.RecordTypeInfosByName.get('Agency').RecordTypeId
	    );

	    insert account;

	    List<AMS_OSCAR__c> oscarList = new List<AMS_OSCAR__c>{
	        new AMS_Oscar__c(
	            Name = 'Test Oscar 1',
	            Account__c = account.Id,
	            STEP1__c = 'In Progress'
	        ),
	        new AMS_Oscar__c(
	            Name = 'Test Oscar 2',
	            Account__c = account.Id,
	            AML_result__c = 'In Progress'
	        ),
	        new AMS_Oscar__c(
	            Name = 'Test Oscar 3',
	            Account__c = account.Id,
	            STEP2__c = 'In Progress',
	            AML_result__c = 'In Progress'
	        ),
	        new AMS_Oscar__c(
	            Name = 'Test Oscar 4',
	            Account__c = account.Id,
	            STEP2__c = 'In Progress',
	            STEP6__c = 'In Progress',
	            AML_result__c = 'In Progress',
	            RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId()
	        ),
	        new AMS_Oscar__c(
	            Name = 'Test Oscar 5',
	            Account__c = account.Id,
	            STEP2__c = 'In Progress',
	            STEP6__c = 'In Progress',
	            AML_result__c = 'In Progress',
	            RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId()
	        ),
	      new AMS_Oscar__c(
	            Name = 'Test Oscar 6',
	            Account__c = account.Id,
	            STEP2__c = 'In Progress',
	            STEP6__c = 'In Progress',
	            AML_result__c = 'In Progress',
	            RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId(),
	            Apply_Penalty_Fee__c = false
	        )
	    };

	    List<AMS_OSCAR_HistoryFields__c> cs = new List<AMS_OSCAR_HistoryFields__c> {
	        new AMS_OSCAR_HistoryFields__c(
	            Name = 'STEP1__c',
	            HasExternalLabel__c = true,
	            FieldName__c = 'STEP1__c'
	        ),
	        new AMS_OSCAR_HistoryFields__c(
	            Name = 'AML_result__c',
	            HasExternalLabel__c = false,
	            FieldName__c = 'AML_result__c'
	        )
	    };

	    insert cs;

	    insert oscarList;

	    oscarList[0].First_Step_Completed__c = true;
	    oscarList[0].STEP1__c = 'Passed';

	    oscarList[1].First_Step_Completed__c = true;
	    oscarList[1].AML_result__c = 'Passed';

	    oscarList[2].First_Step_Completed__c = true;
	    oscarList[2].STEP2__c = 'Failed';
	    oscarList[2].RPM_Approval__c = 'Authorize Disapproval';
	    oscarList[2].RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('NEW').getRecordTypeId();
	    
	    oscarList[3].First_Step_Completed__c = true;
	    oscarList[3].STEP6__c = 'Passed';
	    oscarList[3].RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
	    oscarList[3].AMS_Correction_change_code__c = 'COR';

	    oscarList[4].First_Step_Completed__c = true;
	    oscarList[4].STEP6__c = 'Passed';
	    oscarList[4].RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
	    oscarList[4].AMS_Correction_change_code__c = 'CAD';

	    oscarList[5].First_Step_Completed__c = true;
	    oscarList[5].STEP6__c = 'Passed';
	    oscarList[5].RecordTypeId = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('CORRECTION').getRecordTypeId();
	    oscarList[5].AMS_Correction_change_code__c = 'LET';
	    oscarList[5].Apply_Penalty_Fee__c = true;
	    oscarList[5].Type_of_change__c = 'Location';

	    Test.startTest();

	    update oscarList;

	    Test.stopTest();
	}
	
}