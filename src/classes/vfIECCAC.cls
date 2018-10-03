/**  
  * Description: This class contains the controller for the Visualforce page (Check A Code) 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */

public without sharing class vfIECCAC extends IECPageController {
  
  //Controller to handle the subscription information
    public vfIECSubscriptionInfo   ctrSubsInfo        {get; set;}
  
  
  //Display variables
  public list<String> lstErrorMessage   {get; set;}
  public boolean bShowAgent         {get; set;}
  public boolean bShowAgency         {get; set;}
  public String sValidationCode       {get; set;}
  public String sCASSCode          {get; set;}
  public Boolean bshowInvalidCode      {get; set;}
  public Boolean baskCASSCode        {get; set;}
  public Boolean bShowNoAgencyResults    {get; set;}
  public Boolean bShowNoAgentResults    {get; set;}
  
  public Boolean bIsValid          {get; set;}
  public String sAgencyCode        {get; set;}
  public String sAgentCode        {get; set;}

  public IEC_Subscription_History__c oSubscriptionHistory  {get; private set;}
  public Zuora__Subscription__c oSubscription {get; private set;}
  public boolean bDisplayRenewBtn        {get; set;} 
    public boolean bDisplayUpgradeBtn      {get; set;}
  public ID idSelectedRatePlanInfo      {get; set;} // Initially set from Subscription History, but then swapped if applicable
  public ID idSelectedProdInfo        {get; set;} // Initially set from Subscription History, but then swapped if applicable

  /* Each item in the result List will contain the information 
   * as list of 4 string elements and they will be in the following order:
   *
   * [0] = Label
   * [1] = Tooltip
   * [2] = Data Type (S=status, T=text, A=Address,D=Date,L=link)
   * [3] = Data Value
   */
  public List<List<String>> lResultList {get; set;}
  

  //public GDP_Account__c oAgency {get; set;}
  public GDP_Products_Account_View__c oAgency {get; set;}
  public ID_Card__c oAgent {get; set;}
  
  public String sProductCode {
    get {
      return IECConstants.ProductCategory_SF_CACPRO;
    }
  }

  /**
   * Constructor Method
   **/
     public vfIECCAC() {
       
       sValidationCode = '';
       bShowAgency = bShowAgent = baskCASSCode = bShowNoAgencyResults = bShowNoAgentResults = bIsValid = false;
       lstErrorMessage = new list<string>();
       
        //Initilize subscription component        
        ctrSubsInfo = new vfIECSubscriptionInfo(); 
        ctrSubsInfo.loggedCustomer = loggedCustomer;
        ctrSubsInfo.sApplicationName = IECConstants.ProductCategory_SF_CACPRO;
       
       lResultList = new List< List<String> >();
       
    }

  public Pagereference pageLoad() {
    // first check if the user is logged in
    try {
      if (IECUserManager.isUserLoggedIn() == false) {
        Pagereference prLogin = Page.IECLogin;
        prLogin.getParameters().put(IECConstants.PARAM_RETURN_URL, IECUtil.EncryptEncodeParameter(ApexPages.currentPage().getUrl()));
        prLogin.getParameters().put(IECConstants.PARAM_WARNING_MSG, IECUtil.EncryptEncodeParameter(Label.IEC_Warning_Must_Login));
        prLogin.setRedirect(true);
        return prLogin;
      }
      else {
        // Validate Logged in user profile and ensure profile is complete
        validUserProfile();
        
                // Make sure to validate user access to application subscription
                ctrSubsInfo.validateAccess();         

        // if no access, redirect to the unauthorized page
        if (!ctrSubsInfo.hasPageAccess)
          return Page.IECUnauthorized;
      }
    }
    catch(Exception ex) {
      addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
    }
    return null;
  }

   public void validateCode() {
    try {      
      //Test code 7: 5755500 575a500
      //Test code 8: 96826376
      //Test error: 60500296
      //Test ICCArd: 5990078523
      //Test ICCArd:  5056008908      
      
      
      // Reset showing the result sections
      bShowAgency = bShowAgent = false;
      oAgency = null;
      oAgent = null;
      lstErrorMessage.clear();
      bShowNoAgencyResults = false;
      bShowNoAgentResults = false;
      sAgencyCode = '';
      sAgentCode = '';
      
      //Trim any leading or trailing spaces
      if (sValidationCode != null)
        sValidationCode = sValidationCode.trim();
        
      system.debug('SALV - validateCode: ' +sValidationCode);

      //Validate numerica values only  
      Pattern isnumbers = Pattern.Compile('^[0-9]+$');
      Matcher postalMatch = isnumbers.matcher(sValidationCode);

      if(!postalMatch.Matches()){
        bshowInvalidCode = true;
        baskCASSCode = false;
        //sCASSCode = '';  
        system.debug('SALV - validateCode: ' +sValidationCode + ' is not numeric');
        return;        
      }        
      
      //Process to validate the code
      if (ctrSubsInfo.hasPageAccess) {
        bshowInvalidCode = false;
        
       
       // sAgencyCode = (sCASSCode != null && sCASSCode != '') ? sValidationCode + sCASSCode : sValidationCode;
       // following the IATA_Code__c + CASS_Number__c + Check_Digit__c logic
       // sAgencyCode  logic moved to if statements bellow
       
        system.debug('SALV - validate : sValidationCode=' +sValidationCode+  ' sCASSCode  ' + sCASSCode );
     
        
        if (sValidationCode.length() == 7) {
          system.debug('SALV - validateCode: It\'s a 7 digits code: ' +sValidationCode);
          sAgencyCode = sValidationCode;
          queryByIATACode();
          }
        else if (sValidationCode.length() == 8) {
          system.debug('SALV - validateCode: It\'s a 8 digits code: ' +sValidationCode);
          
          sAgencyCode = (sCASSCode != null && sCASSCode != '') ? sValidationCode.substring(0,7) + sCASSCode + sValidationCode.substring(7,8) : sValidationCode;
          
          queryByAgencyCode_8();
        }        
        else if (sValidationCode.length() == 11 || sValidationCode.length() == 12) {
          system.debug('SALV - validateCode: It\'s a 11 or 12 digits code: ' +sValidationCode);
          
          sAgencyCode = (sCASSCode != null && sCASSCode != '') ? sValidationCode.substring(0,7) + sCASSCode + sValidationCode.substring(7,8) : sValidationCode;
          
          
          queryByAgencyCode_11();
        }
          else if (sValidationCode.length() == 10) {
          system.debug('SALV - validateCode: It\'s a 10 digits code: ' +sValidationCode);
            sAgentCode = sValidationCode;
            queryByIDCard();
          }
        else {
          system.debug('SALV - validateCode: It is not a valid code: ' +sValidationCode);
          bshowInvalidCode = true;
          baskCASSCode = false;
         // sCASSCode = '';
        }
        
        
        //Update usage counter (UI Only)
        if (!baskCASSCode && !bshowInvalidCode) {
          ctrSubsInfo.dUnitsConsumed++;
          if (ctrSubsInfo.iUsageLeft > 0) 
            ctrSubsInfo.iUsageLeft--;
        } 
        
        
      }
    }
    catch (Exception ex) {
      addErrorMessage(ex.getMessage() + '<br />' + ex.getStackTraceString());
    }
  }

  private void queryByIDCard() {

    //Query the Agent
    oAgent = IECApplicationsManager.customerSearchAgentByVER(sValidationCode, IECConstants.ProductCategory_SF_CACPRO, loggedCustomer);

    //Handling VALID/INVALID
    if (oAgent != null) {
      bShowAgent = true;
      bIsValid = (oAgent.Card_Status__c != null && oAgent.Card_Status__c != '');
      bShowNoAgentResults = !bIsValid;
    }
    else {
      bIsValid = false;
      bShowNoAgentResults = true;  
    }
    
    //Clean input texts
    baskCASSCode = false;
    sValidationCode = '';
    sCASSCode = '';  
    
  }
  
  
  

  private void queryByIATACode() {
    List<GDP_Products_Account_View__c> result = IECApplicationsManager.customerSearchAgencyByIATACode(sValidationCode, sCASSCode, null, IECConstants.ProductCategory_SF_CACPRO, loggedCustomer);
          
    //If more than 1 result, ask for CASS code
    if (result != null && result.size() > 1) {
      baskCASSCode = true;
      return;
    }
            
    if (result != null && result.size() > 0) {
      oAgency = result[0];
      bShowAgency = true;
        bIsValid = (oAgency.Related_Accreditation_Class__r.Status__r != null && integer.valueOf(oAgency.Related_Accreditation_Class__r.Status__r.Code__c) >= 4);
        bShowNoAgencyResults = !bIsValid;
        if (bIsValid) sAgencyCode = oAgency.Agency_Code__c;
    }
    else {
      bIsValid = false;
      bShowNoAgencyResults = true;  
    }
    
    baskCASSCode = false;
    sValidationCode = '';
    sCASSCode = '';  
  }
  
  
  
  
  private void queryByAgencyCode_8() {
    try {
      String sIATACode = sValidationCode.substring(0,7);         
      String sCheckCode =  sValidationCode.substring(sValidationCode.length()-1,sValidationCode.length());
        

      system.debug('SALV - Code_8: sIATACode=' +sIATACode + ' - sCheckCode=' + sCheckCode+ ' sCASSCode  ' + sCASSCode );
      
      List<GDP_Products_Account_View__c> result = IECApplicationsManager.customerSearchAgencyByIATACode(sIATACode, sCASSCode, sCheckCode, IECConstants.ProductCategory_SF_CACPRO, loggedCustomer);
          
      //system.debug('SALV - Code_8: result size=' + result.size());   
        
      //If more than 1 result, ask for CASS code
      if (result != null && result.size() > 1) {
        baskCASSCode = true;
        system.debug('SALV - Code_8: should ask for CASSCode');
        return;
      }
        
      if (result != null && result.size() > 0) {
        oAgency = result[0];
        bShowAgency = true;
          bIsValid = (oAgency.Related_Accreditation_Class__r.Status__r != null && integer.valueOf(oAgency.Related_Accreditation_Class__r.Status__r.Code__c) >= 4);
          bShowNoAgencyResults = !bIsValid;
          if (bIsValid) sAgencyCode = oAgency.Agency_Code__c;
      }
      else {
        bIsValid = false;
        bShowNoAgencyResults = true;  
      }
      
      baskCASSCode = false;
      sValidationCode = '';
      sCASSCode = '';  
  
    } 
    catch (Exception ex) {
      addErrorMessage('Error ' + ex.getMessage() + '<br />' + ex.getStackTraceString());
      system.debug('SALV - Code_8: exception error:' + ex.getMessage() );
      system.debug('SALV - Code_8: exception StackTraceString:' + ex.getStackTraceString() );
    }
  }
  
  private void queryByAgencyCode_11() {
    
    String sIATACode = sValidationCode.substring(0,7);        

    String sCheckCode = sValidationCode.substring(sValidationCode.length()-1,sValidationCode.length());
        
    
    if (sValidationCode.length() == 11)
      sCASSCode = sValidationCode.substring(7,10);
    else
      sCASSCode = sValidationCode.substring(7,11);
      
      
     system.debug('SALV - Code_11: sIATACode=' +sIATACode + ' - sCheckCode=' + sCheckCode+ ' sCASSCode  ' + sCASSCode );
    
    List<GDP_Products_Account_View__c> result = IECApplicationsManager.customerSearchAgencyByIATACode(sIATACode, sCASSCode, sCheckCode, IECConstants.ProductCategory_SF_CACPRO, loggedCustomer);
          
    //If more than 1 result, ask for CASS code
    if (result != null && result.size() > 1) {
      baskCASSCode = true;
      return;
    }
    
    if (result != null && result.size() > 0) {
      oAgency = result[0];
      bShowAgency = true;
        bIsValid = (oAgency.Related_Accreditation_Class__r.Status__r != null && integer.valueOf(oAgency.Related_Accreditation_Class__r.Status__r.Code__c) >= 4);
        bShowNoAgencyResults = !bIsValid;
        if (bIsValid) sAgencyCode = oAgency.Agency_Code__c;
    }
    else {
      bIsValid = false;
      bShowNoAgencyResults = true;
    }
    
    baskCASSCode = false;
    sValidationCode = '';
    sCASSCode = '';  
  }
}