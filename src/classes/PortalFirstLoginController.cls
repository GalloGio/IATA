public without sharing class PortalFirstLoginController {

    @AuraEnabled
    public static void redirectToChangePasswordPage(String urlExtension){
        PageReference pageRef = new PageReference(urlExtension);
        String parameters = pageRef.getParameters().get('c');
        parameters =  Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(parameters),'UTF-8') ;

        List<String> paramList =  parameters.split(PortalPasswordHandler.SEPARATOR,-1);
        
        String userName = paramList[0].replace(PortalPasswordHandler.plusReplacer, '+');
        String password = paramList[1];
        string UID      = paramList[2];
 
        string ids = '';
        if (!String.isEmpty(userName)) {
            List<User> user = [Select Id, Username, UID__c from user where username = :userName OR email = :userName];

            if (user <> null && user.size() > 0) {
                if (user[0].UID__c == UID) {
                    ids = user[0].id;

                    if (!test.isRunningTest()) {
                        //redirect create password
                        aura.redirect(Site.login(userName, password, Label.CSP_PortalPath + 'createPassword'));
                     }
                }
                else {
                    //redirect to login page
                    aura.redirect(new PageReference(Network.getLoginURL(Network.getNetworkId())));
                }
            }
        }
    }

}