public with sharing class PortalFAQsCtrl {

	public static Integer RESULTS_PER_PAGE = 10;
	public static String LANGUAGE;
	public static String DEFAULT_LANG_EN='en_US';

	/*
	* @description Return a FAQ structure based on the user visibility.
	* @description Joining metadata records from Portal FAQs with setup configuration from Data Category Visibility if internal user or just metadata records if guest user
	* @params
	* @return List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>
	*/
	@AuraEnabled(cacheable=true)
	public static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> getFAQsInfo() {
		return convertStructure(DescribeDataCategoryGroupStructures.getFaqsStructure());
	}

	/*
	* @description Same as getFAQsInfo method, but here is specific for guest user because we're setting the language
	* @params String lang
	* @return List<FAQCategoryWrapper>
	*/
	@AuraEnabled(cacheable=true)
	public static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> getFAQsInfoByLanguage(String lang) {
		return convertStructure(DescribeDataCategoryGroupStructures.getPublicFaqsStructure(lang));
	}

	private static List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> convertStructure(List<DescribeDataCategoryGroupStructures.FAQCategoryWrapper> lstToConvert){
		List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstToReturn = new List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>();

		for(DescribeDataCategoryGroupStructures.FAQCategoryWrapper categoryAux : lstToConvert){
			for(DescribeDataCategoryGroupStructures.FAQTopicWrapper topicAux : categoryAux.lstTopics){
				Map<String,String> mapSubtopics = new Map<String,String>();
				Map<String,String> mapSubtopicsEn = new Map<String,String>();
				for(DescribeDataCategoryGroupStructures.FAQSubtopicWrapper subtopicAux : topicAux.lstSubtopics){
					mapSubtopics.put(subtopicAux.subtopicLabel, subtopicAux.subtopicName);
					mapSubtopicsEn.put(subtopicAux.subtopicName, subtopicAux.subtopicLabelEn);
				}

				lstToReturn.add(new DescribeDataCategoryGroupStructures.DataCategoryWrapper(topicAux.topicName, topicAux.topicLabel, topicAux.topicLabelEn,
																							categoryAux.categoryName, categoryAux.categoryLabel, categoryAux.categoryLabelEn,
																							mapSubtopics, mapSubtopicsEn));
			}
		}

		return lstToReturn;
	}

	@AuraEnabled
	public static List<FAQ__kav> getArticlesByLanguage(String selectedParams, String lang) {
		LANGUAGE = lang;

		return getArticlesWithParam(selectedParams, 15);
	}

	@AuraEnabled(cacheable=true)
	public static List<FAQ__kav> getArticles(String selectedParams) {
		return getArticlesWithParam(selectedParams, 15);
	}

	@AuraEnabled(cacheable=true)
	public static List<FAQ__kav> getArticlesWithParam(String selectedParams, Integer limitParam) {
		String language = String.isNotBlank(LANGUAGE) ?  LANGUAGE : '';
		List<FAQ__kav> faqLanList= getArticles(selectedParams,limitParam,language,null);
		
		//searches for articles without translations only if there are slots availables
		if(limitParam-faqLanList.size()>0){
			set<string> langARSet = new set<string>();
			for(FAQ__kav faq:faqLanList){
				langARSet.add(faq.ArticleNumber);
			}			
			faqLanList.addAll(getArticles(selectedParams,(limitParam-faqLanList.size()),DEFAULT_LANG_EN,langARSet));		
		}
		return faqLanList;
	}

	//generic method to search for pkb articles with a SOQL
	// Parameters
	//selectedParams - Selected topics and subtopics to search for
	//limitParam - Restrict number of returned records
	//language - FAQ Article language
	//expectionsSet - set of articles that should be excluded from the search- used for when searching articles in english to remove the articles in the local language
	public static List<FAQ__kav> getArticles(String selectedParams, Integer limitParam,String language,Set<String> expectionsSet) {
		String queryOne = 'SELECT Id, ArticleNumber, Title, Answer__c,ArticleTotalViewCount FROM FAQ__kav WHERE PublishStatus=\'Online\'';
		String queryTwo = String.isNotBlank(language) ? ' AND Language = \'' + language + '\'' : '';
		string queryException = expectionsSet!=null?' AND ArticleNumber NOT IN :expectionsSet ':'';		
		String queryThree = ' WITH DATA CATEGORY FAQs__c BELOW ' + String.escapeSingleQuotes(selectedParams) + ' ORDER BY ArticleTotalViewCount DESC ';
		String limits=limitParam!=null?' LIMIT ' + limitParam:'';

		String finalQuery = queryOne + queryTwo +queryException+ queryThree+limits;
		System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getArticles] finalQuery - ' + finalQuery);
		
		return Database.query(finalQuery);

	}

	@AuraEnabled(cacheable=true)
	public static List<PKB_Article_Feedback_Deflection__c> getArticlesFeedback(String articleIds, String sessionCookie) {
		String query = 'SELECT Article_ID__c, Article_Title__c, Deflection__c FROM PKB_Article_Feedback_Deflection__c WHERE Session_ID__c = \'' + String.escapeSingleQuotes(sessionCookie) + '\' AND Article_ID__c IN ' + articleIds;
		System.debug(LoggingLevel.FINE, '____ [cls PortalFAQsCtrl - getArticlesFeedback] query - ' + query); 

		return Database.query(query);
	}

	@AuraEnabled(cacheable=true)
	public static String getArticleTitle(String articleId) {
		return [SELECT Title FROM FAQ__kav WHERE Id = :articleId].Title;
	}

	@AuraEnabled
	public static void createFeedback(String articleId, String articleNumber, String articleTitle, String feedbackSource, String feedbackComments, String sessionId, Boolean isDeferred) {
		// validate that the feedback source option is a valid option
		Set<String> feedbackSourceOptions = pkb_Controller.getActivePicklistOptions('PKB_Article_Feedback_Deflection__c', 'Feedback_Source__c').keySet();

		String fs = (feedbackSourceOptions.contains(feedbackSource) ? feedbackSource : null);

		PKB_Article_Feedback_Deflection__c articleFeedback = new PKB_Article_Feedback_Deflection__c(
			Article_ID__c = articleId,
			Article_Number__c = articleNumber,
			Article_Title__c = articleTitle,
			Feedback_Source__c = fs,
			Comments__c = feedbackComments != null ? feedbackComments : '',
			Session_ID__c = sessionId,
			Deflection__c = isDeferred
		);

		insert articleFeedback;
	}

	/*
		This method is used for CS Portal searchbar.
		@param urlName - URL Name of the article to be fetch
		@param lang -User/ selected language to return the article, defaults to the english version
		@param datacategories - Categories that the user has access to
	*/
	public static CSP_Utils.PagedResult getFAQbyURLName(String urlName,string lang,string datacategories){

		//Get the articles being referenced
		set<id> articleIdSet=new set<id>();
		String soqlGen='SELECT Id,KnowledgeArticleid, ArticleNumber, Title, Answer__c,language FROM faq__kav WHERE publishstatus =\'Online\' ';
		String soqlTransl=' AND KnowledgeArticleid=:articleIdSet AND language=:lang';
		String soqlEng=' AND language=\'en_US\' AND UrlName=:urlName';
		String soqlDat=' WITH DATA CATEGORY FAQs__c BELOW '+datacategories;
		
		Map<id,faq__kav> articleMap= new map<id,faq__kav>(); // fetch the english version of the article(s) 
		
		//in case of more than one article in english with the same URLName, all articles will be returned
		list<faq__kav> enArticles=Database.query(soqlGen+soqlEng+soqlDat);
		for(FAQ__kav ar:enArticles){
			articleIdSet.add(ar.KnowledgeArticleid);
			articleMap.put(ar.KnowledgeArticleid,ar);
		}

		//Iterate over the translations based on the users language
		list<faq__kav> translatedArticles=Database.query(soqlGen+soqlTransl);
		for(faq__kav faq:translatedArticles){
			if(articleMap.containsKey(faq.KnowledgeArticleid)){ // if version available in the user language, replace for that one
				articleMap.put(faq.KnowledgeArticleid,faq);
			}
		}

		CSP_Utils.PagedResult result= new CSP_Utils.PagedResult();
		result.records=articleMap.values();
		result.totalItemCount=articleMap.values().size();
		return result;
	
	}

	/*
		This method is used for CS Portal searchbar.
		@refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
	*/
	@AuraEnabled (cacheable=true)
	public static CSP_Utils.PagedResult getFilteredFAQsResultsPage(String searchKey, String requestedPage){
		PortalSearchFilterWrapper filtersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(searchKey, PortalSearchFilterWrapper.class);
		Integer requestedPageAux = integer.valueof(requestedPage);
		System.debug(LoggingLevel.FINE, '[cls PortalFAQsCtrl - getFilteredFAQsResultsPage] filtersWrapper - ' + filtersWrapper);
		List<FAQ__kav> lstToReturn = new List<FAQ__kav>();
		//Create an empty default return object
		CSP_Utils.PagedResult result = new CSP_Utils.PagedResult();
		result.records = lstToReturn;
		result.totalItemCount = 0;

		if(filtersWrapper != null && ((filtersWrapper.searchText != null && filtersWrapper.searchText != '') || !String.isEmpty(filtersWrapper.urlName))) {

			List<String> subtopics = new List<String>();
			if(filtersWrapper.faqsComponent == null || filtersWrapper.faqsComponent.faqSubtopicsList == null || filtersWrapper.faqsComponent.faqSubtopicsList.isEmpty()){
				List<DescribeDataCategoryGroupStructures.DataCategoryWrapper> lstStructure = new List<DescribeDataCategoryGroupStructures.DataCategoryWrapper>();
				//Get FAQ structure based on the user visibility
				if(String.isNotBlank(filtersWrapper.language)) {
					lstStructure = PortalFAQsCtrl.getFAQsInfoByLanguage(filtersWrapper.language);
				} else {
					lstStructure = PortalFAQsCtrl.getFAQsInfo();
				}

				if(!lstStructure.isEmpty()) {
					for(DescribeDataCategoryGroupStructures.DataCategoryWrapper category : lstStructure){
						if(category.categoryName != 'All'){
							for(String subtopicAux : category.childs.values()){
								subtopics.add(subtopicAux+'__c');
							}
						}
					}
				}
			}
		
			else{
				for(String subtopicAux : filtersWrapper.faqsComponent.faqSubtopicsList){
					subtopics.add(subtopicAux + '__c');
				}
			}

			String levels = '';
			if(!subtopics.isEmpty()) levels = '(' + String.join(subtopics,' , ') + ' ) ';


			String selectedLang =filtersWrapper.guestUser != null && filtersWrapper.guestUser && String.isNotBlank(filtersWrapper.language)? filtersWrapper.language :  UserInfo.getLanguage();
			
			//IF searching for URLName, invoke specific method to fetch the article(s)
			if(!String.isEmpty(filtersWrapper.urlName)){

				result = getFAQbyURLName(filtersWrapper.urlName,selectedLang,levels);
				return result;
			
			}
			 
			String queryPartOne = 'FIND \'' + String.escapeSingleQuotes(filtersWrapper.searchText) + '\' IN ALL FIELDS '+
						   'RETURNING FAQ__kav(Id, ArticleNumber, Title, Answer__c WHERE PublishStatus = \'online\'';
			
			
			
			String queryPartTwo = ' WITH DATA CATEGORY FAQs__c BELOW ' + levels ;


			//gets list of articles in the user language
			//to be used on exclusion on english version search
			set<string> langARSet = new set<string>();

			
			if(selectedLang != DEFAULT_LANG_EN){ // check only necessary if lang not english

				for(FAQ__kav faq:getArticles(levels, null,selectedLang,null)){
					langARSet.add(faq.ArticleNumber);
				}
			}
				

			//Since SOSL don't have count, the first requested page is queried to all records
			//and then the count is retrived from the returned results list. For the next pages
			//limit and offset is used to improve loading times. 
			if(requestedPageAux == 0){
				String finalQuery;
				if(String.isNotBlank(selectedLang)) {
					finalQuery = queryPartOne + ' AND Language = \'' + selectedLang + '\')';
				} else {
					finalQuery = queryPartOne + ')';
				}
				if(String.isNotBlank(levels)) finalQuery += queryPartTwo;

				System.debug(LoggingLevel.FINE, '[cls PortalFAQsCtrl - getFilteredFAQsResultsPage] finalQuery - ' + finalQuery);
				List<List<SObject>> searchList = Search.query(finalQuery);
				List<FAQ__kav> tmpList = (List<FAQ__kav>)searchList[0];

				if(selectedLang != DEFAULT_LANG_EN){ // check only necessary if lang not english
					//Add articles to set to exclude already retrieved articles				
					for(FAQ__kav faq:tmpList){
						langARSet.add(faq.ArticleNumber);
					}
					string queryLang = ' AND Language =\''+DEFAULT_LANG_EN+'\'';
					string queryException = ' AND ArticleNumber NOT IN :langARSet )';
					
					Integer offset = (requestedPageAux * PortalFAQsCtrl.RESULTS_PER_PAGE) -tmpList.size(); //calculates the available slots for the articles in english

					String offsetQuery = ' LIMIT ' + PortalFAQsCtrl.RESULTS_PER_PAGE + ' OFFSET ' + offset + ')';
					
					finalQuery = queryPartOne +queryLang+queryException;
					if(String.isNotBlank(queryPartTwo)) finalQuery += queryPartTwo;

					searchList = Search.query(finalQuery);
					tmpList.addAll((List<FAQ__kav>)searchList[0]);
				}
				

				for(Integer i = 0; i<tmpList.size() && i < PortalFAQsCtrl.RESULTS_PER_PAGE; i++){
					lstToReturn.add(tmpList.get(i));
				}
				
				result.records = lstToReturn;
				result.totalItemCount = tmpList.size();
			}else{
				Integer offset = requestedPageAux * PortalFAQsCtrl.RESULTS_PER_PAGE;
				String offsetQuery = ' LIMIT ' + PortalFAQsCtrl.RESULTS_PER_PAGE + ' OFFSET ' + offset + ')';

				String finalQuery = queryPartOne + ' AND Language = \'' +selectedLang + '\'' + offsetQuery;
				if(String.isNotBlank(queryPartTwo)) finalQuery += queryPartTwo;
				
				System.debug(LoggingLevel.FINE, '[cls PortalFAQsCtrl - getFilteredFAQsResultsPage] finalQuery - ' + finalQuery);
				List<List<SObject>> searchList = Search.query(finalQuery); // Retrieve articles in selected/ user language
				
				List<FAQ__kav> tmpList = (List<FAQ__kav>)searchList[0];
				if(selectedLang != DEFAULT_LANG_EN){

					//Add articles to set to exclude already retrieved articles
					for(FAQ__kav faq:tmpList){
						langARSet.add(faq.ArticleNumber);
					}
					string queryLang = ' AND Language =\''+DEFAULT_LANG_EN+'\'';
					string queryException = ' AND ArticleNumber NOT IN :langARSet ';//Exclude retrieved articles
					
					offset=offset-tmpList.size();

					offsetQuery = ' LIMIT ' + PortalFAQsCtrl.RESULTS_PER_PAGE + ' OFFSET ' + offset + ')';
					
					finalQuery = queryPartOne +queryLang+queryException+offsetQuery;
					if(String.isNotBlank(queryPartTwo)) finalQuery += queryPartTwo;

					searchList = Search.query(finalQuery);				
					tmpList.addAll((List<FAQ__kav>)searchList[0]);
				}
				result.records = tmpList;
			}
			
		}
		
		return result;
	}

	/*
	* @description Used in Submit for Approval Quick Action on FAQ__kav. Update field Categories according to selected Article Categories.
	* @params List<Id> articleTypeIds
	* @return ApexMessageHandling
	*/
	@AuraEnabled
	public static ApexMessageHandling updateArticleCategories(List<Id> articleTypeIds) {
		List<FAQ__kav> lstArticleType =
			[SELECT Id, Categories__c, PublishStatus, ValidationStatus
			FROM FAQ__kav
			WHERE Id IN:articleTypeIds AND PublishStatus = 'Draft' AND ValidationStatus != 'Pending publication'];

		if(!lstArticleType.isEmpty()) {
			List<FAQ__DataCategorySelection> lstDC =
				[SELECT ParentId, DataCategoryName
				FROM FAQ__DataCategorySelection
				WHERE ParentId IN:articleTypeIds];

			Map<Id, String> datacategoryNameMap = new Map<Id, String>();
			String str;
			for(FAQ__DataCategorySelection dcObj:lstDC) {
				if(datacategoryNameMap.containsKey(dcObj.ParentId)) {
					str = datacategoryNameMap.get(dcObj.ParentId);
					datacategoryNameMap.put(dcObj.ParentId, str + ',' + dcObj.DataCategoryName);
				}
				else {
					datacategoryNameMap.put(dcObj.ParentId, dcObj.DataCategoryName);
				}
			}

			for(FAQ__kav artObj:lstArticleType) {
				if(datacategoryNameMap.containsKey(artObj.Id)) {
					artObj.Categories__c = datacategoryNameMap.get(artObj.Id);
				}
			}

			try {
				update lstArticleType;
				return new ApexMessageHandling();
			} catch(DmlException e) {
				return new ApexMessageHandling(false, e.getMessage());
			}
		} else {
			return new ApexMessageHandling(false, Label.CSP_PendingApproval);
		}
	}

	/*
	* @description Submit a record for approval.
	* @params String approvalNameOrId, Id recordId, Id userId, String comments
	* @return
	*/
	@AuraEnabled
	public static void submitArticleForApproval(String approvalNameOrId, Id recordId, Id userId, String comments) {
		// Contains generic methods related to Approval Process, which can be used just passing params
		AMS_OSCAR_ApprovalHelper.submit(approvalNameOrId, recordId, userId, comments);
	}
}