public with sharing class ProductAssignmentRelListCtrl {

    public List<Product_Assignment__c> pas {get;set;}
    public Account acc {get;set;}
    public integer printLimit {get;set;} 
    public integer counter {get;set;} 
    public boolean isRelatedList {get;set;}
    
    public ProductAssignmentRelListCtrl(ApexPages.StandardController standardcontroller){
         isRelatedList = (ApexPages.currentPage().getParameters().get('isPage') != 'true');
         acc = (Account)standardcontroller.getRecord();
         /*List<Product_Assignment__c> allPA= [SELECT Id, Name, ICCS_Product_Currency__r.Country__c, ICCS_Product_Currency__r.Currency__c, Bank_Account_Code__c, Bank_Account_Currency__c, 
                                                    Notice_of_Assignment__c, GSA_Agreement__c,Third_Party_Payment__c, Status__c,De_Activation_Date__c, Split_Type__c, ICCS_Product_Currency__r.Product__c,
                                                    Percentage__c, Amount__c
                                            FROM Product_Assignment__c
                                            WHERE Account__c = :acc.Id ORDER BY ICCS_Product_Currency__r.Country__c ASC];
        
        Date LastChangeDate ;
        pas = new List<Product_Assignment__c>();
        
        counter = 0;
        printLimit = 10;
        for(Product_Assignment__c pa : allPA){
            if(pa.Status__c == 'Active'){
                if(!(isRelatedList && pas.size()>=printLimit))
                    pas.add(pa);
                counter ++;
            }
            if(LastChangeDate==null || pa.De_Activation_Date__c > LastChangeDate)
                LastChangeDate = pa.De_Activation_Date__c;
        }
        
        if(pas.size()==0){
            for(Product_Assignment__c pa : allPA){
                if(LastChangeDate==pa.De_Activation_Date__c)
                    if(!(isRelatedList && pas.size()>=printLimit))
                        pas.add(pa);
                    counter ++;
            }
        }*/

        pas = new List<Product_Assignment__c>();
        counter = 0;
        printLimit = 10;

        // Create a map with a List of Product Assignments per key Product - Country - Currency
        Map<String, List<Product_Assignment__c>> mapProductAssignmentsPerProductCurrencyKey = new Map<String, List<Product_Assignment__c>>();
        List<Product_Assignment__c> lstPAs = [SELECT Id, Account__c, Name, ICCS_Product_Currency__c, Status__c, ICCS_Bank_Account__c, Bank_Account_Code__c, Bank_Account_Currency__c, GSA_Agreement__c, Third_Party_Payment__c, De_Activation_Date__c, Split_Type__c, Percentage__c, ICCS_Product_Currency__r.Product__c, ICCS_Product_Currency__r.Country__c, ICCS_Product_Currency__r.Currency__c, Notice_of_Assignment__c, Amount__c  FROM Product_Assignment__c WHERE Account__c = :acc.Id ORDER BY De_Activation_Date__c DESC];
        for (Product_Assignment__c pa : lstPAs) {
          //mapProductAssignmentsPerKey.put(String.valueOf(pa.ICCS_Product_Currency__c), pa);
          List<Product_Assignment__c> lst = mapProductAssignmentsPerProductCurrencyKey.get(String.valueOf(pa.ICCS_Product_Currency__c));
          if(lst == null)
            lst = new List<Product_Assignment__c>{pa};
          else
            lst.add(pa);

          mapProductAssignmentsPerProductCurrencyKey.put(String.valueOf(pa.ICCS_Product_Currency__c), lst);

        }

        for(String key: mapProductAssignmentsPerProductCurrencyKey.keyset())
        {

            List<Product_Assignment__c> paL = mapProductAssignmentsPerProductCurrencyKey.get(key);
            //List of Assignments to display for the ProductCurrency
            List<Product_Assignment__c> productCurrencyDisplayList = new List<Product_Assignment__c>();
            for(Product_Assignment__c pa: paL)
            {
                //all actives should show in list
                if(pa.Status__c == 'Active')
                {
                    productCurrencyDisplayList.add(pa);
                    System.debug('###Adding PA: '+ pa.Name + ' from Product Currency:' + pa.ICCS_Product_Currency__c);
                }
            }

            //if displayList is empty for the ProductCurrency then we must show the most recently deactivated PAs
            if(productCurrencyDisplayList.size() == 0)
            {
                for(Product_Assignment__c pa: paL)
                {
                    //always add the first most recent Inactivated
                    if(productCurrencyDisplayList.size() == 0)
                        productCurrencyDisplayList.add(pa);
                    else
                        //compare with first PA in display List, PAs with equal deactivation Date will be added
                        if(pa.De_Activation_Date__c == productCurrencyDisplayList[0].De_Activation_Date__c)
                            productCurrencyDisplayList.add(pa);
                }
            }

            if(!(isRelatedList && pas.size()>=printLimit))
                pas.addAll(productCurrencyDisplayList);
            
            counter += productCurrencyDisplayList.size();
            System.debug('###Adding' + productCurrencyDisplayList.size() + ' PAs from Product Currency to display List. displayList current size: '+ counter);


        }
        
        pas = sortProductAssignmentByCountry(pas);

    }

    public PageReference PDF(){
        return new PageReference('/apex/ICCSPdfPAGenerator?id='+acc.id);
    }
    
    public integer getPasSize(){
        if(pas==null)   return 0;
        return pas.size();
    }
    
    public List<Product_Assignment__c> sortProductAssignmentByCountry(List<Product_Assignment__c> pAssignments)
    {
        boolean swapped = false;
        do{
            swapped = false;
            for(Integer i=0; i< pAssignments.size()-1; i++)
            {
                if(pAssignments[i].ICCS_Product_Currency__r.Country__c.compareTo(pAssignments[i+1].ICCS_Product_Currency__r.Country__c) > 0)
                {
                    Product_Assignment__c tmp = pAssignments[i];
                    pAssignments[i] = pAssignments[i+1];
                    pAssignments[i+1] = tmp;
                    swapped = true;
                }
                    
            }
        }while(swapped==true);
        
        return pAssignments;
    }
    
}