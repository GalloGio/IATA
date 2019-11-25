public with sharing class PortalRecommendationCtrl {

    public static final Id serviceRecommendationRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Recommendations_Visibility__c', 'ServiceRecommendation');

    public static List<String> getQueryFields() {
		return new List<String>{
            'Id',
			'Recommendation_Visibility__r.Id',
            'Recommendation_Visibility__r.PortalService__c',
            'Recommendation_Visibility__r.Product__c',
            'Recommendation_Visibility__r.Icon_URL__c',
            'Recommendation_Visibility__r.Product_Description__c',
            'Recommendation_Visibility__r.Service_Description__c',
            'Recommendation_Visibility__r.StartDate__c',
            'Recommendation_Visibility__r.EndDate__c',
            'Recommendation_Visibility__r.Icon__c',
            'Recommendation_Visibility__r.RecommendationTitle__c',
            'Recommendation_Visibility__r.ActionButtonLink__c',
            'Recommendation_Visibility__r.InformationButtonLink__c',
            'Recommendation_Visibility__r.RecordTypeId',
            'Recommendation_Visibility__r.RecordType.Name',
            'Recommendation_Visibility__r.Important__c',
            'Recommendation_Visibility__r.PortalService__r.Requestable__c',
            'Recommendation_Visibility__r.PortalService__r.Cannot_be_managed_by_portal_admin__c',
            'Recommendation_Visibility__r.DescriptionLabel_ar__c',
            'Recommendation_Visibility__r.DescriptionLabel_de__c',
            'Recommendation_Visibility__r.DescriptionLabel_en_US__c',
            'Recommendation_Visibility__r.DescriptionLabel_es__c',
            'Recommendation_Visibility__r.DescriptionLabel_fr__c',
            'Recommendation_Visibility__r.DescriptionLabel_in__c',
            'Recommendation_Visibility__r.DescriptionLabel_it__c',
            'Recommendation_Visibility__r.DescriptionLabel_ja__c',
            'Recommendation_Visibility__r.DescriptionLabel_ko__c',
            'Recommendation_Visibility__r.DescriptionLabel_pt_BR__c',
            'Recommendation_Visibility__r.DescriptionLabel_ru__c',
            'Recommendation_Visibility__r.DescriptionLabel_th__c',
            'Recommendation_Visibility__r.DescriptionLabel_TR__c',
            'Recommendation_Visibility__r.DescriptionLabel_vi__c',
            'Recommendation_Visibility__r.DescriptionLabel_zh_CN__c'
		};
	}

    public static final String productHighlight = 'CSPortal/Images/Backgrounds/ProductHighlight.JPG';
    public static final String serviceHighlight = 'CSPortal/Images/Backgrounds/ServiceHighlight.JPG';

    public static final String learnMoreLabel = System.Label.CSP_Learn_More;
    public static final String buyOnlineLabel = System.Label.CSP_Buy_Online;
    public static final String requestServiceLabel = System.Label.CSP_Request_Service;
    public static final String goToServiceLabel = System.Label.CSP_Services_GoToService;
    public static final String enableThisServiceLabel = System.Label.ISSP_Enable_Service;

    public static final Boolean isPortalAdmin = CSP_Utils.isAdmin();
    
    @AuraEnabled
    public static List<RecommendationWrapper> getRecommendations(String type) {
        User usr = CSP_Utils.getLoggedUser();
        String LANGUAGE = UserInfo.getLanguage();

        Set<String> availableAppNames = new Set<String>();
        List<PortalServicesCtrl.ServiceWrapper> blaList = PortalServicesCtrl.getUserAvailableServices();
        for(PortalServicesCtrl.ServiceWrapper service : blaList){
            availableAppNames.add(service.recordService.Id);
        }

        List<Card_Visibility__c> recommendationListImportant = new List<Card_Visibility__c>();
        List<Card_Visibility__c> recommendationListNonImportant = new List<Card_Visibility__c>();

        List<RecommendationWrapper> recommendations = new List<RecommendationWrapper>();

        String whereClause = '';

        whereClause += '(Sector__c = \'All\' OR (Sector__c = \'' + usr.Contact.Account.Sector__c + '\' AND Category__c INCLUDES (\'' + usr.Contact.Account.Category__c + '\'))) AND Recommendation_Visibility__r.IsActive__c = true AND Recommendation_Visibility__r.Visible__c = true';

        if( type.equals('Services') ) {
            whereClause += ' AND Recommendation_Visibility__r.RecordTypeId = \'' + serviceRecommendationRecTypeId + '\'';
        }
        
        String recommendationQuery = String.format('SELECT {0} FROM Card_Visibility__c WHERE {1} ORDER BY CreatedDate DESC', 
			new List<String>{String.join(getQueryFields(), ', '), whereClause}
		);

        List<Card_Visibility__c> recommendationList = (List<Card_Visibility__c>) Database.query(recommendationQuery);

        for(Card_Visibility__c rec : recommendationList) {
            if(rec.Recommendation_Visibility__r.Important__c) {
                recommendationListImportant.add(rec);
            } else {
                recommendationListNonImportant.add(rec);
            }
        }

        recommendationList = recommendationListImportant;
        recommendationList.addAll(recommendationListNonImportant);

        String prodDescription = '';
        for(Card_Visibility__c rec : recommendationList) {
            if (rec.Recommendation_Visibility__r.Product__c != null || availableAppNames.contains(rec.Recommendation_Visibility__r.PortalService__c) ) {

                if (rec.Recommendation_Visibility__r.RecordTypeId != serviceRecommendationRecTypeId) {
                    prodDescription = getProductDescriptionWithUserLanguage(LANGUAGE, rec);
                }

                recommendations.add(new RecommendationWrapper(
                    rec.Recommendation_Visibility__r.Icon_URL__c,
                    rec.Recommendation_Visibility__r.RecordType.Name,
                    rec.Recommendation_Visibility__r.RecommendationTitle__c,
                    (rec.Recommendation_Visibility__r.RecordTypeId != serviceRecommendationRecTypeId ? ( !String.isBlank(prodDescription) ? prodDescription : rec.Recommendation_Visibility__r.Product_Description__c): rec.Recommendation_Visibility__r.Service_Description__c),
                    learnMoreLabel,
                    rec.Recommendation_Visibility__r.InformationButtonLink__c,
                    (rec.Recommendation_Visibility__r.RecordTypeId != serviceRecommendationRecTypeId ? buyOnlineLabel : (rec.Recommendation_Visibility__r.PortalService__r.Requestable__c ? (isPortalAdmin ? (rec.Recommendation_Visibility__r.PortalService__r.Cannot_be_managed_by_portal_admin__c == false ? enableThisServiceLabel : requestServiceLabel ) : requestServiceLabel) : goToServiceLabel) ),
                    rec.Recommendation_Visibility__r.ActionButtonLink__c,
                    (rec.Recommendation_Visibility__r.RecordTypeId != serviceRecommendationRecTypeId ? 'PRODUCT' : 'SERVICE')
                ));
            }
            
        }

        return recommendations;
    }

    private static String getProductDescriptionWithUserLanguage(String userLanguage, Card_Visibility__c cardVisibilityAux){
        //fallback to default label if user language was not found
        String defaultLabel = '';

        SObject cardVisibility = cardVisibilityAux;
        String dataCatLanguage = (String) cardVisibility.getSobject('Recommendation_Visibility__r').get('DescriptionLabel_' + userLanguage + '__c');
        String defaultValue = (String) cardVisibility.getSobject('Recommendation_Visibility__r').get('DescriptionLabel_en_US__c');

        if(String.isNotBlank(dataCatLanguage)){
            defaultLabel = dataCatLanguage;
        } else {
            defaultLabel = defaultValue;
        }

        return defaultLabel;
    }

    public class RecommendationWrapper {
        @AuraEnabled
        public String imgURL {get; set;}
        @AuraEnabled
        public String type {get; set;}
        @AuraEnabled
        public String title {get; set;}
        @AuraEnabled
        public String text {get; set;}
        @AuraEnabled
        public String informationButton {get; set;}
        @AuraEnabled
        public String informationButtonLink {get; set;}
        @AuraEnabled
        public String actionButton {get; set;}
        @AuraEnabled
        public String actionButtonLink {get; set;}
        @AuraEnabled
        public String actionType {get; set;}

        public RecommendationWrapper(String imgURL, String type, String title, String text, String informationButton, String informationButtonLink, String actionButton, String actionButtonLink, String actionType) {
            this.imgURL = imgURL;
            this.type = type;
            this.title = title;
            this.text = text;
            this.informationButton = informationButton;
            this.informationButtonLink = informationButtonLink;
            this.actionButton = actionButton;
            this.actionButtonLink = actionButtonLink;
            this.actionType = actionType;
        }
    }

    @AuraEnabled
    public static String getBaseURL() {
        return URL.getSalesforceBaseUrl().toExternalForm();
    } 

}
