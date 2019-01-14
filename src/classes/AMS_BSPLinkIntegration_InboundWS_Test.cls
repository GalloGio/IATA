@isTest
private class AMS_BSPLinkIntegration_InboundWS_Test {
	
	static testMethod void TestNoAuthorization() {
		Account a = new account(Name='Test1');
        insert a;
        
        Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = a.Id, Status__c = 'Not set');
        insert aa;
        
        string sId = string.valueOf(aa.Id);
        
        delete aa;
        
        test.STartTest();
        
        string sResult = AMS_BSPLinkIntegration_InboundWS.doPost(null);
        
        AMS_BSPLinkIntegration_InboundWS.ResponsePOST result = (AMS_BSPLinkIntegration_InboundWS.ResponsePOST)JSON.Deserialize(sResult, AMS_BSPLinkIntegration_InboundWS.ResponsePOST.class);
        
        system.assertEquals('ERROR', result.Status);
        system.assertEquals('No BSPLink Authorization to process', result.ErrorMsg);
        
        string sResult2 = AMS_BSPLinkIntegration_InboundWS.doPost(new list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest>());
        
        AMS_BSPLinkIntegration_InboundWS.ResponsePOST result2 = (AMS_BSPLinkIntegration_InboundWS.ResponsePOST)JSON.Deserialize(sResult2, AMS_BSPLinkIntegration_InboundWS.ResponsePOST.class);
        
        system.assertEquals('ERROR', result2.Status);
        system.assertEquals('No BSPLink Authorization to process', result2.ErrorMsg);
        
        
        
        list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest> lsReq = new list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest>();
        
        lsReq.add(new AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest(sId, 'Active'));
        
        string sResult3 = AMS_BSPLinkIntegration_InboundWS.doPost(lsReq);
        
        AMS_BSPLinkIntegration_InboundWS.ResponsePOST result3 = (AMS_BSPLinkIntegration_InboundWS.ResponsePOST)JSON.Deserialize(sResult3, AMS_BSPLinkIntegration_InboundWS.ResponsePOST.class);
        
        system.assertEquals('ERROR', result3.Status);
        system.assertEquals('All given BSPLink authorization not found', result3.ErrorMsg);
        test.StopTest();
    }
    
    
    static testMethod void TestSingleAuthorization() {
        Account a = new account(Name='Test1');
        insert a;
        
        Agency_Authorization__c aa = new Agency_Authorization__c(Account__c = a.Id, Status__c = 'Not set');
        insert aa;
        
        test.StartTest();
        
        list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest> lsReq = new list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest>();
        
        lsReq.add(new AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest(string.ValueOf(aa.ID), 'Active'));
        
        string sResult = AMS_BSPLinkIntegration_InboundWS.doPost(lsReq);
        
        AMS_BSPLinkIntegration_InboundWS.ResponsePOST result = (AMS_BSPLinkIntegration_InboundWS.ResponsePOST)JSON.Deserialize(sResult, AMS_BSPLinkIntegration_InboundWS.ResponsePOST.class);
        
        system.assertEquals('SUCCESS', result.Status);
        system.assertEquals('', result.ErrorMsg);
        system.assertEquals('Active', [select status__c from Agency_Authorization__c where Account__c = :a.id].get(0).Status__c);
        Test.StopTest();
    }
    
    
    static testMethod void TestMultipleAuthorizationAllSuccess() {
        list<Account> lsAccnt = new list<Account>();
        lsAccnt.add(new account(Name='Test1'));
        lsAccnt.add(new account(Name='Test2'));
        insert lsAccnt;
        
        list<Agency_Authorization__c> lsAA = new list<Agency_Authorization__c>();
        lsAA.add(new Agency_Authorization__c(Account__c = lsAccnt.get(0).Id, Status__c = 'Not set'));
        lsAA.add(new Agency_Authorization__c(Account__c = lsAccnt.get(1).Id, Status__c = 'Not set'));
        insert lsAA;
        
        test.StartTest();
        
        list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest> lsReq = new list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest>();
        
        lsReq.add(new AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest(string.ValueOf(lsAA.get(0).id), 'Active'));
        lsReq.add(new AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest(string.ValueOf(lsAA.get(1).id), 'Active'));
        
        string sResult = AMS_BSPLinkIntegration_InboundWS.doPost(lsReq);
        
        AMS_BSPLinkIntegration_InboundWS.ResponsePOST result = (AMS_BSPLinkIntegration_InboundWS.ResponsePOST)JSON.Deserialize(sResult, AMS_BSPLinkIntegration_InboundWS.ResponsePOST.class);
        
        system.assertEquals('SUCCESS', result.Status);
        system.assertEquals('', result.ErrorMsg);
        system.assertEquals('Active', [select status__c from Agency_Authorization__c where Account__c = :lsAccnt.get(0).id].get(0).Status__c);
        system.assertEquals('Active', [select status__c from Agency_Authorization__c where Account__c = :lsAccnt.get(1).id].get(0).Status__c);
        Test.StopTest();
    }
    
    
    static testMethod void TestSingleAuthorizationPartialSuccess() {
        list<Account> lsAccnt = new list<Account>();
        lsAccnt.add(new account(Name='Test1'));
        lsAccnt.add(new account(Name='Test2'));
        insert lsAccnt;
        
        list<Agency_Authorization__c> lsAA = new list<Agency_Authorization__c>();
        lsAA.add(new Agency_Authorization__c(Account__c = lsAccnt.get(0).Id, Status__c = 'Not set'));
        lsAA.add(new Agency_Authorization__c(Account__c = lsAccnt.get(1).Id, Status__c = 'Not set'));
        insert lsAA;
        
        test.StartTest();
        
        list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest> lsReq = new list<AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest>();
        string sId = string.ValueOf(lsAA.get(0).id);
        lsReq.add(new AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest(sId, 'Active'));
        lsReq.add(new AMS_BSPLinkIntegration_InboundWS.BSPLinkRequest(string.ValueOf(lsAA.get(1).id), 'Active'));
        
        delete lsAA.get(0);
        
        string sResult = AMS_BSPLinkIntegration_InboundWS.doPost(lsReq);
        
        AMS_BSPLinkIntegration_InboundWS.ResponsePOST result = (AMS_BSPLinkIntegration_InboundWS.ResponsePOST)JSON.Deserialize(sResult, AMS_BSPLinkIntegration_InboundWS.ResponsePOST.class);
        
        system.assertEquals('PARTIAL SUCCESS', result.Status);
        system.assertEquals('Authorization not found: ' + sId.left(15) + '; ', result.ErrorMsg);
        system.assertEquals('Active', [select status__c from Agency_Authorization__c where Account__c = :lsAccnt.get(1).id].get(0).Status__c);
        Test.StopTest();
        
    }
}