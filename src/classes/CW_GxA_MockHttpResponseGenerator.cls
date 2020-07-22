
@isTest
global class CW_GxA_MockHttpResponseGenerator implements HttpCalloutMock {
	private String statusCode;

	global CW_GxA_MockHttpResponseGenerator() {
		this.statusCode = 'OK';
	}

	global CW_GxA_MockHttpResponseGenerator(String statusCode) {
		this.statusCode = statusCode;
	}

	global HTTPResponse respond(HTTPRequest req) {
		String bodyMock = '{"ClientName": "SF Ecllipse14_1000770","SurveyId": "11","SurveySessionId": "2076","SurveyName": "IATA Cargo_v13_Electronic System Capacities","SurveyAnswers": [{"QuestionTypeId": "13","QuestionID": "5878","Question": "Availability","Response": "No","SubSurvey": []}]}';

		HttpResponse res = new HttpResponse();
		res.setHeader('Content-Type', 'application/json');
		res.setBody(bodyMock);
		res.setStatusCode(statusCode.equals('OK') ? 200 : 401);
		return res;
	}
}
