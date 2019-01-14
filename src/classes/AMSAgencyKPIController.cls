public class AMSAgencyKPIController {

    public Account ag {get;set;}
    public Account HO {get;set;}
    public Boolean isBranch {get;set;}

    // The extension constructor initializes the private member
    // variable mysObject by using the getRecord method from the standard
    // controller.
    public AMSAgencyKPIController(ApexPages.StandardController stdController) {
        /*stdController.addFields(new List<String>{'Name', 'IATACode__c', 'Trading_Name_1__c', 'Agency_Status__c', 'Primary_address__r.Address_1__c', 'Primary_address__r.City__c',
                                                    'Primary_address__r.Email__c', 'Primary_address__r.AMS_ZipCode__c', 'Primary_address__r.Country__r.Name', 'RecordType.Name',
                                                    'CurrencyISOCode', 'Recert_Expiry_Date__c', 'Accumulated_Irregularities__c'});*/

        Id objectId = ApexPages.currentPage().getParameters().get('id');

        if(objectId == null)
            return;

        this.ag = (Account)stdController.getRecord();
        this.ag = [select id, Name, IATACode__c, TradeName__c, Status__c, Primary_address__r.Address_1__c, Primary_address__r.City__c,
                                                    Primary_address__r.Email__c, Primary_address__r.AMS_ZipCode__c, IATA_ISO_Country__r.Name, RecordType.Name,
                                                    CurrencyISOCode, Expiry_Date__c, Accumulated_Irregularities__c, Guaranteed_amount__c,
                                                    Identify_as_Key_Customer__c, Key_Customer__c
                                                     from Account where id =: this.ag.id];
        ID aux = this.ag.id;
        Account auxParent = null;
        isBranch = false;
        while(HO == null){
            List<AMS_Agencies_relationhip__c> parentList = [select id, Child_Account__c, Child_Account__r.Name, Child_Account__r.IATACode__c, Child_Account__r.Status__c, Child_Account__r.Primary_Address__r.Country__r.Name,
            Parent_Account__c, Parent_Account__r.Name, Parent_Account__r.IATACode__c, Parent_Account__r.Status__c, Parent_Account__r.IATA_ISO_Country__r.Name
            from AMS_Agencies_relationhip__c where Child_Account__c =: aux];
            if(parentList.size() > 0){
                aux = parentList.get(0).Parent_Account__c;
                isBranch = true;
            }
            else
                break;
        }
        HO = [select id, Name, IATACode__c, TradeName__c, Status__c, Primary_address__r.Address_1__c, Primary_address__r.City__c, Primary_address__r.Email__c,
                    Primary_address__r.AMS_ZipCode__c, IATA_ISO_Country__r.Name, RecordType.Name, CurrencyISOCode, Expiry_Date__c, Accumulated_Irregularities__c, Guaranteed_amount__c,
                    Identify_as_Key_Customer__c, Key_Customer__c
                    from Account where id =: aux];
        /*if(isBranch){
            this.ag = [select id, Name, IATACode__c, Trading_Name_1__c, Agency_Status__c, Primary_address__r.Address_1__c, Primary_address__r.City__c, Primary_address__r.Email__c,
                    Primary_address__r.AMS_ZipCode__c, Primary_address__r.Country__r.Name, RecordType.Name, CurrencyISOCode, Recert_Expiry_Date__c, Accumulated_Irregularities__c
                    from AMS_Agency__c where id =: this.ag.id];
        }*/
    }
}