public without sharing class CW_RemoteValidationsController {
	@AuraEnabled(cacheable=true)
	public static string getUserRemoteValidations(List<String> managedFacilitiesIds) {
		Set<String> managedFacilitiesSet = managedFacilitiesIds != null ? new Set<String>(managedFacilitiesIds) : new Set<String>();
		return JSON.serialize([SELECT id, Station__c, Station__r.Id, Station__r.Name, Station__r.Street_Nr_FOR__c, Station__r.Postal_Code_FOR__c,
									Station__r.State_Province_FOR__c, Station__r.City_FOR__c, Station__r.Company_FOR__c, Order.Remote_Validation_Status__c,
									Order.EffectiveDate, Order.CreatedBy.Name 
								FROM OrderItem
								WHERE product2.Smart_Facility_Remote_Validation__c = true 
									AND Station__c != null 
									AND Station__c IN :managedFacilitiesSet
									AND IEC_Is_Paid__c = true
								]);
	}
	@AuraEnabled(cacheable=true)
	public static String getProductSmartFacilityRemoteValidation() {
		return JSON.serialize([SELECT id, SAP_Material_Number__c, IEC_SAP_Material_Number_Unformatted__c, Smart_Facility_Remote_Validation__c
								FROM Product2 
								WHERE Smart_Facility_Remote_Validation__c = true]);
	}

	@AuraEnabled
	public static Response createRemoteValidation(String stationId) {
		Response res = new Response();
		res.success = true;
		try{
			PriceBookEntry pre = [select Id, Product2Id, IsActive, UnitPrice, PriceBook2Id from pricebookentry where product2.Smart_Facility_Remote_Validation__c = true and IsActive = true limit 1];
			Order oOrder = new Order();
			oOrder.Status = 'New';
			oOrder.AccountId = [Select Account_Role__r.Account__c from ICG_Account_Role_Detail__c where Id =:stationId].Account_Role__r.Account__c;
			oOrder.Pricebook2Id = pre.PriceBook2Id;
			oOrder.EffectiveDate= date.today();
			insert oOrder;
			
			OrderItem oit = new OrderItem(
				PriceBookEntryId=pre.Id,
				OrderId=oOrder.Id,
				Quantity=1,
				UnitPrice=0,
				ServiceDate=Date.Today(),
				Station__c = stationId
			);
			insert oit;
			oit.IEC_Is_Paid__c = true;
			update oit;
		}catch (Exception ex){
			res.success = false;
			res.errorMessage = ex.getMessage();
		}
		return res;
	
	}

	public class Response {
		@AuraEnabled
		public Boolean success {get;set;}
		@AuraEnabled
		public String errorMessage {get;set;}
	}
}