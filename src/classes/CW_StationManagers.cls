public without sharing class CW_StationManagers {

    @AuraEnabled(cacheable = false)
	public static string getAllAccountContactRoles(String accountRoleDetailId){
        return (JSON.serialize(CW_Utilities.getStationManagersContactRoleDetails(accountRoleDetailId)));
    }

    @AuraEnabled(cacheable = false)
	public static string deleteAccountContactRole(String contactRoleDetailId, Boolean isCompanyAdmin){
        try {
            String status =  isCompanyAdmin ? 'Removed' : 'Pending for Removal';
            ICG_Contact_Role_Detail__c cRd = [Select Id, ContactId__c, status__c, Contact_Role_Remove_Requestor__c, Account_Contact_Role__r.Contact__r.Email, ICG_Account_Role_Detail__r.Account_Role__r.Account__c from ICG_Contact_Role_Detail__c where Id=:contactRoleDetailId];  
			cRd.status__c = status;
			cRd.Contact_Role_Remove_Requestor__c = UserInfo.getUserId();
            upsert cRd;

            if(status.equals('Pending for Removal')){
                String whoId = cRd.ContactId__c;
                String templateName;
                //Send remove confirmation to removed station manager
                templateName = 'Station_Manager_to_requestor_req_sent';
                List<String> whoEmails = new List<String>{cRd.Account_Contact_Role__r.Contact__r.Email};
                CW_Utilities.sendEmailTemplate(templateName, cRd.Id, whoId, whoEmails, true);
            
                //Send remove confirmation to CompanyAdmins
                templateName = 'Approve_Reject_Remov_to_comp_adm';
                List<String> whoEmailsCompanyAdmins = new List<String>();
                for (Contact cadmn : CW_Utilities.getCompanyAdminContactsFromAccountId(cRd.ICG_Account_Role_Detail__r.Account_Role__r.Account__c)){
                    whoEmailsCompanyAdmins.add(cadmn.Email);
                }
                CW_Utilities.sendEmailTemplate(templateName, cRd.Id, whoId, whoEmailsCompanyAdmins, false);

                if(whoEmailsCompanyAdmins.isEmpty()){
                    //Send remove confirmation to IATA
                    templateName = 'Approve_Reject_Remov_to_IATA_no_comp_adm';
                    List<String> whoEmailsIATA = CW_Utilities.getIATAStakeholdersEmails();
                    CW_Utilities.sendEmailTemplate(templateName, cRd.Id, whoId, whoEmailsIATA, false);
                }
            }

            return status;
        } catch (DmlException  exc) {
			throw new AuraHandledException('exception: ' + exc);
		} 
    }


    @AuraEnabled(cacheable = true)
	public static string getContactsToAdd(String stationId){
        Set<Id> relatedAccounts = CW_Utilities.getRelatedAccountsByStation(stationId);
        List<Contact> contacts = [Select Id, Name from Contact WHERE AccountId in :relatedAccounts];
        return JSON.serialize(contacts);
    }

}