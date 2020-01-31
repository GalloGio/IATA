/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This is a webservice that creates an interface between Salesforce and FAS. It will be called periodically by FAS
 *      in order to sync their Contacts database with Salesforce.
 */

global class ICCS_FAS_Interface {

	global class ICCSContact {
		webservice String FirstName;
		webservice String LastName;
		webservice String Email;
		webservice String CompanyDesignator;
		webservice String SalesforceId;

		webservice Boolean QuarterlyStatementFlag;
		webservice Boolean CashflowMonthlyReportFlag;
		webservice Boolean Cashflow12MonthReportFlag;
		webservice Boolean PayableReportFlag;

		public ICCSContact (Contact c) {
			FirstName = c.FirstName != null ? c.FirstName : '';
			LastName = c.LastName != null ? c.LastName : '';

			if (c.RecordType.DeveloperName == 'Senior') {
				// for Senior contacts, return the email from the Senior_Contact_Email__c field
				Email = c.Senior_Contact_Email__c != null ? c.Senior_Contact_Email__c : '';
			} else {
				Email = c.Email != null ? c.Email : '';
			}

			CompanyDesignator = c.Airline_Designator__c != null ? c.Airline_Designator__c : '';
			SalesforceId = String.valueOf(c.Id);

			QuarterlyStatementFlag = c.Communication_Interest__c != null && c.Communication_Interest__c.contains('Quarterly Statement - DataMart');
			CashflowMonthlyReportFlag = c.Communication_Interest__c != null && c.Communication_Interest__c.contains('Cash Flow - Monthly Report');
			Cashflow12MonthReportFlag = c.Communication_Interest__c != null && c.Communication_Interest__c.contains('Cash Flow - 12 Month Report');
			PayableReportFlag = c.Communication_Interest__c != null && c.Communication_Interest__c.contains('Payable Report');
		}
	}

	global class ICCSResponse {
		webservice Integer ItemCount;
		webservice String Message;
		webservice List<ICCSContact> Contacts;

		public ICCSResponse (List<ICCSContact> lstContacts, String strMsg) {
			if (!lstContacts.isEmpty()) {
				ItemCount = lstContacts.size();
				Contacts = lstContacts;
				Message = 'OK';
			} else {
				ItemCount = 0;
				Contacts = null;

				// If strMsg contains an error message already, leave it as-is. If not error message, then send "zero results" message.
				Message = strMsg != '' ? strMsg : 'No results.';
			}

		}
	}

	webService static ICCSResponse getContacts (String CommunicationInterest) {
		List<ICCSContact> lstResult = new List<ICCSContact>();

		if (CommunicationInterest != null && CommunicationInterest != '') {
			String soqlQuery = 'SELECT Id, RecordType.DeveloperName, FirstName, LastName, Email, Senior_Contact_Email__c, Airline_Designator__c, Communication_Interest__c FROM Contact';
			soqlQuery += ' WHERE Communication_Interest__c INCLUDES (\'' + CommunicationInterest + '\')';

			List<Contact> qResult = Database.query(soqlQuery);

			for (Contact c : qResult) {
				lstResult.add(new ICCSContact(c));
			}

			return new ICCSResponse(lstResult,'');
		} else {
			return new ICCSResponse(lstResult, 'ERROR: The CommunicationInterest parameter is mandatory.');
		}
	}
}
