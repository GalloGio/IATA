/******************************************************************************************************************
 *  IEC_ProductListController: IEC_SearchResults page Controller                                                  *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
public with sharing class IEC_SearchResultsController extends IEC_PageController
{
    /**************************************************************************************************************
     *  Wrapper class to display the filters for refinement                                                       *     
     **************************************************************************************************************/
	public class FilterWrapper
    {
        public String field{get;set;}
        public String label{get;set;}
        public String type_x{get;set;}
        public List<SelectOption> values{get;set;}

        public FilterWrapper(){}
    }

	//Page parameters
    public String searchToken{get;set;}

	//Search Reult Products
    public List<EComProduct_DTO> allProducts{get;set;}
    private String searchCondition;
    public Integer totalNumberOfPages{get;set;}
    public List<Integer> pages{get;set;}
    
    //Products displayed
	public List<EComProduct_DTO> products{ get; set; }
    public static final Integer MAX_PRODUCTS_PER_PAGE = 12;
    public Boolean showPrevious{get;set;}
    public Boolean showNext{get;set;}
    public Integer currentPageNumber{get;set;}
    
    public String sortBy{get;set;}
    public List<SelectOption> sortingFields{get;set;}

    public List<FilterWrapper> filters{get;set;}

    public String selectedFilters{get;set;}


    /**************************************************************************************************************
     *  IEC_SearchResultsController: Class Constructor                                                            *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public IEC_SearchResultsController() 
	{
		//-- Search Token 
        searchToken = ApexPages.currentPage().getParameters().get('site-search');
        if (!String.isBlank(searchToken))
            searchToken = searchToken.trim();

        //-- Product Sorting picklist
        sortingFields = Utility.getFieldSetSelectOptions('Product2', 'Ecoomerce_Sort_By', false);
	}

    /**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
	public PageReference onLoadAction()
    {
        if(String.isBlank(searchToken) || searchToken.length() < 2) return null;


        //-- Query products to be displayed
        queryProducts();

        //-- Refresh product list page
        refreshDisplayedProducts();
        
        //--Advance search filters
        buildRefinementFilters();

        return null; 
    }

    /**************************************************************************************************************
     *  gotoNext: method calls when customer clicks on Next button in the pagination section                      *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void gotoNext()
    {
        currentPageNumber++;
        refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  gotoPrevious: method calls when customer clicks on Previous button in the pagination section              *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void gotoPrevious()
    {
        currentPageNumber--;
        refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  gotoPage: method call when customer clicks on a specific page number in the pagination section            *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void gotoPage()
    {
    	String pageNum = ApexPages.currentPage().getParameters().get('pageNum');
        currentPageNumber = Integer.valueOf(pageNum);
        refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  sortProducts: method calls when customer change the sort by value                                         *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void sortProducts()
    {
        queryProducts();
        refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  refine: method calls when customer clicks on Refine button                                                *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void refine()
    {
        if(String.isBlank(selectedFilters))
        {
            searchCondition = null; 
        }
        else
        {
            List<String> lst_selected_filters =  selectedFilters.split(':');
            Map<String, List<String>> filterConditions = new Map<String, List<String>>(); 
            for(String filter : lst_selected_filters)
            {
                List<String> filter_parts = filter.split('\\|');
                List<String> tmp = (filterConditions.containsKey(filter_parts[0])) ? filterConditions.get(filter_parts[0]) : new List<String>(); 
                    tmp.add(filter_parts[1]);

                filterConditions.put(filter_parts[0].replace('Inventory_Status__c1','Inventory_Status__c'), tmp);
            }

            Map<String, String> fieldType = new Map<String, String>(); //fild => type
            for(FilterWrapper fw : filters)
            {
                fieldType.put(fw.field.replace('Inventory_Status__c1','Inventory_Status__c'), fw.type_x);
            }

            List<String> conditions = new List<String>();

            for(String field : filterConditions.keySet())
            {
                if(fieldType.get(field) == 'STRING')
                {
                    conditions.add(field + ' LIKE \'%'+String.join(filterConditions.get(field), '') +'%\' ');
                }
                else
                {
                    String s = (fieldType.get(field) == 'BOOLEAN') ? String.join(filterConditions.get(field), ' , ') : '\'' + String.join(filterConditions.get(field), '\' , \'') + '\'';
                    conditions.add(field + ' IN ('+s+') ');
                }                
            }

            searchCondition = String.join(conditions,' AND ');
        }

       

        queryProducts();
        refreshDisplayedProducts();
    }
   
    /**************************************************************************************************************
     *  buildRefinementFilters: method used to initialize the refinement filters                                  *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    private void buildRefinementFilters()
    {
        //-- Get list of fields for refinement 
        List<Schema.FieldSetMember> fields  = Utility.readFieldSet('Product2', 'ECOM_Refinement_FIelds');
        filters = new List<FilterWrapper>();

        for(Schema.FieldSetMember field : fields)
        {
            FilterWrapper fw = new FilterWrapper();
            fw.field    = field.getFieldPath();
            fw.label    = field.getLabel();
            fw.type_x   = field.getType().name();

			if(fw.field == 'Inventory_Status__c'){
                FilterWrapper fw2 = new FilterWrapper();
                fw2.field = field.getFieldPath()+'1';
                fw2.type_x = field.getType().name();
                
                fw.label  = 'Print & CDs';
                fw2.label = 'Digital';

                fw.values = new List<SelectOption>(); 
                fw.values.add(new SelectOption('In stock','In stock'));
                fw.values.add(new SelectOption('Out of stock','Out of stock'));
                
                fw2.values = new List<SelectOption>(); 
                fw2.values.add(new SelectOption('Available Now',' Available Now'));
                fw2.values.add(new SelectOption('Coming Soon','Coming Soon'));

                filters.add(fw2);
            }
            else if(fw.type_x =='PICKLIST')
            {
                fw.values = Utility.getPicklistSelectOptions('Product2',fw.field,false);
            }  
            else if(fw.type_x =='BOOLEAN')
            {
                fw.values = new List<SelectOption>(); 
                    fw.values.add(new SelectOption('true','Yes'));
                    fw.values.add(new SelectOption('false','No'));
            }

            filters.add(fw);  
        }        
    }

    /**************************************************************************************************************
     *  queryProducts: method to return the list of products that will be displayed in the page                   *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    private void queryProducts()
    {
        //-- Fetch ecom Products
        allProducts =  Product_Sel.findProducts(searchToken, searchCondition, sortBy);

         //-- Back to 1st page if product exist 
        if(allProducts.size() > 0) 
            currentPageNumber = 1;

        totalNumberOfPages = (Math.mod(allProducts.size(), MAX_PRODUCTS_PER_PAGE) == 0 ) ?   (Integer)Math.ceil(allProducts.size() / MAX_PRODUCTS_PER_PAGE) :   1 + (Integer)Math.ceil(allProducts.size() / MAX_PRODUCTS_PER_PAGE);

        pages = new List<Integer>();
        for(Integer x = 1; x <= totalNumberOfPages; x++)
        {
        	pages.add(x);
        }
    }

    /**************************************************************************************************************
     *  refreshDisplayedProducts: method calls the set the products to be displayed in the current page           *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    private void refreshDisplayedProducts()
    {
    	Integer totalNumberOfProducts = allProducts.size();

        if(currentPageNumber == null) currentPageNumber = 1;

        Integer min = (currentPageNumber-1) * MAX_PRODUCTS_PER_PAGE;
        Integer max = min + MAX_PRODUCTS_PER_PAGE -1;
        if(max > totalNumberOfProducts) max =  totalNumberOfProducts; 

        showPrevious =(currentPageNumber > 1);
        showNext = (currentPageNumber < totalNumberOfPages);

        products = new List<EComProduct_DTO>();
        for(Integer x= 0; x<allProducts.size(); x++)
            if(min <= x   && x <= max)
                products.add(allProducts[x]);

        /*** ENHCS-2018-7 ***/
        List<Map<String,Object>> productsListWrapper = new List<Map<String,Object>>();
        Integer pos = 1;
        for(EComProduct_DTO prod : products) {
            Map<String,Object> prodObj = new Map<String,Object>();
            prodObj.put('id', prod.ProductNumber);
            prodObj.put('name', prod.ProductName);
            prodObj.put('category', prod.Portfolio);            
            prodObj.put('price', prod.unitPrice == null ? 0.00 : prod.unitPrice);    
            prodObj.put('brand', prod.ProductCategory);        
            prodObj.put('list', 'Search results'); 
            prodObj.put('position', pos);
            prodObj.put('dimension1', prod.Edition);
            prodObj.put('dimension2', prod.Language);
            prodObj.put('dimension3', prod.InventoryStatus);
            prodObj.put('dimension4', prod.AvailabilityDate);
            prodObj.put('dimension5', prod.Media);
            prodObj.put('dimension6', prod.EffectiveTo);

            pos++;
            productsListWrapper.add(prodObj);
        }
        productListStr = JSON.serialize(productsListWrapper);
    }

    /*** ENHCS-2018-7 ***/
    public String productListStr {get;set;}
    public Integer pageNumber {get;set;}

}