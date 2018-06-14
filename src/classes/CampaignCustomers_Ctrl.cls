public class CampaignCustomers_Ctrl 
{
    //-- Campaigns
    public List<SelectOption> campaigns{get;set;}
    public Id campaignId{get;set;}

    //-- Available & Selected Products 
    public Map<Integer, Product2> availableProducts{get;set;}
    public Map<Integer, Product2> selectedProducts{get;set;}
    
    //-- Order Date range 
    public Date startDate{get;set;}
    public Date endDate{get;set;}

    //-- CustomerType 
    public List<SelectOption> availableCustomerTypes{get;set;}
    public List<String> selectedCustomerTypes{get;set;}

    //-- Non members sub Category 
    public List<SelectOption> availableSubCategories{get;set;}
    public List<String> selectedSubCategories{get;set;}

    //-- Region
    public List<SelectOption> availableRegions{get;set;}
    public List<String> selectedRegions{get;set;}  

    //-- Countries 
    public List<SelectOption> availableCountries{get;set;}
    public List<String> selectedCountries{get;set;}

    //-- Units & Volumes
    public Decimal minUnit{get;set;}
    public Decimal maxUnit{get;set;}
    public Decimal minVolume{get;set;}
    public Decimal maxVolume{get;set;} 

    //public String msg {get; set;}
    //public List<String> prodWithoutStdPrice {get;set;}
    
    public CampaignCustomers_Ctrl()
    {

        String strFilter;
      availableProducts = new Map<Integer, Product2>();
        //-- Init data 

        //Campaign
        campaigns = new List<SelectOption>();
        strFilter = Utility.getSeqTextSetting('Campaign Filter for Renewal', ' ');
        Campaign_Sel campaignSelector = new Campaign_Sel(); 
        for(Campaign c: campaignSelector.getActiveCampaigns(strFilter))
            campaigns.add(new SelectOption(c.Id, c.Name));
        
        //Products
        strFilter = Utility.getSeqTextSetting('Product Filter for Renewal', ' ');
        List<Product2> availableProducts1 = Database.query('SELECT Id, Name, SAP_Material_Number__c, Product_Segment__c FROM Product2 WHERE (SAP_Material_Number__c != null) ' + strFilter + 'order By name');
        for(Integer index = 0 ; index < availableProducts1.size() ; index++) {
            availableProducts.put(index,availableProducts1[index]);
       }
       
        //CustomerTypes
        availableCustomerTypes =  new List<SelectOption>(); 
        availableCustomerTypes.add(new SelectOption('', '-'));
        Map<String, String> mapCustomerTypes = Utility.getPicklistValue_Label('Account', 'Customer_Type__c');
        for(String  val : mapCustomerTypes.keySet())
            availableCustomerTypes.add(new SelectOption(val,mapCustomerTypes.get(val)));

        //Non members sub Category 
        availableSubCategories =  new List<SelectOption>(); 
        Map<String, String> mapSubCategories = Utility.getPicklistValue_Label('Account', 'Non_Members_Sub_Category__c');
        for(String  val : mapSubCategories.keySet())
            availableSubCategories.add(new SelectOption(val,mapSubCategories.get(val)));

        //Regions
        availableRegions =  new List<SelectOption>(); 
        Map<String, String> mapRegions = Utility.getPicklistValue_Label('Account', 'Region__c');
        for(String  val : mapRegions.keySet())
            availableRegions.add(new SelectOption(val,mapRegions.get(val)));

        //Countries
        availableCountries = new List<SelectOption>();
        for(IATA_ISO_Country__c c : [Select Id, Name FROM IATA_ISO_Country__c WHERE Name != 'All Countries' ORDER BY Name])
            availableCountries.add(new SelectOption(c.Id, c.Name));
    }

    //Method called when click on  Generate Campaign Members button 
    public void generateCampaignMembers()
    {   

        //msg = '';
        //prodWithoutStdPrice = new List<String>();

        //-- Build SOQL to retrieve OrderItems 
        String query = 'SELECT OrderId, Order.BillToContactId, Product__c, Quantity, Invoice_Date__c FROM OrderItem WHERE IsDeleted = false and Order.Type in (\'Order\', \'History\') AND Order.Status != \'New\' AND Order.Status != \'Cancelled\'';

        //-- Products criteria
        if(selectedProducts != null && selectedProducts.size() > 0)
        {
            List<String> selectedProductNumbers = new List<String>(); 
            List<Campaign_Product__c> campaignProducts2Save = new List<Campaign_Product__c>();

            //Verified if the selectedProducts have standard price
            for(Integer id : selectedProducts.keySet()){
                selectedProductNumbers.add(selectedProducts.get(id).SAP_Material_Number__c);
            }

            Boolean selectedProductWithStdPrice = true;
            
            //Get the products price info
            /*Map<String, PriceInfo_DTO> priceMap = new Product_Sel().getProductPriceInfo(new Set<String>(selectedProductNumbers), null, null, null, true);
            for(String prodNumber : selectedProductNumbers){
                PriceInfo_DTO priceInfo = priceMap.get(prodNumber);
                //Verified if the product have Standard price
                if((priceInfo != null && priceInfo.standardPrice == null) || priceInfo == null){
                    prodWithoutStdPrice.add(prodNumber);
                }                
            }

            if(prodWithoutStdPrice.size() > 0){
                msg = 'Make sure these products have standard prices <br /> ' + String.join(prodWithoutStdPrice, ', ') + '<br /> <br /> ';
                return;
            }*/

            //-- Find selected products last ersions 
            Set<Id> productsOrdered = new Set<Id>();             
             for(Integer id : selectedProducts.keySet())
                productsOrdered.add(selectedProducts.get(id).Id);
            Map<Id, Product2> productLastVersion = new Product_Sel().getProductLastVersions(productsOrdered);

            
            for(Integer id : selectedProducts.keySet())
            {                
                Product2 lastVersion = productLastVersion.get(selectedProducts.get(id).Id);
                campaignProducts2Save.add(new Campaign_Product__c(
                    Campaign__c = campaignId, 
                    Product__c = selectedProducts.get(id).Id,
                    Product_Last_Version__c = lastVersion.Id
                ));
            }

            //-- Remove old campaign products and create new one 
            delete [SELECT Id FROM Campaign_Product__c WHERE Campaign__c = :campaignId];
            insert campaignProducts2Save; 
            
            query += ' AND Product_Number__c IN (\'' + String.join(selectedProductNumbers, '\' , \'') + '\') ';         
        }

        //-- Reset Generate_Members_Completed_On
        Campaign c = new Campaign(Id = campaignId, Generate_Members_Completed_On__c =null);
        update c;

        //-- Customer Criteria
        if(selectedCustomerTypes != null && selectedCustomerTypes.size() > 0) query += ' AND Order.Account.Customer_Type__c IN (\'' + String.join(selectedCustomerTypes, '\' , \'') + '\') ';
        if(selectedSubCategories != null && selectedSubCategories.size() > 0) query += ' AND Order.Account.Non_Members_Sub_Category__c IN (\'' + String.join(selectedSubCategories, '\' , \'') + '\') ';
        if(selectedRegions != null && selectedRegions.size() > 0) query += ' AND Order.Account.Region__c IN (\'' + String.join(selectedRegions, '\' , \'') + '\') ';    
        if(selectedCountries != null && selectedCountries.size() > 0) query += ' AND Order.Account.IATA_ISO_Country__c IN (\'' + String.join(selectedCountries, '\' , \'') + '\') ';
        

        //-- Purchase Criteria
        if(startDate != null) query += ' AND Invoice_Date__c >= '+ Utility.formatDate(startDate);
        if(endDate != null) query += ' AND Invoice_Date__c <= ' + Utility.formatDate(endDate);
        

        if(minUnit != null && minUnit > 0) query += ' AND Quantity >= '+ minUnit;
        if(maxUnit != null && maxUnit > 0) query += ' AND Quantity <= '+ maxUnit;
        
        if(minVolume != null && minVolume > 0) query += ' AND Order.Sales_Volume__c >= '+ minVolume;
        if(maxVolume != null && maxVolume > 0) query += ' AND Order.Sales_Volume__c <= '+ maxVolume;
        
        System.debug('query::'+query);

        //-- Clean CampaignMember, CampaignMemberProducts and then regenerate them 
        //at the end of CampaignMember cleanupbatch, a campaignmemberProduct batch is processed and after that the campaignmember and campaignmemberproducts are generated 
        Cleanup_Batch firstCleanBatch = new Cleanup_Batch('SELECT Id FROM CampaignMember WHERE CampaignId = \''+campaignId+'\'');
            firstCleanBatch.finishAction    =   'ClearCampaignMemberProducts';
            firstCleanBatch.idCampaign      =   campaignId;
            firstCleanBatch.finishQuery     =   query;

        Database.ExecuteBatch(firstCleanBatch); 
    }

    //Method called when click on Select Products 
    public PageReference selectProducts()
    {
        String productsNumbers = ApexPages.currentPage().getParameters().get('productsNumbers');

        if(String.isNotBlank(productsNumbers))
        {
            Set<String> setProductsNumbers = new Set<String>(productsNumbers.split('_'));

            if(selectedProducts == null) selectedProducts = new Map<Integer, Product2>();

            Map<Integer,Product2> newAvailableProducts = new Map<Integer,Product2>();
            List<Product2> listAux = new List<Product2>();

            for(Integer id: availableProducts.keySet()){
                if(setProductsNumbers.contains(availableProducts.get(id).SAP_Material_Number__c)) selectedProducts.put(id, availableProducts.get(id)); // fazer map 
                    else newAvailableProducts.put(id, availableProducts.get(id));
            }
            availableProducts = newAvailableProducts; 
        }
        return null;
    }

    public PageReference removeProducts()
    {
        String productsNumbers = ApexPages.currentPage().getParameters().get('productsNumbers');

        if(String.isNotBlank(productsNumbers))
        {
            Set<String> setProductsNumbers = new Set<String>(productsNumbers.split('_'));

            if(availableProducts == null) availableProducts = new Map<Integer, Product2>();

        
            Map<Integer, Product2> newSelectedProducts = new Map<Integer, Product2>();
            
            
            for(Integer id: selectedProducts.keySet())
            {             
                if(setProductsNumbers.contains(selectedProducts.get(id).SAP_Material_Number__c)) availableProducts.put(id,selectedProducts.get(id));
                else newSelectedProducts.put(id, selectedProducts.get(id));               
            }

            selectedProducts = newSelectedProducts;
        }

        return null;
    }
} 