/******************************************************************************************************************
 *  IEC_ProductListController: IEC_ProductList page Controller                                                    *
 *  Author: David Daboué - CGI                                                                                    *
 ******************************************************************************************************************/
public with sharing class IEC_ProductListController extends IEC_PageController {
    /**************************************************************************************************************
     *  Wrapper class to display the filters for refinement                                                       *
     **************************************************************************************************************/
    public class FilterWrapper {
        public String field {get; set;}
        public String label {get; set;}
        public String type_x {get; set;}
        public List<SelectOption> values {get; set;}

        public FilterWrapper() {}
    }

    //Page parameters
    public Map<String, String> pageParams;
    public String selectedTopic {get; set;}
    public String selectedTopicLabel {get; set;}
    public String selectedCustomerType {get; set;}

    //Products available
    public List<EComProduct_DTO> allProducts;


    private String searchCondition;
    public Integer totalNumberOfPages {get; set;}
    public List<Integer> pages {get; set;}

    //Products displayed
    public List<EComProduct_DTO> products { get; set; }

    private String userAgent {get; set;}
    public static final Integer MAX_PRODUCTS_PER_PAGE = Utility.getIntegerSetting('PRODUCT_LIST_PAGE_SIZE_LIMIT');// 12;

    public Boolean showPrevious {get; set;}
    public Boolean showNext {get; set;}
    public Integer currentPageNumber {get; set;}

    public String sortBy {get; set;}
    public List<SelectOption> sortingFields {get; set;}

    public List<FilterWrapper> filters {get; set;}

    public String selectedFilters {get; set;}
    public String pageNumber {get; set;}

    //susana
    private final Product2 prods;
    public List<EComProduct_DTO> productList {get; set;}

    /**************************************************************************************************************
     *  IEC_ProductListController: Class Constructor                                                              *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    public IEC_ProductListController() {
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
    public PageReference onLoadAction() {
        system.debug('onLoadAction');
        buildQueryConditions();
        getProductRecordsList();
        //queryProducts();

        //refreshDisplayedProducts();

        //--Advance search filters
        buildRefinementFilters();



        return null;
    }

    /**************************************************************************************************************
     *   buildQueryConditions: method to set dynamically the products query parameters                            *
     *   Author: David Daboué                                                                                     *
     **************************************************************************************************************/
    private void buildQueryConditions() {
        system.debug('buildQueryConditions');
        //Set default Mega Menu to Publication
        selected_category = (pageParams != null && pageParams.containsKey('category')) ? pageParams.get('category') : 'publications';

        Set<String> validCategories = new Set<String>();
        for (SelectOption so : categories)
            validCategories.add(so.getValue());

        if (!validCategories.contains(selected_category)) selected_category = 'publications';

        for (SelectOption so : categories) {
            if (so.getValue() == selected_category) {
                selectedCategory = so;
                break;
            }
        }

        //-- Query products
        searchCondition = '  Mega_Menu__c=\'' + selected_category + '\' ';

        if (pageParams.containsKey('topic')) {
            selectedTopic = pageParams.get('topic');
            searchCondition += ' AND Display_Ecom_Topic__c INCLUDES(\'' + selectedTopic + '\') ';
            if (subCategories.containsKey(selected_category))
                for (SelectOption so : subCategories.get(selected_category))
                    if (so.getValue() == selectedTopic) {
                        selectedTopicLabel = so.getLabel();
                        break;
                    }
        }

        if (pageParams.containsKey('customer_type')) {
            selectedCustomerType = pageParams.get('customer_type');
            searchCondition += ' AND Display_Ecom_Customer_Type__c INCLUDES(\'' + selectedCustomerType + '\') ';
        }

        system.debug('buildQueryConditions - searchCondition : ' + searchCondition);
    }

    /**************************************************************************************************************
     *  sortProducts: method calls when customer change the sort by value                                         *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    public void sortProducts() {
        //queryProducts();
        system.debug('sortProducts');
        productRecords = new ApexPages.StandardSetController(Product_Sel.getListOfProducts(null, false, searchCondition, sortBy, true));
        // sets the number of records to show in each page view
        productRecords.setPageSize(12);
        //refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  buildRefinementFilters: method used to initialize the refinement filters                                  *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    private void buildRefinementFilters() {
        system.debug('buildRefinementFilters');
        //-- Get list of fields for refinement
        List<Schema.FieldSetMember> fields  = Utility.readFieldSet('Product2', 'ECOM_Refinement_FIelds');
        filters = new List<FilterWrapper>();

        for (Schema.FieldSetMember field : fields) {
            FilterWrapper fw = new FilterWrapper();
            fw.field    = field.getFieldPath();
            fw.label    = field.getLabel();
            fw.type_x   = field.getType().name();

            /*if (fw.field == 'Inventory_Status__c') {
                FilterWrapper fw2 = new FilterWrapper();
                fw2.field = field.getFieldPath() + '1';
                fw2.type_x = field.getType().name();

                fw.label  = 'Print';
                fw2.label = 'Digital';

                fw.values = new List<SelectOption>();
                fw.values.add(new SelectOption('In stock', 'In stock'));
                fw.values.add(new SelectOption('Out of stock', 'Out of stock'));

                fw2.values = new List<SelectOption>();
                fw2.values.add(new SelectOption('Available Now', ' Available Now'));
                fw2.values.add(new SelectOption('Coming Soon', 'Coming Soon'));

                filters.add(fw2);
            } else 
            */
            if (fw.type_x == 'PICKLIST') {
                fw.values = Utility.getPicklistSelectOptions('Product2', fw.field, false);
            } else if (fw.type_x == 'BOOLEAN') {
                fw.values = new List<SelectOption>();
                fw.values.add(new SelectOption('true', 'Yes'));
                fw.values.add(new SelectOption('false', 'No'));
            }

            filters.add(fw);
        }
        system.debug('### buildRefinementFilters filters :: ' + filters);
    }

    /**************************************************************************************************************
     *  refine: method calls when customer clicks on Refine button                                                *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    public void refine() {
        system.debug('refine start');
        buildQueryConditions();

        if (String.isNotBlank(selectedFilters)) {
            system.debug('### lst_selected_filters:: ' + selectedFilters);
            List<String> lst_selected_filters =  selectedFilters.split(':');
            Map<String, List<String>> filterConditions = new Map<String, List<String>>();
            for (String filter : lst_selected_filters) {
                List<String> filter_parts = filter.split('\\|');
                List<String> tmp = (filterConditions.containsKey(filter_parts[0])) ? filterConditions.get(filter_parts[0]) : new List<String>();
                tmp.add(filter_parts[1]);

                filterConditions.put(filter_parts[0].replace('Inventory_Status__c1', 'Inventory_Status__c'), tmp);
            }

            Map<String, String> fieldType = new Map<String, String>(); //fild => type
            for (FilterWrapper fw : filters) {
                fieldType.put(fw.field.replace('Inventory_Status__c1', 'Inventory_Status__c'), fw.type_x);
            }

            for (String field : filterConditions.keySet()) {
                if (fieldType.get(field) == 'STRING') {
                    searchCondition += ' AND ' + field + ' LIKE \'%' + String.join(filterConditions.get(field), '') + '%\' ';
                } else {
                    String s = (fieldType.get(field) == 'BOOLEAN')  ? String.join(filterConditions.get(field), ' , ') : '\'' + String.join(filterConditions.get(field), '\' , \'') + '\'';
                    searchCondition += ' AND ' + field + ' IN (' + s + ') ';
                }
            }
        }

        System.debug('searchCondition::' + searchCondition);

        productRecords = new ApexPages.StandardSetController(Product_Sel.getListOfProducts(null, false, searchCondition, sortBy, true));
        // sets the number of records to show in each page view
        productRecords.setPageSize(12);
        //refreshDisplayedProducts();
        system.debug('refine end');
    }

    /**************************************************************************************************************
     *  gotoNext: method calls when customer clicks on Next button in the pagination section                      *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    public void gotoNext() {
        next();
        //refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  gotoPrevious: method calls when customer clicks on Previous button in the pagination section              *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    public void gotoPrevious() {
        previous();
        //refreshDisplayedProducts();
    }

    /**************************************************************************************************************
     *  gotoPage: method call when customer clicks on a specific page number in the pagination section            *
     *  Author: David Daboué                                                                                      *
     **************************************************************************************************************/
    public void gotoPage() {
        String pageNum = ApexPages.currentPage().getParameters().get('pageNum');
        currentPageNumber = Integer.valueOf(pageNum);
        //refreshDisplayedProducts();
        productRecords.setpageNumber(currentPageNumber);
    }

    //susana
    public IEC_ProductListController(ApexPages.StandardSetController controller) {
        system.debug('IEC_ProductListController 1');
        this.prods = (Product2)controller.getRecord();
    }

    public ApexPages.StandardSetController productRecords {
        get {
            system.debug('productRecords start');
            if (productRecords == null) {
                system.debug('productRecords is null');
                productRecords = new ApexPages.StandardSetController(Product_Sel.getListOfProducts(null, false, searchCondition, sortBy, true));
                // sets the number of records to show in each page view
                productRecords.setPageSize(12);
            }
            system.debug('### productRecords :: ' + productRecords.getRecords());
            system.debug('### productRecords size :: ' + productRecords.getRecords().size());
            system.debug('productRecords end');
            return productRecords;
        }
        private set;
    }

    public List<EComProduct_DTO> getProductRecordsList() {
        system.debug('### productRecordsList start ');
        List<Product2> listFilteredProduct;
        Map<String, Map<String, String>> mapPickList_Label = new Map<String, Map<String, String>>();
        Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();
        Product_Sel exe = new Product_Sel();
        productList = new List<EComProduct_DTO>();

        String customerType = User_Sel.getCustomerType(UserInfo.getUserId());
        system.debug('### productRecordsList customerType :: ' + customerType);

        // Filter products based on compliance requirements
        Contact contactCurrent = IECUserManager.getContact();
        if (contactCurrent != null) {
            Set<String> setCountry = new Set<String>();

            if (contactCurrent.MailingCountry != null) setCountry.add(contactCurrent.MailingCountry);
            if (contactCurrent.Account.ShippingCountry != null) setCountry.add(contactCurrent.Account.ShippingCountry);
            if (contactCurrent.Account.BillingCountry != null) setCountry.add(contactCurrent.Account.BillingCountry);

            listFilteredProduct = new List<Product2>();
            Boolean bAddProduct;

            system.debug('### productRecordsList productRecords.getRecords() :: ' + productRecords.getRecords());
            for (Product2 prod : (List<Product2>) productRecords.getRecords()) {
                if (prod.Non_Compliance_Countries__r == null) {
                    listFilteredProduct.add(prod);
                } else {
                    bAddProduct = true;

                    for (Non_Compliant_Country__c country : prod.Non_Compliance_Countries__r) {
                        if (setCountry.contains(country.IATA_ISO_Country__r.Name) && !country.Display_in_E_Com__c) {
                            bAddProduct = false;
                            break;
                        }
                    }

                    if (bAddProduct)
                        listFilteredProduct.add(prod);

                    system.debug('listFilteredProduct...');
                }
            }
        } else {
            system.debug('getProductRecordsList else');
            listFilteredProduct = (List<Product2>) productRecords.getRecords();
        }

        if (listFilteredProduct.size() > 0) {
            totalNumberOfPages = getTotalPages();
            if (currentPageNumber == null) currentPageNumber = 1;
            showPrevious = (currentPageNumber > 1);
            showNext = (currentPageNumber < totalNumberOfPages);
        }

        pages = new List<Integer>();
        if (totalNumberOfPages > 0)
            for (Integer x = 1; x <= totalNumberOfPages; x++)
                pages.add(x);

        system.debug('### productRecordsList listFilteredProduct :: ' + listFilteredProduct);
        // Filter price info for products not related to Phase 1& 2 products only
        for (Product2 p : listFilteredProduct) {
            if (p.IEC_Product_Information__c == null) {
                mapProductNumber_Price.put(p.SAP_Material_Number__c, null);
            }
        }

        mapProductNumber_Price = exe.getProductPriceInfo(mapProductNumber_Price.keySet(), customerType, null, null, true);
        system.debug('### productRecordsList mapProductNumber_Price :: ' + mapProductNumber_Price);

        //*** get picklist translations
        mapPickList_Label.put('Category', Utility.getPicklistValue_Label('Product2', 'Line_of_Business__c'));
        mapPickList_Label.put('Media', Utility.getPicklistValue_Label('Product2', 'Media__c'));
        mapPickList_Label.put('Language', Utility.getPicklistValue_Label('Product2', 'Language__c'));  //*** do not use Refinement_Language__c because less values
        mapPickList_Label.put('InvStatus', Utility.getPicklistValue_Label('Product2', 'Inventory_Status__c'));

        //*** build ECom products list
        for (Product2 p : listFilteredProduct)
            productList.add(new EComProduct_DTO(p, mapProductNumber_Price, mapPickList_Label, false, customerType));

        system.debug('### productRecordsList productList :: ' + productList);
        system.debug('### productRecordsList productList size :: ' + productList.size());
        system.debug('### productRecordsList end ');

        /*** ENHCS-2018-7 ***/
        List<Map<String, Object>> productsListWrapper = new List<Map<String, Object>>();
        Integer pos = 1;
        String lst = selectedCategory.getLabel() + ' > ' + (String.isBlank(selectedTopicLabel) ? 'All' : selectedTopicLabel);
        for (EComProduct_DTO prod : productList) {
            system.debug('prod_dto: ' + prod);

            Map<String, Object> prodObj = new Map<String, Object>();
            prodObj.put('id', prod.ProductNumber);
            prodObj.put('name', prod.ProductName);
            prodObj.put('category', prod.Portfolio);
            prodObj.put('price', prod.unitPrice == null ? 0.00 : prod.unitPrice);
            prodObj.put('brand', prod.ProductCategory);
            prodObj.put('list', lst);
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

        return productList;
    }


    /*** ENHCS-2018-7 ***/
    public String productListStr {get; set;}



    //Boolean to check if there are more records after the present displaying records
    public Boolean hasNext {
        get
        {
            return productRecords.getHasNext();
        }
        set;
    }

    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious {
        get
        {
            return productRecords.getHasPrevious();
        }
        set;
    }

    //Returns the previous page of records
    public void previous() {
        Integer pageNum = productRecords.getPageNumber();
        currentPageNumber = pageNum - 1;
        productRecords.previous();
    }

    //Returns the next page of records
    public void next() {
        Integer pageNum = productRecords.getPageNumber();
        currentPageNumber = pageNum + 1;
        productRecords.next();
        for (SObject p : productRecords.getRecords()) {
            system.debug(p);
        }

    }

    //Page number of the current displaying records
    public Integer pageNumbers {
        get
        {
            return productRecords.getPageNumber();
        }
        set;
    }

    /** total number of pages for page */
    Public Integer getTotalPages() {
        Decimal totalSize = productRecords.getResultSize();
        Decimal pageSize = productRecords.getPageSize();
        Decimal pages = totalSize / pageSize;
        return (Integer)pages.round(System.RoundingMode.CEILING);
    }

    public void first() {
        productRecords.first();
    }

    public void last() {
        productRecords.last();
    }

}