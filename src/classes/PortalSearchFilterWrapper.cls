public class PortalSearchFilterWrapper {

    @AuraEnabled
    public Boolean showAllComponents {get; set;}
    @AuraEnabled
    public String searchText {get; set;}
    @AuraEnabled
    public Boolean highlightTopResults {get; set;}
    @AuraEnabled
    public Boolean advancedSearch {get; set;}
    @AuraEnabled
    public String language {get; set;}
    @AuraEnabled
    public Boolean guestUser {get; set;}

    @AuraEnabled
    public casesComponent casesComponent {get; set;}
    @AuraEnabled
    public faqsComponent faqsComponent {get; set;}
    @AuraEnabled
    public servicesComponent servicesComponent {get; set;}
    @AuraEnabled
    public documentsComponent documentsComponent {get; set;}

    public PortalSearchFilterWrapper(){}


    /* 
        For the cases filter component
    */
    public class casesComponent {

        @AuraEnabled
        public Boolean show {get; set;}
        @AuraEnabled
        public Boolean loading {get; set;}
        @AuraEnabled
        public Boolean highlight {get; set;}
        @AuraEnabled
        public String nrResults {get; set;}
        @AuraEnabled
        public String caseTypeFilter {get; set;}
        @AuraEnabled
        public String caseCountryFilter {get; set;}
        @AuraEnabled
        public String caseContactFilter {get; set;}
        @AuraEnabled
        public String dateFromFilter {get; set;}
        @AuraEnabled
        public String dateToFilter {get; set;}

        public casesComponent(){}
    }

    /* 
        For the faqs filter component
    */
    public class faqsComponent {

        @AuraEnabled
        public Boolean show {get; set;}
        @AuraEnabled
        public Boolean loading {get; set;}
        @AuraEnabled
        public Boolean highlight {get; set;}
        @AuraEnabled
        public String nrResults {get; set;}
        @AuraEnabled
        public String faqCategoryFilter {get; set;}
        @AuraEnabled
        public String faqTopicFilter {get; set;}
        @AuraEnabled
        public String faqSubtopicFilter {get; set;}
        @AuraEnabled
        public List<String> faqSubtopicsList {get; set;}

        public faqsComponent(){}
    }

    /* 
        For the faqs filter component
    */
    public class servicesComponent {

        @AuraEnabled
        public Boolean show {get; set;}
        @AuraEnabled
        public Boolean loading {get; set;}
        @AuraEnabled
        public Boolean highlight {get; set;}
        @AuraEnabled
        public String nrResults {get; set;}

        public servicesComponent(){}
    }

    /* 
        For the documents filter component
    */
    public class documentsComponent {

        @AuraEnabled
        public Boolean show {get; set;}
        @AuraEnabled
        public Boolean loading {get; set;}
        @AuraEnabled
        public Boolean highlight {get; set;}
        @AuraEnabled
        public String nrResults {get; set;}
        @AuraEnabled
        public String documentCategoryFilter {get; set;}
        @AuraEnabled
        public String documentProductCategoryFilter {get; set;}
        @AuraEnabled
        public String documentCountryFilter {get; set;}

        public documentsComponent(){}
    }

}