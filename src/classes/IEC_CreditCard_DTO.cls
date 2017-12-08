public with sharing class IEC_CreditCard_DTO 
{
	public String 	zId { get; set; }
	public Boolean 	isDefault{get;set;}
	public Boolean 	isExpired{get;set;}
	public Integer  numberOfDays{get;set;}
	public Date 	creditCardDate { get; set; }
	public String 	name { get; set; }
	public String 	creditCardType { get; set; }
	public String 	creditCardMaskNumber { get; set; }
	public String 	creditCardCVV { get; set; }
	public Integer 	expirationMonth { get; set; }
	public Integer 	expirationYear { get; set; }
	public String 	holderName { get; set; }
	public String 	country { get; set; }
	public String 	addresLine1 { get; set; }
	public String 	addresLine2 { get; set; }
	public String 	city { get; set; }
	public String 	stateProvince { get; set; }
	public String 	postalCode { get; set; }
	public String 	accountId { get; set; }
	public String 	lastTransactionStatus { get; set; }


	public IEC_CreditCard_DTO() {}

	public IEC_CreditCard_DTO(Zuora.zObject zAccount, Zuora.zObject zCreditCard) 
	{
		zId 					= (String)  zCreditCard.getValue('Id');
		name 					= (String)  zCreditCard.getValue('Name');
		creditCardType 			= (String)  zCreditCard.getValue('CreditCardType');
		creditCardMaskNumber 	= (String)  zCreditCard.getValue('CreditCardMaskNumber');
		creditCardCVV 			= (String)  zCreditCard.getValue('cardSecurityCode');	
		expirationMonth 		= (Integer) zCreditCard.getValue('CreditCardExpirationMonth');
		expirationYear 			= (Integer) zCreditCard.getValue('CreditCardExpirationYear');
		holderName 				= (String)  zCreditCard.getValue('CreditCardHolderName');
		country 				= (String)  zCreditCard.getValue('CreditCardCountry');
			if (country != null && country.length() != 2)  
				country = IECZuoraHelper.convertCountryNameToCode(country);

		addresLine1 			= (String)	zCreditCard.getValue('CreditCardAddress1');
		addresLine2 			= (String)	zCreditCard.getValue('CreditCardAddress2');
		city 					= (String)	zCreditCard.getValue('CreditCardCity');
		stateProvince 			= (String)	zCreditCard.getValue('CreditCardState');
		postalCode 				= (String)	zCreditCard.getValue('CreditCardPostalCode');
		lastTransactionStatus 	= (String)	zCreditCard.getValue('LastTransactionStatus');
		accountId 				= (String)	zCreditCard.getValue('AccountId');

		isDefault 				= (zId == (String)zAccount.getValue('DefaultPaymentMethodId'));
		creditCardDate			= Date.newInstance(expirationYear, expirationMonth, 1);
		numberOfDays 			= Date.daysInMonth(creditCardDate.year(), creditCardDate.month());
		isExpired 				= (Date.today() > Date.newInstance(expirationYear, expirationMonth, numberOfDays));	
	}

	public Zuora.zObject toZObjectForUpdate() {
			Zuora.zObject zObj = new Zuora.zObject('PaymentMethod');
			zObj.setValue('Id', zId);
			zObj.setValue('CreditCardExpirationMonth', 	expirationMonth);
			zObj.setValue('CreditCardExpirationYear', 	expirationYear);
			zObj.setValue('CreditCardSecurityCode', 	creditCardCVV);
			zObj.setValue('CreditCardHolderName', 		holderName);
			zObj.setValue('CreditCardCountry', 			country);
			zObj.setValue('CreditCardAddress1', 		addresLine1);
			zObj.setValue('CreditCardAddress2', 		addresLine2);
			zObj.setValue('CreditCardCity', 			city);
			zObj.setValue('CreditCardState', 			stateProvince);
			zObj.setValue('CreditCardPostalCode', 		postalCode);
			zObj.setValue('AccountId', 					accountId);
			return zObj;
		}

}