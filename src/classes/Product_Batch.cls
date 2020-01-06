global class Product_Batch implements Database.Batchable<sObject> , Database.AllowsCallouts
{
	List<Product2> productsToProcess;
	String action;

	global Product_Batch(String a, List<Product2> p)
	{
		action = a;
		productsToProcess = p;

		if(p <> null && p.size() > 0 && test.isRunningTest()){
		productsToProcess = new List<Product2>();
		productsToProcess.add(p[0]);
		}
	}

	global List<Product2> start(Database.BatchableContext BC)
	{
		return productsToProcess;
	}

	global void execute(Database.BatchableContext BC, List<Product2> scope)
	{
		if(action == 'saveZProducts')
		{
			Map<Id, Product2> productById = new Map<Id, Product2>(scope);
			String saveResult = Product_Svc.saveZProducts(productById.keySet());
		}
		else if(action == 'ProductStockStatus')
		{
			List<Product2> updateStatusResult = Product_Svc.productsToSendToSAP(scope);
		}
	}

	global void finish(Database.BatchableContext BC)
	{

	}
}
