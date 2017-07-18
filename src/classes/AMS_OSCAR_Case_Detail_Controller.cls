public with sharing class AMS_OSCAR_Case_Detail_Controller {


    public AMS_OSCAR__c oscarObj { get; set; }
    public AMS_Pax_Accreditation_Form__c accreditationObj { get; set; }

    public Boolean saveAction { get; set; }
    public Boolean isCargoAgency{get;set;}
    public Boolean isCertificationOSCAR{get;set;}
    public Boolean isNewGenProcess{get;set;}

    public Id objectId { get; set; }

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
                , AMS_Pax_Accreditation_Form__c.Solicitation_Flag__c
                , AMS_Pax_Accreditation_Form__c.VAT_Number_2__c 
                , AMS_Pax_Accreditation_Form__c.Link_agent_name__c
                , AMS_Pax_Accreditation_Form__c.Is_your_firm_handling_Dangerous_Goods__c
                , AMS_Pax_Accreditation_Form__c.ANG_IsNewGenAgency__c
            };
        }
    }

    public List<String> accreditationFieldNames {
        get{
            if(accreditationFieldNames == null){
                accreditationFieldNames = new List<String>();
                for(Schema.SObjectField field : accreditationFieldList) accreditationFieldNames.add(field.getDescribe().getName());
            }
            return accreditationFieldNames;
        }
        set;
    }

    private Set<String> editableFields{
        get{
            editableFields = new Set<String>();
            if(oscarObj != null && oscarObj.Type_of_change__c != null) editableFields = AMS_AgencyChangesConfigHelper.getFieldsToMigrate(oscarObj.Type_of_change__c);

            System.debug(loggingLevel.FINEST, '____ [cls AMS_OSCAR_Case_Detail_Controller - getEditableFields] editableFields - ' + editableFields);

            return editableFields;
        }
        private set;
    }

    private Boolean isEditable(String fieldName){

        //verifu "hardcoded" logic
        if(fieldName == 'IATACode__c') return false;
        if(!isAgencyChanges) return true;        

        //check per field
        return editableFields.contains(fieldName);
    }

    private Boolean isRendered(String fieldName){
        if(fieldName == 'Is_your_firm_handling_Dangerous_Goods__c') return isCargoAgency;
        if(fieldName == 'CASS_Number__c') return !isNewGenProcess;
        if(fieldName == 'SAAM_Case__c') return isNewGenProcess;

        return true;
    }

    public Boolean isAgencyChanges{
        get{
            if(oscarObj != null && oscarObj.Process__c == AMS_Utils.AGENCYCHANGES) return true;
            else return false;
        }
        private set;
    }

    public List<FormField> accreditationFields{
        get{
            accreditationFields = new List<FormField>();
            for(String fieldName : accreditationFieldNames) accreditationFields.add(new FormField(fieldName, isEditable(fieldName), isRendered(fieldName)));
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
            System.debug('Could not fetch any Oscar or does not have an accreditation object');
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
                        Account__r.IATA_ISO_Country__r.Name,AMS_Online_Accreditation__c,Account__c,Account__r.Name,Process__c, Type_of_change__c from AMS_OSCAR__c where id = :idToSearch LIMIT 1];

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
            
            if(accreditationObj != null){
                update accreditationObj;
            }

            this.saveAction = true;

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