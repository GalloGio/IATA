public class ClaimEU261_ExtractCSVController {
	
	@AuraEnabled
	public static List<Case> getListEU261Cases() {
      
      	return [SELECT CaseNumber, Contact.Name, Subject, Status, Priority, CreatedDate, Owner.Name, Portal_Case_Status__c FROM Case WHERE RecordTypeId =: RecordTypeSingleton.getInstance().getRecordTypeId('Case','ClaimEU261')];
   }
}