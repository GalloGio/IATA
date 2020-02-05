/****************************************************************************************************
	Created by Kevin Ky 2015-08-26
	Schedule the Product In Stock/Out of Stock from SAP
****************************************************************************************************/
global class ProductStockStatus_Scheduler implements Schedulable
{
	//schedule the batch with time in the parameter
	//runs every day at 1 AM. '0 0 1 * * ?'
	global static String doSchedule(String CRON_EXP)
	{
		String name = (Test.isRunningTest()) ? 'Product Stock Status '+ Datetime.now().getTime() : 'Product In Stock/Out of Stock';
		return System.schedule(name, CRON_EXP, new ProductStockStatus_Scheduler());
	}

	global void execute(SchedulableContext sc)
	{
		Integer batchSize = Utility.getIntegerSetting('Number of products to SAP callout');
		Product_Batch batch = new Product_Batch('ProductStockStatus',Product_Sel.activeProducts());
		Database.executebatch(batch,batchSize);
	}
}
