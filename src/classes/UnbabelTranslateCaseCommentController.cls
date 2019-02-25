public with sharing class UnbabelTranslateCaseCommentController {
    //Apex properties or variables

    public Case cas { get; set; }
    public CaseComment cc { get; set; }

    private UnbabelTranslationUtils unbabelTU= new UnbabelTranslationUtils();

    //constructor to get the Case record
    public UnbabelTranslateCaseCommentController(ApexPages.StandardController controller) {

        cas = [select id, Publish_with_Unbabel__c,unbabelsc__Unbabel_Language__c from case where id = :controller.getRecord().Id limit 1];

        cc = [select id,IsPublished,CommentBody from CaseComment where parentId =:cas.Id and isPublished = true order by createdDate desc limit 1];

    }

    public void requestTranslation(){
        //get last published Case Comment
        // check if it was already translated
		String customerLang = unbabelTU.getCustomerLang(cas,cc); 

        if(customerLang == null){
            apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Error,unbabelTU.ERRORCUSTLANG));
		}
        else{
						
            String agentLang = unbabelTU.getDefaultLanguage();

			if( !Test.isRunningTest() &&  !unbabelapi.UnbabelCustomSettingUtils.validLanguagePair(customerLang, agentLang)){
                apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Error,unbabelTU.ERRORLANGPAIR.replaceFirst('@lang1',customerLang).replaceFirst('@lang2',agentLang)));

            }else{

                UnbabelTranslationUtils.sendRequest( cc.Id, unbabelTU.TRANSLATIONTYPEINBOUND, customerLang, agentLang);
        
                apexpages.addmessage(new Apexpages.Message(ApexPages.Severity.Info,unbabelTU.SUCCESSREQUEST));

                if(cas.unbabelsc__Unbabel_Language__c == null){
                    cas.unbabelsc__Unbabel_Language__c = customerLang+':'+unbabelsc.UnbabelTranslationOptions.languageMap.get(customerLang);
                    update cas;
                } 

            }
        }
    }

    public PageReference goToCase() {

        PageReference pageRef = new PageReference('/'+cas.Id);
        pageRef.setRedirect(true);
        return pageRef; //Returns to the case page
    }
    
}