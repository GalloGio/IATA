@isTest
public class PortalSearchFilterWrapperTest {

    @isTest
    public static void PortalSearchFilterWrapperTest_testOne() {
        
        Test.StartTest();

        PortalSearchFilterWrapper.casesComponent casesComponent = new PortalSearchFilterWrapper.casesComponent();
        casesComponent.show = true;
        casesComponent.loading = true;
        casesComponent.highlight = true;
        casesComponent.nrResults = '1';
        casesComponent.caseTypeFilter = '';
        casesComponent.caseCountryFilter = '';

        PortalSearchFilterWrapper.faqsComponent faqsComponent = new PortalSearchFilterWrapper.faqsComponent();
        faqsComponent.show = true;
        faqsComponent.loading = true;
        faqsComponent.highlight = true;
        faqsComponent.nrResults = '1';
        faqsComponent.faqCategoryFilter = '';
        faqsComponent.faqTopicFilter = '';
        faqsComponent.faqSubtopicFilter = '';
        faqsComponent.faqSubtopicsList = new List<String>();

        PortalSearchFilterWrapper.servicesComponent servicesComponent = new PortalSearchFilterWrapper.servicesComponent();
        servicesComponent.show = true;
        servicesComponent.loading = true;
        servicesComponent.highlight = true;
        servicesComponent.nrResults = '1';

        PortalSearchFilterWrapper.documentsComponent documentsComponent = new PortalSearchFilterWrapper.documentsComponent();
        documentsComponent.show = true;
        documentsComponent.loading = true;
        documentsComponent.highlight = true;
        documentsComponent.documentCategoryFilter = '1';
        documentsComponent.documentProductCategoryFilter = '1';
        documentsComponent.documentCountryFilter = '1';

        PortalSearchFilterWrapper psfw = new PortalSearchFilterWrapper();
        psfw.showAllComponents = true;
        psfw.searchText = '';
        psfw.highlightTopResults = true;
        psfw.advancedSearch = true;

        psfw.casesComponent = casesComponent;
        psfw.faqsComponent = faqsComponent;
        psfw.servicesComponent = servicesComponent;
        psfw.documentsComponent = documentsComponent;

        Test.StopTest();
    }

}