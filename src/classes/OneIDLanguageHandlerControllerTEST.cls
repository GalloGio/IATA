@isTest
public class OneIDLanguageHandlerControllerTEST {
	
	@isTest static void Metodostest()
	{
		
		Map<String,String> langMap = new Map<String,String>{
			'en_US' => 'English',		
			'fr' => 'French',		
			'pt_BR' => 'Portuguese (Brazilian)',
			'ar' => 'Arabic'
		};

		user u = new user(id=userinfo.getuserid(), LanguageLocaleKey ='en_US');
		update u;

		
		
		
		System.runAs(u){
			Test.startTest();

			OneIdLanguageHandlerController.getSupportedLanguagesMap();
			OneIdLanguageHandlerController.changeLanguage('pt_BR');
			Test.stopTest();
		}

	}
}