@isTest
private class FormulaField_Helper_Test {
	@testSetup 
	static void testSetup(){

            Account acc = new Account(
                    name='acc1',
                    Location_Type__c=AMS_Utils.HE,
                    Location_Class__c= AMS_Utils.LC_PASSENGER,
                    Remittance_frequency__c=ANG_Risk_Helper.REMITTANCE_FREQUENCY_MONTHLY,
                    ANG_Accreditation_Model__c =AMS_Utils.ACCREDITATIONMODEL_CASH,
                    recordtypeId=AMS_Utils.RECTYPE_IATAAGENCY,
                    IATACode__c ='123',
                    Accreditation_date__c = Date.valueOf('2017-01-01')
            );
            
            insert acc;
	
	}
	
    static testMethod void testCreationFromCase() {
    	Account a = [select ID from Account where Name='acc1'].get(0);
    	
    	test.StartTest();
    		case c = new case(AccountId = a.Id);
    		
    		insert c;
    		system.assertEquals(1, [select id from Case_formula_helper__c].size());
    		system.assertEquals([select id from Case_formula_helper__c where case__c =:c.Id].get(0).Id, [Select Case_formula_helper__c from case where id=:c.id].get(0).Case_formula_helper__c);
    	test.stopTest();
    }
    
    
    static testMethod void testCreationFromHelper() {
    	Account a = [select ID from Account where Name='acc1'].get(0);
    	
   		case c = new case(AccountId = a.Id);
    	FormulaField_Helper.isRunningFromHelper = true;
    	FormulaField_Helper.isRunningFromCAse = true;	
   		
   		insert c;
		
		FormulaField_Helper.isRunningFromHelper = false;
    	FormulaField_Helper.isRunningFromCAse = false;	
   		
   		Case_formula_helper__c cc = new Case_formula_helper__c(case__c = c.Id, UniqueId__c = c.Id);
   		
   		test.startTest();
   			insert cc;
   			
   			system.assertEquals(1, [select id from Case_formula_helper__c].size());
    		system.assertEquals([select id from Case_formula_helper__c where case__c =:c.Id].get(0).Id, [Select Case_formula_helper__c from case where id=:c.id].get(0).Case_formula_helper__c);
   		test.StopTest();
    }
    
    
    static testMethod void testFillingFromCase_KPI2(){
    	Account a = [select ID from Account where Name='acc1'].get(0);
    	
    	Id caseRTIt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Cases (IDFS ISS)').getRecordTypeId();
    	list<Formula_Field_Helper_Config__mdt> lsReason = [select id, Helper_Type__c, Field_to_check__c, Values_to_check__c, result__c from Formula_Field_Helper_Config__mdt where ObjectName__c='Case' and  Helper_Type__c='KPI2_Reason1'];
    	list<Formula_Field_Helper_Config__mdt> lsRT = [select id, Helper_Type__c, Field_to_check__c, Values_to_check__c, result__c from Formula_Field_Helper_Config__mdt where ObjectName__c='Case' and  Helper_Type__c='KPI2_RecordType'];
    	
    	system.assert(!lsRT.isEmpty());
    	system.assert(!lsReason.isEmpty());
    	
    	string sRTName = lsRT[0].Values_to_check__c.split(';')[0];
    	string sReason = lsReason[0].Values_to_check__c.split(';')[0];
    	
    	
   		case c = new case(AccountId = a.Id
   						  ,RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(sRTName).getRecordTypeId()
   						  ,Reason1__c = sReason);
   		
   		test.startTest();
	   		insert c;
	   		list<Case_formula_helper__c> theHelp = [select AccProcessType_Reason1_Helper__c, KPI1_Reason1_Helper__c, KPI1_RecordType_Helper__c, KPI2_Reason1_Helper__c, KPI2_RecordType_Helper__c, ProcessAge_Reason1_Helper__c from Case_formula_helper__c where case__c=:c.id];
	   		
	   		system.assertEquals(1, theHelp.size());
	   		
	   		system.assertEquals(0, theHelp[0].KPI1_RecordType_Helper__c);
	   		system.assertEquals(0, theHelp[0].KPI1_Reason1_Helper__c);
	   		
	   		system.assertEquals('Medium 20d', theHelp[0].AccProcessType_Reason1_Helper__c);
	   		system.assertEquals(1, theHelp[0].ProcessAge_Reason1_Helper__c);
	   		
	   		system.assertEquals(1, theHelp[0].KPI2_RecordType_Helper__c);
	   		system.assertEquals(1, theHelp[0].KPI2_Reason1_Helper__c);
	   		
	   	test.stopTest();
    }
    
    
    static testMethod void testFillingFromCase_KPI1(){
    	Account a = [select ID from Account where Name='acc1'].get(0);
    	
    	Id caseRTIt = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Internal Cases (IDFS ISS)').getRecordTypeId();
    	list<Formula_Field_Helper_Config__mdt> lsReason = [select id, Helper_Type__c, Field_to_check__c, Values_to_check__c, result__c from Formula_Field_Helper_Config__mdt where ObjectName__c='Case' and  Helper_Type__c='KPI1_Reason1'];
    	list<Formula_Field_Helper_Config__mdt> lsRT = [select id, Helper_Type__c, Field_to_check__c, Values_to_check__c, result__c from Formula_Field_Helper_Config__mdt where ObjectName__c='Case' and  Helper_Type__c='KPI1_RecordType'];
    	
    	system.assert(!lsRT.isEmpty());
    	system.assert(!lsReason.isEmpty());
    	
    	string sRTName = lsRT[0].Values_to_check__c.split(';')[0];
    	string sReason = lsReason[0].Values_to_check__c.split(';')[0];
    	
    	
   		case c = new case(AccountId = a.Id
   						  ,RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get(sRTName).getRecordTypeId()
   						  ,Reason1__c = sReason);
   		
   		test.startTest();
	   		insert c;
	   		list<Case_formula_helper__c> theHelp = [select AccProcessType_Reason1_Helper__c, KPI1_Reason1_Helper__c, KPI1_RecordType_Helper__c, KPI2_Reason1_Helper__c, KPI2_RecordType_Helper__c, ProcessAge_Reason1_Helper__c from Case_formula_helper__c where case__c=:c.id];
	   		
	   		system.assertEquals(1, theHelp.size());
	   		
	   		system.assertEquals(1, theHelp[0].KPI1_RecordType_Helper__c);
	   		system.assertEquals(1, theHelp[0].KPI1_Reason1_Helper__c);
	   		
	   		system.assertEquals('Long 50d', theHelp[0].AccProcessType_Reason1_Helper__c);
	   		system.assertEquals(1, theHelp[0].ProcessAge_Reason1_Helper__c);
	   		
	   		system.assertEquals(0, theHelp[0].KPI2_RecordType_Helper__c);
	   		system.assertEquals(0, theHelp[0].KPI2_Reason1_Helper__c);
	   		
	   	test.stopTest();
    }
}