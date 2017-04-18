public class OneIdLanguageHandlerController {



	//static maps
	public static final Map<String,String> langMap = new Map<String,String>{
		'en_US' => 'English',
		//'de' => 'German',
		'fr' => 'French',
		//'it' => 'Italian',
		'pt_BR' => 'Portuguese (Brazilian)',
		//'es' => 'Spanish',
		//'ja' => 'Japanese',
		//'zh_CN' => 'Chinese_Simplified',
		//'ko' => 'Korean',
		//'th' => 'Thai',
		//'in' => 'Indonesian',
		//'vi' => 'Vietnamese',
		'ar' => 'Arabic'
	};

	public static String currentLanguage='en_US';

    
	@AuraEnabled
	public static Map<String,String> getSupportedLanguagesMap() {
		System.debug('Entrou getSupportedLanguagesList apex');
        
        //List<String> myLangList = new List<String>{'en_US', 'pt_BR'};
        
		return langMap;
	}

	@AuraEnabled
	public static String changeLanguage(String newLanguage) {
		System.debug('APEX LanguageHandlerController.changeLanguage newLanguage='+newLanguage);
		currentLanguage=newLanguage;
        
        //Change user sales force language if user logged
        if (Schema.SObjectType.User.isAccessible() && Schema.SObjectType.User.Fields.LanguageLocaleKey.isAccessible()){
         	User me = [SELECT LanguageLocaleKey FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
            if (newLanguage != null && me.LanguageLocaleKey != newLanguage 
                && Schema.SObjectType.User.isUpdateable()
                && Schema.SObjectType.User.Fields.LanguageLocaleKey.isUpdateable()
               ){
                    me.LanguageLocaleKey = newLanguage;
                    update me;
                    System.debug('APEX LanguageHandlerController.changeLanguage Updated User language settings in sales force');
            }
         } 

        return currentLanguage;
	}
}