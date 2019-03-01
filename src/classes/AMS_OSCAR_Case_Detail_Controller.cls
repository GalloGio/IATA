public with sharing class AMS_OSCAR_Case_Detail_Controller {


    public AMS_OSCAR__c oscarObj { 
        get{ 
            if(this.oscarObj == null)
                return new AMS_OSCAR__c();
            else return this.oscarObj;
        }
        set; }
    public AMS_Pax_Accreditation_Form__c accreditationObj { get; set; }

    public Boolean saveAction { get; set; }
    public Boolean isCargoAgency{get;set;}
    public Boolean isCertificationOSCAR{get;set;}
    public Boolean isNewGenProcess{get;set;}
    public Boolean isNewAE { get{ return (oscarObj.Process__c == AMS_Utils.NEWAE);}set;}
    public Boolean displayErrorMsg{get{return false;} set;}
    public Boolean showStagingArea {get; set;}

    private Set<Id> hierarchyAccountIds = new Set<Id>();
    private Map<Id, Account> hierarchyAccountsMap = new Map<Id, Account>();
    private Map<Id, List<AMS_Agencies_relationhip__c>> accountHierarchyRelationships = new Map<Id, List<AMS_Agencies_relationhip__c>>();

    //FM AMSU-1
    public ID corrRT {get{return RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');}set;}

        //this flag will controll if picklist or multipicklist is displayed for Remittance Frequency 
    public Boolean allowMultipleRemittances{
        get{
            if(this.allowMultipleRemittances == null){
                this.allowMultipleRemittances = false;
                if(operationCodes != null && !operationCodes.isEmpty()){
                    for(AMS_Operation__c opCode: operationCodes){
                        if(opCode.Allow_multiple_remittances__c){
                            this.allowMultipleRemittances = opCode.Allow_multiple_remittances__c;
                            return this.allowMultipleRemittances;
                        }
                    }
                }
            }
            return this.allowMultipleRemittances;

        }set;
    }

    public Id objectId { get; set; }

    public String remittanceFrequencyToShow{
        get{
            if (accreditationObj.Remittance_frequency__c == null || accreditationObj.Remittance_frequency__c == '') return '';
            if (!accreditationObj.Remittance_frequency__c.contains(';')) {
                return getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get(accreditationObj.Remittance_frequency__c);
            }else {
                List<String> auxRF = new List<String>();
                for (String rf :accreditationObj.Remittance_frequency__c.split(';')){
                    auxRF.add(getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get(rf));
                }
                return String.join(auxRF,';');
            }                   
        }
        set;
    }

    //using Schema to avoid typos on field Names
    private List<Schema.SObjectField> accreditationFieldList{
        get{
            return new List<Schema.SObjectField>{
                AMS_Pax_Accreditation_Form__c.Account_Name__c
                , AMS_Pax_Accreditation_Form__c.IATACode__c
                , AMS_Pax_Accreditation_Form__c.ISSP_AMS_Legal_Status__c
                , AMS_Pax_Accreditation_Form__c.CASS_Number__c
                , AMS_Pax_Accreditation_Form__c.SAAM_Case__c
                , AMS_Pax_Accreditation_Form__c.Short_Name__c
                , AMS_Pax_Accreditation_Form__c.Location_Class__c
                , AMS_Pax_Accreditation_Form__c.Location_Type__c
                , AMS_Pax_Accreditation_Form__c.Trade_Name__c
                , AMS_Pax_Accreditation_Form__c.ISSP_AMS_License_No__c
                , AMS_Pax_Accreditation_Form__c.ISSP_AMS_VAT_number__c
                , AMS_Pax_Accreditation_Form__c.ISSP_AMS_GDS_with_signed_contract__c
                , AMS_Pax_Accreditation_Form__c.Branch_Office_Country__c
                , AMS_Pax_Accreditation_Form__c.Branch_Office_Street_name_number__c
                , AMS_Pax_Accreditation_Form__c.Branch_Office_Postal_code__c
                //, AMS_Pax_Accreditation_Form__c.Billing_State__c DT: remove as per request 
                //, AMS_Pax_Accreditation_Form__c.ISO_Country__c DT: remove as per request
                , AMS_Pax_Accreditation_Form__c.Branch_Office_City__c
                , AMS_Pax_Accreditation_Form__c.IATA_ISO_State__c
                //, AMS_Pax_Accreditation_Form__c.Shipping_Country__c DT: remove as per request
                , AMS_Pax_Accreditation_Form__c.Shipping_Street__c
                , AMS_Pax_Accreditation_Form__c.Shipping_Postal_Code__c
                , AMS_Pax_Accreditation_Form__c.Shipping_ISO_Country__c
                , AMS_Pax_Accreditation_Form__c.Shipping_ISO_State__c
                //, AMS_Pax_Accreditation_Form__c.Shipping_State__c DT: remove as per request
                , AMS_Pax_Accreditation_Form__c.Shipping_City__c
                , AMS_Pax_Accreditation_Form__c.Branch_Office_Email__c
                , AMS_Pax_Accreditation_Form__c.Website__c
                , AMS_Pax_Accreditation_Form__c.Branch_Office_Phone__c
                , AMS_Pax_Accreditation_Form__c.Branch_Office_FAX__c
                , AMS_Pax_Accreditation_Form__c.ISSP_AMS_Premises_located_at_airport__c
                , AMS_Pax_Accreditation_Form__c.Mobile__c
                , AMS_Pax_Accreditation_Form__c.Abbreviated_name__c
                , AMS_Pax_Accreditation_Form__c.Abbreviated_Address__c
                , AMS_Pax_Accreditation_Form__c.Remittance_frequency__c
                //, AMS_Pax_Accreditation_Form__c.Solicitation_Flag__c CB: remove as per request AMSU-109
                , AMS_Pax_Accreditation_Form__c.VAT_Number_2__c 
                , AMS_Pax_Accreditation_Form__c.Link_agent_name__c
                , AMS_Pax_Accreditation_Form__c.Is_your_firm_handling_Dangerous_Goods__c
                , AMS_Pax_Accreditation_Form__c.ANG_IsNewGenAgency__c
                , AMS_Pax_Accreditation_Form__c.ANG_Accreditation_type__c
            };
        }
    }

    public static Set<String> hidenFieldsNewgenApplications = new Set<String>{};

    public List<String> accreditationFieldNames {
        get{
            if(accreditationFieldNames == null){
                accreditationFieldNames = new List<String>();
                for(Schema.SObjectField field : accreditationFieldList) {
                    accreditationFieldNames.add(field.getDescribe().getName());
                }
            }
            return accreditationFieldNames;
        }
        set;
    }

    private Set<String> editableFields{
        get{
            editableFields = new Set<String>();
            //FM AMSU-1
            String sCorrectionType_of_change = '';

            if(oscarObj != null && oscarObj.Type_of_change__c != null) editableFields = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(oscarObj.Type_of_change__c);
            if(oscarObj != null && oscarObj.ANG_Type_of_change__c != null) editableFields = ANG_AgencyChangesConfigHelper.getFieldsToMigrate(oscarObj.ANG_Type_of_change__c);

            //FM AMSU-1
            //AMSU-151 (AMSU-1) - added chech for isVATnumberSpecialCase in order to use the new 
            if(isSingleAccountHierarchy){
                sCorrectionType_of_change = 'CorrectionSingleAccount';
            }else if(isAllHierarchySelected){
                sCorrectionType_of_change = 'CorrectionAllHierarchy';
            }else{
                sCorrectionType_of_change = 'CorrectionPerLocation';
            }
            if(oscarObj != null && isAgencyCorrection) editableFields = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(sCorrectionType_of_change);

            Set<String> specialLocations = new Set<String> {'P', 'D'};
            UtilityCS__c ucsAccLinkAgentCountries = Test.isRunningTest() ? new UtilityCS__c(name ='AMS_COR_LINK_AGENT_COUNTRIES',value__c = 'ID') : UtilityCS__c.getInstance('AMS_COR_LINK_AGENT_COUNTRIES');
            List<String> lLinkAgentSpecialCaseCountries = ucsAccLinkAgentCountries.Value__c.split(';');
            Set<String> sLinkAgentSpecialCaseCountries = new Set<String>(lLinkAgentSpecialCaseCountries);
            Boolean isLinkAgentSpecialCase = specialLocations.contains(oscarObj.Account__r.Location_Class__c) && sLinkAgentSpecialCaseCountries.contains(oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c);
            system.debug('isLinkAgent special case: ' + isLinkAgentSpecialCase);
            system.debug('type of correction: ' + sCorrectionType_of_change);
            if((!isAllHierarchySelected || isSingleAccountHierarchy) && isLinkAgentSpecialCase && isAgencyCorrection) {
                editableFields.add('Link_agent_name__c');
            }
            if(!isAllHierarchySelected && isVATnumberSpecialCase && isAgencyCorrection) {
                editableFields.add('ISSP_AMS_VAT_number__c');
            }
            if(!isAllHierarchySelected && isAccNameSpecialCase && isAgencyCorrection) {
                editableFields.add('Account_Name__c');
            }
            if(isAllHierarchySelected && !isSingleAccountHierarchy && isVATnumberSpecialCase && isAgencyCorrection) {
                editableFields.remove('ISSP_AMS_VAT_number__c');
            }

            //System.debug(loggingLevel.FINEST, '____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] editableFields - ' + editableFields);
            System.debug('____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] sCorrectionType_of_change - ' + sCorrectionType_of_change);
            System.debug('____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] isAgencyCorrection - ' + isAgencyCorrection);
            System.debug('____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] isVATnumberSpecialCase - ' + isVATnumberSpecialCase);
            System.debug('____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] isAccNameSpecialCase - ' + isAccNameSpecialCase);

            System.debug('____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] editableFields - ' + editableFields);

            return editableFields;
        }
        private set;
    }

    private Boolean isEditable(String fieldName){

        //Enforce non editable fields for newgen processes.  NEWGEN-1862/NEWGEN-3387: Don't enforce for newgen changes/correction
        if(this.oscarObj.Account__r.ANG_IsNewGenAgency__c && (this.oscarObj.Process__c != AMS_Utils.NGCHANGES && this.oscarObj.Process__c != AMS_Utils.NGCORRECTION))
            if(notEditableForNEWGEN.contains(fieldName))
                return false;

        //verifu "hardcoded" logic
        if(fieldName == 'IATACode__c') return false;
        //if(fieldName == 'Location_Class__c' && isNewGenProcess) return false;
        //if(fieldName == 'Location_Type__c' && isNewGenProcess) return false;
        if(fieldName == 'ANG_Accreditation_Type__c' && isNewGenProcess && !isAgencyChanges) return false;
        if(fieldName == 'Remittance_frequency__c' && isNewGenProcess && oscarObj.Process__c == AMS_Utils.NEWAE) return false;     

        if(!isAgencyChanges && !isAgencyCorrection) return true;     

        //check per field
        return editableFields.contains(fieldName);
    }

    private Boolean isRendered(String fieldName){
        if(fieldName == 'Is_your_firm_handling_Dangerous_Goods__c') return isCargoAgency;
        if(fieldName == 'CASS_Number__c') return !isNewGenProcess;
        if(fieldName == 'SAAM_Case__c') return isNewGenProcess;
        if(fieldName == 'ANG_Accreditation_Type__c') return isNewGenProcess;

        if(hidenFieldsNewgenApplications.contains(fieldName))
            return  !isNewGenProcess;

        return true;
    }


    private List<AMS_Operation__c> operationCodes{
        get{
            if(this.operationCodes == null)
                this.operationCodes = ANG_AgencyChangesHelper.fetchOperationCodeConfiguration(RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c','BSP'), accreditationObj.Branch_Office_Country__c, accreditationObj.Location_Class__c);

            return this.operationCodes;            
        } set;
    }

    private Map<Id,AMS_Agency_Operations__c> agencyOperations{
        get{
            if(this.agencyOperations == null)
                this.agencyOperations = ANG_AgencyChangesHelper.fetchAccountAgOperationPerOpCode(new List<Id>{oscarObj.Account__c});
            
            return this.agencyOperations;
        }set;
    }

    private List<SelectOption> populateRightOptions(List<String> split) {

        List<SelectOption> rightopts = new List<SelectOption>();
       
        for(String a :split)
            rightopts.add(new SelectOption(a,getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get(a)));

        return rightopts;
    }

    // We need to know the correspondent labels to show on the page
    private Map<String,String> getPicklistLabels (String obj, String field){

        Map<String,String> valueLabelMap = new Map<String,String>();

        Schema.DescribeFieldResult dfr = Schema.getGlobalDescribe().get(obj).getDescribe().fields.getMap().get(field).getDescribe();
        for(Schema.PicklistEntry entry:  dfr.getPicklistValues()) {

            valueLabelMap.put(entry.getvalue(),entry.getLabel());
        }

        return valueLabelMap;
    }

    //auxiliary to the custom multipicklist
    public List<SelectOption> rightOptionsRF{
        get{
            if(this.rightOptionsRF == null && allowMultipleRemittances){

                this.rightOptionsRF = new List<SelectOption>();

                If(accreditationObj.Remittance_frequency__c != null)
                    this.rightOptionsRF = populateRightOptions(accreditationObj.Remittance_frequency__c.split(';'));

            }
            return this.rightOptionsRF;
        }
        set;
    }
    
    //AMSU-125
    public Boolean loadAMSRemittance(AMS_OSCAR__c oscar) {
        Set<String> locationsClass = new Set<String> {'P', 'D'};        
        Set<String> processesToCheck = new Set<String> {AMS_Utils.AGENCYCHANGES, AMS_Utils.new_HO, AMS_Utils.new_BR, AMS_Utils.new_SA};

        return !String.isBlank(oscar.Process__c) && locationsClass.contains(accreditationObj.Location_Class__c) && processesToCheck.contains(oscar.Process__c);
    }

    public List<SelectOption> getRfPicklistValues(){
        //AMSU-125
        if(loadAMSRemittance(oscarObj)) {
            return getRfPicklistValuesAMS();    
        }
        
        List<SelectOption> rfPicklistValues = new List<SelectOption>();
        Set<String> rightOptions;
        Set<String> auxOptions = new Set<String>();

                if(!allowMultipleRemittances){
                    rfPicklistValues.add(new SelectOption('','--None--'));
                // if multipicklist is being displayed, check the rightOptions to prevent record duplication between the left and right lists
                }else if(accreditationObj.Remittance_frequency__c != null){
                    rightOptions = new Set<String>(accreditationObj.Remittance_frequency__c.Split(';'));
                }else{
                    rightOptions = new Set<String>();
                    rightOptions.add('');
                }
                

               // for new HE Accreditations get the values from the BSP configuration of all BSP operation codes related to this country
                if(oscarObj.Process__c == AMS_Utils.NEWHELITE || oscarObj.Process__c == AMS_Utils.NEWHESTANDARD) {

                    for(AMS_Operation__c operation :operationCodes) {
                        for(ANG_BSP_Attributes__c attribute : operation.BSP_Attributes__r) {

                            if(!auxOptions.contains(attribute.Remittance_Frequency__c)){                               
                                rfPicklistValues.add(new SelectOption (attribute.Remittance_Frequency__c, getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get(attribute.Remittance_Frequency__c)));                               
                                //prevent duplication
                                auxOptions.add(attribute.Remittance_Frequency__c);
                            }
                        }
                    }

                // for New AE, remittance frequency is populated from the Parent Account and picklist values are restricted to the value of the parent
                }else if(oscarObj.Process__c == AMS_Utils.NEWAE) {

                    if(oscarObj.Account__r.Top_Parent__r.Remittance_Frequency__c != null )
                        rfPicklistValues.add(new SelectOption (oscarObj.Account__r.Top_Parent__r.Remittance_Frequency__c, getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get( oscarObj.Account__r.Top_Parent__r.Remittance_Frequency__c)));                 
                  
                // for changes and corrections populate only with BSP attributes of operation codes related with the current account
                }else if((oscarObj.Process__c == AMS_Utils.COR || oscarObj.Process__c == AMS_Utils.NGCHANGES || oscarObj.Process__c == AMS_Utils.NGCORRECTION) && isEditable('Remittance_frequency__c')) {

                    if(!agencyOperations.isEmpty()){                     
                        for(AMS_Operation__c opCode: operationCodes) {
                            //Make sure attributes are related with the current account
                            if(agencyOperations.keySet().contains(opCode.id)) {

                                for(ANG_BSP_Attributes__c attribute: opCode.BSP_Attributes__r) {
                                    if(!allowMultipleRemittances || !rightOptions.contains(attribute.Remittance_Frequency__c))
                                        rfPicklistValues.add(new SelectOption (attribute.Remittance_Frequency__c,getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get(attribute.Remittance_Frequency__c))); 
                                }
                            }
                        }
                    }
                   //for all the other processes get all the values from the picklist
                }else{
                    Schema.DescribeFieldResult dfr = AMS_Pax_Accreditation_Form__c.Remittance_frequency__c.getDescribe();
                    for(Schema.PicklistEntry entry:  dfr.getPicklistValues()) {
                        rfPicklistValues.add(new SelectOption (entry.getvalue(),entry.getLabel()));
                    }
                }
            
            return rfPicklistValues;
        
    }
    
    //AMSU-125
    public List<SelectOption> getRfPicklistValuesAMS() {
        List<SelectOption> rfPicklistValues = new List<SelectOption>();
        system.debug('operationCodes: ' +operationCodes);
        rfPicklistValues.add(new SelectOption('', '--None--'));
        if(!operationCodes.isEmpty()) {
            for(AMS_Operation__c opCode: operationCodes) {
                for(ANG_BSP_Attributes__c attribute : opCode.BSP_Attributes__r) {
                    //rfPicklistValues.add(new SelectOption(attribute.Remittance_Frequency__c, attribute.Remittance_Frequency__c));
                    rfPicklistValues.add(new SelectOption (attribute.Remittance_Frequency__c,getPicklistLabels('AMS_Pax_Accreditation_Form__c','Remittance_frequency__c').get(attribute.Remittance_Frequency__c))); 
                }
            }
        }
        return rfPicklistValues;
    }

    public Boolean isAgencyChanges{
        get{
            //Added NGCorrection, since NGCorrection will act like the change process
            if(oscarObj != null && (oscarObj.Process__c == AMS_Utils.AGENCYCHANGES  
                                || oscarObj.Process__c == AMS_Utils.COR  //FM AMSU-1
                                || oscarObj.Process__c == AMS_Utils.NGCHANGES  
                                || oscarObj.Process__c == AMS_Utils.NGCORRECTION)) return true;
            else return false;
        }
        private set;
    }

    public Boolean isOSCARCorrection{
        get{
            return oscarObj != null && oscarObj.Process__c == AMS_Utils.NGCORRECTION;
        }
        private set;
    }

    //FM AMSU-1
    public Boolean isAgencyCorrection{
        get{
            if(oscarObj != null && (oscarObj.Process__c == AMS_Utils.COR)) return true;
            else return false;
        }
        private set;
    }
    

    //FM AMSU-1
    public Boolean isVATnumberSpecialCase{
        get{
            if(isVATnumberSpecialCase != null){
                return isVATnumberSpecialCase;
            }else{

                //AMSU-151 (AMSU-1)
                UtilityCS__c ucsVATnumberSpecialCaseCountries = Test.isRunningTest() ? new UtilityCS__c(name ='AMS_COR_VAT_COUNTRIES',value__c = 'BR;IN;MY;TH') : UtilityCS__c.getInstance('AMS_COR_VAT_COUNTRIES');
                List<String> lVATnumberSpecialCaseCountries = ucsVATnumberSpecialCaseCountries.Value__c.split(';');
                Set<String> sVATnumberSpecialCaseCountries = new Set<String>(lVATnumberSpecialCaseCountries);

                System.debug('isVATnumberSpecialCase: ' + isVATnumberSpecialCase);
                System.debug('isVATnumberSpecialCase - oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c: ' + oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c);
                System.debug('isVATnumberSpecialCase - oscarObj.Account__r.Is_Branch_Abroad__c ' + oscarObj.Account__r.Is_Branch_Abroad__c);
                
                //if(isAgencyCorrection && (oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Portugal' ||oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Brazil' || oscarObj.Account__r.IATA_ISO_Country__r.Name == 'India' || oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Malaysia' || oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Thailand' || oscarObj.Account__r.Is_Branch_Abroad__c == 'Yes')){
                if(isAgencyCorrection && ( sVATnumberSpecialCaseCountries.contains( oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c ) || oscarObj.Account__r.Is_Branch_Abroad__c == 'Yes')){
                    isVATnumberSpecialCase = true;
                } else{
                    isVATnumberSpecialCase = false;
                } 
            }
            return isVATnumberSpecialCase;
        } 
        private set;
    }
         
    //FM AMSU-153
    public Boolean isAccNameSpecialCase{
        get{
            if(isAccNameSpecialCase != null){
                return isAccNameSpecialCase;
            }else{

                //AMSU-151 (AMSU-1)
                UtilityCS__c ucsAccNameSpecialCaseCountries = Test.isRunningTest() ? new UtilityCS__c(name ='AMS_COR_ACC_NAME_COUNTRIES',value__c = 'CN;TW') : UtilityCS__c.getInstance('AMS_COR_ACC_NAME_COUNTRIES');
                List<String> lAccNameSpecialCaseCountries = ucsAccNameSpecialCaseCountries.Value__c.split(';');
                Set<String> sAccNameSpecialCaseCountries = new Set<String>(lAccNameSpecialCaseCountries);

                System.debug('isAccNameSpecialCase - oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c: ' + oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c);
               
                //if(isAgencyCorrection && (oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Portugal' ||oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Brazil' || oscarObj.Account__r.IATA_ISO_Country__r.Name == 'India' || oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Malaysia' || oscarObj.Account__r.IATA_ISO_Country__r.Name == 'Thailand' || oscarObj.Account__r.Is_Branch_Abroad__c == 'Yes')){
                if(isAgencyCorrection && sAccNameSpecialCaseCountries.contains( oscarObj.Account__r.IATA_ISO_Country__r.ISO_Code__c ) ){
                    isAccNameSpecialCase = true;
                } else{
                    isAccNameSpecialCase = false;
                }     

                System.debug('isAccNameSpecialCase: ' + isAccNameSpecialCase);
                
            }
            return isAccNameSpecialCase;
        } 
        private set;
    } 

    //FM AMSU-1
    //Need to get the "isAllHierarchySelected" 1st in order to get the correct value
    public Boolean isBranchAbroadSelected{
        get{
            if(isBranchAbroadSelected != null){
                return isBranchAbroadSelected;
            }else{
                return false;
            }
        } 
        private set;
    }

    public Boolean isSingleAccountHierarchy{
        get{
            if(isSingleAccountHierarchy != null){
                return isSingleAccountHierarchy;
            }else{
                return false;
            }
        } 
        private set;
    }

    //FM AMSU-1
    public Boolean isAllHierarchySelected{
        get{
            System.debug('isAllHierarchySelected - entrei - isAllHierarchySelected : ' + isAllHierarchySelected);
            if(isAllHierarchySelected != null){
                return isAllHierarchySelected;
            }else{
                Map<Id, List<AMS_Process_Detail__c>> processDetailPerOSCAR = new Map<Id, List<AMS_Process_Detail__c>>();
                Set<Id> oscarIds = new Set<Id>();
                Set<Id> oscarOnlineAccredIds = new Set<Id>();
                
                oscarIds.add(oscarObj.Id);
                oscarOnlineAccredIds.add(oscarObj.AMS_Online_Accreditation__c);

                Map<Id, AMS_Pax_Accreditation_Form__c> onlineAccreditations = new Map<Id, AMS_Pax_Accreditation_Form__c>([SELECT Account_Name__c, IATACode__c, ISSP_AMS_Legal_Status__c, Short_Name__c, Trade_Name__c, ISSP_AMS_License_No__c, ISSP_AMS_VAT_number__c,
                    ISSP_AMS_GDS_with_signed_contract__c, Operation__c, Branch_Office_Country__r.Name, Branch_Office_Country__r.Due_diligence_mandatory__c, Branch_Office_Street_name_number__c, Branch_Office_Postal_code__c,
                    Billing_State__c, Branch_Office_City__c, ISO_Country__c, IATA_ISO_State__c, Shipping_Country__c, Shipping_Street__c, Shipping_Postal_Code__c,
                    Shipping_State__c, Shipping_City__c, Branch_Office_Email__c, Website__c, Branch_Office_Phone__c, Branch_Office_FAX__c, ISSP_AMS_Premises_located_at_airport__c,
                    Abbreviated_name__c, Abbreviated_address__c, Remittance_frequency__c, Solicitation_Flag__c, VAT_Number_2__c, CASS_Number__c, Location_Class__c, Location_Type__c, Mobile__c, Is_your_firm_handling_Dangerous_Goods__c,
                    Shipping_ISO_Country__c, Shipping_ISO_State__c, Shipping_ISO_Country__r.Name, Shipping_ISO_State__r.Name, IATA_ISO_State__r.Name, IATA_ISO_State__r.Valid_for_Address__c   
                    FROM AMS_Pax_Accreditation_Form__c
                    WHERE Id IN :oscarOnlineAccredIds]);

                AMS_Pax_Accreditation_Form__c oscarOnlineAccreditation = onlineAccreditations.get(oscarObj.AMS_Online_Accreditation__c);

                //query the the Process Detail object for all the agencies that are being bought
                List<AMS_Process_Detail__c> allProcessDetails = new List<AMS_Process_Detail__c>([SELECT Id, Account__c, OSCAR__c, Account__r.Status__c,Account__r.Is_Branch_Abroad__c, RecordType.Developername FROM AMS_Process_Detail__c WHERE OSCAR__c IN :oscarIds and RecordType.Developername = 'Agency_Involved']);

                for (AMS_Process_Detail__c pd : allProcessDetails) {

                    //TERMINATED AGENCIES IGNORED
                    if(pd.Account__c != null && pd.Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED){
                        if (processDetailPerOSCAR.get(pd.OSCAR__c) == null)
                            processDetailPerOSCAR.put(pd.OSCAR__c, new List<AMS_Process_Detail__c> {pd});
                        else
                            processDetailPerOSCAR.get(pd.OSCAR__c).add(pd);
                    }

                    if(pd.Account__r.Is_Branch_Abroad__c == 'Yes'){
                        isBranchAbroadSelected = true;
                    }

                }

                List<AMS_Process_Detail__c> pds = processDetailPerOSCAR.get(oscarObj.Id);

                Set<Id> agenciesAffected = new Set<Id>();
                Set<Id> agenciesAffectedWithHO = new Set<Id>();
                agenciesAffectedWithHO.add(oscarObj.Account__c);

                if (pds != null){
                    for (AMS_Process_Detail__c pd : pds){
                        agenciesAffected.add(pd.Account__c);
                        agenciesAffectedWithHO.add(pd.Account__c);
                    }
                }

                if(this.hierarchyAccountsMap.size() < 2){
                    isSingleAccountHierarchy = true;
                }

                system.debug('applyChangeCodesWithDependencies() -> processDetailPerOSCAR : ' + processDetailPerOSCAR);
                system.debug('applyChangeCodesWithDependencies() -> accountHierarchyRelationships : ' + this.accountHierarchyRelationships);
                system.debug('applyChangeCodesWithDependencies() -> accountIds : ' + this.hierarchyAccountsMap.keySet());
                system.debug('applyChangeCodesWithDependencies() -> hierarchyAccountsMap : ' + this.hierarchyAccountsMap);
                system.debug('applyChangeCodesWithDependencies() -> agenciesAffected : ' + agenciesAffected);
                
                //Checks if all Hierarchy was Selected
                isAllHierarchySelected = AMS_HierarchyHelper.isAllHierarchySelected(agenciesAffectedWithHO, this.accountHierarchyRelationships.get(oscarObj.Account__c), this.hierarchyAccountsMap);
                return isAllHierarchySelected;
                //system.debug('applyChangeCodesWithDependencies() -> isAllHierarchySelected : ' + isAllHierarchySelected);
            }
        }
        private set;
    }

    public List<FormField> accreditationFields{
        get{
            accreditationFields = new List<FormField>();
            for(String fieldName : accreditationFieldNames){
                accreditationFields.add(new FormField(fieldName, isEditable(fieldName), isRendered(fieldName)));
            }
            System.debug('## accreditationFields - ' + accreditationFields);
            return accreditationFields;
        }
        private set;
    }

    public Boolean hasEditableFields{
        get{
            Boolean editable = false;
            for(FormField field : accreditationFields) if(field.inlineEdit) editable = true;

            return editable;
        }
    }

    /*** AMSU-121 Start ***/
    public Boolean isChangeOfLocation {
        get {
            return oscarObj != null && !String.isBlank(oscarObj.Type_of_change__c) && oscarObj.Type_of_change__c.indexOf(AMS_Utils.Location) >= 0;
        }
        set;
    }
    /*** AMSU-121 End ***/

    public static final Set<String> notEditableForNEWGEN = new Set<String>{'Location_Class__c','Location_Type__c','CASS_Number__c','Abbreviated_Address__c','Abbreviated_name__c'};


    // The extension constructor initializes the private member
    // variable oscarObj by using the getRecord method from the standard
    // controller.
    public AMS_OSCAR_Case_Detail_Controller() {

        this.objectId = ApexPages.currentPage().getParameters().get('id');

        if(objectId == null) return;

        this.oscarObj = fetchOscarFields(objectId, isObjectCase(objectId));

        if(this.oscarObj != null && this.oscarObj.AMS_Online_Accreditation__c != null){
            this.accreditationObj = fetchAccreditationFields(this.oscarObj.AMS_Online_Accreditation__c);
            this.isCargoAgency = AMS_Utils.LocationClassDGR.contains(accreditationObj.Location_Class__c);
            this.isCertificationOSCAR = oscarObj.Process__c == AMS_Utils.CERTIFICATION;
            this.isNewGenProcess = AMS_Utils.oscarNewGenProcesses.contains(oscarObj.Process__c);
 
        }else{
            System.debug('## Could not fetch any Oscar or does not have an accreditation object');
        }
        
        this.showStagingArea = (oscarObj.Process__c != AMS_Utils.NGCHINACONVERSION);

        this.accountHierarchyRelationships = AMS_HierarchyHelper.getAccountsHierarchies(new Set<Id>{oscarObj.Account__c});

        for (AMS_Agencies_relationhip__c relationship : this.accountHierarchyRelationships.get(oscarObj.Account__c)) {

            if(oscarObj.Process__c == AMS_Utils.NGCHINACONVERSION){
                hierarchyAccountIds.add(relationship.Parent_Account__c);
                hierarchyAccountIds.add(relationship.Child_Account__c);
            }
            
            if(relationship.Parent_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Parent_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && relationship.Parent_Account__r.Status__c != '' ){
                hierarchyAccountsMap.put(relationship.Parent_Account__c, new Account(id = relationship.Parent_Account__c, Status__c = relationship.Parent_Account__r.Status__c));
            }
            if(relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S0_TERMINATED && relationship.Child_Account__r.Status__c != AMS_Utils.ACC_S1_NOTACCREDITED && relationship.Child_Account__r.Status__c != '' ){
                hierarchyAccountsMap.put(relationship.Child_Account__c, new Account(id = relationship.Child_Account__c, Status__c = relationship.Child_Account__r.Status__c));
            }

        }

        Integer pendingCases = 0;

        if(oscarObj.Process__c == AMS_Utils.NGCHINACONVERSION){

            //Just in case there is a single agency in the hierachy
            hierarchyAccountIds.add(oscarObj.Account__c);
        
            pendingCases = 
                [SELECT 
                    COUNT() 
                 FROM
                    Case
                 WHERE
                     AccountId IN :hierarchyAccountIds 
                 AND RecordType.DeveloperName = 'OSCAR_Communication' 
                 AND Status NOT IN ('Closed_ Not Accepted', 'Closed_Rejected', 'Closed_Withdrawn', 'Closed')
                ];
        }

        if(oscarObj.Process__c == AMS_Utils.NGCHINACONVERSION && pendingCases > 1){
            ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.WARNING, Label.ANG_OnGoing_OSCAR_Warning));
        }

    }

    private AMS_Pax_Accreditation_Form__c fetchAccreditationFields(Id accreditationId){

         /*List<AMS_Pax_Accreditation_Form__c> accreditationLst = [select Id, Account_Name__c,IATACode__c,ISSP_AMS_Legal_Status__c,Short_Name__c,
                Location_Class__c,Location_Type__c,TradeName__c,ISSP_AMS_License_No__c,ISSP_AMS_VAT_number__c,ISSP_AMS_GDS_with_signed_contract__c,
                Branch_Office_Country__c,Branch_Office_Country__r.Name,Branch_Office_Street_name_number__c,Branch_Office_Postal_code__c,Billing_State__c,
                Branch_Office_City__c,ISO_Country__c,IATA_ISO_State__c,Shipping_Country__c,Shipping_Street__c,Shipping_Postal_Code__c,Shipping_State__c,
                Shipping_City__c,Branch_Office_Email__c,Website__c,Branch_Office_Phone__c,Branch_Office_FAX__c,ISSP_AMS_Premises_located_at_airport__c,
                Mobile__c,Abbreviated_name__c,Abbreviated_Address__c,Remittance_frequency__c,Solicitation_Flag__c,VAT_Number_2__c,CASS_Number__c,
                IATA_ISO_State__r.Name,ISO_Country__r.Name, Ready_for_Accreditation__c, Trade_Name__c, Shipping_ISO_Country__c, Shipping_ISO_State__c //DT: Added 2 new fields
                from AMS_Pax_Accreditation_Form__c where Id = :accreditationId];*/

        //query is done using the same fields that will appear on the page
        List<AMS_Pax_Accreditation_Form__c> accreditationLst = Database.query('SELECT Id, '+String.join(accreditationFieldNames, ', ')+' FROM AMS_Pax_Accreditation_Form__c WHERE Id = :accreditationId');

        if(accreditationLst.isEmpty()) return null;

        return accreditationLst.get(0);
    }


    private Boolean isObjectCase(Id objectToFind){
        return AMS_Utils.findObjectNameFromRecordIdPrefix(objectToFind).equalsIgnoreCase('CASE');
    }
    
    private AMS_OSCAR__c fetchOscarFields(Id objectId, Boolean isFromCase){

        Id idToSearch = null;

        if(!isFromCase) idToSearch = objectId;
        else{
            List<Case> cases = [select Id, OSCAR__c from CASE where id = :objectId LIMIT 1];

            if(cases.isEmpty()) System.debug('Did not find any OSCAR object using Id ' + objectId + ' and with case flag as ' + isFromCase);
            else idToSearch = cases.get(0).OSCAR__c;
        }
        
        if(idToSearch == null) return null;

        List<AMS_OSCAR__c> oSCARs = [SELECT Change_Code__c,Invoice_number__c,Process_Start_Date__c,Invoice_Requested__c,Operational_Systems_Updated__c,New_docs_Received__c,
                        Fees_refund_requested__c,Dossier_Validation__c,Welcome_Pack_Sent__c,status__c,Documentation_Compliant__c,Proof_of_payment_received__c,
                        Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_requested__c,Bank_Guarantee_deadline__c,
                        Bank_Guarantee_received__c,Bank_Guarantee_amount__c,Local_Inspection_requested__c,Local_Inspection_deadline__c,
                        Local_Inspection_received__c,Local_Inspection_compliant__c,PSAA_EACP_Agreement_received__c,Criteria_remarks__c,Bank_Guarantee_time__c,
                        Out_of_deadline_SAAM__c,OSCAR_Deadline__c,Dossier_Reception_Date__c,OwnerId,CNS_process__c ,
                        Owner.Phone,Owner.Email,Owner.Name,CreatedBy.Name,Owner.UserRole.Name,LastModifiedBy.Name,Contact_Name__c,Contact_Phone__c,Contact_Email__c,
                        createdDate,Date_Time_Closed__c,RecordTypeId,Account__r.IATA_ISO_Country__r.Region__c, Account__r.Sector__c,
                        Account__r.IATA_ISO_Country__r.Name,AMS_Online_Accreditation__c,Account__c,Account__r.Name,Process__c, Type_of_change__c, Account__r.ANG_IsNewGenAgency__c, 
                        ANG_Type_of_change__c, Account__r.Top_Parent__r.Remittance_Frequency__c,
                        AMS_Target_Agency__c, Account__r.Is_Branch_Abroad__c, STEP6__c, //FM AMSU-1
                        Account__r.IATA_ISO_Country__r.ISO_Code__c, Location_Class__c, Account__r.Location_Class__c //AMSU-151 
                        FROM AMS_OSCAR__c where id = :idToSearch LIMIT 1];

        if(oSCARs.isEmpty()) return null;

        return OSCARs.get(0);
    }

    public Boolean getExistOscarInspections(){

        if(this.oscarObj == null) return false;
            
        Id oscarId=  this.oscarObj.Id;
        if (AMS_Utils.isProcessUsingAppointments(this.oscarObj) && database.countQuery('select count() from AMS_Inspection__c where oscar__c = : oscarId') == 0) {   
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, Label.AMS_OSCAR_Warning_1));
            return false;
        }

       return true;
    }

    public void save(){
        try{
            List<String> values;

            if(accreditationObj != null){ 

                if(rightOptionsRF != null && rightOptionsRF.size()>2){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The maximum amount of allowed values for Remmitance Frequency is 2.')); 
                    displayErrorMsg = true;
                    rightOptionsRF = null; // force repopulation 
                }else if(rightOptionsRF != null){    
                    values = new List<String>();
                    for (SelectOption o :rightOptionsRF){
                        values.add(o.getValue());
                        accreditationObj.Remittance_frequency__c = String.Join(values,';');
                    }            
                    update accreditationObj;
                }else{
                    update accreditationObj;          
                    this.saveAction = true;
                }
            }

        }catch(Exception e){
                if(!e.getMessage().contains('FIELD_CUSTOM_VALIDATION_EXCEPTION, CASS Number')){
                    accreditationObj.addError('An error occured trying to save Accreditation Object, reason:' + e);
                }
        }
    } 

    public void cancel(){
        this.saveAction = true;
    } 


    public class FormField {
        public String name { get; set; }
        public String styleClass { get; set; }
        public String event { get; set; }
        public Boolean inlineEdit { get; set; }
        public Boolean rendered { get; set; }

        public FormField(String name, Boolean inlineEdit, Boolean rendered){
            this.name = name;
            this.inlineEdit = inlineEdit;
            this.rendered = rendered;

            System.debug(loggingLevel.FINEST, '____ [cls AMS_OSCAR_Case_Detail_Controller - new FormField] name - ' + name);
            System.debug(loggingLevel.FINEST, '____ [cls AMS_OSCAR_Case_Detail_Controller - new FormField] inlineEdit - ' + inlineEdit);

            this.styleClass = (inlineEdit ? 'editable' : '');
            if(name == 'Branch_Office_Country__c') this.styleClass += ' branchOffice';
            if(name == 'IATA_ISO_State__c') this.styleClass += ' isoState';
            //when adding new classes, dont forget the space in front *wink*

            //FM AMSU-1        
            if(name == 'ISSP_AMS_VAT_number__c') this.styleClass += ' vatNumber';
            if(name == 'VAT_Number_2__c') this.styleClass += ' vatNumber2';
            
            this.event = 'ondblClick';
            if(name == 'Branch_Office_Country__c') this.event = 'onclick';
            if(name == 'IATA_ISO_State__c') this.event = 'onclick';
        }
    }

}