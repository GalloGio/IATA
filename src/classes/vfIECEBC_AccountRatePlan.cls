/*  
  * Controller for the IECEBC_AccountRatePlan page (eBroadcast Account Rate Plan Overview) 
  * Initial Author: Sonny Leman
  * 
  * Description:
  *  - For a given Billing Account (Zuora__CustomerAccount)/User display the current EBroadcast Rate Plan options
  *  - Personalized upgrade suggestion
  *  - Selected plan will be stored in newSubscriptionProductCharge, currently not saved
  *   
  * History: 
  *  - 20160720-sl: initial working version
  */


public with sharing class vfIECEBC_AccountRatePlan extends vfIECEBC_Controller
{
	
	// ======================================================================== 
	// selectedProductRatePlanCharge & newSubscriptionProductCharge will be the result of user interaction
	public zqu__ProductRatePlanCharge__c selectedProductRatePlanCharge {get;private set;}
	public Zuora__SubscriptionProductCharge__c newSubscriptionProductCharge {get;private set;}
	
	
	// ======================================================================== 
	// constructor
	public vfIECEBC_AccountRatePlan()
	{
		selectedProductRatePlanCharge = null; // nothing is selected at the beginning 
		newSubscriptionProductCharge = new Zuora__SubscriptionProductCharge__c( Name ='--none--'
			, Zuora__EffectiveStartDate__c = Date.today()
			, Zuora__EffectiveEndDate__c = Date.today().addYears(1)
			, Zuora__Price__c = 0
			, Product_Rate_Plan_Charge__c = null
		);
	} // vfIECEBC_AccountRatePlan constructor
	
	
	// =======================================================================-
	// showUpgradeOption flag is used to turn on/off the rate plan upgrade options 
	public Boolean showUpgradeOption{
		get {
			return (productRatePlanChargeUpgradeList.size() > 0 );
		}
	}
	
	// =======================================================================-
	// showPaymentConfirmation flag is used to turn on/off the payment confirmation
	public Boolean showPaymentConfirmation{
 		get {
			return (newSubscriptionProductCharge.Product_Rate_Plan_Charge__c != null) ;
		}
	}
	
	
	// ========================================================================
	// updateRatePlanChargeSelection is done by calling selectRatePlanCharge from VfP
	public Integer selectedRatePlanChargeIndex {get;set;} // used as parameter for calling selectRatePlanCharge
	// selectRatePlanCharge updates the RatePlanCharge selection and flags, called from VfP
	// input parameter: selectedRatePlanChargeIndex
	// initial model: work by toggling the selected flag pointed by the selectedRatePlanChargeIndex
	public void selectRatePlanCharge()
	{
		if (productRatePlanChargeWrapperUpgradeList[selectedRatePlanChargeIndex].selected == true)
		{ // unselect previously selected plan
			productRatePlanChargeWrapperUpgradeList[selectedRatePlanChargeIndex].selected = false;
			selectedProductRatePlanCharge = null;
			newSubscriptionProductCharge.Product_Rate_Plan_Charge__c = null;
			newSubscriptionProductCharge.Zuora__Price__c = 0;
		} else { // select that plan
			productRatePlanChargeWrapperUpgradeList[selectedRatePlanChargeIndex].selected = true;
			for (Integer i=0;i<productRatePlanChargeWrapperUpgradeList.size();i++)
			{
				if (i != selectedRatePlanChargeIndex) {
					productRatePlanChargeWrapperUpgradeList[i].selected = false;
				}
			}
			selectedProductRatePlanCharge = productRatePlanChargeWrapperUpgradeList[selectedRatePlanChargeIndex].productRatePlanCharge;
			newSubscriptionProductCharge.Product_Rate_Plan_Charge__c = selectedProductRatePlanCharge.Id;
			newSubscriptionProductCharge.Zuora__Price__c = selectedProductRatePlanCharge.zqu__ListPrice__c;
		}
		
		//System.debug( 'vfIECEBC_AccountRatePlan.selectRatePlanCharge: newSubscriptionProductCharge= '+ newSubscriptionProductCharge + '\n' + showPaymentConfirmation);
	} // end of selectRatePlanCharge
	
	
	// ========================================================================
	// productRatePlanUpgradeWrapperList is used to display and select the product rate plan charge
	public List<ProductRatePlanChargeWrapper> productRatePlanChargeWrapperUpgradeList {
		get{
			if (productRatePlanChargeWrapperUpgradeList == null) 
			{
				List<ProductRatePlanChargeWrapper> prpcWrapperList = new List<ProductRatePlanChargeWrapper>();
				
				for (zqu__ProductRatePlanCharge__c prpc : productRatePlanChargeUpgradeList)
				{
					ProductRatePlanChargeWrapper prpcWrapper = new ProductRatePlanChargeWrapper(prpc);
					prpcWrapper.selected = false;
					prpcWrapper.index = prpcWrapperList.size();
					prpcWrapperList.add(prpcWrapper);
				}
				productRatePlanChargeWrapperUpgradeList = prpcWrapperList;
			}
			return productRatePlanChargeWrapperUpgradeList;
		}
		set;
	} // end of productRatePlanUpgradeWrapperList getter/setter
	
	
	
	// ========================================================================
	// wrapper class for ProductRatePlanCharge
	// needed checking the selected flag and index.
	public class ProductRatePlanChargeWrapper{
		public Integer index {get;set;} // array index
		public zqu__ProductRatePlanCharge__c productRatePlanCharge {get;private set;}
		public Boolean selected {get;set;}
		
		public ProductRatePlanChargeWrapper(zqu__ProductRatePlanCharge__c prpc)
		{
			productRatePlanCharge = prpc;
			selected = false;
		}
		
	} // end class ProductRatePlanChargeWrapper
} // end of class vfIECEBC_AccountRatePlan