@isTest
public class ISSP_ConstantTest {

	public static testMethod void testISSP_ConstantTest() {
		insert new ISSP_CS__c(Name='Test',value__c='Test');
		system.debug(ISSP_Constant.adminIdSet);
		system.debug(ISSP_Constant.customSetingMap);
		system.debug(ISSP_Constant.fiilTopBatch);
		system.debug(ISSP_Constant.NEW_CONTACT_STATUS);
		system.debug(ISSP_Constant.profileIdByProfileNameMap);
		system.debug(ISSP_Constant.profilNameByUserTypeMap);
		system.debug(ISSP_Constant.UserAccountChangeParent);
		system.debug(ISSP_Constant.userTypeByAccountRtDeveloperNameMap);
		system.assertEquals(ISSP_Constant.customSetingMap.get('Test'), 'Test');

	}
}
