public with sharing class Pricebook_Sel extends Selector
{
	public List<Schema.SObjectField> getSObjectFieldList()
	{
		return new List<Schema.SObjectField> 
		{
			Pricebook2.Id,
			Pricebook2.Name,
			Pricebook2.IsActive,
			Pricebook2.Description, 
			Pricebook2.IsStandard
		};
	}

	public Schema.SObjectType getSObjectType()
	{
		return Pricebook2.sObjectType;
	}

	/****************************************************************************************************
        Created by CGI - David
            this function return the standard pricebook. 
    ****************************************************************************************************/
	public Pricebook2 getStandardPriceBook()
	{
		Pricebook2 ret; 

		String query = String.format(
			'SELECT {0}  ' + 
			'FROM {1} ' + 
			'WHERE IsStandard=true LIMIT 1' , 
			new List<String>{
				String.join(getDefaultFields(), ', '),
				getSObjectType().getDescribe().getName()
			}
		);

		List<Pricebook2> pricebooks = Database.query(query);
		if(!pricebooks.isEmpty()) ret = pricebooks[0];
		
		return (Test.isRunningTest()) ? new Pricebook2(Id=Test.getStandardPricebookId()) : ret;
	}


	public String getCorporateCurrencyCode()
	{
		List<CurrencyType> currencies = [SELECT Id,IsCorporate,IsoCode FROM CurrencyType WHERE IsCorporate = true LIMIT 1];
		return (currencies.isEmpty()) ? 'USD' : currencies[0].IsoCode;
	}

	/****************************************************************************************************
        Created by CGI - David
            this function generate pricebook entries for given product/price and pricebook specified
    ****************************************************************************************************/
	public List<PricebookEntry> generatePriceBokkEntries(Map<Id, zqu__ProductRatePlanCharge__c> chargeByProductId, Pricebook2 pricebook, Boolean doInsert)
	{
		// Use standard Pricebook for unit test 
		Id pricebookId = (Test.isRunningTest()) ? Test.getStandardPricebookId() : pricebook.Id; 

		String currencyCode = getCorporateCurrencyCode();

		Map<String, PricebookEntry> existingEntries = new Map<String, PricebookEntry>(); 
		Set<Id> productIds = new Set<Id>();

		for(Id productId : chargeByProductId.keySet()) productIds.add(productId);
		

		for(PricebookEntry pbe : [SELECT Id, Pricebook2Id, Product2Id FROM PricebookEntry WHERE Product2Id IN :productIds AND Pricebook2Id=:pricebookId])
		{
			String key = pbe.Pricebook2Id + '-' + pbe.Product2Id;
			existingEntries.put(key, pbe);
		}

		List<PricebookEntry> pbe2create = new List<PricebookEntry>();
		List<PricebookEntry> pbe2update = new List<PricebookEntry>();

		for(Id productId : chargeByProductId.keySet())
		{
			zqu__ProductRatePlanCharge__c zCharge = chargeByProductId.get(productId);

			/*
			System.debug('zqu__ProductRatePlanCharge__c Id: ' + zCharge.Id);
			System.debug('  ListPrice: ' + zCharge.zqu__ListPrice__c);
			*/

			// Ecommerce Enhancements R2, aosantos, 2017-06-16, dont create pricebook entries for discounts, etc, just for prices
			if (zCharge.zqu__ListPrice__c != null) {
				//-- Validate PricebookEntry exist
				PricebookEntry pbe; 
				if(existingEntries.containsKey(pricebookId + '-' + productId))
				{
					//-- Update existing Entry
					pbe = existingEntries.get(pricebookId + '-' + productId);

					//System.debug('   pbeId: ' + pbe.Id);

					pbe.UnitPrice = zCharge.zqu__ListPrice__c;
					pbe.IsActive = true;

					pbe2update.add(pbe);
				}
				else
				{
					//-- Create new Entry
					pbe = new PricebookEntry(
						IsActive = true,
						Pricebook2Id = pricebookId,
						Product2Id = productId,
						UnitPrice = zCharge.zqu__ListPrice__c,
						CurrencyIsoCode = currencyCode
					);

					pbe2create.add(pbe);
				}
			}
		}

		List<PricebookEntry> priceBookEntries = new List<PricebookEntry>();

		if(!pbe2create.isEmpty())
		{
			insert pbe2create; 
			priceBookEntries.addAll(pbe2create);
		}

		if(!pbe2update.isEmpty())
		{
			update pbe2update;
			priceBookEntries.addAll(pbe2update);
		}

		return priceBookEntries;
	} 
}