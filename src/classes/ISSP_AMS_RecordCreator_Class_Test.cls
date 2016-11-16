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
}