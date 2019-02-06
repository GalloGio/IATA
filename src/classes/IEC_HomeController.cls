public with sharing class IEC_HomeController extends IEC_PageController{
    //New releases by category 
    public Map<String, List<EComProduct_DTO>> newReleases{get;set;} 

    //-- TOP Sellers 
    public List<EComProduct_DTO> topSellers { get;set; }

    /*** ENHCS-2018-7 ***/
    public String productListStr {get;set;}

    public IEC_HomeController() { }

    public PageReference onLoadAction(){

        //-- New Releases
        newReleases = new Map<String, List<EComProduct_DTO>>();
        List<EComProduct_DTO> lst_releases = Product_Sel.getEComProduct(null, false, ' IsNewRelease__c = true ', 'LastModifiedDate') ;
        for(EComProduct_DTO prod : lst_releases){
            List<EComProduct_DTO> tmp = (newReleases.containsKey(prod.megaMenu)) ? newReleases.get(prod.megaMenu) : new List<EComProduct_DTO>();
                tmp.add(prod);

            newReleases.put(prod.megaMenu, tmp);
        }

        //Make sure all categories has entries 
        for(SelectOption so : categories)
            if(!newReleases.containsKey(so.getValue()))
                newReleases.put(so.getValue(), new List<EComProduct_DTO>());

        //-- Top Sellers 
        topSellers = Product_Sel.getEComProduct(null, false, 'Recommended__c = true', 'Recommended_Ranking__c, Name') ;

        /*** ENHCS-2018-7 ***/
        List<Map<String,Object>> productsListWrapper = new List<Map<String,Object>>();
        if(topSellers != null && !topSellers.isEmpty()){
            Integer pos = 1;
            for(EComProduct_DTO prod : topSellers) {
                system.debug('prod_dto: ' + prod);

                Map<String,Object> prodObj = new Map<String,Object>();
                prodObj.put('id', prod.ProductNumber);
                prodObj.put('name', prod.ProductName);
                prodObj.put('category', prod.Portfolio);            
                prodObj.put('price', prod.unitPrice == null ? 0.00 : prod.unitPrice);    
                prodObj.put('brand', prod.ProductCategory);        
                prodObj.put('position', pos);

                pos++;
                productsListWrapper.add(prodObj);
            }
        }
        productListStr = JSON.serialize(productsListWrapper);

        return null;
    }

}