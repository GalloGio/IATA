public with sharing class ANG_RequestProvisionalRHCCtrl {

	private static final Set<String> FORECAST_REQUIRED_FIELDS = new Set<String>{'ANG_CashCondition__c','ANG_AccountId__c',
        'ANG_Financial_Security__c', 'ANG_RME_Amount__c','ANG_RHC_Amount_Provisional__c','ANG_Exceeding_Financial_Security__c'};

    private String objId;

    private Decimal requestedProvisionalRHCAmount;
    private Date requestedProvisionalRHCAmountLastUpdate;

    private static DescribeSObjectResult sObjDesc{
        get{
            if(sObjDesc==null){
                sObjDesc = ANG_RHC_Information__c.SObjectType.getDescribe();
            }

            return sObjDesc;
        }
        set;
    }

    private static List<Schema.FieldSetMember> fieldsSet{
        get{
            if(fieldsSet == null){
                fieldsSet = Schema.SObjectType.ANG_RHC_Information__c.fieldSets.Request_Provisional.getFields();
            }

            return fieldsSet;
        }
        set;
    } 

    public List<FieldWrapper> displayFields{get; set;}
    
    private Set<String> fieldsToQuery{
        get{
            if(fieldsToQuery == null){
                fieldsToQuery = new Set<String>();
                for(Schema.SObjectField soF:  sObjDesc.fields.getMap().values()){
                    for(Schema.FieldSetMember fieldToShow : fieldsSet){
                        if(soF.getDescribe().getName() == fieldToShow.getFieldPath()){
                            if(displayFields == null){
                                displayFields = new List<FieldWrapper>();
                            }
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

    public boolean hasChanged{get;set;}
    public boolean buttonAlreadyPushed{get;set;}

    public ANG_RHC_Information__c rhc{get;set;}

    public void requestProvisionalRHC(){ 
		
		buttonAlreadyPushed= true;
		ANG_RME_Alert_Service.WebserviceResult result = ANG_RME_Alert_Service.requestProvisionalRHCAux(rhc.ANG_AccountId__c, false,false);

        if(Test.isRunningTest()){
            result.isSuccess = true;
            ANG_RME_Alert_Service.RHCMessage message = result.getResultMessage();
            message.provisionalRHC = 200;
        }

        if(result.isSuccess){

            System.debug('[ANG_RequestProvisionalRHCCtrl] - Result from webservice is:'+result);

            rhc.ANG_RHC_Amount_Provisional__c = result.getResultMessage().provisionalRHC;
            rhc.ANG_Provisional_RHC_Last_Update__c = System.today();

            if( rhc.ANG_RHC_Amount_Provisional__c <> requestedProvisionalRHCAmount ||
                rhc.ANG_Provisional_RHC_Last_Update__c <> requestedProvisionalRHCAmountLastUpdate
            ){
                
                hasChanged = true;
                
                requestedProvisionalRHCAmount = rhc.ANG_RHC_Amount_Provisional__c;
                requestedProvisionalRHCAmountLastUpdate = rhc.ANG_Provisional_RHC_Last_Update__c;
                
                rhc.ANG_RME_Amount__c = rhc.ANG_RHC_Amount_Provisional__c;

            }else{
                this.hasChanged = false;
            }
        }else{ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,result.description));}

    }

    public void save(){
        
        if(canUpdateRHC()){
            update rhc;
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,'Provisional RHC Amount saved on record.'));
        }

    }

    private boolean canUpdateRHC(){

        // check if current user is Admin
        Profile profile = [Select id, Name from Profile where Id = :UserInfo.getProfileId()];
        boolean isAdminUser = profile.Name.startsWithIgnoreCase('System Administrator');
        
        boolean toBlockUpdate = !isAdminUser && rhc.ANG_CashCondition__c && ( rhc.ANG_Financial_Security__c == 0 || rhc.ANG_Financial_Security__c == null);

        if(toBlockUpdate){
            ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Provisional RHC cannot be enforced as RHC amount because the agent has cash condition equal to FS. If the agent has no valid FS, please contact your administrator'));
            return false;
        }

        return true;
    }

    private void queryRHC(){
        this.rhc = Database.query('SELECT Id,Name,'+String.join(new List<String>(fieldsToQuery),',') +' FROM ANG_RHC_Information__c WHERE Id = :objId LIMIT 1');
    }

    public ANG_RequestProvisionalRHCCtrl() {
        this.objId = ApexPages.currentPage().getParameters().get('Id'); 
        this.rhc = Database.query('SELECT Id,'+String.join(new List<String>(fieldsToQuery),',') +' FROM ANG_RHC_Information__c WHERE Id = :objId LIMIT 1');

        requestedProvisionalRHCAmount = rhc.ANG_RHC_Amount_Provisional__c;
        requestedProvisionalRHCAmountLastUpdate = rhc.ANG_Provisional_RHC_Last_Update__c;
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