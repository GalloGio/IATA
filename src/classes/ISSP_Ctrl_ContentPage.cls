public class ISSP_Ctrl_ContentPage
{
  //Global Variables
  public String UserPortalStatus {get;set;}
  public String UserPortalCountry {get;set;}
  public String UserPortalRegion {get;Set;} 
  public String UserPortalAccountSector {get;set;}
  public String PortalUserId {get;set;}
  
  public String Title {get;set;}

  //Library section
  public ContentWorkspace ContentWorkspace ;
  public String LibraryId = '';
  public String LibraryName {get;set;}
  
  //List Holds ContentVirsions for Sector Filtering
  public List<ContentVersion> tmpContentVersion_Lst;

   //set Holds ContentVirsions for Country Filtering
  public set<ContentVersion> tmpContentVersion_set ;

 
  // the soql without the order and limit
  private String soql {get;set;}

  // the collection of contacts to display
  public List<ContentVersion> ContentVersions {get;set;}

  // SPRINT6 Content modification
  public ContentVersion cont_ContentVersion { get; set; }

  public String csHost {get;set;}


  // format the soql for display on the visualforce page
 /* public String debugSoql {
    get { return soql + ' order by ' + sortField + ' ' + sortDir + ' limit 20'; }
    set;
  }*/
  
  public String UserPortalCategory;
  public String UserPortalRecodType;
  // List of names of the libraries with visibility
  public List<String> AccessLibraryName;
  // set of ids of the libraries with visibility
  public Set<Id> libraryIds_set;

  private String sortDirection = 'ASC';
  private String sortExp = 'LastModifiedDate';
  

  //Consetructor
  public ISSP_Ctrl_ContentPage(){
    Init();
  }

  //Initialize Variables and Parameters
  public void Init(){
    List<ContentWorkspace> ContentWorkspace_Lst;
    
    User tmpPortalUSer = [select Id , ContactId From User Where id =: userinfo.getuserid()];
  ISSP_CS__c cs = ISSP_CS__c.getInstance('Host');
    String csHost = cs.value__c;

    //Get Parameters ACcording to the Contact Related to User 
    Contact PortalContact = [select Id ,Name, Status__c ,User_Portal_Status__c,OwnerId ,Account.BillingCountry ,Account.sector__c, Account.Category__c, Account.RecordType.Name,
                             Account.IATA_ISO_Country__r.Name ,Account.IATA_ISO_Country__r.Region__c
                             From Contact 
                             where Id =: tmpPortalUSer.ContactId][0]  ;

    system.debug('KER0  PortalContact '+PortalContact); 
  
  /////////////////////////////////////////////////
  //Prepare Permissions parameters
  //STATUS
    UserPortalStatus  = PortalContact.User_Portal_Status__c ;
  if (UserPortalStatus == null){
      UserPortalStatus = 'NoStatusValue';
    }
  //COUNTRY
    UserPortalCountry = PortalContact.Account.IATA_ISO_Country__r.Name ;
  if (UserPortalCountry == null){
      UserPortalCountry = 'NoCountryValue';
    }
  //SECTOR (ACCOUNT)
    UserPortalAccountSector   = PortalContact.Account.sector__c;
    if (UserPortalAccountSector == null){
      UserPortalAccountSector = '';
    }
  //REGION
  UserPortalRegion = PortalContact.Account.IATA_ISO_Country__r.Region__c ;
  
  //CATEGORY (ACCOUNT)
  UserPortalCategory = PortalContact.Account.Category__c;
  
  //RECORD TYPE (ACCOUNT)
  UserPortalRecodType = PortalContact.Account.RecordType.Name;
  
  /////////////////////////////////////////////////                       
    
    PortalUserId              = tmpPortalUSer.Id ;


    system.debug('KER0  UserPortalStatus '+UserPortalStatus);   
    system.debug('KER0  UserPortalCountry '+UserPortalCountry);   
    system.debug('KER0  UserPortalRegion '+UserPortalRegion);   
    system.debug('KER0  UserPortalAccountSector '+UserPortalAccountSector);   
    system.debug('KER0  Category  '+ UserPortalCategory);    
    system.debug('KER0  RecordType '+ UserPortalRecodType);

  // SPRINT6 Content modification
  cont_ContentVersion = new ContentVersion();
  cont_ContentVersion.Country_of_publication__c = UserPortalCountry ;
    // init the controller and display some sample data when the page loads
    soql = 'select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl '+
           ' From ContentVersion '+
           ' Where IsLatest = true '+
           ' AND User_status_access__c includes (\''+String.escapeSingleQuotes(UserPortalStatus)+'\')' ;  
    
    List<Access_to_Libraries_on_Portal__c> accessToLibrariesCS = Access_to_Libraries_on_Portal__c.getAll().values();
    AccessLibraryName = new List<String>();
    libraryIds_set = new Set<Id>();
 
    system.debug('accessToLibrariesCS : ' + accessToLibrariesCS.size());
    
    for(Access_to_Libraries_on_Portal__c a : accessToLibrariesCS){
      system.debug('CS group : ' + a);
      if( (a.Category_of_Account__c == UserPortalCategory && a.Sector_of_Account__c == UserPortalAccountSector && a.Record_Type_of_Account__c == UserPortalRecodType) || 
              a.Category_of_Account__c == 'All'&& a.Sector_of_Account__c == UserPortalAccountSector && a.Record_Type_of_Account__c == UserPortalRecodType){
          
          system.debug('CS group match');
          String libs = String.valueOf(a.Library_visibility__c);
          system.debug('libraries : ' + libs);
          for(String lib : libs.split(',')){
            system.debug('each library before : ' + lib);
            AccessLibraryName.add(lib);
            system.debug('each library after: ' + lib);
          }
      }
    }
    
    if(UserPortalAccountSector != null && ( AccessLibraryName == null || AccessLibraryName.isEmpty()) ){ 
        ContentWorkspace_Lst = new List<ContentWorkspace>([select Id ,Name from ContentWorkspace where Name =: UserPortalAccountSector]);
        if(ContentWorkspace_Lst != null && ContentWorkspace_Lst.size() > 0){ 
            LibraryId = ContentWorkspace_Lst[0].Id;
            libraryIds_set.add(LibraryId);
            LibraryName = ContentWorkspace_Lst[0].Name;
            system.debug('KER0 LibraryId '+LibraryId );
            runQueryAfterSearch(); 
        }
    }
    
    system.debug('before...'); 
    if(AccessLibraryName != null || !AccessLibraryName.isEmpty()){
      system.debug('size : ' + AccessLibraryName.size());
      for(String name : AccessLibraryName){
        system.debug('name : ' + name);
        ContentWorkspace_Lst = new List<ContentWorkspace>([select Id from ContentWorkspace where Name =: name]);
        if(ContentWorkspace_Lst != null){
          system.debug('ids libds : ' + ContentWorkspace_Lst.size());
          for(ContentWorkspace libId : ContentWorkspace_Lst){
              libraryIds_set.add(libId.Id);
              system.debug('id lib : ' + libId.Id);
               runQueryAfterSearch();
          }
        }
      }
        
    }


    //runQueryAfterSearch();

        system.debug('KER0  TagWrapper_Lst1 '+ContentVersions);
  }







  // runs the actual query
  public void runQuery() {
    
  }
  


  //Method Handles TAGS and Sector Filtering
  public void runQueryAfterSearch() {
    system.debug('KER0 START runQueryAfterSearch sortDir ' + sortExpression + ' sortField ' + sortDirection);
    try {
        //List Holds ContentVirsions for Sector Filtering
        tmpContentVersion_Lst = new List<ContentVersion>(); 
        
        //Run the soql Query
        ContentVersions = Database.query(soql + ' order by ' + sortExpression  + ' ' + sortDirection );//+ ' limit 20'
        system.debug('SFF Title'+Title);

        //Run Filter BY Country 
        FilterContentVersionByCountry();
        system.debug('SFF ContentVersions.size(02) ==> '+ContentVersions.size() + ' ContentVersions records ' + ContentVersions);
       
        //Run Filter By Library 
        FilterContentVersionBySector(UserPortalAccountSector ,libraryIds_set);
        system.debug('SFF ContentVersions.size(03) ==> '+ContentVersions.size());
       
        //Add all content in the public library
        if(Title != null && Title != ''){
          system.debug('SFF Search');
          AddAllPublicLibraryContent('Search');
        }else{
          system.debug('SFF Init');
          AddAllPublicLibraryContent('Init');
        }

        system.debug('SFF ContentVersions.size(04) ==> '+ContentVersions.size());
        
        if(ContentVersions != null && ContentVersions.size() > 0 ){
          if(Title != null){
            FilterContentVersionByFreeText();
          }

          system.debug('SFF cont_ContentVersion.Document_Category__c ==> '+cont_ContentVersion.Document_Category__c);
          system.debug('SFF cont_ContentVersion.Country_of_publication__c ==> '+cont_ContentVersion.Country_of_publication__c);
          if(cont_ContentVersion.Document_Category__c != null ||
             cont_ContentVersion.Country_of_publication__c != null){
              system.debug('SFF INNNN6 ');
              FilterContentVersionByDocumentCategory();
          }
          List<ContentVersion> tmpContentVersion_set1 = new List<ContentVersion>();
         
          integer count = 0 ;
          for(ContentVersion con : ContentVersions){
              if(count < 40 ){
                  tmpContentVersion_set1.add(ContentVersions[count]);
                  count++;
              }
          }

          if(tmpContentVersion_set1 != null && tmpContentVersion_set1.size() > 0){
                ContentVersions.clear();
                ContentVersions.addAll(tmpContentVersion_set1); 
            }else{
                ContentVersions.clear();
            }
        }
    } catch (Exception e) {
        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Ooops!'+e));
    }

  }

  // runs the search with parameters passed via Javascript
  public PageReference runSearch() {
    system.debug('KER0 runSearch START'+title );

    //////////////////////////////Search Dynamic Query SECTION//////////////////////////////
    soql = 'select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl '+
           ' From ContentVersion '+
           ' Where IsLatest = true '+
           ' AND User_status_access__c includes( \''+String.escapeSingleQuotes(UserPortalStatus)+'\') ' ;
    ///////////////////////////////////////////////////////////////////////

    system.debug('KER0 soql '+soql ); 
    // run the query again
    runQueryAfterSearch(); 
    
    system.debug('KER0 ContentVersions.size() RUNSEARCH END '+ContentVersions.size());
    return null;
  }
   
 

  public void FilterContentVersionBySector(String inUserPortalAccountSector ,Set<Id> inLibrary){
  
      //////////////////////////////LIBRARY SECTION//////////////////////////////
      if(inUserPortalAccountSector != null){ 

          Set<Id> set_contentworkspaceDoc = new Set<Id>();
          Set<Id> set_contentverIds = new Set<Id>();
          for(ContentWorkspaceDoc Content_WS_Doc : [select Id ,ContentDocumentId ,ContentWorkspaceId from ContentWorkspaceDoc where ContentWorkspaceId  IN: inLibrary ]){
              set_contentworkspaceDoc.add(Content_WS_Doc.ContentDocumentId);
          }
          
          system.debug('KER0 set_contentworkspaceDoc'+set_contentworkspaceDoc); 
          system.debug('KER0 set_contentworkspaceDoc.size()'+set_contentworkspaceDoc.size());
          
          for(ContentVersion cv : ContentVersions ){
              //system.debug('KER0 cv '+cv ); 
              if(set_contentworkspaceDoc.contains(cv.ContentDocumentId)){
                  set_contentverIds .add(cv.Id);
              }
          }
          ////////////////////////////////////
         /* List<ContentVersion > tmpContentVersion_Lst = new List<ContentVersion >([ select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c ,ContentUrl
                                    From ContentVersion 
                                    where IsLatest = true AND
                                        Id IN: set_contentverIds 
                                    Order by LastModifiedDate desc]) ;
          //sortExpression  + ' ' + sortDirection
          
          system.debug('KER0 tmpContentVersion_Lst   '+tmpContentVersion_Lst ); 
          system.debug('KER0 tmpContentVersion_Lst   .size()'+tmpContentVersion_Lst   .size()); 
          if(tmpContentVersion_Lst != null && tmpContentVersion_Lst.size() > 0){
              ContentVersions.clear();
              ContentVersions.addAll(tmpContentVersion_Lst);
          }else{
              ContentVersions.clear();
          }
          system.debug('KER0 ContentVersions  '+ContentVersions  ); 
          system.debug('KER0 ContentVersions.size()'+ContentVersions.size());
          ///////////////////////////////////////////////////////////////////////*/
      }else{
          ContentVersions.clear();
          ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Not Founud a Content with a Library that Matches account sector' ));
      }
       
  }

   public void FilterContentVersionByCountry(){

    //////////////////////////////Country ALL  SECTION//////////////////////////////
      system.debug('KER01 START ContentVersions ==> '+ContentVersions);
        tmpContentVersion_set = new set<ContentVersion>();
            for(ContentVersion cv : ContentVersions ){
              //system.debug('KER01 cv ==> '+cv);
              if(cv.Country_visibilty__c != null && cv.Country_visibilty__c.contains(UserPortalCountry)){
                    system.debug('KER01 INNNN');
                    tmpContentVersion_set.add(cv);
                    //break ;
                }else{
          if(cv.Country_visibilty__c != null && cv.Country_visibilty__c.contains(UserPortalRegion) ){
            tmpContentVersion_set.add(cv);
          }
        }
        if (cv.Country_visibilty__c != null && cv.Country_visibilty__c.contains('All - Globally'))
        {
          tmpContentVersion_set.add(cv);
        }
            }
            
            system.debug('KER0 tmpContentVersion_set   '+tmpContentVersion_set ); 
            if(tmpContentVersion_set != null && tmpContentVersion_set.size() > 0){
                ContentVersions.clear();
                ContentVersions.addAll(tmpContentVersion_set);
            }else{
                ContentVersions.clear();
            }
            tmpContentVersion_set.clear();
      system.debug('KER0 ContentVersions'+ContentVersions);
      system.debug('KER0 ContentVersions.size()'+ContentVersions.size());
      ///////////////////////////////////////////////////////////////////////
   }


   public void AddAllPublicLibraryContent(string inMode){
    system.debug('ADDING: ' + inMode);
    Set <Id> ContentDocumentIdSet = new Set <Id>();
      //////////////////////////////Add All Public Library Content SECTION//////////////////////////////
    List<ContentVersion> PublicLibraryContent = new List<ContentVersion>(); 
          
    List <ContentWorkspaceDoc> Content_WS_Doc_list = new List <ContentWorkspaceDoc>();
    //system.debug('UserPortalAccountSector: ' + UserPortalAccountSector);
    if (UserPortalAccountSector == 'General Public'){
      system.debug('running General Public');
      Content_WS_Doc_list = [select Id ,ContentDocumentId ,ContentWorkspaceId from ContentWorkspaceDoc where ContentWorkspace.Name = 'PUBLIC' ];
    }
    else{
            system.debug('running other');
            Content_WS_Doc_list = [select Id ,ContentDocumentId ,ContentWorkspaceId from ContentWorkspaceDoc where ContentWorkspace.Name = 'PUBLIC' OR ContentWorkspace.Name = 'Third Party'];
    }
    
    for(ContentWorkspaceDoc Content_WS_Doc : Content_WS_Doc_list){
            system.debug('in for Content_WS_Doc_list, adding: ' + Content_WS_Doc.ContentDocumentId);
            ContentDocumentIdSet.add(Content_WS_Doc.ContentDocumentId);
    }
    
    if(inMode == 'Init'){                   
      List <ContentVersion> cvList = [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl From ContentVersion Where IsLatest = true and ContentDocumentId IN :ContentDocumentIdSet];
      //for(ContentVersion cv : [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl From ContentVersion Where IsLatest = true and ContentDocumentId = :Content_WS_Doc.ContentDocumentId] )
      for (ContentVersion cv : cvList)
            {
        PublicLibraryContent.add(cv);
            }
        }
        else if(inMode == 'Search'){
      String TmpTitle = '%' + Title + '%';
            List <ContentVersion> cvList = [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl From ContentVersion Where IsLatest = true And (Title LIKE :TmpTitle OR Description LIKE : TmpTitle) and ContentDocumentId IN :ContentDocumentIdSet];
      //for(ContentVersion cv : [select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl From ContentVersion Where IsLatest = true And (Title LIKE :TmpTitle OR Description LIKE : TmpTitle) and ContentDocumentId = :Content_WS_Doc.ContentDocumentId] )
      for (ContentVersion cv : cvList)
      {
        PublicLibraryContent.add(cv);
            }
    }
    
    if(PublicLibraryContent != null && PublicLibraryContent.size() > 0)
    {
      system.debug('adding at the end');
      ContentVersions.addAll(PublicLibraryContent);
    }
      ///////////////////////////////////////////////////////////////////////
    }
 
  public void FilterContentVersionByDocumentCategory(){

  //////////////////////////////Country ALL  SECTION//////////////////////////////
      system.debug('Kerensen2 START FilterContentVersionByDocumentCategory ==> ' +cont_ContentVersion.Document_Category__c);
      system.debug('Kerensen2 START ContentVersions ==> '+ContentVersions);
            tmpContentVersion_set = new set<ContentVersion>();

            //runQueryAfterSearch();

            for(ContentVersion cv : ContentVersions ){
               system.debug('Kerensen2  cv.Document_Category__c ==> '+cv.Document_Category__c);
                if(cv.Document_Category__c != null &&
                   cont_ContentVersion.Document_Category__c != null &&
                   cont_ContentVersion.Document_Category__c != '' && 
                   cv.Document_Category__c.contains(cont_ContentVersion.Document_Category__c)){ 
                      system.debug('KER01 INNNN');
                      tmpContentVersion_set.add(cv);
                }     
              }
            
            system.debug('Kerensen2 tmpContentVersion_set   '+tmpContentVersion_set ); 
            if(tmpContentVersion_set != null && tmpContentVersion_set.size() > 0){
                ContentVersions.clear();
                ContentVersions.addAll(tmpContentVersion_set);
            }

            system.debug('Kerensen2 tmpContentVersion_set  ==> ' +tmpContentVersion_set);
            system.debug('Kerensen2 Document_Category__c  ==> ' +cont_ContentVersion.Document_Category__c);
            system.debug('Kerensen2 Country_of_publication__c ==> ' +cont_ContentVersion.Country_of_publication__c);
            if((tmpContentVersion_set == null || tmpContentVersion_set.size() < 1)  && cont_ContentVersion.Country_of_publication__c == null){
              system.debug('Kerensen2 INN Clear');
               ContentVersions.clear();
            } 

            if((tmpContentVersion_set == null || tmpContentVersion_set.size() < 1)  && cont_ContentVersion.Document_Category__c != null && cont_ContentVersion.Country_of_publication__c != null){
              system.debug('Kerensen2 INN Clear');
               ContentVersions.clear();
            } 
            system.debug('Kerensen2 ContentVersions'+ContentVersions);
            system.debug('Kerensen2 ContentVersions.size()'+ContentVersions.size());
            tmpContentVersion_set.clear();
            
            FilterContentVersionByCountryofpublication();
      system.debug('Kerensen2 ContentVersions'+ContentVersions);
      system.debug('Kerensen2 ContentVersions.size()'+ContentVersions.size());
      ///////////////////////////////////////////////////////////////////////
  }

   public void FilterContentVersionByCountryofpublication(){

     //////////////////////////////Country ALL  SECTION//////////////////////////////
      system.debug('Kerensen2 START FilterContentVersionByCountryofpublication ==> ' +cont_ContentVersion.Country_of_publication__c);
      system.debug('Kerensen2 START ContentVersions ==> '+ContentVersions);
      tmpContentVersion_set = new set<ContentVersion>();

            for(ContentVersion cv : ContentVersions ){
              system.debug('Kerensen2  cv.Country_of_publication__c ==> '+cv.Country_of_publication__c);
                if(cv.Country_of_publication__c != null &&
                   cont_ContentVersion.Country_of_publication__c != null &&
                   cont_ContentVersion.Country_of_publication__c != '' &&
                   (cv.Country_of_publication__c.contains(cont_ContentVersion.Country_of_publication__c)
                   	|| cv.Country_of_publication__c.contains('All - Globally'))
                   ){
                      system.debug('KER01 INNNN');
                      tmpContentVersion_set.add(cv);
                }     
            }
            
            system.debug('Kerensen2 tmpContentVersion_set   '+tmpContentVersion_set ); 
            if(tmpContentVersion_set != null && tmpContentVersion_set.size() > 0){
                ContentVersions.clear();
                ContentVersions.addAll(tmpContentVersion_set);
            }
            
            system.debug('Kerensen2 tmpContentVersion_set  ==> ' +tmpContentVersion_set);
            system.debug('Kerensen2 Document_Category__c  ==> ' +cont_ContentVersion.Document_Category__c);
            system.debug('Kerensen2 Country_of_publication__c ==> ' +cont_ContentVersion.Country_of_publication__c);
            if( cont_ContentVersion.Country_of_publication__c != null && (tmpContentVersion_set == null || tmpContentVersion_set.size() < 1)){
                ContentVersions.clear();
            } 
            if(cont_ContentVersion.Document_Category__c == null && cont_ContentVersion.Country_of_publication__c == null){
                Init();
            }
            tmpContentVersion_set.clear(); 
      system.debug('Kerensen2 ContentVersions'+ContentVersions);
      system.debug('Kerensen2 ContentVersions.size()'+ContentVersions.size());

      ///////////////////////////////////////////////////////////////////////
  }
  

  public void FilterContentVersionByFreeText(){
    system.debug('Kerensen3 ContentVersions'+ContentVersions);
    system.debug('Kerensen3 ContentVersions.size()'+ContentVersions.size());
    //////////////////////////////TAG SECTION//////////////////////////////
          if(Title ==null || Title == ''){
              Title = Apexpages.currentPage().getParameters().get('title');
              system.debug('Kerensen3 Title'+title);
            }

            tmpContentVersion_set = new set<ContentVersion>();
            for(ContentVersion cv : ContentVersions ){
              system.debug('Kerensen3 cv ==> '+cv);
              system.debug('Kerensen3 cv.TagCsv ==> '+cv.TagCsv);
               if(cv.TagCsv != null){
                  //system.debug('Kerensen3 cv.TagCsv.containsIgnoreCase(Title)==>'+cv.TagCsv.containsIgnoreCase(Title));
               }
               if(Title != null){
                if(cv.TagCsv != null && cv.TagCsv.containsIgnoreCase(Title) ||
                   cv.Title != null && cv.Title.containsIgnoreCase(Title) ||
                   cv.Description != null && cv.Description.containsIgnoreCase(Title)){
                  system.debug('Kerensen3 INNNN');
                    tmpContentVersion_set.add(cv);
                }
              }
            }
            
            system.debug('Kerensen3 tmpContentVersion_set   '+tmpContentVersion_set ); 
            if(tmpContentVersion_set != null && tmpContentVersion_set.size() > 0){
                ContentVersions.clear();
                ContentVersions.addAll(tmpContentVersion_set);
            }else{
                  if (Title !=null && Title != '')
                {
                   ContentVersions.clear();
                }
            }
            tmpContentVersion_set.clear();
            system.debug('Kerensen3 ContentVersions'+ContentVersions);
      ///////////////////////////////////////////////////////////////////////
  }

  public PageReference ClearFilters(){
    cont_ContentVersion = new ContentVersion();
    Title = '';
    runSearch(); 
    return null ;
  }


  public List<SelectOption> getCountries()
  {
    List<SelectOption> options = new List<SelectOption>();
    options.add(new SelectOption('', '--None--'));
        
     Schema.DescribeFieldResult fieldResult =
      ContentVersion.Country_of_publication__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
     for( Schema.PicklistEntry f : ple)
     {
      options.add(new SelectOption(f.getLabel(), f.getValue()));
     }       
     return options;
  }

    // toggles the sorting of query from asc<-->desc
  
   /* public void toggleSort() {
      // simply toggle the direction
      sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        // run the query again
        runQueryAfterSearch();
    }*/




     public String sortExpression
   {
     get
     {
        return sortExp;
     }
     set
     {
       //if the column is clicked on then switch between Ascending and Descending modes
       if (value == sortExp)
         sortDirection = (sortDirection == 'ASC')? 'DESC' : 'ASC';
       else
         sortDirection = 'ASC';
       sortExp = value;
     }
   }

 public String getSortDirection()
 {
    //if not column is selected 
    if (sortExpression == null || sortExpression == '')
      return 'ASC';
    else
     return sortDirection;
 }

 public void setSortDirection(String value)
 {  
   sortDirection = value;
 }

    // the current sort direction. defaults to accessToLibrariesCS
   /*public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
   
   // the current field to sort by. defaults to account Name
    public String sortField {
        get  { if (sortField == null) {sortField = 'LastModifiedDate '; } return sortField;  }
        set;
    }*/

}