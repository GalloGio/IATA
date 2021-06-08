@isTest
private class IGOMAttachmentUtilTest
{
	public static final String ACC_TEST_NAME = 'Test Account';
	public static final String ATT_CONTENT_TYPE = 'text/plain';
	public static final String ATT_TEST_NAME = 'Test Attachment';
	public static final String ATT_TEST_BODY = 'Test body for the attachment';

	@TestSetup
	static void makeData(){
		insert new Apex_Setting__c(
			Name='RT valid to reopen attachment trigger',
			Text_1__c='CasesEurope,Cases_Global,CasesAmericas,CasesMENA,ExternalCasesIDFSglobal,Cases_China_North_Asia, ComplaintIDFS,'
			+  'Inter_DPCs,Invoicing_Collection_Cases,Cases_SIS_Help_Desk,InternalCasesEuropeSCE,CS_Process_IDFS_ISS,ID_Card_Application'
			);
	}
	private static final String exampleXMLDoc = '<?xml version="1.0" encoding="utf-8"?><Section1 id="igom-3" permid="igom-permid_0.3353042888060461" xml:lang="en">	<!--This is a mocked-up file for the GAP Analysis application to assess if all the required information is present	Note: The @permid values will not remain, this is only a working file for analysis. 	Once we agree on an XML model, then the @permid will be permanent across Editions -->	<Section1Number>Chapter 3:</Section1Number>	<Section1Heading>Aircraft General Safety/Servicing Operations</Section1Heading>	<Section2 id="igom-3-3.1" permid="igom-permid_0.09462902173770504">		<Section2Number>3.1</Section2Number>		<Section2Heading>Ramp Safety in Aircraft Handling</Section2Heading>		<Section3 id="igom-3-3.1.1" permid="igom-permid_0.6294904593080234">			<Section3Number>3.1.1</Section3Number>			<Section3Heading>Introduction</Section3Heading>		</Section3>		<Section3 id="igom-3-3.1.2" permid="igom-permid_0.9085996764717117">			<Section3Number>3.1.2</Section3Number>			<Section3Heading>General Ramp Safety</Section3Heading>			<Section4 id="igom-3-3.1.2.1" permid="igom-permid_0.2791543240464456" iatareq="yes">				<Section4Number>3.1.2.1</Section4Number>				<Section4Heading>Engine Danger Areas</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.2.2" permid="igom-permid_0.9485939957848422">				<Section4Number>3.1.2.2</Section4Number>				<Section4Heading>Engine Danger Area Diagrams</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.2.3" permid="igom-permid_0.9485939957848423" rev="inserted">				<!--*** IMPORTANT: Because this provision is inserted as 3.1.2.3, 				the next two siblings Section4 must be renumbered 3.1.2.4 and 3.1.2.5 and their @id updated, which is done for validity purposes.				The @permid do not change and this is the mechanism to match the previous Edition with the new one--><Section4Number>3.1.2.3</Section4Number>				<Section4Heading>Engine Danger Area Diagrams</Section4Heading>			</Section4><Section4 id="igom-3-3.1.2.4" permid="igom-permid_0.008944337201748698">				<Section4Number>3.1.2.4</Section4Number>				<Section4Heading>Equipment Restraint Area and Equipment Restraint Line</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.2.5" permid="igom-permid_0.23072966019093089" iatareq="yes">				<Section4Number>3.1.2.5</Section4Number>				<Section4Heading>Foreign Object Debris</Section4Heading>			</Section4>		</Section3>		<Section3 id="igom-3-3.1.3" permid="igom-permid_0.4613772127462904" rev="changed">			<Section3Number>3.1.3</Section3Number>			<Section3Heading>Safety Instructions for Operating Ground Support Equipment on the Ramp</Section3Heading>			<Section4 id="igom-3-3.1.3.1" permid="igom-permid_0.7263469291425035" iatareq="yes">				<Section4Number>3.1.3.1</Section4Number>				<Section4Heading>General Safety Instructions </Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.2" permid="igom-permid_0.6963592082391147" iatareq="yes">				<Section4Number>3.1.3.2</Section4Number>				<Section4Heading>Basic Operating Requirements for Ground Support Equipment  </Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.3" permid="igom-permid_0.8734648459551397">				<Section4Number>3.1.3.3</Section4Number>				<Section4Heading>Non- Motorized Ground Support Equipment </Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.4" permid="igom-permid_0.3687213716865928" iatareq="yes">				<Section4Number>3.1.3.4</Section4Number>				<Section4Heading>Ground Support Equipment Safety Driving and Parking Inside the Equipment Restraint Area  </Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.5" permid="igom-permid_0.08880848691642873">				<Section4Number>3.1.3.5</Section4Number>				<Section4Heading>Passenger Boarding Bridge </Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.6" permid="igom-permid_0.2709749648258717" iatareq="yes">				<Section4Number>3.1.3.6</Section4Number>				<Section4Heading>Passenger Stairs</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.7" permid="igom-permid_0.18574751356988628" iatareq="yes">				<Section4Number>3.1.3.7</Section4Number>				<Section4Heading>Belt Loader</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.8" permid="igom-permid_0.473541510387281" iatareq="yes">				<Section4Number>3.1.3.8</Section4Number>				<Section4Heading>Unit Load Device Loader</Section4Heading>			</Section4>			<!--***IMPORTANT: When an element is deleted, the following sibling must be renumbered!			3.1.3.10 must become 3.1.3.9			3.1.3.11 must become 3.1.3.11			This is not done to demonstrate the complexity of renumbering.-->			<Section4 id="igom-3-3.1.3.9" permid="igom-permid_0.15576692881015153" iatareq="yes" rev="deleted">				<Section4Number>3.1.3.9</Section4Number>				<Section4Heading>Elevating Equipment</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.10" permid="igom-permid_0.12204705525389548" regreq="no" iatareq="yes">				<Section4Number>3.1.3.10</Section4Number>				<Section4Heading>Tractor/Electric Baggage  Tag</Section4Heading>			</Section4>			<Section4 id="igom-3-3.1.3.11" permid="igom-permid_0.6198190670899335">				<Section4Number>3.1.3.11</Section4Number>				<Section4Heading>ULD Transporter</Section4Heading>			</Section4>		</Section3>	</Section2>	<Section2 id="igom-3-3.2" permid="igom-permid_0.8118698323482747">		<Section2Number>3.2</Section2Number>		<Section2Heading>Safety during Fueling/Defueling</Section2Heading>		<Section3 id="igom-3-3.2.1" permid="igom-permid_0.7536208559556861">			<Section3Number>3.2.1</Section3Number>			<Section3Heading>Fueling Safety Zone</Section3Heading>		</Section3>		<Section3 id="igom-3-3.2.2" permid="igom-permid_0.8705956690666813">			<Section3Number>3.2.2</Section3Number>			<Section3Heading>Fuel Spillage</Section3Heading>		</Section3>		<Section3 id="igom-3-3.2.3" permid="igom-permid_0.3808262956177082">			<Section3Number>3.2.3</Section3Number>			<Section3Heading>Fueling/Defueling with Passengers on Board</Section3Heading>		</Section3>	</Section2></Section1>';

