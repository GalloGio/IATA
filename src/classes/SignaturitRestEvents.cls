@RestResource(urlMapping='/signaturit/event/*')
global with sharing class SignaturitRestEvents {

/*
https://iata--bi.cs87.my.salesforce.com/services/apexrest/signaturit/event
*/

	public static String testJson;

	@HttpPost
	global static void receiveEvent() {
		try {
			String jsonStr = Test.isRunningTest()? testJson: RestContext.request.requestBody.toString();
			//saveLog(jsonStr);
			processEvent(jsonStr);
		} catch (Exception e) {
			//saveLog('ERROR ' + e.getMessage());
			System.debug('ERROR in SignaturitRestEvents.receiveEvent() ' + e);
		}
	}

/*
	private static void saveLog(String text) {
		Tracked_Email__c email;
		//json = json.replace('\\','\\\\');
		email = new Tracked_Email__c(
			Case__c = '5008E000000cX6NQAU',
			FromAddress__c ='test@email.com',
			Subject__c = 'body',
			TextBody__c = text
		);
		insert email;
	}
*/
	@HttpGet
	global static String testService() {
		return 'testService OK';
	}

	global static void processEvent(String jsonStr) {
		jsonStr = jsonStr.replace('"date"','"date_x"');
		JSONParser parser = JSON.createParser(jsonStr);
		EventResponse response = (EventResponse)parser.readValueAs(EventResponse.class);

		System.debug('****** ' + response);

		Tracked_Email__c trackedEmail = [
			Select Id
			From Tracked_Email__c
			Where Signaturit_Id__c = :response.certificate.id
			or Signaturit_Certificate_Ids__c = :response.certificate.id
			limit 1];

		if (trackedEmail != null) {
			Savepoint sp = Database.setSavepoint();
			try {
				Tracked_Email_Event__c event = new Tracked_Email_Event__c(
					Parent__c = trackedEmail.Id,
					Timestamp__c = response.getEventDate(),
					Status__c = response.getEventType()
				);
				insert event;

				trackedEmail.Status__c = event.Status__c;
				update trackedEmail;

			} catch ( Exception e) {
				Database.rollback(sp);
				System.debug('SignaturitRestEvents Error in processEvent() : ' + e.getMessage());
			}
		}
	}


	global class EventResponse {
		global String date_x;
		global String type;
		global Certificate certificate;

		public DateTime getEventDate() {
			if (certificate.last_event == null) {
				return getDate();
			}
			return certificate.last_event.getDate();
		}

		public String getEventType() {
			if (certificate.last_event == null) {
				return this.type;
			}
			return certificate.last_event.type;
		}

		private DateTime getDate() {
			return parseDateString(date_x);
		}
	}

	global class Certificate {
		//global CertifiedEmail certified_email;
		global String created_at;
		//global Event events;
		global String id;
		global EventData last_event;
		global String recipient_email;
		global String recipient_name;
	}

	global class EventData {
		global String date_x;
		global String type;

		private DateTime getDate() {
			return parseDateString(date_x);
		}
	}

	private static DateTime parseDateString(String dateStr) {
		try {
			list<Integer> timeParts = new list<Integer>();
			for ( String part: dateStr.split('[T:+-]') ) {
				timeParts.add( Integer.ValueOf(part));
			}
			return DateTime.newInstanceGmt(timeParts[0], timeParts[1], timeParts[2], timeParts[3], timeParts[4], timeParts[5]);
		} catch( Exception e) {
			return DateTime.now();
		}
	}

}