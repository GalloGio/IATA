@isTest
public class CNSCaseManagerTest {

	@testSetup
	static void init() {
		Group cnsGroup = [SELECT Id FROM Group WHERE DeveloperName = 'CNS_Collection_Process_Group' LIMIT 1];

		GroupMember gm = new GroupMember(UserOrGroupId = UserInfo.getUserId(),
										 GroupId = cnsGroup.Id);
		insert gm;
	}


	@isTest
	public static void insertCNSCasesTest() {
		User testUser = SidraLiteManagerTest.getCNSUser();
		SidraLiteManagerTest.configureUserToCNS(testUser);

		System.RunAs(testUser) {
			Case cnsCase = SidraLiteManagerTest.createCNSAgent();
			insert cnsCase;

			cnsCase = [SELECT Id, CNSCase__c, Region__c, BSPCountry__c, SAAM_Deadline_Date__c, Origin
					   FROM Case
					   WHERE Id = :cnsCase.Id];

			System.assertEquals(true, cnsCase.CNSCase__c);
			System.assertEquals('Americas', cnsCase.Region__c);
			System.assertEquals('United States', cnsCase.BSPCountry__c);
			//System.assertEquals(Date.today() + 7, cnsCase.SAAM_Deadline_Date__c);
			System.assertEquals('IATA Internal User', cnsCase.Origin);
		}
	}


	@isTest
	public static void updateCNSCases() {
		User testUser = SidraLiteManagerTest.getCNSUser();
		SidraLiteManagerTest.configureUserToCNS(testUser);

		System.RunAs(testUser) {
			Case cnsCase = SidraLiteManagerTest.createCNSAgent();
			insert cnsCase;

			cnsCase.Demand_by_Email_Fax__c = Date.today();
			cnsCase.CS_Contact_Result__c = 'IATA charges';
			update cnsCase;

			cnsCase = [SELECT Id, CS_Rep_Contact_Customer__c
					   FROM Case
					   WHERE Id = :cnsCase.Id];

			System.assertEquals(UserInfo.getUserId(), cnsCase.CS_Rep_Contact_Customer__c);
		}
	}

}
