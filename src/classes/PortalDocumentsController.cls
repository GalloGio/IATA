public with sharing class PortalDocumentsController {

	public static Integer RESULTS_PER_PAGE = 10;
	public static Integer requestedPageNumber;
	public static CSP_Utils.PagedResult result;

	/*
	* @description Main method that returns a list of ContentVersion records based on user level access
	* @params String searchKey, String category, String prodCat, String publiCountry, Integer requestedPage
	* @return CSP_Utils.PagedResult
	*/
	@AuraEnabled(cacheable=true)
	public static CSP_Utils.PagedResult getSearchDocuments(String searchKey, String category, String prodCat, String publiCountry, Integer requestedPage, String docId) {
		String UserPortalStatus;
		String UserPortalCountry;
		String UserPortalRegion;
		String UserPortalCategory;
		String UserPortalRecodType;
		String UserPortalAccountSector;
		String soql;
		String queryConditions;
		String queryLimit;
		Set<Id> DocIds_set;
		Set<Id> PublicDocIds_set;
		List<ContentWorkspaceDoc> ContentWorkspaceDoc_Lst;
		List<ContentWorkspaceDoc> PublicDocs_list;
		List<String> AccessLibraryName;
		List<Access_to_Libraries_on_Portal__c> accessToLibrariesCS = Access_to_Libraries_on_Portal__c.getAll().values(); /* Custom Setting to control the visibility on Libraries */

		Contact PortalContact = [
			SELECT User_Portal_Status__c, Account.Sector__c, Account.Category__c, Account.RecordType.Name,
				Account.IATA_ISO_Country__r.Name, Account.IATA_ISO_Country__r.Region__c, Account.ICH_Member__c
			FROM Contact
			WHERE Id = :[SELECT ContactId FROM User WHERE Id = :UserInfo.getUserId()].ContactId
			LIMIT 1
		];
		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] PortalContact - ' + PortalContact);

		UserPortalStatus = String.isNotBlank(PortalContact.User_Portal_Status__c) ? PortalContact.User_Portal_Status__c : 'NoStatusValue';
		UserPortalCountry = String.isNotBlank(PortalContact.Account.IATA_ISO_Country__r.Name) ? PortalContact.Account.IATA_ISO_Country__r.Name : 'NoCountryValue';
		UserPortalRegion = String.isNotBlank(PortalContact.Account.IATA_ISO_Country__r.Region__c) ? PortalContact.Account.IATA_ISO_Country__r.Region__c : 'NoRegionValue';
		UserPortalAccountSector = String.isNotBlank(PortalContact.Account.Sector__c) ? PortalContact.Account.Sector__c : 'NoSectorValue';
		UserPortalCategory = String.isNotBlank(PortalContact.Account.Category__c) ? PortalContact.Account.Category__c : 'NoCategoryValue';
		UserPortalRecodType = String.isNotBlank(PortalContact.Account.RecordType.Name) ? PortalContact.Account.RecordType.Name : 'NoRecordTypeValue';

		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] UserPortalAccountSector / UserPortalCategory / UserPortalRecodType - ' + UserPortalAccountSector + ' / ' + UserPortalCategory + ' / ' + UserPortalRecodType);

		AccessLibraryName = new List<String>();
		/* Get library names which can be visible based on Account Sector and Record Type */
		for(Access_to_Libraries_on_Portal__c a : accessToLibrariesCS) {
			System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] accessToLibrariesCS - ' + a);
			if(((a.Category_of_Account__c == UserPortalCategory && a.Sector_of_Account__c == UserPortalAccountSector && a.Record_Type_of_Account__c == UserPortalRecodType) ||
				a.Category_of_Account__c == 'All' && a.Sector_of_Account__c == UserPortalAccountSector && a.Record_Type_of_Account__c == UserPortalRecodType)) {

				String libs = String.valueOf(a.Library_visibility__c);
				System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] Library_visibility__c - ' + libs);
				for(String lib : libs.split(',')) {
					AccessLibraryName.add(lib);
				}
			}
		}

		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] AccessLibraryName - ' + AccessLibraryName);
		DocIds_set = new Set<Id>();
		/* Get Library Ids */
		if(!AccessLibraryName.isEmpty()) {
			ContentWorkspaceDoc_Lst = new List<ContentWorkspaceDoc>([
				SELECT Id, ContentDocumentId, ContentWorkspaceId
				FROM ContentWorkspaceDoc
				WHERE ContentWorkspaceId = :[SELECT Id FROM ContentWorkspace WHERE Name IN :AccessLibraryName]
			]);
			System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] ContentWorkspaceDoc_Lst - ' + ContentWorkspaceDoc_Lst);

			if(!ContentWorkspaceDoc_Lst.isEmpty()) {
				for(ContentWorkspaceDoc libId : ContentWorkspaceDoc_Lst) {
					DocIds_set.add(libId.ContentDocumentId);
				}
			}
		}

		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] DocIds_set - ' + DocIds_set);

		if (UserPortalAccountSector == 'General Public') {
			PublicDocs_list = [
				SELECT ContentDocumentId
				FROM ContentWorkspaceDoc
				WHERE ContentWorkspace.Name = 'Public'
			];
		} else {
			PublicDocs_list = [
				SELECT ContentDocumentId
				FROM ContentWorkspaceDoc
				WHERE ContentWorkspace.Name = 'Public' OR ContentWorkspace.Name = 'Third Party'
			];
		}
		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] PublicDocs_list - ' + PublicDocs_list);

		PublicDocIds_set = new Set<Id>();
		for(ContentWorkspaceDoc doc : PublicDocs_list) {
			PublicDocIds_set.add(doc.ContentDocumentId);
		}

		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] PublicDocIds_set - ' + PublicDocIds_set);

		soql = 'SELECT Id, Title, Description, Product_Category__c, FileType, OwnerId,Owner.Name, '+
					'VersionNumber, Country_visibilty__c, User_status_access__c, Region__c, TagCsv, '+
					'ContentSize, Language__c, ContentDocumentId, Document_Category__c, Country_of_publication__c, ContentUrl, ICH_Member_Only__c, LastModifiedDate'+
				' FROM ContentVersion';

		String searchQuery = '';
		if(String.isNotBlank(searchKey)){
			String[] searchTerms = searchKey.split(' ');
			String searchQuery = '(';
			for(String term : searchTerms)
				searchQuery += 'Title LIKE \'%'+ String.escapeSingleQuotes(term) +'%\' OR ';

			if(searchQuery.indexOf(' OR ') > -1)
				searchQuery.removeEnd(' OR ');
			searchQuery += ')';
			searchKey = searchQuery;
		}
		else searchKey = 'Title LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\'';

		queryConditions = ' WHERE IsLatest = true AND ' + searchKey;

		if(String.isNotBlank(category)){
			category = category.replace(' ','%');
			queryConditions += ' AND Document_Category__c = \''+ String.escapeSingleQuotes(category) +'\'';			
		}else{
			List<CSP_Utils.PickListWrapper> lstAllCats = CSP_Utils.getPickListValues('ContentVersion','Document_Category__c');
			
			List<String> catsToCommaString = new List<String>();
			
			for(CSP_Utils.PickListWrapper cat : lstAllCats){
				catsToCommaString.add(String.escapeSingleQuotes(cat.value));
			}

			queryConditions += ' AND (Document_Category__c IN: catsToCommaString AND Document_Category__c != null) ';
		}

		if(String.isNotBlank(prodCat)) queryConditions += ' AND Product_Category__c LIKE \'%'+ String.escapeSingleQuotes(prodCat) +'%\'';
		if(String.isNotBlank(publiCountry)) queryConditions += ' AND Country_of_publication__c includes (\''+ String.escapeSingleQuotes(publiCountry) +'\')';
		if(String.isNotBlank(docId)) queryConditions += ' AND Id = \''+ String.escapeSingleQuotes(docId) +'\'';

		queryConditions += ' AND User_status_access__c includes (\''+ String.escapeSingleQuotes(UserPortalStatus) +'\')'+
					' AND ((ContentDocumentId IN: DocIds_set'+
					' AND Country_visibilty__c includes (\'All - Globally\', \''+ String.escapeSingleQuotes(UserPortalCountry) +'\', \'All - Region '+ String.escapeSingleQuotes(UserPortalRegion) +'\'))'+
					' OR (ContentDocumentId IN: PublicDocIds_set))';

		queryLimit = ' LIMIT ' + RESULTS_PER_PAGE + ' OFFSET ' + Integer.valueOf(requestedPage) * RESULTS_PER_PAGE;

		System.debug('____ [cls PortalDocumentsController - getSearchDocuments] queryString - ' + soql + queryConditions + queryLimit);

		ContentVersion[] contents = Database.query(soql + queryConditions + queryLimit);
		System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] contents - ' + contents);


		/* Filtering by products membership (ICH only, SIS only...) */
		for(Integer j = 0; j < contents.size(); j++) {
			if(contents[j].ICH_Member_Only__c) {
				if(!PortalContact.Account.ICH_Member__c) {
					System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] content - ' + contents[j]);
					contents.remove(j);
				}
			}
		} 
		result = new CSP_Utils.PagedResult();
		if(requestedPage == 0) {
			result.totalItemCount = Database.countQuery('SELECT COUNT() FROM ContentVersion' + queryConditions);
		}

		result.records = sortContentVersions(contents, UserPortalCountry, UserPortalRegion);

		return result;
	}

	public class docWrapper{
	
		@AuraEnabled
		public sobject record;
		@AuraEnabled
		public boolean isBookmarked;
		public docWrapper(ContentVersion cv,boolean ibm){
			this.record=cv;
			this.isBookmarked=ibm;
		}

	}

	/*
	* @description Filter method to return the ContentVersion records that a user has access
	* @params List<ContentVersion> docs, String UserPortalCountry, String UserPortalRegion
	* @return List<ContentVersion>
	*/
	@TestVisible
	private static List<ContentVersion> sortContentVersions(List<ContentVersion> docs, String UserPortalCountry, String UserPortalRegion) {
		List<ContentVersion> retDocs = new List<ContentVersion>();
		Set<Integer> excludeIndexes = new Set<Integer>();
		Integer currentIndex = 0;

		/* Add from user country (exact match) */
		for(ContentVersion doc : docs) {
			if(doc.Country_of_publication__c != null && doc.Country_of_publication__c.equals(String.escapeSingleQuotes(UserPortalCountry))) {
				retDocs.add(doc);
				excludeIndexes.add(currentIndex);
			}
			currentIndex++;
		}

		/* Add from user country (not exact match) */
		currentIndex = 0;
		for(ContentVersion doc : docs) {
			if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false && doc.Country_of_publication__c.contains(String.escapeSingleQuotes(UserPortalCountry))) {
				retDocs.add(doc);
				excludeIndexes.add(currentIndex);
			}
			currentIndex++;
		}

		/* Add from region */
		currentIndex = 0;
		for(ContentVersion doc : docs) {
			if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false && doc.Country_of_publication__c.contains(String.escapeSingleQuotes(UserPortalRegion))) {
				retDocs.add(doc);
				excludeIndexes.add(currentIndex);
			}
			currentIndex++;
		}

		/* Add from all global */
		currentIndex = 0;
		for(ContentVersion doc : docs) {
			if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false && doc.Country_of_publication__c.contains('All - Globally')) {
				retDocs.add(doc);
				excludeIndexes.add(currentIndex);
			}
			currentIndex++;
		}

		/* Add from all other not blank */
		currentIndex = 0;
		for(ContentVersion doc : docs) {
			if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false) {
				retDocs.add(doc);
				excludeIndexes.add(currentIndex);
			}
			currentIndex++;
		}

		/* Add other */
		currentIndex = 0;
		for(ContentVersion doc : docs) {
			if(excludeIndexes.contains(currentIndex) == false) {
				retDocs.add(doc);
			}
			currentIndex++;
		}
		System.debug('____ [cls PortalDocumentsController - sortContentVersions] retDocs - ' + retDocs);

		return retDocs;
	}


	/*
	* @description Returns the list of content Versions  that the user has access with bookmark information
	* @params String searchKey, String category, String prodCat, String publiCountry, Integer requestedPage
	* @return CSP_Utils.PagedResult
	*/
	@AuraEnabled(cacheable=false)
	public static CSP_Utils.PagedResult getSearchDocumentsWithBookmarks(String searchKey, String category, String prodCat, String publiCountry, Integer requestedPage, String docId) {
		

		//Retrieve documents from main method
		CSP_Utils.PagedResult docList=getSearchDocuments(searchKey, category, prodCat, publiCountry, requestedPage, docId);
		
		
		//Fetch the documents bookmarked by this user
		set<Id> bookmarkedDocSet= new set<Id>();
		for(EntitySubscription es:[select parentId from EntitySubscription where SubscriberId =:UserInfo.getUserId() limit 1000]){
			bookmarkedDocSet.add(es.parentId);
		}

		list<docWrapper> resultList= new list<docWrapper>();
		for(ContentVersion cv:(List<ContentVersion>)docList.records){
			resultList.add( new docWrapper(cv,bookmarkedDocSet.contains(cv.ContentDocumentId)));
		}
		docList.recordsString =  JSON.Serialize(resultList);
		docList.records=null;
	
		return docList;
	}


	/*
	* @description Method to bookmark unbookmark a specific document
	* @params String docId- ContentDocument Id of the document to apply action
	* @return CSP_Utils.PagedResult
	*/
	@AuraEnabled
	public static void toggleBookmarkDocument(String docId){
		Id usrId=UserInfo.getUserId();
		list<EntitySubscription> entSubList=[Select id from EntitySubscription where ParentId=:docId and SubscriberId=:usrId limit 1];

		try{
			//Check if document is not bookmarked
			if(entSubList.isEmpty()){					

				//get community Id to add to file
				Id netId=[Select id from network where name ='CS Portal'].id;
				
				insert new EntitySubscription (    
					ParentId=docId,
					SubscriberId=usrId,
					NetworkId=netId
				);
			}else{			
				delete entSubList.get(0);
			}				
			
		} catch(Exception e){
			System.debug(LoggingLevel.FINE, e.getMessage());
			throw new CSP_Utils.portalException(Label.ISSP_ANG_GenericError);
		}
	}

	/*
	* @description Method to fetch the list of the documents bookmarked by the user
	* @params String searchKey- Possible search key for searchign a specific doc(empty if to retrieve all docs);
	* @params Integer searchKey- NR of the requested Page for pagination purposes
	* @return CSP_Utils.PagedResult
	*/
	
	@AuraEnabled(cacheable=true)
	public static CSP_Utils.PagedResult getBookmarkedDocuments(String searchKey,integer requestedPage) {
	
		Id usrId=UserInfo.getUserId();
		CSP_Utils.PagedResult respWrapper = new CSP_Utils.PagedResult();

		if(requestedPage==null) requestedPage=1;

		set<id> entitySet= new set<id>();
		for(EntitySubscription es:[select ParentId FROM EntitySubscription WHERE SubscriberId=:usrId limit 1000]){
			entitySet.add(es.ParentId);
		}

		String soqlFields = 'SELECT Id, Title, Description, Document_Category__c, Product_Category__c, FileType, '+
					'VersionNumber, Country_visibilty__c, Region__c,Country_of_publication__c, '+
					'ContentSize, Language__c, ContentDocumentId, ContentUrl,LastModifiedDate';

		String soqlCount='SELECT COUNT()';
		String soqlFrom=' FROM ContentVersion '+
						'WHERE IsLatest = true '+
						'AND ContentDocumentid in :entitySet';

		if(String.isNotBlank(searchKey)){
			searchKey = searchKey.replace(' ','%');
		}
		String sqlCond=String.isNotEmpty(searchKey)?' AND Title LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\'':'';
		String sqlSort=' ORDER BY Title ASC';
		respWrapper.totalItemCount = Database.countQuery(soqlCount+soqlFrom+sqlCond);

		if(respWrapper.totalItemCount <=RESULTS_PER_PAGE) requestedPage=1;

		String finalQuery=soqlFields+soqlFrom+sqlCond+sqlSort;

		finalQuery+=' LIMIT '+RESULTS_PER_PAGE+' OFFSET '+ (requestedPage -1) * RESULTS_PER_PAGE;

		List<ContentVersion> documentsList= Database.query(finalQuery);


		respWrapper.recordsString = JSON.Serialize(documentsList);

		return respWrapper;
	}
}