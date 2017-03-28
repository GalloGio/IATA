@isTest
public class ISSP_AvailableServices_Test {

	public static testMethod void testServices_1() {
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();
        ISSPServiceListView__c cs = new ISSPServiceListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Available_services';
        cs.SOQL_Filter__c = 'WHERE Name != \'12345\' ';
        cs.Permission_set__c = '0PS200000004CryGAE';
        insert cs;
        
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;
        
        cttr.initialization();
        
        cttr.getServiceList();
        
        cttr.getServices();
        cttr.refresh();
        
        cttr.sortExpression = 'Name';
        cttr.getServices();
        cttr.refresh();
        cttr.sortExpression = 'Case_creation_record_type__c';
        cttr.getServices();
        cttr.refresh();
        
        cttr.setSortDirection('DESC');
        system.assertEquals('DESC', cttr.getSortDirection());
        cttr.sortExpression = 'ASC';
        
    }
    
    public static testMethod void testServices_2() {
    	
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();

        cttr.initialization();
        
    }
    
    public static testMethod void testServices_3() {
    	
    	Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;
		Contact con = ISSP_ObjectFactory.createNewContact();
		insert con;
		Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;
        
        ISSP_AvailableServices cttr = new ISSP_AvailableServices();
        Apexpages.currentPage().getParameters().put('ServId', app.Id);
		
    	cttr.doRequest();
    	ISSP_AvailableServices.newAppsRequest(app.Id, app.Name, con.Id);
    }
    
}