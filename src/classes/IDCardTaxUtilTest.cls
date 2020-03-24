@isTest(seeAlldata=true)
public class IDCardTaxUtilTest {


	static testMethod void testGetTaxes() {
		Map<String,String>  taxesForQuebec = IDCardTaxUtil.GetTaxes('Quebec','');
		taxesForQuebec = IDCardTaxUtil.GetTaxes('Quebec','USA');
		taxesForQuebec = IDCardTaxUtil.GetTaxes(null,'Australia');
		String tax = IDCardTaxUtil.CalculateTaxes('5','300');
			decimal dtax = IDCardTaxUtil.getCalculatedTaxes('5','300');
	}

}
