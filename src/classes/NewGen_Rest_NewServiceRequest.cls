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
            insert new Portal_Application_Right__c(Contact__c = data.contactId,Portal_Application__c = data.portalId,Right__c = appRight);
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