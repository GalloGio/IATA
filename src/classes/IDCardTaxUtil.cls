global with sharing class IDCardTaxUtil {



// returns a list of taxes and percentage applied for a province
//eg:  (GST,5) (QST,9.975)
@RemoteAction
public static Map<String,String> GetTaxes(String province, String country) {

	List<CanadianTax__c> tax = CanadianTax__c.getAll().values();

	Map<String,String> taxes = new Map<String,String>();

	if(country==null)country='';
	if(province==null)province='';

	for (CanadianTax__c t : tax)
	{
		if ((t.Province__c==null || province == null || province.equalsIgnoreCase(t.Province__c)) && (!String.isNotBlank(country) || country.equalsIgnoreCase(t.Country__c)))
		{
			taxes.put(t.Tax_Name__c , String.ValueOf(t.Tax_Percentage__c));
		}
	}

	return taxes;

}


// returns back the tax ammount.
//
 @RemoteAction
public static string CalculateTaxes(string tax, string ammountWithTax) {

	Decimal taxpercentage  = decimal.valueOf(tax);
	Decimal amm = decimal.valueOf(ammountWithTax);

	Decimal taxammount =  amm - ( (amm)*(100 / (100 + (taxpercentage))));

	return String.valueOf(taxammount.setScale(2));



}


// returns back the tax ammount.
//
 @RemoteAction
public static Decimal getCalculatedTaxes(string tax, string ammountWithTax) {

	Decimal taxpercentage  = decimal.valueOf(tax);
	Decimal amm = decimal.valueOf(ammountWithTax);

	Decimal taxammount =  amm - ( (amm)*(100 / (100 + (taxpercentage))));

	return taxammount.setScale(2);



}




}
