public with sharing class ANG_ChangeRHCCurrency {

    private static final Set<String> FORECAST_REQUIRED_FIELDS = new Set<String>{'ANG_CashCondition__c','ANG_AccountId__c',
        'ANG_Financial_Security__c', 'ANG_RME_Amount__c','ANG_RHC_Amount_Provisional__c','ANG_Exceeding_Financial_Security__c'};

    private String objId;
    private static DescribeSObjectResult sObjDesc{
        get{
            if(sObjDesc==null)
                sObjDesc = ANG_RHC_Information__c.SObjectType.getDescribe();
                
            return sObjDesc;
        }
        set;
    }

    private static List<Schema.FieldSetMember> fieldsSet{
        get{
            if(fieldsSet == null)
                fieldsSet = Schema.SObjectType.ANG_RHC_Information__c.fieldSets.Display_On_Currency.getFields();

            return fieldsSet;
        }
        set;
    } 

    public Boolean isEdit{
        get{
            if(isEdit == null)
                isEdit=false;

            return isEdit;
        }
        private set;
    }

    public List<FieldWrapper> displayFields{get; set;}

    private Set<String> fieldsToQuery{
        get{
            if(fieldsToQuery == null){
                fieldsToQuery = new Set<String>();
                for(Schema.SObjectField soF:  sObjDesc.fields.getMap().values()){
                    for(Schema.FieldSetMember fieldToShow : fieldsSet){
                        if(soF.getDescribe().getName() == fieldToShow.getFieldPath()){
                            if(displayFields == null)
                                displayFields = new List<FieldWrapper>();

                            displayFields.add(new FieldWrapper(soF.getDescribe().getName(),soF.getDescribe().getLabel()));
                            fieldsToQuery.add(soF.getDescribe().getName());
                        }
                    }
                }
                fieldsToQuery.addAll(FORECAST_REQUIRED_FIELDS);
            }
            return fieldsToQuery;
        }
        private set;
    }

    private String oldCurrency{get; set;}

    public ANG_RHC_Information__c rhc{get;set;}

    public List<SelectOption> plOptions{
        get{
            if(plOptions == null){
                plOptions = new List<SelectOption>();
                for(ANG_RHC_Currencies__c cur : ANG_RHC_Currencies__c.getAll().values()){
                    plOptions.add(new SelectOption(cur.Name,cur.Currency_Name__c+' ('+cur.Name+')'));
                }
            }
            return plOptions;
        }
        private set;
    }

    public void forecast(){

        Map<String,Schema.SObjectField> fieldsMap = sObjDesc.fields.getMap();

        for (String field : fieldsToQuery){
            if(rhc.get(field) != null && fieldsMap.get(field).getDescribe().getType().name() == 'CURRENCY' && !fieldsMap.get(field).getDescribe().isCalculated()){
                Decimal value = (Decimal)rhc.put(field, CurrencySingleton.getInstance().convertCurrency((Decimal)rhc.get(field), oldCurrency, rhc.CurrencyIsoCode));
            }
        }

        //ANG_RHCHelper.calculateRHCAmount(new List<ANG_RHC_Information__c>{rhc});
        rhc.recalculateFormulas();
        oldCurrency = rhc.CurrencyIsoCode;
        
    }

    public void toggleEditMode(){
        isEdit = (!isEdit && sObjDesc.isUpdateable());
    }

    public void save(){
        update rhc;
        queryRHC();
        ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,'Currency Saved'));
    }

    private void queryRHC(){
        this.rhc = Database.query('SELECT Id,'+String.join(new List<String>(fieldsToQuery),',') +' FROM ANG_RHC_Information__c WHERE Id = :objId LIMIT 1');
    }

    public ANG_ChangeRHCCurrency() {
        this.objId = ApexPages.currentPage().getParameters().get('Id'); 
        queryRHC();
        oldCurrency = rhc.CurrencyIsoCode;      
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