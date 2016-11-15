@isTest
private class ChangeOwnershipCtrlTest {
		
		
		    public static testMethod void testMyController() {
					
				        
				        
				        Contact c = new Contact(lastname = 'baba' ,
				        						email = 'baba@com.com');
				        insert c;
        						
        				CRMfusionDBR101__Scenario__c scen  = new CRMfusionDBR101__Scenario__c(Name = 'myscenario');
        				insert scen;				        
				        
				        scen = [SELECT ID,CRMfusionDBR101__Scenario_Number__c 
        						FROM  CRMfusionDBR101__Scenario__c
        						WHERE ID =: SCEN.ID];

        				
        				UtilityCS__c utCs = New UtilityCS__c(name = 'DupeScenarioNumber' , value__c = scen.CRMfusionDBR101__Scenario_Number__c);
        				insert utCs;
        				
				        
				        
				        PageReference pageRef = Page.ChangeOwnership;
        				Test.setCurrentPage(pageRef);
        				
        				ApexPages.StandardController controller= new ApexPages.StandardController(c);
        				ChangeOwnershipCtrl crtl = new ChangeOwnershipCtrl(controller);
        				
        				 PageReference pageRefRet = crtl.returnToContact();
        		
        				string result2 = String.valueof(c.id).substring(0, 15);
        				 System.assertEquals('/' + result2,pageRefRet.getUrl());
        				
        			
						
		    }
}