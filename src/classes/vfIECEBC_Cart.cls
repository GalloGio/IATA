public class vfIECEBC_Cart extends vfIECEBC_Controller {
	public Id selectedRatePlanInformationId {
		get {
			return 'a4S8E0000000in0';
		}
		set;
	}

	public ApexPages.StandardController con {
		public get;
		private set;
	}

	public vfIECEBC_Cart(ApexPages.StandardController stdController) {
		this.con = stdController;
	}

	public Pagereference addToCart() {
		IEC_Shopping_Cart__c cart = IECShoppingCartHelper.getCurrentShoppingCart();

		// create shopping cart if not existing
		if (cart == null) {
			// create new shopping cart and save guid in cookie
			cart = IECShoppingCartHelper.createNewShoppingCart(billingAccount.Contact__c, !IECUserManager.isUserLoggedIn());
		}

		// by default, quantity is 1
		IECShoppingCartHelper.addCartItem(cart, selectedRatePlanInformationId, 1);
		Pagereference prShoppingCart = Page.IECShoppingCart;
		prShoppingCart.getParameters().put('cb', '/IECEBC_CampaignConfirm?id=a768E00000004WgQAI');
		prShoppingCart.setRedirect(true);
		return prShoppingCart;
	}
}
