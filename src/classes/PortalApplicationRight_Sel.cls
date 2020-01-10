public with sharing class PortalApplicationRight_Sel extends Selector {
	private static final integer CONTACTSBATCH =50; // returns batches of 50 contacts in the

	public List<Schema.SObjectField> getSObjectFieldList(){
		return new List<Schema.SObjectField> {
			Portal_Application_Right__c.Id,
			Portal_Application_Right__c.Portal_Application__c,
			Portal_Application_Right__c.Contact__c,
			Portal_Application_Right__c.Right__c,
			Portal_Application_Right__c.Technical_Provisioning_Status__c,
			Portal_Application_Right__c.IsSCIMIFG__c,
			Portal_Application_Right__c.Is_Favorite__c
		};
	}

	public List<String> getSObjectFieldListForWithContactInfo(){
		return new List<string> {
			'Portal_Application_Right__c.Application_Name__c',
			'Portal_Application_Right__c.Portal_Application__r.Service_Description__c',
			'Portal_Application_Right__c.Portal_Application__r.Service_Description_Label__c',
			'Portal_Application_Right__c.Portal_Application__r.Requestable__c',
			'Portal_Application_Right__c.Portal_Application__r.Cannot_be_managed_by_portal_admin__c',
			'Portal_Application_Right__c.Application_icon_del__c',
			'Portal_Application_Right__c.Portal_Application__r.New_Window__c',
			'Portal_Application_Right__c.Right__c',
			'Portal_Application_Right__c.Portal_Application__r.Application_icon_URL__c',
			'Portal_Application_Right__c.Portal_Application__c',
			'Portal_Application_Right__c.My_Apps__c',
			'Portal_Application_Right__c.Contact__c',
			'Portal_Application_Right__c.Application_Start_URL__c',
			'Portal_Application_Right__c.Case_creation_record_Type__c',
					'Portal_Application_Right__c.IsSCIMIFG__c',
					'Technical_Provisioning_Status__c',
			'Portal_Application_Right__c.Contact__r.Id',
			'Portal_Application_Right__c.Contact__r.Name',
			'Portal_Application_Right__c.Contact__r.Email',
			'Portal_Application_Right__c.Contact__r.AccountId',
			'Portal_Application_Right__c.Contact__r.FirstName',
			'Portal_Application_Right__c.Contact__r.LastName',
			'Portal_Application_Right__c.Contact__r.Account.Name',
			'Portal_Application_Right__c.ANG_Portal_Service_Role__c',
			'Portal_Application_Right__c.Contact__r.User_Portal_Status__c',
			'Portal_Application_Right__c.Contact__r.Status__c',
			'Portal_Application_Right__c.Account__c',
			'Portal_Application_Right__c.Contact__r.Account.IATACode__c',
			'Portal_Application_Right__c.Contact__r.Account.BillingCity',
			'Portal_Application_Right__c.Contact__r.Account_Country__c'
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
	public integer getTotalNrContacts(string serviceId){
		string access_granted=PortalServicesCtrl.PORTAL_ACCESS_GRANTED;
		string access_requested=PortalServicesCtrl.PORTAL_ACCESS_REQUESTED;
		string access_denied=PortalServicesCtrl.PORTAL_ACCESS_DENIED;

		String query = String.format(
			'SELECT count() ' +
			'FROM {1} ' +
			'where Portal_Application__c =:serviceId '+
			'and (Right__c =:access_granted or Right__c =:access_requested or Right__c =:access_denied) '+
			'and Portal_Application__r.Hide_on_Homepage__c = false ',
			new List<String>{
				String.join(getSObjectFieldListForWithContactInfo(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);
		return Database.countQuery(query);
	}
	public List<Portal_Application_Right__c> getPortalApplicationRightsByPortalService(String serviceId,integer offset) {
		return getPortalApplicationRightsByPortalService(serviceId,offset,'');
	}

	public List<Portal_Application_Right__c> getPortalApplicationRightsByPortalService(String serviceId,integer offset,String extraFilter) {
		string access_granted=PortalServicesCtrl.PORTAL_ACCESS_GRANTED;
		string access_requested=PortalServicesCtrl.PORTAL_ACCESS_REQUESTED;
		string access_denied=PortalServicesCtrl.PORTAL_ACCESS_DENIED;

		string range='';
		if(offset!=null){
			range=' ORDER BY Portal_Application_Right__c.Contact__r.Name ASC LIMIT '+CONTACTSBATCH+' OFFSET '+offset;
		}


		String query = String.format(
			'SELECT {0} , Portal_Application__r.Name ' +
			'FROM {1} ' +
			'where Portal_Application__c =:serviceId '+
			'and (Right__c =:access_granted or Right__c =:access_requested or Right__c =:access_denied) '+
			'and Portal_Application__r.Hide_on_Homepage__c = false ',
			new List<String>{
				String.join(getSObjectFieldListForWithContactInfo(), ', '),
				getSObjectType().getDescribe().getName()
			}
		)
		+extraFilter
		+range;
		system.debug(query.right(250));
		return Database.query(query);
	}



}
