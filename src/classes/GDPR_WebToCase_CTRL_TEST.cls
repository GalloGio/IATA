@isTest
public class GDPR_WebToCase_CTRL_TEST {
    
    public static testMethod void webtocase_ctrl_test1() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.gdpr.registration@testgdprregistration.com';
    	con.RecordTypeId = rtId;
		insert con;

       	User newUser = new User(alias = 'dsfsdfds',
                                email = con.email,
                                emailencodingkey = 'UTF-8',
                                firstname = con.firstName,
                                lastname = con.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                Username = 'test.gdpr.registration.testgdprpregistration.com@partner.iata.org',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = ISSP_Constant.TEST_User_ProfileID,
                                IsActive = true);
        insert newUser;
        
        
        System.runAs(newUser) {
            
           	List<GDPR_WebToCase_CTRL.PickListWrapper> lstPickValues = GDPR_WebToCase_CTRL.getDataPrivacyRightsPickValues();
            
            Boolean isDPO = GDPR_WebToCase_CTRL.checkIfContactIsDPO();
            
            Case caseAux = GDPR_WebToCase_CTRL.createEmptyCase(newUser.email);
            
            caseAux.Subject = 'test';
            caseAux.Description = 'test';
            caseAux.Status = 'Open';
            caseAux.Data_Privacy_Rights__c = 'Right to be informed';
            caseAux.Passenger_Name_PXNM__c = 'test passenger';
            caseAux.Ticket_Number_TDNR__c = 'ticket number';
            caseAux.Date_of_Issue_DAIS__c = Date.today();
            
            GDPR_WebToCase_CTRL.ReturnWrapper returnwrap = GDPR_WebToCase_CTRL.submitCase(JSON.serialize(caseAux), true);
            
        }
    }
    
}