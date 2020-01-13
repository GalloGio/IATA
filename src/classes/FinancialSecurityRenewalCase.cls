global class FinancialSecurityRenewalCase implements Schedulable{

global void execute(SchedulableContext SC) {

FinancialSecurityRenewalCaseBatch batch = new FinancialSecurityRenewalCaseBatch();
Database.executeBatch(batch, 25);

	 }
}
