@isTest
public class IfapXmlGeneratorTest {

/*
		new IfapXmlGenerator.Casexml(cse.CaseNumber),
		new IfapXmlGenerator.FileXml(mergedFileName),
		new IfapXmlGenerator.ReviewType(cse.Financial_Review_Type__c ),
		new IfapXmlGenerator.SubmittedDate(Date.Today())
*/
	private static testMethod void caseXMLTest() {

		Test.startTest();
		try {
			IfapXmlGenerator.Casexml casexml = new IfapXmlGenerator.Casexml(null);
			System.assert(false,'transformationException expected');
		} catch(transformationException e ) {
			System.assert(true,'transformationException expected');
		} catch(Exception e ) {
			System.assert(false,'transformationException expected');
		}

		String casenumber = '12345678';
		IfapXmlGenerator.Casexml casexml = new IfapXmlGenerator.Casexml(casenumber);
		System.assert( true, casexml.getCasexml() == casenumber);
		Test.stopTest();
	}

}
