@isTest
public class IfapXmlParserTest {

	private static testmethod void parseReassessmentRequestTest() {
		IfapXmlParser demo = new IfapXmlParser();

		String str ='<?xml version="1.0" ?>'+
			+'<WorkflowIntegrationDictionary xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
			+'<SalesforceCaseNumber>00000002</SalesforceCaseNumber>'
			+'<ReassessmentRejectionReason>Unsatisfactory - New Financial Security</ReassessmentRejectionReason>'
			+'</WorkflowIntegrationDictionary>';

		XmlStreamReader reader = new XmlStreamReader(str);
		IfapXmlParser.ReassessmentRequest ReassessmentRequest = demo.parseReassessmentRequest(reader);
		System.debug(ReassessmentRequest);

	}


	private static testmethod void parseIfapResultTest() {
		IfapXmlParser demo = new IfapXmlParser();

		String str ='<?xml version="1.0" ?>'+
			+'<WorkflowIntegrationDictionary xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
			+'<SalesforceCaseNumber>00000002</SalesforceCaseNumber>'
			+'<File>'
			+'<FileName>MX-P-8653021.pdf</FileName>'
			+'<FileType>FinancialAssessmentResult</FileType>'
			+'</File>'
			+'<GFAStatus>Unsatisfactory - New Financial Security</GFAStatus>'
			+'<FinancialSecurity><Amount>100</Amount><Currency_x>EUR</Currency_x></FinancialSecurity>'
			+'<Error>'
			+'<ErrorCode>0</ErrorCode>'
			+'</Error>'
			+'</WorkflowIntegrationDictionary>';

		XmlStreamReader reader = new XmlStreamReader(str);
		IfapXmlParser.IfapResult ReassessmentRequest = demo.parseIfapResult(reader);
		System.debug(ReassessmentRequest);

	}
	
	private static testmethod void parseIfapResultErrorTest() {
		IfapXmlParser demo = new IfapXmlParser();

		String str ='<?xml version="1.0" ?>'+
			+'<WorkflowIntegrationDictionary xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
			+'<SalesforceCaseNumber>00000002</SalesforceCaseNumber>'
			+'<Error>'
				+'<ErrorCode>1</ErrorCode>'
				+'<ErrorMessage>msg</ErrorMessage>'
			+'</Error>'
			+'</WorkflowIntegrationDictionary>';

		XmlStreamReader reader = new XmlStreamReader(str);
		IfapXmlParser.IfapResult ReassessmentRequest = demo.parseIfapResult(reader);
		System.debug(ReassessmentRequest);

	}
	
	private static testmethod void testClasses() {
		//file
		IfapXmlParser.File file = new IfapXmlParser.File();
		file.setFileName('filename');
		file.setFileType('filetype');
		System.assert(true, file.getFileName() == 'filename');
		System.assert(true, file.getFileType() == 'filetype');

		//error
		IfapXmlParser.Error error = new IfapXmlParser.Error();
		error.setErrorMessage('msg');
		error.setErrorCode('code');
		System.assert(true, error.getErrorMessage() == 'msg');
		System.assert(true, error.getErrorCode() == 'code');

		//FinancialSecurity
		IfapXmlParser.FinancialSecurity financialSecurity = new IfapXmlParser.FinancialSecurity();
		financialSecurity.setAmount('10');
		financialSecurity.setCurrency_x('EUR');
		System.assert(true, financialSecurity.getAmount() == '10');
		System.assert(true, financialSecurity.getCurrency_x() == 'EUR');

		//ifapresult
		IfapXmlParser.IfapResult ifapResult = new IfapXmlParser.IfapResult();
		IfapXmlParser.File[] listfiles = new IfapXmlParser.File[1];
		listFiles[0] = file;
		ifapResult.setFinancialSecurity( null);
		ifapResult.setGFAStatus( 'status');
		ifapResult.setFiles( listFiles);
		ifapResult.setSalesforceCaseNumber( 'caseNumber');
		ifapResult.setError( error);
		
		System.assert(true, ifapResult.getFinancialSecurity() == null);
		System.assert(true, ifapResult.getGFAStatus() == 'status');
		System.assert(true, ifapResult.getFiles().size() == 1);
		System.assert(true, ifapResult.getSalesforceCaseNumber() == 'caseNumber');
		System.assert(true, ifapResult.getError() == error);
		
		//ReassessmentRequest
		IfapXmlParser.ReassessmentRequest reassessmentRequest = new IfapXmlParser.ReassessmentRequest();
		reassessmentRequest.setSalesforceCaseNumber('123456');
		reassessmentRequest.setReassessmentRejectionReason('reason');
		System.assert(true, reassessmentRequest.getSalesforceCaseNumber() == '123456');
		System.assert(true, reassessmentRequest.getReassessmentRejectionReason() == 'reason');
	}

	private static testmethod void parseIfapResultTestFinancialCriteria() {
		IfapXmlParser demo = new IfapXmlParser();

		String str ='<?xml version="1.0" ?>'+
			+'<WorkflowIntegrationDictionary xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
			+'<SalesforceCaseNumber>00000002</SalesforceCaseNumber>'
			+'<File>'
			+'<FileName>MX-P-8653021.pdf</FileName>'
			+'<FileType>FinancialAssessmentResult</FileType>'
			+'</File>'
			+'<GFAStatus>Unsatisfactory - New Financial Security</GFAStatus>'
			+'<FinancialCriteriaTotalScore>100</FinancialCriteriaTotalScore>'
			+'<FinancialSecurity><Amount>100</Amount><Currency_x>EUR</Currency_x></FinancialSecurity>'
			+'<Error>'
			+'<ErrorCode>0</ErrorCode>'
			+'</Error>'
			+'</WorkflowIntegrationDictionary>';

		XmlStreamReader reader = new XmlStreamReader(str);
		IfapXmlParser.IfapResult ReassessmentRequest = demo.parseIfapResult(reader);
		System.debug(ReassessmentRequest);

		System.assertEquals('100',ReassessmentRequest.getFinancialCriteriaTotalScore());

	}
}