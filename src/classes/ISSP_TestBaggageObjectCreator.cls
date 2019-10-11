public without sharing class ISSP_TestBaggageObjectCreator {
	public static PIR_Form__c CreatePirForm(Id airlineIssuingId, String pirFileRef){

        PIR_Form__c pirForm = new PIR_Form__c();

        pirForm.Airline_issuing__c = airlineIssuingId;
        pirForm.PIR_File_Ref__c = pirFileRef;
        pirForm.Amount__c = 20;

        insert pirForm;
         
        return pirForm;  
    }

    public static Baggage_Claim__c CreateProrateRequest(Id pirFormId, Id airlineReceivingId, String airlineCode){

        Baggage_Claim__c prorateRequest = new Baggage_Claim__c();

        prorateRequest.Airline_receiving__c = airlineReceivingId;
        prorateRequest.Parent_PIR_Form__c = pirFormId;
        prorateRequest.X2_letter_Airline_Code__c = airlineCode;
        prorateRequest.Status__c = 'Proceed to payment';

        insert prorateRequest;
         
        return prorateRequest;  
    }

    public static Flight_Information__c CreateFlightInfo(Id pirFormId){

        Flight_Information__c flightInfo = new Flight_Information__c();

        flightInfo.PIR_Ref__c = pirFormId;
        flightInfo.PIR_Segment_1__c = '1';
        flightInfo.PIR_Flight_Date__c  = date.today();
        flightInfo.PIR_Percentage__c = 20;

        insert flightInfo;
         
        return flightInfo;  
    }

    public static PIR_Bag_Information__c CreateBagInfo(Id pirFormId){

        PIR_Bag_Information__c bagInfo = new PIR_Bag_Information__c();

        bagInfo.PIR_Form__c = pirFormId;
        bagInfo.Bag_Number__c = '1';

        insert bagInfo;
         
        return bagInfo;  
    }

    public static Baggage_Claim_Comment__c CreateProrateRequestComment(Id prorateRequestId){

        Baggage_Claim_Comment__c comment = new Baggage_Claim_Comment__c();

        comment.Baggage_Claim__c = prorateRequestId;
        comment.Comments__c = 'Test';

        insert comment;
         
        return comment;  
    }

    public static Account CreateAccount(String accountName, String airlineCode){

    	Id accRtId = [ SELECT Id FROM RecordType 
		WHERE SobjectType = 'Account'
		AND DeveloperName = 'IATA_Airline'][0].Id;

        Account acc = new Account();

        acc.Airline_designator__c = airlineCode;
        acc.Email_Prorate__c = 'test@gmail.com';
        acc.Name = accountName;
        acc.RecordTypeId = accRtId;

        insert acc;
         
        return acc;  
    }
}