@isTest
private class IECFirstLoginCtrlTest {
    
    @isTest static void loginPage() {


         PageReference pageRef = Page.IECFirstLogin;
         Test.setCurrentPage(pageRef);

         ApexPages.currentPage().getParameters().put('un',EncodingUtil.urlEncode(Comm_User_Helper.EncryptString('topolino@iata.org'), 'UTF-8'));
         ApexPages.currentPage().getParameters().put('pw',EncodingUtil.urlEncode(Comm_User_Helper.EncryptString('paperina'), 'UTF-8'));

         IECFirstLoginCtrl ctrl = new IECFirstLoginCtrl();
         Pagereference pr = Page.IECLogin;

        system.assertEquals('/apex/ieclogin',ctrl.DoNext().getUrl());   


    }


    @isTest static void changePWDPage() {

        String UID =  Comm_User_Helper.NewGuid();
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
                               
        Contact con = new Contact(lastname = 'baba' ,accountId = Hqrter.id,firstName= 'name',
                                                email = 'baba@com.com');
                        insert con;

        string selectedCustomerType= 'Airline';

        User thisUser = [ select Id from User where Id <> :UserInfo.getUserId() and isactive = true and profile.name = 'System Administrator' limit 1];

        System.runAs ( thisUser ) {

                string userName = ISSP_Utilities.buildPortalUserName(con.email);
                User u = new User();
                //u.Username = con.email;
                u.UID__c = UID;
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
                system.debug('selectedCustomerType: ' + selectedCustomerType);   
                string profileName = ISSP_Constant.profilNameByUserTypeMap.get('User').get(selectedCustomerType);
                system.debug('profileName: ' + profileName);
                u.ProfileId = [SELECT ID FROM PROFILE WHERE NAME = 'ISS Portal Airline User'][0].id;//ISSP_Constant.profileIdByProfileNameMap.get(profileName);
                system.debug('u.ProfileId: ' + u.ProfileId);

                u.contactid = con.id;
                                                u.emailencodingkey = 'UTF-8';
                                                u.localesidkey = 'en_US';
                                                u.timezonesidkey = 'America/Los_Angeles';
                                                u.languagelocalekey = 'en_US'; 
                                                u.alias = 'cspu';
                  //Site.createPortalUser(u, Hqrter.id,'testpassword', false);
                   insert u;               

        
                                    }


         
          PageReference pageRef = Page.IECFirstLogin;
         Test.setCurrentPage(pageRef);

        
        string parameters ='baba@com.com'+Comm_User_Helper.SEPARATOR+'testpassword'+Comm_User_Helper.SEPARATOR+ UID;


         ApexPages.currentPage().getParameters().put('c',Comm_User_Helper.EncryptString(parameters));

       User thisUser2 = [ select Id 
                          from User 
                          where Id <> :UserInfo.getUserId() 
                          and isactive = true 
                          and profile.name = 'System Administrator' 
                          and id <>: thisUser.id limit 1];

        System.runAs ( thisUser2 ) {      

         IECFirstLoginCtrl ctrl = new IECFirstLoginCtrl();
         Pagereference pr = Page.IECLogin;
         system.assertEquals('/apex/iecchangepassword',ctrl.DoNext().getUrl()); 
        }           

      }
      
     /* @isTest static void loginPage_ISSP() {


         PageReference pageRef = Page.ISSP_First_Login;
         Test.setCurrentPage(pageRef);

         ApexPages.currentPage().getParameters().put('un',EncodingUtil.urlEncode(Comm_User_Helper.EncryptString('topolino@iata.org'), 'UTF-8'));
         ApexPages.currentPage().getParameters().put('pw',EncodingUtil.urlEncode(Comm_User_Helper.EncryptString('paperina'), 'UTF-8'));

         ISSP_First_Login ctrl = new ISSP_First_Login();
         Pagereference pr = Page.ISSP_Login;

        system.assertEquals('/apex/issp_login',ctrl.DoNext().getUrl()); 


    }
*/





    }