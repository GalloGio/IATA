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
        return System.schedule('Product In Stock/Out of Stock', CRON_EXP, new ProductStockStatus_Scheduler());
    }

	global void execute(SchedulableContext sc) 
	{
		Integer batchSize = Utility.getIntegerSetting('Number of products to SAP callout');
	    Product_Batch batch = new Product_Batch('ProductStockStatus',Product_Sel.activeProducts());
	    Database.executebatch(batch,batchSize);
	}
}