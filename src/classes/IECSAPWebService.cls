/**
 * Class offering web services to be called from SAP for the IEC project
 */
global class IECSAPWebService {

	/**
	 * Inner class that holds the values received from SAP for payment confirmation
	 */
	global class PaymentConfirmationRequest {

		// SAP Clearance date
		webservice Date InvoiceClearanceDate;

		// SalesForce (Zuora) Invoice number
		webservice String ZuoraInvoiceNumber;

		// SAP Invoice number (generated in SAP)
		webservice String SAPInvoiceNumber;
	}

	/**
	 * Inner class that holds the result values to send to SAP
	 */
	global class PaymentConfirmationResponse {

		// SalesForce Invoice number
		webservice String InvoiceNumber;

		// True if the payment has been successfully received in SalesForce
		webservice Boolean Success;

		// Error message if not success
		webservice String Error;
	}

	/**
	 * SAP calls this web method to confirm payments that were received
	 */
	webservice static PaymentConfirmationResponse[] confirmInvoicePayments(PaymentConfirmationRequest[] arrPayments) {

		try {

			if (arrPayments == null || arrPayments.isEmpty())
				return null;

			return IECSAPManager.updateInvoicesFromSAPPayment(arrPayments);
		}
		catch (Exception ex) {
			system.debug('ALEX - IECSAPWebService.confirmInvoicePayments(): Exception: ' + ex.getMessage() + ' Stack: ' + ex.getStacktraceString() + '\r\narrPayments: ' + String.valueOf(arrPayments));
			return null;
		}
	}
}
