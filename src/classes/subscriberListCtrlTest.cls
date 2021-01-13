@isTest
private class subscriberListCtrlTest {


    @TestSetup
    private static void testSetup() {
		

        ContentVersion content = new ContentVersion();
        content.Title = 'ContentVersion Test Portal Documents';
        content.Country_of_publication__c = 'Belgium';
        content.Country_visibilty__c = 'All - Globally';
        content.Document_Category__c = 'Calendars';
        content.User_status_access__c = 'Approved User;Approved Admin';
        content.PathOnClient ='test';
        content.versiondata=EncodingUtil.base64Decode('Unit Test Attachment Body');
        
        insert content;

        content=[select contentDocumentId from contentVersion where id=:content.id];

        EntitySubscription es= new EntitySubscription(
            ParentId=content.contentDocumentId,
            SubscriberId=UserInfo.getUserId()
            
        );

        insert es;

	}

    @IsTest
    static void testGetSubscribers(){
        
        contentVersion doc= [select contentDocumentId from contentVersion where title='ContentVersion Test Portal Documents' limit 1];
        Test.startTest();

            CSP_Utils.searchDetailsWrapper searchWrapper= new  CSP_Utils.searchDetailsWrapper();
            searchWrapper.sortField ='Name';
            searchWrapper.sortDirection='Desc';
            searchWrapper.requestedPage=1;
           
            string searchDtl =JSON.serialize(searchWrapper);
            CSP_Utils.PagedResult result= subscriberListCtrl.getDocumentSubscribers(doc.contentDocumentId, searchDtl);
            system.assertEquals(1,result.records.size());
            system.assertEquals(1,result.totalItemCount);
        Test.stopTest();
        
    }

}