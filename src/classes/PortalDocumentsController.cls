public with sharing class PortalDocumentsController {

    /* 
    * @description Main method that returns a list of ContentVersion records based on user level access
    * @params String searchKey
    * @return List<ContentVersion>
    */
    @AuraEnabled(cacheable=true)
    public static List<ContentVersion> getSearchDocuments(String searchKey) {
        String UserPortalStatus;
        String UserPortalCountry;
        String UserPortalRegion;
        String UserPortalCategory;
        String UserPortalRecodType;
        String UserPortalAccountSector;
        String soql;
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

        UserPortalStatus = String.isNotEmpty(PortalContact.User_Portal_Status__c) ? PortalContact.User_Portal_Status__c : 'NoStatusValue';   
        UserPortalCountry = String.isNotEmpty(PortalContact.Account.IATA_ISO_Country__r.Name) ? PortalContact.Account.IATA_ISO_Country__r.Name : 'NoCountryValue';
        UserPortalRegion = String.isNotEmpty(PortalContact.Account.IATA_ISO_Country__r.Region__c) ? PortalContact.Account.IATA_ISO_Country__r.Region__c : 'NoRegionValue';
        UserPortalAccountSector = String.isNotEmpty(PortalContact.Account.Sector__c) ? PortalContact.Account.Sector__c : 'NoSectorValue';
        UserPortalCategory = String.isNotEmpty(PortalContact.Account.Category__c) ? PortalContact.Account.Category__c : 'NoCategoryValue';
        UserPortalRecodType = String.isNotEmpty(PortalContact.Account.RecordType.Name) ? PortalContact.Account.RecordType.Name : 'NoRecordTypeValue';

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

        /* Get Library Ids */
        if(!AccessLibraryName.isEmpty()) {
            ContentWorkspaceDoc_Lst = new List<ContentWorkspaceDoc>([
                SELECT Id, ContentDocumentId, ContentWorkspaceId 
                FROM ContentWorkspaceDoc 
                WHERE ContentWorkspaceId = :[SELECT Id FROM ContentWorkspace WHERE Name IN :AccessLibraryName]
            ]);
            System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] ContentWorkspaceDoc_Lst - ' + ContentWorkspaceDoc_Lst);

            if(!ContentWorkspaceDoc_Lst.isEmpty()) {
                DocIds_set = new Set<Id>();
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

        soql = 'SELECT Id, Title, Description, FileType, OwnerId,Owner.Name, '+
                    'VersionNumber, Country_visibilty__c, User_status_access__c, Region__c, TagCsv, '+
                    'ContentSize, Language__c, ContentDocumentId, Document_Category__c, Country_of_publication__c, ContentUrl, ICH_Member_Only__c'+
                ' FROM ContentVersion'+
                ' WHERE IsLatest = true'+
                    ' AND Title LIKE \'%'+ String.escapeSingleQuotes(searchKey) +'%\''+
                    ' AND User_status_access__c includes (\''+ String.escapeSingleQuotes(UserPortalStatus) +'\')'+
                    ' AND ((ContentDocumentId IN: DocIds_set'+
                    ' AND Country_visibilty__c includes (\'All - Globally\', \''+ String.escapeSingleQuotes(UserPortalCountry) +'\', \'All - Region '+ String.escapeSingleQuotes(UserPortalRegion) +'\'))'+
                    ' OR (ContentDocumentId IN: PublicDocIds_set))';

        System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] soql - ' + soql);

        ContentVersion[] contents = Database.query(soql);
        System.debug('____ [cls PortalDocumentsController - getSearchDocuments] contents - ' + contents);

        /* Filtering by products membership (ICH only, SIS only...) */
        for(Integer j = 0; j < contents.size(); j++) {
            if(contents[j].ICH_Member_Only__c) {
                if(!PortalContact.Account.ICH_Member__c) {
                    System.debug(LoggingLevel.FINE, '____ [cls PortalDocumentsController - getSearchDocuments] content - ' + contents[j]);
                    contents.remove(j);
                }
            }
        }

        return sortContentVersions(contents, UserPortalCountry, UserPortalRegion);
    }


    /* 
    * @description Filter method to return the ContentVersion records that a user has access
    * @params List<ContentVersion> docs, String UserPortalCountry, String UserPortalRegion
    * @return List<ContentVersion>
    */
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
}
