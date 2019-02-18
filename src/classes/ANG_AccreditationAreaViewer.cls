global with sharing class ANG_AccreditationAreaViewer {
    
    public Set<String> ahdocComparisonFields = new Set<String>{'ISSP_AMS_Legal_Status__c','ISSP_AMS_GDS_with_signed_contract__c','ISSP_AMS_Premises_located_at_airport__c'};

    public Map<String,String> changedFieldsSet{get;set;}

    public Id existingOscarCaseId{get;set;}

    public String existingOscarCaseNumber{get;set;}

    public Set<String> notes{
            get{
                            
                            notes = new Set<String>();
                            notes.add('This is the Staging Area for the Account ' + accreditationObj.HO_Account__r.IATACODE__c);
                            notes.add('You can create an Oscar Changes process by clicking the button below.');
                            notes.add('The Oscar Process will clone this accreditation area and will create a new Oscar/Case to be processed, attached to this account.');

                    return notes;
            }
            set;
    }
    public boolean doNotHaveOscarYet{
        get{
                List<AMS_Pax_Accreditation_Form__c> paxLst = [Select Id, HO_Account__r.IATACODE__c, HO_Account__c, SAAM_Case__c, SAAM_Case__r.Casenumber from AMS_Pax_Accreditation_Form__c where HO_Account__c = :this.accreditationObj.HO_Account__c and Id != :this.accreditationObj.Id and SAAM_Case__r.ParentId = :this.accreditationObj.SAAM_Case__c ];

                if(!paxLst.isEmpty()){
                    existingOscarCaseId = paxLst.get(0).SAAM_Case__c;
                    existingOscarCaseNumber = paxLst.get(0).SAAM_Case__r.Casenumber;
                }

                return paxLst.isEmpty();
        }
        set;
    }

    public List<String> noteList{
        get{
                return new List<String>(notes);
        }
        set;
    }

    public Account accreditationAccount{
        get{

            if(this.accreditationAccount == null){
                this.accreditationAccount = fetchAccountFields(this.accreditationObj.HO_Account__c);
            }
                return this.accreditationAccount;
        }
        set;
    }

    public AMS_Pax_Accreditation_Form__c accreditationObj { get; set; }

    public Map<String, String> fieldsMapping{
        get{
            if(this.fieldsMapping == null){
                this.fieldsMapping  = new Map<String, String> { 'Account_Name__c'=>    'Name' 
                                                                ,'IATACode__c' => 'IATACode__c' 
                                                                ,'Short_Name__c' => 'Short_Name__c' 
                                                                ,'Trade_Name__c' => 'TradeName__c' 
                                                                ,'ISSP_AMS_License_No__c' => 'License_Number__c' 
                                                                ,'ISSP_AMS_VAT_number__c' => 'VAT_Number__c' 
                                                                ,'Branch_Office_Street_name_number__c' => 'BillingStreet' 
                                                                ,'Website__c' => 'Website' 
                                                                ,'Branch_Office_Postal_code__c' => 'BillingPostalCode' 
                                                                ,'Branch_Office_City__c' => 'BillingCity' 
                                                                ,'Branch_Office_Country__c' => 'IATA_ISO_Country__c' 
                                                                ,'IATA_ISO_State__c' => 'Iso_State__c' 
                                                                ,'Shipping_Street__c' => 'ShippingStreet' 
                                                                ,'Shipping_Postal_Code__c' => 'ShippingPostalCode' 
                                                                ,'Branch_Office_Email__c' => 'Email__c' 
                                                                ,'Branch_Office_Phone__c' => 'Phone' 
                                                                ,'Branch_Office_FAX__c' => 'Fax' 
                                                                ,'Shipping_City__c' => 'ShippingCity' 
                                                                ,'Operation__c' => 'Operation__c' 
                                                                ,'Abbreviated_name__c' => 'Abbreviated_name__c' 
                                                                ,'Abbreviated_Address__c' => 'Abbreviated_address__c' 
                                                                ,'Remittance_frequency__c' => 'Remittance_frequency__c' 
                                                                ,'Solicitation_Flag__c' => 'Solicitation_Flag__c' 
                                                                ,'VAT_Number_2__c' => 'VAT_Number_2__c' 
                                                                ,'CASS_Number__c' => 'CASS_Number__c' 
                                                                ,'Location_Class__c' => 'Location_Class__c' 
                                                                ,'Location_Type__c' => 'Location_Type__c' 
                                                                ,'Mobile__c' => 'Mobile__c' 
                                                                ,'Is_your_firm_handling_Dangerous_Goods__c' => 'Is_your_firm_handling_Dangerous_Goods__c' 
                                                                ,'Shipping_ISO_Country__c' => 'IATA_ISO_Shipping_Country__c' 
                                                                ,'Shipping_ISO_State__c' => 'IATA_ISO_Shipping_State__c' 
                                                                ,'Link_agent_name__c' => 'Link_agent_name__c'
                                                                ,'VAT_Number_2__c' => 'VAT_Number_2__c'
                                                                ,'ANG_Accreditation_type__c' => 'ANG_Accreditation_Model__c'
                                                                ,'ISSP_AMS_GDS_with_signed_contract__c' => 'GDS__c'
                                                                ,'ISSP_AMS_Legal_Status__c' => 'Company_Type__c'
                                                                ,'Shipping_Country__c' => 'ShippingCountry'
                                                                ,'Shipping_State__c' => 'ShippingState'

        };
            }
            return this.fieldsMapping;

        }
            set;
        }

    public static List<String> fieldsAccContacts = new List<String>{'First_Name__c','Last_Name__c','Email__c','Phone__c','Agency_owner__c','Agency_role__c','Authorised_signatory__c','Financial_Assessment_Contact__c','Portal_administrator__c','Salutation__c','Mobile__c','FAX__c','Financial_interest__c','Time_devoted_to_Agency_business__c','Date_joined_agency__c','Job_title__c','AddressStreet__c','AddressCity__c','AddressPostCode__c','AddressCountry__c'};


/*
        //using Schema to avoid typos on field Names
    private List<Schema.SObjectField> fieldsAccContacts{
        get{
            return new List<Schema.SObjectField>{
                  AMS_Accreditation_Contact__c.First_Name__c
                , AMS_Accreditation_Contact__c.Last_Name__c
                , AMS_Accreditation_Contact__c.Email__c
                , AMS_Accreditation_Contact__c.Phone__c
                , AMS_Accreditation_Contact__c.Agency_owner__c
                , AMS_Accreditation_Contact__c.Agency_role__c
                , AMS_Accreditation_Contact__c.Authorised_signatory__c
                , AMS_Accreditation_Contact__c.Financial_Assessment_Contact__c
                , AMS_Accreditation_Contact__c.Portal_administrator__c
                , AMS_Accreditation_Contact__c.Salutation__c
                , AMS_Accreditation_Contact__c.Mobile__c
                , AMS_Accreditation_Contact__c.FAX__c
                , AMS_Accreditation_Contact__c.Financial_interest__c
                , AMS_Accreditation_Contact__c.Time_devoted_to_Agency_business__c
                , AMS_Accreditation_Contact__c.Date_joined_agency__c
                , AMS_Accreditation_Contact__c.Job_title__c
                , AMS_Accreditation_Contact__c.AddressStreet__c
                , AMS_Accreditation_Contact__c.AddressCity__c
                , AMS_Accreditation_Contact__c.AddressPostCode__c
                , AMS_Accreditation_Contact__c.AddressCountry__c
            };
        }
    }
*/
    public Map<String,boolean> accountFieldsMapping{
        get{
            if(accountFieldsMapping == null){

                accountFieldsMapping = new Map<String,boolean>();

                for(Schema.SObjectField field : accreditationFieldList) {
            
                    if(fieldsMapping.get(field.getDescribe().getName()) <> null){

                        accountFieldsMapping.put(field.getDescribe().getName(),true);
                  
                    }else{
                        accountFieldsMapping.put(field.getDescribe().getName(),false);
                    }
        }

            }
            return accountFieldsMapping;

        }
        set;
    }

    public List<ANG_AccreditationAreaViewer.AccreditationContact> accreditationContactFormList{

        get {
            if(accreditationContactFormList == null )
                accreditationContactFormList = fetchAccreditationContacts();

                System.debug('accreditationContactFormList is:'+accreditationContactFormList);
                return accreditationContactFormList;
            }

        set;

    }

    public ANG_AccreditationAreaViewer(ApexPages.StandardController stdController) {
        
        //Id objectId = ApexPages.currentPage().getParameters().get('id');

        this.accreditationObj = (AMS_Pax_Accreditation_Form__c)stdController.getRecord();

        this.accreditationObj = fetchAccreditationFields(this.accreditationObj.Id);

        compareAccreditationWithAccount();

    }

    public List<String> accreditationFields{
        get{
            accreditationFields = new List<String>();
            for(String fieldName : accreditationFieldNames){
                accreditationFields.add(fieldName);
            }
            return accreditationFields;
        }
        private set;
    }

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

    private AMS_Pax_Accreditation_Form__c fetchAccreditationFields(Id accreditationId){

        //query is done using the same fields that will appear on the page

        List<AMS_Pax_Accreditation_Form__c> accreditationLst = Database.query('SELECT Id, HO_Account__r.IATACODE__c,Confirm_Ownership_details_are_correct__c, '+String.join(accreditationFieldNames, ', ')+' FROM AMS_Pax_Accreditation_Form__c WHERE Id = :accreditationId');

        if(accreditationLst.isEmpty()) return null;

        return accreditationLst.get(0);
    }


        //using Schema to avoid typos on field Names
    private List<Schema.SObjectField> accreditationFieldList{
        get{
            return new List<Schema.SObjectField>{
                  AMS_Pax_Accreditation_Form__c.Name
                , AMS_Pax_Accreditation_Form__c.Account_Name__c
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
                , AMS_Pax_Accreditation_Form__c.Branch_Office_City__c
                , AMS_Pax_Accreditation_Form__c.IATA_ISO_State__c
                , AMS_Pax_Accreditation_Form__c.Shipping_Street__c
                , AMS_Pax_Accreditation_Form__c.Shipping_Postal_Code__c
                , AMS_Pax_Accreditation_Form__c.Shipping_ISO_Country__c
                , AMS_Pax_Accreditation_Form__c.Shipping_Country__c
                , AMS_Pax_Accreditation_Form__c.Shipping_ISO_State__c
                , AMS_Pax_Accreditation_Form__c.Shipping_State__c
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
                , AMS_Pax_Accreditation_Form__c.VAT_Number_2__c 
                , AMS_Pax_Accreditation_Form__c.Is_your_firm_handling_Dangerous_Goods__c
                , AMS_Pax_Accreditation_Form__c.ANG_IsNewGenAgency__c
                , AMS_Pax_Accreditation_Form__c.ANG_Accreditation_type__c
                , AMS_Pax_Accreditation_Form__c.HO_Account__c
            };
        }
    }

    private Account fetchAccountFields(String accountId){

        if(accountId == null)
            return null;

        List<String> fieldList = new List<String>();

        Map<String, Schema.SObjectField> schemaFieldMap = Account.sObjectType.getDescribe().fields.getMap();

        for (String field : schemaFieldMap.keySet()){
                fieldList.add(field);
        }

        return Database.query('SELECT '+String.join(fieldList, ', ')+' FROM Account WHERE Id = :accountId LIMIT 1');

    }

    private void compareAccreditationWithAccount(){

        if(changedFieldsSet == null){

            changedFieldsSet = new Map<String,String>();
        }

        for(Schema.SObjectField field : accreditationFieldList) {
            
            if(ahdocComparisonFields.contains(field.getDescribe().getName())){

                if(field.getDescribe().getName() == 'ISSP_AMS_Legal_Status__c'){
                    if(accreditationAccount.Company_Type__c == AMS_Utils.transformCompanyType(accreditationObj.ISSP_AMS_Legal_Status__c))
                        changedFieldsSet.put(field.getDescribe().getName(),'BLANK');
                    else
                        changedFieldsSet.put(field.getDescribe().getName(),'CHANGED');

                }
                else if(field.getDescribe().getName() == 'ISSP_AMS_GDS_with_signed_contract__c'){
                    if(accreditationAccount.GDS__c == AMS_Utils.transformGDS(accreditationObj.ISSP_AMS_GDS_with_signed_contract__c))
                        changedFieldsSet.put(field.getDescribe().getName(),'BLANK');
                    else
                        changedFieldsSet.put(field.getDescribe().getName(),'CHANGED');
                }
                else if(field.getDescribe().getName() == 'ISSP_AMS_Premises_located_at_airport__c'){
                    Boolean boolValue = accreditationObj.ISSP_AMS_Premises_located_at_airport__c == 'Yes' ? true : false;
                    if(accreditationAccount.In_a_Airport__c == boolValue)
                        changedFieldsSet.put(field.getDescribe().getName(),'BLANK');
                    else
                        changedFieldsSet.put(field.getDescribe().getName(),'CHANGED');
                }

            }else if(fieldsMapping.get(field.getDescribe().getName()) <> null){

                if(this.accreditationObj.get(field) <> this.accreditationAccount.get(fieldsMapping.get(field.getDescribe().getName()))){
                    changedFieldsSet.put(field.getDescribe().getName(),'CHANGED');
                }
                else{
                    changedFieldsSet.put(field.getDescribe().getName(),'BLANK');
                }
            }else{
                    changedFieldsSet.put(field.getDescribe().getName(),'BLANK');
            }
        }


        System.debug('changedFieldsSet is ' +  changedFieldsSet);
    }

    public List<ANG_AccreditationAreaViewer.AccreditationContact> fetchAccreditationContacts(){
        
        List<ANG_AccreditationAreaViewer.AccreditationContact> accreditationContactFormListOut = new List<ANG_AccreditationAreaViewer.AccreditationContact>();

        Map<String,AMS_Accreditation_Contact__c> oldContactsMap = new Map<String,AMS_Accreditation_Contact__c>();

        List<AMS_Accreditation_Contact__c> accreditationContactLst = Database.query('SELECT Id, RecordType.DeveloperName , AMS_ContactId__c, ' + String.join(fieldsAccContacts, ', ')+' FROM AMS_Accreditation_Contact__c  WHERE AMS_Pax_Accreditation_Form__c = ' + '\'' + this.accreditationObj.Id + '\'');

        for(AMS_Accreditation_Contact__c ac: accreditationContactLst){
            if(!(ac.RecordType.DeveloperName == 'Current_Company_Owner' || ac.RecordType.DeveloperName == 'Current_Owner'))
                oldContactsMap.put(ac.AMS_ContactId__c, ac);
        }

        for(AMS_Accreditation_Contact__c ac: accreditationContactLst){
            if(ac.RecordType.DeveloperName == 'Current_Company_Owner' || ac.RecordType.DeveloperName == 'Current_Owner'){
                accreditationContactFormListOut.add(new ANG_AccreditationAreaViewer.AccreditationContact(ac,ac.AMS_ContactId__c == null, oldContactsMap.get(ac.AMS_ContactId__c)));
            }
        }

        return accreditationContactFormListOut;
    }

    global class AccreditationContact{
    
        public AMS_Accreditation_Contact__c ac{get;set;}
        public Boolean isNew{get;set;}
        public AMS_Accreditation_Contact__c previousAC{get;set;}
        public Map<String,Boolean> changedFieldsMap{get;set;}

        public AccreditationContact(AMS_Accreditation_Contact__c ac, Boolean isNew,AMS_Accreditation_Contact__c previousAC ){
            this.ac = ac;
            this.isNew = isNew;
            this.previousAC = previousAC;
            
            changedFieldsMap = compareAccreditations(ac,previousAC,isNew);
        }

        public Map<String,Boolean> compareAccreditations(AMS_Accreditation_Contact__c ac,AMS_Accreditation_Contact__c previousAC, Boolean isNew){

            Map<String,Boolean> toReturn = new Map<String,Boolean>();

            For(String field: fieldsAccContacts){
                if(isNew)
                    toReturn.put(field,false);
                else
                    toReturn.put(field,ac.get(field) <> previousAC.get(field));
            }

            return toReturn;
        }

    }

}