	@isTest
	private static void testInvalidDataUpload() {
		Account acc = new Account(Name = ACC_TEST_NAME);
		insert acc;

		System.assertEquals(0, [SELECT Id FROM Attachment].size());

		Test.startTest();

		try {
			Id attachmentId = IGOMAttachmentUtil.saveAttachment(acc.Id, 'Filename', ATT_CONTENT_TYPE, null, '%%==');
			System.assert(false);
		} catch(Exception ex) {
			System.assert(true);
		}

		Test.stopTest();

		System.assertEquals(0, [SELECT Id FROM Attachment].size());
	}

	@isTest
	private static void testSingleUpload() {
		Account acc = new Account(Name = ACC_TEST_NAME);
		insert acc;

		System.assertEquals(0, [SELECT Id FROM Attachment].size());

		Test.startTest();

		Id attachmentId = IGOMAttachmentUtil.saveAttachment(acc.Id, 'Filename', ATT_CONTENT_TYPE, null, EncodingUtil.base64Encode(Blob.valueOf('exampleFile')));

		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, ParentId, Name, ContentType, Body FROM Attachment LIMIT 1];
		System.assertEquals(1, attachments.size());

		System.assertEquals('Filename', attachments[0].Name);
		System.assertEquals(acc.Id, attachments[0].ParentId);
		System.assertEquals(ATT_CONTENT_TYPE, attachments[0].ContentType);
		System.assertEquals(Blob.valueOf('exampleFile'), attachments[0].Body);
	}

	@isTest
	private static void testChunkedUpload() {
		Account acc = new Account(Name = ACC_TEST_NAME);
		insert acc;

		System.assertEquals(0, [SELECT Id FROM Attachment].size());

		Test.startTest();

		String fullFile = EncodingUtil.base64Encode(Blob.valueOf('exampleFile'));

		Id attachmentId = IGOMAttachmentUtil.saveAttachment(acc.Id, 'Filename', ATT_CONTENT_TYPE, null, fullFile.substring(0,8));
		IGOMAttachmentUtil.saveAttachment(acc.Id, 'Filename', ATT_CONTENT_TYPE, attachmentId, fullFile.substring(8));

		Test.stopTest();

		List<Attachment> attachments = [SELECT Id, ParentId, Name, ContentType, Body FROM Attachment LIMIT 1];
		System.assertEquals(1, attachments.size());

		System.assertEquals('Filename', attachments[0].Name);
		System.assertEquals(acc.Id, attachments[0].ParentId);
		System.assertEquals(ATT_CONTENT_TYPE, attachments[0].ContentType);
		System.assertEquals(Blob.valueOf('exampleFile'), attachments[0].Body);
	}

	@isTest
	private static void testDeleteAttachmentOfComplianceReviewPart() {
		Document__c document = IGOMTestFactory.documentFactoryCreation(1, null, 'Example Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM)[0];
		insert document;
		Compliance_Review__c complianceReview = IGOMTestFactory.createComplianceReview(document.Id, null, 'Example Compliance Review');
		insert complianceReview;
		Compliance_Review_Part__c complianceReviewPart = IGOMTestFactory.createComplianceReviewPart(complianceReview.Id, null, document.Id);
		insert complianceReviewPart;
		Attachment attachment = new Attachment(
			Name = ATT_TEST_NAME,
			Body = Blob.valueOf(ATT_TEST_BODY),
			ParentId = complianceReviewPart.Id
		);
		insert attachment;

		System.assertEquals(1, [SELECT Id FROM Attachment].size());

		Test.startTest();

		IGOMAttachmentUtil.deleteAttachment(attachment.Id);

		Test.stopTest();

		System.assertEquals(0, [SELECT Id FROM Attachment].size());
	}

	@isTest
	private static void testDeleteAttachmentOfDocument() {
		Document__c document = IGOMTestFactory.documentFactoryCreation(1, null, 'Example Document', 'English', IGOMConstants.DOCUMENT.RECORD_TYPE.GOM)[0];
		insert document;
		Attachment attachment = new Attachment(
			Name = ATT_TEST_NAME,
			Body = Blob.valueOf(ATT_TEST_BODY),
			ParentId = document.Id
		);
		insert attachment;

		System.assertEquals(1, [SELECT Id FROM Attachment].size());

		Test.startTest();

		IGOMAttachmentUtil.deleteAttachment(attachment.Id);

		Test.stopTest();

		System.assertEquals(0, [SELECT Id FROM Attachment].size());
	}

	@isTest
	private static void testDeleteAttachmentOfAccountError() {
		Account acc = new Account(Name = ACC_TEST_NAME);
		insert acc;
		Attachment attachment = new Attachment(
			Name = ATT_TEST_NAME,
			Body = Blob.valueOf(ATT_TEST_BODY),
			ParentId = acc.Id
		);
		insert attachment;

		System.assertEquals(1, [SELECT Id FROM Attachment].size());

		Test.startTest();

		try {
			IGOMAttachmentUtil.deleteAttachment(attachment.Id);
			System.assert(false);
		} catch (AuraHandledException ex) {
			System.assert(true);
		}

		Test.stopTest();

		System.assertEquals(1, [SELECT Id FROM Attachment].size());
	}

	@isTest
	private static void testDeleteAccountError() {
		Account acc = new Account(Name = ACC_TEST_NAME);
		insert acc;
		Attachment attachment = new Attachment(
			Name = ATT_TEST_NAME,
			Body = Blob.valueOf(ATT_TEST_BODY),
			ParentId = acc.Id
		);
		insert attachment;

		Test.startTest();

		try {
			IGOMAttachmentUtil.deleteAttachment(acc.Id);
			System.assert(false);
		} catch (AuraHandledException ex) {
			System.assert(true);
		}

		Test.stopTest();
	}

	@isTest
	private static void testDuplicateAttachments() {
		Account sourceAcc = new Account(Name = 'Source Account');
		insert sourceAcc;
		Account destinationAcc = new Account(Name = 'Destination Account');
		insert destinationAcc;
		Attachment originalAttachment = new Attachment(
			Name = ATT_TEST_NAME,
			Body = Blob.valueOf(ATT_TEST_BODY),
			ParentId = sourceAcc.Id
		);
		insert originalAttachment;

		System.assertEquals(1, [SELECT Id FROM Attachment].size());

		Test.startTest();

		IGOMAttachmentUtil.duplicateAttachments(new List<Attachment>{ originalAttachment }, new Map<Id, Id>{ sourceAcc.Id => destinationAcc.Id });

		Test.stopTest();

		// Count the attachments
		Map<Id, List<Attachment>> parentIdToAttachments = new Map<Id, List<Attachment>>();
		for (Attachment attachment : [SELECT Id, Name, Body, ParentId FROM Attachment]) {
			List<Attachment> atts = parentIdToAttachments.get(attachment.ParentId);
			if (atts == null) {
				atts = new List<Attachment>();
				parentIdToAttachments.put(attachment.ParentId, atts);
			}
			atts.add(attachment);
		}
		System.assertEquals(parentIdToAttachments.get(sourceAcc.Id).size(), 1);
		System.assertEquals(parentIdToAttachments.get(destinationAcc.Id).size(), 1);
		// Verify the contents
		for (Attachment attachment : parentIdToAttachments.get(destinationAcc.Id)) {
			if (attachment.Name == ATT_TEST_NAME) {
				System.assertEquals(Blob.valueOf(ATT_TEST_BODY), attachment.Body);
			} else {
				System.assert(false);
			}
		}
	}

	// This test won't run due to a SOQL Limit Exception by the trigger NewAttachment
	/*@isTest
	private static void testDuplicateAttachmentsBatch() {
		Account sourceAcc = new Account(Name = 'Source Account');
		insert sourceAcc;
		Account destinationAcc = new Account(Name = 'Destination Account');
		insert destinationAcc;
		List<Attachment> attachments = new List<Attachment>();
		for (Integer i = 0; i < 200; i++) {
			attachments.add(new Attachment(
				Name = i + ' Test Attachment',
				Body = Blob.valueOf(i + ' Test body for the attachment'),
				ParentId = sourceAcc.Id
			));
		}
		insert attachments;

		System.assertEquals(200, [SELECT Id FROM Attachment].size());

		Test.startTest();

		IGOMAttachmentUtil.duplicateAttachments(attachments, new Map<Id, Id>{ sourceAcc.Id => destinationAcc.Id });

		Test.stopTest();

		// Count the attachments
		Map<Id, List<Attachment>> parentIdToAttachments = new Map<Id, List<Attachment>>();
		for (Attachment attachment : [SELECT Id, Name, Body, ParentId FROM Attachment]) {
			List<Attachment> atts = parentIdToAttachments.get(attachment.ParentId);
			if (atts == null) {
				atts = new List<Attachment>();
				parentIdToAttachments.put(attachment.ParentId, atts);
			}
			atts.add(attachment);
		}
		System.assertEquals(parentIdToAttachments.get(sourceAcc.Id).size(), 200);
		System.assertEquals(parentIdToAttachments.get(destinationAcc.Id).size(), 200);
		// Verify the contents
		for (Attachment attachment : parentIdToAttachments.get(destinationAcc.Id)) {
			if (attachment.Name.endsWith(' Test Attachment')) {
				System.assertEquals(Blob.valueOf(attachment.Name.split(' ')[0] + ' Test body for the attachment'), attachment.Body);
			} else {
				System.assert(false);
			}
		}
	}*/

}