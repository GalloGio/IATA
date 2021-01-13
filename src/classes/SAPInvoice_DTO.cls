public class SAPInvoice_DTO
{
	public Date clearanceDate{get;set;}
	public String invoiceNumber{get;set;}
	public String orderId{get;set;}

	public SAPInvoice_DTO(SAP_Invoice__c invoice)
	{
		clearanceDate = invoice.Clearance_Date__c;
		invoiceNumber = invoice.Invoice_Number__c;
		orderId = invoice.Order__c;
	}
}
