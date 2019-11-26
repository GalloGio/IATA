/**
 * Created by bkaya01 on 14/08/2019.
 */

public without sharing class PortalPasswordHandler {

    public class resultWrapper{
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public boolean success {get;set;}
        @AuraEnabled
        public String password {get;set;}
        @AuraEnabled
        public User user {get;set;}
    }

    public static final string SEPARATOR    = '@#@#@#';
    public static final string KEYTODECODE  = 'Kg0m2vAj4VmBBviGAUehrw==';
    public static final string plusReplacer = '@@##';

    public static String EncryptString(String str) {
        Blob dataToEncrypt = Blob.valueOf(str);
        Blob encryptedData = Crypto.encryptWithManagedIV('AES128', EncodingUtil.base64Decode(KEYTODECODE), dataToEncrypt);
        return EncodingUtil.base64Encode(encryptedData);
    }

    public static String DecryptString(String str) {
        try{Blob encryptedData = Encodingutil.base64Decode(str);
            Blob decryptedData = Crypto.decryptWithManagedIV('AES128', EncodingUtil.base64Decode(KEYTODECODE), encryptedData);
            return decryptedData.toString();
        }catch(Exception e){
            throw new transformationException(''+  e.getMessage() +   '  ' + e.getStackTraceString());
        }
    }

    //check the email is valid
    public static resultWrapper checkEmailIsValid(String email) {
        resultWrapper result = new resultWrapper();
        result.success = true;

        if(!Site.isValidUsername(email)) {
            result.success = false;
            result.message = Label.Site.invalid_email;
        }
        return result;
    }

    //get user information
    public static User getUserFromEmail(String email){
        User user;
        List<User> userList = [Select id, contactId, uid__c, userName, contact.Preferred_Language__c from user where email = :email and contactId != '' and
                                (isActive = true or portal_user_frozen_checkbox__c = true)];

        if(!userList.isEmpty()){
            user = userList.get(0);
        }
        return user;
    }

    //update user information
    public static resultWrapper updateUserPassword(User user){
        resultWrapper result = new resultWrapper();
        result.success = true;
        result.user    = user;

        user.uid__c   = Comm_User_Helper.NewGuid();
        user.isActive = true;
        user.portal_user_frozen_checkbox__c = false;

        update user;

        result.password = Comm_User_Helper.generateRandomString(6)+'1a';

        try{
            system.setPassword(user.id, result.password);
        }
        catch(Exception ex){
            result.message = ex.getMessage();
            result.success = false;
        }

        if(result.success == true) update user;

        return result;
    }

    public static string generateUrl (User user, String password, String pageName){
        String cleanUsername = user.userName.replace('+', plusReplacer);
        String encodedPart = 'c=' + EncodingUtil.urlEncode(EncryptString(cleanUsername + SEPARATOR + password + SEPARATOR + user.uid__c + SEPARATOR + string.valueOf(system.now())), 'UTF-8');

        String languageParam = '';

        if(user.contact.Preferred_Language__c != null){
            for(Preferred_Language_on_ISS_Portal__c portalLang : Preferred_Language_on_ISS_Portal__c.getAll().values()){
                if(user.contact.Preferred_Language__c == portalLang.language__c){
                    languageParam = 'language=' + portalLang.languageLocalKey__c + '&';
                    break;
                }
            }
        }

        String prefix = '';
        List<Network> networkList = [Select id from Network where name =: 'CS Portal' Limit 1];
        if(!test.isRunningTest()){
            if(!networkList.isEmpty()) prefix = Network.getLoginURL(networkList.get(0).Id).substring(0,Network.getLoginURL(networkList.get(0).Id).lastIndexOf('/'));
        }
        String link = prefix + '/' + pageName + '?' + languageParam + encodedPart;
        return link;
    }

    public static Map<String, String> forgotPasswordEmailMap(User user, String link){
        //get contact information
        Contact contactInfo = [SELECT Id,Email, firstName FROM Contact WHERE ID = :user.contactid limit 1];

        String headerImageName = Label.CSP_Email_Header_Image;
        String footerImageName = Label.CSP_Email_Footer_Image;

        String headerImageUrl;
        String footerImageUrl;

        Map<String,Id> docNameIdMap = new Map<String,Id>();
        for(Document doc : [Select id, name From Document Where name = :headerImageName or name= :footerImageName]){
            docNameIdMap.put(doc.name,doc.id);
        }

        if(docNameIdMap.get(headerImageName) != null) headerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(headerImageName)+'&oid='+userinfo.getorganizationid();
        if(docNameIdMap.get(footerImageName) != null) footerImageUrl = URL.getSalesforceBaseUrl().getProtocol()+'://'+System.URL.getSalesforceBaseUrl().getHost().remove('-api' )+'/servlet/servlet.ImageServer?id='+docNameIdMap.get(footerImageName)+'&oid='+userinfo.getorganizationid();

        Map<String, String> mapBodyParams = new map<String, String>{
                '{!HeaderUrl}'                                   => headerImageUrl,
                '{!FooterUrl}'                                   => footerImageUrl,
                '{!Receiving_User.FirstName}'                    => contactInfo.Firstname,
                '{!Community_Url}'                               => link,
                '{!$Label.CSP_Email_Here}'                       => Label.CSP_Email_Here,
                '{!$Label.CSP_Dear}'                             => Label.CSP_Dear,
                '{!$Label.CSP_Email_Password_Reset_Body_Part_1}' => Label.CSP_Email_Password_Reset_Body_Part_1,
                '{!$Label.CSP_Email_Password_Reset_Body_Part_2}' => Label.CSP_Email_Password_Reset_Body_Part_2,
                '{!$Label.CSP_Email_Password_Reset_Body_Part_3}' => Label.CSP_Email_Password_Reset_Body_Part_3,
                '{!$Label.CSP_Email_Password_Reset_Body_Part_4}' => Label.CSP_Email_Password_Reset_Body_Part_4,
                '{!$Label.CSP_Email_Signature_Part_1}'           => Label.CSP_Email_Signature_Part_1,
                '{!$Label.CSP_Email_Signature_Part_2}'           => Label.CSP_Email_Signature_Part_2
        };
        return mapBodyParams;
    }

    public static boolean sendEmail(Id userId, String template, Map<String, String> mapBodyParams) {
        boolean success = true;

        try{
            List<Messaging.SendEmailResult>    listEmailResult = null;
            List<Messaging.SingleEmailmessage> listSingleEmailMessages = new List<Messaging.SingleEmailmessage>();

            EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName=:template Limit 1];
            Messaging.SingleEmailMessage message = Messaging.renderStoredEmailTemplate(emailTemplate.Id, userId, null);

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress orgWideEmail  = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address='noreply@iata.org' Limit 1];
            if(orgWideEmail != null){
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            else{
                mail.setSenderDisplayName('IATA Noreply');
            }

            mail.setReplyTo('noreply@iata.org');
            mail.setTargetObjectId(userId);
            mail.setSubject(emailTemplate.Subject);

            String plainBody = message.getPlainTextBody();
            for(String key : mapBodyParams.keySet()) {
                if(plainBody <> null && mapBodyParams <> null) {
                    plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                }
            }

            if(plainBody <> null) mail.setHtmlBody(plainBody);

            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            listSingleEmailMessages.add(mail);

            if(!Test.isRunningTest())  listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
        }
        catch(Exception ex){
            success = false;
        }

        return success;
    }

    @AuraEnabled
    public static resultWrapper handleResetPassword(String email){
        resultWrapper result = new resultWrapper();
        //check email validity
        result = checkEmailIsValid(email);
        if(result.success == true){
            result.user = getUserFromEmail(email);
            if(result.user != null){
                result = updateUserPassword(result.user);
            }
            else{
                result.success = false;
            }
        }
        return result;
    }

    @AuraEnabled
    public static resultWrapper changePassword(String currentPassword, String newPassword, String confirmPassword){
        resultWrapper result = new resultWrapper();
        result.success = true;
        try{
            PageReference pageRef = Site.changePassword(newPassword, confirmPassword, currentPassword);
        }
        catch(Exception ex){
            result.success = false;
            result.message = Label.CSP_Change_Password_Error;
        }
        return result;
    }

}