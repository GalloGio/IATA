/**
 * REST API for NewGen Mobile APP - Rest class to deal with new service request done by the user from the NewGen mobile App
 * @author André Casaleiro
 * @since 30/01/2018
 */

 @RestResource(urlMapping='/newgenapp/v1/newServiceRequest/*')
 global class NewGen_Rest_NewServiceRequest {

    @HttpPost
    global static String SendNewServiceRequest(){
        ServiceRequestJson data = (ServiceRequestJson) JSON.deserialize(
            RestContext.request.requestBody.toString(),
            ServiceRequestJson.class
            );

        String appRight = 'Access Requested';

        System.debug('DATA OF PORTAL :' + data);
        try{
            List <Portal_Application_Right__c> portalAppRight = new List <Portal_Application_Right__c>([SELECT    Id 
                                                                                                        FROM      Portal_Application_Right__c
                                                                                                        WHERE     Contact__c =: data.contactId
                                                                                                        AND       Portal_Application__c =: data.portalId]);
            Id portalAppRightId = null;
            if(portalAppRight != null && portalAppRight.size() == 1){
                portalAppRightId = portalAppRight[0].Id;
            }

            upsert new Portal_Application_Right__c(Id = portalAppRightId, Contact__c = data.contactId,Portal_Application__c = data.portalId,Right__c = appRight);
        } 
        catch(exception e){
            System.Debug('ERROR : ' + e);
        }


        return 'SentServiceRequest';
    }

    global class ServiceRequestJson{
        global String portalId;
        global String contactId;
    }

 }