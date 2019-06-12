@isTest
public class GDPR_RequestList_CTRL_TEST {
    
    public static testMethod void requestList_ctrl_test1() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.gdpr.registration@testgdprregistration.com';
    	con.RecordTypeId = rtId;
        con.Data_Protection_Officer__c = true;
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

		ISSP_Registration ctrl = new ISSP_Registration();
        
        
        List<Case> lstCases = new List<Case>();
        Id gdprCaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'GDPR_Request');
        //Create Normal cases
        Case case1 = new Case();
        case1.RecordTypeId = gdprCaseRecordTypeId;
        case1.Subject = 'test';
        case1.Description = 'test';
        case1.Status = 'Open';
        case1.Data_Privacy_Rights__c = 'Right to be informed';
        case1.ContactId = con.Id;
        
        lstCases.add(case1);
        
        //Create DPO Cases
        Case dpoCase1 = new Case();
        dpoCase1.RecordTypeId = gdprCaseRecordTypeId;
        dpoCase1.Subject = 'test';
        dpoCase1.Description = 'test';
        dpoCase1.Status = 'Open';
        dpoCase1.Data_Privacy_Rights__c = 'Right to be informed';
        case1.ContactId = con.Id;
        dpoCase1.Passenger_Name_PXNM__c = 'test passenger';
        dpoCase1.Ticket_Number_TDNR__c = 'ticket number';
        dpoCase1.Date_of_Issue_DAIS__c = Date.today();
        dpoCase1.DPO_Owner__c = con.Id;
        
        lstCases.add(dpoCase1);
        
        insert lstCases;
        
        //Normal cases test
        Test.startTest();
        System.runAs(newUser) {
			List<Case> lstCasesAux1 = GDPR_RequestList_CTRL.getUserCases();
            System.assertEquals(1,lstCasesAux1.size());
        }
        Test.stopTest();
    }
    
    public static testMethod void requestList_ctrl_test2() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.gdpr.registration@testgdprregistration.com';
    	con.RecordTypeId = rtId;
        con.Data_Protection_Officer__c = true;
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

		ISSP_Registration ctrl = new ISSP_Registration();
        
        
        List<Case> lstCases = new List<Case>();
        Id gdprCaseRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'GDPR_Request');
        //Create Normal cases
        Case case1 = new Case();
        case1.RecordTypeId = gdprCaseRecordTypeId;
        case1.Subject = 'test';
        case1.Description = 'test';
        case1.Status = 'Open';
        case1.Data_Privacy_Rights__c = 'Right to be informed';
        case1.ContactId = con.Id;
        
        lstCases.add(case1);
        
        //Create DPO Cases
        Case dpoCase1 = new Case();
        dpoCase1.RecordTypeId = gdprCaseRecordTypeId;
        dpoCase1.Subject = 'test';
        dpoCase1.Description = 'test';
        dpoCase1.Status = 'Open';
        dpoCase1.Data_Privacy_Rights__c = 'Right to be informed';
        dpoCase1.ContactId = con.Id;
        dpoCase1.Passenger_Name_PXNM__c = 'test passenger';
        dpoCase1.Ticket_Number_TDNR__c = 'ticket number';
        dpoCase1.Date_of_Issue_DAIS__c = Date.today();
        dpoCase1.DPO_Owner__c = con.Id;
        
        lstCases.add(dpoCase1);
        
        insert lstCases;
        
        //dpo cases test
        Test.startTest();
        System.runAs(newUser) {
			List<Case> lstCasesAux2 = GDPR_RequestList_CTRL.getUserCasesDPO();
            System.assertEquals(1,lstCasesAux2.size());
        }
        Test.stopTest();
    }
    
    public static testMethod void requestList_ctrl_test3() {
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		Contact con = ISSP_ObjectFactory.createNewContact();
    	con.AccountId = acc.Id;
    	con.LastName = 'test';
    	con.Email = 'test.gdpr.registration@testgdprregistration.com';
    	con.RecordTypeId = rtId;
        con.Data_Protection_Officer__c = true;
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

		ISSP_Registration ctrl = new ISSP_Registration();
        
        
        //is contact dpo test
        Test.startTest();
        System.runAs(newUser) {
			Boolean booleanAux = GDPR_RequestList_CTRL.checkIfContactIsDPO();
            System.assertEquals(true,booleanAux);
        }
        Test.stopTest();
    }

}