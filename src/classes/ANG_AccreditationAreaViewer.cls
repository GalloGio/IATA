public with sharing class ANG_AccreditationAreaViewer {

    public Id existingOscarCaseId{get;set;}

    public String existingOscarCaseNumber{get;set;}

    public Set<String> notes{
            get{
                            
                            notes = new Set<String>();
                            notes.add('This is the Staging Area for the Account ' + accreditationObj.IATACode__c);
                            notes.add('You can create an Oscar Changes process by clicking the button below.');
                            notes.add('The Oscar Process will clone this accreditation area and will create a new Oscar/Case to be processed, attached to this account.');

                    return notes;
            }
            set;
    }
    public boolean doNotHaveOscarYet{
        get{
                List<AMS_Pax_Accreditation_Form__c> paxLst = [Select Id, HO_Account__c, SAAM_Case__c, SAAM_Case__r.Casenumber from AMS_Pax_Accreditation_Form__c where HO_Account__c = :this.accreditationObj.HO_Account__c and Id != :this.accreditationObj.Id and SAAM_Case__r.ParentId = :this.accreditationObj.SAAM_Case__c ];

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

	public AMS_Pax_Accreditation_Form__c accreditationObj { get; set; }

	public ANG_AccreditationAreaViewer(ApexPages.StandardController stdController) {
		
		//Id objectId = ApexPages.currentPage().getParameters().get('id');

		this.accreditationObj = (AMS_Pax_Accreditation_Form__c)stdController.getRecord();

		this.accreditationObj = fetchAccreditationFields(this.accreditationObj.Id);

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
        List<AMS_Pax_Accreditation_Form__c> accreditationLst = Database.query('SELECT Id, '+String.join(accreditationFieldNames, ', ')+' FROM AMS_Pax_Accreditation_Form__c WHERE Id = :accreditationId');

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
                , AMS_Pax_Accreditation_Form__c.Shipping_ISO_State__c
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
                , AMS_Pax_Accreditation_Form__c.Link_agent_name__c
                , AMS_Pax_Accreditation_Form__c.Is_your_firm_handling_Dangerous_Goods__c
                , AMS_Pax_Accreditation_Form__c.ANG_IsNewGenAgency__c
                , AMS_Pax_Accreditation_Form__c.ANG_Accreditation_type__c
                , AMS_Pax_Accreditation_Form__c.HO_Account__c 
            };
        }
    }
}