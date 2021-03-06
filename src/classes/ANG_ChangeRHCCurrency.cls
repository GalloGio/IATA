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
		set;
	}

	public List<FieldWrapper> displayFields{get; set;}

	public Case caseToUpdate {get; set;}

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
				Decimal value = (Decimal)rhc.put(field, ANG_Risk_Helper.currencyConverter(oldCurrency,(Decimal)rhc.get(field), rhc.CurrencyIsoCode));
			}
		}

		//ANG_RHCHelper.calculateRHCAmount(new List<ANG_RHC_Information__c>{rhc});
		rhc.recalculateFormulas();
		oldCurrency = rhc.CurrencyIsoCode;

	}

	public void toggleEditMode(){
		isEdit = (isEdit && sObjDesc.isUpdateable());
	}

	public void save(){
		if(caseToUpdate.ParentId != null){

			List<case> cse = [Select Id, CaseNumber, Subject, Reason1__c, CaseArea__c FROM Case Where Id = :caseToUpdate.ParentId and recordTypeId = :AMS_Utils.RECTYPE_SAAM];

			if (cse.isEmpty()){
				ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Incorrect Case Number'));
				return;
			}

			this.caseToUpdate = cse[0];

			caseToUpdate.Reason1__c = 'RHC Changes';
			caseToUpdate.CaseArea__c = 'Risk Management Process';
			caseToUpdate.Subject = 'RHC currency updated';

			update caseToUpdate;
			update rhc;
			queryRHC(true);
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.INFO,'Currency Saved'));

		}else{
			ApexPages.addMessage( new ApexPages.Message(ApexPages.Severity.ERROR,'Please input a valid Case Number'));
		}
	}

	private void queryRHC(Boolean getName){
		this.rhc = Database.query('SELECT Id,'+(getName ? 'Name,' : '')+String.join(new List<String>(fieldsToQuery),',') +' FROM ANG_RHC_Information__c WHERE Id = :objId LIMIT 1');
	}

	public ANG_ChangeRHCCurrency() {
		this.objId = ApexPages.currentPage().getParameters().get('Id');
		queryRHC(false);
		oldCurrency = rhc.CurrencyIsoCode;
		caseToUpdate = new case();
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
