public class ISSP_Ctrl_ContentPage
{
  //Global Variables
  public String UserPortalStatus {get;set;}
  public String UserPortalCountry {get;set;}
  public String UserPortalRegion {get;Set;}
  public String UserPortalAccountSector {get;set;}
  public String PortalUserId {get;set;}
  public List<ContentVersion> allCV;
  public List<SelectOption> paginationSizeOptions{get;set;}


  //Library section
  public ContentWorkspace ContentWorkspace ;
  public String DocId = '';

  // the soql without the order and limit
  private String soql {get;set;}
  public ApexPages.StandardSetController setCon {get;set;}
  public String search {get;set;}
  public String selectedValCat {get;set;}
  public String selectedValPub {get;set;}

  public List<ContentVersion> getContentVersions() {      
      return (List<ContentVersion>) setCon.getRecords();
    }

  public Integer currentPageNumber{get;set;}
  public List<Integer> pageList{get;set;}
  public Integer size{get;set;}

  public String csHost {get;set;}
  
  public String UserPortalCategory;
  public String UserPortalRecodType;
  // List of names of the libraries with visibility
  public List<String> AccessLibraryName;
  // set of ids of the libraries with visibility
  public Set<Id> DocIds_set = new Set<Id>();
  public Set<Id> PublicDocIds_set = new Set<Id>();

  public List<SelectOption> allCountriesList {get;set;}
  public List<SelectOption> allFileTypesList {get;set;}
  public List<SelectOption> allDocumentCategoryList {get;set;}
  public List<SelectOption> allLanguagesList {get;set;}

