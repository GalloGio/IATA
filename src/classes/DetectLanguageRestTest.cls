@isTest
private class DetectLanguageRestTest {

    static testMethod void testQuery_Exception() {
        DetectLanguageRest.TESTSTRING = null;
        Test.startTest();
        try {
            DetectLanguageRest.Detection result = DetectLanguageRest.query('');
            System.assert(false,'Exception expected');
        } catch(Exception e) {
            System.assert(true);
        }
        Test.stopTest();
    }

    static testMethod void testQuery_OK() {
        DetectLanguageRest.TESTSTRING = '{"data": {"detections": [[{"language": "en","isReliable": true,"confidence": 8}]]}}';
        Test.startTest();
        DetectLanguageRest.Detection result = DetectLanguageRest.query('');
        Test.stopTest();
        System.assert(result.isReliable,'Wrong result');
    }

}