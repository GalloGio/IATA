public with sharing class PortalBreadcrumbCtrl {

	@AuraEnabled
	public static List<Breadcrumb__mdt> getBreadcrumbs(String pageName){
		List<Breadcrumb__mdt> lstbreadcrumbs = new List<Breadcrumb__mdt>(20);

		//because name cannot have - , instead replace with _
		String finalPageName = pageName.replaceAll('-', '_');

		List<Breadcrumb__mdt> lstAux = [SELECT DeveloperName,
										Label,Language,MasterLabel,
										ParentPage__c,Replace_With_Param__c FROM Breadcrumb__mdt
										WHERE Environment__c = 'CSPortal'];

		if(lstAux != null && !lstAux.isEmpty()){
			Boolean finishedSearch = false;
			while(!finishedSearch){

				Breadcrumb__mdt foundBreadcrumb = null;

				for(Breadcrumb__mdt breadcrumbAux : lstAux){
					if(breadcrumbAux.DeveloperName == finalPageName){
						foundBreadcrumb = breadcrumbAux;

						if(breadcrumbAux.ParentPage__c == null || breadcrumbAux.ParentPage__c == ''){
							finishedSearch = true;
						}else{
							finalPageName = breadcrumbAux.ParentPage__c;
						}
						break;
					}
				}

				if(foundBreadcrumb == null){
					finishedSearch = true;
				}else{
					lstbreadcrumbs.add(0,foundBreadcrumb);
				}
			}
		}

		return lstbreadcrumbs;
	}
}
