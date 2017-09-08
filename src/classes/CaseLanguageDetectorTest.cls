@isTest
private class CaseLanguageDetectorTest {
    private static Id RT_ISSCASE = [Select Id from Recordtype WHERE DeveloperName = 'ISS_Portal_New_Case_RT'].Id;
    
    static testMethod void testsetLanguageForNewISSPCases_Exception() {
        DetectLanguageRest.TESTSTRING = null;
        
        Case cse = new Case(
            RecordtypeId = RT_ISSCASE,
            Description = 'Test description',
            Case_Language__c = null,
            Origin = 'Portal'
        );

        Test.startTest();
        CaseLanguageDetector.detectCaseLanguage(cse);
        Test.stopTest();
    }
    
    static testMethod void testsetLanguageForNewISSPCases_NotReliable() {
        DetectLanguageRest.TESTSTRING = '{"data": {"detections": [[{"language": "en","isReliable": false,"confidence": 8}]]}}';
        
        Case cse = new Case(
            RecordtypeId = RT_ISSCASE,
            Description = 'Test description',
            Case_Language__c = null,
            Origin = 'Portal'
        );

        Test.startTest();
        CaseLanguageDetector.detectCaseLanguage(cse);
        Test.stopTest();
    }
    
    static testMethod void testsetLanguageForNewISSPCases_OK() {
        DetectLanguageRest.TESTSTRING = '{"data": {"detections": [[{"language": "en","isReliable": true,"confidence": 8}]]}}';
        
        Case cse = new Case(
            RecordtypeId = RT_ISSCASE,
            Description = 'Test description',
            Case_Language__c = null,
            Origin = 'Portal'
        );

        Test.startTest();
        CaseLanguageDetector.detectCaseLanguage(cse);
        Test.stopTest();
    }
    
    static testMethod void testsetLanguageForNewISSPCases_LongResponse_OK() {
        DetectLanguageRest.TESTSTRING = '{"data": {"detections": [[{"language": "en","isReliable": true,"confidence": 8}]]}}';
        String description = '';
        for (Integer i=0; i<CaseLanguageDetector.WORDS_NUMBER; i++) {
            description += ' word';
        }
        
        Case cse = new Case(
            RecordtypeId = RT_ISSCASE,
            Description = description,
            Case_Language__c = null,
            Origin = 'Portal'
        );

        Test.startTest();
        CaseLanguageDetector.detectCaseLanguage(cse);
        Test.stopTest();
    }
}