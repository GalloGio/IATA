public class ISSP_Ctrl_Bannertestpage {

  //Global Variables
  public String UserPortalStatus {get;Set;}
  public String UserPortalCountry {get;Set;}
  public String UserPortalRegion {get;Set;}
  public String UserPortalAccountSector {get;Set;}
  public String FirstBannerId {get;Set;}


  //Binding Banner List to Display
  public List<ISSP_Banner__c> Banners_List {get;Set;}
  public List<WrapperBanner> wrapperBanItem_List {get;Set;}

  // Helper Private variables
  public List<ISSP_Banner__c> unFilteredBanner_List ;

  // the soql without the order and limit
  public String soql {get;set;}


 public ISSP_Ctrl_Bannertestpage(){
	//Initialize Method
	Init();
	//Filter By Country Method
	FilterContentVersionByCountry();
	system.debug('SFII Last  Banners_List '+Banners_List);

	 if(Banners_List == null || Banners_List.size() < 1){
        getDefaultBanner();
     }
	//Call method that set the language of the banner
	setBannerLanguage();
	system.debug('SFII Last  wrapperBanItem_List '+wrapperBanItem_List);
	system.debug('SFII Last  wrapperBanItem_List.size() '+wrapperBanItem_List.size());
    if (wrapperBanItem_List != null && !wrapperBanItem_List.isEmpty() ){
			FirstBannerId = wrapperBanItem_List[0].bannerItem.Id;
			system.debug('SFII  FirstBannerId '+FirstBannerId);
    }
	system.debug('SFII 2 Last  wrapperBanItem_List '+wrapperBanItem_List);
	system.debug('SFII 2 Last  wrapperBanItem_List.size() '+wrapperBanItem_List.size());
 }

  //Initialize Variables and Parameters
  public void Init(){
	//Initialize the Banner List to Display
	Banners_List = new List<ISSP_Banner__c>();
	//Init Wrapper Banners List
	wrapperBanItem_List = new List<WrapperBanner> ();
	//Today's Date
	String TodayInstanse = String.valueOf(Date.today());
	//Select Current logged in user
    User tmpPortalUSer = [select Id , ContactId From User Where id =: userinfo.getuserid()];
    //Get Parameters According to the Contact Related to User
    Contact PortalContact = [select Id ,Name, Status__c ,User_Portal_Status__c,OwnerId ,Account.BillingCountry ,Account.sector__c,
    						 Account.IATA_ISO_Country__r.Name ,Account.IATA_ISO_Country__r.Region__c
                             From Contact
                             where Id =: tmpPortalUSer.ContactId][0]  ;

    system.debug('KER0  PortalContact '+PortalContact);

	//Prepare Permissions parameters
	//STATUS
    UserPortalStatus  = PortalContact.User_Portal_Status__c ;
	if (UserPortalStatus == null){
    	UserPortalStatus = 'NoStatusValue';
    }
	//COUNTRY
	if (PortalContact.Account.IATA_ISO_Country__c == null){
		UserPortalCountry = 'NoCountryValue';
		UserPortalRegion = 'NoCountryValue';
	}
	else{
	    UserPortalCountry = PortalContact.Account.IATA_ISO_Country__r.Name ;
		if (UserPortalCountry == null){
	    	UserPortalCountry = 'NoCountryValue';
	    }
	    //REGION
	    UserPortalRegion = PortalContact.Account.IATA_ISO_Country__r.Region__c ;
	    if (UserPortalRegion == null){
	    	UserPortalRegion = 'NoCountryValue';
	    }
	}
	//SECTOR
    UserPortalAccountSector   = PortalContact.Account.sector__c;
    if (UserPortalAccountSector == null){
    	UserPortalAccountSector = '';
    }

	system.debug('SFII  TodayInstanse '+TodayInstanse);

	soql = 	'select id ,Background_image__c ,Background_image_url_link__c ,Background_image_url_link_target__c ,Country__c ,'+
			'Publication_end_date__c ,Publication_start_date__c ,Sector__c ,Status__c ,User_portal_Status__c ,DE_Zone_text_1__c ,'+
			'Zone_1_text__c ,Zone_1_text_background_colour__c ,ZH_Zone_1_text__c ,Zone_1_text_colour__c ,FR_Zone_1_text__c ,'+
			'Zone_1_text_hyperlink__c ,Zone_1_text_hyperlink_target_window__c ,IT_Zone_text_1__c ,JA_Zone_1_text__c ,'+
			'KO_Zone_1_text__c ,PT_Zone_1_text__c ,Zone_1_text_size__c ,ES_Zone_1_text__c ,Zone_2_text__c ,'+
			'Zone_2_text_background_colour__c ,ZH_Zone_2_text__c ,Zone_2_text_colour__c ,FR_Zone_2_text__c ,'+
			'Zone_2_text_hyperlink__c ,Zone_2_text_hyperlink_target_window__c ,IT_Zone_2_text__c ,JA_Zone_2_text__c ,'+
			'KO_Zone_2_text__c ,PT_Zone_2_text__c ,Zone_2_text_size__c ,ES_Zone_2_text__c ,Zone_3_text__c ,'+
			'Zone_3_text_background_colour__c ,ZH_Zone_text_3__c ,Zone_3_text_colour__c ,FR_Zone_3_text__c ,'+
			'Zone_3_text_hyperlink__c ,Zone_3_text_hyperlink_target_window__c ,IT_Zone_3_text__c ,JA_Zone_3_text__c ,'+
			'KO_Zone_3_text__c ,PT_Zone_3_text__c ,Zone_3_text_size__c ,ES_Zone_3_text__c ,AR_Zone_text_1__c ,'+
			'ID_Zone_text_1__c ,TH_Zone_text_1__c ,VI_Zone_text_1__c ,AR_Zone_text_2__c ,DE_Zone_text_2__c ,'+
			'ID_Zone_text_2__c ,TH_Zone_text_2__c ,VI_Zone_text_2__c ,AR_Zone_text_3__c ,DE_Zone_text_3__c ,'+
			'ID_Zone_text_3__c ,TH_Zone_text_3__c ,VI_Zone_text_3__c '+
			'From ISSP_Banner__c '+
			'Where Status__c  = \'Active\''+
			' AND Publication_start_date__c < ' +TodayInstanse +
			' AND Publication_end_date__c > '+TodayInstanse +
		    ' AND User_portal_Status__c includes (\''+String.escapeSingleQuotes(UserPortalStatus)+'\')' +
		    ' AND Sector__c includes (\''+String.escapeSingleQuotes(UserPortalAccountSector)+'\')' +
			' AND Name != \'Ban-001\'';



	 unFilteredBanner_List = new List<ISSP_Banner__c>();
	 //Run the soql Query
	 system.debug('SFII  soql '+soql);
     unFilteredBanner_List  = Database.query(soql + ' order by Publication_start_date__c Desc Limit 8' );

	system.debug('SFII  unFilteredBanner_List '+unFilteredBanner_List);
	system.debug('SFII  unFilteredBanner_List size '+unFilteredBanner_List.size());

    if (unFilteredBanner_List != null && !unFilteredBanner_List.isEmpty() ){
			Banners_List = unFilteredBanner_List ;
			system.debug('SFII  Banners_List '+Banners_List);
    }
  }

  //Filter Banner records by Account.BillingCountry
  public void FilterContentVersionByCountry(){
		//Temporary Helper Banners set
		set<ISSP_Banner__c> tmpBanner_set = new set<ISSP_Banner__c>();
		system.debug('SFIIcountry  UserPortalCountry '+UserPortalCountry);
		system.debug('SFIIcountry  UserPortalRegion '+UserPortalRegion);
        User u = [SELECT Id, Contact.Account.CNS_Agency__c,  Contact.Account.CNS_Account__c FROM User WHERE Id =:UserInfo.getUserId()];
        Boolean isCNS = false;
        if(u.Contact.Account.CNS_Agency__c || u.Contact.Account.CNS_Account__c) { isCNS = true;}
        for(ISSP_Banner__c ban : unFilteredBanner_List ){
		system.debug('SFIIcountry  ban.Country__c '+ban.Country__c);

        if(isCNS) {
                if(ban.Country__c != null && ban.Country__c.contains('All - CNS')) {
                    tmpBanner_set.add(ban);
                }
            } else {
            if(ban.Country__c != null && ban.Country__c.contains(UserPortalCountry)){
                tmpBanner_set.add(ban);
            }else{
                if(ban.Country__c != null && ban.Country__c.contains(UserPortalRegion) ){
                    tmpBanner_set.add(ban);
                }
				if (ban.Country__c != null && ban.Country__c.contains('All - Globally'))
				{
					tmpBanner_set.add(ban);
				}
            }
            }

        }system.debug('SFIIcountry tmpBanner_set '+tmpBanner_set);
        //Filters the List to display
        if(tmpBanner_set != null && tmpBanner_set.size() > 0){
            Banners_List.clear();
            Banners_List.addAll(tmpBanner_set);
        }else{
            Banners_List.clear();
        }
        tmpBanner_set.clear();
   }

   public class WrapperBanner{
		public ISSP_Banner__c bannerItem {get;Set;}
		public string  Zone_text_1 {get;Set;}
		public string  Zone_text_2 {get;Set;}
		public string  Zone_text_3 {get;Set;}

		public WrapperBanner(ISSP_Banner__c inBannerItem){
			this.bannerItem = inBannerItem ;
			if(inBannerItem.Zone_1_text__c != null){
				this.Zone_text_1 = inBannerItem.Zone_1_text__c ;
			}
			if(inBannerItem.Zone_2_text__c != null){
				this.Zone_text_2 = inBannerItem.Zone_2_text__c ;
			}
			if(inBannerItem.Zone_3_text__c != null){
				this.Zone_text_3 = inBannerItem.Zone_3_text__c ;
			}
		}
   }


	public void setBannerLanguage(){
	system.debug('SFII  START setBannerLanguage');
		String currentLanguage = UserInfo.getLanguage();
		system.debug('SFII   currentLanguage' +currentLanguage);
		for(ISSP_Banner__c ban :Banners_List)
		{
			WrapperBanner wrapItem = new WrapperBanner(ban);
			if (currentLanguage == 'es'){
				if (ban.ES_Zone_3_text__c != null) {	wrapItem.Zone_text_3 = ban.ES_Zone_3_text__c; }
				if (ban.ES_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.ES_Zone_2_text__c; }
				if (ban.ES_Zone_1_text__c != null) {	wrapItem.Zone_text_1 = ban.ES_Zone_1_text__c; }
			}
			else if (currentLanguage == 'ko'){
				if (ban.KO_Zone_3_text__c != null) {	wrapItem.Zone_text_3 = ban.KO_Zone_3_text__c; }
				if (ban.KO_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.KO_Zone_2_text__c; }
				if (ban.KO_Zone_1_text__c != null) {	wrapItem.Zone_text_1 = ban.KO_Zone_1_text__c; }
			}
			else if (currentLanguage == 'zh_CN'){
				if (ban.ZH_Zone_text_3__c != null) {	wrapItem.Zone_text_3 = ban.ZH_Zone_text_3__c; }
				if (ban.ZH_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.ZH_Zone_2_text__c; }
				if (ban.ZH_Zone_1_text__c != null) {	wrapItem.Zone_text_1 = ban.ZH_Zone_1_text__c; }
			}
			else if (currentLanguage == 'pt_BR'){
				if (ban.PT_Zone_3_text__c != null) {	wrapItem.Zone_text_3 = ban.PT_Zone_3_text__c; }
				if (ban.PT_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.PT_Zone_2_text__c; }
				if (ban.PT_Zone_1_text__c != null) {	wrapItem.Zone_text_1 = ban.PT_Zone_1_text__c; }
			}
			else if (currentLanguage == 'fr'){
				if (ban.FR_Zone_3_text__c != null) {	wrapItem.Zone_text_3 = ban.FR_Zone_3_text__c; }
				if (ban.FR_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.FR_Zone_2_text__c; }
				if (ban.FR_Zone_1_text__c != null) {	wrapItem.Zone_text_1 = ban.FR_Zone_1_text__c; }
			}
			else if (currentLanguage == 'ja'){
				if (ban.JA_Zone_3_text__c != null) {	wrapItem.Zone_text_3 = ban.JA_Zone_3_text__c; }
				if (ban.JA_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.JA_Zone_2_text__c; }
				if (ban.JA_Zone_1_text__c != null) {	wrapItem.Zone_text_1 = ban.JA_Zone_1_text__c; }
			}
			else if (currentLanguage == 'it'){
				if (ban.IT_Zone_3_text__c != null) {	wrapItem.Zone_text_3 = ban.IT_Zone_3_text__c; }
				if (ban.IT_Zone_2_text__c != null) {	wrapItem.Zone_text_2 = ban.IT_Zone_2_text__c; }
				if (ban.IT_Zone_text_1__c != null) {	wrapItem.Zone_text_1 = ban.IT_Zone_text_1__c; }
			}
			else if (currentLanguage == 'de'){
				if (ban.DE_Zone_text_3__c != null) {	wrapItem.Zone_text_3 = ban.DE_Zone_text_3__c; }
				if (ban.DE_Zone_text_2__c != null) {	wrapItem.Zone_text_2 = ban.DE_Zone_text_2__c; }
				if (ban.DE_Zone_text_1__c != null) {	wrapItem.Zone_text_1 = ban.DE_Zone_text_1__c; }
			}
			else if (currentLanguage == 'th'){
				if (ban.TH_Zone_text_3__c != null) {	wrapItem.Zone_text_3 = ban.TH_Zone_text_3__c; }
				if (ban.TH_Zone_text_2__c != null) {	wrapItem.Zone_text_2 = ban.TH_Zone_text_2__c; }
				if (ban.TH_Zone_text_1__c != null) {	wrapItem.Zone_text_1 = ban.TH_Zone_text_1__c; }
			}
			else if (currentLanguage == 'in'){
				if (ban.ID_Zone_text_3__c != null) {	wrapItem.Zone_text_3 = ban.ID_Zone_text_3__c; }
				if (ban.ID_Zone_text_2__c != null) {	wrapItem.Zone_text_2 = ban.ID_Zone_text_2__c; }
				if (ban.ID_Zone_text_1__c != null) {	wrapItem.Zone_text_1 = ban.ID_Zone_text_1__c; }
			}
			else if (currentLanguage == 'vi'){
				if (ban.VI_Zone_text_3__c != null) {	wrapItem.Zone_text_3 = ban.VI_Zone_text_3__c; }
				if (ban.VI_Zone_text_2__c != null) {	wrapItem.Zone_text_2 = ban.VI_Zone_text_2__c; }
				if (ban.VI_Zone_text_1__c != null) {	wrapItem.Zone_text_1 = ban.VI_Zone_text_1__c; }
			}
			else if (currentLanguage == 'ar'){
				if (ban.AR_Zone_text_3__c != null) {	wrapItem.Zone_text_3 = ban.AR_Zone_text_3__c; }
				if (ban.AR_Zone_text_2__c != null) {	wrapItem.Zone_text_2 = ban.AR_Zone_text_2__c; }
				if (ban.AR_Zone_text_1__c != null) {	wrapItem.Zone_text_1 = ban.AR_Zone_text_1__c; }
			}
			system.debug('SFII   wrapItem' +wrapItem);
			wrapperBanItem_List.add(wrapItem);
		}

    }

	public void getDefaultBanner(){
		// Handels the case when no records matches criteria by adding Default banner
		List<ISSP_Banner__c> noResults_List = new List<ISSP_Banner__c>([select id ,Background_image__c ,Background_image_url_link__c ,Background_image_url_link_target__c ,Country__c ,
															Publication_end_date__c ,Publication_start_date__c ,Sector__c ,Status__c ,User_portal_Status__c ,DE_Zone_text_1__c ,
															Zone_1_text__c ,Zone_1_text_background_colour__c ,ZH_Zone_1_text__c ,Zone_1_text_colour__c ,FR_Zone_1_text__c ,
															Zone_1_text_hyperlink__c ,Zone_1_text_hyperlink_target_window__c ,IT_Zone_text_1__c ,JA_Zone_1_text__c ,
															KO_Zone_1_text__c ,PT_Zone_1_text__c ,Zone_1_text_size__c ,ES_Zone_1_text__c ,Zone_2_text__c ,
															Zone_2_text_background_colour__c ,ZH_Zone_2_text__c ,Zone_2_text_colour__c ,FR_Zone_2_text__c ,
															Zone_2_text_hyperlink__c ,Zone_2_text_hyperlink_target_window__c ,IT_Zone_2_text__c ,JA_Zone_2_text__c ,
															KO_Zone_2_text__c ,PT_Zone_2_text__c ,Zone_2_text_size__c ,ES_Zone_2_text__c ,Zone_3_text__c ,
															Zone_3_text_background_colour__c ,ZH_Zone_text_3__c ,Zone_3_text_colour__c ,FR_Zone_3_text__c ,
															Zone_3_text_hyperlink__c ,Zone_3_text_hyperlink_target_window__c ,IT_Zone_3_text__c ,JA_Zone_3_text__c ,
															KO_Zone_3_text__c ,PT_Zone_3_text__c ,Zone_3_text_size__c ,ES_Zone_3_text__c ,AR_Zone_text_1__c ,
															ID_Zone_text_1__c ,TH_Zone_text_1__c ,VI_Zone_text_1__c ,AR_Zone_text_2__c ,DE_Zone_text_2__c ,
															ID_Zone_text_2__c ,TH_Zone_text_2__c ,VI_Zone_text_2__c ,AR_Zone_text_3__c ,DE_Zone_text_3__c ,
															ID_Zone_text_3__c ,TH_Zone_text_3__c ,VI_Zone_text_3__c
															From ISSP_Banner__c
															Where Name  = 'Ban-001']);

		if (noResults_List != null && !noResults_List.isEmpty() ){
				Banners_List = noResults_List ;
				system.debug('SFII  Banners_List '+Banners_List);
		}
	}
}
