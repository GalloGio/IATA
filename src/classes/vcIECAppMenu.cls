public with sharing class vcIECAppMenu {
	public String sSubscriptionNumber {get; set;}
	public String sProductCode {get; set;}
	public String sPageName {get; set;}

	public PageReference NavigateTo() {
		Pagereference pgRef = new PageReference('/' + sPageName);
		if (sPageName != 'IECFD' && sPageName != 'IEC_CACW')
			pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter(sSubscriptionNumber));
		pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(sProductCode));
		pgRef.setRedirect(true);
		return pgRef;
	}
}
