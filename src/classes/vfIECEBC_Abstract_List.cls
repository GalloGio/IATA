public virtual class vfIECEBC_Abstract_List extends vfIECEBC_Controller {
    public static Integer DEFAULT_ITEMS_PER_PAGE = 10;
   
    
    public static Integer itemsPerPage {
        get{
            if (itemsPerPage == null) {
                itemsPerPage = DEFAULT_ITEMS_PER_PAGE;
            }
            return itemsPerPage;
        }
        set;
    }

    public Id selectedItemId { get; set; } 
    public sObject selectedItem {
        get {
            if (selectedItem == null || selectedItem.Id != selectedItemId) {
            	Map<Id, sObject> itemsMapping = new Map<Id, sObject>(items);
                selectedItem = itemsMapping.get(selectedItemId);
            }
            
            return selectedItem;
        }
        set;
	}
    
    public PageReference deleteItem() {
        try {
            delete selectedItem;
            
        }catch (DMLException e){
            
        }
        resetPaging();
        
        clear();
        return null;
    }
    
    public PageReference save() {
        try {
            update selectedItem;
        }catch (DMLException e){
            
        }
        
        clear();
        return null;
    }
    
    public Integer page {
        get {
            if (page == null || page == 0) page = 1;
            if (page > maxPage) page = MaxPage;
            return page;
        }
        set {
            page = value;
            
            offset = null;
            
            items = null;
        }
    }
     
    public Integer maxPage {
        get {
            if (maxPage == null) maxPage = Integer.valueOf(Math.ceil(Double.valueOf(itemsCount) / Double.valueOf(itemsPerPage)));
            if (maxPage == 0) maxPage = 1;
            return maxPage;
        }
        private set;
    }
    
    public List<SelectOption> getPageOptions() {
        List<SelectOption> options = new List<SelectOption>();
        
        for(Integer i = 1; i<=maxPage; i++) {
            options.add(new SelectOption(String.valueOf(i), String.valueOf(i)));
        }
        
        return options;
    }
    
    class Controller_Exception extends Exception{}
    
    public String sortBy {
        get {
            if (sortBy == null) {
                sortBy = 'CreatedDate DESC ';
            }
            
            return sortBy;
        }
        set {
            sortBy = value;
            
            items = null;
        }
    }
    private virtual Boolean getIsFirstTimeLoadPage() { return true; }
    public virtual List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (getIsFirstTimeLoadPage()) options.add(new SelectOption('CreatedDate DESC ','Sort by', true));
        options.add(new SelectOption('CreatedDate DESC','Creation Date'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited'));
        options.add(new SelectOption('Name ASC','Name'));

        return options;
       
    }

    public Integer offset {
        get {
            if (offset == null) offset = (page * itemsPerPage) - itemsPerPage;
            return offset;
        }
        set;
    }
    
    private virtual String getQuery(Boolean isCountOnly) { return null; }
    
    public Integer itemsCount {
        get {
            if (itemsCount == null) itemsCount = Database.countQuery(getQuery(true));
            
            return itemsCount;
        }
        set;
    }
    
    public List<sObject> items {
        get {
            if (items == null) {
                String query = getQuery(false) + ' ORDER BY ' + sortBy + ' LIMIT ' + itemsPerPage + ' OFFSET ' + offset;
                System.debug(query);
                items = Database.query(query);
            }
            return items;
        }
        private set;
    }
    
    public void resetQuery() {
        clear();
        page = 1;
    }
    public void resetPaging() {
        itemsCount = null;
        items = null;
        maxPage = null;
        offset = null;
        //page = 1;
    }
    public void clear() {
        itemsCount = null;
        items = null;
        maxPage = null;
        offset = null;
        if (page > maxPage) {
            page = maxPage;
        }
    }
}