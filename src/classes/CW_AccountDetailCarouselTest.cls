/*
 * @author
 * Description: CW_AccountDetailCarouselTest Tests
 */
@isTest
public class CW_AccountDetailCarouselTest {
	/*
	 * Description: case 1 - carrouselOK 100% coverage
	 */
	@isTest
	public static void carrouselOK() {
		IATA_ISO_Country__c isoCode = CW_TestDataFactory.newISOCountry();
		insert isoCode;

		Account acc = CW_TestDataFactory.TestAccount(isoCode.Id);
		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(isoCode.Id, acc.Id);
		insert airport;


		Contact con1 = CW_TestDataFactory.testContact(acc.id);
		insert con1;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(
			acc.Id,
			'Test'
		);
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(
			accRole.Id,
			airport
		);
		insert accRoleDetail;

		final Blob beforeblob = Blob.valueOf('Unit Test Attachment Body');
		final List<ContentVersion> lstCV = new List<ContentVersion>();
		final ContentVersion cv1 = new ContentVersion();
		cv1.PathOnClient = 'test.txt';
		cv1.VersionData = beforeblob;
		cv1.Title = 'test content title';
		cv1.Description = 'test content description';
		lstCV.add(cv1);
		insert lstCV;

		final ContentVersion testContent = [
			SELECT id, ContentDocumentId
			FROM ContentVersion
			WHERE Id = :cv1.Id
		];

		final ContentDocumentLink contentlink = new ContentDocumentLink();
		contentlink.ShareType = 'I';
		contentlink.LinkedEntityId = accRoleDetail.Id;
		contentlink.ContentDocumentId = testcontent.ContentDocumentId;
		contentlink.Visibility = 'AllUsers';
		insert contentlink;

		Test.startTest();
		Boolean devuelveJSON = false;

		List<CW_AccountDetailCarousel.Carousel> lstCar = CW_AccountDetailCarousel.getFacilityFiles(
			accRoleDetail.Id
		);
		if (lstCar != null) {
			devuelveJSON = true;
		}
		System.assert(devuelveJSON, 'communication Ok');
		System.assert(testContent != null, 'ContentVersion Creation Ok');

		CW_AccountDetailCarousel.Carousel currentCar = lstCar[0];
		Map<String, Object> currentCarMap = (Map<String, Object>) JSON.deserializeUntyped(
			JSON.serialize(currentCar)
		);

		System.assertEquals(
			currentCarMap.containsKey('id'),
			true,
			'id property not present'
		);
		System.assertEquals(currentCarMap.get('id'), cv1.id, 'id not expected');

		System.assertEquals(
			currentCarMap.containsKey('fileExtension'),
			true,
			'fileExtension property not present'
		);
		System.assertEquals(
			currentCarMap.get('fileExtension'),
			'txt',
			'fileExtension expected: .txt'
		);

		Test.stopTest();
	}
}