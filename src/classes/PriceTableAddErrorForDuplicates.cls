public class PriceTableAddErrorForDuplicates extends TriggerAction {
	
	/**
	 * Method that checks if the relevant fields for this action were changed
	 * @param s the affected record
	 * @return true if the relevant fields for this action were changed and false if not
	 */
	protected override Boolean isRelevant(SObject s) {

		Price_Table__c ptRecord = (Price_Table__c) s;

		if(Trigger.isUpdate) {

			Map<Id, Price_Table__c> oldMap = (Map<Id, Price_Table__c>) Trigger.oldMap;

			if(ptRecord.ISO_Country__c == oldMap.get(ptRecord.Id).ISO_Country__c 
				&& ptRecord.Type_Class_of_Agent__c == oldMap.get(ptRecord.Id).Type_Class_of_Agent__c) return false;
		}

		return true;
	}

	/**
	 * Method that adds a error for duplicate records
	 * @param records duplicated records
	 * @param uw 	  unit of work to include all DML operations
	 * @return
	 */
	protected override void execute(List<SObject> records, UnitOfWork uw) {

		PriceTableSelector priceTableSelector = PriceTableSelector.getInstance();

		for(Price_Table__c ptRecord : (List<Price_Table__c>)records) {

			for(Price_Table__c pt : priceTableSelector.getPriceTablesByISOCountry(ptRecord.ISO_Country__c)) {

				if(pt.Type_Class_of_Agent__c == ptRecord.Type_Class_of_Agent__c) {
					ptRecord.ISO_Country__c.addError(' A record with the same ISO Country and Agent type is already created. No Duplicates are allowed.');
					break;
				}
			}
		}
	}

}