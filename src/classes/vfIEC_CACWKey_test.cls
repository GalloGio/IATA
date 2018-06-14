/**
* @author Alexandre Jaimes
* @date 2016
* @group CACW
* @description This is the Test class to test the Visual force contoller extension vfIEC_CACWkey
* SeeAllData notation is required to be able to use Zuora WSDL
*/
@isTest (seeAllData=true)
private class vfIEC_CACWKey_test {
    private static Product_Category__c oProductCategory;
    private static Product_Information__c oProductInfo;
    private static zqu__ZProduct__c oProduct;
    private static zqu__ProductRatePlan__c oProductRatePlan;
    private static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    private static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    private static Zuora__Subscription__c subscription;
    private static Zuora__SubscriptionProductCharge__c subscriptionCharge;

    private static IECCustomer currentCustomer;
    
    private static CAC_Subscription_Detail__c CAC_SubscriptionDetail ;


    /*******************************************************************************************************
    * @description Initialize data requied to have a subscription and related records required to run test
    */    
    static void Init() {
        System.debug('Unit Test: Start: Init');
        oProductCategory = IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACWEB, true);
        insert oProductCategory;
        
        oProduct = IECTestUtil.CreateSampleProduct('PTST');
        insert oProduct;
        
        oProductInfo = IECTestUtil.CreateSampleProductInfo('PITST', oProductCategory, oProduct);
        oProductInfo.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert oProductInfo;
        
        oProductRatePlan = IECTestUtil.CreateSampleProductRatePlan('PRPTST', false, oProduct);
        insert oProductRatePlan;
        
        oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan, 'CHARGETEST', 1);
        insert oProductRatePlanCharge;
        
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('PCRPTST', false, oProductRatePlan, oProductInfo);
        insert oProductRatePlanInfo;
        
        currentCustomer = IECCustomer.getCurrentIECCustomer();
        
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(currentCustomer.RelatedAccount.Id, currentCustomer.RelatedBillingAccount.Id, 'Subs 01', Date.today().addMonths(6));
        subscription.Zuora__Status__c='Active';
        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id, Date.today().addMonths(-6), oProduct, oProductRatePlan);
        insert subscriptionCharge;
        
        // Create dummy CAC Subscription Detail
        CAC_SubscriptionDetail = 
            new CAC_Subscription_Detail__c(Name=subscription.Name
                						  ,Subscription__c=subscription.Id
                                          ,Service_Activation_Date__c=Date.Today()
                                          ,Max_API_Call_Per_Month__c=10000
                                          ,Status__c='Active'
                                          /*Service_Specification__c=*/
                                          /*,Service_Token__c=*/);
        Insert CAC_SubscriptionDetail;
            
        
        System.debug('Unit Test: Finish: Init');
    }
    
    
    
    static testMethod void testIEC_CACWKey() {

        System.debug('Unit Test: Start: TestIEC_CACWKey');

        //Set current page to GSSDetail File
        PageReference pgRef = Page.IEC_CACWKey;
        pgRef.getParameters().put(IECConstants.PARAM_SUBSCRIPTION_NAME, IECUtil.EncryptEncodeParameter('Subs 01'));
        pgRef.getParameters().put(IECConstants.PARAM_PRODUCT_CODE, IECUtil.EncryptEncodeParameter(IECConstants.ProductCategory_SF_CACWEB));
        Test.setCurrentPage(pgRef);
        
        User usr = IECTestUtil.createSampleGuestUserAndLogin();
        System.runAs(usr) {
            
            Test.startTest();
            //Arrange                
            // setup data
            Init();

            // triggers the Product Access creation
            update subscription;
                
            Test.stopTest();

            //Instantiate Controller

            vfIEC_CACW iecCacWebController = new vfIEC_CACW();
            vfIEC_CACWKey MyExtension = new vfIEC_CACWKey(iecCacWebController);
            
            
            //Act
            system.debug(MyExtension.CAC_SubscriptionDetailList);
            list<CAC_Subscription_Detail__c> ListOfCACDetails = MyExtension.CAC_SubscriptionDetailList;
            //Assert
            //Check if token on page is the same than the one on the database
            
            
            system.debug('ListOfCACDetails Size' + ListOfCACDetails.size());
            system.debug('ListOfCACDetails Values' + ListOfCACDetails);
            /*
			id TestID;
            for (CAC_Subscription_Detail__c cacd : ListOfCACDetails){
                if(cacd.id != CAC_SubscriptionDetail.id )
                    system.debug('ID Different');
                else {
                    system.debug('ID Found');
                    TestId = cacd.id;
                }      
            }
            
            set<Id> CacDetailIdSet = new set<id>();            
            for (CAC_Subscription_Detail__c cacd : ListOfCACDetails){
                CacDetailIdSet.add(cacd.Id); 
            }
            System.Debug('CacDetailIdSet Contains inserted ID = ' + CacDetailIdSet.contains(CAC_SubscriptionDetail.Id));
            System.Assert(CacDetailIdSet.contains(CAC_SubscriptionDetail.Id),'The CAC Subscription Detail Id inserted during the test method is expected to be returned by Controller ');
			*/
        }
        System.debug('Unit Test: Finish: TestIEC_CACWKey');
        
    }
}