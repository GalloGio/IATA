public class ISSP_Ctrl_ContentPage
{
  //Global Variables
  public String UserPortalStatus {get;set;}
  public String UserPortalCountry {get;set;}
  public String UserPortalRegion {get;Set;}
  public String UserPortalAccountSector {get;set;}
  public String PortalUserId {get;set;}


  //Library section
  public ContentWorkspace ContentWorkspace ;
  public String DocId = '';

  // the soql without the order and limit
  private String soql {get;set;}

  // the collection of contacts to display
  public List<ContentVersion> ContentVersions {get;set;}

  public String csHost {get;set;}

  public String UserPortalCategory;
  public String UserPortalRecodType;
  // List of names of the libraries with visibility
  public List<String> AccessLibraryName;
  // set of ids of the libraries with visibility
  public Set<Id> DocIds_set = new Set<Id>();
  public Set<Id> PublicDocIds_set = new Set<Id>();

  public List<String> allCountriesList {get;set;}
  public List<String> allFileTypesList {get;set;}
  public List<String> allDocumentCategoryList {get;set;}
  public List<String> allLanguagesList {get;set;}

  //CNS
  public String communityName{ get{ return ApexPages.currentPage().getParameters().get('CommunityName'); }set;}


  //Consetructor
  public ISSP_Ctrl_ContentPage(){
    Init();
  }

  //Initialize Variables and Parameters
  public void Init(){
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

   // init the controller and display some sample data when the page loads
    soql = 'select id, Title, Description, FileType,OwnerId,Owner.Name, VersionNumber ,Country_visibilty__c ,User_status_access__c,Region__c,TagCsv ,ContentSize,Language__c,ContentDocumentId,Document_Category__c,Country_of_publication__c,ContentUrl '+
         ' From ContentVersion '+
         ' Where IsLatest = true '+
         ' AND User_status_access__c includes (\''+String.escapeSingleQuotes(UserPortalStatus)+'\')'+
         ' AND ((ContentDocumentId IN: DocIds_set'+
         ' AND Country_visibilty__c includes (\'All - Globally\',\''+String.escapeSingleQuotes(UserPortalCountry)+'\', \'All - Region '+String.escapeSingleQuotes(UserPortalRegion)+'\'))'+
         ' OR (ContentDocumentId IN: PublicDocIds_set))';


    system.debug('susana soql ' + soql);
    ContentVersions = sortContentVersions(Database.query(soql));
    system.debug('susana ContentVersions : ' + ContentVersions);

    allCountriesList = getPicklistValues('ContentVersion', 'Country_of_publication__c');
    allLanguagesList = getPicklistValues('ContentVersion', 'Language__c');
    allFileTypesList = getPicklistValues('ContentVersion', 'FileType');
    allDocumentCategoryList = getPicklistValues('ContentVersion', 'Document_Category__c');

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

    public static List<String> getPicklistValues(String ObjectApi_name,String Field_name){

      List<String> lstPickvals=new List<String>();
      Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name);//From the Object Api name retrieving the SObject
      Sobject Object_name = targetType.newSObject();
      Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
      Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
      Map<String, Schema.SObjectField> field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
      List<Schema.PicklistEntry> pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject

        for (Schema.PicklistEntry a : pick_list_values) { //for all values in the picklist list
          lstPickvals.add(a.getValue());//add the value  to our final list
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

}