@isTest
public class IGOMAccountRoleDetailUtilTest {
	public static final String AIRLINE = IGOMConstants.STATION.TYPE.AIRLINE;
	public static final String GH_HQ = IGOMConstants.STATION.TYPE.GROUND_HANDLER_HQ;

	/**
	 * @description Test the setRecordTypes method when the user needs to have a simulated contact.
	 */
	@isTest
	public static void setRecordTypesTest_GH(){
		// Create accounts
		List<Account> accs = IGOMTestFactory.accountFactoryCreation(20);
		for (Account acc: accs) {
			acc.Category__c = 'Ground Service Provider';
		}
		insert accs;

		// Create account roles
		List<Account_Role__c> accRoles = new List<Account_Role__c>();
		for (Account acc : accs) {
			accRoles.add(IGOMTestFactory.accountRoleFactoryCreation(1, acc.Id).get(0));
		}
		insert accRoles;

		Map<Id, Id> accRolePerAccount = new Map<Id, Id>();
		for(Account_Role__c ar : accRoles){
			accRolePerAccount.put(ar.Account__c, ar.Id);
		}

		// Create account role details
		List<IGOM_Account_Role_Detail__c> accRoleDetails = new List<IGOM_Account_Role_Detail__c>();
		for (Account acc : accs) {
			accRoleDetails.add(IGOMTestFactory.createIGOMAccountRoleDetail(accRolePerAccount.get(acc.Id), null));
		}
		insert accRoleDetails;

		List<Id> accountRoleDetails = new List<Id>();
		Test.startTest();
		accountRoleDetails = IGOMAccountRoleDetailUtil.setRecordTypes(accRoleDetails);
		Test.stopTest();

		List<IGOM_Account_Role_Detail__c> accRoleDetailsNew = [SELECT Id, RecordTypeId FROM IGOM_Account_Role_Detail__c WHERE Id IN :accountRoleDetails];

		Id ghHQRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IGOM_Account_Role_Detail__c', GH_HQ);
		System.assertEquals(20, accRoleDetailsNew.size());
		for (IGOM_Account_Role_Detail__c accRoleDetail : accRoleDetailsNew) {
			System.assertEquals(ghHQRecordTypeId, accRoleDetail.RecordTypeId);
		}
	}

	/**
	 * @description Test the setRecordTypes method when the user needs to have a simulated contact.
	 */
	@isTest
	public static void setRecordTypesTest_Airline(){
		// Create accounts
		List<Account> accs = IGOMTestFactory.accountFactoryCreation(20);
		for (Account acc: accs) {
			acc.Type = 'Bus';
		}
		insert accs;

		// Create account roles
		List<Account_Role__c> accRoles = new List<Account_Role__c>();
		for (Account acc : accs) {
			accRoles.add(IGOMTestFactory.accountRoleFactoryCreation(1, acc.Id).get(0));
		}
		insert accRoles;

		Map<Id, Id> accRolePerAccount = new Map<Id, Id>();
		for(Account_Role__c ar : accRoles){
			accRolePerAccount.put(ar.Account__c, ar.Id);
		}

		// Create account role details
		List<IGOM_Account_Role_Detail__c> accRoleDetails = new List<IGOM_Account_Role_Detail__c>();
		for (Account acc : accs) {
			accRoleDetails.add(IGOMTestFactory.createIGOMAccountRoleDetail(accRolePerAccount.get(acc.Id), null));
		}
		insert accRoleDetails;

		List<Id> accountRoleDetails = new List<Id>();
		Test.startTest();
		accountRoleDetails = IGOMAccountRoleDetailUtil.setRecordTypes(accRoleDetails);
		Test.stopTest();

		List<IGOM_Account_Role_Detail__c> accRoleDetailsNew = [SELECT Id, RecordTypeId FROM IGOM_Account_Role_Detail__c WHERE Id IN :accountRoleDetails];

		Id airlineRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('IGOM_Account_Role_Detail__c', AIRLINE);
		System.assertEquals(20, accRoleDetailsNew.size());
		for (IGOM_Account_Role_Detail__c accRoleDetail : accRoleDetailsNew) {
			System.assertEquals(airlineRecordTypeId, accRoleDetail.RecordTypeId);
		}
	}
}