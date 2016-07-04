/**
 * This class is used to extends any controller of the eBroadcast project.
 * 
 * It contains various usefull method and properties that can be reused such as
 * as the access to the rate plan, etc.
 **/
public virtual class vfIECEBC_Controller {
    // Exception to be thrown by the controllers
	public class Controller_Exception extends Exception{}
    
    // The current user
    public User usr {
        get {
            if (usr == null) usr = vfIECEBC.usr;
            return usr;
        }
        set;
    }
    
    // The billing account associated with the current user
    public Zuora__CustomerAccount__c billingAccount {
        get {
            if (billingAccount == null) billingAccount = vfIECEBC.billingAccount;
            return billingAccount;
        }
        set;
    }
    
    // The zuora subscription associated with the current billing account
    public Zuora__Subscription__c subscription {
        get {
            if (subscription == null) subscription = vfIECEBC.subscriptionInfo.oSubscription;
            return subscription;
        }
        set;
    }
    
    // The zuora rate plan associated with the current subscription
    public zqu__ProductRatePlan__c productRatePlan {
        get {
            if (productRatePlan == null) productRatePlan = vfIECEBC.productRatePlan;
            return productRatePlan;
        }
        set;
    }
    
    // The zuora rate plan associated with the current subscription
    public EBC_Preference__c preferences {
        get {
            if (preferences == null) preferences = vfIECEBC.pref;
            return preferences;
        }
        set;
    }
    
    // Used by visualforce pages to rerender block without reloading entire page
    public PageReference doNothing() {
        return null;
    }
}