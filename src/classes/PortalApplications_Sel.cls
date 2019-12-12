public with sharing class PortalApplications_Sel extends Selector {

	public List<Schema.SObjectField> getSObjectFieldList(){
		return new List<Schema.SObjectField> {
			Portal_Applications__c.Id,
			Portal_Applications__c.Name,
			Portal_Applications__c.Application_icon_URL__c,
			Portal_Applications__c.Application_icon__c, //WMO-736 - ACAMBAS
			Portal_Applications__c.Application_URL__c,
			Portal_Applications__c.Confirm_Box__c,
			Portal_Applications__c.Confirm_Text__c,
			Portal_Applications__c.Description__c,
			Portal_Applications__c.GSSA__c,
			Portal_Applications__c.Hide_on_Homepage__c,
			Portal_Applications__c.ICH_Airline__c,
			Portal_Applications__c.New_Window__c,
			Portal_Applications__c.ServiceName__c,
			Portal_Applications__c.Not_ICH_Airline__c,
			Portal_Applications__c.Record_type_for_App_Rigth__c,
			Portal_Applications__c.Requestable__c,
			Portal_Applications__c.Restricted_App__c,
			Portal_Applications__c.Visible__c,
			Portal_Applications__c.Service_Description__c,
			Portal_Applications__c.Cannot_be_managed_by_portal_admin__c,
			Portal_Applications__c.Service_Description_Label__c,
			Portal_Applications__c.ANG_Restrict_by_Agency_Sector__c,
			Portal_Applications__c.ANG_Accredited_Agents_Only__c
		};
	}

	public Schema.SObjectType getSObjectType(){
		return Portal_Applications__c.sObjectType;
	}

	/****************************************************************************************************
    	
	****************************************************************************************************/
	public List<Portal_Applications__c> getPortalApplicationsByApplicationsList( Set<String> lstPortalApplicationsIds) {
		String query = String.format(
            'SELECT {0} ' +
            'FROM {1} ' + 
            'WHERE Id IN :lstPortalApplicationsIds ' , 
            new List<String>{
                String.join(getDefaultFields(), ', '),
                getSObjectType().getDescribe().getName()
            }
        );
		
		return Database.query(query);
	}



}