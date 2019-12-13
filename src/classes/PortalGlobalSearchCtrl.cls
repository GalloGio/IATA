public with sharing class PortalGlobalSearchCtrl {

/*
 *	Wrapper used to contain all data for the search cards.
 *
 */
public class GlobalSearchWrapper {
@AuraEnabled public String id {get; set;}
@AuraEnabled public String category {get; set;}
@AuraEnabled public String title {get; set;}
@AuraEnabled public String description {get; set;}
@AuraEnabled public String styleClass {get; set;}

public GlobalSearchWrapper(String idAux, String categoryAux,String titleAux, String descriptionAux, String styleClassAux) {
	this.id = idAux;
	this.category = categoryAux;
	this.title = titleAux;
	this.description = descriptionAux;
	this.styleClass = styleClassAux;
}
}

/*
 *	Method that retrieves data from all sources
 *
 */
@AuraEnabled (cacheable=false)
public static CSP_Utils.PagedResult portalGlobalSearch(String filterWrapperAux, String searchObject) {

	PortalSearchFilterWrapper filtersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(filterWrapperAux, PortalSearchFilterWrapper.class);

	CSP_Utils.PagedResult searchResults = new CSP_Utils.PagedResult();

	if(filtersWrapper != null) {

		switch on searchObject {
			when 'Cases' {
				if(filtersWrapper.casesComponent != null && filtersWrapper.casesComponent.show) {
					searchResults = portalGlobalSearchCases(filterWrapperAux);
				}
			}
			when 'FAQS' {
				if(filtersWrapper.faqsComponent != null && filtersWrapper.faqsComponent.show) {
					searchResults = portalGlobalSearchFAQ(filterWrapperAux);
				}
			}
			when 'Services' {
				if(filtersWrapper.servicesComponent != null && filtersWrapper.servicesComponent.show) {
					searchResults = portalGlobalSearchServices(filterWrapperAux);
				}
			}
			when 'Documents' {
				if(filtersWrapper.documentsComponent != null && filtersWrapper.documentsComponent.show) {
					searchResults = portalGlobalSearchDocuments(filterWrapperAux);
				}
			}
			when 'Profiles' {
				if(filtersWrapper.profileComponent != null && filtersWrapper.profileComponent.show) {
					searchResults = portalGlobalSearchProfiles(filterWrapperAux);
				}
			}
			when null {
				System.debug('No object to be searched defined');

			}
			when else{
				System.debug('The object used for the search does not exist');
			}
		}
	}

	return searchResults;
}


private static CSP_Utils.PagedResult portalGlobalSearchCases(String filterWrapperCasesAux){
	return portalCasesCtrl.getFilteredCasesResultsPage(filterWrapperCasesAux, '0', CSP_Utils.isAdmin());
}

private static CSP_Utils.PagedResult portalGlobalSearchFAQ(String filterWrapperFAQAux){
	return PortalFAQsCtrl.getFilteredFAQsResultsPage(filterWrapperFAQAux, '0');
}

private static CSP_Utils.PagedResult portalGlobalSearchDocuments(String filterWrapperDocumentsAux){
	PortalSearchFilterWrapper filtersWrapper = (PortalSearchFilterWrapper) JSON.deserialize(filterWrapperDocumentsAux, PortalSearchFilterWrapper.class);
	return PortalDocumentsController.getSearchDocuments(filtersWrapper.searchText, '', '', '', 0, '');
}

private static CSP_Utils.PagedResult portalGlobalSearchServices(String filterWrapperServicesAux){
	return PortalServicesCtrl.getUserFilteredServices(filterWrapperServicesAux, '0');
}
private static CSP_Utils.PagedResult portalGlobalSearchProfiles(String filterWrapperProfilesAux){
	return portalProfileCtrl.getFilteredProfileResultsPageWithLimit(filterWrapperProfilesAux, '9');
}


}