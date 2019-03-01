/*
    !!!!   USED FOR IATA ODE GENERATION  !!!! 
    
    This class is in charge of generatin and apply new IATA Code to dedicated Agency
    v0.1 8/20/2015
        Workaround:
        
        1 look for Range matching agency criteria
            - country 
            - cass / passenger
        2 create a list of possible prefix based on this range
        
        3 select first selectable item 
        
        
    v1.0 upgrading to custom object with dedicated lookup to segment/countries/States.
    Use of program to define usable ranges
    no use of pax/cargo cass any more. Program should define the rules
    
    
    v.2.0: 7th March 2016: Addition of ProgramCode__c into Code_Range__c and removal of Program__c
    This update changes the master-detail linking between Code Range and Segment (AMS) of Code_Range__c.Program__c into 
    a lookup field. It also modifies the code logic a little bit, so that instead of utilizing the Program__c ID linking
    to determine which programs are available for the Agency (based on its type), the ProgramCode__c field will be used
    instead.
    
    
    AMS_Default_State__c
    AMS_Deplicate_Prevention_Lock__c
    RangeNamingConventionTrigger
    
*/
global class AmsIataCodeGenerator{

    public static ANG_OscarProcessHelper.EntityUpdater generatedAgencyIATACode(String accountId, String onlineAccreditationId){

            Account theAccount = [SELECT Name, IATACode__c, Company_Type__c, Short_Name__c, TradeName__c, License_Number__c, VAT_Number__c, GDS__c, Operation__c,
                    BillingCountry, BillingStreet, BillingPostalCode, BillingState, BillingCity, IATA_ISO_Country__c, Iso_State__c, ShippingCountry,
                    ShippingStreet, ShippingPostalCode, ShippingState, ShippingCity, Email__c, Website, Phone, Fax, In_a_Airport__c, Abbreviated_name__c, Abbreviated_address__c,
                    Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                    ,IATA_ISO_Billing_State__c, IATA_ISO_Shipping_Country__c, IATA_ISO_Shipping_Country__r.Name, IATA_ISO_Shipping_State__c, IATA_ISO_Shipping_State__r.Name, ISO_State__r.Name,
                    Link_agent_name__c, ANG_Accreditation_Model__c, IATA_ISO_Country__r.CurrencyIsoCode, 
                    (SELECT Id FROM RHC_Informations__r), Is_PCI_compliant__c,Link_agent_code__c, Sector__c, Category__c, Check_Digit__c, RecordTypeId,Due_Diligence_Status__c,CNS_Agency__c
                    FROM Account
                    WHERE Id =:accountId FOR UPDATE];

            AMS_Pax_Accreditation_Form__c theAccreditation = [SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                    ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                    Billing_State__c, Branch_Office_City__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                    Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                    Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c
                    ,Shipping_ISO_Country__c,Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, Link_agent_name__c, IATA_ISO_State__r.Valid_for_Address__c,
                    Link_agent_name__r.Link_agent_code__c, Link_agent_name__r.IATACode__c,Chk_Dgt__c,SAAM_Case__r.Account.Top_Parent__c, SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c,
                    Branch_Office_Country__c, Branch_Office_Country__r.AMS_Default_State__c, SAAM_Case__r.Account.Top_Parent__r.Check_Digit__c, SAAM_Case__r.Account.Top_Parent__r.N_Code__c, SAAM_Case__r.Account.Top_Parent__r.C_Code__c, 
                    SAAM_Case__r.Account.Top_Parent__r.A_Code__c, SAAM_Case__r.Account.Top_Parent__r.IATACode__c, ISO_country__c, N_Code__c, A_Code__c, C_Code__c,
                    SAAM_Case__r.OSCAR__r.Process__c, ANG_IsNewGenAgency__c, SAAM_Case__r.OSCAR__r.STEP6__c,Branch_Office_Country__r.Due_diligence_mandatory__c,HO_Account__c
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE Id = :onlineAccreditationId FOR UPDATE];

            return generatedAgencyIATACode(theAccount,theAccreditation,null);
            
    }

    public static ANG_OscarProcessHelper.EntityUpdater generatedAgencyIATACode(Account theAccount, AMS_Pax_Accreditation_Form__c theAccreditation, ANG_OscarProcessHelper.EntityUpdater updaterObj ){

        if(updaterObj == null)
            updaterObj = new ANG_OscarProcessHelper.EntityUpdater();

        StringBuilder sb = new StringBuilder();
        Set<String> allowedProgramCodes = new Set<String>();
        allowedProgramCodes.add('A');
        allowedProgramCodes.add('C');
        allowedProgramCodes.add('P');
        allowedProgramCodes.add('R');
        allowedProgramCodes.add('Q');
        allowedProgramCodes.add('I');
        allowedProgramCodes.add('K');
        allowedProgramCodes.add('T');
        allowedProgramCodes.add('M');
        allowedProgramCodes.add('G');
        allowedProgramCodes.add('X');
        allowedProgramCodes.add('D');
        allowedProgramCodes.add('L');
        
        
        // This means handling these program codes as if they were Cargo agencies,
        // which means having cass number included in the IATACode field
        Set<String> longCodePrograms = new Set<String>();
        longCodePrograms.add('C-Cargo Agent');
        longCodePrograms.add('R-Cargo Agent');
        longCodePrograms.add('Q-Cargo Agent');
        //longCodePrograms.add('I-Cargo Agent'); -- This has been removed to be handled differently using importAgentsCodePrograms
        longCodePrograms.add('G-Cargo Agent');
        
        Set<String> importAgentsCodePrograms = new Set<String>(); // new map to handle import agents
        importAgentsCodePrograms.add('I-Cargo Agent');

        Map<String, String> programCategoryMap = AmsIataCodeGenerator.constructProgramCategoryMap();
        Map<String, String> programSectorMap = AmsIataCodeGenerator.constructProgramSectorMap();
        
        
        Boolean isImportAgentWithLink = false;
        
        try
        {

            //Account theAccount = [select Id, Link_agent_code__c, Sector__c, Category__c, Location_Class__c, Check_Digit__c, IATA_ISO_Country__c, RecordTypeId, IATACode__c, CASS_Number__c,  Iso_State__c from Account where Id = :accountId FOR UPDATE];
            
            //AMS_Pax_Accreditation_Form__c theAccreditation = [select Id, Link_agent_name__c, Link_agent_name__r.Link_agent_code__c, Link_agent_name__r.IATACode__c, Chk_Dgt__c, SAAM_Case__r.Account.Top_Parent__c, SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c, Branch_Office_Country__c, SAAM_Case__r.Account.Top_Parent__r.Check_Digit__c, SAAM_Case__r.Account.Top_Parent__r.N_Code__c, SAAM_Case__r.Account.Top_Parent__r.C_Code__c, SAAM_Case__r.Account.Top_Parent__r.A_Code__c, SAAM_Case__r.Account.Top_Parent__r.IATACode__c, IATA_ISO_State__c, ISO_country__c, CASS_Number__c, Location_Class__c, IATACode__c, N_Code__c, A_Code__c, C_Code__c, SAAM_Case__r.OSCAR__r.Process__c, ANG_IsNewGenAgency__c, SAAM_Case__r.OSCAR__r.STEP6__c from AMS_Pax_Accreditation_Form__c where Id = :onlineAccreditationId FOR UPDATE];
            
            if(theAccount.CNS_Agency__c == false && theAccreditation.SAAM_Case__r.OSCAR__r != null && theAccreditation.SAAM_Case__r.OSCAR__r.STEP6__c != AMS_Utils.PASSED && (theAccreditation.SAAM_Case__r.OSCAR__r.Process__c != 'NEW.MSO.1.0' && theAccreditation.SAAM_Case__r.OSCAR__r.Process__c != 'NEW.GSA.1.0' && theAccreditation.SAAM_Case__r.OSCAR__r.Process__c != 'NEW.AHA.1.0')){

                System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] IATA Code Generation is only allowed after Sanity Check step be passed');

                updaterObj.isFaulty=true;
                updaterObj.errorMessage = 'IATA Code Generation is only allowed after Sanity Check step be passed.';

                return updaterObj;
            }

            isImportAgentWithLink = theAccreditation.Link_agent_name__c != null && importAgentsCodePrograms.contains(theAccreditation.Location_Class__c + '-' + theAccount.Sector__c) ? true : false;

            System.debug('[generatedAgencyIATACode] theAccount is ' + theAccount);
            System.debug('[generatedAgencyIATACode] theAccreditation is ' + theAccreditation);
            System.debug('[generatedAgencyIATACode] isImportAgentWithLink flag set to ' + isImportAgentWithLink);

            /*** AMSU-173 ***/
            Boolean isGSA = theAccreditation.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSA || theAccreditation.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSA_BSP;
            if(AMS_Utils.CLASS_REQ_CASS_NUMBER.contains(theAccreditation.Location_Class__c) && !isGSA && theAccreditation.CASS_Number__c == null) { /*** AMSU-173 ***/
                System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] C, I, R, Q and G Location Types must have a CASS number defined before generating the IATA code.');

                updaterObj.isFaulty=true;
                updaterObj.errorMessage = 'C, I, R, Q and G Location Types must have a CASS number defined before generating the IATA code.';

                return updaterObj;
            }

            if(theAccreditation.IATACode__c != null || theAccount.IATACode__c != null)
            {
                System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] This account has already an existing IATA code.');

                updaterObj.isFaulty=true;
                updaterObj.errorMessage = 'This account has already an existing IATA code.';

                return updaterObj;
            }

            if(!allowedProgramCodes.contains(theAccreditation.Location_Class__c))
            {
                System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] IATA Code Generation is only allowed for A, C, D, I, K, P, Q, R, T, M, G, X and P Location Classes.');

                updaterObj.isFaulty=true;
                updaterObj.errorMessage = 'IATA Code Generation is only allowed for A, C, D, I, K, P, Q, R, T, M, G, X and P Location Classes.';
                
                return updaterObj;
            }
            


            //List<String> availablePrograms = new List<String>();
            Map<String, String> programLabelToStringMap = new Map<String, String>();
            programLabelToStringMap = AmsIataCodeGenerator.convertProgramLabelsToStringMap();
            
            // For Cargo Agency branches, the IATA code should be the same as for the top-level Agency
            // So if the account has a top-level parent with IATA Code, we shall use it and utilize the C, A and N codes based on the IATA Code.
            if(AMS_Utils.CLASS_REQ_CASS_NUMBER.contains(theAccreditation.Location_Class__c) && !isGSA && theAccreditation.SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c != null) { /*** AMSU-173 ***/
                System.debug('*** Entered based on longCodePrograms with value ' + theAccreditation.Location_Class__c + '-' + theAccount.Sector__c);

                theAccreditation.IATACode__c = theAccreditation.SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c.subString(0, 7)+theAccreditation.CASS_Number__c;
                //theAccreditation.Chk_Dgt__c = theAccreditation.SAAM_Case__r.Account.Top_Parent__r.Check_Digit__c;
                theAccreditation.C_Code__c = theAccreditation.IATACode__c.subString(0, 2);
                theAccreditation.A_Code__c = theAccreditation.IATACode__c.subString(2, 3);
                theAccreditation.N_Code__c = theAccreditation.IATACode__c.subString(3, 7);
                AmsIataCodeGenerator.checkDigitCreation(theAccreditation, theAccount, false);
                theAccount.Site = theAccreditation.IATACode__c;
                theAccreditation.IATACode__c = theAccreditation.IATACode__c+theAccreditation.Chk_Dgt__c;
                
                theAccount.IATACode__c = theAccreditation.SAAM_Case__r.OSCAR__r.Account__r.Top_Parent__r.IATACode__c.subString(0, 7)+theAccreditation.CASS_Number__c;
                //theAccount.Check_Digit__c = theAccreditation.SAAM_Case__r.Account.Top_Parent__r.Check_Digit__c;
                theAccount.C_Code__c = theAccreditation.IATACode__c.subString(0, 2);
                theAccount.A_Code__c = theAccreditation.IATACode__c.subString(2, 3);
                theAccount.N_Code__c = theAccreditation.IATACode__c.subString(3, 7);
                theAccount.IATACode__c = theAccreditation.IATACode__c;
                
                theAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
                if(theAccreditation.ANG_IsNewGenAgency__c) theAccount.Sector__c = AMS_Utils.SECTOR_PASSENGER;
                if(allowedProgramCodes.contains(theAccreditation.Location_Class__c))
                {
                    //hammer: new requirement has same location class mapping to different account categories...
                    if(theAccreditation.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSSA && theAccount.Location_Class__c == 'G') {
                        theAccount.Category__c = 'GSSA Cargo';
                        theAccount.Sector__c = 'Cargo Agent'; // AMS Enhancements AMSU-24
                    }
                    else if (theAccount.Location_Class__c == 'G') { // AMS Enhancements AMSU-24                        
                        if (theAccount.CASS_Number__c != null) {
                            theAccount.Category__c = 'GSSA Cargo';
                            theAccount.Sector__c = 'Cargo Agent';
                        } else {
                            theAccount.Category__c = 'GSA General Sales Agent';
                            theAccount.Sector__c = 'Travel Agent';
                        }
                    }
                    else {
                        theAccount.Category__c = programCategoryMap.get(theAccreditation.Location_Class__c);
                        theAccount.Sector__c = programSectorMap.get(theAccreditation.Location_Class__c); // AMS Enhancements AMSU-24                        
                    }
                }
                else
                {
                    // TODO Later... These are already mapped, but there's no task to activate these yet
                    // When the moment comes, we should remove the above IF and this ELSE
                    
                    // theAccount.Category__c = programCategoryMap.get(theAccount.Location_Class__c);
                }
                


                if(!AmsIataCodeGenerator.isIATACodeGeneratedUnique(theAccreditation.IATACode__c)){

                    if(isImportAgentWithLink){
                    
                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The IATA code generated is not unique. Since this is an Import Agent, the code is based on the Link agent\' Iata code. Please search the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool or contact the System Administrator.');

                        updaterObj.isFaulty=true;
                        updaterObj.errorMessage = 'The IATA code generated is not unique. Since this is an Import Agent, the code is based on the Link agent\' Iata code. Please search the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool or contact the System Administrator.';
                        
                        return updaterObj;

                    }
                    else{

                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The IATA code generated is not unique. Please check the CASS Number (if it is a branch) in the hierarchy or search for the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool.');

                        updaterObj.isFaulty=true;
                        updaterObj.errorMessage = 'The IATA code generated is not unique. Please check the CASS Number (if it is a branch) in the hierarchy or search for the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool ';
                        
                        return updaterObj;

                    }

                }

                String isoState = theAccreditation.IATA_ISO_State__c;
                if(isoState == null && theAccreditation.Branch_Office_Country__c != null)
                {
         
                    if(theAccreditation.Branch_Office_Country__c == null || theAccreditation.Branch_Office_Country__r.AMS_Default_State__c == null){
                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.');

                        updaterObj.isFaulty=true;
                        updaterObj.errorMessage = 'The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.';
                        
                        return updaterObj;
                    }

                    String countryDefaultState = theAccreditation.Branch_Office_Country__r.AMS_Default_State__c;
                    List<IATA_ISO_State__c> defaultIsoStateList = new List<IATA_ISO_State__c>();
                    for(IATA_ISO_State__c state : IATAIsoStateDAO.getIsoStateByIsoCodes(new Set<String>{countryDefaultState})){
                        if(state.IATA_ISO_Country__c == theAccreditation.Branch_Office_Country__c)
                            defaultIsoStateList.add(state);
                    }

                    if(defaultIsoStateList.isEmpty()){

                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.');

                        updaterObj.isFaulty=true;
                        updaterObj.errorMessage = 'The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.';
                        
                        return updaterObj;
                    }

                    isoState = defaultIsoStateList.get(0).Id;
                   
                }
                else
                {
                    isoState = theAccreditation.IATA_ISO_State__c;
                    System.debug('[generatedAgencyIATACode] isostate existed: '+isoState);
                }

                System.debug('[generatedAgencyIATACode] Storing accreditation with iata code: '+theAccreditation.IATACode__c);
                System.debug('[generatedAgencyIATACode] storing account with iata code: '+theAccount.IATACode__c);

                //Database.SaveResult sr = Database.update(theAccreditation, true); 
                updaterObj.onlineAMap.put(theAccreditation.Id,theAccreditation);
                
                //Database.SaveResult srForAccount = Database.update(theAccount, true); 
                updaterObj.acctMap.put(theAccount.Id,theAccount);

                return updaterObj;
            }
            
            if(theAccreditation.Branch_Office_Country__c != null)
            {

                System.debug('[generatedAgencyIATACode] Entered based on theAccreditation.Branch_Office_Country__c with value ' + theAccreditation.Branch_Office_Country__c);
                
                List<Code_Range__c> acceptableRanges = new List<Code_Range__c>();
                
                /*    
                    A -         Select RANGES
                    
                    UPDATE 31.3.2016:
                    Switched from the old system, because as of 31.3.2016, we should trust the Code Range tables to give us exact matching even with the "fake states" set.
                    UPDATE 12.4.2016:
                    Started using theAccreditation.Branch_Office_Country__c instead of IATA_ISO_Country__c
                */

                String isoState = theAccreditation.IATA_ISO_State__c;
                if(isoState == null && theAccreditation.Branch_Office_Country__c != null)
                {

                    if(theAccreditation.Branch_Office_Country__c == null || theAccreditation.Branch_Office_Country__r.AMS_Default_State__c == null){
                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.');

                        updaterObj.isFaulty=true;
                        updaterObj.errorMessage = 'The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.';
                        
                        return updaterObj;
                    }

                    String countryDefaultState = theAccreditation.Branch_Office_Country__r.AMS_Default_State__c;
                    List<IATA_ISO_State__c> defaultIsoStateList = new List<IATA_ISO_State__c>();
                    for(IATA_ISO_State__c state : IATAIsoStateDAO.getIsoStateByIsoCodes(new Set<String>{countryDefaultState})){
                        if(state.IATA_ISO_Country__c == theAccreditation.Branch_Office_Country__c)
                            defaultIsoStateList.add(state);
                    }

                    if(defaultIsoStateList.isEmpty()){

                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.');

                        updaterObj.isFaulty=true;
                        updaterObj.errorMessage = 'The agency you were submitting does not have IATA ISO State set. The system failed to find a default one to use for your selected ISO Country. Please provide a State value as well and try generating the IATA code again, please.';
                        
                        return updaterObj;
                    }

                    isoState = defaultIsoStateList.get(0).Id;
                   
                }
                else
                {
                    isoState = theAccreditation.IATA_ISO_State__c;
                    System.debug('[generatedAgencyIATACode] isostate existed: '+isoState);
                }
                
                acceptableRanges  = [select IATA_ISO_State__r.Name, Area__c, Area_Code__c, Prefix__c, IATA_ISO_Country__c, IATA_ISO_State__c, Max_Range__c, Min_Range__c, ProgramCode__c, Program__c, Name from Code_Range__c where 
                            IATA_ISO_Country__c = :theAccreditation.Branch_Office_Country__c and IATA_ISO_State__c = :isoState and ProgramCode__c = :theAccreditation.Location_Class__c order by Area_Code__c, Min_Range__c ];
                
                System.debug('[generatedAgencyIATACode] Acceptable Ranges: '+acceptableRanges);
                
                /*    
                    B -         Select AVAILABLE ID
                
                    ISSUE HERE: cannot be run in ONE QUERY: if we have >5 AREA CODE full range: we would have possibly > 50K records returned. And a failure.
                    As we are far from the SOQL limit, it is recomanded to  run the Query Range Per Range
                */
                if(acceptableRanges.size() > 0)
                {
                    List<String> prefixes = new List<String>();
                    for(Code_Range__c range : acceptableRanges)
                    {

                        System.debug('[generatedAgencyIATACode] prefix: '+range.Prefix__c);
                        System.debug('[generatedAgencyIATACode] area c: '+range.Area_Code__c);
                        System.debug('[generatedAgencyIATACode] min -1: '+string.valueof(range.Min_Range__c).left(1));


                        Integer rangeValueToUse = -1;

                        if(!isImportAgentWithLink){

                            String infLimit = AmsIataCodeGenerator.resizeNumericString(range.Prefix__c+'',2)+''+range.Area_Code__c;
                            System.debug('[generatedAgencyIATACode] Create infLimit  '+infLimit+' based on range  '+range.Prefix__c+''+range.Area_Code__c+''+string.valueof(range.Min_Range__c).left(1));
                            Integer minRange = Integer.valueOf(String.valueOf(range.Min_Range__c).left(1));
                            Integer maxRange = Integer.valueOf(String.valueOf(range.Max_Range__c).left(1));
                            
                            System.debug('[generatedAgencyIATACode] min: '+minRange);
                            System.debug('[generatedAgencyIATACode] max: '+maxRange);
                            
                            List<String> rangesToSearch = new List<String>();
                            if(range.Min_Range__c < 1000)
                            {
                                rangesToSearch.add(infLimit+'0');
                            }
                            
                            if(range.Max_Range__c >= 1000)
                            {
                                for(integer i = (range.Min_Range__c < 1000? 1 : minRange); i<=maxRange; i++)
                                {
                                    rangesToSearch.add(infLimit+String.valueOf(i));
                                }
                            }
                            
                            String accountQuery;
                            String accreditationFormQuery;
                            if(rangesToSearch.size() == 1)
                            {
                                accountQuery = 'select IATACode__c from Account where IATACode__c like \'' +rangesToSearch.get(0) +'%\' '+
                                                'and (RecordType.DeveloperName = \'IATA_Agency\' OR RecordType.DeveloperName = \'Standard_Account\') '+
                                                'group by IATACode__c order by IATACode__c';
                                accreditationFormQuery = 'select IATACode__c from AMS_Pax_Accreditation_Form__c where IATACode__c like \'' +rangesToSearch.get(0) +'%\' and (NOT SAAM_Case__r.OSCAR__r.Account__r.IATACode__c  like \'P%\') group by IATACode__c order by IATACode__c';
                            }
                            else if(rangesToSearch.size() > 1)
                            {
                                String queryPart1 = 'select IATACode__c from ';
                                String queryPart2Account = ' where (';
                                String queryPart2PAX = ' where (';
                                for(String rangeToSearch : rangesToSearch)
                                {
                                    queryPart2Account = queryPart2Account + 'IATACode__c like \'' + rangeToSearch + '%\' or ';
                                    queryPart2PAX = queryPart2PAX + 'IATACode__c like \'' + rangeToSearch + '%\' or ';
                                }
                                
                                queryPart2Account = queryPart2Account.subString(0, queryPart2Account.length()-4);
                                queryPart2Account = queryPart2Account + '  )  ' + 
                                        'and (RecordType.DeveloperName = \'IATA_Agency\' OR RecordType.DeveloperName = \'Standard_Account\') '+
                                        'group by IATACode__c order by IATACode__c';
                                
                                queryPart2PAX = queryPart2PAX.subString(0, queryPart2PAX.length()-4);
                                queryPart2PAX = queryPart2PAX + '  ) and (NOT SAAM_Case__r.OSCAR__r.Account__r.IATACode__c  like \'P%\') group by IATACode__c order by IATACode__c';

                                accountQuery = queryPart1 + 'Account' + queryPart2Account;
                                accreditationFormQuery = queryPart1 + 'AMS_Pax_Accreditation_Form__c' + queryPart2PAX;
                            }
                            
                            System.debug('[generatedAgencyIATACode] Account query: '+accountQuery);
                            System.debug('[generatedAgencyIATACode] Accreditation form query: '+accreditationFormQuery);
                            
                            List<AggregateResult> rangeAgenciesBeforeFilterAccount = Database.query(accountQuery);
                            List<AggregateResult> rangeAgenciesBeforeFilterAccreditationForm = Database.query(accreditationFormQuery);
                            
                            Set<Integer> usedValuesInRange = new Set<Integer>();

                            if(rangeAgenciesBeforeFilterAccount != null){
                                for(AggregateResult ag : rangeAgenciesBeforeFilterAccount){
                                    String iatacode = (String) ag.get('IATACode__c');
                                    try{
                                        usedValuesInRange.add(Integer.valueOf(iatacode.subString(3, 7)));
                                    }catch(TypeException te){
                                        //In case the IATA code found is not numeric I don't need to do anything else because this class will assign only numeric IATA codes
                                    }catch(Exception e){

                                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] Shorter IATA code found in the system: '+iatacode);

                                        updaterObj.isFaulty=true;
                                        updaterObj.errorMessage = 'Shorter IATA code found in the system: '+iatacode;

                                        return updaterObj;

                                    }
                                }
                            }
                            system.debug('[generatedAgencyIATACode] Used values in the defined range (accounts): '+ usedValuesInRange.size());

                            if(rangeAgenciesBeforeFilterAccreditationForm != null){
                                for(AggregateResult ag : rangeAgenciesBeforeFilterAccreditationForm){
                                    String iatacode = (String) ag.get('IATACode__c');
                                    try{
                                        usedValuesInRange.add(Integer.valueOf(iatacode.subString(3, 7)));
                                    }catch(TypeException te){
                                        //In case the IATA code found is not numeric I don't need to do anything else because this class will assign only numeric IATA codes
                                    }catch(Exception e){

                                        System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] Shorter IATA code found in the system: '+iatacode);

                                        updaterObj.isFaulty=true;
                                        updaterObj.errorMessage = 'Shorter IATA code found in the system: '+iatacode;

                                        return updaterObj;
                                    }
                                }
                            }
                            system.debug('[generatedAgencyIATACode] Used values in the defined range (accounts + accreditation forms): '+ usedValuesInRange.size());

                            Integer minRangeInt = Integer.valueOf(String.valueOf(range.Min_Range__c).replace(',', ''));
                            Integer maxRangeInt = Integer.valueOf(String.valueOf(range.Max_Range__c).replace(',', ''));

                            System.debug('[generatedAgencyIATACode] Min range ---> ' + minRangeInt);
                            System.debug('[generatedAgencyIATACode] Max range ---> ' + maxRangeInt);

                            List<Integer> orderedSlotsOccupied = new List<Integer>(usedValuesInRange);
                            orderedSlotsOccupied.sort();

                            rangeValueToUse = AMS_Utils.findGapInRange(minRangeInt, maxRangeInt, orderedSlotsOccupied);

                        }
                        else{
                            rangeValueToUse = 1; // dummy value just to skipp next validations
                        }

                        if(rangeValueToUse == -1){
                            // No availability within the code ranges: IATA Code can't be created for the current Agency configuration.
                        
                            System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] System failed to find an open slot for IATA Code based on the current configuration of Agency. Please contact your system Administrator.');

                            updaterObj.isFaulty=true;
                            updaterObj.errorMessage = 'System failed to find an open slot for IATA Code based on the current configuration of Agency. Please contact your system Administrator.';

                            return updaterObj;

                        }else{

                            system.debug('[generatedAgencyIATACode] Found value available within defined range: ' + rangeValueToUse);

                            theAccreditation.C_Code__c = AmsIataCodeGenerator.resizeNumericString(String.valueOf(range.Prefix__c), 2);
                            theAccreditation.A_Code__c = String.valueOf(range.Area_Code__c);
                            theAccreditation.N_Code__c = isImportAgentWithLink ? theAccreditation.Link_agent_name__r.IATACode__c.subString(3, 7) : AmsIataCodeGenerator.resizeNumericString(String.valueOf(rangeValueToUse), 4);

                            String iatacodeToValidate = AmsIataCodeGenerator.generateIATACodeWithCheckDigit(theAccreditation, theAccount);

                            if(iatacodeToValidate == null){
 
                                System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] Couldn\'t generate IATA Code, please make sure the location class "' + theAccreditation.Location_Class__c + '", sector "' + theAccount.Sector__c + '" and category "' + theAccount.Category__c + '" are correct');

                                updaterObj.isFaulty=true;
                                updaterObj.errorMessage = 'The IATA code generated is not unique. Since this is an Import Agent, the code is based on the Link agent\' Iata code. Please search the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool or contact the System Administrator.';

                                return updaterObj;

                            }

                            if(!AmsIataCodeGenerator.isIATACodeGeneratedUnique(iatacodeToValidate)){
                                
                                if(isImportAgentWithLink){
                                    
                                    System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The IATA code generated is not unique. Since this is an Import Agent, the code is based on the Link agent\' Iata code. Please search the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool or contact the System Administrator.');

                                    updaterObj.isFaulty=true;
                                    updaterObj.errorMessage = 'The IATA code generated is not unique. Since this is an Import Agent, the code is based on the Link agent\' Iata code. Please search the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool or contact the System Administrator.';

                                    return updaterObj;

                                }
                                else{
                                    
                                    System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] The IATA code generated is not unique. Please check the CASS Number (if it is a branch) in the hierarchy or search for the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool.');

                                    updaterObj.isFaulty=true;
                                    updaterObj.errorMessage = 'The IATA code generated is not unique. Please check the CASS Number (if it is a branch) in the hierarchy or search for the IATA Code ' + theAccreditation.IATACode__c + ' in the search tool ';

                                    return updaterObj;
                                }

                            }

                            //theAccount.IATACode__c = theAccreditation.IATACode__c;
                            if(theAccreditation.ANG_IsNewGenAgency__c) theAccount.Sector__c = AMS_Utils.SECTOR_PASSENGER;
                            theAccount.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
                            if(allowedProgramCodes.contains(theAccreditation.Location_Class__c))
                            {
                                if(theAccreditation.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSSA && theAccount.Location_Class__c == 'G') {
                                    theAccount.Category__c = 'GSSA Cargo';
                                    theAccount.Sector__c = 'Cargo Agent'; // AMS Enhancements AMSU-24
                                }
                                else if (theAccount.Location_Class__c == 'G') { // AMS Enhancements AMSU-24                        
                                    if (theAccount.CASS_Number__c != null) {
                                        theAccount.Category__c = 'GSSA Cargo';
                                        theAccount.Sector__c = 'Cargo Agent';
                                    } else {
                                        theAccount.Category__c = 'GSA General Sales Agent';
                                        theAccount.Sector__c = 'Travel Agent';
                                    }
                                }
                                else {
                                    theAccount.Category__c = programCategoryMap.get(theAccount.Location_Class__c);
                                    theAccount.Sector__c = programSectorMap.get(theAccount.Location_Class__c); // AMS Enhancements AMSU-24                                    
                                }
                            }
                            
                            System.debug('[generatedAgencyIATACode] storing accreditation with iata code: '+theAccreditation.IATACode__c);
                            List<Code_Range__c> codeRangesToLock = [select id, AMS_Deplicate_Prevention_Lock__c from Code_Range__c where id = :range.Id for update];
                            Code_Range__c codeRange = codeRangesToLock.get(0);
                            codeRange.AMS_Deplicate_Prevention_Lock__c = true;
                            update codeRangesToLock;

                            
                            //Database.SaveResult sr = Database.update(theAccreditation, true);
                            updaterObj.onlineAMap.put(theAccreditation.Id,theAccreditation);

                            System.debug('[generatedAgencyIATACode] storing account with iata code: '+theAccount.IATACode__c);
                            //Database.SaveResult srForAccount = Database.update(theAccount, true); 
                            updaterObj.acctMap.put(theAccount.Id,theAccount);

                            codeRange.AMS_Deplicate_Prevention_Lock__c = false;
                            update codeRangesToLock;
                            return updaterObj;
                        }                                   
                        
                    }
                    
                }
                else
                {
                    System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] System failed to find an existing range for the Agency based on Primary Address criteria and Type. Please contact your system Administrator.');

                    updaterObj.isFaulty=true;
                    updaterObj.errorMessage = 'System failed to find an existing range for the Agency based on Primary Address criteria and Type. Please contact your system Administrator.';

                    return updaterObj;

                }
                
            }
            else
            {

                System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] Agency  doesn’t have a Country  or Primary Address to select a range. Please create a Primary address and/or assign a country.');

                updaterObj.isFaulty=true;
                updaterObj.errorMessage = 'Agency  doesn’t have a Country  or Primary Address to select a range. Please create a Primary address and/or assign a country.';

                return updaterObj;

            }
        }
        catch(Exception e)
        {

            sb.add('*************************** Failure while processing the code '+e.getStackTraceString());

            AmsIataCodeGenerator.sendLogsToUser(sb.getStringValue(),theAccount.Id);

            System.debug(LoggingLevel.ERROR,'[generatedAgencyIATACode] Exception while IATA code was generated:' + e.getStackTraceString());

            updaterObj.isFaulty=true;
            updaterObj.errorMessage = 'Exception while IATA code was generated:' + e.getStackTraceString();

            return updaterObj;

        }

        updaterObj.toUpdate = true;

        return updaterObj ;
    }
    
    // Added 04.04.2016: The IATACode stored on Account and Accreditation Online records should contain:
    // 7 digits + 1 Check Digit for Passenger and other but Cargo Agencies
    // 7 digits + Cass Number + Check Digit for Cargo agencies
    public static String generateIATACodeWithCheckDigit(AMS_Pax_Accreditation_Form__c agt, Account act)
    {
        checkDigitCreation(agt, act, false);
        
        Boolean isGSA = agt.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSA || agt.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSA_BSP;   
        if(agt.Location_Class__c.equalsIgnoreCase('P') || agt.Location_Class__c.equalsIgnoreCase('M') || (agt.Location_Class__c.equalsIgnoreCase('G') && isGSA) || agt.Location_Class__c.equalsIgnoreCase('X') || agt.Location_Class__c.equalsIgnoreCase('T') || agt.Location_Class__c.equalsIgnoreCase('D'))
        {
            agt.IATACode__c = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+agt.Chk_Dgt__c;
            act.Site = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c;
        }
        else if(agt.Location_Class__C.equalsIgnoreCase('C') || agt.Location_Class__C.equalsIgnoreCase('R') || agt.Location_Class__C.equalsIgnoreCase('Q') || agt.Location_Class__C.equalsIgnoreCase('I'))
        {
            agt.IATACode__c = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+agt.CASS_Number__c+agt.Chk_Dgt__c;
            act.Site = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+agt.CASS_Number__c;
        }
        else if(agt.C_Code__c != null && agt.A_Code__c != null&& agt.N_Code__c != null&& agt.CASS_Number__c != null&& agt.Chk_Dgt__c != null)
        {
            agt.IATACode__c = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+agt.CASS_Number__c+agt.Chk_Dgt__c;
            act.Site = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+agt.CASS_Number__c;
        }else if(agt.Location_Class__C.equalsIgnoreCase('L')){//PASS coding to be changed later
            String passNumber=createPassNumber(agt);
            agt.IATACode__c = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+passNumber+agt.Chk_Dgt__c;
            act.Site = agt.C_Code__c +agt.A_Code__c+agt.N_Code__c+passNumber;
        }
        act.IATACode__c = agt.IATACode__c;

        return act.IATACode__c;
    }
    
    /**
    Compare 2 codes. 
    @Return return the numeric value of code1 - code 2
    */
    @TestVisible private static integer compare2Codes(String code1, String code2){
        String c1 = code1.replaceAll('[^0-9]', '');
        String c2 = code2.replaceAll('[^0-9]', '');
        return integer.valueof(c1)-integer.valueof(c2);
    }
    
    public static String  resizeNumericString(String aString, integer expectedSize){
        String s = aString;
        while(s.length()<expectedSize)
        {
            s = '0'+s;
        }
        System.debug('*** [IATA CODE Generator] update String from '+aString+' to '+s);
        return s;
    }
    
    /**
    Calculate the CheckDigit based on all elelment from IATA Code
    boolean parameter for to save or not the record
    */
    public static void checkDigitCreation(AMS_Pax_Accreditation_Form__c agt, Account act, boolean saveRecord){
     
        Map<String,String> letterIndex = new Map<String,String>{'A'=> '10','B'=> '11','C' => '','D'=> '13','E'=> '14','F'=> '15','G'=> '16','H'=> '17','I'=> '18','J'=> '19','K'=> '20','L'=> '21','M'=> '22','N'=> '23','O'=> '24','P'=> '25','Q'=> '26','R'=> '27','S'=> '28','T'=> '29','U'=> '30','V'=> '31','W'=> '32','X'=> '33','Y'=> '34','Z'=> '35'};
        String nACode = agt.A_code__c;
        String nCCode  ='' ; 
        String cNCode = agt.N_code__c;
        String cCassNumber ='' ;  
        
        //'country' digits can be Chars. We need to replace them by the values from Map
        System.debug('**** Agency IATA Code: '+agt.IATACode__c + ' C Code: '+ agt.C_code__c);
        if(agt.C_code__c==null || agt.A_code__c==null || agt.N_code__c==null)
        {
            System.debug('***** returning null from CAN code check: C: ' + agt.C_code__c + ' A: ' + agt.A_code__c + ' N: ' + agt.N_code__c);
            return;
        }
        
        if(!agt.C_code__c.isNumeric())
        {
            String[] stringCharacters = agt.C_code__c.split('');
            stringCharacters.remove(0);
            
            for(String c : stringCharacters)
            {
                //sometimes split method is adding null
                if(c != null)
                {
                    String s = c.toUpperCase();
                    System.debug('**** [CHECKDIGIT]  LETTER INDEX: for char'+s+' returned '+letterIndex.get(s));
                    if(!c.isNumeric())
                    {
                        nCCode +=  letterIndex.get(c.toUpperCase());
                    }
                    else
                    {
                        nCCode += c;
                    }
                }
            }
        }
        else
        {
            //STD case: directly set the Country code
            nCCode = agt.C_code__c;
        }
        
        /*** AMSU-173 ***/
        Boolean isGSA = agt.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSA || agt.SAAM_Case__r.OSCAR__r.Process__c == AMS_Utils.new_GSA_BSP;        
        if(AMS_Utils.CLASS_REQ_CASS_NUMBER.contains(agt.Location_Class__c) && !isGSA &&  agt.CASS_Number__c != null) {
            cCassNumber = resizeNumericString(agt.CASS_Number__c+'',3);
        }

        //PASS Specific scenario
        if(agt.Location_Class__C.equalsIgnoreCase('L')){
            cCassNumber=createPassNumber(agt);
        }
        
        // System.debug('****************** C, A, N, Cass: '+nCCode + ' - ' + nACode + ' - ' + cNCode + ' - ' + cCassNumber);
        String code = nCCode + nACode + cNCode + cCassNumber ;
        System.debug('**** [CHECKDIGIT] built '+code+' from Values'+nCCode   +'/'+nACode +'/'+cNCode +'/'+cCassNumber );
        System.debug('**** [CHECKDIGIT]  from AGT values '+agt.C_code__c+'/'+agt.A_code__c+'/'+agt.N_code__c+'/'+act.CASS_Number__c);
        Long l = Long.valueOf(code);
        String checkDigit = math.mod(l,7)+'';
        agt.Chk_Dgt__c = checkDigit ;
        act.Check_Digit__c = checkDigit;
        
        
        //jfo 2016-02-01 .. adding the DML
        if(saveRecord)
        {
            update agt;
            update act;
        }
    }
    
    
    /**
    Calculate the CheckDigit based on all elelment from IATA Code
    always save the agt record
    */
    //public static void checkDigitCreation(Ams_Agency__c agt){#AMSFTS
    public static void checkDigitCreation(AMS_Pax_Accreditation_Form__c agt, Account act)
    {
        checkDigitCreation(agt, act, true);
    }
    
    public static void sendLogsToUser(String body, String title)
    {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        List<String> receivers = new List<String>();
        for(User u:[Select Id,Name,Email from User where Id=:userinfo.getuserId()])
        {
            receivers.add(u.Email);
        }
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setSubject('[IATA CODE GENERATION] Logger '+title);
        mail.setToAddresses(receivers) ;           
        mail.setPlainTextBody(body);
        emails.add( mail);
        Messaging.sendEmail(emails);    
    }
    
    // Just to be sure we're always using the real picklist values and not hardcoded ones. The code supports longer picklist values as well, if needed.
    public static Map<String, String> convertProgramLabelsToStringMap()
    {
        Map<String, String> mapToReturn = new Map<String, String>();
        Schema.DescribeFieldResult fieldResult = Code_Range__c.ProgramCode__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for(Schema.PicklistEntry entry : ple)
        {
            mapToReturn.put(entry.getValue().subString(0,1), entry.getValue());
        }
        return mapToReturn;
    }

    //method to create the PASS Number to be used in the IATA Code:  HQ & BR indication, HQ is 000, BR= starting from 001
    public static String createPassNumber(AMS_Pax_Accreditation_Form__c accreditationForm){
        String passNumber='';
        if(accreditationForm.Location_Type__c=='HO'){
            passNumber=AmsIataCodeGenerator.resizeNumericString('0', 3);
        }else if(accreditationForm.Location_Type__c=='BR'){
            List<AMS_Pax_Accreditation_Form__c> otherAccreditationFormList=[SELECT Id FROM AMS_Pax_Accreditation_Form__c WHERE IATACode__c!='' AND HO_Account__c=:accreditationForm.HO_Account__c AND Location_Type__c='BR'];

            passNumber=AmsIataCodeGenerator.resizeNumericString(String.valueOf(otherAccreditationFormList.size()+1), 3);
        }
        return passNumber;
    }
    
    public static Map<String, String> constructProgramCategoryMap()
    {
        //PASS- Added new location class "L" in the Account picklist field related to the PASS process. The old Category value for the Location value L was "Non-IATA Locations", but now it was changed to "Postal Service"
        Map<String,String> pcMap = new Map<String,String>{'A' => 'Airline Point of Sale', 'C' => 'IATA Cargo Agent', 'D' => 'Domestic Agent', 'F'=> 'ERSP (ELEC.RSVTN.SRV.PROVIDER)',  'I'=> 'Import Agent', 'K' => 'CATO', 'L' => 'Postal Service', 'M' => 'MSO Member Sales Office', 'N' => 'NISI', 'O' => 'SATO', 'P' => 'IATA Passenger Sales Agent', 'Q' => 'Courier', 'R' => 'CASS Associate', 'S' => 'SSI', 'T' => 'TIDS Agent', 'U' => 'Puerto Rico And US Virgin IS', 'X' => 'Handling Agent', 'Y' => 'Associations', 'Z' => 'Travel Ind Suppliers'};
        return pcMap;
    }
    
    public static Map<String, String> constructProgramSectorMap()
    {
        //PASS- Added new location class "L" in the Account picklist field related to the PASS process
        Map<String,String> psMap = new Map<String,String>{'A' => 'Travel Agent', 'C' => 'Cargo Agent', 'D' => 'Travel Agent', 'I'=> 'Cargo Agent', 'K' => 'Travel Agent', 'L' => 'Cargo Agent', 'M' => 'Travel Agent', 'P' => 'Travel Agent', 'Q' => 'Cargo Agent', 'R' => 'Cargo Agent', 'T' => 'Travel Agent', 'X' => 'Travel Agent'};
        
        return psMap;
    }

    public static boolean isIATACodeGeneratedUnique(String iataCode){
        return [SELECT ID from Account where IATACode__c =:iataCode LIMIT 1].isEmpty() && [SELECT ID from AMS_Pax_Accreditation_Form__c where IATACode__c =:iataCode and (NOT SAAM_Case__r.OSCAR__r.Account__r.IATACode__c like 'P%') LIMIT 1].isEmpty();
    }
}