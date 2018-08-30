@isTest
private class pkb_SecurityHandler_Test {

    public static testMethod void testSecurityEnabled() {
    	
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){

            for (Profile p : profileList) {

                u[0].profileId = p.id;
                update u;
                
                System.assertEquals(pkb_SecurityHandler.isAccessible(Case.sObjectType), Case.sObjectType.getDescribe().isAccessible());
                System.assertEquals(pkb_SecurityHandler.isCreateable(Case.sObjectType), Case.sObjectType.getDescribe().isCreateable());
                System.assertEquals(pkb_SecurityHandler.isUpdateable(Case.sObjectType), Case.sObjectType.getDescribe().isUpdateable());
                System.assertEquals(pkb_SecurityHandler.isDeletable(Case.sObjectType), Case.sObjectType.getDescribe().isDeletable());

                System.assertEquals(pkb_SecurityHandler.isAccessible(Case.subject), Case.subject.getDescribe().isAccessible());
                System.assertEquals(pkb_SecurityHandler.isCreateable(Case.subject), Case.subject.getDescribe().isCreateable());
                System.assertEquals(pkb_SecurityHandler.isUpdateable(Case.subject), Case.subject.getDescribe().isUpdateable());

                if (Case.sObjectType.getDescribe().isAccessible())
                    pkb_SecurityHandler.canAccess(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canAccess(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isCreateable())
                    pkb_SecurityHandler.canCreate(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canCreate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isUpdateable())
                    pkb_SecurityHandler.canUpdate(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canUpdate(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.sObjectType.getDescribe().isDeletable())
                    pkb_SecurityHandler.canDelete(Case.sObjectType);
                else
                    try {
                        pkb_SecurityHandler.canDelete(Case.sObjectType);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isAccessible())
                    pkb_SecurityHandler.canAccess(Case.subject);
                else
                    try {
                        pkb_SecurityHandler.canAccess(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isCreateable())
                    pkb_SecurityHandler.canCreate(Case.subject);
                else
                    try {
                        pkb_SecurityHandler.canCreate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}

                if (Case.subject.getDescribe().isUpdateable())
                    pkb_SecurityHandler.canUpdate(Case.subject);
                else
                    try {
                        pkb_SecurityHandler.canUpdate(Case.subject);
                        System.assert(false);
                    } catch (SecurityException e) {}
            }
        }
        
    }

    public static testMethod void testSecurityDisabled() {
    	
        pkb_SecurityHandler.securityEnabled = false;
        
        Profile[] profileList = [select Id, Name from Profile where Name = 'System Administrator' OR Name = 'Standar User' limit 2];

        Map<Id,String> profileMap = new Map<Id,String>();

        for( Profile p : profileList ){
            profileMap.put( p.id, p.Name );
        }
        
        List<User> u = [select id, profileId from User where Id =: UserInfo.getUserId() limit 1];

        if( profileMap.containsKey( UserInfo.getProfileId() ) && profileMap.get( UserInfo.getProfileId() ) == 'System Administrator' ){

            for (Profile p : profileList) {
                u[0].profileId = p.id;
                update u;
                System.assertEquals(pkb_SecurityHandler.isAccessible(Case.sObjectType), true);
                System.assertEquals(pkb_SecurityHandler.isCreateable(Case.sObjectType), true);
                System.assertEquals(pkb_SecurityHandler.isUpdateable(Case.sObjectType), true);
                System.assertEquals(pkb_SecurityHandler.isDeletable(Case.sObjectType), true);

                System.assertEquals(pkb_SecurityHandler.isAccessible(Case.subject), true);
                System.assertEquals(pkb_SecurityHandler.isCreateable(Case.subject), true);
                System.assertEquals(pkb_SecurityHandler.isUpdateable(Case.subject), true);

                pkb_SecurityHandler.canAccess(Case.sObjectType);
                pkb_SecurityHandler.canCreate(Case.sObjectType);
                pkb_SecurityHandler.canUpdate(Case.sObjectType);
                pkb_SecurityHandler.canDelete(Case.sObjectType);

                pkb_SecurityHandler.canAccess(Case.subject);
                pkb_SecurityHandler.canCreate(Case.subject);
                pkb_SecurityHandler.canUpdate(Case.subject);

                List<Schema.SObjectField> fieldList = new List<Schema.SObjectField>();
                fieldList.add( Case.subject );
                pkb_SecurityHandler.toString(fieldList);

                List<Schema.SObjectType> objectTypeList = new List<Schema.SObjectType>();
                objectTypeList.add( Case.sObjectType );
                pkb_SecurityHandler.toString(objectTypeList);
            }
        }

    }

    public static testMethod void testIsGuest(){
    	
        User u = [select Id from User  Where ProfileId IN (SELECT Id  FROM Profile WHERE name = 'System Administrator' AND UserType = 'Standard') and IsActive = true limit 1];
        
        system.runAs(u){
            system.assertEquals(pkb_SecurityHandler.isGuestUser(),false);
        }

    }

    public static testMethod void testOne() {

        String msg = '';
        
        Map<String, Boolean> kavPermissionsMap = pkb_SecurityHandler.getKAVPermissions();
        
        SObjectType caseObjType = Case.sObjectType;
        // Observed bizarre behavior: if first call is false rest will be false
        System.runAs(readOnlyUser()) {
            //create permission
            try{
                pkb_SecurityHandler.canCreate(caseObjType);
            }catch(pkb_SecurityHandler.SecurityException sEx){
                msg = pkb_SecurityHandler.formatReplace( pkb_SecurityHandler.ERROR_OBJECT_NOT_CREATEABLE, new String[] {pkb_SecurityHandler.toString(new Schema.SObjectType[] {caseObjType})});
                system.assertEquals( sEx.getMessage(), msg );
            }
            //update permissions
            try{
                pkb_SecurityHandler.canUpdate(caseObjType);
            }catch(pkb_SecurityHandler.SecurityException sEx){
                msg = pkb_SecurityHandler.formatReplace( pkb_SecurityHandler.ERROR_OBJECT_NOT_UPDATEABLE, new String[] {pkb_SecurityHandler.toString(new Schema.SObjectType[] {caseObjType})});
                system.assertEquals( sEx.getMessage(), msg );
            }
            //delete permission
            try{
                pkb_SecurityHandler.canDelete(caseObjType);
            }catch(pkb_SecurityHandler.SecurityException sEx){
                msg = pkb_SecurityHandler.formatReplace( pkb_SecurityHandler.ERROR_OBJECT_NOT_DELETABLE, new String[] {pkb_SecurityHandler.toString(new Schema.SObjectType[] {caseObjType})});
                system.assertEquals( sEx.getMessage(), msg );
            }
        }
    }
    
	private static User readOnlyUser() {

        Profile p = [select Id, Name from Profile where Name = 'Read Only'];
        
        User u = new User(
            UserName 				= 'test-user@testtesttest-company.com',
            FirstName 				= 'Test-First-Name',
            LastName 				= 'Test-Last-Name',
            Alias 					= 'test',
            Email 					= 'test-user@test-company.com',
            EmailEncodingKey 		= 'UTF-8',
            LanguageLocaleKey 		= 'en_US',
            LocalesIdKey 			= 'en_US',
            License_Cost_Center__c 	= 'ISF005CH01',
            TimezonesIdKey 			= 'America/Los_Angeles',
            ProfileId 				= p.Id
        );
        
        return u;
        
    }

}