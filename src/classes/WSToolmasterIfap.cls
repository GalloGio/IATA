//Generated by wsdl2apex
public class WSToolmasterIfap {
//
	public static Integer DEFAULT_TIMEOUT = 120000;
	public static String webserviceURL = 'http://webservice.toolmaster.ifap.iata.org';

	public class mergeAndSubmitParametersResponse_element {
		public String mergeAndSubmitParametersReturn;
		private String[] mergeAndSubmitParametersReturn_type_info = new String[]{'mergeAndSubmitParametersReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'mergeAndSubmitParametersReturn'};
	}

	public class submitCaseQualityIssuesToMFT_element {
		public String confName;
		public String caseNumber;
		public String xmlFilName;
		public String xmlString;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] caseNumber_type_info = new String[]{'caseNumber',webserviceURL,null,'1','1','false'};
		private String[] xmlFilName_type_info = new String[]{'xmlFilName',webserviceURL,null,'1','1','false'};
		private String[] xmlString_type_info = new String[]{'xmlString',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','caseNumber','xmlFilName','xmlString'};
	}

	public class submitCaseCancellationToMFTResponse_element {
		public String submitCaseCancellationToMFTReturn;
		private String[] submitCaseCancellationToMFTReturn_type_info = new String[]{'submitCaseCancellationToMFTReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'submitCaseCancellationToMFTReturn'};
	}

	public class mergeAllPDFForCase_element {
		public String confName;
		public String caseNumber;
		public String mergedFileName;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] caseNumber_type_info = new String[]{'caseNumber',webserviceURL,null,'1','1','false'};
		private String[] mergedFileName_type_info = new String[]{'mergedFileName',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','caseNumber','mergedFileName'};
	}

	public class submitCaseCancellationToMFT_element {
		public String confName;
		public String caseNumber;
		public String xmlFilName;
		public String xmlString;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] caseNumber_type_info = new String[]{'caseNumber',webserviceURL,null,'1','1','false'};
		private String[] xmlFilName_type_info = new String[]{'xmlFilName',webserviceURL,null,'1','1','false'};
		private String[] xmlString_type_info = new String[]{'xmlString',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','caseNumber','xmlFilName','xmlString'};
	}

	public class processPWCRejections_element {
		public String confName;
		public Integer maxRejections;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] maxRejections_type_info = new String[]{'maxRejections',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','maxRejections'};
	}

	public class deletePWCResults_element {
		public String confName;
		public String jsonFileNames;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] jsonFileNames_type_info = new String[]{'jsonFileNames',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','jsonFileNames'};
	}

	public class mergeAndSubmitParameters_element {
		public String confName;
		public String caseNumber;
		public String mergedFileName;
		public String xmlString;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] caseNumber_type_info = new String[]{'caseNumber',webserviceURL,null,'1','1','false'};
		private String[] mergedFileName_type_info = new String[]{'mergedFileName',webserviceURL,null,'1','1','false'};
		private String[] xmlString_type_info = new String[]{'xmlString',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','caseNumber','mergedFileName','xmlString'};
	}

	public class deletePWCRejectionsResponse_element {
		public String deletePWCRejectionsReturn;
		private String[] deletePWCRejectionsReturn_type_info = new String[]{'deletePWCRejectionsReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'deletePWCRejectionsReturn'};
	}

	public class processPWCResults_element {
		public String confName;
		public Integer maxResults;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] maxResults_type_info = new String[]{'maxResults',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','maxResults'};
	}

	public class processPWCResultsGxA_element {
		public String confName;
		public Integer maxResults;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] maxResults_type_info = new String[]{'maxResults',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','maxResults'};
	}
	
	public class processPWCRejectionsResponse_element {
		public String processPWCRejectionsReturn;
		private String[] processPWCRejectionsReturn_type_info = new String[]{'processPWCRejectionsReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'processPWCRejectionsReturn'};
	
	}
	public class mergeAllPDFForCaseResponse_element {
		public String mergeAllPDFForCaseReturn;
		private String[] mergeAllPDFForCaseReturn_type_info = new String[]{'mergeAllPDFForCaseReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'mergeAllPDFForCaseReturn'};
	}

