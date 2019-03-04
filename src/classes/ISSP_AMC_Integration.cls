/*
	Class Name: ISSP_AMC_Integration
	Related Classes:

	Copyright @Right IT Services

	Purpose: Class with logic to handle Integration Layer with ACLI (SAP) via Mulesoft

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Manuel Conde		09-01-2019   	INITIAL DEVELOPMENT
*/

public without sharing class ISSP_AMC_Integration {

    public static Integer REQUEST_TIMEOUT = 120000;

    public static final Integer STATUSOKLOWER  = 199;
    public static final Integer STATUSOKHIGHER = 300;
    public static string caseStatus = ISSP_AMC_Constants.AMC_CASE_STATUS_SUBMITTED;

    public static HttpResponse doPost(Id caseIdReceived) {
        string payload;
        HttpResponse res = new HttpResponse();
        ACLIResponse acliResp = new ACLIResponse();
        try {
            ACLIForm acliForms = applicationInfoMapping(caseIdReceived);
            //if ( acliForms.isEmpty() ) throw new customException('No ACLI Forms to process');
            if (acliForms == null)  throw new customException('No ACLI Forms to process');
            payload = JSON.serialize(acliForms);


            res = sendRequest(payload, caseIdReceived);

            System.debug('payload ' + payload);
            
        }catch(CalloutException e){
            system.debug('MC  --> ACLI doPost exception: ' + e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage()));
        }
        return res;
    }

    public static ACLIForm applicationInfoMapping(Id oscarCaseId){
        //Case oscarCase = new Case();
        //List<ACLIForm> acliFormList = new List<ACLIForm>();
        ACLIForm acliFormFields = New ACLIForm();
        //set<Id> oscarCaseSet = new set<Id>();

        /*for(Case eachCase : oscarCaseList){
            oscarCaseSet.add(eachCase.Id);
        }*/

        Participation_Online_Application__c applicationFromOscar = [SELECT ID, Case__c,
                                                                        Legal_Name__c,
                                                                        HQ_Street_address_1__c,
                                                                        HQ_City__c,
                                                                        HQ_State_Province__c,
                                                                        HQ_Country__c,
                                                                        HQ_Postal_Zip_code__c,
                                                                        HQ_VAT__c,
                                                                        HOB_Salutation__c,
                                                                        HOB_First_Name__c,
                                                                        HOB_Last_Name__c,
                                                                        HOB_Email__c,
                                                                        HOB_Phone__c,
                                                                        HOB_Title__c,
                                                                        Billing_Street_address_1__c,
                                                                        Billing_City__c,
                                                                        Billing_State_Province__c,
                                                                        Billing_Country__c,
                                                                        Billing_Postal_Zip_code__c,
                                                                        Billing_VAT__c,
                                                                        HOC_Salutation__c,
                                                                        HOC_First_Name__c,
                                                                        HOC_Last_Name__c,
                                                                        HOC_Email__c,
                                                                        HOC_Phone__c,
                                                                        HOC_Title__c,
                                                                        Name_of_Organization__c,
                                                                        Accounting_Code_Airline_Prefix_Purpose__c,
                                                                        Authorized_areas_of_operations__c,
                                                                        Baggage_Reason_For_Use_1__c,
                                                                        Baggage_Reason_For_Use_2__c,
                                                                        Baggage_Reason_For_Use_3__c,
                                                                        Baggage_Reason_For_Use_4__c,
                                                                        Baggage_Reason_For_Use_5__c,
                                                                        City_Name__c,
                                                                        Date_when_airport_has_been_operational__c,
                                                                        Does_Metropolitan_area_currently_exists__c,
                                                                        GPS_Coordinates__c,
                                                                        Has_airline_assigned_two_char_code__c,
                                                                        Has_company_assigned_numeric_code__c,
                                                                        Has_the_company_published_their_schedule__c,
                                                                        IATA_ISO_Country__r.Name,
                                                                        IATA_ISO_Country__r.ISO_Code__c,
                                                                        ICAO_Code__c,
                                                                        Is_ULD_participation_IATA_program__c,
                                                                        Location_Code_1__c,
                                                                        Location_Code_2__c,
                                                                        Location_Code__c,
                                                                        Location_Name__c,
                                                                        Off_Line_Point_Purpose__c,
                                                                        Preference_of_Code_1__c,
                                                                        Preference_of_Code_2__c,
                                                                        Preference_of_Code_3__c,
                                                                        Previously_assigned_IATA_code__c,
                                                                        Previously_assigned_numeric_code__c,
                                                                        Recommended_Loc_Identifier__c,
                                                                        State__c,
                                                                        Time_Zone__c,
                                                                        X1_other_airlines_in_the_airport__c,
                                                                        X2_other_airlines_in_the_airport__c,
                                                                        X3_other_airlines_in_the_airport__c,
                                                                        RecordType.DeveloperName,
                                                                        Submitted_By__c,
                                                                        Submitted_By__r.Name,
                                                                        Submitted_By__r.salutation,
                                                                        AOC_Scheduled_Passenger__c,
                                                                        AOC_Non_Scheduled_Passenger__c,
                                                                        AOC_Scheduled_Cargo__c,
                                                                        AOC_Non_Scheduled_Cargo__c,
                                                                        AOC_ULD__c,
                                                                        AOC_CRS__c,
                                                                        AOC_Ferry_Company__c,
                                                                        AOC_Bus_Company__c,
                                                                        AOC_Railway_Company__c,
                                                                        AAO_Domestic__c,
                                                                        AAO_International__c,
                                                                        Does_the_airline_presently_hold_a_three__c,
                                                                        Case__r.account.Accounting_Code__c,
                                                                        Case__r.account.Airline_Prefix__c,
                                                                        case__r.account.IATA_ISO_Billing_State__c,
                                                                        case__r.account.IATA_ISO_Country__r.Name,
                                                                        case__r.account.IATA_ISO_Country__r.ISO_Code__c,
                                                                        case__r.account.Iso_State__r.ISO_Code__c,
                                                                        case__r.Status,
                                                                        case__r.account.IATA_ISO_Billing_State__r.ISO_Code__c,
                                                                        case__r.Coding_Application_ID__c,
                                                                        Terms_Conditions_Agreement__c,
                                                                        Is_the_billing_contact_same_the_HOC__c
                                                                    FROM Participation_Online_Application__c
                                                                    WHERE Case__c =: oscarCaseId
        AND (RecordType.DeveloperName = 'Designator_Code' OR RecordType.DeveloperName = 'Accounting_or_Prefix_Code') AND case__r.Status =: caseStatus];

        //for(Participation_Online_Application__c applicationFromOscar :applicationFromOscarList) {
            //acliFormFields  = new ACLIForm();

            acliFormFields.CodePreferences = new List<String>();
            acliFormFields.Authorized_areas_of_operations = new List<String>();

            acliFormFields.Terms_And_Conditions_Contact_Name = applicationFromOscar.Submitted_By__r.Name;
            acliFormFields.Terms_And_Conditions_Contact_Salutation = applicationFromOscar.Submitted_By__r.salutation;
            acliFormFields.Terms_And_Conditions = applicationFromOscar.Terms_Conditions_Agreement__c;

            acliFormFields.Name_of_Organization = applicationFromOscar.Name_of_Organization__c;
            acliFormFields.Legal_Name = applicationFromOscar.Legal_Name__c;
            acliFormFields.OscarCase = applicationFromOscar.Case__c;
            acliFormFields.RecordType = applicationFromOscar.RecordType.DeveloperName;

            acliFormFields.Does_the_airline_presently_hold_a_three =  applicationFromOscar.Does_the_airline_presently_hold_a_three__c;

            acliFormFields.AOC_Scheduled_Passenger = applicationFromOscar.AOC_Scheduled_Passenger__c;
            acliFormFields.AOC_Non_Scheduled_Passenger = applicationFromOscar.AOC_Non_Scheduled_Passenger__c;
            acliFormFields.AOC_Scheduled_Cargo = applicationFromOscar.AOC_Scheduled_Cargo__c;
            acliFormFields.AOC_Non_Scheduled_Cargo = applicationFromOscar.AOC_Non_Scheduled_Cargo__c;
            acliFormFields.AOC_ULD = applicationFromOscar.AOC_ULD__c;
            acliFormFields.AOC_CRS = applicationFromOscar.AOC_CRS__c;
            acliFormFields.AOC_Ferry_Company = applicationFromOscar.AOC_Ferry_Company__c;
            acliFormFields.AOC_Bus_Company = applicationFromOscar.AOC_Bus_Company__c;
            acliFormFields.AOC_Railway_Company = applicationFromOscar.AOC_Railway_Company__c;

            if(acliFormFields.AOC_Scheduled_Passenger == true){
                acliFormFields.Type_Of_Operation = 'A';
            }
            if(acliFormFields.AOC_Non_Scheduled_Passenger == true){
                acliFormFields.Type_Of_Operation = 'B';
            }
            if(acliFormFields.AOC_Scheduled_Cargo == true){
                acliFormFields.Type_Of_Operation = 'C';
            }
            if(acliFormFields.AOC_Non_Scheduled_Cargo == true){
                acliFormFields.Type_Of_Operation = 'D';
            }
            if(acliFormFields.AOC_ULD == true){
                acliFormFields.Type_Of_Operation = 'G';
            }
            if(acliFormFields.AOC_CRS == true){
                acliFormFields.Type_Of_Operation = 'H';
            }
            if(acliFormFields.AOC_Ferry_Company == true){
                acliFormFields.Type_Of_Operation = 'F';
            }
            if(acliFormFields.AOC_Bus_Company == true){
                acliFormFields.Type_Of_Operation = 'K';
            }
            if(acliFormFields.AOC_Railway_Company == true){
                acliFormFields.Type_Of_Operation = 'E';
            }
            if(acliFormFields.AOC_Scheduled_Passenger == true && acliFormFields.AOC_Scheduled_Cargo == true){
                acliFormFields.Type_Of_Operation = 'I';
            }
            if(acliFormFields.AOC_Non_Scheduled_Passenger == true && acliFormFields.AOC_Non_Scheduled_Cargo == true){
                acliFormFields.Type_Of_Operation = 'J';
            }

            //address
            acliFormFields.HQ_Street_address_1 = applicationFromOscar.HQ_Street_address_1__c;
            acliFormFields.HQ_City = applicationFromOscar.HQ_City__c;
            acliFormFields.HQ_State_Province = applicationFromOscar.HQ_State_Province__c;
            acliFormFields.HQ_Country = applicationFromOscar.HQ_Country__c;
            acliFormFields.HQ_Postal_Zip_code = applicationFromOscar.HQ_Postal_Zip_code__c;

            acliFormFields.HQ_VAT = applicationFromOscar.HQ_VAT__c;

            acliFormFields.IS_Billing_Contact_Same_As_HOC = applicationFromOscar.Is_the_billing_contact_same_the_HOC__c;

            //contact
            acliFormFields.HOC_Salutation = applicationFromOscar.HOC_Salutation__c;
            acliFormFields.HOC_First_Name = applicationFromOscar.HOC_First_Name__c;
            acliFormFields.HOC_Last_Name = applicationFromOscar.HOC_Last_Name__c;
            acliFormFields.HOC_Title = applicationFromOscar.HOC_Title__c;
            acliFormFields.HOC_Phone = applicationFromOscar.HOC_Phone__c;
            acliFormFields.HOC_Email = applicationFromOscar.HOC_Email__c;

            //address Billing
            acliFormFields.IATA_ISO_Country_Code = applicationFromOscar.case__r.account.IATA_ISO_Country__r.ISO_Code__c;
            acliFormFields.IATA_ISO_State_Code = applicationFromOscar.case__r.account.Iso_State__r.ISO_Code__c;
            acliFormFields.IATA_ISO_Billing_State_Code = applicationFromOscar.case__r.account.IATA_ISO_Billing_State__r.ISO_Code__c;
            //acliFormFields.IATA_ISO_Country = applicationFromOscar.case__r.account.IATA_ISO_Country__r.Name;
            acliFormFields.Billing_Street_address_1 = applicationFromOscar.Billing_Street_address_1__c;
            acliFormFields.Billing_City = applicationFromOscar.Billing_City__c;
            acliFormFields.Billing_State_Province = applicationFromOscar.Billing_State_Province__c;
            acliFormFields.Billing_Country = applicationFromOscar.Billing_Country__c;
            acliFormFields.Billing_Postal_Zip_code = applicationFromOscar.Billing_Postal_Zip_code__c;

            acliFormFields.Billing_VAT = applicationFromOscar.Billing_VAT__c;

            //contact
            acliFormFields.HOB_Salutation = applicationFromOscar.HOB_Salutation__c;
            acliFormFields.HOB_First_Name = applicationFromOscar.HOB_First_Name__c;
            acliFormFields.HOB_Last_Name = applicationFromOscar.HOB_Last_Name__c;
            acliFormFields.HOB_Title = applicationFromOscar.HOB_Title__c;
            acliFormFields.HOB_Phone = applicationFromOscar.HOB_Phone__c;
            acliFormFields.HOB_Email = applicationFromOscar.HOB_Email__c;

            acliFormFields.Accounting_Code_Airline_Prefix_Purpose = applicationFromOscar.Accounting_Code_Airline_Prefix_Purpose__c;
            if(!String.isBlank(applicationFromOscar.Authorized_areas_of_operations__c)){
                for(string s : applicationFromOscar.Authorized_areas_of_operations__c.split(',')){
                    acliFormFields.Authorized_areas_of_operations.add(s.trim());
                }
            }

            acliFormFields.Has_airline_assigned_two_char_code = applicationFromOscar.Has_airline_assigned_two_char_code__c;

            /*acliFormFields.Preference_of_Code_1 = applicationFromOscar.Preference_of_Code_1__c;
            acliFormFields.Preference_of_Code_2 = applicationFromOscar.Preference_of_Code_2__c;
            acliFormFields.Preference_of_Code_3 = applicationFromOscar.Preference_of_Code_3__c;*/
            acliFormFields.Previously_assigned_IATA_code = applicationFromOscar.Previously_assigned_IATA_code__c;

            /*acliFormFields.Authorized_Domestic = applicationFromOscar.AAO_Domestic__c;
            acliFormFields.Authorized_International = applicationFromOscar.AAO_International__c;*/
            acliFormFields.Accounting_Code = applicationFromOscar.Case__r.account.Accounting_Code__c;
            acliFormFields.Prefix_Code = applicationFromOscar.Case__r.account.Airline_Prefix__c;

            acliFormFields.CodePreferences.add(applicationFromOscar.Preference_of_Code_1__c);
            acliFormFields.CodePreferences.add(applicationFromOscar.Preference_of_Code_2__c);
            acliFormFields.CodePreferences.add(applicationFromOscar.Preference_of_Code_3__c);
            acliFormFields.ICAO_Code = applicationFromOscar.ICAO_Code__c;

            /*acliFormFields.Baggage_Reason_For_Use_1 = applicationFromOscar.Baggage_Reason_For_Use_1__c;
            acliFormFields.Baggage_Reason_For_Use_2 = applicationFromOscar.Baggage_Reason_For_Use_2__c;
            acliFormFields.Baggage_Reason_For_Use_3 = applicationFromOscar.Baggage_Reason_For_Use_3__c;
            acliFormFields.Baggage_Reason_For_Use_4 = applicationFromOscar.Baggage_Reason_For_Use_4__c;
            acliFormFields.Baggage_Reason_For_Use_5 = applicationFromOscar.Baggage_Reason_For_Use_5__c;
            acliFormFields.City_Name = applicationFromOscar.City_Name__c;
            acliFormFields.Date_when_airport_has_been_operational =
                    string.valueOf(applicationFromOscar.Date_when_airport_has_been_operational__c);
            acliFormFields.Does_Metropolitan_area_currently_exists =
                    applicationFromOscar.Does_Metropolitan_area_currently_exists__c;
            acliFormFields.GPS_Coordinates = applicationFromOscar.GPS_Coordinates__c;*/


            /*acliFormFields.Has_company_assigned_numeric_code = applicationFromOscar.Has_company_assigned_numeric_code__c;
            acliFormFields.Has_the_company_published_their_schedule = applicationFromOscar.Has_the_company_published_their_schedule__c;
            acliFormFields.Is_ULD_participation_IATA_program = applicationFromOscar.Is_ULD_participation_IATA_program__c;*/
            /*acliFormFields.Location_Code_1 = applicationFromOscar.Location_Code_1__c;
            acliFormFields.Location_Code_2 = applicationFromOscar.Location_Code_2__c;
            acliFormFields.Location_Code = applicationFromOscar.Location_Code__c;
            acliFormFields.Location_Name = applicationFromOscar.Location_Name__c;
            acliFormFields.Off_Line_Point_Purpose = applicationFromOscar.Off_Line_Point_Purpose__c;*/

            /*acliFormFields.HOB_Name = applicationFromOscar.HOB_First_Name__c + ' ' + applicationFromOscar.HOB_Last_Name__c;*/

            /*acliFormFields.Previously_assigned_numeric_code = applicationFromOscar.Previously_assigned_numeric_code__c;
            acliFormFields.Recommended_Loc_Identifier = applicationFromOscar.Recommended_Loc_Identifier__c;
            acliFormFields.State = applicationFromOscar.State__c;
            acliFormFields.Time_Zone = applicationFromOscar.Time_Zone__c;
            acliFormFields.X1_other_airlines_in_the_airport = applicationFromOscar.X1_other_airlines_in_the_airport__c;
            acliFormFields.X2_other_airlines_in_the_airport = applicationFromOscar.X2_other_airlines_in_the_airport__c;
            acliFormFields.X3_other_airlines_in_the_airport = applicationFromOscar.X3_other_airlines_in_the_airport__c;*/

            /*acliFormFields.HOC_Name = applicationFromOscar.HOC_First_Name__c + ' ' + applicationFromOscar.HOC_Last_Name__c;*/


            //acliFormList.add(acliFormFields);
        //}

        return acliFormFields;
    }

    public class ACLIForm{
        public string   RecordType                                        {get; set;}
        public string   Accounting_Code_Airline_Prefix_Purpose            {get; set;}
        public List<string>   Authorized_areas_of_operations              {get; set;}
        public string   Has_airline_assigned_two_char_code                {get; set;}
        /*public string   Preference_of_Code_1                              {get; set;}
        public string   Preference_of_Code_2                              {get; set;}
        public string   Preference_of_Code_3                              {get; set;}*/
        public string   Previously_assigned_IATA_code                     {get; set;}
        public string   Name_of_Organization                              {get; set;}
        public string   Legal_Name                                        {get; set;}
        public List<String>   CodePreferences                             {get; set;}
        public string   HQ_VAT                                            {get; set;}
        public string   HQ_City                                           {get; set;}
        public string   HQ_Country                                        {get; set;}
        public string   HQ_Postal_Zip_code                                {get; set;}
        public string   HQ_State_Province                                 {get; set;}
        public string   HQ_Street_address_1                               {get; set;}
        public string   Billing_City                                      {get; set;}
        public string   Billing_Country                                   {get; set;}
        public string   Billing_Postal_Zip_code                           {get; set;}
        public string   Billing_State_Province                            {get; set;}
        public string   Billing_Street_address_1                          {get; set;}
        public string   HOB_Salutation                                    {get; set;}
        //public string   HOB_Name                                          {get; set;}
        public string   HOB_First_Name                                    {get; set;}
        public string   HOB_Last_Name                                     {get; set;}
        public string   HOB_Email                                         {get; set;}
        public string   HOB_Phone                                         {get; set;}
        public string   HOB_Title                                         {get; set;}
        public string   HOC_Salutation                                    {get; set;}
        //public string   HOC_Name                                          {get; set;}
        public string   HOC_First_Name                                    {get; set;}
        public string   HOC_Last_Name                                     {get; set;}
        public string   HOC_Email                                         {get; set;}
        public string   HOC_Phone                                         {get; set;}
        public string   HOC_Title                                         {get; set;}
        public string   Billing_VAT                                       {get; set;}
        public string   OscarCase                                         {get; set;}
        public string   Terms_And_Conditions_Contact_Name                 {get; set;}
        public string   Terms_And_Conditions_Contact_Salutation           {get; set;}
        public Boolean  Terms_And_Conditions                              {get; set;}
        public string   Type_Of_Operation                                 {get; set;}
        public Boolean  AOC_Scheduled_Passenger                           {get; set;}
        public Boolean  AOC_Non_Scheduled_Passenger                       {get; set;}
        public Boolean  AOC_Scheduled_Cargo                               {get; set;}
        public Boolean  AOC_Non_Scheduled_Cargo                           {get; set;}
        public Boolean  AOC_ULD                                           {get; set;}
        public Boolean  AOC_CRS                                           {get; set;}
        public Boolean  AOC_Ferry_Company                                 {get; set;}
        public Boolean  AOC_Bus_Company                                   {get; set;}
        public Boolean  AOC_Railway_Company                               {get; set;}
        //public Boolean  Authorized_Domestic                               {get; set;}
        //public Boolean  Authorized_International                          {get; set;}
        public String   Accounting_Code                                   {get; set;}
        public String   Prefix_Code                                       {get; set;}
        public Boolean  IS_Billing_Contact_Same_As_HOC                    {get; set;}
        public string   IATA_ISO_Country_Code                             {get; set;}
        //public string   IATA_ISO_Country                             {get; set;}
        public string   IATA_ISO_State_Code                               {get; set;}
        public string   IATA_ISO_Billing_State_Code                       {get; set;}

        public string   ICAO_Code                                         {get; set;}
        public String Does_the_airline_presently_hold_a_three               {get;set;}

        /*public Boolean  Baggage_Reason_For_Use_1                          {get; set;}
        public Boolean  Baggage_Reason_For_Use_2                          {get; set;}
        public Boolean  Baggage_Reason_For_Use_3                          {get; set;}
        public Boolean  Baggage_Reason_For_Use_4                          {get; set;}
        public Boolean  Baggage_Reason_For_Use_5                          {get; set;}
        public string   City_Name                                         {get; set;}
        public string   Date_when_airport_has_been_operational            {get; set;}
        public string   Does_Metropolitan_area_currently_exists           {get; set;}
        public string   Does_the_airline_presently_hold_a_three           {get; set;}
        public string   GPS_Coordinates                                   {get; set;}
        public string   Has_company_assigned_numeric_code                 {get; set;}
        public string   Has_the_company_published_their_schedule          {get; set;}
        public string   Is_ULD_participation_IATA_program                 {get; set;}
        public string   Location_Code_1                                   {get; set;}
        public string   Location_Code_2                                   {get; set;}
        public string   Location_Code                                     {get; set;}
        public string   Location_Name                                     {get; set;}
        public string   Off_Line_Point_Purpose                            {get; set;}
        public String   Previously_assigned_numeric_code                  {get; set;}
        public string   Recommended_Loc_Identifier                        {get; set;}
        public string   State                                             {get; set;}
        public string   Time_Zone                                         {get; set;}
        public string   X1_other_airlines_in_the_airport                  {get; set;}
        public string   X2_other_airlines_in_the_airport                  {get; set;}
        public string   X3_other_airlines_in_the_airport                  {get; set;}*/





        //MuleSoft requirements?
        /*public string caller_id {get; set;} //Max Mule
        public string opened_by {get; set;} //Max Mule
        public string assignment_group {get; set;}  //Mulesoft Support
        */

    }

    /*public class responseForm{
        public String status            {get; set;}
        public String requestId         {get; set;}
        public String caseNumber        {get; set;}
    }*/

    public class customException extends Exception {}

    public class ACLIResponse{

        public Boolean isSuccess {get; set;}
        public String errorCode {get; set;}
        public String errorDescription {get; set;}

        public String status            {get; set;}
        public String requestId         {get; set;}
        //public String caseNumber        {get; set;}
        public String OscarCase        {get; set;}
        //public String detail        {get; set;}
        public List<Error> errors {get;set;}

    }

    public class Error{
        public String detail        {get; set;}
    }

    public static HttpResponse sendRequest(string theBody, Id caseIdReceived){

        AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
        String username = amcConfiguration.username__c;
        String password = amcConfiguration.password__c;
        String endpoint = amcConfiguration.endpoint__c;

        HttpRequest req = new HttpRequest();
        req.setHeader('Content-Type', 'application/json');

        //String username = '9b5e2abd65ee4c8e9bff0e97bd8c4e16';
        //String password = '8ac07dac22564502AB51BfBF6f24D217';

        Blob headerValue = Blob.valueOf(username + ':' + password);
        String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        System.debug('FILIPA:' + authorizationHeader);


        //req.setHeader('Accept', 'application/json');
        req.setMethod('POST');
        req.setTimeout(ISSP_AMC_Integration.REQUEST_TIMEOUT);
        //req.setEndpoint('callout:ServiceNow_Login/api/now/table/incident');
        //req.setEndpoint('https://apisbx.iata.org/acli-coding/requests');
        req.setEndpoint(endpoint);
        req.setBody(theBody);

        Http http = new Http();
        HTTPResponse res;

        ACLIResponse acliResp = new ACLIResponse();
        //acliResp.errors = new List<HTTPResponse>();
        //System.debug('FILI ' + acliResp.errors.size());


        try{
            //if(!Test.isRunningTest()){
                res = http.send(req);
            /*}
            else{
                res = new HttpResponse();
            }*/

            system.debug('MC  --> ACLI Response: ' + res);
            system.debug('MC  --> ACLI Response body: ' + res.getBody());
            system.debug('MC  --> ACLI Response status: ' + res.getStatusCode());
                acliResp = (ACLIResponse)System.JSON.deserialize(res.getBody(), ACLIResponse.class);
            if(res.getStatusCode() == 201){
                //system.debug('FILLLLI ' + acliResp);
                //String status = acliResp.Status

                update new Case(Id = caseIdReceived, Coding_Application_ID__c = acliResp.requestId);

            }else if(res.getStatusCode() == 400){
                //String status = errors[0].Status;
                String detail = acliResp.errors[0].detail;
                //System.debug('FILIPA MM ' + detail);
                //system.debug('FILLLLI ' + acliResp);
            }
            if(Test.isRunningTest()){
                CalloutException e = (CalloutException)CalloutException.class.newInstance();
                e.setMessage('Unauthorized endpoint, please check Setup->Security->Remote site settings.');
                throw e;
            }

        }catch(CalloutException e){
            //No body found in HTTP response
            system.debug('MC  --> ACLI exception: ' + e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage()));
            ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();
            log.Web_Service__c = req.getEndpoint(); //'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
            try{
                log.Input_Description__c = 'body:' + res.getBody();
            }catch(exception e1){}
            log.Method__c = 'POST';
            log.Web_Service__c = String.valueOf(req);
            log.Error_Code__c = 'Exception sending request';
            log.Error_Message__c = e.getStackTraceString() + ' Cause:' + String.valueOf(e.getMessage());
            log.Success__c = false;
            insert log;

            //return;
        }

        ISSP_Web_Service_Log__c log = new ISSP_Web_Service_Log__c();


        //log.Agency_Applied_Change_code__c = changeCodeId;
        log.Web_Service__c = req.getEndpoint(); //'callout:'+namedCredential+endPointCredential+body+'?client_id='+clientId+'&client_secret='+clientSecret;
        log.Input_Description__c= 'body:'+res.getBody();
        log.Method__c = 'POST';
        //log.Web_Service__c = String.valueOf(req);

        try{
            log.Response__c = res.getBody();
        }catch(exception e){}

        log.Error_Code__c = String.valueOf(res.getStatusCode());
        log.Error_Message__c = res.getStatus();


        if((res.getStatusCode() > ISSP_AMC_Integration.STATUSOKLOWER && res.getStatusCode() < ISSP_AMC_Integration.STATUSOKHIGHER )) log.Success__c = true;
        else log.Success__c = false;

        insert log;

        return res;
    }
}