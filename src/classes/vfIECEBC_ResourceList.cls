public class vfIECEBC_ResourceList extends vfIECEBC_Abstract_List {
    public Decimal STORAGE_CAPACITY=1; //in mg
    public Decimal FILE_SIZE_MAX=1; //in meg
    private boolean firsttimepageload=true;

    public boolean MessageFlag {
        get {
                if (MessageFlag==null) {
                    MessageFlag=false;
                } 
            return Messageflag;
        }
        private set;
    }
    public String MessageContent {get;set;}
    
    public boolean loadmoreimage{
        get {
         AggregateResult[] groupedResults = [Select Sum(Image_Size__c) From EBC_Resource__c
                       			Where Billing_Account__c=:vfIECEBC.billingAccount.Id];
          
          
          Decimal mb=0;
          for (AggregateResult ar : groupedResults)  {
                //MB

                if (ar.get('expr0')==null) continue;
                mb = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
                mb = (mb / (STORAGE_CAPACITY * 1024*1024))*100;
               
            }
           if (mb>=100) return false;
           return true;
          }
      private set;  
    }
    public vfIECEBC_ResourceList() {
        sortBy='CreatedDate Desc';
        MessageFlag=false;
        MessageContent='';
        UploadInit();
        List<EBC_Setup__c> setup = new List<EBC_Setup__c>();
                setup=[Select Default_Storage_Capacity__c,
                       			Maximum_File_Size_Upload__c
                            From EBC_Setup__c
                            Limit 1];
        if (setup.size()>0) {STORAGE_CAPACITY=setup[0].Default_Storage_Capacity__c;}
        if (setup.size()>0) {FILE_SIZE_MAX=setup[0].Maximum_File_Size_Upload__c;}
        List<Zuora__CustomerAccount__c> billingaccount = new List<Zuora__CustomerAccount__c>();
        billingaccount=[Select eBroadcast_Storage__c
                        From Zuora__CustomerAccount__c
        				Where Id=:vfIECEBC.billingAccount.Id Limit 1];
        if (billingaccount.size()>0) {
            if (billingaccount[0].eBroadcast_Storage__c!=null) {STORAGE_CAPACITY=billingaccount[0].eBroadcast_Storage__c;}
        }
        
    }
    
    public override List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        if (getIsFirstTimeLoadPage()) options.add(new SelectOption('CreatedDate DESC','Sort by'));
        options.add(new SelectOption('Name ASC','Image Name'));
        options.add(new SelectOption('Image_Type__c DESC','Image Type'));
        options.add(new SelectOption('Image_size__c DESC','Image Size'));    
        
        options.add(new SelectOption('CreatedDate ASC','Upload Date - Ascending'));
        options.add(new SelectOption('CreatedDate DESC','Upload Date - Descending')); 
        return options;
       
    }
    
    private String getQuery(Boolean isCountOnly) {
        
        List<String> fields = new List<String>();
        if (isCountOnly) {
            fields.add('count()');
        } else {
            fields.add('Id');
            fields.add('Name');
            fields.add('Image_Type__c');
            fields.add('Image_Size__c');
            fields.add('Thumbnail_URL__c');
            fields.add('Image_URL__c');
            fields.add('Size_KBytes__c');
            fields.add('CreatedDate');
            fields.add('LastModifiedDate'); 
        }
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Resource__c Where IsDeleted=false and Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
        
        //return 'Select ' + String.join(fields, ',') + ' FROM EBC_Template__c Where Is_Reusable__c  = true AND Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
    }
    
    public List<EBC_Resource__c> getFilters() {
        return (List<EBC_Resource__c>)items; 
    }
    public EBC_Resource__c getSelectedFilter() {
        return (EBC_Resource__c)selectedItem; 
    }
    private Boolean getIsFirstTimeLoadPage() { 
        if (firsttimepageload) {firsttimepageload=false; return true;}
        return false;}
    //Upload
        
    public void UploadInit()
    {  
     attachment = null;
    }  
    public Attachment attachment {
      get {
          if (attachment == null)
            attachment = new Attachment();
          return attachment;
        }
      set;
      }
    public String gaugestorage
    {
      get {
         
          AggregateResult[] groupedResults = [Select Sum(Image_Size__c) From EBC_Resource__c
                       			Where Billing_Account__c=:vfIECEBC.billingAccount.Id];
          
          gaugestorage ='0mb of '+String.ValueOf(STORAGE_CAPACITY.Setscale(0))+'mb';
          for (AggregateResult ar : groupedResults)  {
                //MB
                Decimal mb=0;
                if (ar.get('expr0')==null) continue;
                mb = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
                mb = mb / (1024*1024);
                gaugestorage =String.ValueOf(mb.Setscale(2))+ 'mb of '+String.ValueOf(STORAGE_CAPACITY.Setscale(0))+'mb';
            }
           
          
          return gaugestorage;
        }
      private set;  
    }
    public String gaugepercent
    {
      get {
          
          AggregateResult[] groupedResults = [Select Sum(Image_Size__c) From EBC_Resource__c
                       			Where Billing_Account__c=:vfIECEBC.billingAccount.Id];
          
          gaugepercent ='0%;';
          Decimal mb=0;
          for (AggregateResult ar : groupedResults)  {
                //MB

                if (ar.get('expr0')==null) continue;
                mb = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
                mb = (mb / (STORAGE_CAPACITY * 1024*1024))*100;
               
            }
           if (mb>=100) mb=100;
           gaugepercent =String.ValueOf(mb.Setscale(0))+ '%;';
          
          return gaugepercent;
        }
      private set;  
    }
    public Pagereference ClearMessage()
    {
        MessageFlag=false;
        MessageContent='';
        return null;
    }
    public Pagereference SaveAttachments()  
    {
        MessageFlag=false;
        MessageContent='';
        try {
            IECEBC_Utility.createResourceForAttachment(attachment, vfIECEBC.billingAccount);
        } catch(IECEBC_Utility.Resource_Invalid_Attachment_Exception e) {
            MessageFlag=true;
            MessageContent=e.getMessage();
            UploadInit();
            return null;
        } catch(IECEBC_Utility.Attachment_Size_Exceeds_Capacity_Exception e) {
            MessageFlag=true;
            MessageContent=e.getMessage();
            UploadInit();
            return null;
        }
        
        
        attachment.Name = String.valueOf('image.png');
        attachment.OwnerId = UserInfo.getUserId();
        attachment.IsPrivate = true;
            
        insert attachment;
        
        UploadInit();
        resetQuery();
        
        return null;
    }
    //Upload
    
}