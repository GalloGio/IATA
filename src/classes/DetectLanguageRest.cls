public with sharing class DetectLanguageRest {
    public static String ENDPOINT = 'https://ws.detectlanguage.com/0.2/detect';
    public static String USERKEY = '006925d457d4238c3d7f944834694b44';
    public static String TESTSTRING;

    public static Detection query(String text) {
        return query(new list<String>{text})[0];
    }

    public static list<Detection> query(list<String> listText) {
        try {
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(getURL(listText));
            req.setTimeout(120000);

            HttpResponse res;
            if(!Test.isRunningTest()) res = new Http().send(req);

            String jsonStr = !Test.isRunningTest() ? res.getBody() : TESTSTRING ;
            return getDetections(jsonStr);

        } catch (Exception e) {
            System.debug('ERROR in DetectLanguage.query(' + listText + ') : ' + e);
            return null;
        }
    }
    
    private static String getURL(list<String> listText) {
        String url = ENDPOINT + '?key=' + USERKEY;
        for (String text: listText) {
            url += '&q[]=' + EncodingUtil.urlEncode(text,'UTF-8');
        }
        System.debug('REST CALL: ' + url);
        return url;
    }
    private static list<Detection> getDetections(String jsonstr) {
        System.debug('RESPONSE: ' + jsonstr);
        JSONParser parser = JSON.createParser(jsonStr);
        DetectLanguageResponse response = (DetectLanguageResponse)parser.readValueAs(DetectLanguageResponse.class);
        list<Detection> listDetection = new list<Detection>();
        for (list<Detection> listDetectionResult : response.data.detections) {
            listDetection.add(listDetectionResult[0]);
        }
        return listDetection;
    }
    
    public class DetectLanguageResponse {
        public DataResponse data;
    }
    
    public class DataResponse {
        public list<list<Detection>> detections;
    }
    
    public class Detection {
        public String language;
        public Boolean isReliable;
        public Decimal confidence;
    }
}