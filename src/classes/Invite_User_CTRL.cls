public without sharing class Invite_User_CTRL {
    @AuraEnabled
    public static user getCurrenthUserInfo(){
        User oUser = [select id, UserType FROM User Where id =: userInfo.getUserId()];
        return oUser;
    }
    @AuraEnabled
    public static List<Account> getGadmActors() {
        List<Account> gadmActors = new List<Account>();

        List<Account_Roles__c> gadmParticipant = [SELECT Id FROM Account_Roles__c WHERE Name = 'GADM Participant' LIMIT 1];
        if(! gadmParticipant.isEmpty()) {
            Date today = System.today();

            List<Account_Role__c> accountRoles = [SELECT Id, Account__c FROM Account_Role__c WHERE Status__c = 'Active' AND Effective_From_Date__c <= :today AND Effective_To_Date__c >= :today AND Account_Roles__c = :gadmParticipant];
            if(! accountRoles.isEmpty()) {
                Set<Id> actorIds = new Set<Id>();
                for(Account_Role__c accountRole : accountRoles) {
                    actorIds.add(accountRole.Account__c);
                }
                if(! actorIds.isEmpty()) {
                    List<Account> gadmList = [SELECT Id, Name FROM Account WHERE Id = :actorIds];
                    if(! gadmList.isEmpty()) {
                        gadmActors = gadmList;
                    }
                }
            }
        }

        return gadmActors;
    }

    @AuraEnabled
    public static Map<Id, List<String>> getActorsAllowedDomains(String actors) {
        Map<Id, List<String>> actorIdToDomainsMap = new Map<Id, List<String>>();

        if(String.isNotBlank(actors)) {

            List<Account> actorsList = null;

            try{
                actorsList = (List<Account>)JSON.deserialize(actors, List<Account>.class);
            }catch(JSONException e) {
                //JSON error
            }

            if(actorsList != null && !actorsList.isEmpty()) {

                Set<Id> actorIds = new Set<Id>();
                for(Account actor : actorsList) {
                    actorIds.add(actor.Id);
                }

                List<GADM_Account_Service_Detail__c> serviceDetailsList = [SELECT Id, Allowed_email_domain__c, Account_Role_Service__r.Account_Role__r.Account__c FROM GADM_Account_Service_Detail__c WHERE Account_Role_Service__r.Account_Role__r.Account__c = :actorIds];

                for(GADM_Account_Service_Detail__c detail : serviceDetailsList) {
                    if(detail.Allowed_email_domain__c != null) {
                        List<String> domainsList = new List<String>();
                        if(detail.Allowed_email_domain__c.indexOf(';') > -1) {
                            List<String> tempList = detail.Allowed_email_domain__c.split(';');
                            for(String domain : tempList) {
                                domainsList.add(domain.trim());
                            }
                        }else{
                            domainsList.add(detail.Allowed_email_domain__c);
                        }

                        actorIdToDomainsMap.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, domainsList);

                    }else{//nothing in Allowed_email_domain__c field
                        actorIdToDomainsMap.put(detail.Account_Role_Service__r.Account_Role__r.Account__c, new List<String>());
                    }
                }
            }

        }

        return actorIdToDomainsMap;
    }

    @AuraEnabled
    public static string sendInvitation(string contactStr, string invitationStr) {
        Invitation__c invitation = null;
        Contact contact = null;
        try{
            contact = (Contact)JSON.deserialize(contactStr, Contact.Class);
        } catch (Exception ex){}
        try{
            invitation = (Invitation__c)JSON.deserialize(invitationStr, Invitation__c.Class);

        } catch (Exception ex){}

        try{
            if(contact == null && invitation != null){
                insert invitation;
                invitation = [SELECT Id, Salutation__c, AccountId__c, Email__c, Last_Name__c, First_Name__c FROM Invitation__c WHERE Id =: invitation.Id];
                return sendEmail(true, invitation);
            } else if (contact != null) {
                return sendEmail(false, contact);
            }
            return invitationStr;
        } catch(Exception e) {
            return 'err:'+e.getMessage();
        }
    }

    private static string sendEmail(boolean newUser, SObject obj){

        string linkSuffix = '';
        string emailTemplate = '';
        string emailAddress = '';
        String userName = '';
        Id whatId = null;
        Id accountId = null;

        if (newUser){
            emailTemplate = 'Invite_user_new';
            linkSuffix = '/login/SelfRegister?serviceName=GADM&token='+obj.get('Id');
            Invitation__c invitation = (Invitation__c)obj;
            emailAddress = invitation.Email__c;
            whatId = invitation.Id;
            accountId = invitation.AccountId__c;


            if((invitation.Last_Name__c != null && invitation.Last_Name__c != '') && (invitation.First_Name__c != null && invitation.First_Name__c != '')) {
                userName = invitation.First_Name__c + ' ' + invitation.Last_Name__c;
            }else if((invitation.Salutation__c != null && invitation.Salutation__c != '') && (invitation.Last_Name__c != null && invitation.Last_Name__c != '')) {
                userName = invitation.Salutation__c + invitation.Last_Name__c;
            }else if(invitation.First_Name__c != null && invitation.First_Name__c != '') {
                userName = invitation.First_Name__c;
            }else{
                userName = 'User';
            }

        } else {
            emailTemplate = 'Invite_user_already_exists';
            linkSuffix = '/login/';
            Contact con = (Contact)obj;
            emailAddress = con.Email;
            whatId = con.Id;
            accountId = con.Account.Id;
        }

        string accountName = '';

        if (accountId != null){
            List<Account> accs = [SELECT Id, Name FROM Account WHERE Id = :accountId];
            if(accs != null && accs.size() > 0){
                accountName = accs[0].Name;
            }
        }

        Id iataNoReplyId = null;
        OrgWideEmailAddress[] iataNoReply = [select Id from OrgWideEmailAddress where Address = 'noreply@iata.org'];
        if(iataNoReply != null && iataNoReply.size() > 0){
            iataNoReplyId = iataNoReply.get(0).Id;
        }

        EmailTemplate et = [SELECT Id, Name, Subject, Body FROM EmailTemplate WHERE DeveloperName =: emailTemplate];
        Messaging.SingleEmailMessage mail = Messaging.renderStoredEmailTemplate(et.Id, UserInfo.getUserId(), whatId);
        string link = OneIdUtils.getSiteCompleteUrl(OneIdUtils.Mode.IDENTITY) + linkSuffix;

        mail.setToAddresses(new List<string>{emailAddress});
        mail.setSaveAsActivity(false);
        if(iataNoReplyId != null) {
            mail.setOrgWideEmailAddressId(iataNoReplyId);
        }
        mail.setUseSignature(false);
        mail.setTreatTargetObjectAsRecipient(false);
        string body = mail.getHtmlBody();
        if(newUser) {
            mail.setHtmlBody(body.replace('*link*', link).replace('*userName*', userName).replace('*account*', accountName));
            mail.setPlainTextBody(body.replace('*link*', link).replace('*userName*', userName).replace('*account*', accountName));

        }else{
            mail.setHtmlBody(body.replace('*link*', link).replace('*account*', accountName));
            mail.setPlainTextBody(body.replace('*link*', link).replace('*account*', accountName));
        }

        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        allmsg.add(mail);

        try {
            Messaging.sendEmail(allmsg,false);
            return 'sent';
        } catch (Exception e) {
            return e.getMessage();
        }
    }
    @AuraEnabled
    public static List<Account> getUserAccounts(){

        List<Account> accountsToReturn = new List<Account>();

        Id userId = UserInfo.getUserId();
        List<Account> userAccounts = Contact_Roles_Helper.getUserAccounts(userId);

        if(userAccounts != null && userAccounts.size() > 0) {

            Date today = System.today();

            List<Account_Role__c> accountRoles = [SELECT Id, Account__c, Status__c, Effective_From_Date__c, Effective_To_Date__c FROM Account_Role__c WHERE Status__c = 'Active' AND (Effective_From_Date__c <= :today AND Effective_To_Date__c >= :today) AND Account__c =:userAccounts];
            if(! accountRoles.isEmpty()) {
                Set<Id> accountIds = new Set<Id>();

                for(Account_Role__c accountRole : accountRoles) {
                    accountIds.add(accountRole.Account__c);
                }

                if(! accountIds.isEmpty()) {
                    for(Account acc : userAccounts) {
                        if(accountIds.contains(acc.Id)) {
                            accountsToReturn.add(acc);
                        }
                    }
                }

            }

        }

        return accountsToReturn;
    }
    @AuraEnabled
    public static List<OneId_RegistrationProcessController.PicklistEntry> getContactJobFunctionValues() {
        return OneId_RegistrationProcessController.getContactJobFunctionValues();
    }
    @AuraEnabled
    public static Map<String,String> getContactLabels() {
        return OneId_RegistrationProcessController.getContactLabels();
    }
    @AuraEnabled
    public static UserInformationWrapper getUserInformationFromEmail(String email, String serviceName){
        List<Contact> existingContacts = OneId_RegistrationProcessController.returnExistingContact(email);

        boolean emailAddressAvailable = OneId_RegistrationProcessController.checkIsUsernameIsAvailableInGlobalSalesforce(email, existingContacts);
        boolean contactExists = existingContacts.size() > 0;
        boolean contactOrUserExists = !emailAddressAvailable || contactExists;

        UserInformationWrapper wrapper = new UserInformationWrapper(
                contactExists ? existingContacts[0] : null, new Invitation__c(Email__c=email)
        );

        wrapper.showNotifyButton = !(!emailAddressAvailable && !contactExists);

        wrapper.createNewInvitation = !contactOrUserExists;
        if(emailAddressAvailable && contactExists){
            Contact con = existingContacts[0];
            Account acc = [SELECT Id, Top_Parent__c	FROM Account WHERE Id =: con.AccountId][0];
            Invitation__c invitation = new Invitation__c();
            invitation.AccountId__c = acc.Top_Parent__c != null ? acc.Top_Parent__c : con.AccountId;
            invitation.Business_Fax__c = con.Fax;
            invitation.Business_Phone__c = con.Phone;
            invitation.Email__c = con.Email;
            invitation.First_Name__c = con.FirstName;
            invitation.Last_Name__c = con.LastName;

            invitation.Job_Title__c = con.Title;
            invitation.Mobile_Phone__c = con.MobilePhone;
            invitation.Salutation__c = con.Salutation;
            wrapper.invitation = invitation;
            wrapper.contact = null;
        }

        if(!emailAddressAvailable && !contactExists){
            //internal user
            wrapper.invitation = null;
            wrapper.contact = null;
        }

        return wrapper;
    }

    @AuraEnabled
    public static String findLocation(){

        String ipAddress = '92.104.157.175';

        if(!Test.isRunningTest()) {
            Map<String,String> currentSessionAttributes = Auth.SessionManagement.getCurrentSession();
            ipAddress = currentSessionAttributes.get('SourceIp');
        }

        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://ipinfo.io/' + ipAddress + '/json?token=' + ISSP_CS__c.getInstance('ipinfo_token').Value__c);
        req.setMethod('GET');
        req.setTimeout(2000);
        HttpResponse res;

        try{
            res = new Http().send(req);
            Map<String, String> response = (Map<String, String>)JSON.deserialize(res.getBody(), Map<String, String>.class);
            return response.get('country');

        }catch(Exception e){
            System.debug('Exception findLocation Invite_User_CTRL...' + e);
            return e.getMessage();
        }
    }



    public class UserInformationWrapper{
        @AuraEnabled
        public boolean createNewInvitation{get;set;}
        @AuraEnabled
        public boolean showNotifyButton{get;set;}
        @AuraEnabled
        public Invitation__c invitation {get;set;}
        @AuraEnabled
        public Contact contact {get;set;}
        public UserInformationWrapper(Contact contact, Invitation__c invitation){
            this.contact = contact;
            this.invitation = invitation;
        }
    }
}