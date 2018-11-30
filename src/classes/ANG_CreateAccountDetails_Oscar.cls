/***********************************************************
	2018-11-26. Author: Daniele Tullo
	Class to create OSCAR, from External Sources.
    Currently supported:
        - GDI Offer [INT_077] Jira issue: https://iatasfdc.atlassian.net/browse/NEWGEN-4336
***********************************************************/

global without sharing class ANG_CreateAccountDetails_Oscar {
    global static void ANG_Create_GDIOscar(Account accnt, string OfferId) {
        //Take a database snapshot
        //to rollback in case of exception or something not being created succesfully
        try{
            //DO ALL THE STUFFS HERE

            //CREATE OSCAR

            //CREATE CASE

            //Create staging area, if necessary

            //Create Opportunity

            //return message, Id of Record Created (oscar)
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT077_SuccessPayload('')), 200);
        }
        catch(exception e){
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
        }
    }

    private class INT077_SuccessPayload{
        string recordId;
        public INT077_SuccessPayload(string sId){
			this.recordId = sId;
        }
    }
}
