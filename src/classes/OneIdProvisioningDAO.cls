/**
 * Created by Manuel Conde on 14/03/2017.
 */
public class OneIdProvisioningDAO {

    public  static Map<string,map<string,id>> AppRecordTypesConfig = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string>{'One_Id_Service_Provider_Config__c'});

    public static List<One_Id_Service_Provider_Config__c> getFilteredServiceBundles(Account filter){

        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        /*if(filter != null && !String.isBlank(filter.Sector__c) && String.isBlank(filter.Category__c)){

          System.debug('selecting with filtering ' + filter);


        }
        else{

            toReturn = [select id,One_Id_Service_Provider_Config__c, Connected_App_SSO_Name__c,PermissionSet_SSO__c,Connected_App_Provisioning_Name__c, Connected_App_SSO_Name__c,
                      Service_Bundle__r.App_Picture_Url__c,Service_Bundle__r.Description__c,Service_Bundle__r.Portal_Visible__c,Service_Bundle__r.License_Upgrade_Required__c,Service_Bundle__r.Profile_Id__c,Sector__c,Service_Bundle__r.Service_Provider_Name__c,
                    One_Id_Service_Provider_Config__r.Service_Provider_Name__c

            	 from One_Id_App_Config_Detail__c where  Service_Bundle__r.Is_Active__c = true and One_Id_Service_Provider_Config__r.Is_Active__c = true]

        }*/

        return toReturn;

    }
