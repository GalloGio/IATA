public virtual class vfIECEBC_Abstract_List extends vfIECEBC_Controller {
    public static final Integer DEFAULT_ITEMS_PER_PAGE = 5;
    
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
        delete selectedItem;
        clear();
        return null;
    }
    
    public PageReference save() {
        update selectedItem;
        clear();
        return null;
    }
    
    public Integer page {
        get {
            if (page == null) page = 1;
            
            return page;
        }
        set {
            page = value;
            
            offset = (page * itemsPerPage) - itemsPerPage;
            
            items = null;
        }
    }
     
    public Integer maxPage {
        get {
            if (maxPage == null) maxPage = Integer.valueOf(Math.ceil(Double.valueOf(itemsCount) / Double.valueOf(itemsPerPage)));
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
                sortBy = 'CreatedDate ASC';
            }
            
            return sortBy;
        }
        set {
            sortBy = value;
            
            items = null;
        }
    }
    
    public virtual List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CreatedDate DESC','Creation Date'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited'));
        options.add(new SelectOption('Name ASC','Name'));
        
        return options;
    }

    public Integer offset {
        get {
            if (offset == null) offset = 0;
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
    private void clear() {
        itemsCount = null;
        items = null;
        maxPage = null;
        if (page > maxPage) {
            page = maxPage;
        }
    }
}