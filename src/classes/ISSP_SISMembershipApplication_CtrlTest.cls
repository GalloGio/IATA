@isTest
private class ISSP_SISMembershipApplication_CtrlTest {

    private static User createPortalUser() {
        Account account = new Account(
            Name = 'test Account',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','IATA_Agency'),
            Sector__c = 'Airline',
            Category__c = 'CASS Associate',
            Give_SIS_Membership__c = 'ISPA'
        );
        insert account;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= account.Id;
        con.Email = 'Test' + String.valueOf(Math.random()) + '@test11.com';
        con.User_Portal_Status__c='Administrator';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;
        
        Portal_Applications__c SISapp = new Portal_Applications__c(Name = ISSP_SISMembershipApplication_Ctrl.APP_NAME);
        insert SISapp;
        insert new Case_Reason_Service__c (
            Name ='SIS Client',
            Service__c =ISSP_SISMembershipApplication_Ctrl.APP_NAME,
            Provider_Required__c = false);

        Portal_Application_Right__c right = new Portal_Application_Right__c(
            Contact__c = con.Id,
            Right__c = 'Access Granted',
            Portal_Application__c = SISapp.Id
        );
        PortalServiceAccessTriggerHandler.avoidAppTrigger = true;
        insert right;
        
        return newUser;
    }

    @isTest static void TestController() {
        User portalUser = createPortalUser();
        
        Test.startTest();
        System.runas(portalUser) {
            ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
            controller.initActions();
            controller.getListFeatureNames();
            System.assert(controller.listWrapperType.size()>0);
        }
        Test.stopTest();
    }

    @isTest static void Test_CreateCase() {
        User portalUser = createPortalUser();
        
        System.runas(portalUser) {
            ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
            System.assert(controller.listWrapperType.size()>0);
            
            Test.startTest();
            ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
            System.assertEquals(true,wrapper.getShowApplyNow());
            System.assert(wrapper.applyNow()!=null);
            Test.stopTest();
        }
    }

    @isTest static void Test_ContinueProcess() {
        User portalUser = createPortalUser();
        
        System.runas(portalUser) {
            ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
            System.assert(controller.listWrapperType.size()>0);
            ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
            System.assertEquals(true,wrapper.getShowApplyNow());
            wrapper.applyNow();
            
            Test.startTest();
            System.assertEquals(true,wrapper.getShowContinueProcess());
            System.assert(wrapper.continueProcess()!=null);
            Test.stopTest();
        }
    }
    
    @isTest static void Test_GoToCase() {
        User portalUser = createPortalUser();
        
        System.runas(portalUser) {
            ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
            System.assert(controller.listWrapperType.size()==1);
            ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
            System.assertEquals(true,wrapper.getShowApplyNow());
            wrapper.applyNow();
            
            Case cse = [SELECT Id, Status FROM Case WHERE Id = :wrapper.form.Case__c];
            cse.Status = 'Open';
            update cse;
            
            Test.startTest();
            controller = new ISSP_SISMembershipApplication_Ctrl();
            wrapper = controller.listWrapperType[0];
            System.assert(wrapper.getShowCurrentMembership()==false);
            System.assert(wrapper.form!=null);
            System.assert(wrapper.form.Case__r.Status != 'Draft', 'status is ' + wrapper.form.Case__r);
            System.assertEquals(true,wrapper.getShowGoToCase());
            System.assert(wrapper.goToCase()!=null);
            Test.stopTest();
        }
    }
    
    @isTest static void Test_CurrentMembership() {
        User portalUser = createPortalUser();
        
        Account account = [SELECT Id, SIS_Status__c, SIS_Sub_Status__c FROM Account LIMIT 1];
        account.SIS_Status__c='Active';
        account.SIS_Sub_Status__c='ISPA Airline';
        update account;
        
        System.runas(portalUser) {
            ISSP_SISMembershipApplication_Ctrl controller = new ISSP_SISMembershipApplication_Ctrl();
            System.assert(controller.listWrapperType.size()>0);
            ISSP_SISMembershipApplication_Ctrl.WrapperType wrapper = controller.listWrapperType[0];
            wrapper.applyNow();
            
            Test.startTest();
            System.assertEquals(true,wrapper.getShowCurrentMembership());
            Test.stopTest();
        }
    }
}