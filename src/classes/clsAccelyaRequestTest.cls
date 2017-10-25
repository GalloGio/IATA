@isTest
private class clsAccelyaRequestTest {
    
    static testMethod void testAccelyaRequestMethod() {
        
        Contact c = new Contact();
        c.FirstName = 'Name';
        c.LastName = 'Test';
        insert c;
        
        Case cs = new Case();
        cs.Subject = 'Test case';
        cs.Status = 'New';
        cs.origin = 'Phone';
        cs.ContactId = c.Id;
        cs.Accelya_Request_Type__c = 'Bug Correction';
        cs.Applicable_to_Which_BSP_s__c = 'Canada;France;Italy';
        cs.Case_Creator_Email__c = 'test@test.org';
        insert cs;
        
        cs.BSPCountry__c = '';
        
        update cs;
        
        cs.Applicable_to_Which_BSP_s__c = 'India;Canada;France;Italy';
        
        update cs;
        
        
        
        Case cs1 = new Case();
        cs1.Subject = 'Test case';
        cs1.Status = 'New';
        cs1.origin = 'Phone';
        cs1.ContactId = c.Id;
        cs1.Accelya_Request_Type__c = 'Bug Correction';
        cs1.Applicable_to_Which_BSP_s__c = 'Canada;France;Italy';
        cs1.Case_Creator_Email__c = 'test@iata.org';
        
        insert cs1;
        
        
        
    }
}