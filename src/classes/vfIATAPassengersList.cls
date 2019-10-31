public with sharing class vfIATAPassengersList extends IECPageController{

  public list<GDP_Airlines_Statistic__c> Statistics {get;set;}
   
  public Boolean AO_Flag  {get;set;}
  public Boolean SA_Flag  {get;set;}
  public Boolean HO_Flag {get;set;}
  public Boolean BR_Flag {get;set;}
  public Boolean ES_Flag {get;set;}
  public Boolean EP_Flag {get;set;}
  public Boolean ST_Flag {get;set;}
  public Boolean SE_Flag {get;set;}
  public Boolean SP_Flag {get;set;}
  public Boolean TD_Flag {get;set;}
  public Boolean IC_Flag {get;set;}
  public Boolean AA_Flag {get;set;}
  public Boolean AC_Flag {get;set;}
  public Boolean AW_Flag {get;set;}
  public Boolean EB_Flag {get;set;}
  public Boolean WH_Flag {get;set;}
  public Boolean CS_Flag {get;set;}

  public decimal AO_Total  {get;set;}
  public decimal SA_Total  {get;set;}
  public decimal HO_Total {get;set;}
  public decimal BR_Total {get;set;}
  public decimal ES_Total {get;set;}
  public decimal EP_Total {get;set;}
  public decimal ST_Total {get;set;}
  public decimal SE_Total {get;set;}
  public decimal SP_Total {get;set;}
  public decimal TD_Total {get;set;}
  public decimal IC_Total {get;set;}
  public decimal AA_Total {get;set;}
  public decimal AC_Total {get;set;}
  public decimal AW_Total {get;set;}
  public decimal EB_Total {get;set;}
  public decimal WH_Total {get;set;}
  public decimal CS_Total {get;set;}
  public decimal Grand_Total {get;set;}
     
  public dateTime dataLastRefreshedOn{get;set;}
  
  // Created for Header Component
  public vfIECSubscriptionInfo    ctrSubsInfo         {get; set;}
  public vfIECSavedFilters        ctrSavedFilters     {get; set;}

  public String PageTitle{
    public get {
        if (PageTitle == null) {
            if (sProductCode =='GAD') PageTitle='Global Agency Directory';
            else if (sProductCode =='PAL') PageTitle='Passenger Agency List';
            else if (sProductCode =='CAL') PageTitle='Cargo Agency List';
            else if (sProductCode =='ASL') PageTitle='MSO & GSA List';
        }
        return PageTitle;
    }
    private set;
  }
    
  public String ListTitle{
    public get {
      if (ListTitle == null) {
        if (sProductCode =='GAD') ListTitle='';
        else if (sProductCode =='PAL') ListTitle='IATA Passenger Sales Agents Worldwide (Including IATAN U.S. Travel Agents) Statistics';
        else if (sProductCode =='CAL') ListTitle='IATA Cargo Agencies Worldwide Statistics';
        else if (sProductCode =='ASL') ListTitle='IATA Airline Sales Worldwide Statistics';
      }
      return ListTitle;
    }
    private set;
  }
    
  public String sProductCode {
    get {
      if (sProductCode == null) {
        Cookie storedIECProductCode = ApexPages.currentPage().getCookies().get('IECProductCode');
        if (ApexPages.currentPage().getParameters().containsKey(IECConstants.PARAM_PRODUCT_CODE)) {
            sProductCode = IECUtil.DecodeDecryptParameter(ApexPages.currentPage().getParameters().get(IECConstants.PARAM_PRODUCT_CODE));
            storedIECProductCode = new Cookie('IECProductCode',sProductCode,null,-1,false);
        } else if (storedIECProductCode != null) {
            sProductCode = (String)storedIECProductCode.getValue();
        }
        ApexPages.currentPage().setCookies(new Cookie[]{storedIECProductCode});
      }
      return sProductCode;
    }
    private set;
  }
   
  public vfIATAPassengersList(){
    //Created for Page Headers
    //Initilize subscription component        
    ctrSubsInfo = new vfIECSubscriptionInfo(); 
    ctrSubsInfo.loggedCustomer = loggedCustomer;
    ctrSubsInfo.sApplicationName = sProductCode;
    
    ctrSavedFilters = new vfIECSavedFilters();
    ctrSavedFilters.loggedCustomer = loggedCustomer;
    
    Statistics = new list<GDP_Airlines_Statistic__c>();
    Statistics = [SELECT id, name, Country__c, State__c, Class__c, lastModifiedDate 
                        ,AO__c, SA__c, HO__c, BR__c, ES__c
                        ,EP__c, ST__c, SE__c, SP__c, TD__c
                        ,IC__c, AA__c, AC__c, AW__c, EB__c
                        ,WH__c, CS__c, Total__c                    
                    FROM GDP_Airlines_Statistic__c
                    WHERE Class__c=:sProductCode
                    ORDER BY Country__c, State__c
                    LIMIT 10000];
    
    if(Statistics.size()>0) dataLastRefreshedOn = Statistics[0].lastModifiedDate;
    
    AO_Flag=false;
    SA_Flag=false;
    HO_Flag=false;
    BR_Flag=false;
    ES_Flag=false;
    EP_Flag=false;
    ST_Flag=false;
    SE_Flag=false;
    SP_Flag=false;
    TD_Flag=false;
    IC_Flag=false;
    AA_Flag=false;
    AC_Flag=false;
    AW_Flag=false;
    EB_Flag=false;
    WH_Flag=false;
    CS_Flag=false;
    //Totals
    AO_Total=0;
    SA_Total=0;
    HO_Total=0;
    BR_Total=0;
    ES_Total=0;
    EP_Total=0;
    ST_Total=0;
    SE_Total=0;
    SP_Total=0;
    TD_Total=0;
    IC_Total=0;
    AA_Total=0;
    AC_Total=0;
    AW_Total=0;
    EB_Total=0;
    WH_Total=0;
    CS_Total=0;
    Grand_Total=0;
    //TODO: Make sure to show only column with data
    for(GDP_Airlines_Statistic__c stats :Statistics){
      //Load data and condition
      if (stats.AO__c != 0)  {AO_Flag=true;  AO_Total +=stats.AO__c; }
      if (stats.SA__c != 0)  {SA_Flag=true;  SA_Total +=stats.SA__c;}
      if (stats.HO__c != 0)  {HO_Flag=true;  HO_Total +=stats.HO__c;}
      if (stats.BR__c != 0)  {BR_Flag=true;  BR_Total +=stats.BR__c;}
      if (stats.ES__c != 0)  {ES_Flag=true;  ES_Total +=stats.ES__c;}
      if (stats.EP__c != 0)  {EP_Flag=true;  EP_Total +=stats.EP__c;}
      if (stats.ST__c != 0)  {ST_Flag=true;  ST_Total +=stats.ST__c;}
   
      if (stats.SE__c != 0)  {SE_Flag=true;  SE_Total +=stats.Se__c;}
      if (stats.SP__c != 0)  {SP_Flag=true;  SP_Total +=stats.SP__c;}
      if (stats.TD__c != 0)  {TD_Flag=true;  TD_Total +=stats.TD__c;}
      if (stats.IC__c != 0)  {IC_Flag=true;  IC_Total +=stats.IC__c;}
      if (stats.AA__c != 0)  {AA_Flag=true;  AA_Total +=stats.AA__c;}
      if (stats.AC__c != 0)  {AC_Flag=true;  AC_Total +=stats.AC__c;}
      if (stats.AW__c != 0)  {AW_Flag=true;  AW_Total +=stats.AW__c;}
      if (stats.EB__c != 0)  {EB_Flag=true;  EB_Total +=stats.EB__c;}
      if (stats.WH__c != 0)  {WH_Flag=true;  WH_Total +=stats.WH__c;}
      if (stats.CS__c != 0)  {CS_Flag=true;  CS_Total +=stats.CS__c;}
      
      Grand_Total +=stats.Total__c; 
    }
  } 
        
   // This method is used for Component Header
        
  public Pagereference pageLoad() {
    // first check if the user is logged in
    try {
      if (IECUserManager.isUserLoggedIn() == false) {
        Pagereference prLogin = Page.IECLogin;
        prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
        prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
        prLogin.setRedirect(true);
        return prLogin;
      }else {
        // Validate Logged in user profile and ensure profile is complete
        validUserProfile();

        // Make sure to validate user access to application subscription
        ctrSubsInfo.validateAccess(new Set<String>{'PAL', 'ASL', 'CAL'});
        
        // if no access, redirect to the unauthorized page
        if (!ctrSubsInfo.hasPageAccess)
            return Page.IECUnauthorized;
        
        //Load Saved filters
        ctrSavedFilters.loadFilters(sProductCode);
      }
    }
    catch(Exception ex) {
        addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
    }
    return null;
  }

}