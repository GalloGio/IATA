public with sharing class PortalNewsController {

    public static List<ISSP_Banner__c> Banners_List;
    public static List<ISSP_Banner__c> unFilteredBanner_List;
    public static List<WrapperBanner> wrapperBanItem_List;
    public static String UserPortalCountry;
    public static String UserPortalRegion;

    /* 
    * @description Main method that returns a List of Wrapper Class, with the Banner itself and its last uploaded image
    * @params
    * @return List<WrapperBanner>
    */
    @AuraEnabled(cacheable=true)
    public static List<WrapperBanner> getBannerInformation() {

        populateVariables();
        filterContentVersionByCountry(UserPortalCountry, UserPortalRegion);
        System.debug('____ [cls PortalNewsController - getBannerInformation] Banners_List - ' + Banners_List);

        if(Banners_List.isEmpty()) {
            getDefaultBanner();
        }

        createWrapperContent();
        System.debug('____ [cls PortalNewsController - getBannerInformation] wrapperBanItem_List - ' + wrapperBanItem_List.size() + ' record(s) - ' + wrapperBanItem_List);

        return wrapperBanItem_List;
    }

    /* 
    * @description Populate "Banners_List" from records of ISSP_Banner__c related to the logged contact
    * @params
    * @return
    */
    private static void populateVariables() {
        String UserPortalStatus;
        String UserPortalAccountSector;
        String soql;
        String TodayInstance = String.valueOf(Date.today());
        User portalUser = [
                SELECT Id, ContactId
                FROM User 
                WHERE Id = :UserInfo.getUserId()
        ];    
        Contact PortalContact = [
            SELECT User_Portal_Status__c, Account.Sector__c, 
                Account.IATA_ISO_Country__r.Name, Account.IATA_ISO_Country__r.Region__c 
            FROM Contact 
            WHERE Id = :portalUser.ContactId
            LIMIT 1
        ];
        System.debug('____ [cls PortalNewsController - populateVariables] PortalContact - ' + PortalContact);

        UserPortalStatus = String.isNotEmpty(PortalContact.User_Portal_Status__c) ? PortalContact.User_Portal_Status__c : 'NoStatusValue';   
        UserPortalCountry = String.isNotEmpty(PortalContact.Account.IATA_ISO_Country__r.Name) ? PortalContact.Account.IATA_ISO_Country__r.Name : 'NoCountryValue';
        UserPortalRegion = String.isNotEmpty(PortalContact.Account.IATA_ISO_Country__r.Region__c) ? PortalContact.Account.IATA_ISO_Country__r.Region__c : 'NoRegionValue';
        UserPortalAccountSector = String.isNotEmpty(PortalContact.Account.Sector__c) ? PortalContact.Account.Sector__c : 'NoSectorValue';

        System.debug('____ [cls PortalNewsController - populateVariables] UserPortalCountry / UserPortalRegion - ' + UserPortalCountry + ' / ' + UserPortalRegion);

        soql =  'SELECT Id, Country__c, Publication_end_date__c, Publication_start_date__c, Sector__c, Status__c, User_portal_Status__c '+
                'FROM ISSP_Banner__c '+
                'WHERE Status__c = \'Active\''+
                ' AND Publication_start_date__c < ' + TodayInstance +
                ' AND Publication_end_date__c > ' + TodayInstance +
                ' AND User_portal_Status__c INCLUDES (\'' + String.escapeSingleQuotes(UserPortalStatus) + '\')' +
                ' AND Sector__c INCLUDES (\'' + String.escapeSingleQuotes(UserPortalAccountSector) + '\')' +
                ' AND Name != \'Ban-001\'';

        System.debug(LoggingLevel.FINE, '____ [cls PortalNewsController - populateVariables] soql - ' + soql);

        unFilteredBanner_List = Database.query(soql + ' ORDER BY Publication_start_date__c DESC LIMIT 8');
        System.debug('____ [cls PortalNewsController - populateVariables] unFilteredBanner_List - ' + unFilteredBanner_List.size() + ' record(s) - ' + unFilteredBanner_List);

        Banners_List = new List<ISSP_Banner__c>();
        if(!unFilteredBanner_List.isEmpty()) {
            Banners_List = unFilteredBanner_List;
        }
    }

    /* 
    * @description Filter Banner records by Account Country Name and Country Region
    * @params String UserPortalCountry, String UserPortalRegion
    * @return
    */
    private static void filterContentVersionByCountry(String UserPortalCountry, String UserPortalRegion) {
        Set<ISSP_Banner__c> tmpBanner_set = new Set<ISSP_Banner__c>();
        
        for(ISSP_Banner__c ban : unFilteredBanner_List) {
            System.debug(LoggingLevel.FINE, '____ [cls PortalNewsController - filterContentVersionByCountry] ban.Country - ' + ban.Country__c);

            if(ban.Country__c != null && (ban.Country__c.contains(UserPortalCountry) || ban.Country__c.contains(UserPortalRegion) || ban.Country__c.contains('All - Globally'))) {
                tmpBanner_set.add(ban);
            }
        }
        System.debug('____ [cls PortalNewsController - filterContentVersionByCountry] tmpBanner_set - ' + tmpBanner_set);

        if(!tmpBanner_set.isEmpty()) {
            Banners_List.clear();
            Banners_List.addAll(tmpBanner_set);
        } else {
            Banners_List.clear();
        }
        
        tmpBanner_set.clear();
    }

    /* 
    * @description Handels the case when no records matches criteria by adding Default banner
    * @params
    * @return
    */
	private static void getDefaultBanner() {
		List<ISSP_Banner__c> noResults_List = new List<ISSP_Banner__c>([
            SELECT Id,  Country__c, Publication_end_date__c, Publication_start_date__c, Sector__c, Status__c, User_portal_Status__c
            FROM ISSP_Banner__c
            WHERE Name  = 'Ban-001'
        ]);

		if(!noResults_List.isEmpty()) {
            Banners_List = noResults_List;
            System.debug('____ [cls PortalNewsController - getDefaultBanner] Banners_List - ' + Banners_List);
		}
	}

    /* 
    * @description Get latest uploaded Banner images to display
    * @params Set<Id> bannersId, Map<Id, Id> bannerContent
    * @return
    */
    private static void getPictures(Set<Id> bannersId, Map<Id, Id> bannerContent) {
        List<ContentDocumentLink> links = [
            SELECT Id, ContentDocument.Title, ContentDocument.ContentModifiedDate, ContentDocumentId, LinkedEntityId, ContentDocument.LatestPublishedVersionId 
            FROM ContentDocumentLink 
            WHERE LinkedEntityId IN :bannersId AND ContentDocument.FileType IN ('PNG', 'JPG', 'GIF') 
            ORDER BY ContentDocument.ContentModifiedDate
        ];
        System.debug(LoggingLevel.FINE, '____ [cls PortalNewsController - getPictures] links - ' + links);

        if(!links.isEmpty()) {
            Set<Id> contentIds = new Set<Id>();

            for (ContentDocumentLink link :links) {
                bannerContent.put(link.LinkedEntityId, link.ContentDocument.LatestPublishedVersionId);
            }
            System.debug(LoggingLevel.FINE, '____ [cls PortalNewsController - getPictures] bannerContent - ' + bannerContent);
        }
    }

    /* 
    * @description Create the list to be returned for Lightning web component used in Portal, with a reference to the Banner itself and its latest uploaded image
    * @params
    * @return
    */
	private static void createWrapperContent() {
        Map<Id, Id> bannerContent;
        Set<Id> bannersId = new Set<Id>();

        for(ISSP_Banner__c ban :Banners_List) {
           bannersId.add(ban.Id);
        }

        if(!bannersId.isEmpty()) {
            bannerContent = new Map<Id, Id>();
            wrapperBanItem_List = new List<WrapperBanner>();

            getPictures(bannersId, bannerContent);

            for(ISSP_Banner__c ban :Banners_List) {
                if(bannerContent.get(ban.Id) != null) {
                    WrapperBanner wrapItem = new WrapperBanner(ban, bannerContent.get(ban.Id));

                    wrapperBanItem_List.add(wrapItem);
                }   
            }            
        }
    }           

    public class WrapperBanner {
        @AuraEnabled
        public ISSP_Banner__c bannerItem { get;set; }
        @AuraEnabled
        public Id content { get;set; }

        public WrapperBanner(ISSP_Banner__c inBannerItem, Id inContent) {
            this.bannerItem = inBannerItem ;
            this.content = inContent;
        }
    }    
}