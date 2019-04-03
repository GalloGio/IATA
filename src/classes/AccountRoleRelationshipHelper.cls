public without sharing class AccountRoleRelationshipHelper {
    
	public static void OneId_emailCreatedConnection (List<Account_Role_Relationship__c> ndcRelationshipList) {
        
        try{
            String troubleshooting = Label.NDC_Troubleshooting;
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Id> relIdList = new List<Id>();
            List<Id> airlineIdList = new List<Id>();
            Map<Id, String> accDetailMap = new Map<Id, String>();
            OrgWideEmailAddress address = [SELECT Id 
                                           FROM OrgWideEmailAddress 
                                           WHERE Address = 'noreply@iata.org'];
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            for (Account_Role_Relationship__c rel : ndcRelationshipList) {
                if(rel.Portal_Service__c == oneIdService.Portal_Service__c && rel.Relationship_Type__c == 'NDC Player' && rel.Relationship_Status__c == 'Active') {
                    relIdList.add(rel.Id);
                    airlineIdList.add(rel.To__c);
                }
            }
            
            List<Account_Role_Relationship__c> ndcRelationshipListQuery = [SELECT Id, To__c, From__r.Account__r.Name
                                                                           FROM Account_Role_Relationship__c 
                                                                           WHERE Id =: relIdList];
            
            for (NDC_Account_Service_Detail__c detail : [SELECT Id, Account_Role_Service__r.Account_Role__c, Contact_Email__c 
                                                         FROM NDC_Account_Service_Detail__c
                                                         WHERE Account_Role_Service__r.Account_Role__c =: airlineIdList]) {
                                                             accDetailMap.put(detail.Account_Role_Service__r.Account_Role__c, detail.Contact_Email__c);
                                                         }
            
            for (Account_Role_Relationship__c rel : ndcRelationshipListQuery) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { accDetailMap.get(rel.To__c) };
                    message.optOutPolicy = 'FILTER';
                message.setSaveAsActivity(false);
                message.subject = 'NDC Matchmaking - New Connection';
                message.HtmlBody = 								  'Thank you for using the NDC Matchmaker. ' +
                   																   rel.From__r.Account__r.Name + 
                    ' has created a connection with your company. If you have any issues please contact us ' + 
                   											   									 '<a href="' + 
                   																			 troubleshooting + 
                  																			  '">here.</a>';
                message.setOrgWideEmailAddressId(address.Id);
                mails.add(message);
            }
            Messaging.sendEmail(mails);
        }
        catch (Exception ex){
        }
    }
    
    public static void OneId_emailDeletedConnection (List<Account_Role_Relationship__c> ndcRelationshipList) {

        try{
            String troubleshooting = Label.NDC_Troubleshooting;
            Map<Id, Id> relIdsMap = new Map<Id, String>();
            Map<String, String> emailNameMap = new Map<String, String>();
            Map<Id, NDC_Account_Service_Detail__c> airlineQuery = new Map<Id, NDC_Account_Service_Detail__c>();
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            
            OrgWideEmailAddress address = [SELECT Id 
                                           FROM OrgWideEmailAddress 
                                           WHERE Address = 'noreply@iata.org'];
            
            One_Id_Service_Provider_Config__c oneIdService = [SELECT Portal_Service__c 
                                                              FROM One_Id_Service_Provider_Config__c 
                                                              WHERE Service_Provider_Name__c = 'NDCMM' 
                                                              AND RecordType.DeveloperName = 'Service_Provider' LIMIT 1];
            
            for (Account_Role_Relationship__c rel : ndcRelationshipList) {
                if(rel.Portal_Service__c == oneIdService.Portal_Service__c && rel.Relationship_Type__c == 'NDC Player' && rel.Relationship_Status__c == 'Active') {
                    relIdsMap.put(rel.To__c, rel.From__c);
                }
            }
            
            Map<Id, Account_Role__c> sellerAggregatorQuery = new Map<Id, Account_Role__c>([SELECT Id, Account__r.Name 
                                                                                           FROM Account_Role__c 
                                                                                           WHERE Id =: relIdsMap.values()]);
            
            for (NDC_Account_Service_Detail__c detail : [SELECT Id, Account_Role_Service__r.Account_Role__c, Contact_Email__c 
                                                         FROM NDC_Account_Service_Detail__c
                                                         WHERE Account_Role_Service__r.Account_Role__c =: relIdsMap.keySet()]) {
                                                             airlineQuery.put(detail.Account_Role_Service__r.Account_Role__c, detail);
                                                         }
            
            for (Id airlineId : relIdsMap.keySet()) {
                NDC_Account_Service_Detail__c a = airlineQuery.get(airlineId);
                Account_Role__c s = sellerAggregatorQuery.get(relIdsMap.get(airlineId));
                
                emailNameMap.put(a.Contact_Email__c, s.Account__r.Name);
            }
            
            for (String email : emailNameMap.keySet()) {
                Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
                message.toAddresses = new String[] { email };
                    message.optOutPolicy = 'FILTER';
                message.setSaveAsActivity(false);
                message.subject = 'NDC Matchmaking - Deleted Connection';
                message.HtmlBody = 'Thank you for using the NDC Matchmaker. Your connection with ' +
                    									  				   emailNameMap.get(email) + 
                   				    ' has been deleted. If you have any issues please contact us ' + 
                    																   '<a href="' + 
                    															   troubleshooting + 
                    																'">here.</a>';
                message.setOrgWideEmailAddressId(address.Id);
                mails.add(message);
            }
            Messaging.sendEmail(mails);
        }
        catch (Exception ex){
        }
    }
}