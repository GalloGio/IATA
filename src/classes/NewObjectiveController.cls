public with sharing class NewObjectiveController {

    public Id parentId;
    public String recordtype;

    public NewObjectiveController(ApexPages.standardController controller) {
        this.parentId = ApexPages.CurrentPage().getParameters().get('parent');
        this.recordtype = ApexPages.CurrentPage().getParameters().get('recordtype');
    }

    public Pagereference redirect() {
        Objective__c parent = [
            Select Unit_Type__c, SystemModstamp, Region__c, Sub_region__c, Name, Id, Functional_Area__c, Division__c, Description__c, Type__c, Deadline__c, CurrencyIsoCode
            from Objective__c
            where Id = :this.parentId
        ];
        Objective__c newObjective = parent.clone();
        newObjective.Parent_Objective__c = this.parentId;
        newObjective.RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', recordtype);
        newObjective.Name = parent.Description__c;
        insert newObjective;

        Pagereference pageref = new Pagereference('/'+newObjective.Id + '/e');
        pageref.getParameters().put('retURL','/' + newObjective.Id);
        pageref.setRedirect(true);
        return pageref;
    }
    
}