public class PriceTableAddErrorForDuplicates extends TriggerAction {
	
	/**
	 * Method that checks if the record has a duplicate or not
	 * @param s the affected record
	 * @return true if there is a duplicate and false if not
	 */
	protected override Boolean isRelevant(SObject s) {

		Price_Table__c ptRecord = (Price_Table__c) s;

		if(Trigger.isUpdate) {

			Map<Id, Price_Table__c> oldMap = (Map<Id, Price_Table__c>) Trigger.oldMap;

			if(ptRecord.ISO_Country__c == oldMap.get(ptRecord.Id).ISO_Country__c 
				&& ptRecord.Type_Class_of_Agent__c == oldMap.get(ptRecord.Id).Type_Class_of_Agent__c) return false;
		}


		List<Price_Table__c> priceTableList = PriceTableSelector.getInstance().getPriceTablesByISOCountry(ptRecord.ISO_Country__c);

		if(priceTableList.isEmpty()) return false;

		for(Price_Table__c pt : priceTableList) {
			if(pt.Type_Class_of_Agent__c == ptRecord.Type_Class_of_Agent__c) return true;
		}

		return false;
	}

	/**
	 * Method that adds a error for duplicate records
	 * @param records duplicated records
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		for(Price_Table__c pt : (List<Price_Table__c>)records)
			pt.ISO_Country__c.addError(' A record with the same ISO Country and Agent type is already created. No Duplicates are allowerd.');
	}

}