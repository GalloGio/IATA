public with sharing class ANG_ChangeRHCCurrency {

    private String objId;
    private static DescribeSObjectResult sObjDesc = ANG_RHC_Information__c.SObjectType.getDescribe();
    private static Map<String, Schema.SObjectField> fieldMap = sObjDesc.fields.getMap();
    private static List<Schema.FieldSetMember> fieldsSet{
        get{
            if(fieldsSet == null)
                fieldsSet = Schema.SObjectType.ANG_RHC_Information__c.fieldSets.Display_On_Currency.getFields();

            return fieldsSet;
        }set;
    } 

    public Boolean isEdit{
        get{
            if(isEdit == null)
                isEdit = sObjDesc.isUpdateable();

            return isEdit;
        }
        private set;
    }

    public List<FieldWrapper> displayFields{get; set;}

    private List<String> fieldsToQuery{
        get{
            if(fieldsToQuery == null){
                fieldsToQuery = new List<String>();
                for(Schema.SObjectField soF: fieldMap.values()){
                    for(Schema.FieldSetMember fieldToShow : fieldsSet){
                        if(soF.getDescribe().getName() == fieldToShow.getFieldPath()){
                            if(displayFields == null)
                                displayFields = new List<FieldWrapper>();

                            displayFields.add(new FieldWrapper(soF.getDescribe().getName(),soF.getDescribe().getLabel()));
                            fieldsToQuery.add(soF.getDescribe().getName());
                        }
                    }
                }
            }
            return fieldsToQuery;
        }
        private set;
    }

    public ANG_RHC_Information__c rhc{get;set;}

    public ANG_ChangeRHCCurrency() {
        this.objId = ApexPages.currentPage().getParameters().get('Id');       
        this.rhc = Database.query('SELECT Id, '+String.join(fieldsToQuery,',') +' FROM ANG_RHC_Information__c WHERE Id = :objId LIMIT 1');
        system.debug('## rhc: '+rhc);
    }

    public class FieldWrapper{
        public String name {get; set;} 
        public String label {get; set;} 

        public FieldWrapper(String name, String label){
            this.name = name;
            this.label = label;
        }

    }

}