/**
 * Created by bkaya01 on 14/08/2019.
 */

public without sharing class PortalPasswordHandler {

    public class resultWrapper{
        @AuraEnabled
        public String message {get;set;}
        @AuraEnabled
        public boolean success {get;set;}
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
        List<User> userList = [Select id, contactId, uid__c, userName from user where email = :email and contactId != '' and
                                     (isActive = true or portal_user_frozen_checkbox__c = true)];

        if(!userList.isEmpty()){
            user = userList.get(0);
        }
        return user;
    }

    //update user information
    public static boolean updateUserPassword(User user){
        boolean success = true;

        user.uid__c   = Comm_User_Helper.NewGuid();
        user.isActive = true;
        user.portal_user_frozen_checkbox__c = false;

        string password = Comm_User_Helper.generateRandomString(6)+'1a';

        try{
            system.setPassword(user.id, password);
            sendEmail(user,password);
        }
        catch(Exception ex){
            success = false;
        }

        if(success == true) update user;

        return success;
    }

    public static void sendEmail(User user, String password) {
        //get contact information
        Contact contactInfo = [SELECT Id,Email, firstName, LastName,Salutation FROM Contact WHERE ID = :user.contactid limit 1];

        //generate one time link for forgot password
        String cleanUsername = user.userName.replace('+', plusReplacer);
        String encodedPart = 'c=' + EncodingUtil.urlEncode(EncryptString(cleanUsername + SEPARATOR + password + SEPARATOR + user.uid__c), 'UTF-8');

        String prefix   = '';
        if(Network.getNetworkId() != null) prefix = Network.getLoginURL(Network.getNetworkId()).substring(0,Network.getLoginURL(Network.getNetworkId()).indexOf('/login'));
        String link     = prefix + '/firstLogin?' + encodedPart;
        String template = 'CSP_Forgot_Password_Email';
        String imageURL = Label.OneId_Email_Header_Identity;

        Map<String, String> mapBodyParams = new map<String, String>{
                '{!Contact.Salutation}' => contactInfo.Salutation,
                '{!Contact.Password}' => password,
                '{!Receiving_User.FirstName}' => contactInfo.Firstname,
                '{!Receiving_User.LastName}' => contactInfo.LastName,
                '{!Receiving_User.Email}' => contactInfo.Email,
                '{!Community_Name}' => '',
                '{!Community_Url}' => link,
                '{!Community_Header}' => imageURL,
                '{!$Label.ISSP_Email_Here}' => 'here',
                '{!$Label.ISSP_Email_do_not_reply}' => Label.ISSP_Email_do_not_reply,
                '{!$Label.OneId_IATA_represent_lead_and_serve_the_airline_industry}' => Label.OneId_IATA_represent_lead_and_serve_the_airline_industry
        };

        try{
            List<Messaging.SendEmailResult>    listEmailResult = null;
            List<Messaging.SingleEmailmessage> listSingleEmailMessages = new List<Messaging.SingleEmailmessage>();

            EmailTemplate emailTemplate = [SELECT Id,Subject,HtmlValue,Body FROM EmailTemplate WHERE DeveloperName=:template];

            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            OrgWideEmailAddress orgWideEmail  = [SELECT Id,Address FROM OrgWideEmailAddress WHERE Address='noreply@iata.org' Limit 1];
            if(orgWideEmail != null){
                mail.setOrgWideEmailAddressId(orgWideEmail.Id);
            }
            else{
                mail.setSenderDisplayName('IATA Noreply');
            }

            mail.setReplyTo('noreply@iata.org');
            mail.setTargetObjectId(user.Id);
            mail.setSubject(emailTemplate.Subject);

            String htmlBody  = emailTemplate.HtmlValue;
            String plainBody = emailTemplate.Body;
            for(String key : mapBodyParams.keySet()) {
                if(htmlBody <> null && mapBodyParams <> null) {
                    htmlBody  = htmlBody.replace(key, (mapBodyParams.get(key) == null)  ? '' : mapBodyParams.get(key));
                    plainBody = plainBody.replace(key, (mapBodyParams.get(key) == null) ? '' : mapBodyParams.get(key));
                }
            }

            if(htmlBody <> null){
                mail.setHtmlBody(htmlBody);
            }

            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(plainBody);
            listSingleEmailMessages.add(mail);

            if(!Test.isRunningTest()) {
                listEmailResult = Messaging.sendEmail(listSingleEmailMessages);
            }
        }
        catch(Exception ex){
            system.debug(ex.getMessage());
        }
    }

    @AuraEnabled
    public static resultWrapper handleResetPassword(String email){
        resultWrapper result = new resultWrapper();
        //check email validity
        result = checkEmailIsValid(email);

        if(result.success == true){
            User user = getUserFromEmail(email);
            if(user != null){
                result.success = updateUserPassword(user);
            }
            else{
                result.success = false;
            }
        }
        return result;
    }

}