/*
    public static List<One_Id_Service_Provider_Config__c> getFilteredServiceBundles(){
        
        Account theAccount;
        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        List<User> lstUser = [Select u.Id,u.ContactId from User u where u.Id = :UserInfo.getUserId()];

        if( lstUser != null && lstUser.size() > 0 && lstUser[0].ContactId <> null){
            System.debug('lstUser[0].ContactId::' + lstUser[0].ContactId);
            Contact theContact = [select id, account.id from contact where id = :lstUser[0].ContactId];

            if(theContact <> null){
                theAccount = new Account();
                theAccount.id = theContact.account.id;
                //theAccount.sector__c = theContact.account.sector__c;
                //theAccount.category__c = theContact.account.category__c;
            }

        }

        if(theAccount <> null){
            toReturn = OneIdProvisioningDAO.getFilteredServiceBundles(theAccount);
        }

        return toReturn;

    }
*/
    public static List<One_Id_Service_Provider_Config__c> getAppListForAppicker(){

        Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get('Service_Bundle');

        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_Service_Provider_Config__c> bundlesAvailable = new List<One_Id_Service_Provider_Config__c>();
        Map<String, One_Id_User_Applications__c> usrMap = new Map<String, One_Id_User_Applications__c>();

        List<One_Id_User_Applications__c> userAppsList = [select One_Id_App_Bundle__c, id, Application__c,One_Id_Service_Provider_Config__c, User_Provisioning_Request__c from One_Id_User_Applications__c
                                                        where Identity_User__c = :UserInfo.getUserId() and Provisioning_Status__c <> 'Deleted' order by createdDate limit 100];

        bundlesAvailable = [select id, Service_Provider_Name__c,Description__c,App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c
                             from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
                             and RecordTypeid = :recTypeId order by createdDate desc limit 500];


        for(One_Id_User_Applications__c anUap : userAppsList){
            usrMap.put(anUap.One_Id_App_Bundle__c, anUap);
        }
        System.debug('usrMap ' + usrMap.keySet());


        for(One_Id_Service_Provider_Config__c testBundle : bundlesAvailable){
            System.debug('testBundle ' + testBundle);
            if(!usrMap.containsKey(testBundle.id)){
                toReturn.add(testBundle);
            }
        }
        return toReturn;

    }

    public static List<One_Id_App_Role_Config__c> getAppRolesListForAppicker(String bundleName){


        List<One_Id_App_Role_Config__c> toReturn = new List<One_Id_App_Role_Config__c>();

        if(String.isNotBlank(bundleName)) {
            toReturn = [select Role_Name__c, Role_Description__c, Bundle_Name__c
                    from One_Id_App_Role_Config__c where Bundle_Name__c = :bundleName limit 10];
        }

        return toReturn;

    }

    public static List<One_Id_Service_Provider_Config__c> getAppPicListForAppicker(String bundleName){


        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if(String.isNotBlank(bundleName)) {

            Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get(
                    'Service_Bundle');

            toReturn = [select id, Service_Provider_Name__c,Description__c,App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c
                    from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
                    and RecordTypeid = :recTypeId and Service_Provider_Name__c = :bundleName limit 1];
        }

        return toReturn;

    }

    public static List<One_Id_Service_Provider_Config__c> getAppDescListForAppicker(String bundleName){


        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if(String.isNotBlank(bundleName)) {

            Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get(
                    'Service_Bundle');

            toReturn = [select id, Service_Provider_Name__c,Description__c,App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c
                    from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
            and RecordTypeid = :recTypeId and Service_Provider_Name__c = :bundleName limit 1];
        }

        return toReturn;

    }

    public static List<One_Id_App_Config_Detail__c> getAppPermissionSetListForAppicker(String bundleName){


        List<One_Id_Service_Provider_Config__c> temp = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_App_Config_Detail__c> toReturn = new List<One_Id_App_Config_Detail__c>();
        Map<String, One_Id_App_Config_Detail__c> mapOfApps = new Map<String, One_Id_App_Config_Detail__c>();

        if(String.isNotBlank(bundleName)) {

            Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get(
                    'Service_Bundle');

            temp = [select id, Service_Provider_Name__c,Description__c,App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c,
                    Service_Bundle__r.Service_Provider_Name__c,
                    (select id, Connected_App_Provisioning_Name__c, PermissionSet_Provisioning__c, PermissionSet_SSO__c,One_Id_Service_Provider_Config__r.id,One_Id_Service_Provider_Config__r.Service_Provider_Name__c,
                            One_Id_Service_Provider_Config__r.Service_Bundle__r.id,One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c from One_Id_App_Config_Details__r)
                    from One_Id_Service_Provider_Config__c where Is_Active__c = true and Service_Bundle__r.Is_Active__c = true and Service_Bundle__r.Portal_Visible__c = true
            and Service_Bundle__r.RecordTypeid = :recTypeId and Service_Bundle__r.Service_Provider_Name__c = :bundleName limit 500];


            if(!temp.isEmpty()){

                for(One_Id_Service_Provider_Config__c sp : temp){
                    System.debug('sp ' + sp);
                    for(One_Id_App_Config_Detail__c app : sp.One_Id_App_Config_Details__r){
                        System.debug('app ' + app);
                        mapOfApps.put(app.Connected_App_Provisioning_Name__c, app);
                    }

                }

                if(!mapOfApps.isEmpty()) toReturn.addAll(mapOfApps.values());
            }
        }

        return toReturn;

    }


    public static List<One_Id_App_Config_Detail__c> getAppPermissionSetListForSSO(){


        List<One_Id_Service_Provider_Config__c> temp = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_App_Config_Detail__c> toReturn = new List<One_Id_App_Config_Detail__c>();
        Map<String, One_Id_App_Config_Detail__c> mapOfApps = new Map<String, One_Id_App_Config_Detail__c>();



        Id recTypeId = OneIdProvisioningDAO.AppRecordTypesConfig.get('One_Id_Service_Provider_Config__c').get(
                'Service_Bundle');

        temp = [select id, Service_Provider_Name__c,Description__c,App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c,
                Service_Bundle__r.Service_Provider_Name__c,
                (select id, Connected_App_Provisioning_Name__c, PermissionSet_Provisioning__c, PermissionSet_SSO__c,One_Id_Service_Provider_Config__r.id,One_Id_Service_Provider_Config__r.Service_Provider_Name__c,
                        One_Id_Service_Provider_Config__r.Service_Bundle__r.id,One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c from One_Id_App_Config_Details__r)
                from One_Id_Service_Provider_Config__c where Is_Active__c = true and Service_Bundle__r.Is_Active__c = true and Service_Bundle__r.Portal_Visible__c = true
        and Service_Bundle__r.RecordTypeid = :recTypeId limit 500];


        if(!temp.isEmpty()){

            for(One_Id_Service_Provider_Config__c sp : temp){
                System.debug('sp ' + sp);
                for(One_Id_App_Config_Detail__c app : sp.One_Id_App_Config_Details__r){
                    System.debug('app ' + app);
                    mapOfApps.put(app.Connected_App_Provisioning_Name__c, app);
                }

            }

            if(!mapOfApps.isEmpty()) toReturn.addAll(mapOfApps.values());
        }

        return toReturn;

    }
}