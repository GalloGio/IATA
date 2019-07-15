public with sharing class GDP_FileDefRatePlanDefWizard {

    public zqu__ProductRatePlan__c theObj {get;set;}
    public List<FileDescriptionItemCls> FileDescriptionItemList {get;set;}
    public List<FileDescriptionSelectedCls> FileDescriptionSelectedList {get;set;}
    private List<GDP_File_Description_To_Rate_Plan__c> toDeleteList {get;set;}
    private Integer Counter=0;
    public String toSelect {get; set;}
    public String toUnselect {get; set;}
    public Boolean FlagMessage {get; set;}
    public String ErrorMessage {get;set;}
    public String fmagnitude {get;set;}
    public String ffileformat {get;set;}
    public String fproducttype {get;set;}
    public String fcoverage {get;set;}
    public String idc {get;set;}
    public GDP_File_Description__c filterdefinition {get;set;}
   
    public GDP_FileDefRatePlanDefWizard(ApexPages.StandardController controller) {
        fmagnitude='';  
        fproducttype='';
        ffileformat='';
        fcoverage='';
        filterdefinition = new GDP_File_Description__c();
        toDeleteList =new List<GDP_File_Description_To_Rate_Plan__c>();
        idc=String.escapeSingleQuotes(controller.getRecord().Id);
        theObj = [select id
                        , Name
                        , zqu__Product__c
                        , zqu__Product__r.name
                   From zqu__ProductRatePlan__c
                   Where Id =:idc limit 1];
        LoadDLI(true);
              
    }
    public PageReference refetch()
    {
     LoadDLI(false);
     return null;
    }
    
    public String getMagnitudes()
    {
     String options = '';        
     Schema.DescribeFieldResult fieldResult = GDP_File_Description__c.Magnitude__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
       for( Schema.PicklistEntry f : ple)
       {
          options += '"'+f.getLabel()+'","'+f.getLabel()+'",';
       }       
       return options;
    } 
    public String getProductTypes()
    {
     String options = '';       
     Schema.DescribeFieldResult fieldResult = GDP_File_Description__c.Product_Type__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
       for( Schema.PicklistEntry f : ple)
       {
          
          if (f.getLabel()=='CAC') continue;
          if (f.getLabel()=='CACEWS') continue;
          if (f.getLabel()=='CACSWS') continue;
          options += '"'+f.getLabel()+'","'+f.getLabel()+'",';
       }       
       return options;
    } 
    public String getFileFormats()
    {
     String options = '';        
     Schema.DescribeFieldResult fieldResult = GDP_File_Description__c.File_Format__c.getDescribe();
     List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
       for( Schema.PicklistEntry f : ple)
       {
           options += '"'+f.getLabel()+'","'+f.getLabel()+'",';
       }       
       return options;
    } 
    public String getGeoCoverages()
    {
     String options = '';        
     list<GDP_Area_Definition__c> listg = new list<GDP_Area_Definition__c>();
     listg= [select id, Name                        
                   From GDP_Area_Definition__c
                   Order by name
                   Limit 1000];
      for(GDP_Area_Definition__c f : listg)
       {
           options += '"'+f.name+'","'+f.id+'",';
       }      
       return options;
    } 
    public void LoadDLI(Boolean FlagFirstTime)
    {
        FileDescriptionItemList=new List<FileDescriptionItemCls>();      
        if (FlagFirstTime) FileDescriptionSelectedList=new List<FileDescriptionSelectedCls>();  
        
        //Read the Area FileDescription configuration and creat a set of definition id
        Set<Id> cset=new Set<Id>();
        List<GDP_File_Description_To_Rate_Plan__c> clist=new List<GDP_File_Description_To_Rate_Plan__c>();
        clist = [select Id
                    ,GDP_File_Description__c
                    ,GDP_File_Description__r.name
                    ,GDP_File_Description__r.Class__c
                    ,GDP_File_Description__r.Frequency__c
                    ,GDP_File_Description__r.Magnitude__c
                    ,GDP_File_Description__r.File_Format__c
                    ,GDP_File_Description__r.Reference__r.Product_Type__c
                    ,GDP_File_Description__r.Geo_Coverage_Definition__r.name
                    ,Product_Rate_Plan__c
                  From GDP_File_Description_To_Rate_Plan__c          
                   Where Product_Rate_Plan__c=:idc 
                    and  GDP_File_Description__r.product_type__c not in ('CAC', 'CACSWS','CACEWS')
                    order by GDP_File_Description__r.Product_Type__c, GDP_File_Description__r.name
                   Limit 1000];
        Counter=0;
        for(GDP_File_Description_To_Rate_Plan__c cli:clist)
        {
          FileDescriptionSelectedCls nsc=new FileDescriptionSelectedCls(Counter, null,cli);
          if (FlagFirstTime) FileDescriptionSelectedList.add(nsc);
          cset.add(cli.GDP_File_Description__c);
          Counter++;
        } 
        
        
        //Read all the kown Counties from IATA List and excluded the one selected already        
        List<GDP_File_Description__c> dlist=new List<GDP_File_Description__c>();
        string sql='select Id';
        sql +=',Name';
        sql +=',Class__c';
        sql +=',Frequency__c';
        sql +=',Magnitude__c';
        sql +=',File_Format__c';
        sql +=',Reference__r.Product_Type__c';
        sql +=',Geo_Coverage_Definition__r.name';
        sql +=' From GDP_File_Description__c ';
        sql +=' Where Is_Reference__c=false and product_type__c not in (\'CAC\', \'CACSWS\',\'CACEWS\')';
        sql +=' and magnitude__c=:fmagnitude';
        sql +=' and product_type__c=:fproducttype';
        sql +=' and file_format__c=:ffileformat';
        sql +=' and geo_coverage_definition__c=:fcoverage';
        sql +=' order by Reference__r.Product_Type__c,name';
        sql +=' Limit 1000';
                   
        if (fmagnitude=='') sql = sql.Replace('and magnitude__c=:fmagnitude','');  
        if (fproducttype=='') sql = sql.Replace('and product_type__c=:fproducttype','');
        if (ffileformat=='') sql = sql.Replace('and file_format__c=:ffileformat','');
        if (fcoverage=='') sql = sql.Replace('and geo_coverage_definition__c=:fcoverage','');
             
        dlist = database.query(sql);
        
        Counter=0;                      
        for(GDP_File_Description__c dli:dlist)
        {
          if (cset.Contains(dli.id))
          {
           //just make sure to reinject the definition
           for (FileDescriptionSelectedCls ncc:FileDescriptionSelectedList)
           {
            if (ncc.FileDescriptionSelected.GDP_File_Description__c==dli.id) {ncc.definition=dli; }
           }
           continue;
          }
          FileDescriptionItemCls nsc=new FileDescriptionItemCls(Counter,dli);
          FileDescriptionItemList.add(nsc);
          Counter++;

        }
                               
        
    }
    public PageReference onSelectInvoice()
    {

        return null;
    }
    
    public PageReference GoBack()
    {
     return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    public PageReference DoUpdate()
    {
     if (!SaveFileDescriptionItemList()) return null;
     return null;
     
    }
    private boolean SaveFileDescriptionItemList()
     {
      ErrorMessage='';
      try
       {
       list<GDP_File_Description_To_Rate_Plan__c> clist = new list<GDP_File_Description_To_Rate_Plan__c>();          
      
       for(FileDescriptionSelectedCls dli:FileDescriptionSelectedList)
        {
          if (dli.FileDescriptionSelected==null) dli.FileDescriptionSelected=new GDP_File_Description_To_Rate_Plan__c(Product_Rate_Plan__c=theObj.id,GDP_File_Description__c=dli.definition.id);
          clist.add(dli.FileDescriptionSelected);
        }
        upsert clist;
        if (toDeleteList.size()>0) delete toDeleteList;
        toDeleteList.Clear();
       }
       catch(Exception ex)
       {
        return false;
       }
       LoadDLI(true);
      return true;
    }
    public PageReference AddToFileDescriptionCart(){
        Integer Counter=0;        
        for(FileDescriptionSelectedCls dli:FileDescriptionSelectedList)
        {
            if (Counter<dli.Counter)  Counter=dli.Counter;
        }
        Counter++;
        integer indexremove=0;
        for(FileDescriptionItemCls dli:FileDescriptionItemList)
        {
            if (Integer.ValueOf(toSelect)==dli.Counter)
            {
              FileDescriptionSelectedCls nsc = new FileDescriptionSelectedCls(Counter, dli.definition,null);
              FileDescriptionSelectedList.add(nsc);
              FileDescriptionItemList.Remove(indexremove);
              break;
            }
            indexremove++;
        }
       
        return null;
    }
    public PageReference RemoveFileDescriptionCart(){
        Integer Counter=0;        
        for(FileDescriptionItemCls dli:FileDescriptionItemList)
        {
            if (Counter<dli.Counter)  Counter=dli.Counter;
        }
        Counter++;
        FileDescriptionItemCls nsc=new FileDescriptionItemCls(Counter,null);
        List<FileDescriptionSelectedCls> nlist= new List<FileDescriptionSelectedCls>();
        for(FileDescriptionSelectedCls dli:FileDescriptionSelectedList)
        {
            if (Integer.ValueOf(toSelect)!=dli.Counter) nlist.add(dli);
            if (Integer.ValueOf(toSelect)==dli.Counter) {nsc.definition=dli.definition; }
            if (Integer.ValueOf(toSelect)==dli.Counter && dli.FileDescriptionSelected!=null) toDeleteList.add(dli.FileDescriptionSelected);
            
        }
        FileDescriptionSelectedList=nlist;
        
        FileDescriptionItemList.add(nsc);
        return null;
    }
    public Class FileDescriptionItemCls
    {
      public Boolean selected {get;set;}
      public GDP_File_Description__c definition {get;set;}
      public Integer Counter {get;set;}
      public FileDescriptionItemCls(Integer vcounter, GDP_File_Description__c vdefinition)
      {
        this.Counter=vcounter;
        this.definition = vdefinition;
        this.selected=false;
      }
    }
    public Class FileDescriptionSelectedCls
    {
      public Boolean selected {get;set;}
      public Boolean recordexists {get;set;}
      public GDP_File_Description__c definition {get;set;}
      public Integer Counter {get;set;}
      public GDP_File_Description_To_Rate_Plan__c FileDescriptionSelected {get;set;}
     
      
      public FileDescriptionSelectedCls(Integer vcounter, GDP_File_Description__c vdefinition, GDP_File_Description_To_Rate_Plan__c vdselected)
      {
        this.Counter=vcounter;
        this.definition = vdefinition;
        this.FileDescriptionSelected=vdselected;
        this.selected=false;

        if (FileDescriptionSelected!=null)
        {
            if (FileDescriptionSelected.id!=null) recordexists=true;
         }
      }
  
    }
}