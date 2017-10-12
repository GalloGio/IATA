public with sharing class DetectLanguageRest {
    public static String ENDPOINT = 'https://ws.detectlanguage.com/0.2/detect';
    public static String USERKEY = '006925d457d4238c3d7f944834694b44';
    public static String TESTSTRING;
    public static final map<String,String> MAP_LANGS= new map<String,String>{
        'aa' => 'Afar',
        'ab' => 'Abkhazian',
        'af' => 'Afrikaans',
        'ak' => 'Akan',
        'am' => 'Amharic',
        'ar' => 'Arabic',
        'as' => 'Assamese',
        'ay' => 'Aymara',
        'az' => 'Azerbaijani',
        'ba' => 'Bashkir',
        'be' => 'Belarusian',
        'bg' => 'Bulgarian',
        'bh' => 'Bihari',
        'bi' => 'Bislama',
        'bn' => 'Bengali',
        'bo' => 'Tibetan',
        'br' => 'Breton',
        'bs' => 'Bosnian',
        'bug' => 'Buginese',
        'ca' => 'Catalan',
        'ceb' => 'Cebuano',
        'chr' => 'Cherokee',
        'co' => 'Corsican',
        'crs' => 'Seselwa',
        'cs' => 'Czech',
        'cy' => 'Welsh',
        'da' => 'Danish',
        'de' => 'German',
        'dv' => 'Dhivehi',
        'dz' => 'Dzongkha',
        'egy' => 'Egyptian',
        'el' => 'Greek',
        'en' => 'English',
        'eo' => 'Esperanto',
        'es' => 'Spanish',
        'et' => 'Estonian',
        'eu' => 'Basque',
        'fa' => 'Persian',
        'fi' => 'Finnish',
        'fj' => 'Fijian',
        'fo' => 'Faroese',
        'fr' => 'French',
        'fy' => 'Frisian',
        'ga' => 'Irish',
        'gd' => 'Scots_gaelic',
        'gl' => 'Galician',
        'gn' => 'Guarani',
        'got' => 'Gothic',
        'gu' => 'Gujarati',
        'gv' => 'Manx',
        'ha' => 'Hausa',
        'haw' => 'Hawaiian',
        'hi' => 'Hindi',
        'hmn' => 'Hmong',
        'hr' => 'Croatian',
        'ht' => 'Haitian_creole',
        'hu' => 'Hungarian',
        'hy' => 'Armenian',
        'ia' => 'Interlingua',
        'id' => 'Indonesian',
        'ie' => 'Interlingue',
        'ig' => 'Igbo',
        'ik' => 'Inupiak',
        'is' => 'Icelandic',
        'it' => 'Italian',
        'iu' => 'Inuktitut',
        'iw' => 'Hebrew',
        'ja' => 'Japanese',
        'jw' => 'Javanese',
        'ka' => 'Georgian',
        'kha' => 'Khasi',
        'kk' => 'Kazakh',
        'kl' => 'Greenlandic',
        'km' => 'Khmer',
        'kn' => 'Kannada',
        'ko' => 'Korean',
        'ks' => 'Kashmiri',
        'ku' => 'Kurdish',
        'ky' => 'Kyrgyz',
        'la' => 'Latin',
        'lb' => 'Luxembourgish',
        'lg' => 'Ganda',
        'lif' => 'Limbu',
        'ln' => 'Lingala',
        'lo' => 'Laothian',
        'lt' => 'Lithuanian',
        'lv' => 'Latvian',
        'mfe' => 'Mauritian_creole',
        'mg' => 'Malagasy',
        'mi' => 'Maori',
        'mk' => 'Macedonian',
        'ml' => 'Malayalam',
        'mn' => 'Mongolian',
        'mr' => 'Marathi',
        'ms' => 'Malay',
        'mt' => 'Maltese',
        'my' => 'Burmese',
        'na' => 'Nauru',
        'ne' => 'Nepali',
        'nl' => 'Dutch',
        'no' => 'Norwegian',
        'nr' => 'Ndebele',
        'nso' => 'Pedi',
        'ny' => 'Nyanja',
        'oc' => 'Occitan',
        'om' => 'Oromo',
        'or' => 'Oriya',
        'pa' => 'Punjabi',
        'pl' => 'Polish',
        'ps' => 'Pashto',
        'pt' => 'Portuguese',
        'qu' => 'Quechua',
        'rm' => 'Rhaeto_romance',
        'rn' => 'Rundi',
        'ro' => 'Romanian',
        'ru' => 'Russian',
        'rw' => 'Kinyarwanda',
        'sa' => 'Sanskrit',
        'sco' => 'Scots',
        'sd' => 'Sindhi',
        'sg' => 'Sango',
        'si' => 'Sinhalese',
        'sk' => 'Slovak',
        'sl' => 'Slovenian',
        'sm' => 'Samoan',
        'sn' => 'Shona',
        'so' => 'Somali',
        'sq' => 'Albanian',
        'sr' => 'Serbian',
        'ss' => 'Siswant',
        'st' => 'Sesotho',
        'su' => 'Sundanese',
        'sv' => 'Swedish',
        'sw' => 'Swahili',
        'syr' => 'Syriac',
        'ta' => 'Tamil',
        'te' => 'Telugu',
        'tg' => 'Tajik',
        'th' => 'Thai',
        'ti' => 'Tigrinya',
        'tk' => 'Turkmen',
        'tl' => 'Tagalog',
        'tlh' => 'Klingon',
        'tn' => 'Tswana',
        'to' => 'Tonga',
        'tr' => 'Turkish',
        'ts' => 'Tsonga',
        'tt' => 'Tatar',
        'ug' => 'Uighur',
        'uk' => 'Ukrainian',
        'ur' => 'Urdu',
        'uz' => 'Uzbek',
        've' => 'Venda',
        'vi' => 'Vietnamese',
        'vo' => 'Volapuk',
        'war' => 'Waray_philippines',
        'wo' => 'Wolof',
        'xh' => 'Xhosa',
        'yi' => 'Yiddish',
        'yo' => 'Yoruba',
        'za' => 'Zhuang',
        'zh' => 'Chinese_simplified',
        'zh-Hant' => 'Chinese_traditional',
        'zu' => 'Zulu'
    };

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
        
        public String getLanguageName() {
            return MAP_LANGS.get(language);
        }
    }
}