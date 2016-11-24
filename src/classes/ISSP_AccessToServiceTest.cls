@isTest
private class ISSP_AccessToServiceTest {
	
	@isTest static void test_method_one() {
		

        ISSP_AccessToService controller = new ISSP_AccessToService();
        ISSPAccServiceListView__c cs = new ISSPAccServiceListView__c();
        cs.Name = 'ISSP All';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSPAccServiceListView';
        cs.Label_API_name__c = 'ISSP_All';
        insert cs;
        
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;
        
        controller.initialization();
		controller.getAccServiceList();
		controller.getAccServices();
		controller.getSortDirection();
		controller.refresh();
	}
	
}