@isTest
public with sharing class ISSP_AMS_RecordCreator_Class_Test {
	public static testMethod void testMyController(){
		ISSP_AMS_RecordCreator_Class ca = new ISSP_AMS_RecordCreator_Class ();
		ISSP_AMS_RecordCreator_Class.DebuggingInfo_element DebuggingInfo = new ISSP_AMS_RecordCreator_Class.DebuggingInfo_element();
		ISSP_AMS_RecordCreator_Class.LogInfo LogInfo = new ISSP_AMS_RecordCreator_Class.LogInfo();
		ISSP_AMS_RecordCreator_Class.Address Address = new ISSP_AMS_RecordCreator_Class.Address();
		ISSP_AMS_RecordCreator_Class.CallOptions_element CallOptions_element = new ISSP_AMS_RecordCreator_Class.CallOptions_element();
		ISSP_AMS_RecordCreator_Class.DebuggingHeader_element DebuggingHeader_element = new ISSP_AMS_RecordCreator_Class.DebuggingHeader_element();
		ISSP_AMS_RecordCreator_Class.AccountChanges AccountChanges = new ISSP_AMS_RecordCreator_Class.AccountChanges();
		ISSP_AMS_RecordCreator_Class.createAccreditationResponse_element createAccreditationResponse_element = new ISSP_AMS_RecordCreator_Class.createAccreditationResponse_element();
		ISSP_AMS_RecordCreator_Class.SessionHeader_element SessionHeader_element = new ISSP_AMS_RecordCreator_Class.SessionHeader_element();
		ISSP_AMS_RecordCreator_Class.createMinorChangesChangeCode_element createMinorChangesChangeCode_element = new ISSP_AMS_RecordCreator_Class.createMinorChangesChangeCode_element();
		ISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_element createMinorChangesChangeCodeResponse_element = new ISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_element();
		ISSP_AMS_RecordCreator_Class.location location = new ISSP_AMS_RecordCreator_Class.location();
		ISSP_AMS_RecordCreator_Class.AllowFieldTruncationHeader_element AllowFieldTruncationHeader_element = new ISSP_AMS_RecordCreator_Class.AllowFieldTruncationHeader_element();
		ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice AMS_RecordCreatorWebservice = new ISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice();

		
		try {
			AMS_RecordCreatorWebservice.createAccreditation(null,null,null,null);
		}

		catch (Exception e) {

		}

try {
			AMS_RecordCreatorWebservice.createMinorChangesChangeCode(null,null);
		}

		catch (Exception e) {
			
		}

		DebuggingInfo.debugLog = 'test';
		LogInfo.category = 'test';
		Address.city = 'test';
	}

	public static testMethod void testMyController_async(){
		AsyncISSP_AMS_RecordCreator_Class.AsyncAMS_RecordCreatorWebservice ca = new AsyncISSP_AMS_RecordCreator_Class.AsyncAMS_RecordCreatorWebservice();

		System.Continuation conti = new System.Continuation(60);
		conti.continuationMethod = 'processResponse';

		//AsyncISSP_AMS_RecordCreator_Class.DebuggingInfo_element DebuggingInfo = new AsyncISSP_AMS_RecordCreator_Class.DebuggingInfo_element();
		//AsyncISSP_AMS_RecordCreator_Class.LogInfo LogInfo = new AsyncISSP_AMS_RecordCreator_Class.LogInfo();
		//AsyncISSP_AMS_RecordCreator_Class.Address Address = new AsyncISSP_AMS_RecordCreator_Class.Address();
		//AsyncISSP_AMS_RecordCreator_Class.CallOptions_element CallOptions_element = new AsyncISSP_AMS_RecordCreator_Class.CallOptions_element();
		//AsyncISSP_AMS_RecordCreator_Class.DebuggingHeader_element DebuggingHeader_element = new AsyncISSP_AMS_RecordCreator_Class.DebuggingHeader_element();
		//AsyncISSP_AMS_RecordCreator_Class.AccountChanges AccountChanges = new AsyncISSP_AMS_RecordCreator_Class.AccountChanges();
		//AsyncISSP_AMS_RecordCreator_Class.createAccreditationResponse_element createAccreditationResponse_element = new AsyncISSP_AMS_RecordCreator_Class.createAccreditationResponse_element();
		//AsyncISSP_AMS_RecordCreator_Class.SessionHeader_element SessionHeader_element = new AsyncISSP_AMS_RecordCreator_Class.SessionHeader_element();
		//AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCode_element createMinorChangesChangeCode_element = new AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCode_element();
		//AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_element createMinorChangesChangeCodeResponse_element = new AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_element();
		//AsyncISSP_AMS_RecordCreator_Class.location location = new AsyncISSP_AMS_RecordCreator_Class.location();
		//AsyncISSP_AMS_RecordCreator_Class.AllowFieldTruncationHeader_element AllowFieldTruncationHeader_element = new AsyncISSP_AMS_RecordCreator_Class.AllowFieldTruncationHeader_element();
		//AsyncISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice AMS_RecordCreatorWebservice = new AsyncISSP_AMS_RecordCreator_Class.AMS_RecordCreatorWebservice();

		
		try {
			AsyncISSP_AMS_RecordCreator_Class.createAccreditationResponse_elementFuture var1 = 
		   			ca.beginCreateAccreditation(conti,
		   										'accountId',
		   										'accreditationId',
		   										'NEW.HO',
		   										'caseId');
		}

		catch (Exception e) {

		}

		try {
			ISSP_AMS_RecordCreator_Class.AccountChanges[] accountChanges = null;
			AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_elementFuture var2 = 
		   			ca.beginCreateMinorChangesChangeCode(conti,'accountId',accountChanges);
            
		}

		catch (Exception e) {
			
		}

		try {
		AsyncISSP_AMS_RecordCreator_Class.createAccreditationResponse_elementFuture ca2 = new AsyncISSP_AMS_RecordCreator_Class.createAccreditationResponse_elementFuture();
		string s1 = ca2.getValue();
		}

		catch (Exception e) {
			
		}

		try {
		AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_elementFuture ca3 = new AsyncISSP_AMS_RecordCreator_Class.createMinorChangesChangeCodeResponse_elementFuture();
		ca3.getValue();
		}

		catch (Exception e) {
			
		}
    }
    
}