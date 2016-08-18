public class vfIECEBC_ResourceList extends vfIECEBC_Abstract_List {
    public static Integer ITEMS_PER_PAGE = 200;
    public Decimal STORAGE_CAPACITY=1; //in mg
    private boolean firsttimepageload=true;
    public vfIECEBC_ResourceList() {
        sortBy='CreatedDate Desc';
        UploadInit();
        List<EBC_Setup__c> setup = new List<EBC_Setup__c>();
                setup=[Select Default_Storage_Capacity__c 
                            From EBC_Setup__c
                            Limit 1];
        if (setup.size()>0) {STORAGE_CAPACITY=setup[0].Default_Storage_Capacity__c;}
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
        options.add(new SelectOption('CreatedDate DESC','Creation Date')); 
        options.add(new SelectOption('Image_size__c DESC','Image Size'));
        options.add(new SelectOption('Image_Type__c DESC','Image Type'));
        options.add(new SelectOption('Name ASC','Name'));

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
          
          gaugestorage ='0mb of 10mb';
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
          for (AggregateResult ar : groupedResults)  {
                //MB
                Decimal mb=0;
                if (ar.get('expr0')==null) continue;
                mb = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
                mb = (mb / (STORAGE_CAPACITY * 1024*1024))*100;
                if (mb>100) mb=100;
                gaugepercent =String.ValueOf(mb.Setscale(0))+ '%;';
            }
           
          
          return gaugepercent;
        }
      private set;  
    }
     
     
    public Pagereference SaveAttachments()  
    {  
         if (attachment.name == '' || attachment.body == null)  return null;
        
         AggregateResult[] groupedResults = [Select Sum(Image_Size__c) From EBC_Resource__c
                       			Where Billing_Account__c=:vfIECEBC.billingAccount.Id];
          
        //Control over STORAGE CAPACITY
        Decimal mb=0;
        for (AggregateResult ar : groupedResults)  {
                //MB
                
                if (ar.get('expr0')==null) continue;
                mb = Decimal.ValueOf(String.ValueOf(ar.get('expr0')));
                
            }
        String bodyEncoded = EncodingUtil.base64Encode(attachment.body);  
        Decimal mk = bodyEncoded.length();
        //mb = mb +mk;
        mb = (mb / (STORAGE_CAPACITY * 1024*1024))*100;
        if (mb>=105) return null;
              
        
        
        //if (!attachment.Name.Contains('.png')) return null;
        //if (!attachment.Name.Contains('.jpg')) return null;
        //if (!attachment.Name.Contains('.gif')) return null;
        List<EBC_Resource__c> resourcelist= new List<EBC_Resource__c>();
        resourcelist = [Select id From EBC_Resource__c
                       			Where name=:attachment.name
                       			and Billing_Account__c=:vfIECEBC.billingAccount.Id
                       Limit 1];
        if (resourcelist.Size()>0) return null;
        
        String typen = attachment.Name.right(3);
        EBC_Resource__c AttachmentParentRec = new EBC_Resource__c();
        AttachmentParentRec.Billing_Account__c=vfIECEBC.billingAccount.Id;
        AttachmentParentRec.name = attachment.name;
        
        AttachmentParentRec.Image_Size__c = bodyEncoded.length();
        AttachmentParentRec.Image_Type__c = typen;
        Insert AttachmentParentRec; 
        
        
        
        attachment.Name = String.valueOf('image.png');
        attachment.ParentId = AttachmentParentRec.Id;
        
        attachment.OwnerId = UserInfo.getUserId();
        attachment.IsPrivate = true;
            
        insert attachment;
              
        UploadInit();
        resetQuery();
        return null;  
    }  
    
    
    //Upload
    
}