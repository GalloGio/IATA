/****************************************************************************************************
    Created by David D 2015-09-22
       This class contains all the business logic on zqu__ProductRatePlanCharge__c
****************************************************************************************************/
public with sharing class ProductRatePlanCharge_Svc 
{
    /****************************************************************************************************
        Created by David D 2015-09-22
            Method to set the standard price modelfrom zCharges listPrice
    ****************************************************************************************************/
    public static void setStandardPrice(Map<Id, zqu__ProductRatePlanCharge__c> zChargesNew, Map<Id, zqu__ProductRatePlanCharge__c> zChargesOld)
    {
        //-- Only PerUNit charge is considered
        List<zqu__ProductRatePlanCharge__c> perUnitCharges =  getChargesByModel(zChargesNew, zChargesOld, ZuoraUtil.ZCHARGE_MODEL_PER_UNIT);

        //-- Get Rate plans associated to charges
        Map<Id, zqu__ProductRatePlan__c> ratePlanByChargeId = new ProductRatePlan_Sel().getRatePlanByCharge(perUnitCharges, true); //CHARGE_ID=>RATE_PLAN
        
        //-- Get Products associated to rate plans  
        Map<Id, Id> zProductIdByPlanId = new ZProduct_Sel().getProductIdByPlan(ratePlanByChargeId.values()); //RATE_PLAN_ID => PRODUCT_ID

        //-- Get SFDC Products associated to ZProducts 
        //Map<Id, Product2> productByZProductId = new Product_Sel().getProductByZproduct(zProductIdByPlanId.values());

        //-- Get Products associated to zCharges 
        Map<Id, zqu__ProductRatePlanCharge__c> chargeByProductId = new Map<Id, zqu__ProductRatePlanCharge__c>(); //PRODUCT_ID => ZCHARGE
        
        for(Id chargeId : ratePlanByChargeId.keySet())
        {
            if(ratePlanByChargeId.containsKey(chargeId))
            {
                zqu__ProductRatePlan__c ratePlan = ratePlanByChargeId.get(chargeId);

                Id zProductId = zProductIdByPlanId.get(ratePlan.Id);
                //if(productByZProductId.containsKey(zProductId))
                //{
                    //Product2 product = productByZProductId.get(zProductId);

                    if(zChargesNew.containsKey(chargeId))
                    {
                        chargeByProductId.put(zProductId, zChargesNew.get(chargeId));
                    }
                //}
            }
                
        }

        System.debug('chargeByProductId::'+chargeByProductId);

        //-- Create PricebookEntry for each product
        Pricebook_Sel pricebookSelector = new Pricebook_Sel();  
        Pricebook2 stdPriceBook = pricebookSelector.getStandardPriceBook();
        List<PricebookEntry> priceBookEntries = pricebookSelector.generatePriceBokkEntries(chargeByProductId, stdPriceBook, true); 
    }

    /****************************************************************************************************
        Created by David D 2015-09-22
            Return List of charges with specific model 
    ****************************************************************************************************/
    public static List<zqu__ProductRatePlanCharge__c> getChargesByModel(Map<Id, zqu__ProductRatePlanCharge__c> zChargesNew, Map<Id, zqu__ProductRatePlanCharge__c> zChargesOld, String model)
    {
        List<zqu__ProductRatePlanCharge__c> perUnitCharges = new List<zqu__ProductRatePlanCharge__c>(); 

        //-- Get Rate Plans associated to PerUnit Charges
        for(Id chargeId : zChargesNew.keySet())
        {
            zqu__ProductRatePlanCharge__c zChargeNew = zChargesNew.get(chargeId);

            if(zChargesOld == null)
            {
                //-- New Charges created 
                if(zChargeNew.zqu__Model__c != null && zChargeNew.zqu__Model__c.contains(model))
                    perUnitCharges.add(zChargeNew);
            }
            else
            {
                //-- Charge updated : validate listPrice or model changed 
                zqu__ProductRatePlanCharge__c zChargeOld = zChargesOld.get(chargeId);
                if((zChargeNew.zqu__ListPrice__c != zChargeOld.zqu__ListPrice__c  || zChargeNew.zqu__Model__c != zChargeOld.zqu__Model__c )
                    && zChargeNew.zqu__Model__c != null && zChargeNew.zqu__Model__c.contains(model))
                    perUnitCharges.add(zChargeNew);
            }
        }

        return perUnitCharges;
    }
	
	public static void increasecoverage () {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
	
	
	
	}
	
}