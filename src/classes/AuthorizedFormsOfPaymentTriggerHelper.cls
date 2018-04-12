public class AuthorizedFormsOfPaymentTriggerHelper {

	public static void populatesFormOfPaymentsFields(list<Authorized_Forms_Of_Payment__c> triggerNew){

		Map<Id, GDP_Products_Account_View__c> gdpProductsAccViewMap = new Map<Id, GDP_Products_Account_View__c>();

		for(Authorized_Forms_Of_Payment__c afop : triggerNew){

			if(!String.isEmpty(afop.Form_of_Payment_Code__c)){

				GDP_Products_Account_View__c gdpProductAccView;
				
				//A single GDP Product Account View may contain several forms of payments, this way we just have a list with unique 
				//GDP Product Account View to be updated. 
				if(gdpProductsAccViewMap.containsKey(afop.Related_GDP_Products_Account_View__c)){
					
					gdpProductAccView = gdpProductsAccViewMap.get(afop.Related_GDP_Products_Account_View__c);
				}else{
					
					gdpProductAccView = new GDP_Products_Account_View__c();
					gdpProductAccView.Id = afop.Related_GDP_Products_Account_View__c; 
				}

				//Depending of the form of payment code a unique field of the GDP Product Account View will be update 
				if(afop.Form_of_Payment_Code__c == AMS_Utils.CA){
					 
					gdpProductAccView.CA_FoP_Status__c = afop.Status_Code__c;

				}

				if(afop.Form_of_Payment_Code__c == AMS_Utils.CC){
					
					gdpProductAccView.CC_FoP_Status__c = afop.Status_Code__c;

				}

				if(afop.Form_of_Payment_Code__c == AMS_Utils.EP){

					gdpProductAccView.EP_FoP_Status__c = afop.Status_Code__c;

				}

				gdpProductsAccViewMap.put(gdpProductAccView.Id, gdpProductAccView);
			}
		}

		update gdpProductsAccViewMap.values();

	}

}