  //CNS
  public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}

  //Constructor
  public ISSP_Ctrl_ContentPage(){
    size=10;
        paginationSizeOptions = new List<SelectOption>();
        paginationSizeOptions.add(new SelectOption('10','10'));
        paginationSizeOptions.add(new SelectOption('25','25'));
        paginationSizeOptions.add(new SelectOption('50','50'));
        paginationSizeOptions.add(new SelectOption('100','100'));
    search = '';
    selectedValPub = '';
    selectedValCat = '';
    Init();
  }

  //Initialize Variables and Parameters
  public void Init(){
    currentPageNumber = 1;    
    List<ContentWorkspaceDoc> ContentWorkspaceDoc_Lst;

    List<ContentWorkspaceDoc> PublicDocs_list;

    User tmpPortalUSer = [select Id , ContactId From User Where id =: userinfo.getuserid()];
    ISSP_CS__c cs = ISSP_CS__c.getInstance('Host');
    String csHost = cs.value__c;

    //Get Parameters ACcording to the Contact Related to User
    Contact PortalContact = [select Id ,Name, Status__c ,User_Portal_Status__c,OwnerId ,Account.BillingCountry ,Account.sector__c, Account.Category__c, Account.RecordType.Name,
                             Account.IATA_ISO_Country__r.Name ,Account.IATA_ISO_Country__r.Region__c
                             From Contact
                             where Id =: tmpPortalUSer.ContactId][0];

    system.debug('KER0  PortalContact '+PortalContact);

  /////////////////////////////////////////////////
  //Prepare Permissions parameters
  //STATUS
  UserPortalStatus  = PortalContact.User_Portal_Status__c ;
  if (UserPortalStatus == null){
      UserPortalStatus = 'NoStatusValue';
  }

  //COUNTRY
  UserPortalCountry = String.escapeSingleQuotes(PortalContact.Account.IATA_ISO_Country__r.Name);
  if (UserPortalCountry == null){
      UserPortalCountry = 'NoCountryValue';
  }

  //SECTOR (ACCOUNT)
  UserPortalAccountSector   = PortalContact.Account.sector__c;
  if (UserPortalAccountSector == null){
      UserPortalAccountSector = '';
  }

  //REGION
  UserPortalRegion = PortalContact.Account.IATA_ISO_Country__r.Region__c;

  //CATEGORY (ACCOUNT)
  UserPortalCategory = PortalContact.Account.Category__c;

  //RECORD TYPE (ACCOUNT)
  UserPortalRecodType = PortalContact.Account.RecordType.Name;

  /////////////////////////////////////////////////

    PortalUserId = tmpPortalUSer.Id;

    system.debug('KER0  UserPortalStatus '+UserPortalStatus);
    system.debug('KER0  UserPortalCountry '+UserPortalCountry);
    system.debug('KER0  UserPortalRegion '+UserPortalRegion);
    system.debug('KER0  UserPortalAccountSector '+UserPortalAccountSector);
    system.debug('KER0  Category  '+ UserPortalCategory);
    system.debug('KER0  RecordType '+ UserPortalRecodType);

  // Custom Setting to control the visibility on Libraries
  List<Access_to_Libraries_on_Portal__c> accessToLibrariesCS = Access_to_Libraries_on_Portal__c.getAll().values();
  AccessLibraryName = new List<String>();

  system.debug('susana accessToLibrariesCS : ' + accessToLibrariesCS.size());

  Boolean isCNS = ISSP_Utilities.isCNS();

  //get library names which can be visible based on account sector and record type
  for(Access_to_Libraries_on_Portal__c a : accessToLibrariesCS){
      system.debug('susana accessToLibrariesCS group : ' + a);
      if(!isCNS && ((a.Category_of_Account__c == UserPortalCategory && a.Sector_of_Account__c == UserPortalAccountSector && a.Record_Type_of_Account__c == UserPortalRecodType) ||
          a.Category_of_Account__c == 'All' && a.Sector_of_Account__c == UserPortalAccountSector && a.Record_Type_of_Account__c == UserPortalRecodType) ){

          system.debug('CS group match');
          String libs = String.valueOf(a.Library_visibility__c);
          system.debug('susana libraries : ' + libs);
          for(String lib : libs.split(',')){
            AccessLibraryName.add(lib);
          }
      }
    }

    system.debug('susana names of the libraries : ' + AccessLibraryName);

    //get library ids
    if(AccessLibraryName != null || !AccessLibraryName.isEmpty()){
            ContentWorkspaceDoc_Lst = new List<ContentWorkspaceDoc>
                                      ([select Id ,ContentDocumentId ,ContentWorkspaceId
                                        from ContentWorkspaceDoc
                                        where ContentWorkspaceId =: [select Id from ContentWorkspace where Name IN: AccessLibraryName]]);

            if(ContentWorkspaceDoc_Lst != null && ContentWorkspaceDoc_Lst.size() > 0){
                system.debug('susana ContentWorkspaceDoc_Lst size : ' + ContentWorkspaceDoc_Lst.size());

                for(ContentWorkspaceDoc libId : ContentWorkspaceDoc_Lst){
                    DocId = libId.ContentDocumentId;
                    system.debug('susana DocId : ' + DocId);
                    DocIds_set.add(DocId);
                    system.debug('susana ids of the documents : '+DocId);
                }

            }
    }

    system.debug('susana DocIds_set : ' + DocIds_set);

    if (UserPortalAccountSector == 'General Public'){
      PublicDocs_list = [select ContentDocumentId from ContentWorkspaceDoc where ContentWorkspace.Name = 'Public' ];
      system.debug('susana documents General Public : '+PublicDocs_list);
    }
    else {
      PublicDocs_list = [select ContentDocumentId from ContentWorkspaceDoc where ContentWorkspace.Name = 'Public' OR ContentWorkspace.Name = 'Third Party'];
      system.debug('susana documents General Public and Third Party : '+PublicDocs_list);
    }

    for(ContentWorkspaceDoc doc : PublicDocs_list)
       PublicDocIds_set.add(doc.ContentDocumentId);

      system.debug('susana PublicDocIds_set : ' + PublicDocIds_set);
    string filterSearch = '';
    
    if(search!='' && search != null && String.isNotBlank(search)){
      system.debug('##RN search: ' + search);
      filterSearch = 'and (Title like \'' + '%' + search +'%' +'\' or Description like \'' + '%'  +search +  '%' +'\' or Country_of_publication__c includes (\'' +search +   '\') or Language__c = \'' +search +'\')'; 
    }
    string filterCat = '';
    string filterCountryP = '';
    system.debug('##RN selectedValCat: ' + selectedValCat);
    if(selectedValCat!='' && selectedValCat != null && String.isNotBlank(selectedValCat)){
      system.debug('##RN filterCat: ' + filterCat);
      filterCat = ' and Document_Category__c = \'' + selectedValCat + '\'';
    }

    if(selectedValPub!='' && selectedValPub != null && String.isNotBlank(selectedValPub)){
      filterCountryP = ' and Country_of_publication__c includes (\'' + selectedValPub  + '\')';
    }

   // init the controller and display some sample data when the page loads
    soql = 'select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl '+
         ' From ContentVersion '+
         ' Where IsLatest = true '+
         ' AND User_status_access__c includes (\''+String.escapeSingleQuotes(UserPortalStatus)+'\')'+
         ' AND ((ContentDocumentId IN: DocIds_set'+
         ' AND Country_visibilty__c includes (\'All - Globally\',\''+String.escapeSingleQuotes(UserPortalCountry)+'\', \'All - Region '+String.escapeSingleQuotes(UserPortalRegion)+'\'))'+
         ' OR (ContentDocumentId IN: PublicDocIds_set))' + filterSearch + filterCat + filterCountryP;


    system.debug('susana soql ' + soql);
    setCon = new ApexPages.StandardSetController(sortContentVersions(Database.query(soql)));
    system.debug('##RN: ' + Database.query(soql));
 //   system.debug('##RN setCon.getRecords(): ' + setCon.getRecords().size);
    //ContentVersions = sortContentVersions(;
    system.debug('susana ContentVersions : ' + getContentVersions());

    allCountriesList = getPicklistValues('ContentVersion', 'Country_of_publication__c');
    allLanguagesList = getPicklistValues('ContentVersion', 'Language__c');
    allFileTypesList = getPicklistValues('ContentVersion', 'FileType');
    allDocumentCategoryList = getPicklistValues('ContentVersion', 'Document_Category__c');
    refreshPageSize();

}
    /*
    private List<String> getPicklistValuesFromField(SObject field){
        List<String> options = new List<String>();

        Schema.DescribeFieldResult fieldResult = ContentVersion.field.getDescribe();

        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();

        for(Schema.PicklistEntry f : ple){
          options.add(f.getValue());
        }

        system.debug('susana options : ' + options);
        return options;
    }*/

    public static List<SelectOption> getPicklistValues(String ObjectApi_name,String Field_name){

      List<SelectOption> lstPickvals=new  List<SelectOption>();
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
      Sobject Object_name = targetType.newSObject();
      Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
      lstPickvals.add(new SelectOption('','-None-'));
        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(new SelectOption(a.getValue(),a.getValue()));//add the value  to our final list
        }

      return lstPickvals;
    }



    private List<ContentVersion> sortContentVersions(List<ContentVersion> docs){

        List<ContentVersion> retDocs = new List<ContentVersion>();
        Set<Integer> excludeIndexes = new Set<Integer>();
        Integer currentIndex = 0;

        // add from user country (exact match)
        for(ContentVersion doc : docs){

            if(doc.Country_of_publication__c != null && doc.Country_of_publication__c.equals(String.escapeSingleQuotes(UserPortalCountry))){

                retDocs.add(doc);
                excludeIndexes.add(currentIndex);
            }

            currentIndex++;
        }

        // add from user country (not exact match)
        currentIndex = 0;
        for(ContentVersion doc : docs){

            if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false && doc.Country_of_publication__c.contains(String.escapeSingleQuotes(UserPortalCountry))){

                retDocs.add(doc);
                excludeIndexes.add(currentIndex);
            }

            currentIndex++;
        }

        // add from region
        currentIndex = 0;
        for(ContentVersion doc : docs){

            if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false && doc.Country_of_publication__c.contains(String.escapeSingleQuotes(UserPortalRegion))){

                retDocs.add(doc);
                excludeIndexes.add(currentIndex);
            }

            currentIndex++;
        }

        // add from all global
        currentIndex = 0;
        for(ContentVersion doc : docs){

            if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false && doc.Country_of_publication__c.contains('All - Globally')){

                retDocs.add(doc);
                excludeIndexes.add(currentIndex);
            }

            currentIndex++;
        }

        // add from all other not blank
        currentIndex = 0;
        for(ContentVersion doc : docs){

            if(doc.Country_of_publication__c != null && excludeIndexes.contains(currentIndex) == false){

                retDocs.add(doc);
                excludeIndexes.add(currentIndex);
            }

            currentIndex++;
        }

        // add other
        currentIndex = 0;
        for(ContentVersion doc : docs){

            if(excludeIndexes.contains(currentIndex) == false){

                retDocs.add(doc);
            }

            currentIndex++;
        }

        return retDocs;
    }

    public void currentPage(){
      setCon.previous();
    }

    //Returns the previous page of records
    public void previous()
    {
        Integer pageNum = setCon.getPageNumber();
        currentPageNumber = pageNum-1;
        setCon.previous();
    }
 
    //Returns the next page of records
    public void next()
    {
        Integer pageNum = setCon.getPageNumber();
        currentPageNumber = pageNum+1;
        system.debug('##RN next: ' + currentPageNumber);
        setCon.next();
    }

    //Page number of the current displaying records
    public Integer pageNumber
    {
        get
        {
            return setCon.getPageNumber();
        }
        set{
          system.debug('##RN: ' + pageNumber);
        }
    }

    public Integer pageSize{
       get
        {
            return setCon.getPageSize();
        }
        set;
    }

    /** total number of pages for page */
    public Integer getTotalPages(){
     Decimal totalSize = setCon.getResultSize();
     Decimal pageSize = setCon.getPageSize();
     Decimal pages = totalSize/pageSize;
     return (Integer)pages.round(System.RoundingMode.CEILING);
    }

    public void first() {
       setCon.first();
    }

    public void last() {
       setCon.last();
    }

    public Boolean hasNext
    {
        get
        {
            return setCon.getHasNext();
        }
        set;
    }
 
    //Boolean to check if there are more records before the present displaying records
    public Boolean hasPrevious
    {
        get
        {
            return setCon.getHasPrevious();
        }
        set;
    }

     //Changes the size of pagination
    public PageReference refreshPageSize() {
         currentPageNumber = 1; 
         setCon.setPageSize(size);
         return null;
    }


    public PageReference navigateToPage() {
      system.debug('##RN setCon.PageNumber: ' + setCon.getPageNumber());
      system.debug('##RN pageNumber: ' + currentPageNumber);
         setCon.setPageNumber(currentPageNumber);
         return null;
    }

    public List<Integer> getPageNumberButtons(){      
    system.debug('##RN getPageNumberButtons');
    pageList = new List<Integer>();     
        for(Integer i=1; i<getTotalPages()+1;i++){
            pageList.add(i);
        }
        return pageList;
    }
}