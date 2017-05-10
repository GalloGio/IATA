@isTest
private class CaseRecordTypeAssignmentTest {
  
  @isTest static void getCorrectCaseRecordType() {
    
    Test.startTest();

        Map<String,Object> inputParams = new Map<String,Object>();

        inputParams.put('caseCountryIsoCode', 'MG');

        Process.PluginRequest request = new Process.PluginRequest(inputParams);           
        
        CaseRecordTypeAssignment plugin = new CaseRecordTypeAssignment();
        plugin.invoke(request);

        plugin.describe();

      Test.stopTest();
  }
  

  
}