global class ISSP_AMC_Invocable {
    
    public static boolean isULD = false;
    public static boolean isFBR = false;
    public static boolean isCRS = false;
    
    
    @InvocableMethod(label='Create configuration for ACLI Process' description='Create configuration')
    public static void invokeACLICustomImpl(List<ID> orchestrator) {
        
        if(orchestrator != null && !orchestrator.isEmpty()){   
            System.debug(orchestrator[0]);
                 
            AMC_Configuration__c amcConfiguration = AMC_Configuration__c.getInstance();
            ID recordTypeId = Schema.SObjectType.IATA_Process_Orchestrator__c.RecordTypeInfosByName.get(amcConfiguration.Orchestrator_Step_RecordType__c).RecordTypeId;
            
            IATA_Process_Orchestrator__c theParent = [select id, process_name__c, associated_case__c from IATA_Process_Orchestrator__c where id =:orchestrator[0]];
    
            Case theCase = [select id, subject from case where id = :theParent.associated_case__c ];
            try{
                ISSP_AMC_Invocable.getFormData(theCase.id);
            }catch(Exception err){}
            
            List<IATA_Process_Orchestrator__c> theSteps = new List<IATA_Process_Orchestrator__c>();
            
            
            List<String> stageList = new List<String>();
            stageList.add('STAGE A');
            stageList.add('STAGE B');
            stageList.add('STAGE C');
            stageList.add('STAGE D');
            stageList.add('STAGE E');
            stageList.add('STAGE F');
            
            for(String stage : stageList){
                IATA_Process_Orchestrator__c sp = new IATA_Process_Orchestrator__c();
                sp.process_step_stage__c = stage;
                sp.recordTypeId=recordTypeId;
                sp.IATA_Orchestrator_Process__c = theParent.id;     
                           
                if(stage.equals('STAGE A')){
                    sp.Process_Step_Name__c = 'Perform Sanity Check';
                    insert sp;
                    
                    List<String> stageActionList = new List<String>();
                    
                    if(ISSP_AMC_Invocable.isULD){
                        stageActionList.add('Application Form');
                        stageActionList.add('IATA Strategic Partnership Participation');
                        stageActionList.add('Certificate of Incorporation or Registration');
                        stageActionList.add('Breakdown of Shareholders with Percentages');
                    }
                    else if(ISSP_AMC_Invocable.isFBR){ 
                        stageActionList.add('Application Form');
                        stageActionList.add('Valid authorization issued by a government body to provide transportation services');
                        stageActionList.add('Scheduled Operations Published');                       
                        stageActionList.add('Intermodal Traffic Agreement with an airline holding a valid IATA Code');
                        stageActionList.add('Certificate of Incorporation or Registration');
                        stageActionList.add('Breakdown of Shareholders with Percentages');                    
                    }
                    else if(ISSP_AMC_Invocable.isCRS){  
                        stageActionList.add('Application Form');
                        stageActionList.add('Letter from an airline holding a valid IATA Code that the CRS is providing services to them');
                        stageActionList.add('Certificate of Incorporation or Registration');
                        stageActionList.add('Breakdown of Shareholders with Percentages');                    
                    }
                    else{
                    
                        stageActionList.add('Application Form');
                        stageActionList.add('AOC');
                        stageActionList.add('Scheduled Airlines');
                        stageActionList.add('Non-Scheduled Airlines');
                        stageActionList.add('Certificate of Incorporation or Registration');
                        stageActionList.add('Breakdown of Shareholders with Percentages');                    
                    }
                    
                    List<IATA_Process_Orchestrator_Step_Action__c> actions = new List<IATA_Process_Orchestrator_Step_Action__c>();      
                    for(String ac : stageActionList){
                        IATA_Process_Orchestrator_Step_Action__c anAction = new IATA_Process_Orchestrator_Step_Action__c();
                        anAction.Action_Name__c = ac;
                        anAction.Associated_Case__c = theCase.id;
                        anAction.IATA_Process_Orchestrator__c = sp.Id;
                        actions.add(anAction);                        
                    }
                    
                    if(!actions.isEmpty()) insert actions;
                   
                }
                
                if(stage.equals('STAGE B')){
                    sp.Process_Step_Name__c = 'Additional Confirmation';
                    insert sp;
                    
                    List<String> stageActionList = new List<String>();
                    
                    stageActionList.add('Corporate Compliance Clearance');
                    stageActionList.add('Airline Distribution Standards');
                    stageActionList.add('Legal Department');

                    
                    List<IATA_Process_Orchestrator_Step_Action__c> actions = new List<IATA_Process_Orchestrator_Step_Action__c>();      
                    for(String ac : stageActionList){
                        IATA_Process_Orchestrator_Step_Action__c anAction = new IATA_Process_Orchestrator_Step_Action__c();
                        anAction.Action_Name__c = ac;
                        anAction.Associated_Case__c = theCase.id;
                        anAction.IATA_Process_Orchestrator__c = sp.Id;
                        actions.add(anAction);                        
                    }
                    
                    if(!actions.isEmpty()) insert actions;


                   
                }                
                
                             

                if(stage.equals('STAGE C')){
                    sp.Process_Step_Name__c = 'Coding Fee (With the option of not Applicable)';
                    insert sp;
                    
                    List<String> stageActionList = new List<String>();                    
                    stageActionList.add('Request Billing Document');
                    stageActionList.add('Billing Document sent to the customer');
                    stageActionList.add('Confirmation of Payment Received');

                    
                    List<IATA_Process_Orchestrator_Step_Action__c> actions = new List<IATA_Process_Orchestrator_Step_Action__c>();      
                    for(String ac : stageActionList){
                        IATA_Process_Orchestrator_Step_Action__c anAction = new IATA_Process_Orchestrator_Step_Action__c();
                        anAction.Action_Name__c = ac;
                        anAction.Associated_Case__c = theCase.id;
                        anAction.IATA_Process_Orchestrator__c = sp.Id;
                        actions.add(anAction);                        
                    }
                    
                    if(!actions.isEmpty()) insert actions;
                   
                } 

                if(stage.equals('STAGE E')){
                    sp.Process_Step_Name__c = 'Finalization of Application';
                    insert sp;
                    
                    List<String> stageActionList = new List<String>();                    
                    stageActionList.add('Assignment of the code');
                    stageActionList.add('Assignment Letter Sent');

                    
                    List<IATA_Process_Orchestrator_Step_Action__c> actions = new List<IATA_Process_Orchestrator_Step_Action__c>();      
                    for(String ac : stageActionList){
                        IATA_Process_Orchestrator_Step_Action__c anAction = new IATA_Process_Orchestrator_Step_Action__c();
                        anAction.Action_Name__c = ac;
                        anAction.Associated_Case__c = theCase.id;
                        anAction.IATA_Process_Orchestrator__c = sp.Id;
                        actions.add(anAction);                        
                    }
                    
                    if(!actions.isEmpty()) insert actions;
                   
                }                 

                if(stage.equals('STAGE D')){
                    sp.Process_Step_Name__c = 'Request for approval';
                    insert sp;
                    
                    List<String> stageActionList = new List<String>();                    
                    stageActionList.add('Request for approval');

                    
                    List<IATA_Process_Orchestrator_Step_Action__c> actions = new List<IATA_Process_Orchestrator_Step_Action__c>();      
                    for(String ac : stageActionList){
                        IATA_Process_Orchestrator_Step_Action__c anAction = new IATA_Process_Orchestrator_Step_Action__c();
                        anAction.Action_Name__c = ac;
                        anAction.Associated_Case__c = theCase.id;
                        anAction.IATA_Process_Orchestrator__c = sp.Id;
                        actions.add(anAction);                        
                    }
                    
                    if(!actions.isEmpty()) insert actions;
                   
                }            
                if(stage.equals('STAGE F')){
                    sp.Process_Step_Name__c = 'SIS Registration';
                    insert sp;
                    
                    List<String> stageActionList = new List<String>();                    
                    stageActionList.add('Internal Case for AP (Completed)');

                    
                    List<IATA_Process_Orchestrator_Step_Action__c> actions = new List<IATA_Process_Orchestrator_Step_Action__c>();      
                    for(String ac : stageActionList){
                        IATA_Process_Orchestrator_Step_Action__c anAction = new IATA_Process_Orchestrator_Step_Action__c();
                        anAction.Action_Name__c = ac;
                        anAction.Associated_Case__c = theCase.id;
                        anAction.IATA_Process_Orchestrator__c = sp.Id;
                        actions.add(anAction);                        
                    }
                    
                    if(!actions.isEmpty()) insert actions;
                   
                }                                        
            }
      
            
            System.debug('Test');
            System.debug(orchestrator);
        }else{
            System.debug('No valid parameters passed');
        }             
       //return returnList; 
    }

    public static void getFormData(ID caseId){
    
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
                                                                        Case__r.account.Accounting_Code__c,
                                                                        Case__r.account.Airline_Prefix__c,
                                                                        Terms_Conditions_Agreement__c,
                                                                        Is_the_billing_contact_same_the_HOC__c
                                                                    FROM Participation_Online_Application__c
                                                                    WHERE Case__c = :caseId];    
    
            if(applicationFromOscar.AOC_ULD__c== true){
                ISSP_AMC_Invocable.isULD = true;
            }     
            if(applicationFromOscar.AOC_CRS__c== true){
                ISSP_AMC_Invocable.isCRS = true;
            }               

            if(applicationFromOscar.AOC_Ferry_Company__c || applicationFromOscar.AOC_Bus_Company__c || applicationFromOscar.AOC_Railway_Company__c){
                ISSP_AMC_Invocable.isFBR = true;
            }       
    }
}