	public class submitCaseQualityIssuesToMFTResponse_element {
		public String submitCaseQualityIssuesToMFTReturn;
		private String[] submitCaseQualityIssuesToMFTReturn_type_info = new String[]{'submitCaseQualityIssuesToMFTReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'submitCaseQualityIssuesToMFTReturn'};
	}

	public class deletePWCResultsResponse_element {
		public String deletePWCResultsReturn;
		private String[] deletePWCResultsReturn_type_info = new String[]{'deletePWCResultsReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'deletePWCResultsReturn'};
	}

	public class deletePWCdocumentsGXAResponse_element {
		public String deletePWCdocumentsGXAReturn;
		private String[] deletePWCdocumentsGXAReturn_type_info = new String[]{'deletePWCdocumentsGXAReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'deletePWCdocumentsGXAReturn'};
	}

	public class submitCaseParametersToMFTResponse_element {
		public String submitCaseParametersToMFTReturn;
		private String[] submitCaseParametersToMFTReturn_type_info = new String[]{'submitCaseParametersToMFTReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'submitCaseParametersToMFTReturn'};
	}

	public class processPWCResultsResponse_element {
		public String processPWCResultsReturn;
		private String[] processPWCResultsReturn_type_info = new String[]{'processPWCResultsReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'processPWCResultsReturn'};
	}

	public class processPWCdocumentsGXAResponse_element {
		public String processPWCdocumentsGXAReturn;
		private String[] processPWCdocumentsGXAReturn_type_info = new String[]{'processPWCdocumentsGXAReturn',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'processPWCdocumentsGXAReturn'};
	}

	public class submitCaseParametersToMFT_element {
		public String confName;
		public String caseNumber;
		public String pdfName;
		public String xmlString;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] caseNumber_type_info = new String[]{'caseNumber',webserviceURL,null,'1','1','false'};
		private String[] pdfName_type_info = new String[]{'pdfName',webserviceURL,null,'1','1','false'};
		private String[] xmlString_type_info = new String[]{'xmlString',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','caseNumber','pdfName','xmlString'};
	}

	public class deletePWCRejections_element {
		public String confName;
		public String jsonFileNames;
		private String[] confName_type_info = new String[]{'confName',webserviceURL,null,'1','1','false'};
		private String[] jsonFileNames_type_info = new String[]{'jsonFileNames',webserviceURL,null,'1','1','false'};
		private String[] apex_schema_type_info = new String[]{webserviceURL,'true','false'};
		private String[] field_order_type_info = new String[]{'confName','jsonFileNames'};
	}

	public class IfapToolMaster {
		public String endpoint_x =UserInfo.getOrganizationId().substring(0,15) == '00D2000000008TF'  ? Amazon_Cred__c.getInstance('endpoint').Prod_Configuration__c :Amazon_Cred__c.getInstance('endpoint').Dev_Configuration__c ;
		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x = DEFAULT_TIMEOUT ;
		private String[] ns_map_type_info = new String[]{webserviceURL, 'WSToolmasterIfap'};

		public String processPWCResults(String confName,Integer maxResults) {
			WSToolmasterIfap.processPWCResults_element request_x = new WSToolmasterIfap.processPWCResults_element();
			request_x.confName = confName;
			request_x.maxResults = maxResults;
			WSToolmasterIfap.processPWCResultsResponse_element response_x;
			Map<String, WSToolmasterIfap.processPWCResultsResponse_element> response_map_x = new Map<String, WSToolmasterIfap.processPWCResultsResponse_element>();
			response_map_x.put('response_x', response_x);
			
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'processPWCResults',
									webserviceURL,
									'processPWCResultsResponse',
									'WSToolmasterIfap.processPWCResultsResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.processPWCResultsReturn;
		}
	
