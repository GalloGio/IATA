public with sharing class PortalApplicationRight_Sel extends Selector {

	public List<Schema.SObjectField> getSObjectFieldList(){
		return new List<Schema.SObjectField> {
			Portal_Application_Right__c.Id,
            Portal_Application_Right__c.Portal_Application__c,
            Portal_Application_Right__c.Right__c,
            Portal_Application_Right__c.Technical_Provisioning_Status__c,
            Portal_Application_Right__c.IsSCIMIFG__c
		};
	}

	public Schema.SObjectType getSObjectType(){
		return Portal_Application_Right__c.sObjectType;
	}

	/****************************************************************************************************
    	
	****************************************************************************************************/
	public List<Portal_Application_Right__c> getPortalApplicationRightsByContactIdAndRightsList(String contactId, List<String> lstRights) {
		String query = String.format(
            'SELECT {0} , Portal_Application__r.Name ' +
            'FROM {1} ' + 
            'WHERE Contact__c = :contactId AND Right__c IN :lstRights ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
		
		return Database.query(query);
	}



}