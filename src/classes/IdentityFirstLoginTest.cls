@isTest
public class IdentityFirstLoginTest {
    
    @isTest 
    static void loginPage() {    
        
        String username = 'topolino@iata.org';
        String password = 'paperina';
        String UID = Comm_User_Helper.NewGuid();
        
        Account a = new Account(name = 'a');
        insert a;
        
        Contact con = new Contact(firstName = 'aaa', lastName = 'bbb', email = username, title = 'aa', accountId = a.id);
        insert con;
        
        User u = new User (
                CommunityNickname= 'thisNickname', 
                title=con.title, 
                contactid = con.id, 
                Firstname = con.firstname, 
                lastname = con.lastname, 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                email = con.email,
                UID__c = UID, 
                username=ISSP_Utilities.buildPortalUserName(con.email), 
                Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), 
                timezonesidkey = 'America/Los_Angeles', 
                languagelocalekey = 'en_US',
                Date_ToU_accepted__c = system.Now(), 
                ToU_accepted__c = true,
            	ProfileId = [SELECT ID FROM PROFILE WHERE NAME = 'ISS Portal Airline User'][0].id
                );  
        insert u;
        
        IdentityFirstLogin ifl = new IdentityFirstLogin();
        
        String userId = Site.createPortalUser(u, con.accountId, password, false);
        
        String encodedPart = 'https://aaa.com/s/IdentityFirstLogin?c='+EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(username+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+UID), 'UTF-8');
        
        test.startTest();
        String result = IdentityFirstLogin.checkLogin(encodedPart);
        test.stopTest();
        
        system.assertEquals('finish',result);
        
        result = IdentityFirstLogin.checkLogin('encodedPart');
        system.assertEquals('ERROR!', result);
    }
    
    
    @isTest 
    static void noLoginPage() {    
        
        String username = 'topolino@iata.org';
        String password = 'paperina';
        String UID = Comm_User_Helper.NewGuid();
        
        Account a = new Account(name = 'a');
        insert a;
        
        Contact con = new Contact(firstName = 'aaa', lastName = 'bbb', email = username, title = 'aa', accountId = a.id);
        insert con;
        
        User u = new User (
                CommunityNickname= 'thisNickname', 
                title=con.title, 
                contactid = con.id, 
                Firstname = con.firstname, 
                lastname = con.lastname, 
                emailencodingkey = 'UTF-8', 
                localesidkey = 'en_US', 
                email = con.email,
                UID__c = 'aaa', 
                username=ISSP_Utilities.buildPortalUserName(con.email), 
                Alias = ISSP_Utilities.buildPortalUserName(con.email).left(5), 
                timezonesidkey = 'America/Los_Angeles', 
                languagelocalekey = 'en_US',
                Date_ToU_accepted__c = system.Now(), 
                ToU_accepted__c = true,
            	ProfileId = [SELECT ID FROM PROFILE WHERE NAME = 'ISS Portal Airline User'][0].id
                );  
        insert u;
        
        IdentityFirstLogin ifl = new IdentityFirstLogin();
        
        String userId = Site.createPortalUser(u, con.accountId, password, false);
        
        String encodedPart = 'https://aaa.com/s/IdentityFirstLogin?c='+EncodingUtil.urlEncode(Comm_User_Helper.EncryptString(username+Comm_User_Helper.SEPARATOR+password+Comm_User_Helper.SEPARATOR+UID), 'UTF-8');
        Comm_User_Helper.updateUsersGUID(u.Id);
        test.startTest();
        String result = IdentityFirstLogin.checkLogin(encodedPart);
        test.stopTest();
        
        system.assertEquals('finish',result);
        
        
        result = IdentityFirstLogin.checkLogin('encodedPart');
        system.assertEquals('ERROR!', result);
    }
}