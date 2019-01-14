@isTest
private class AMS_Case_Popup_ctrlTest {
	private static id SIDRALiteRTId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'SIDRA_Lite');
    private static id SIDRARTId = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'SIDRA');
	private static Id RTOSCAR = RecordTypeSingleton.getInstance().getRecordTypeID('Case', 'OSCAR_Communication');
	private static id AgencyRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeID('Account', 'IATA_Agency') ;
	
    static testMethod void testEmptyCase() {
    	test.StartTest();
    	PageReference pageRef = Page.AMS_Case_AccIrr_popup;
    	Test.setCurrentPage(pageRef);
    	
    	AMS_Case_Popup_ctrl controller = new AMS_Case_Popup_ctrl(null);
    	
    	system.assertEquals('', controller.sMsgToDisplay);
    	test.StopTest();
    }
    
    static testMethod void testNoChangeCodesAtAll() {
        Account acc = new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId);
        insert acc;
        
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = acc.Id);
        insert parent;
        
        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = acc.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;
        insert SidraLiteCase;
        
        test.StartTest();
    	PageReference pageRef = Page.AMS_Case_AccIrr_popup;
    	Test.setCurrentPage(pageRef);
    	
    	AMS_Case_Popup_ctrl controller = new AMS_Case_Popup_ctrl(new ApexPages.standardController(SidraLiteCase));
    	
    	system.assertEquals('', controller.sMsgToDisplay);
    	test.StopTest();
    }
    
    static testMethod void testNoDefNoPopup() {
        Account acc = new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, Accumulated_Irregularities__c=1);
        insert acc;
        
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = acc.Id);
        insert parent;
        
        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = acc.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;
        SidraLiteCase.Acc_IRR_leading_to_DEF__c = 3;
        insert SidraLiteCase;
        
        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = acc.Id, Change_code__c = 'NOT', AIMS_ID__c='1', SIDRA_Case__c = SidraLiteCase.Id));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = acc.Id, Change_code__c = 'NOT', AIMS_ID__c='2', SIDRA_Case__c = SidraLiteCase.Id));
        insert lsCC;
        
        test.StartTest();
    	PageReference pageRef = Page.AMS_Case_AccIrr_popup;
    	Test.setCurrentPage(pageRef);
    	
    	AMS_Case_Popup_ctrl controller = new AMS_Case_Popup_ctrl(new ApexPages.standardController(SidraLiteCase));
    	
    	system.assertEquals('', controller.sMsgToDisplay);
    	test.StopTest();
    }
    
    static testMethod void testDefNoPopup() {
    	Account acc = new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, Accumulated_Irregularities__c=3);
        insert acc;
        
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = acc.Id);
        insert parent;
        
        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = acc.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;
        SidraLiteCase.Acc_IRR_leading_to_DEF__c = 1;
        insert SidraLiteCase;
        
        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = acc.Id, Change_code__c = 'DEF', Effective_date__c = system.today(), AIMS_ID__c='1', SIDRA_Case__c = SidraLiteCase.Id));
        insert lsCC;
        
        test.StartTest();
    	PageReference pageRef = Page.AMS_Case_AccIrr_popup;
    	Test.setCurrentPage(pageRef);
    	
    	AMS_Case_Popup_ctrl controller = new AMS_Case_Popup_ctrl(new ApexPages.standardController(SidraLiteCase));
    	
    	system.assertEquals('', controller.sMsgToDisplay);
    	test.StopTest();
    }
    
    static testMethod void testNoDefPopup() {
        Account acc = new Account(Name='Accnt1', RecordTypeId = AgencyRecordTypeId, Accumulated_Irregularities__c=2);
        insert acc;
        
        Case parent = new Case(RecordtypeId = RTOSCAR, AccountId = acc.Id);
        insert parent;
        
        Case SidraLiteCase = new Case();
        SidraLiteCase.AccountId = acc.Id;
        SidraLiteCase.recordtypeId = SIDRALiteRTId;
        SidraLiteCase.ParentId = parent.Id;
        SidraLiteCase.Acc_IRR_leading_to_DEF__c = 1;
        insert SidraLiteCase;
        
        list<Agency_applied_change_code__c> lsCC = new list<Agency_applied_change_code__c>();
        lsCC.add(new Agency_Applied_change_code__c(Account__c = acc.Id, Change_code__c = 'NOT', AIMS_ID__c='1', SIDRA_Case__c = SidraLiteCase.Id));
        lsCC.add(new Agency_Applied_change_code__c(Account__c = acc.Id, Change_code__c = 'NOT', AIMS_ID__c='2', SIDRA_Case__c = SidraLiteCase.Id));
        insert lsCC;
        
        test.StartTest();
    	PageReference pageRef = Page.AMS_Case_AccIrr_popup;
    	Test.setCurrentPage(pageRef);
    	
    	AMS_Case_Popup_ctrl controller = new AMS_Case_Popup_ctrl(new ApexPages.standardController(SidraLiteCase));
    	
    	system.assertEquals('', controller.sMsgToDisplay);
    	test.StopTest();
    }
}