/******************************************************************************************************************
 *  IEC_ProductListController: IEC_ProductList page Controller                                                    *
 *  Author: David Daboué - CGI                                                                                    *        
 ******************************************************************************************************************/
public with sharing class IEC_ProductListController extends IEC_PageController
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
    public Map<String, String> pageParams;
    public String selectedTopic{get;set;}
    public String selectedTopicLabel{get;set;}
    public String selectedCustomerType{get;set;}

    //Products available
    public List<EComProduct_DTO> allProducts; 
    
    
    private String searchCondition;
    public Integer totalNumberOfPages{get;set;}
    public List<Integer> pages{get;set;}
    
    //Products displayed
	public List<EComProduct_DTO> products{ get; set; }
    
    private String userAgent{get;set;} 
    public static final Integer MAX_PRODUCTS_PER_PAGE = Utility.getIntegerSetting('PRODUCT_LIST_PAGE_SIZE_LIMIT');// 12;

    public Boolean showPrevious{get;set;}
    public Boolean showNext{get;set;}
    public Integer currentPageNumber{get;set;}
   
    public String sortBy{get;set;}
    public List<SelectOption> sortingFields{get;set;}

    public List<FilterWrapper> filters{get;set;}

    public String selectedFilters{get;set;}
    public String pageNumber{get;set;}


    /**************************************************************************************************************
     *  IEC_ProductListController: Class Constructor                                                              *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public IEC_ProductListController()
    {
        //-- Page parameters
        pageParams = ApexPages.currentPage().getParameters();

        userAgent = ApexPages.currentPage().getHeaders().get('USER-AGENT');
        //-- Product Sorting picklist
        sortingFields = Utility.getFieldSetSelectOptions('Product2', 'Ecoomerce_Sort_By', false);
    }

    /**************************************************************************************************************
     *  onLoadAction: method calls when page loaded                                                               *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public PageReference onLoadAction()
    {
        buildQueryConditions();

        queryProducts();

        refreshDisplayedProducts();
        
        //--Advance search filters
        buildRefinementFilters();

        return null; 
    }

    /**************************************************************************************************************
     *   buildQueryConditions: method to set dynamically the products query parameters                            *
     *   Author: David Daboué                                                                                     *  
     **************************************************************************************************************/
    private void buildQueryConditions()
    {
        //Set default Mega Menu to Publication
        selected_category = (pageParams != null && pageParams.containsKey('category')) ? pageParams.get('category') : 'publications'; 

        Set<String> validCategories = new Set<String>();
        for(SelectOption so : categories)
            validCategories.add(so.getValue());
        
        if(!validCategories.contains(selected_category)) selected_category = 'publications';
        
        for(SelectOption so : categories)
        {
            if(so.getValue() == selected_category)
            {
                selectedCategory = so;
                break;
            }
        }

        //-- Query products
        searchCondition = '  Mega_Menu__c=\''+selected_category+'\' ';

        if(pageParams.containsKey('topic')){
            selectedTopic = pageParams.get('topic');
            searchCondition += ' AND Display_Ecom_Topic__c INCLUDES(\''+selectedTopic+'\') ';
            if (subCategories.containsKey(selected_category))
                for (SelectOption so : subCategories.get(selected_category))
                    if (so.getValue() == selectedTopic)
                    {
                        selectedTopicLabel = so.getLabel();
                        break;
                    }
        }

        if(pageParams.containsKey('customer_type')){
            selectedCustomerType = pageParams.get('customer_type');
            searchCondition += ' AND Display_Ecom_Customer_Type__c INCLUDES(\''+selectedCustomerType+'\') ';
        }
    }

    /**************************************************************************************************************
     *  queryProducts: method to return the list of products that will be displayed in the page                   *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    private void queryProducts()
    {
        //-- Fetch ecom Products
        allProducts = Product_Sel.getEComProduct(null, false, searchCondition, sortBy); 

        for(EComProduct_DTO prod : allProducts)
        {
            prod.ProductDesc = '';
        }

         //-- Back to 1st page if product exist 
        if(allProducts.size() > 0) 
            currentPageNumber = 1;


        totalNumberOfPages = (Math.mod(allProducts.size(), MAX_PRODUCTS_PER_PAGE) == 0 ) ?   (Integer)Math.ceil(allProducts.size() / MAX_PRODUCTS_PER_PAGE)  :   1+ (Integer)Math.ceil(allProducts.size() / MAX_PRODUCTS_PER_PAGE);

        pages = new List<Integer>();
        if(totalNumberOfPages > 0)
            for(Integer x = 1; x <= totalNumberOfPages; x++)
                pages.add(x);
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
        if(max > totalNumberOfProducts)
            max =  totalNumberOfProducts; 

        showPrevious =(currentPageNumber > 1);
        showNext = (currentPageNumber < totalNumberOfPages);

        products = new List<EComProduct_DTO>();
        for(Integer x= 0; x<allProducts.size(); x++)
            if(min <= x   && x <= max)
                products.add(allProducts[x]);
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

            if(fw.type_x =='PICKLIST')
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
     *  refine: method calls when customer clicks on Refine button                                                *
     *  Author: David Daboué                                                                                      *  
     **************************************************************************************************************/
    public void refine()
    {
        buildQueryConditions();

        if(String.isNotBlank(selectedFilters))
        {
            List<String> lst_selected_filters =  selectedFilters.split(':');
            Map<String, List<String>> filterConditions = new Map<String, List<String>>(); 
            for(String filter : lst_selected_filters)
            {
                List<String> filter_parts = filter.split('\\|');
                List<String> tmp = (filterConditions.containsKey(filter_parts[0])) ? filterConditions.get(filter_parts[0]) : new List<String>(); 
                    tmp.add(filter_parts[1]);

                filterConditions.put(filter_parts[0], tmp);
            }

            Map<String, String> fieldType = new Map<String, String>(); //fild => type
            for(FilterWrapper fw : filters)
            {
                fieldType.put(fw.field, fw.type_x);
            }

            for(String field : filterConditions.keySet())
            {
                if(fieldType.get(field) == 'STRING')
                {
                    searchCondition += ' AND ' + field + ' LIKE \'%'+String.join(filterConditions.get(field), '') +'%\' ';
                }
                else
                {
                    String s = (fieldType.get(field) == 'BOOLEAN')  ? String.join(filterConditions.get(field), ' , ') : '\'' + String.join(filterConditions.get(field), '\' , \'') + '\'';
                    searchCondition += ' AND ' + field + ' IN ('+s+') ';
                }                
            }
        } 

        System.debug('searchCondition::'+searchCondition);  

        queryProducts();
        refreshDisplayedProducts();
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
}