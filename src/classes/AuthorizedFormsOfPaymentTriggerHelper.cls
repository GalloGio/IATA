public class AuthorizedFormsOfPaymentTriggerHelper {

	public static void populatesFormOfPaymentsFields(list<Authorized_Forms_Of_Payment__c> triggerNew, boolean isDelete){

		List<GDP_Products_Account_View__c> gdpProductsAccViewList = new List<GDP_Products_Account_View__c>();

		for(Authorized_Forms_Of_Payment__c afop : triggerNew){
			if(afop.Form_of_Payment_Code__c == AMS_Utils.CA){
				gdpProductsAccViewList.add(new GDP_Products_Account_View__c(
					ID = afop.Related_GDP_Products_Account_View__c, 
					CA_FoP_Status__c = (isDelete ? '' : afop.Status_Code__c)));

			}else if(afop.Form_of_Payment_Code__c == AMS_Utils.CC){
				gdpProductsAccViewList.add(new GDP_Products_Account_View__c(
					ID = afop.Related_GDP_Products_Account_View__c, 
					CC_FoP_Status__c = (isDelete ? '' : afop.Status_Code__c)));
			
			}else if(afop.Form_of_Payment_Code__c == AMS_Utils.EP){
				gdpProductsAccViewList.add(new GDP_Products_Account_View__c(
					ID = afop.Related_GDP_Products_Account_View__c, 
					EP_FoP_Status__c = (isDelete ? '' : afop.Status_Code__c)));

			}
		}

		update gdpProductsAccViewList;

	}

}