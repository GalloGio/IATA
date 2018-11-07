public without sharing class ENV {
    
  public static final String Identity = 'Identity';
  public static final String Partner_Community = 'Partner Community';
  public static final String Reply_Email = Label.ISSP_Sender_Email;//noreply@iata.org
  public static final String Reply_Email_CNS = Label.ISSP_Sender_Email_CNS; //noreply@cnsc.us
  public static final String AccessToApplicationServiceRequested_Email_Subject = 'IATA Noreply'; 
  public static final String AccessToApplicationServiceRequested_Email_Subject_CNS = 'CNS'; 
  
  public static ENV.AccessStatusClass AccessStatusPL {
    get{ 
      if(null == AccessStatusPL) AccessStatusPL = new ENV.AccessStatusClass();
      return  AccessStatusPL;  
     }
    private set;
  }
  
  public static ENV.TeamMemberRoleClass TeamMemberRolePL {
    get {
      if(null == TeamMemberRolePL) TeamMemberRolePL = new ENV.TeamMemberRoleClass();
      return  TeamMemberRolePL;  
    }
    private set;
  }
  
  public static ENV.EmailTemplateClass EmailTemplateData {
    get {
      if(null == EmailTemplateData) EmailTemplateData = new ENV.EmailTemplateClass();
      return  EmailTemplateData;  
    }
    private set;
  }
  
  public static ENV.ArticleChannelClass ArticleChannel {
    get {
      if(null == ArticleChannel) ArticleChannel = new ENV.ArticleChannelClass();
      return ArticleChannel;
    }
    private set;
  }
  
  public static ENV.ArticleStatTypeClass ArticleStatType {
    get {
      if(null == ArticleStatType) ArticleStatType = new ENV.ArticleStatTypeClass();
      return ArticleStatType;
    }
    private set;
  }
  
  /*
    Piclist Values
  */
  public class EmailTemplateClass {
    public final string NotifyAdminOfAppRequestVF = 'Notify_Admin_of_app_requestVF';
    public final string NotifyAdminOfAppRequestVF_CNS = 'Notify_Admin_of_app_requestVF_CNS';
    public final string ChangeEmailAddress       = 'ISSP_Change_Email_Verification';
    public final string NotifyAdminNewContact      = 'Notify_Admin_of_user_creationVF';    
    public final string ISSPChangeIEPStatusInProgressToOpenA = 'ISSP_Change_IEP_Status_InProgress_to_OpenA';
    public final string ISSPChangeIEPStatusInProgressToOpen = 'ISSP_Change_IEP_Status_InProgress_to_Open';
    public final string ISSP_ApprovalOfIATAEasyPayUsers = 'ISSP_Approval_Of_IATA_EasyPay_Users';
  }
  
  public class TeamMemberRoleClass {
    public final string PortalAdministrator = 'Portal Administrator';
  }
  
  public class  AccessStatusClass {
    public final string AccessRequested = 'Access Requested';
  }
  
  public class ArticleStatTypeClass {
    public final String View = 'View';
    public final String Satisfied   = 'Satisfied';
    public final String UnSatisfied   = 'UnSatisfied';
  }

  public class ArticleChannelClass {
    public final String AllChannels = 'AllChannels';
    public final String Prm = 'Prm';//partner
    public final String Csp = 'Csp';//customer
    public final String Pkb = 'Pkb';//public 
    public final String App = 'App';//internal
  }

  /*  FAQ2Case */
  public static final String SelectOptionDefaultValue = '-- Select --';
  public static final String SelectOptionEmptyValue   = '-- None --';

}