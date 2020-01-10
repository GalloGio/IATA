public without sharing class SapSalesOrContractOrders_Queueable implements Queueable, Database.AllowsCallouts {


	private Set<Id> orderIds;
	public SapSalesOrContractOrders_Queueable(set<Id> sapOrderIds){
		orderIds = sapOrderIds;
	}

	//Executes the queueable job.
	public void execute(QueueableContext context){
		Order_Svc.createSapSalesOrders(orderIds);
		Order_Svc.createSAPContractsFuture(orderIds);
		//System.enqueueJob(new IEC_ContractOrdersQueueable(orderIds));  //*** failed with error "Maximum callout depth has been reached"
	}

}
