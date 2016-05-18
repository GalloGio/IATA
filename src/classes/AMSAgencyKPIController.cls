public class AMSAgencyKPIController {

	public AMS_Agency__c ag {get;set;}
    public AMS_Agency__c HO {get;set;}
    public Boolean isBranch {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMSAgencyKPIController(ApexPages.StandardController stdController) {
        /*stdController.addFields(new List<String>{'Name', 'IATACode__c', 'Trading_Name_1__c', 'Agency_Status__c', 'Primary_address__r.Address_1__c', 'Primary_address__r.City__c',
                                                    'Primary_address__r.Email__c', 'Primary_address__r.AMS_ZipCode__c', 'Primary_address__r.Country__r.Name', 'RecordType.Name',
                                                    'CurrencyISOCode', 'Recert_Expiry_Date__c', 'Accumulated_Irregularities__c'});*/
        this.ag = (AMS_Agency__c)stdController.getRecord();
        this.ag = [select id, Name, IATACode__c, Trading_Name_1__c, Agency_Status__c, Primary_address__r.Address_1__c, Primary_address__r.City__c,
                                                    Primary_address__r.Email__c, Primary_address__r.AMS_ZipCode__c, Primary_address__r.Country__r.Name, RecordType.Name,
                                                    CurrencyISOCode, Recert_Expiry_Date__c, Accumulated_Irregularities__c from AMS_Agency__c where id =: this.ag.id];
        ID aux = this.ag.id;
        AMS_Agency__c auxParent = null;
        isBranch = false;
        while(HO == null){
            List<AMS_Agencies_relationhip__c> parentList = [select id, Child_Agency__c, Child_Agency__r.Name, Child_Agency__r.IATACode__c, Child_Agency__r.Agency_Status__c, Child_Agency__r.Primary_Address__r.Country__r.Name,
            Parent_agency__c, Parent_agency__r.Name, Parent_agency__r.IATACode__c, Parent_agency__r.Agency_Status__c, Parent_agency__r.Primary_Address__r.Country__r.Name
            from AMS_Agencies_relationhip__c where Child_Agency__c =: aux];
            if(parentList.size() > 0){
                aux = parentList.get(0).Parent_agency__c;
                isBranch = true;
            }
            else
                break;
        }
        HO = [select id, Name, IATACode__c, Trading_Name_1__c, Agency_Status__c, Primary_address__r.Address_1__c, Primary_address__r.City__c, Primary_address__r.Email__c,
                    Primary_address__r.AMS_ZipCode__c, Primary_address__r.Country__r.Name, RecordType.Name, CurrencyISOCode, Recert_Expiry_Date__c, Accumulated_Irregularities__c
                    from AMS_Agency__c where id =: aux];
        /*if(isBranch){
            this.ag = [select id, Name, IATACode__c, Trading_Name_1__c, Agency_Status__c, Primary_address__r.Address_1__c, Primary_address__r.City__c, Primary_address__r.Email__c,
                    Primary_address__r.AMS_ZipCode__c, Primary_address__r.Country__r.Name, RecordType.Name, CurrencyISOCode, Recert_Expiry_Date__c, Accumulated_Irregularities__c
                    from AMS_Agency__c where id =: this.ag.id];
        }*/
    }
}