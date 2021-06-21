/*
 * @author
 * Description: CW_AccountDetailCertificationList Tests
 */
@IsTest
private class CW_AccountDetailCertificationListTest {
	/*
		Test Setup: 
	*/
	@testSetup
	public static void setup() {
		Account accOne = new Account(Name = 'Test testersen');
		Account accTwo = new Account(Name = 'Test testersen 2');
		insert new List<Account>{ accOne, accTwo };

		Account_Role__c accRoleOne = new Account_Role__c(Account__c = accOne.Id);
		Account_Role__c accRoleTwo = new Account_Role__c(Account__c = accTwo.Id);
		insert new List<Account_Role__c>{ accRoleOne, accRoleTwo };

		ICG_Account_Role_Detail__c accRoleDetailOne = new ICG_Account_Role_Detail__c(name = accOne.name, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Airline'), Account_Role__c = accRoleOne.Id);
		ICG_Account_Role_Detail__c accRoleDetailTwo = new ICG_Account_Role_Detail__c(name = accTwo.name, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ICG_Account_Role_Detail__c', 'Airline'), Account_Role__c = accRoleTwo.Id);
		insert new List<ICG_Account_Role_Detail__c>{ accRoleDetailOne, accRoleDetailTwo };

		ICG_Certification__c certOne = CW_TestDataFactory.newCertification();
		certOne.is_visible__C = true;
		certOne.Name = 'TestCert';
		certOne.Applicable_to__c = 'Airline';
		certOne.ValidationPrograms__c = 'IATA';

		ICG_Certification__c certTwo = CW_TestDataFactory.newCertification();
		certTwo.is_visible__C = true;
		certTwo.Name = 'TestCert2';
		certTwo.Applicable_to__c = 'Airline';
		certOne.ValidationPrograms__c = 'IATA';

		insert new List<ICG_Certification__c>{ certOne, certTwo };

		ICG_Capability_Assignment_Group__c certDetailOne = new ICG_Capability_Assignment_Group__c(ICG_Certification__r = certOne, ICG_Account_Role_Detail__r = accRoleDetailOne, ICG_Account_Role_Detail__c = accRoleDetailOne.id, ICG_Certification__c = certOne.Id, Expiration_Date__c = Date.newInstance(2020, 12, 31), Issue_Date__c = Date.newInstance(2020, 10, 31));

		insert new List<ICG_Capability_Assignment_Group__c>{ certDetailOne };
	}
	/*
	 * @author
	 * Description: case 1 - Account with certifications associated
	 */
	@IsTest
	static void testCertificationList() {
		ICG_Account_Role_Detail__c acc = [SELECT Id, Name, RecordType.DeveloperName FROM ICG_Account_Role_Detail__c WHERE Name = 'Test testersen'];
		Map<Boolean, List<CW_AccountDetailCertificationList.wrapperCert>> resultMap = CW_AccountDetailCertificationList.getCertificationList(acc.Id, acc.RecordType.DeveloperName);
		List<CW_AccountDetailCertificationList.wrapperCert> certList = resultMap.get(false);
		System.assertEquals('Airline', acc.RecordType.DeveloperName, 'Account rt incorrect');
		System.assertEquals(1, resultMap.keyset().size(), 'The amount of keys in the map is incorrect' + resultMap.keySet().size());
		System.assertEquals('TestCert', certList[0].Name, 'The certification is incorrect' + certList[0].Name);
	}

	/*
	 * @author
	 * Description: case 2 - Account without any certifications associated
	 */
	@IsTest
	static void testCertificationListShouldBeAllFalse() {
		ICG_Account_Role_Detail__c acc = [SELECT Id, Name, Recordtype.DeveloperName FROM ICG_Account_Role_Detail__c WHERE Name = 'Test testersen 2'];
		Map<Boolean, List<CW_AccountDetailCertificationList.wrapperCert>> resultMap = CW_AccountDetailCertificationList.getCertificationList(acc.Id, acc.RecordType.DeveloperName);
		List<CW_AccountDetailCertificationList.wrapperCert> certList = resultMap.get(false);

		System.assertEquals(1, resultMap.keySet().size(), 'The amount of keys in the map is incorrect' + resultMap.keySet().size());
		System.assertEquals(2, certList.size(), 'The amount of false certifications is incorrect' + certList.size());
	}
}