public with sharing class AMS_OSCAR_Case_Detail_Controller {


    public AMS_OSCAR__c oscarObj{get;set;}

    public AMS_Pax_Accreditation_Form__c accreditationObj{get;set;}

    public boolean hasCase{get;set;}

    public boolean saveAction{get;set;}

    public Id objectId{get;set;}

    // The extension constructor initializes the private member
    // variable oscarObj by using the getRecord method from the standard
    // controller.
    public AMS_OSCAR_Case_Detail_Controller() {
        this.objectId = ApexPages.currentPage().getParameters().get('id');

        if(objectId == null)
            return;

        this.oscarObj = fetchOscarFields(objectId, isObjectCase(objectId));

        if(this.oscarObj != null && this.oscarObj.AMS_Online_Accreditation__c != null){
            this.accreditationObj = fetchAccreditationFields(this.oscarObj.AMS_Online_Accreditation__c);

        }else{
            System.debug('Could not fetch any Oscar or does not have an accreditation object');
        }

    }

    public AMS_OSCAR_Case_Detail_Controller(ApexPages.StandardController std) {

        this.objectId = ApexPages.currentPage().getParameters().get('id');

        if(objectId == null)
            return;

        this.oscarObj = fetchOscarFields(objectId, isObjectCase(objectId));

        if(this.oscarObj != null && this.oscarObj.AMS_Online_Accreditation__c != null){
            this.accreditationObj = fetchAccreditationFields(this.oscarObj.AMS_Online_Accreditation__c);

        }else{
            System.debug('Could not fetch any Oscar or does not have an accreditation object');
        }

    }

    private AMS_Pax_Accreditation_Form__c fetchAccreditationFields(Id accreditationId){

         List<AMS_Pax_Accreditation_Form__c> accreditationLst = [select Id, Account_Name__c,IATACode__c,ISSP_AMS_Legal_Status__c,Short_Name__c,
                Location_Class__c,Location_Type__c,TradeName__c,ISSP_AMS_License_No__c,ISSP_AMS_VAT_number__c,ISSP_AMS_GDS_with_signed_contract__c,
                Branch_Office_Country__c,Branch_Office_Country__r.Name,Branch_Office_Street_name_number__c,Branch_Office_Postal_code__c,Billing_State__c,
                Branch_Office_City__c,ISO_Country__c,IATA_ISO_State__c,Shipping_Country__c,Shipping_Street__c,Shipping_Postal_Code__c,Shipping_State__c,
                Shipping_City__c,Branch_Office_Email__c,Website__c,Branch_Office_Phone__c,Branch_Office_FAX__c,ISSP_AMS_Premises_located_at_airport__c,
                Mobile__c,Abbreviated_name__c,Abbreviated_address__c,Remittance_frequency__c,Solicitation_Flag__c,VAT_Number_2__c,CASS_Number__c,
                IATA_ISO_State__r.Name,ISO_Country__r.Name, Ready_for_Accreditation__c, Trade_Name__c, Shipping_ISO_Country__c, Shipping_ISO_State__c //DT: Added 2 new fields
                from AMS_Pax_Accreditation_Form__c where Id = :accreditationId];

        if(accreditationLst.size() > 0){
            return accreditationLst.get(0);
        }
        System.debug('Did not find any accreditation object using Id ' + accreditationId);

        return null;
    }


    private boolean isObjectCase(Id objectToFind){
        return AMS_Utils.findObjectNameFromRecordIdPrefix(objectToFind).equalsIgnoreCase('CASE');
    }
    
    private AMS_OSCAR__c fetchOscarFields(Id objectId, Boolean isFromCase){

        Id idToSearch = null;

        if(isFromCase){
            List<Case> cases = [select Id, OSCAR__c from CASE where id = :objectId LIMIT 1];

            if(!cases.isEmpty())
                idToSearch = cases.get(0).OSCAR__c;
        }
        else
            idToSearch = objectId;

        if(idToSearch == null){
            System.debug('Did not find any OSCAR object using Id ' + objectId + ' and with case flag as ' + isFromCase);
            return null;
        }

        List<AMS_OSCAR__c> oSCARs = [SELECT Change_Code__c,Invoice_number__c,Process_Start_Date__c,Invoice_Requested__c,Operational_Systems_Updated__c,New_docs_Received__c,
                        Fees_refund_requested__c,Dossier_Validation__c,Welcome_Pack_Sent__c,status__c,Documentation_Compliant__c,Proof_of_payment_received__c,
                        Financial_Assessment_requested__c,Financial_Assessment_deadline__c,Bank_Guarantee_requested__c,Bank_Guarantee_deadline__c,
                        Bank_Guarantee_received__c,Bank_Guarantee_amount__c,Local_Inspection_requested__c,Local_Inspection_deadline__c,
                        Local_Inspection_received__c,Local_Inspection_compliant__c,PSAA_EACP_Agreement_received__c,Criteria_remarks__c,Bank_Guarantee_time__c,
                        Out_of_deadline_SAAM__c,OSCAR_Deadline__c,Dossier_Reception_Date__c,OwnerId, RecordType.DeveloperName, RecordType.Name, 
                        Owner.Phone,Owner.Email,Owner.Name,CreatedBy.Name,Owner.UserRole.Name,LastModifiedBy.Name,Contact_Name__c,Contact_Phone__c,Contact_Email__c,
                        createdDate,Date_Time_Closed__c,RecordTypeId,Account__r.IATA_ISO_Country__r.Region__c,
                        Account__r.IATA_ISO_Country__r.Name,AMS_Online_Accreditation__c,Account__c,Account__r.Name,Process__c from AMS_OSCAR__c where id = :idToSearch LIMIT 1];

        if(oSCARs.size() > 0){
            return OSCARs.get(0);
        }

        return null;

    }
     public Boolean getExistOscarInspections(){

        if(this.oscarObj == null)
            return false;
            
        Id oscarId=  this.oscarObj.Id;
        if (AMS_Utils.oscarProcessesWithAppointments.contains(this.oscarObj.Process__c) 
               && 
            database.countQuery('select count() from AMS_Inspection__c where oscar__c = : oscarId') == 0 
            ) 
        {   
            ApexPages.Message errMsg = new ApexPages.Message(ApexPages.Severity.WARNING, Label.AMS_OSCAR_Warning_1);
            ApexPages.addMessage(errMsg);
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

        return;
    } 

    public void cancel(){

        this.saveAction = true;
        
        return;
    } 



}