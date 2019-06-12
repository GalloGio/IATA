public with sharing class Unbabel_CaseCommentRequestTranslation {
	
	public static void requestTranslation(List<CaseComment> ccList) {
		
		UnbabelTranslationUtils unbabelTU= new UnbabelTranslationUtils();

		system.debug('Unbabel :: Unbabel_CaseCommentRequestTranslation ' + ccList);

		Set<Id> caseIds = new Set<Id>();

		for(CaseComment cc : ccList){
			caseIds.add(cc.ParentId);
		}

		Map<Id,Case> casesMap = new Map<Id,Case>([select id, Publish_with_Unbabel__c,unbabelsc__Unbabel_Language__c from case where id = : caseIds]);

		List<Case> casesToUpdate = new List<Case>();

		for(CaseComment cc : ccList){

			//throw an error if Publish_with_Unbabel__c and  IsPublished

			if(casesMap.get(cc.ParentId).Publish_with_Unbabel__c) {

				if(cc.IsPublished){
					cc.addError(unbabelTU.ERRORPUBLICC);
				} else {
					
					String customerLang = unbabelTU.getCustomerLang(casesMap.get(cc.ParentId),cc);

					if(customerLang == null){
							cc.addError(unbabelTU.ERRORCUSTLANG);
					}
					else{
						
						String agentLang = unbabelTU.getDefaultLanguage();

						if( !Test.isRunningTest() && !unbabelapi.UnbabelCustomSettingUtils.validLanguagePair(agentLang,customerLang)){
							cc.addError(unbabelTU.ERRORLANGPAIR.replaceFirst('@lang1',agentLang).replaceFirst('@lang2',customerLang));

						}else{
							UnbabelTranslationUtils.sendRequest(cc.Id,unbabelTU.getOutboundTranslationType(),agentLang,customerLang);

							Case csToUpdate = casesMap.get(cc.ParentId);				
							
							csToUpdate.Publish_with_Unbabel__c = false;
							csToUpdate.unbabelsc__Unbabel_Language__c = customerLang+':'+unbabelsc.UnbabelTranslationOptions.languageMap.get(customerLang);

							casesToUpdate.add(csToUpdate);

						}					

					}



				}
			}

		}

		if(!casesToUpdate.isEmpty()){
			update casesToUpdate;
		}

	}

}