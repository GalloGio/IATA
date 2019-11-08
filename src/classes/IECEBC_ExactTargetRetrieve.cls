public class IECEBC_ExactTargetRetrieve {
	// get Map<kpi, value> of Triggered Send Summary from ExactTarget
	Public static Map<String, String> getTriggeredSendSummary(String triggeredSendExternalKey) {
		// http instances and variables
		Map<String, String> triggeredSendSummaryMetrics = new Map<String, String>
								{
									'Sent' => '0',
									'Opens'  => '0',
									'Clicks'  => '0',
									'Bounces'  => '0',
									'OptOuts'  => '0',
									'UniqueOpens'  => '0',
									'UniqueClicks'  => '0',
									'NotSentDueToOptOut' => '0',
									'NotSentDueToUndeliverable'  => '0',
									'NotSentDueToError'  => '0',
									'FTAFEmailsSent'  => '0',
									'FTAFOptIns'  => '0',
									'FTAFRequests'  => '0',
									'SurveyResponses'  => '0',
									'Conversions'  => '0',
									'UniqueConversions'  => '0',
									'InProcess'  => '0',
									'Queued'  => '0'
								};

		Http http = new Http();
		HttpRequest req = new HttpRequest();

		// header
		IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
		// body
		req.setBody(
			IECEBC_ETHelper.createXMLHeader()
			+ IECEBC_ETHelper.retrieveRequestTriggeredSendSummary(triggeredSendExternalKey)
			+ IECEBC_ETHelper.createXMLFooter()
		);
		req.setTimeout(IECEBC_ETInit.TimeOut);
		// get response
		HTTPResponse response = http.send(req);
		if (response.getStatusCode() == 200) {
			IECEBC_ETHelper.parseMaptriggeredSendSummary(response, triggeredSendSummaryMetrics);
		}
		// return ID
		return triggeredSendSummaryMetrics;
	}
}
