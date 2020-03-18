global class SalesOrder_Scheduler implements Schedulable
{
	global static String doSchedule(String CRON_EXP)
	{
		String jobName = (Test.isRunningTest())? 'Test_'+Datetime.now().time() : 'SAP Sales Order creation';
		return System.Schedule(jobName, CRON_EXP, new SalesOrder_Scheduler());
	}

	global void execute(SchedulableContext sc)
	{
		Order_Sel orderSelector = new Order_Sel();
		Order_Batch b = new Order_Batch('CreateSalesOrders', orderSelector.getOrdersReady4SAP());
		Integer batchSize = Utility.getIntegerSetting('SAP_SALES_ORDER_BATCH_SIZE');
		Database.ExecuteBatch(b,batchSize);
	}
}
