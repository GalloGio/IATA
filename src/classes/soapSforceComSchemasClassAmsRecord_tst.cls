@isTest
private class soapSforceComSchemasClassAmsRecord_tst {
	
	static testMethod void test_declareVariables() {
		soapSforceComSchemasClassAmsRecord.CreateAgency_element elem1 = new soapSforceComSchemasClassAmsRecord.CreateAgency_element();
		soapSforceComSchemasClassAmsRecord.CreateAgencyResponse_element elem2 = new soapSforceComSchemasClassAmsRecord.CreateAgencyResponse_element();
		soapSforceComSchemasClassAmsRecord.CreateLifecycleRequest_element elem3 = new soapSforceComSchemasClassAmsRecord.CreateLifecycleRequest_element();
		soapSforceComSchemasClassAmsRecord.LogInfo elem4 = new soapSforceComSchemasClassAmsRecord.LogInfo();
		soapSforceComSchemasClassAmsRecord.DebuggingInfo_element elem5 = new soapSforceComSchemasClassAmsRecord.DebuggingInfo_element();
		soapSforceComSchemasClassAmsRecord.Address elem6 = new soapSforceComSchemasClassAmsRecord.Address();
		soapSforceComSchemasClassAmsRecord.CreateOwnerPersonResponse_element elem7 = new soapSforceComSchemasClassAmsRecord.CreateOwnerPersonResponse_element();
		soapSforceComSchemasClassAmsRecord.CallOptions_element elem8 = new soapSforceComSchemasClassAmsRecord.CallOptions_element();
		soapSforceComSchemasClassAmsRecord.CreateAddressResponse_element elem9 = new soapSforceComSchemasClassAmsRecord.CreateAddressResponse_element();
		soapSforceComSchemasClassAmsRecord.DebuggingHeader_element elem10 = new soapSforceComSchemasClassAmsRecord.DebuggingHeader_element();
		soapSforceComSchemasClassAmsRecord.CreateOwnerCompany_element elem11 = new soapSforceComSchemasClassAmsRecord.CreateOwnerCompany_element();
		soapSforceComSchemasClassAmsRecord.CreateEmployeeResponse_element elem12 = new soapSforceComSchemasClassAmsRecord.CreateEmployeeResponse_element();
		soapSforceComSchemasClassAmsRecord.CreateOwnerCompanyResponse_element elem13 = new soapSforceComSchemasClassAmsRecord.CreateOwnerCompanyResponse_element();
		soapSforceComSchemasClassAmsRecord.SessionHeader_element elem14 = new soapSforceComSchemasClassAmsRecord.SessionHeader_element();
		soapSforceComSchemasClassAmsRecord.CreateEmployee_element elem15 = new soapSforceComSchemasClassAmsRecord.CreateEmployee_element();
		soapSforceComSchemasClassAmsRecord.CreateLifecycleRequestResponse_element elem16 = new soapSforceComSchemasClassAmsRecord.CreateLifecycleRequestResponse_element();
		soapSforceComSchemasClassAmsRecord.Location elem17 = new soapSforceComSchemasClassAmsRecord.Location();
		soapSforceComSchemasClassAmsRecord.CreateOwnerPerson_element elem18 = new soapSforceComSchemasClassAmsRecord.CreateOwnerPerson_element();
		soapSforceComSchemasClassAmsRecord.AllowFieldTruncationHeader_element elem19 = new soapSforceComSchemasClassAmsRecord.AllowFieldTruncationHeader_element();
		soapSforceComSchemasClassAmsRecord.CreateAddress_element elem20 = new soapSforceComSchemasClassAmsRecord.CreateAddress_element();
	}

	public class recordCreatorMock implements WebServiceMock {

	    private String responseType = 'soapSforceComSchemasClassAmsRecord.';

	    public recordCreatorMock(String className){
	        this.responseType += className;
	    }

	    public void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	        Object responseElement = Type.forName(responseType).newInstance();
	        response.put('response_x', responseElement); 
	   }
	}

    static testMethod void test_callouts() {

    	soapSforceComSchemasClassAmsRecord.AMS_RecordCreatorWebservice request = new soapSforceComSchemasClassAmsRecord.AMS_RecordCreatorWebservice();

    	Test.setMock(WebServiceMock.class, new recordCreatorMock('createEmployeeResponse_element'));
    	request.createEmployee('agencyId','fName','lName','phone','fax','email','address','mobile','position', System.today(),'contactId');


    	Test.setMock(WebServiceMock.class, new recordCreatorMock('createOwnerCompanyResponse_element'));
    	request.createOwnerCompany('legalName','iataCode','agencyId', 0.0, 'ownershipId');


    	Test.setMock(WebServiceMock.class, new recordCreatorMock('createAddressResponse_element'));
    	request.createAddress('address','phone','fax','email','website','countryName','agencyId');


    	Test.setMock(WebServiceMock.class, new recordCreatorMock('createLifecycleRequestResponse_element'));
    	request.createLifecycleRequest('agencyId');


    	Test.setMock(WebServiceMock.class, new recordCreatorMock('createAgencyResponse_element'));
    	request.createAgency('countryName','accountId','recordType','typeOfLocation','companyType','legalName','tradingName','licenseNumber',new List<String>(),'language','site','numberVAT',false,'cargoIATACode');


    	Test.setMock(WebServiceMock.class, new recordCreatorMock('createOwnerPersonResponse_element'));
    	request.createOwnerPerson('agencyId','fName','lName','phone','fax','email','address','mobile','position', System.today(), 0.0,'ownershipId');


    }	
}