		public String processPWCdocumentsGXA(String confName,Integer maxResults) {
			WSToolmasterIfap.processPWCResultsGxA_element request_x = new WSToolmasterIfap.processPWCResultsGxA_element();
			request_x.confName = confName;
			request_x.maxResults = maxResults;
			WSToolmasterIfap.processPWCdocumentsGXAResponse_element response_x;
			Map<String, WSToolmasterIfap.processPWCdocumentsGXAResponse_element> response_map_x = new Map<String, WSToolmasterIfap.processPWCdocumentsGXAResponse_element>();
			response_map_x.put('response_x', response_x);

			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'processPWCdocumentsGXA',
									webserviceURL,
									'processPWCdocumentsGXAResponse',
									'WSToolmasterIfap.processPWCdocumentsGXAResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.processPWCdocumentsGXAReturn;
		}

		public String mergeAllPDFForCase(String confName,String caseNumber,String mergedFileName) {
			WSToolmasterIfap.mergeAllPDFForCase_element request_x = new WSToolmasterIfap.mergeAllPDFForCase_element();
			request_x.confName = confName;
			request_x.caseNumber = caseNumber;
			request_x.mergedFileName = mergedFileName;
			WSToolmasterIfap.mergeAllPDFForCaseResponse_element response_x;
			Map<String, WSToolmasterIfap.mergeAllPDFForCaseResponse_element> response_map_x = new Map<String, WSToolmasterIfap.mergeAllPDFForCaseResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'mergeAllPDFForCase',
									webserviceURL,
									'mergeAllPDFForCaseResponse',
									'WSToolmasterIfap.mergeAllPDFForCaseResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.mergeAllPDFForCaseReturn;
		}

		public String submitCaseQualityIssuesToMFT(String confName,String caseNumber,String xmlFilName,String xmlString) {
			WSToolmasterIfap.submitCaseQualityIssuesToMFT_element request_x = new WSToolmasterIfap.submitCaseQualityIssuesToMFT_element();
			request_x.confName = confName;
			request_x.caseNumber = caseNumber;
			request_x.xmlFilName = xmlFilName;
			request_x.xmlString = xmlString;
			WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element response_x;
			Map<String, WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element> response_map_x = new Map<String, WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'submitCaseQualityIssuesToMFT',
									webserviceURL,
									'submitCaseQualityIssuesToMFTResponse',
									'WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.submitCaseQualityIssuesToMFTReturn;
		}

		public String deletePWCResults(String confName,String jsonFileNames) {
			WSToolmasterIfap.deletePWCResults_element request_x = new WSToolmasterIfap.deletePWCResults_element();
			request_x.confName = confName;
			request_x.jsonFileNames = jsonFileNames;
			WSToolmasterIfap.deletePWCResultsResponse_element response_x;
			Map<String, WSToolmasterIfap.deletePWCResultsResponse_element> response_map_x = new Map<String, WSToolmasterIfap.deletePWCResultsResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'deletePWCResults',
									webserviceURL,
									'deletePWCResultsResponse',
									'WSToolmasterIfap.deletePWCResultsResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.deletePWCResultsReturn;
		}

		public String deletePWCdocumentsGXA(String confName,String jsonFileNames) {
			WSToolmasterIfap.deletePWCResults_element request_x = new WSToolmasterIfap.deletePWCResults_element();
			request_x.confName = confName;
			request_x.jsonFileNames = jsonFileNames;
			WSToolmasterIfap.deletePWCdocumentsGXAResponse_element response_x;
			Map<String, WSToolmasterIfap.deletePWCdocumentsGXAResponse_element> response_map_x = new Map<String, WSToolmasterIfap.deletePWCdocumentsGXAResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'deletePWCdocumentsGXA',
									webserviceURL,
									'deletePWCdocumentsGXAResponse',
									'WSToolmasterIfap.deletePWCdocumentsGXAResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.deletePWCdocumentsGXAReturn;
		}

		public String deletePWCRejections(String confName,String jsonFileNames) {
			WSToolmasterIfap.deletePWCRejections_element request_x = new WSToolmasterIfap.deletePWCRejections_element();
			request_x.confName = confName;
			request_x.jsonFileNames = jsonFileNames;
			WSToolmasterIfap.deletePWCRejectionsResponse_element response_x;
			Map<String, WSToolmasterIfap.deletePWCRejectionsResponse_element> response_map_x = new Map<String, WSToolmasterIfap.deletePWCRejectionsResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'deletePWCRejections',
									webserviceURL,
									'deletePWCRejectionsResponse',
									'WSToolmasterIfap.deletePWCRejectionsResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.deletePWCRejectionsReturn;
		}

