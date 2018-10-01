/**
 * Created by Manuel Conde on 14/03/2017.
 */
public class OneIdProvisioningDAO {


    public static List<One_Id_Service_Provider_Config__c> getAppInfo(String bundleId) {
        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if (String.isNotBlank(bundleId)) {
            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            toReturn = [select id, Service_Provider_Name__c, Profile_Id__c, Terms_Custom_Label_1__c, Terms_Custom_Label_2__c, Terms_Custom_Label_3__c, Additional_Terms_Custom_Labels__c
            from One_Id_Service_Provider_Config__c
            where id= :bundleId limit 1];
        }

        return toReturn;
    }

    public static List<One_Id_Service_Provider_Config__c> getAppListForAppicker() {

        Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_Service_Provider_Config__c> bundlesAvailable = new List<One_Id_Service_Provider_Config__c>();
        Map<String, One_Id_User_Applications__c> usrMap = new Map<String, One_Id_User_Applications__c>();

        List<One_Id_User_Applications__c> userAppsList = [select One_Id_App_Bundle__c, id, Application__c, One_Id_Service_Provider_Config__c, User_Provisioning_Request__c from One_Id_User_Applications__c
                where Identity_User__c = :UserInfo.getUserId() and Provisioning_Status__c <> 'Deleted' order by createdDate limit 100];

        bundlesAvailable = [select id, Service_Provider_Name__c,Description__c,App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c, Is_Role_Selectable__c
        from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
        and RecordTypeid = :recTypeId order by createdDate desc limit 500];


        for (One_Id_User_Applications__c anUap : userAppsList) {
            usrMap.put(anUap.One_Id_App_Bundle__c, anUap);
        }
        System.debug('usrMap ' + usrMap.keySet());


        for (One_Id_Service_Provider_Config__c testBundle : bundlesAvailable) {
            System.debug('testBundle ' + testBundle);
            if(!usrMap.containsKey(testBundle.id)){
                // Not all users can have access to FRED
                if(testBundle.Service_Provider_Name__c == 'FRED'){
                    Boolean isServiceEligible = false;
                    User usr = [SELECT AccountId FROM User where Id =: UserInfo.getUserId()];
                    Account acc = [SELECT RecordTypeId, fredp_aircraftoperator_eligibility__c, RecordType.DeveloperName FROM Account where Id =: usr.AccountId];
            
                    if((acc.RecordType.DeveloperName == 'IATA_Airline' ||  acc.RecordType.DeveloperName == 'Operator') && acc.fredp_aircraftoperator_eligibility__c){
                        isServiceEligible = true;
                    }
                    else if(acc.RecordType.DeveloperName == 'ICAO_Member_State' || acc.RecordType.DeveloperName == 'Verifiers'){
                        isServiceEligible = true;
                    }
                    
                    if(isServiceEligible){
                        toReturn.add(testBundle);
                    }
                }
                else{
                    toReturn.add(testBundle);
                }
			}
        }
        return toReturn;

    }

    public static List<One_Id_App_Role_Config__c> getAppRolesListForAppicker(String bundleName) {


        List<One_Id_App_Role_Config__c> toReturn = new List<One_Id_App_Role_Config__c>();

        if (String.isNotBlank(bundleName)) {
            toReturn = [select Role_Name__c, Role_Description__c, Bundle_Name__c
                        from One_Id_App_Role_Config__c where Bundle_Name__c = :bundleName limit 10];
        }

        return toReturn;

    }

    public static List<One_Id_Service_Provider_Config__c> getAppPicListForAppicker(String bundleName) {


        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if (String.isNotBlank(bundleName)) {

            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            toReturn = [select id, Service_Provider_Name__c, Description__c, Description_Custom_Label__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c
                        from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
                                and RecordTypeid = :recTypeId and Service_Provider_Name__c = :bundleName limit 1];
        }

        return toReturn;

    }

    public static List<One_Id_Service_Provider_Config__c> getAppDescListForAppicker(String bundleName) {


        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if (String.isNotBlank(bundleName)) {

            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            toReturn = [select id, Service_Provider_Name__c, Description__c, Description_Custom_Label__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c
                        from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
                                and RecordTypeid = :recTypeId and Service_Provider_Name__c = :bundleName limit 1];
        }

        return toReturn;

    }
    public static List<One_Id_Service_Provider_Config__c> getAppTermsForAppicker(String bundleName) {


        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if (String.isNotBlank(bundleName)) {

            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            toReturn = [select id, Service_Provider_Name__c, TermConditions__c, Description_Custom_Label__c, Description__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c
                        from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
                                and RecordTypeid = :recTypeId and Service_Provider_Name__c = :bundleName limit 1];
        }

        return toReturn;

    }


    public static List<One_Id_Service_Provider_Config__c> getAppRoleSelectibilityForAppPicker(String bundleName){
        List<One_Id_Service_Provider_Config__c> toReturn = new List<One_Id_Service_Provider_Config__c>();

        if(String.isNotBlank(bundleName)) {

            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            toReturn = [select id, Is_Role_Selectable__c
            from One_Id_Service_Provider_Config__c where Is_Active__c = true and Portal_Visible__c = true
            and RecordTypeid = :recTypeId and Service_Provider_Name__c = :bundleName limit 1];
        }

        return toReturn;
    }     
     
