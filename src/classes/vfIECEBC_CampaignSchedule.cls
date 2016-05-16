public class vfIECEBC_CampaignSchedule {
    class Controller_Exception extends Exception{}
    
    public EBC_Campaign__c campaign { get; set; }
    public ApexPages.StandardController con { public get; private set; }
    
    public vfIECEBC_CampaignSchedule(ApexPages.StandardController stdController) {
        this.con = stdController;
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
        
        validate();
    }
    
    
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
    
    public Datetime getMinDatetime() {
        List<BusinessHours> bh = [select Id from BusinessHours where Name = 'Americas - Canada'];
        return BusinessHours.add(bh[0].Id, Datetime.now(), Integer.valueOf(3600 * 2 * 8.5 * 1000)); // 2 business day in Montreal office
    }
    
    public String validationMessage { get; set; }
    
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
        validationMessage = null;
        
        if (this.campaign.Scheduled_Date__c != null && this.campaign.Scheduled_Date__c < getMinDatetime()) {
        	validationMessage = 'A delay of minimum 2 business days is required. Date must be greater to ' + getMinDatetime().format('EEEE, MMM d, h:mm a', UserInfo.getTimeZone().getID());
        }
        
        return null;
    }
}