		public String submitCaseCancellationToMFT(String confName,String caseNumber,String xmlFilName,String xmlString) {
			WSToolmasterIfap.submitCaseCancellationToMFT_element request_x = new WSToolmasterIfap.submitCaseCancellationToMFT_element();
			request_x.confName = confName;
			request_x.caseNumber = caseNumber;
			request_x.xmlFilName = xmlFilName;
			request_x.xmlString = xmlString;
			WSToolmasterIfap.submitCaseCancellationToMFTResponse_element response_x;
			Map<String, WSToolmasterIfap.submitCaseCancellationToMFTResponse_element> response_map_x = new Map<String, WSToolmasterIfap.submitCaseCancellationToMFTResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'submitCaseCancellationToMFT',
									webserviceURL,
									'submitCaseCancellationToMFTResponse',
									'WSToolmasterIfap.submitCaseCancellationToMFTResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.submitCaseCancellationToMFTReturn;
		}

		public String submitCaseParametersToMFT(String confName,String caseNumber,String pdfName,String xmlString) {
			WSToolmasterIfap.submitCaseParametersToMFT_element request_x = new WSToolmasterIfap.submitCaseParametersToMFT_element();
			request_x.confName = confName;
			request_x.caseNumber = caseNumber;
			request_x.pdfName = pdfName;
			request_x.xmlString = xmlString;
			WSToolmasterIfap.submitCaseParametersToMFTResponse_element response_x;
			Map<String, WSToolmasterIfap.submitCaseParametersToMFTResponse_element> response_map_x = new Map<String, WSToolmasterIfap.submitCaseParametersToMFTResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'submitCaseParametersToMFT',
									webserviceURL,
									'submitCaseParametersToMFTResponse',
									'WSToolmasterIfap.submitCaseParametersToMFTResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.submitCaseParametersToMFTReturn;
		}

		public String processPWCRejections(String confName,Integer maxRejections) {
			WSToolmasterIfap.processPWCRejections_element request_x = new WSToolmasterIfap.processPWCRejections_element();
			request_x.confName = confName;
			request_x.maxRejections = maxRejections;
			WSToolmasterIfap.processPWCRejectionsResponse_element response_x;
			Map<String, WSToolmasterIfap.processPWCRejectionsResponse_element> response_map_x = new Map<String, WSToolmasterIfap.processPWCRejectionsResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'processPWCRejections',
									webserviceURL,
									'processPWCRejectionsResponse',
									'WSToolmasterIfap.processPWCRejectionsResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.processPWCRejectionsReturn;
		}

		public String mergeAndSubmitParameters(String confName,String caseNumber,String mergedFileName,String xmlString) {
			WSToolmasterIfap.mergeAndSubmitParameters_element request_x = new WSToolmasterIfap.mergeAndSubmitParameters_element();
			request_x.confName = confName;
			request_x.caseNumber = caseNumber;
			request_x.mergedFileName = mergedFileName;
			request_x.xmlString = xmlString;
			WSToolmasterIfap.mergeAndSubmitParametersResponse_element response_x;
			Map<String, WSToolmasterIfap.mergeAndSubmitParametersResponse_element> response_map_x = new Map<String, WSToolmasterIfap.mergeAndSubmitParametersResponse_element>();
			response_map_x.put('response_x', response_x);
			WebServiceCallout.invoke(this,
									request_x,
									response_map_x,
									new String[]{endpoint_x,
									'',
									webserviceURL,
									'mergeAndSubmitParameters',
									webserviceURL,
									'mergeAndSubmitParametersResponse',
									'WSToolmasterIfap.mergeAndSubmitParametersResponse_element'}
			);
			response_x = response_map_x.get('response_x');
			return response_x.mergeAndSubmitParametersReturn;
		}
	}
}
