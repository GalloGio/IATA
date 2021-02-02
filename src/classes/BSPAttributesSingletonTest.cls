@IsTest
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
	private static void getAllBSPAttributes() {
		list<ANG_BSP_Attributes__c> lsAttrs = [SELECT id, BSP__c FROM ANG_BSP_Attributes__c];

		integer iAttr = 0;
		set<id> setBspId = new set<id>();
		for(ANG_BSP_Attributes__c attr:lsAttrs) setBspId.add(attr.BSP__c);

		test.startTest();
		system.assertEquals(0, Limits.getQueries());
		for(id bspId:setBspId){
			list<ANG_BSP_Attributes__c> ls = BSPAttributesSingleton.getInstance().getAllBSPAttributes(bspId);
			iAttr = iAttr + ls.size();
		}
		
		system.assertEquals(1, Limits.getQueries());

		test.stopTest();
		system.assertEquals(iAttr, lsAttrs.size());
	}

	@isTest
	private static void getAllBSPAttributesByRecordtype() {
		AMS_Settlement_System__c BSP = [select id from AMS_Settlement_System__c limit 1];

		test.startTest();
		system.assertEquals(0, Limits.getQueries());
		
		list<ANG_BSP_Attributes__c> ls = BSPAttributesSingleton.getInstance(new set<id>{BSP.Id}, new set<string>{'Cash_Condition_Conf'}).getAllBSPAttributesByRecordtype(bsp.Id, new set<string>{'Cash_Condition_Conf'});
		system.debug('DT ls ' + ls);
		
		system.assertEquals(1, Limits.getQueries());

		system.assertNotEquals(0, ls.Size());

		test.stopTest();
	}

	@isTest
	private static void getSingleBSPAttributeByUniqueId() {
		ANG_BSP_Attributes__c attr = [select id, BSP__C, UniqueKey__c from ANG_BSP_Attributes__c limit 1];

		test.startTest();
		system.assertEquals(0, Limits.getQueries());
		
		ANG_BSP_Attributes__c theRetrievedAttr = BSPAttributesSingleton.getInstance(new set<id>{attr.bsp__c}).getSingleBSPAttributeByUniqueId(attr.bsp__c, attr.UniqueKey__c);
		
		system.assertEquals(1, Limits.getQueries());

		system.assertEquals(theRetrievedAttr.id, attr.Id);

		test.stopTest();
	}

	@isTest
	private static void getBSPFullMap() {
		set<id> setBSPIds = new set<id>();
		for(AMS_Settlement_System__c BSP:[select id from AMS_Settlement_System__c]) setBSPIds.add(bsp.id);

		BSPAttributesSingleton BSPAttrST = BSPAttributesSingleton.getInstance(setBSPIds, new set<string>{'RHC_Amount_Conf', 'Cash_Condition_Conf'});

		test.startTest();
		system.assertEquals(0, Limits.getQueries());
		for(id BSP:setBSPIds){
			map<string, ANG_BSP_Attributes__c> mapAttrsBSP = BSPAttrST.getFullBSPMap(bsp);
			system.assertNotEquals(0, mapAttrsBSP.size());
		}
		system.assertEquals(0, Limits.getQueries());
		test.StopTest();
	}
}