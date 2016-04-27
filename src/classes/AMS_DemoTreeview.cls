public class AMS_DemoTreeview {
    public AMS_Agency__c ag {get;set;}
    public AMS_Agencies_relationhip__c Parent {get;set;}
    public Boolean isHQ {get;set;}

    public AMS_DemoTreeview(ApexPages.StandardController stdController) {
        this.ag = (AMS_Agency__c)stdController.getRecord();
        this.ag = [select id, Name, Account__c, Account__r.Location_Type__c, IATACode__c, Agency_Status__c, Primary_Address__r.Country__r.Name, Location_Class__c, Primary_Address__r.City__c from AMS_Agency__c where id =: this.ag.id];
        this.Parent = fetchParent();
        if(this.Parent == null)
            isHQ = true;
        else
            isHQ = false;
    }

    //public List<AMS_Agency__c> getAccConCases(){
        //return [select id, Name, (select id, Name from Account.Contacts), (select id, ContactId, CaseNumber from Cases) from account LIMIT 10];
      //  return [select id, Name, (Select id, Name, Person__r.First_Name__c from Agency_Employees__r) from AMS_Agency__c LIMIT 10];
    //}

    /*public List<AMS_Agencies_relationhip__c>  getChilds(){
        return [select id, Child_Agency__c, Child_Agency__r.Name, Child_Agency__r.IATACode__c, Child_Agency__r.Agency_Status__c, Child_Agency__r.Primary_Address__r.Country__r.Name, Child_Agency__r.Primary_Address__r.City__c, Child_Agency__r.Account__r.Location_Type__c,
        Parent_agency__c, Parent_agency__r.Name, Parent_agency__r.IATACode__c, Parent_agency__r.Agency_Status__c, Parent_agency__r.Primary_Address__r.Country__r.Name, Parent_agency__r.Primary_Address__r.City__c,Parent_agency__r.Account__r.Location_Type__c, Child_Agency__r.Location_Class__c
        , Parent_agency__r.Location_Class__c from AMS_Agencies_relationhip__c where Parent_agency__c =: this.ag.id];
    }*/

    public Map<Integer, List<AMS_Agencies_relationhip__c>>  getChilds(){
        Map<Integer, List<AMS_Agencies_relationhip__c>> result = new Map<Integer, List<AMS_Agencies_relationhip__c>>();
        List<AMS_Agencies_relationhip__c> auxlist = new List<AMS_Agencies_relationhip__c>();
        Integer Key = 0;

        for(AMS_Agencies_relationhip__c ar: [select id, Child_Agency__c, Child_Agency__r.Name, Child_Agency__r.IATACode__c, Child_Agency__r.Agency_Status__c, Child_Agency__r.Primary_Address__r.Country__r.Name, Child_Agency__r.Primary_Address__r.City__c, Child_Agency__r.Account__r.Location_Type__c,
        Parent_agency__c, Parent_agency__r.Name, Parent_agency__r.IATACode__c, Parent_agency__r.Agency_Status__c, Parent_agency__r.Primary_Address__r.Country__r.Name, Parent_agency__r.Primary_Address__r.City__c,Parent_agency__r.Account__r.Location_Type__c, Child_Agency__r.Location_Class__c
        , Parent_agency__r.Location_Class__c from AMS_Agencies_relationhip__c where Parent_agency__c =: this.ag.id]){
            if(result.get(Key) != null){
                result.get(Key).add(ar);
            }else{
                auxlist.add(ar);
                result.put(Key, auxlist);
            }

            if(result.get(Key).size() == 600){
                auxlist = new List<AMS_Agencies_relationhip__c>();
                Key++;
            }
        }

        return result;
    }

    public AMS_Agencies_relationhip__c  fetchParent(){
        List<AMS_Agencies_relationhip__c> aux = [select id, Child_Agency__c, Child_Agency__r.Name, Child_Agency__r.IATACode__c, Child_Agency__r.Agency_Status__c, Child_Agency__r.Primary_Address__r.Country__r.Name,Child_Agency__r.Primary_Address__r.City__c, Child_Agency__r.Account__r.Location_Type__c,
        Child_Agency__r.Location_Class__c, Parent_agency__c, Parent_agency__r.Name, Parent_agency__r.IATACode__c, Parent_agency__r.Agency_Status__c, Parent_agency__r.Primary_Address__r.Country__r.Name, Parent_agency__r.Primary_Address__r.City__c,Parent_agency__r.Account__r.Location_Type__c
        , Parent_agency__r.Location_Class__c from AMS_Agencies_relationhip__c where Child_Agency__c =: this.ag.id];
        if(aux.size() > 0)
            return aux.get(0);
        return null;
    }
}