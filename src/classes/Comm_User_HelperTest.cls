@isTest
private class Comm_User_HelperTest {
    
    @isTest static void createNewUserTest() {
        // Comm_User_Helper.createNewUser
        //  public static Id createNewUser(Contact con, string selectedCustomerType, string Community){
        //Guest

        profile prof = [SELECT Id  FROM Profile WHERE Name ='ISS Portal Airline User (Partner)'  limit 1 ];
        ISSP_CS__c issc = new ISSP_CS__c(name = 'ISS_Portal_Airline_User', value__c = prof.id);
        insert issc;
        
        String defaultProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c(Name = 'ISS_Portal', Value__c = defaultProfileId);
        ISSP_CS__c identityPortalCS = new ISSP_CS__c(Name = 'IdentityPortal', Value__c = 'customer-portal-iata.force.com');
        insert new List<ISSP_CS__c>{profileCS, identityPortalCS};

        ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
        ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
        ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
        insert isoCountry;

        Account Hqrter = new Account(name ='myAirline',
                                     IATACode__c = '123',
                                     Airline_designator__c='AA',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = Hq );
        insert Hqrter;


        Contact con = new Contact(FirstName = 'myName',
                                  LastName = 'lstname',
                                  Salutation = 'sig',
                                  Email = 'myemail@iata.org',
                                  accountid = Hqrter.id
                                    );
        insert con;

        String selectedCustomerType = 'Airline';

        String community = 'IEC';

        ID userId;      

		User thisUser = [ select Id from User where Id = :UserInfo.getUserId() ];
    	system.runAs(thisUser){
	        test.startTest();
	        userId = Comm_User_Helper.createNewUser(con,  selectedCustomerType, community);
	        
	
	        user ug = [SELECT ID, ContactID FROM User where id =: userID] ;	
	        system.assertEquals(ug.ContactID, con.id);
            userId = Comm_User_Helper.createNewUser(con,  selectedCustomerType, 'ISSP');

            Comm_User_Helper.updateUsersGUID(userId);
            test.stopTest();
    	}

        String enc = Comm_User_Helper.EncryptString('testtest');
        Comm_User_Helper.DecryptString(enc);
    }

    
    @isTest static void resetPassword_test_method_two() {
        
        profile prof = [SELECT Id  FROM Profile WHERE Name ='ISS Portal Airline User (Partner)'  limit 1 ];


        ISSP_CS__c issc = new ISSP_CS__c(name = 'ISS_Portal_Airline_User', value__c = prof.id);
        ISSP_CS__c issc2 = new ISSP_CS__c(name = 'HostIEC', value__c = 'asite');



        insert issc;insert issc2;
        


        ID standardRT =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account') ;
        ID Branch  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR') ;
        ID Hq  =RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        
        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(name = 'suisse',ISO_Code__c ='SS' );
        insert isoCountry;

        Account Hqrter = new Account(name ='myAirline',
                                     IATACode__c = '123',
                                     Airline_designator__c='AA',
                                     industry = 'pluto',
                                     IATA_ISO_Country__c=isoCountry.id,
                                     recordtypeID = Hq );
        insert Hqrter;


        Contact con = new Contact(FirstName = 'myName',
                                  LastName = 'lstname',
                                  Salutation = 'sig',
                                  Email = 'myemail@iata.org',
                                  accountid = Hqrter.id
                                    );
        insert con;




        String userId;
        String accountId = '';
        string log;
        // prepare new User
        
        string userName = ISSP_Utilities.buildPortalUserName(con.email);
        User u = new User();
        //u.Username = con.email;
        u.Username =  userName;//AEF
        u.Email = con.email;
        u.FirstName = con.firstName;
        u.LastName = con.lastName;
        u.Date_ToU_accepted__c = system.Now();//TF - Accept Terms
        u.ToU_accepted__c = true;//TF - Accept Terms
        if (con.lastName.length() > 3)
            u.CommunityNickname = con.lastName.substring(0,3)+Datetime.now().formatLong();
        else 
            u.CommunityNickname = con.lastName+Datetime.now().formatLong();
        string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get('Airline');
        system.debug('profileName: ' + profileName);
        u.ProfileId = ISSP_Constant.profileIdByProfileNameMap.get(profileName);
        system.debug('u.ProfileId: ' + u.ProfileId);
        
        //throw new transformationException('u.ProfileId: ' + u.ProfileId);

        string password;
        
 
        if(con.accountId!=null)
            accountId = con.accountId;
        password = Comm_User_Helper.generateRandomString(6);
            
            u.contactid = con.id;
        u.emailencodingkey = 'UTF-8';
        u.localesidkey = 'en_US';
        u.timezonesidkey = 'America/Los_Angeles';
        u.languagelocalekey = 'en_US'; 
        u.alias = 'cspu';
        
        Comm_User_Helper.ISSP_PassWordBuilMessageWrapper( con ,  password ,  'adsasd' , con.Community__c);
        Comm_User_Helper.getUserListByNameOrEmail(con.email);
        Comm_User_Helper.getUserListByNameOrEmail2(con.email);
        Comm_User_Helper.resetPasswordComm(con.id, 'ISSP',false);
        Comm_User_Helper.resetPasswordISSPContact(con.id);
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 


        list<User> u2 = [SELECT Id FROM User WHERE profile.name = 'System Administrator' and isactive = true];
        system.runAs(u2[0]){
        insert u; }
       
        boolean res1;
        boolean res;
        User thisUser = [ select Id from User where Id <> :UserInfo.getUserId() and isactive = true and profile.name = 'System Administrator' limit 1];
        System.runAs ( thisUser ) {

         res1 = Comm_User_Helper.resetPassword(u.Email,'IEC');
         res =  Comm_User_Helper.resetPassword(u.Email,'CNS');
         res =  Comm_User_Helper.resetPassword(u.Email,'ISSP');
         res =  Comm_User_Helper.resetPassword(u.Email,'IDENTITY');
        }       
        system.assertEquals(res1,true);  
    }
    
}