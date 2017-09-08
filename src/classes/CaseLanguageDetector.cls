public with sharing class CaseLanguageDetector {

    public static String detectCaseLanguage(Case cse) {
        try {
            String cleanedDescription = cleanDescription(cse.Description);
            if (String.isBlank(cleanedDescription)) return '';
            list<String> listQueryText = new list<String>{cleanedDescription};

            list<DetectLanguageRest.Detection> listDetection = DetectLanguageRest.query(listQueryText);
            DetectLanguageRest.Detection detection = listDetection.get(0);
            if (detection.isReliable) {
                return detection.getLanguageName();
            } else {
                String subject = 'Detection Language not reliable: case with subject "' + cse.Subject + '" created by user ' + UserInfo.getName();
                String message = 'QUERY TEXT: ' + listQueryText + '\n';
                message += 'RESULT ' + detection;
                sendEmail(subject,message);
                System.debug(subject + '\n' + message);
            }

        } catch (Exception e) {
            String subject = 'Detection Language Error: case with subject "' + cse.Subject + '" created by user ' + UserInfo.getName();
            String message = 'EXCEPTION:\n' + e.getMessage();
            sendEmail(subject,message);
            System.debug(subject + '\n' + message);
        }
        return '';
    }
    
    public static final Integer WORDS_NUMBER = 15;
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
    
    
    public static final list<String> ERROR_EMAILS = new list<String>{'tenaj@iata.org','shalbakf@iata.org'}; 
    public static void sendEmail(String subject, String message) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage(); 
        email.setSubject(subject);
        email.setPlainTextBody(message );
        email.setToAddresses(ERROR_EMAILS);

        // Sends the email
        if (!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});
    }

}