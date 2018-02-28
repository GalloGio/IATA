/**
 * REST API for NewGen Mobile APP - Accept Service Terms and Conditons
 * @author André Casaleiro
 * @since 31/01/2018
 */

 @RestResource(urlMapping='/newgenapp/v1/toggleServiceFavouriteField/*')
 global class NewGen_Rest_ToggleFavouriteService {
	@HttpPost
 	global static String ToggleServiceFavouriteField(){
 		ServiceRequestJson data = (ServiceRequestJson) JSON.deserialize(
 			RestContext.request.requestBody.toString(),
 			ServiceRequestJson.class
 			);

 		Portal_Application_Right__c appr = [SELECT Id, Favourite_Service__c
 		FROM Portal_Application_Right__c
 		WHERE Contact__c = :data.contactId AND Portal_Application__c =:data.portalId
 		LIMIT 1];

 		Boolean isFavourite = appr.Favourite_Service__c ? False:True;

 		System.debug('DATA OF PORTAL :' + data);
 		System.debug('DATA OF APP :' + appr);
 		try{
 			appr.Favourite_Service__c = isFavourite;
 			update appr;
 		} 
 		catch(exception e){
 			System.Debug('ERROR : ' + e);
 		}

 		return 'FavouriteToggled';
 	}

 	global class ServiceRequestJson{
 		global String portalId;
 		global String contactId;
 	}
}