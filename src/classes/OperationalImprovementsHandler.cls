/**
	Controller class for trigger Operational_Improvements__c
**/
public with sharing class OperationalImprovementsHandler {

	public static final Id CPS_RECORDTYPE_ID = Schema.SObjectType.Operational_Improvements__c.getRecordTypeInfosByDeveloperName().get('CPS_Checks').getRecordTypeId();

	private static Map<String,Decimal> MAP_CURRENCY_RATES;
	public static Map<String,Decimal> getMapCurrencyRate() {
		if(MAP_CURRENCY_RATES == null) {
			MAP_CURRENCY_RATES = new Map<String,Decimal>();
			for(CPS_Currency_Rate__mdt currencyRate : [SELECT DeveloperName, Rate__c FROM CPS_Currency_Rate__mdt]) {
				MAP_CURRENCY_RATES.put(currencyRate.DeveloperName, currencyRate.Rate__c);
			}
		}
		return MAP_CURRENCY_RATES;
	}

	public static void beforeInsert(list<Operational_Improvements__c> listNew) {
		populateExchangeRate(listNew);
	}

	public static void beforeUpdate(map<Id,Operational_Improvements__c> mapNew, map<Id,Operational_Improvements__c> mapOld) {
		populateExchangeRate(mapNew,mapOld);
	}

	/**
		Populates the Exchange rate field using the Custom Metadata "CPS_Currency_Rate__mdt"
		Currently used only for CPS_Checks Recordtype
	**/
	// for insert
	private static void populateExchangeRate(list<Operational_Improvements__c> listImprovements) {
		for (Operational_Improvements__c improvement: listImprovements) {
			if (improvement.RecordTypeId == CPS_RECORDTYPE_ID && improvement.Exchange_rate__c == null) {
				improvement.Exchange_rate__c = getMapCurrencyRate().get(improvement.Currency__c);
			}
		}
	}
	// for update
	private static void populateExchangeRate(map<Id,Operational_Improvements__c> mapNew, map<Id,Operational_Improvements__c> mapOld) {
		for (Operational_Improvements__c improvementNew: mapNew.values()) {
			if (improvementNew.RecordTypeId == CPS_RECORDTYPE_ID) {
				Operational_Improvements__c improvementOld = mapOld.get(improvementNew.Id);
				if (improvementNew.Exchange_rate__c == null || improvementOld.Currency__c != improvementNew.Currency__c ) {
					improvementNew.Exchange_rate__c = getMapCurrencyRate().get(improvementNew.Currency__c);
				}
			}
		}
	}
}
