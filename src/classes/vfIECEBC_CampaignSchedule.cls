public class vfIECEBC_CampaignSchedule extends vfIECEBC_Controller {
    
    public EBC_Campaign__c campaign { get; set; }
    public ApexPages.StandardController con { public get; private set; }
    
    public vfIECEBC_CampaignSchedule(ApexPages.StandardController stdController) {
        this.con = stdController;
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
    }
    
    public vfIECEBC_CampaignSchedule() {}
    
    public String humanCampaignDate {
        get {
            if (humanCampaignDate == null && campaignDate != null) {
                Date cd = Date.parse(campaignDate);
                humanCampaignDate = Datetime.newInstance(cd.year(), cd.month(), cd.day()).format('MMMM d y');
            }
            
            return humanCampaignDate;
        }
        set;
    }
    
    public String campaignDate {
        get {
            if (campaignDate == null && this.campaign.Scheduled_Date__c != null) {
                campaignDate = this.campaign.Scheduled_Date__c.month() + '/' + this.campaign.Scheduled_Date__c.day() + '/' + this.campaign.Scheduled_Date__c.year();
            }
            
            return campaignDate;
        }
        set {
            campaignDate = value;
            updateCampaignScheduledDate();
        }
    }
    
    public Integer campaignHours {
        get {
            if (campaignHours == null && this.campaign.Scheduled_Date__c != null) {
                campaignHours = (this.campaign.Scheduled_Date__c.hour() <= 12 ? this.campaign.Scheduled_Date__c.hour() : this.campaign.Scheduled_Date__c.hour() - 12);
            }
            
            return campaignHours;
        }
        set {
            campaignHours = value;
            updateCampaignScheduledDate();
        }
    }
    public Integer campaignMinutes {
        get {
            if (campaignMinutes == null && this.campaign.Scheduled_Date__c != null) {
                campaignMinutes = this.campaign.Scheduled_Date__c.minute();
            }
            
            return campaignMinutes;
        }
        set {
            campaignMinutes = value;
            updateCampaignScheduledDate();
        }
    }
    public String campaignMeridiem {
        get {
            if (campaignMeridiem == null && this.campaign.Scheduled_Date__c != null) {
                campaignMeridiem = (this.campaign.Scheduled_Date__c.hour() <= 12 ? 'AM' : 'PM');
            }
            
            return campaignMeridiem;
        }
        set {
            campaignMeridiem = value;
            updateCampaignScheduledDate();
        }
    } 
    
    public String getUserTimezoneOffset(){
        Integer offset = UserInfo.getTimeZone().getOffset(DateTime.now());
        
        Double t = Double.valueOf(offset/(1000 * 60 * 60));
        
		Integer m = Integer.valueOf((t - Math.floor(t)) * 60);

        return (t < 0 ? '-' : '+') + (Math.floor(t) < 10 ? '0' : '') + Math.abs(Integer.valueOf(Math.floor(t))) + ':' + (m < 10 ? '0' : '') + m;
    }
    public String getUserTimezoneDisplayName(){
        return UserInfo.getTimeZone().getDisplayName();
    }
    
    public static Datetime getMinDatetime() {
        if (vfIECEBC.billingAccount.eBroadcast_Trusted_Sender__c) {
            return Datetime.now();
        }
        
        List<BusinessHours> bh = [select Id from BusinessHours where Name = 'EBC Campaign Approval'];
        return BusinessHours.add(bh[0].Id, Datetime.now(), Integer.valueOf(3600 * 2 * 9 * 1000)); // 2 business day in Montreal office
    }
    
    public static Datetime getMaxDatetime() {
        return Datetime.now().addDays(31);
    }
    
    public String validationMessage {
        get {
            if (validationMessage == null) {
                Datetime dt = getMinDatetime();
                Datetime dtMax = getMaxDatetime();
                
                if (!vfIECEBC.billingAccount.eBroadcast_Trusted_Sender__c && this.campaign.Status__c != 'APPROVED' && this.campaign.Scheduled_Date__c != null && this.campaign.Scheduled_Date__c <= dt) {
                    validationMessage = 'A minimum delay of 2 business days is required for content validation by IATA. Please select a date greater than ' + dt.format('EEEE, MMM d, h:mm a', UserInfo.getTimeZone().getID());
                }/* else if (this.campaign.Scheduled_Date__c != null && this.campaign.Scheduled_Date__c > dtMax) {
                    validationMessage = 'Scheduled Date must be within 31 days. Date must NOT be greater to ' + dtMax.format('EEEE, MMM d', UserInfo.getTimeZone().getID());
                }*/
            }
            
            return validationMessage;
        }
        set;
    }
    
    public String inputScheduledDatetime {
        get;
        set;
    }
    
    
    private void updateCampaignScheduledDate() {
        try {
	        this.campaign.Scheduled_Date__c = Datetime.parse(campaignDate + ' ' + campaignHours + ':' + campaignMinutes + ' ' + campaignMeridiem);
        } catch(Exception e){}
    }
    public PageReference validate() {
        //throw new Controller_Exception('Test: ' + this.campaign.Scheduled_Date_Valid_Until__c + ' < ' + Datetime.now());
        validationMessage = null;
        
        return null;
    }
}