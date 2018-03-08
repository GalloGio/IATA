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
    public Boolean isNewAE{get{return (oscarObj.Process__c == AMS_Utils.NEWAE);}set;}
    public Boolean displayErrorMsg{get{return false;} set;}

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

    public static Set<String> hidenFieldsNewgenApplications = new Set<String>{'Abbreviated_name__c','Abbreviated_Address__c'};

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
            if(oscarObj != null && oscarObj.Type_of_change__c != null) editableFields = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(oscarObj.Type_of_change__c);
            if(oscarObj != null && oscarObj.ANG_Type_of_change__c != null) editableFields = ANG_AgencyChangesConfigHelper.getFieldsToMigrate(oscarObj.ANG_Type_of_change__c);

            System.debug(loggingLevel.FINEST, '____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] editableFields - ' + editableFields);

            return editableFields;
        }
        private set;
    }

    private Boolean isEditable(String fieldName){

        //For newgen
        if(this.oscarObj.Account__r.ANG_IsNewGenAgency__c)
            if(notEditableForNEWGEN.contains(fieldName))
                return false;

        //verifu "hardcoded" logic
        if(fieldName == 'IATACode__c') return false;
        //if(fieldName == 'Location_Class__c' && isNewGenProcess) return false;
        //if(fieldName == 'Location_Type__c' && isNewGenProcess) return false;
        if(fieldName == 'ANG_Accreditation_Type__c' && isNewGenProcess && !isAgencyChanges) return false;
        if(fieldName == 'Remittance_frequency__c' && isNewGenProcess && oscarObj.Process__c == AMS_Utils.NEWAE) return false;     
        if(!isAgencyChanges) return true;     

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

    //private Set<String> tocList{
    //    get{
    //        tocList = new Set<String>();

    //        if(oscarObj.ANG_Type_Of_Change__c != null) tocList.addAll(oscarObj.ANG_Type_Of_Change__c.split(';'));

    //        return tocList;
    //    }
    //    set;
    //}

    private List<AMS_Operation__c> operationCodes{
        get{
            if(this.operationCodes == null)
                this.operationCodes = ANG_AgencyChangesHelper.fetchOperationCodeConfiguration(AMS_Utils.getRecordType('AMS_Settlement_System__c','BSP').Id, accreditationObj.Branch_Office_Country__c, accreditationObj.Location_Class__c);

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
        return !String.isBlank(oscar.Process__c) && locationsClass.contains(oscar.Location_Class__c) && (AMS_Utils.oscarNewProcesses.contains(oscar.Process__c) || oscar.Process__c == AMS_Utils.AGENCYCHANGES);
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
                }else if((oscarObj.Process__c == AMS_Utils.NGCHANGES || oscarObj.Process__c == AMS_Utils.NGCORRECTION) && isEditable('Remittance_frequency__c')) {

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
                    rfPicklistValues.add(new SelectOption(attribute.Remittance_Frequency__c, attribute.Remittance_Frequency__c));
                }
            }
        }
        return rfPicklistValues;
    }


    public Boolean isAgencyChanges{
        get{
            if(oscarObj != null && (oscarObj.Process__c == AMS_Utils.AGENCYCHANGES  || oscarObj.Process__c == AMS_Utils.NGCHANGES || oscarObj.Process__c == AMS_Utils.NGCORRECTION)) return true;
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

    public List<FormField> accreditationFields{
        get{
            accreditationFields = new List<FormField>();
            for(String fieldName : accreditationFieldNames){
                accreditationFields.add(new FormField(fieldName, isEditable(fieldName), isRendered(fieldName)));
            }
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
                        ANG_Type_of_change__c, Account__r.Top_Parent__r.Remittance_Frequency__c, STEP6__c, Location_Class__c from AMS_OSCAR__c where id = :idToSearch LIMIT 1];

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
                accreditationObj.addError('An error occured trying to save Accreditation Object, reason:' + e);
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

            this.event = 'ondblClick';
            if(name == 'Branch_Office_Country__c') this.event = 'onclick';
            if(name == 'IATA_ISO_State__c') this.event = 'onclick';
        }
    }

}