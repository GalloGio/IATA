/**
 * Created by bkaya01 on 27/08/2019.
 */

public without sharing class PortalCreatePasswordController {

    public class returnWrapper{
        @AuraEnabled
        public String registrationParameters {get;set;}
        @AuraEnabled
        public boolean isUserExist {get;set;}
        @AuraEnabled
        public boolean isExpired {get;set;}

    }

    @AuraEnabled
    public static returnWrapper getParameters(String urlExtension){
        returnWrapper result  = new returnWrapper();
        result.isExpired      = false;
        PageReference pageRef = new PageReference(urlExtension);
        String parameters     = pageRef.getParameters().get('c');
        parameters            = Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters), 'UTF-8');

        //get registration information
        PortalRegistrationFirstLevelCtrl.RegistrationParameters registrationParameters = (PortalRegistrationFirstLevelCtrl.RegistrationParameters) JSON.deserialize(parameters, PortalRegistrationFirstLevelCtrl.RegistrationParameters.class);
        registrationParameters.email  = registrationParameters.email.replace(PortalPasswordHandler.plusReplacer,'+');
        result.isUserExist            = isUserExist(registrationParameters.email, registrationParameters.contactId);
        result.registrationParameters = JSON.serialize(registrationParameters);

        if(system.now() > datetime.valueOf(registrationParameters.registrationTime).addHours(8)) result.isExpired = true;

        return result;
    }

    @AuraEnabled
    public static boolean isUserExist(String email, String contactId) {
        boolean isExist = false;
        if(contactId == null || contactId == ''){
            List<Contact> contactList = [Select id from contact where email =: email];
            if(!contactList.isEmpty()) isExist = true;
        }

        List<User> userList = [Select id from user where email =: email];
        if(!userList.isEmpty()) isExist = true;
        return isExist;
    }

    @AuraEnabled
    public static PortalRegistrationFirstLevelCtrl.RegistrationResult createUserAndSetPassword(String paramStr, String password){
        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = (PortalRegistrationFirstLevelCtrl.RegistrationParameters) JSON.deserialize(paramStr, PortalRegistrationFirstLevelCtrl.RegistrationParameters.class);
        PortalRegistrationFirstLevelCtrl.RegistrationResult result     = PortalRegistrationFirstLevelCtrl.register(params, password);

        if(result.isSuccess == true){
            try{
                System.PageReference pageRef = Site.login(result.username, password, Label.CSP_PortalPath + '?firstLogin=true');
                result.message = pageRef.getUrl();
            }
            catch(Exception ex){
                result.isSuccess = false;
                result.message   = ex.getMessage();
            }
        }
        return result;
    }

    @AuraEnabled
    public static boolean resendEmail(String paramStr) {
        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = (PortalRegistrationFirstLevelCtrl.RegistrationParameters) JSON.deserialize(paramStr, PortalRegistrationFirstLevelCtrl.RegistrationParameters.class);
        params.registrationTime = string.valueOf(system.now());
        boolean success = PortalRegistrationFirstLevelCtrl.sendRegistrationEmail(params);
        return success;
    }

}