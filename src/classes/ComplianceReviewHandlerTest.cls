@isTest
public class ComplianceReviewHandlerTest {

	@TestSetup
	static void makeData() {
		IGOMTestFactory.createExampleComplianceReviewData();
	}

	@isTest
	private static void testPublishUpdate_Test() {
		Compliance_Review__c latestPublished = [SELECT Id, Station__c FROM Compliance_Review__c WHERE Is_Latest_Published__c = false LIMIT 1];
		latestPublished.RecordTypeId = [SELECT Id, SobjectType, DeveloperName FROM RecordType WHERE DeveloperName =
										:IGOMConstants.COMPLIANCE_REVIEW.RECORD_TYPE.IGOM AND SobjectType = 'Compliance_Review__c' LIMIT 1].Id;
		latestPublished.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		latestPublished.Is_Latest_Published__c = true;
		Test.startTest();
		update latestPublished;
		Test.stopTest();

		List<Compliance_Review__c> latestPublishedList = [SELECT Id FROM Compliance_Review__c WHERE Is_Latest_Published__c = true AND Station__c = :latestPublished.Station__c];
		System.assertEquals(1, latestPublishedList.size());
		System.assertEquals(latestPublished.Id, latestPublishedList.get(0).Id);
	}

	@isTest
	private static void testPublish_Test() {
		Document__c igomDocument = [SELECT Id FROM Document__c WHERE RecordType.Name = :IGOMConstants.DOCUMENT.RECORD_TYPE.IGOM];
		IGOM_Account_Role_Detail__c station1 = [SELECT Account_Role__c FROM IGOM_Account_Role_Detail__c LIMIT 1];
		Compliance_Review__c newComplianceReview = IGOMTestFactory.createComplianceReview(igomDocument.Id, station1.Account_Role__c, 'Compliance Review 6');
		newComplianceReview.Publish_Status__c = IGOMConstants.COMPLIANCE_REVIEW.STATUS.PUBLISHED;
		newComplianceReview.Is_Latest_Published__c = true;
		Test.startTest();
		insert newComplianceReview;
		Test.stopTest();

		List<Compliance_Review__c> latestPublishedList = [SELECT Id FROM Compliance_Review__c WHERE Is_Latest_Published__c = true AND Station__c = :newComplianceReview.Station__c];
		System.assertEquals(2, latestPublishedList.size());
		Set<Id> gapIds = new Set<Id>();
		for (Compliance_Review__c gap : latestPublishedList) {
			gapIds.add(gap.Id);
		}
		System.assert(gapIds.contains(newComplianceReview.Id));
	}

}
