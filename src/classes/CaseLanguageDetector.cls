public with sharing class CaseLanguageDetector {

    public static void setLanguageForNewISSPCases(list<Case> listCase) {
        list<Id> listCasesToUpdate = new list<Id>();
        for (Case cse: listCase) {
            if(cse.Origin == 'Portal') {
                listCasesToUpdate.add(cse.Id);
            }
        }
        if (!listCasesToUpdate.isEmpty()) {
            detectBatchCaseLanguage(listCasesToUpdate);
        }
    }

    @future(callout=true)
    public static void detectBatchCaseLanguage(list<Id> listCaseId) {
        try {
            list<String> listQueryText = new list<String>();
            list<Case> listCase = new list<Case>();
            for (Case cse: [SELECT Id, Description, Case_Language__c
                    FROM Case
                    WHERE Id in :listCaseId]) {
                String description = cleanDescription(cse.Description);
                if (description > '') {
                    listQueryText.add(description);
                    listCase.add(cse);
                }
            }
            list<DetectLanguageRest.Detection> listDetection = DetectLanguageRest.query(listQueryText);
            list<Case> listUpdateCase = new list<Case>();
            for (Integer i=0; i<listDetection.size(); i++) {
                DetectLanguageRest.Detection detection = listDetection.get(i);
                Case cse = listCase.get(i);
                if (detection.isReliable) {
                    cse.Case_Language__c = detection.getLanguageName();
                    listUpdateCase.add(cse);
                }
            }
            if (!listUpdateCase.isEmpty()) update listUpdateCase; 

        } catch (Exception e) {
            System.debug('ERROR in detectCaseLanguage(' + listCaseId+ ') ' + e.getMessage());
        }
    }
    
    public static final Integer WORDS_NUMBER = 10;
    public static String cleanDescription(String text) {
        text = text.left(150);
        text = text.replaceAll('[0-9\n\t!@#$*()<>?_+]',' ');
        text = text.replaceAll('-',' ');
        text = text.replaceAll('\\s+',' ');
        text = text.trim();
        list<String> listWords = text.split(' ');
        if (listWords.size() < WORDS_NUMBER) {
            return text;
        }
        list<String> listOut = new list<String>();
        for (Integer i=0; i<WORDS_NUMBER; i++) {
            listOut.add(listWords.get(i));
        }
        return String.join(listOut,' ');
    }
}