    public static List<One_Id_App_Config_Detail__c> getAppPermissionSetListForAppicker(String bundleName){


        List<One_Id_Service_Provider_Config__c> temp = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_App_Config_Detail__c> toReturn = new List<One_Id_App_Config_Detail__c>();
        Map<String, One_Id_App_Config_Detail__c> mapOfApps = new Map<String, One_Id_App_Config_Detail__c>();

        if (String.isNotBlank(bundleName)) {

            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            temp = [select id, Service_Provider_Name__c, Description__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c,
                    Service_Bundle__r.Service_Provider_Name__c,
                    (select id, Connected_App_Provisioning_Name__c, PermissionSet_Provisioning__c, PermissionSet_SSO__c, One_Id_Service_Provider_Config__r.id, One_Id_Service_Provider_Config__r.Service_Provider_Name__c,
                     One_Id_Service_Provider_Config__r.Service_Bundle__r.id, One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c from One_Id_App_Config_Details__r)
                    from One_Id_Service_Provider_Config__c where Is_Active__c = true and Service_Bundle__r.Is_Active__c = true and Service_Bundle__r.Portal_Visible__c = true
                            and Service_Bundle__r.RecordTypeid = :recTypeId and Service_Bundle__r.Service_Provider_Name__c = :bundleName limit 500];


            if (!temp.isEmpty()) {

                for (One_Id_Service_Provider_Config__c sp : temp) {
                    System.debug('sp ' + sp);
                    for (One_Id_App_Config_Detail__c app : sp.One_Id_App_Config_Details__r) {
                        System.debug('app ' + app);
                        mapOfApps.put(app.Connected_App_Provisioning_Name__c, app);
                    }

                }

                if (!mapOfApps.isEmpty()) toReturn.addAll(mapOfApps.values());
            }
        }

        return toReturn;

    }


    public static List<One_Id_App_Config_Detail__c> getAppPermissionSetListForSSO() {


        List<One_Id_Service_Provider_Config__c> temp = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_App_Config_Detail__c> toReturn = new List<One_Id_App_Config_Detail__c>();
        Map<String, One_Id_App_Config_Detail__c> mapOfApps = new Map<String, One_Id_App_Config_Detail__c>();



        Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

        temp = [select id, Service_Provider_Name__c, Description__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c,
                Service_Bundle__r.Service_Provider_Name__c,
                (select id, Connected_App_Provisioning_Name__c, PermissionSet_Provisioning__c, PermissionSet_SSO__c, One_Id_Service_Provider_Config__r.id, One_Id_Service_Provider_Config__r.Service_Provider_Name__c,
                 One_Id_Service_Provider_Config__r.Service_Bundle__r.id, One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c from One_Id_App_Config_Details__r)
                from One_Id_Service_Provider_Config__c where Is_Active__c = true and Service_Bundle__r.Is_Active__c = true //and Service_Bundle__r.Portal_Visible__c = true
                        and Service_Bundle__r.RecordTypeid = :recTypeId limit 500];


        if (!temp.isEmpty()) {

            for (One_Id_Service_Provider_Config__c sp : temp) {
                System.debug('sp ' + sp);
                for (One_Id_App_Config_Detail__c app : sp.One_Id_App_Config_Details__r) {
                    System.debug('app ' + app);
                    mapOfApps.put(app.Connected_App_Provisioning_Name__c, app);
                }

            }

            if (!mapOfApps.isEmpty()) toReturn.addAll(mapOfApps.values());
        }

        return toReturn;

    }

    public static List<One_Id_App_Config_Detail__c> getAppPermissionSetListForISSP(List<String> bundleNames) {


        List<One_Id_Service_Provider_Config__c> temp = new List<One_Id_Service_Provider_Config__c>();
        List<One_Id_App_Config_Detail__c> toReturn = new List<One_Id_App_Config_Detail__c>();
        Map<String, One_Id_App_Config_Detail__c> mapOfApps = new Map<String, One_Id_App_Config_Detail__c>();

        if (!bundleNames.isEmpty()) {

            Id recTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('One_Id_Service_Provider_Config__c', 'Service_Bundle');

            temp = [select id, Service_Provider_Name__c, Description__c, App_Picture_Url__c, License_Upgrade_Required__c, Profile_Id__c,
                    Service_Bundle__r.Service_Provider_Name__c,
                    (select id, Connected_App_Provisioning_Name__c, PermissionSet_Provisioning__c, PermissionSet_SSO__c, One_Id_Service_Provider_Config__r.id, One_Id_Service_Provider_Config__r.Service_Provider_Name__c,
                     One_Id_Service_Provider_Config__r.Service_Bundle__r.id, One_Id_Service_Provider_Config__r.Service_Bundle__r.Service_Provider_Name__c from One_Id_App_Config_Details__r)
                    from One_Id_Service_Provider_Config__c
                    where Is_Active__c = true
                                         and Service_Bundle__r.Is_Active__c = true
                                                 and Service_Bundle__r.Portal_Visible__c = false
                                                         and Service_Bundle__r.RecordTypeid = :recTypeId
                                                                 and Service_Bundle__r.Service_Provider_Name__c = :bundleNames limit 500];

            System.debug('basto1p - getAppPermissionSetListForISSP recTypeId=' + recTypeId + '; bundleNames=' + bundleNames);
            System.debug('basto1p - getAppPermissionSetListForISSP config temp=' + temp);
            if (!temp.isEmpty()) {

                for (One_Id_Service_Provider_Config__c sp : temp) {
                    System.debug('sp ' + sp);
                    for (One_Id_App_Config_Detail__c app : sp.One_Id_App_Config_Details__r) {
                        System.debug('app ' + app);
                        mapOfApps.put(app.Connected_App_Provisioning_Name__c, app);
                    }

                }

                if (!mapOfApps.isEmpty()) toReturn.addAll(mapOfApps.values());
            }
        }

        return toReturn;

    }
}
