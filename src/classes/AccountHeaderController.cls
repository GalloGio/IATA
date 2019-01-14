public with sharing class AccountHeaderController {

    
    public AccountHeaderController(ApexPages.StandardController stdController) {

    }
    
   	public static List<String> getSanctionFields() {
			List<String> sanctionFields = new String [] {
				'SanctionNotice__c'
			};
			return sanctionFields;

			}
    
    	@AuraEnabled
	    public static List<Boolean> getCanEdit() {
            List<Boolean> listCanEdit = new List<Boolean>();
         //   String schema = 'Schema.sObjectType.Account.';
          //  system.debug('isUpdateable aqui: ' + sanction);
            system.debug('FIELDS: ' + Schema.sObjectType.Account.fields);
            //system.debug('fieldToCheck1: ' + Schema.sObjectType.Account.fields.sanction.isUpdateable());
         
	        // Obtain the field name/token map for the Comment__c object
	        Map<String,Schema.SObjectField> m = Schema.SObjectType.Account.fields.getMap();

	        List<String> lsSanctionFields = getSanctionFields();
	        for (String fieldToCheck : lsSanctionFields) {
	            // Check if the user has access to view field
	            //  if (!Schema.sObjectType.Contact.fields.Status__c.isUpdateable()){
	            system.debug('fieldToCheck1: ' + Schema.sObjectType.Account.fields.SanctionNotice__c.isUpdateable() + ' isUpdateable: ' +m.get(fieldToCheck).getDescribe().isUpdateable() );
	          /*  if (!m.get(fieldToCheck).getDescribe().isUpdateable() ) {
	                canEdit = false;
	            }*/
                listCanEdit.add(m.get(fieldToCheck).getDescribe().isUpdateable());
	        }
            system.debug('listCanEdit: ' + listCanEdit);
	        return listCanEdit;
            
	    }
    
    @AuraEnabled
    public static Account saveRecord(Account recordDetail){
        system.debug('saveRecord: ' + recordDetail);
        upsert recordDetail;
        return recordDetail;
    }
    
}
