public class AuthorizedFormsOfPaymentTriggerHelper {

	/**
	* Populates the forms of payments fields from a GDP product account view object during a delete or insert
	*
	*/
	public static void populatesFormOfPaymentsFields(list<Authorized_Forms_Of_Payment__c> triggerValues, boolean isDelete){

		Map<Id, GDP_Products_Account_View__c> gdpProductsAccViewMap = new Map<Id, GDP_Products_Account_View__c>();

		for(Authorized_Forms_Of_Payment__c afop : triggerValues){

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
				fillFormsOfPaymentsStatus(gdpProductAccView, afop.Form_of_Payment_Code__c, isDelete ? '' : afop.Status_Code__c);

				gdpProductsAccViewMap.put(gdpProductAccView.Id, gdpProductAccView);
			}
		}

		update gdpProductsAccViewMap.values();

	}

	/**
	* Update the forms of payments fields from a GDP product account view object during an update
	*
	*/
	public static void updatesFormOfPaymentsFields(list<Authorized_Forms_Of_Payment__c> triggerNew, Map<Id, Authorized_Forms_Of_Payment__c> triggerOldMap){

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


				//Cleans the old values
				fillFormsOfPaymentsStatus(gdpProductAccView, triggerOldMap.get(afop.Id).Form_of_Payment_Code__c, '');

				//Update with the new values
				//Depending of the form of payment code a unique field of the GDP Product Account View will be update 
				fillFormsOfPaymentsStatus(gdpProductAccView, afop.Form_of_Payment_Code__c, afop.Status_Code__c);

				gdpProductsAccViewMap.put(gdpProductAccView.Id, gdpProductAccView);
			}

		}

		update gdpProductsAccViewMap.values();

	}


	private static GDP_Products_Account_View__c fillFormsOfPaymentsStatus(GDP_Products_Account_View__c gdpProductAccView, String formOfPaymentCode, String value){

		if(formOfPaymentCode == AMS_Utils.CA){

			gdpProductAccView.CA_FoP_Status__c = value;
		}

		if(formOfPaymentCode == AMS_Utils.CC){
			
			gdpProductAccView.CC_FoP_Status__c = value;
		}

		if(formOfPaymentCode == AMS_Utils.EP){

			gdpProductAccView.EP_FoP_Status__c = value;
		}

		return gdpProductAccView;

	}

}