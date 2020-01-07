public class IECEBC_ETSubscriberBouncedRetrieve {
	class UnexpectedResponse_Exception extends Exception{}

	// Retrieve the list of bounced email address from Exacttarget
	@future(callout=true)
	public static void RetrieveHardBounceFuture(Datetime lastFetch){
		RetrieveHardBounce(lastFetch);
	}
	public static List<EBC_Email_Exclusion__c> RetrieveHardBounce(Datetime lastFetch){
		List<EBC_Email_Exclusion__c> myList = new List<EBC_Email_Exclusion__c>();

		String type = 'HardBounce';
		String LastDate = lastFetch.formatGmt('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'');
		List<String> subscribersEmailList = new List<String>();
		//Map<String, IECEBC_ETHelper.SubscriberProperties> subscribersEmailMap = new Map<String, IECEBC_ETHelper.SubscriberProperties>();
		HttpRequest req = new HttpRequest();
		Http http = new Http();

		 string bodyContent =

			'<RetrieveRequestMsg xmlns="http://exacttarget.com/wsdl/partnerAPI">'
			+'<RetrieveRequest>'
			+'<ObjectType>BounceEvent</ObjectType>'
			+'<Properties>SubscriberKey</Properties>'
			+'<Properties>EventDate</Properties>'
			+'<Properties>EventType</Properties>'
			+'<Properties>SMTPReason</Properties>'

			+'<Filter xmlns="http://exacttarget.com/wsdl/partnerAPI" xsi:type="ComplexFilterPart">'
			+'<LeftOperand xsi:type="SimpleFilterPart">'
			+'<Property>EventDate</Property>'
			+'<SimpleOperator>greaterThan</SimpleOperator>'
			+'<DateValue>'+ LastDate +'</DateValue>'
			+'</LeftOperand>'
			+'<LogicalOperator>AND</LogicalOperator>'
			+'<RightOperand xsi:type="SimpleFilterPart">'
			+'<Property>EventType</Property>'
			+'<SimpleOperator>equals</SimpleOperator>'
			+'<Value>'+  Type  +'</Value>'
			+'</RightOperand>'
			+'</Filter>'

			+'</RetrieveRequest>'
			+'</RetrieveRequestMsg>';


		req.setTimeout(IECEBC_ETInit.TimeOut);
		System.debug(bodyContent);
		IECEBC_ETHelper.SetSoapRequest(req, 'Retrieve', bodyContent);
		HTTPResponse res = http.send(req);

		System.debug(res.getBody());

		if (res.getStatusCode() == 200) {

			List<String> elements = new List<String>{'SubscriberKey', 'SMTPReason', 'EventDate'};
				List<Map<String, String>> subscribersEmailMap = new List<Map<String, String>>();

			subscribersEmailMap = IECEBC_ETHelper.parseListMap(res, elements);
		   // system.debug('les elements sont: '+subscribersEmailMap);

			Pattern subKeyPattern = Pattern.compile('^(' + EBC_Campaign__c.sobjecttype.getDescribe().getKeyPrefix() + '[a-zA-Z0-9]{15})_(.*)');

			for(Map<String, String> ListMap : subscribersEmailMap) {
				Datetime eventDate = (Datetime)JSON.deserialize('"' + ListMap.get('EventDate') + '"', Datetime.class);
				if (eventDate <= lastFetch) continue;

				String subscriberk = ListMap.get('SubscriberKey');
				Matcher subKeyMatcher = subKeyPattern.matcher(subscriberk);

				if (!subKeyMatcher.matches()) {
					System.debug('Ignoring the subscriber key ' + subscriberk + ' because it does not match the supported syntax.');
					continue; // Subscriber Key does not match the supported syntax.
				}

				//String eventDate2 = ListMap.get('EventDate');
				String SMPTReason = ListMap.get('SMTPReason');
				String campaign = subKeyMatcher.group(1);
				String email = subKeyMatcher.group(2);

				EBC_Email_Exclusion__c ExclusionEmail = new EBC_Email_Exclusion__c();

				ExclusionEmail.Name = 'Bounced_'+ email;
				ExclusionEmail.Email__c = email;
				ExclusionEmail.Type__c = 'HARDBOUNCE';
				ExclusionEmail.Source_Campaign__c = campaign;
				ExclusionEmail.Other_Reason__c = SMPTReason;
				ExclusionEmail.Event_Date__c = eventDate;
				ExclusionEmail.Event_Date_Timestamp__c = eventDate.getTime();

				myList.add(ExclusionEmail);

			}
			upsert myList;

		}else{
			System.debug(res);
			throw new UnexpectedResponse_Exception('Unexpected Response');
		}

		return myList;
	}

}
