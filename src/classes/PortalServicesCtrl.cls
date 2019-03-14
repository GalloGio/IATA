public with sharing class PortalServicesCtrl {


/*
   @AuraEnabled
   public static List<PageWrapper> getServicePages(String refinedSearchSerialized){
    List<Portal_Application_Right__c> lstServices = PortalServicesCtrl.getUserServicesList(refinedSearchSerialized);
    System.debug('lstServices: ' + lstServices);
    List<PageWrapper> lstToReturn = new List<PageWrapper>();

    if(lstServices != null && !lstServices.isEmpty()){

        Integer sizeLista = lstServices.size();

        Double auxNumPages = sizeLista / 5 *(1000 / 1000);
        System.debug('auxNumPages: ' + auxNumPages);

        Decimal auxNumPages2 = Math.ceil(auxNumPages);
        System.debug('auxNumPages2: ' + auxNumPages2);

        Integer numPages = (Integer)auxNumPages;
        System.debug('lstServices.size(): ' + lstServices.size());
        System.debug('numPages: ' + numPages);

        for(Integer i = 0; i<Math.min(numPages,3); i++){
            System.debug('i: ' + i);
            PageWrapper pageWrapperAux = new PageWrapper();

            pageWrapperAux.hasPrevious = i > 0;

            pageWrapperAux.hasNext = i < Math.min(numPages,3)-1;

            lstToReturn.add(pageWrapperAux);
        }


    }

    return lstToReturn;

   }

   public class PageWrapper{

    @AuraEnabled
    public Boolean hasPrevious{get; set;}
    @AuraEnabled
    public Boolean hasNext{get; set;}
    @AuraEnabled
    public Integer currentPage{get; set;}
    @AuraEnabled
    public List<SuperTile> lstSupertiles{get; set;}

    public PageWrapper(){}
   }

   public class SuperTile{

    @AuraEnabled
    public List<Tile> lstTiles {get; set;}

    public SuperTile(){}

   }

   public class Tile{

    @AuraEnabled
    public Boolean height {get; set;}
    @AuraEnabled
    public Portal_Application_Right__c portalApplicationRight {get; set;}

    public Tile (){}
   }*/



/*
    This method is used for CS Portal searchbar.
    @refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
 */
@AuraEnabled (cacheable=true)
public static List<Portal_Application_Right__c> getUserServicesList(String refinedSearchSerialized){
	User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

	String contactId = userAux.ContactId;

	FilteringObject refinedSearch = null;

	System.debug('refinedSearchSerialized: ' + refinedSearchSerialized);

	if(refinedSearchSerialized != null && refinedSearchSerialized != '') {
		refinedSearch = (FilteringObject) JSON.deserialize(refinedSearchSerialized, FilteringObject.class);
	}

	System.debug('refinedSearch: ' + refinedSearch);

	//base query
	String finalQuery = 'Select Application_Name__c, PortalServiceTranslatedName__c ,Portal_Application__r.Description__c, '+
	                    'Portal_Application__r.Requestable__c, Application_icon_del__c, IsSCIMIFG__c, ' +
	                    'Portal_Application__r.New_Window__c, Right__c, Portal_Application__r.Application_icon_URL__c, ' +
	                    'Portal_Application__r.Name, Portal_Application__c, My_Apps__c, Contact__c, ' +
	                    'Application_Start_URL__c,Technical_Provisioning_Status__c, Case_creation_record_Type__c, ' +
	                    'Portal_Application__r.Service_Description__c, Portal_Application__r.Service_Description_Label__c ' +
	                    'FROM Portal_Application_Right__c ' +
	                    'WHERE Contact__c =:contactId AND '+
	                    '   (Right__c = \'Access Granted\' OR Right__c = \'Access Requested\') AND ' +
	                    '    Portal_Application__r.Hide_on_Homepage__c = false ';

	//Add the clauses for further filtering
	if(refinedSearch != null ) {
		finalQuery += ' AND Application_Name__c LIKE \'%' + refinedSearch.searchText + '%\' ';
	}

	finalQuery += ' ORDER BY Right__c DESC,Portal_Application__r.Name ';

	System.debug('finalQuery: ' + finalQuery);

	List<Portal_Application_Right__c> appsGrantedList = Database.query(finalQuery);

	System.debug('appsGrantedList: ' + appsGrantedList);

	return appsGrantedList;
}


@AuraEnabled (cacheable=true)
public static List<Portal_Applications__c> getNonRequestableServicesList(String contactId){

	Contact con = [Select id from Contact where id =:contactId];

	List<Portal_Applications__c> externalLinksList = new List<Portal_Applications__c>();

	for (Portal_Applications__c pApp: [SELECT Name, Description__c, Service_Description__c, Service_Description_Label__c, Visible__c,
	                                   Requestable__c, Application_icon__c, Application_URL__c, New_Window__c, VisibleCNS__c,
	                                   ANG_Flag_Restrict_Accredited_Agent__c, ANG_Flag_Restrict_Sector__c
	                                   FROM Portal_Applications__c
	                                   WHERE Visible__c = true
	                                   AND Requestable__c = false
	                                   AND ANG_Flag_Restrict_by_Agency_Category__c = true
	                                   AND ANG_Accre_Tp__c = true]) {

		if (pApp.Name == 'Insurance Providers') {
			if (((con.Account.Sector__c == 'Travel Agent' || con.Account.Sector__c == 'Cargo Agent')
			     && con.Account.RecordTypeId == RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')) &&
			    (con.Account.Is_Branch_Abroad__c == 'Yes') &&
			    (AMS_Utils.ACTIVEAGENCYSTATUS.contains(con.Account.Status__c) || con.Account.Status__c == AMS_Utils.ACC_S2_NEWAPPLICATIONPENDING) &&
			    (con.Financial_Assessment_Contact__c || con.User_Portal_Status__c == 'Approved Admin')) {
				externalLinksList.add(pApp);
			}
		} else if (pApp.ANG_Flag_Restrict_Accredited_Agent__c && pApp.ANG_Flag_Restrict_Sector__c) {
			externalLinksList.add(pApp);
		}
	}

	return externalLinksList;
}

/*
    This method is used for CS Portal searchbar.
    @refinedSearchSerialized - is a serialized filter object sent from the LWC controller for further filtering
 */
@AuraEnabled (cacheable=true)
public static List<Portal_Application_Right__c> getUsersFavoriteServicesList(String contactId){
	
	//base query
	String finalQuery = 'Select Application_Name__c, PortalServiceTranslatedName__c ,Portal_Application__r.Description__c, '+
	                    'Portal_Application__r.Requestable__c, Application_icon_del__c, IsSCIMIFG__c, ' +
	                    'Portal_Application__r.New_Window__c, Right__c, Portal_Application__r.Application_icon_URL__c, ' +
	                    'Portal_Application__r.Name, Portal_Application__c, My_Apps__c, Contact__c, ' +
	                    'Application_Start_URL__c,Technical_Provisioning_Status__c, Case_creation_record_Type__c, ' +
	                    'Portal_Application__r.Service_Description__c, Portal_Application__r.Service_Description_Label__c ' +
	                    'FROM Portal_Application_Right__c ' +
	                    'WHERE (Contact__c = \'' + contactId + '\' AND '+
	                    '   Right__c = \'Access Granted\' AND ' +
	                    '   Portal_Application__r.Hide_on_Homepage__c = false)';


	finalQuery += ' ORDER BY Portal_Application__r.New_Window__c asc, Portal_Application__r.Name LIMIT 15';

	System.debug('finalQuery: ' + finalQuery);

	List<Portal_Application_Right__c> appsGrantedList = Database.query(finalQuery);

	System.debug('appsGrantedList: ' + appsGrantedList);

	return appsGrantedList;
}

@AuraEnabled (cacheable=true)
public static List<Portal_Application_Right__c> getFavoriteServicesList(){
	User userAux = [SELECT Id, ContactId FROM User WHERE Id = :UserInfo.getUserId()];

	String contactId = userAux.ContactId;

	List<Portal_Application_Right__c> lstPortalApplicationsRights = getUsersFavoriteServicesList(contactId);
	
	List<Portal_Applications__c> lstPortalApplications =  getNonRequestableServicesList(contactId);
	
	
	if(!lstPortalApplications.isEmpty()) {
		for(Portal_Applications__c pa : lstPortalApplications) {
			Portal_Application_Right__c par = new Portal_Application_Right__c();
			par.Portal_Application__r = pa;
			lstPortalApplicationsRights.add(par);
		}
	}

	return lstPortalApplicationsRights;
}

/*
 * Method used to retrieve the old link when redirecting the users to the old Portals
 */
@AuraEnabled
public static String goToOldPortalService(String myurl){
	return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, myurl);
}

/*
    Classes for the search filtering

 */

public class FilteringObject {

@AuraEnabled
public String searchText {get; set;}

//the rest of the filters should be here too

public FilteringObject(){
}


}


}