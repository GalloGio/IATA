public class UnbabelTranslationUtils {


	// Inbound translation type
    public final String TRANSLATIONTYPEINBOUND = 'Machine';

	// Messages

    public final String ERRORCUSTLANG   = 'Error detecting the customer language.';
    public final String ERRORLANGPAIR   = 'Invalid language pair @lang1 : @lang2  detected.';
    public final String SUCCESSREQUEST  = 'Translation requested to Unbabel. In the next minute a new comment will be created with the content translated to your language.';

    public final String ERRORPUBLICC    = 'In order to Publish with Unbabel the Public checkbox must not be selected.';

	@future(callout=true)
	public static void sendRequest(Id ccId, String translationType, String sourceLang, String targetLang){

		system.debug('ccId:' + ccId);

		CaseComment cc = [select CommentBody,isPublished from CaseComment where Id = :ccId];
		//****** Create Translation Request(TR) ******

		unbabelapi__Unbabel_Translation_Request__c tr = new unbabelapi__Unbabel_Translation_Request__c();

		tr.unbabelapi__Unbabel_From_Language__c = sourceLang;
		tr.unbabelapi__Unbabel_To_Language__c = targetLang;
		tr.unbabelapi__Unbabel_Translation_Type__c = translationType;
		tr.unbabelapi__Unbabel_Namespace__c = '';

		//specify the name of the class to handle the translation
		tr.unbabelapi__Unbabel_Class__c = 'Unbabel_CaseCommentTranslationHandler';

		//Request Translation to Unbabel
		unbabelapi.UnbabelRestEnvelope ure = unbabelapi.UnbabelRestConnectorOutbound.requestTranslation( cc, tr,new Set<String>{'CommentBody'});


		//Sets the TR fields
		tr.unbabelapi__Unbabel_sObject_Id__c = cc.id;
		tr.unbabelapi__Unbabel_sObject__c = '';

		//if request is successfull updates the Translation Request status to "Translation Requested" and inserts the TRs
		
		if(!cc.IsPublished){
			if (ure.isSuccess) {
				tr.unbabelapi__Unbabel_Status__c = 'Translation Requested';
				tr.unbabelapi__Unbabel_Translation_Requested_Datetime__c = System.now();

				cc.CommentBody = cc.CommentBody  + ' \n\n # Pending Translation #';

			//If the request fails updates the Translation Request status to "Request Error" and inserts the TRs
			} else {
				tr.unbabelapi__Unbabel_Status__c = 'Request Error';
				tr.unbabelapi__Unbabel_Error_Log__c = ure.message;

				cc.CommentBody = cc.CommentBody  + ' \n\n # Error Requesting Translation #';

			}
			update cc;
		}
		insert tr;
	}
    

    public String getCustomerLang(Case cas, CaseComment cc){
        
        String customerLang;

	    if(cas.unbabelsc__Unbabel_Language__c != null) {
		
            customerLang = cas.unbabelsc__Unbabel_Language__c.split(':').get(0);
	    
        } else {
            
		    customerLang = checkLanguage(cc.CommentBody);
	    
        }

        return customerLang;

    }

	public String checkLanguage(String content){
		
		if(Test.isRunningTest()) unbabelapi.UnbabelRestConnectorOutbound.desiredLanguage = 'pt';

		unbabelapi.UnbabelRestEnvelopeCL ure = unbabelapi.UnbabelRestConnectorOutbound.checkLanguage(JSON.serialize(new EmailMessage(textBody=content)));
        String languageFound;
        //check language is sucessfull and is one of the permitted values on the org. will be used to set the unbabel language on the case
        if(ure.isSuccess){
            languageFound = ure.data.languageCode;
		}

		return languageFound;
	}

	public String getDefaultLanguage(){
    
	    String lang;

		Id userId = UserInfo.getUserId();

        if(userId.getSObjectType() == User.SObjectType){
            User u = [select Id, LanguageLocaleKey, unbabelapi__Unbabel_Language__c from User where Id =:userId];        

            lang = u.LanguageLocaleKey;    
            if(u.unbabelapi__Unbabel_Language__c != null && u.unbabelapi__Unbabel_Language__c != '') {
            
                lang = u.unbabelapi__Unbabel_Language__c.split(':')[0];
            }
            else if(unbabelCodes.containsKey(lang)) lang = unbabelCodes.get(lang);
        }else{
            if(lang == null) lang = 'en';
        }
        
        return lang;
    }

    private  Map<String, String> unbabelCodes{
        get{
            if(unbabelCodes == null){
                unbabelCodes = new Map<String, String>{
                    'en_US' => 'en',
                    'es_MX' => 'es',
                    'nl_NL' => 'nl',
                    'pt_BR' => 'pt-br',
                    'zh_CN' => 'zh-CN',
                    'zh_TW' => 'zh-TW'
                };
            }
            return unbabelCodes;
        }
        set;
    }

	public String getOutboundTranslationType(){

		unbabelapi__Unbabel_Translation_Permission__c userPermission = unbabelapi.UnbabelCustomSettingUtils.getUnbabelTranslationPermission();

		return userPermission.unbabelapi__Human__c ? 'Human' : 'Machine';

	}


}