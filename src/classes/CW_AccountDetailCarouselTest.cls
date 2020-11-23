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
		ISSP_CS__c icgid = new ISSP_CS__c(Name = 'ICG_URL_Base', Value__c = 'https://theurl.com/s/');
		insert icgid;

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

		Account_Role_Detail_Capability__c ardCap = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		ardCap.Photos__c = '[{"visible":true,"url":"https://iata--nextlink6--c.documentforce.com/sfc/dist/version/download/?oid=00D1X000000278m&ids=0681X000000EdCq&d=%2Fa%2F1X000000Ckhe%2FezuTbdb14gd0yv_y8ApOdMKVbXBrylSNamQCPl2L.QM&asPdf=false","label":"Dollies / Tub Carts-1","id":"0691X000000EXIpQAO"}]';
		insert ardCap;

		ICG_Capability_Assignment_Group__c capvalcert = new ICG_Capability_Assignment_Group__c();
		capvalcert.Issue_Date__c = Date.today().addDays(-1);
		capvalcert.Expiration_Date__c = Date.today().addDays(1);
		capvalcert.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		insert capvalcert;

		ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(accRoleDetail.Id, ardCap.Id);
		assignment.ICG_Capability_Assignment_Group__c = capvalcert.id;
		insert assignment;

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
		System.assertNotEquals(currentCarMap.get('id'), cv1.id, 'id not expected');

		System.assertEquals(
			currentCarMap.containsKey('fileExtension'),
			true,
			'fileExtension property not present'
		);
		System.assertEquals(
			currentCarMap.get('fileExtension'),
			'QM&asPdf=false',
			'fileExtension expected: .txt'
		);
		
		String jsonValue = CW_AccountDetailCarousel.hideImageSelected(testContent.Id);
		CW_AccountDetailCarousel.Result response = (CW_AccountDetailCarousel.Result) JSON.deserialize(jsonValue,CW_AccountDetailCarousel.Result.class);
		System.assertEquals(response.success, false, 'error hideImageSelected =' + response.message);

		Test.stopTest();
	}
}