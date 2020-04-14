public with sharing class MetadataService {

	public static String SOAP_M_URI = 'http://soap.sforce.com/2006/04/metadata';

	public virtual class Metadata {
		public String fullName;
	}

	public class NamedCredential extends Metadata {
		public String type = 'NamedCredential';
		public String fullName;
		private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'0','1','false'};
		public Boolean allowMergeFieldsInBody;
		public Boolean allowMergeFieldsInHeader;
		public String authProvider;
		public String certificate;
		public String endpoint;
		public Boolean generateAuthorizationHeader;
		public String label;
		public String oauthRefreshToken;
		public String oauthScope;
		public String oauthToken;
		public String password;
		public String principalType;
		public String protocol;
		public String username;
		private String[] allowMergeFieldsInBody_type_info = new String[]{'allowMergeFieldsInBody',SOAP_M_URI,null,'0','1','false'};
		private String[] allowMergeFieldsInHeader_type_info = new String[]{'allowMergeFieldsInHeader',SOAP_M_URI,null,'0','1','false'};
		private String[] authProvider_type_info = new String[]{'authProvider',SOAP_M_URI,null,'0','1','false'};
		private String[] certificate_type_info = new String[]{'certificate',SOAP_M_URI,null,'0','1','false'};
		private String[] endpoint_type_info = new String[]{'endpoint',SOAP_M_URI,null,'0','1','false'};
		private String[] generateAuthorizationHeader_type_info = new String[]{'generateAuthorizationHeader',SOAP_M_URI,null,'0','1','false'};
		private String[] label_type_info = new String[]{'label',SOAP_M_URI,null,'1','1','false'};
		private String[] oauthRefreshToken_type_info = new String[]{'oauthRefreshToken',SOAP_M_URI,null,'0','1','false'};
		private String[] oauthScope_type_info = new String[]{'oauthScope',SOAP_M_URI,null,'0','1','false'};
		private String[] oauthToken_type_info = new String[]{'oauthToken',SOAP_M_URI,null,'0','1','false'};
		private String[] password_type_info = new String[]{'password',SOAP_M_URI,null,'0','1','false'};
		private String[] principalType_type_info = new String[]{'principalType',SOAP_M_URI,null,'1','1','false'};
		private String[] protocol_type_info = new String[]{'protocol',SOAP_M_URI,null,'1','1','false'};
		private String[] username_type_info = new String[]{'username',SOAP_M_URI,null,'0','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] type_att_info = new String[]{'xsi:type'};
		private String[] field_order_type_info = new String[]{'fullName', 'allowMergeFieldsInBody','allowMergeFieldsInHeader','authProvider','certificate','endpoint','generateAuthorizationHeader','label','oauthRefreshToken','oauthScope','oauthToken','password','principalType','protocol','username'};
	}

	public class SessionHeader_element {
		public String sessionId;
		private String[] sessionId_type_info = new String[]{'sessionId',SOAP_M_URI,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'sessionId'};
	}

	public class Error {
		public MetadataService.ExtendedErrorDetails[] extendedErrorDetails;
		public String[] fields;
		public String message;
		public String statusCode;
		private String[] extendedErrorDetails_type_info = new String[]{'extendedErrorDetails',SOAP_M_URI,null,'0','-1','false'};
		private String[] fields_type_info = new String[]{'fields',SOAP_M_URI,null,'0','-1','false'};
		private String[] message_type_info = new String[]{'message',SOAP_M_URI,null,'1','1','false'};
		private String[] statusCode_type_info = new String[]{'statusCode',SOAP_M_URI,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'extendedErrorDetails','fields','message','statusCode'};
	}

	public class ExtendedErrorDetails {
		public String extendedErrorCode;
		private String[] extendedErrorCode_type_info = new String[]{'extendedErrorCode',SOAP_M_URI,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'extendedErrorCode'};
	}

	public class SaveResult {
		public MetadataService.Error[] errors;
		public String fullName;
		public Boolean success;
		private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
		private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
		private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'errors','fullName','success'};
	}

	public class DeleteResult {
		public MetadataService.Error[] errors;
		public String fullName;
		public Boolean success;
		private String[] errors_type_info = new String[]{'errors',SOAP_M_URI,null,'0','-1','false'};
		private String[] fullName_type_info = new String[]{'fullName',SOAP_M_URI,null,'1','1','false'};
		private String[] success_type_info = new String[]{'success',SOAP_M_URI,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'errors','fullName','success'};
	}

	public class deleteMetadata_element {
		public String type_x;
		public String[] fullNames;
		private String[] type_x_type_info = new String[]{'type',SOAP_M_URI,null,'1','1','false'};
		private String[] fullNames_type_info = new String[]{'fullNames',SOAP_M_URI,null,'0','-1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'type_x','fullNames'};
	}

	public class deleteMetadataResponse_element {
		public MetadataService.DeleteResult[] result;
		private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'result'};
	}

	public class updateMetadata_element {
		public MetadataService.Metadata[] metadata;
		private String[] metadata_type_info = new String[]{'metadata',SOAP_M_URI,null,'0','-1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'metadata'};
	}

	public class updateMetadataResponse_element {
		public MetadataService.SaveResult[] result;
		private String[] result_type_info = new String[]{'result',SOAP_M_URI,null,'0','-1','false'};
		private String[] apex_schema_type_info = new String[]{SOAP_M_URI,'true','false'};
		private String[] field_order_type_info = new String[]{'result'};
	}

	public class MetadataPort {
		public String endpoint_x = URL.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/42.0';
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		public MetadataService.SessionHeader_element SessionHeader;
		private String SessionHeader_hns = 'SessionHeader=http://soap.sforce.com/2006/04/metadata';
		private String DebuggingInfo_hns = 'DebuggingInfo=http://soap.sforce.com/2006/04/metadata';
		private String DebuggingHeader_hns = 'DebuggingHeader=http://soap.sforce.com/2006/04/metadata';
		private String CallOptions_hns = 'CallOptions=http://soap.sforce.com/2006/04/metadata';
		private String AllOrNoneHeader_hns = 'AllOrNoneHeader=http://soap.sforce.com/2006/04/metadata';
		private String[] ns_map_type_info = new String[]{SOAP_M_URI, 'MetadataService'};
		public MetadataService.DeleteResult[] deleteMetadata(String type_x,String[] fullNames) {
			MetadataService.deleteMetadata_element request_x = new MetadataService.deleteMetadata_element();
			request_x.type_x = type_x;
			request_x.fullNames = fullNames;
			MetadataService.deleteMetadataResponse_element response_x;
			Map<String, MetadataService.deleteMetadataResponse_element> response_map_x = new Map<String, MetadataService.deleteMetadataResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
			  this,
			  request_x,
			  response_map_x,
			  new String[]{endpoint_x,
			  '',
			  SOAP_M_URI,
			  'deleteMetadata',
			  SOAP_M_URI,
			  'deleteMetadataResponse',
			  'MetadataService.deleteMetadataResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.result;

		}
		public MetadataService.SaveResult[] updateMetadata(MetadataService.Metadata[] metadata) {
			MetadataService.updateMetadata_element request_x = new MetadataService.updateMetadata_element();
			request_x.metadata = metadata;
			MetadataService.updateMetadataResponse_element response_x;
			Map<String, MetadataService.updateMetadataResponse_element> response_map_x = new Map<String, MetadataService.updateMetadataResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(
			  this,
			  request_x,
			  response_map_x,
			  new String[]{endpoint_x,
			  '',
			  SOAP_M_URI,
			  'updateMetadata',
			  SOAP_M_URI,
			  'updateMetadataResponse',
			  'MetadataService.updateMetadataResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.result;
		}
	}
}