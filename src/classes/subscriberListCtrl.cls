public with sharing class subscriberListCtrl {


    //Retrieves list of the document subscribers
    //@param docId: Id of the content document being subscribed
    //@param searchDtl: searchWrapper containig search parameters of the type CSP_utils.searchDetailsWrapper
	@AuraEnabled(cacheable=true)
	public static CSP_Utils.PagedResult getDocumentSubscribers(string docId,string searchDtl){
		Integer nrPageRecords=20;
		string sortFld;
		string sortDir;
		Integer pagenr;

		CSP_Utils.PagedResult  result= new CSP_Utils.PagedResult ();
		if(!String.IsEmpty(searchDtl)){

			CSP_Utils.searchDetailsWrapper searchObj=(CSP_Utils.searchDetailsWrapper)JSON.deserialize(searchDtl,CSP_Utils.searchDetailsWrapper.class);
			sortFld=(string)searchObj.sortField;
			sortDir=(string)searchObj.sortDirection;
			pagenr=searchObj.requestedPage;
		}
		string soql1='SELECT id,Name,Email,Contact.Name,Contact.AccountId,Contact.Account.Name,Contact.Account.Category__c,Contact.Account.IATA_ISO_Country__r.name,toLabel(LanguageLocaleKey) language, Contact.User_Portal_Status__c, Contact.Title  ';
		string soqlCount='SELECT count()';

		string soql2='FROM user '+
			'WHERE id in ( select subscriberId from entitySubscription where parentId=:docId)';

		if(pagenr==1) result.totalItemCount=Database.countQuery(soqlCount+soql2);

		if(sortFld!=null) soql2+='ORDER BY '+sortFld+' '+sortDir;
		
		string strlimit=' LIMIT '+pagenr*nrPageRecords;


		List<user> userList=Database.query(soql1+soql2+strlimit);

		result.records=userList;

		return result;

	}

}