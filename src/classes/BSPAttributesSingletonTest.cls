@isTest
public class BSPAttributesSingletonTest {

	@TestSetup
	private static void setup(){
		AMS_Settlement_System__c iss01 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-01');
		AMS_Settlement_System__c iss02 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-02');
		AMS_Settlement_System__c iss03 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-03');
		AMS_Settlement_System__c iss04 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-04');
		AMS_Settlement_System__c iss05 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-05');
		AMS_Settlement_System__c iss06 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-06');
		AMS_Settlement_System__c iss07 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-07');
		AMS_Settlement_System__c iss08 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-08');
		AMS_Settlement_System__c iss09 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-09');
		AMS_Settlement_System__c iss10 =AMS_OSCAR_TestDataFactory.createOperationAndItsAttributes('BSP-10');
	}

	@isTest
	private static void getAllBspsAttributes() {
		list<ANG_BSP_Attributes__c> lsAttrs = [SELECT id FROM ANG_BSP_Attributes__c];

		integer iAttr = 0;
		
		test.startTest();
		
		system.assertEquals(0, Limits.getQueries());
		for(AMS_Settlement_System__c bsp:[select id from AMS_Settlement_System__c]){
			BSPAttributesSingleton.getInstance().getRecordTypeId(null, null);
		}
		
		system.assertEquals(1, Limits.getQueries());

		test.stopTest();
		system.assertEquals(iAttr, lsAttrs.size());
	}

	@isTest
	private static void getSingleBSPAttributes() {
	}

	@isTest
	private static void getAllAttributesMatchingRTSingleBSP() {
	}

	@isTest
	private static void getAllAttributesMatchingRTAllBSP() {
	}
}