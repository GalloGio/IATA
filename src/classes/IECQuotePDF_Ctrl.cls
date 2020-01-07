public with sharing class IECQuotePDF_Ctrl
{
	public Order sfQuote{get;set;}
	public Order_DTO vfQuote{get;set;}

	public IECQuotePDF_Ctrl()
	{
		Order_Sel oSelector = new Order_Sel();

		String quoteNumber = ApexPages.currentPage().getParameters().get('quote');
		sfQuote = oSelector.getCustomerQuoteDetails(IECUserManager.getContactId(), quoteNumber);

		if(sfQuote != null)
			vfQuote = new Order_DTO(sfQuote);
	}
}
