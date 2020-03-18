public class vfIEC_CACWDetail {
	//This is an extension to the Vf Controller: vfIEC_CACW
	private final vfIEC_CACW iecCacWeb;

	public vfIEC_CACWDetail(vfIEC_CACW controller) {
		this.iecCacWeb = controller;
	}

	public String sProductName {
		get {
			return (iecCacWeb.subscriptionObj != null) ? iecCacWeb.subscriptionObj.Product_Rate_Plan_Information__r.Related_Product_Information__r.Related_Product_Category__r.Display_Name__c : '';
		}
	}
	public String sOptionName {
		get {
			return (iecCacWeb.subscriptionObj != null) ? iecCacWeb.subscriptionObj.Product_Rate_Plan_Information__r.Product_Rate_Plan__r.Name : '';
		}
	}

	public integer iSubscriptionDaysLeft {
		get {
			if (iecCacWeb.subscriptionObj != null) {
				integer days = Date.today().daysBetween(iecCacWeb.subscriptionObj.Zuora__SubscriptionEndDate__c);
				return (days < 0) ? 0 : days;
			}
			return -1;
		}
	}

}
