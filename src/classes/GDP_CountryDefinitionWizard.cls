public with sharing class GDP_CountryDefinitionWizard {

    public GDP_Area_Definition__c theObj {get;set;}
    public List<CountryItemCls> CountryItemList {get;set;}
    public List<CountrySelectedCls> CountrySelectedList {get;set;}
    private List<GDP_Area_Country__c> toDeleteList {get;set;}
    private Integer Counter=0;
    public String toSelect {get; set;}
    public String toUnselect {get; set;}
    public Boolean FlagMessage {get; set;}
    public String ErrorMessage {get;set;}
   
    public GDP_CountryDefinitionWizard(ApexPages.StandardController controller) {
        toDeleteList =new List<GDP_Area_Country__c>();
        string idc=String.escapeSingleQuotes(controller.getRecord().Id);
        theObj = [select id
                        ,Name                        
                   From GDP_Area_Definition__c 
                   Where Id =:idc limit 1];
        LoadDLI(idc);
              
    }
    
    public void LoadDLI(string idc)
    {
        CountryItemList=new List<CountryItemCls>();      
        CountrySelectedList=new List<CountrySelectedCls>();  
        
        //Read the Area Country configuration and creat a set of country id
        Set<Id> cset=new Set<Id>();
        List<GDP_Area_Country__c> clist=new List<GDP_Area_Country__c>();
        clist = [select Id
                    ,Method__c
                    ,IATA_ISO_Country__c
                    ,IATA_ISO_Country__r.ISO_Code__c
                    ,IATA_ISO_Country__r.Name
                    ,IATA_ISO_Country__r.Region__c
                   From GDP_Area_Country__c          
                   Where GDP_Area_Definition__c=:idc 
                    order by IATA_ISO_Country__r.name
                   Limit 1000];
        Counter=0;
        for(GDP_Area_Country__c cli:clist)
        {
          CountrySelectedCls nsc=new CountrySelectedCls(Counter, null,cli);
          CountrySelectedList.add(nsc);
          cset.add(cli.IATA_ISO_Country__c);
          Counter++;
        } 
        
        
        //Read all the kown Counties from IATA List and excluded the one selected already        
        List<IATA_ISO_Country__c> dlist = IATAIsoCountryDAO.sortIATAIsoCountryList(IATAIsoCountryDAO.getIsoCountries(), 'Name');
        
        Counter=0;                      
        for(IATA_ISO_Country__c dli:dlist)
        {
          if (cset.Contains(dli.id))
          {
           //just make sure to reinject the country
           for (CountrySelectedCls ncc:CountrySelectedList)
           {
            if (ncc.CountrySelected.IATA_ISO_Country__c==dli.id) {ncc.country=dli;}
           }
           continue;
          }
          CountryItemCls nsc=new CountryItemCls(Counter,dli);
          CountryItemList.add(nsc);
          Counter++;
        }
    }
   
    
    public PageReference GoBack()
    {
     return new PageReference('/' + ApexPages.currentPage().getParameters().get('Id'));
    }
    public PageReference DoUpdate()
    {
     if (!SaveCountryItemList()) return null;
     return null;
     
    }
    private boolean SaveCountryItemList()
     {
      ErrorMessage='';
      try
       {
       list<GDP_Area_Country__c> clist = new list<GDP_Area_Country__c>();          
      
       for(CountrySelectedCls dli:CountrySelectedList)
        {
          if (dli.CountrySelected==null) dli.CountrySelected=new GDP_Area_Country__c(GDP_Area_Definition__c=theObj.id,IATA_ISO_Country__c=dli.country.id,Method__c='Include');
          clist.add(dli.CountrySelected);
        }
        upsert clist;
        if (toDeleteList.size()>0) delete toDeleteList;
        toDeleteList.Clear();
       }
       catch(Exception ex)
       {
        return false;
       }
       LoadDLI(theObj.Id);
      return true;
    }
    public PageReference AddToCountryCart(){
        Integer Counter=0;        
        for(CountrySelectedCls dli:CountrySelectedList)
        {
            if (Counter<dli.Counter)  Counter=dli.Counter;
        }
        Counter++;
        integer indexremove=0;
        for(CountryItemCls dli:CountryItemList)
        {
            if (Integer.ValueOf(toSelect)==dli.Counter)
            {
              CountrySelectedCls nsc = new CountrySelectedCls(Counter, dli.country,null);
              CountrySelectedList.add(nsc);
              CountryItemList.Remove(indexremove);
              break;
            }
            indexremove++;
        }
       
        return null;
    }
    public PageReference RemoveCountryCart(){
        Integer Counter=0;        
        for(CountryItemCls dli:CountryItemList)
        {
            if (Counter<dli.Counter)  Counter=dli.Counter;
        }
        Counter++;
        CountryItemCls nsc=new CountryItemCls(Counter,null);
        List<CountrySelectedCls> nlist= new List<CountrySelectedCls>();
        for(CountrySelectedCls dli:CountrySelectedList)
        {
            if (Integer.ValueOf(toSelect)!=dli.Counter) nlist.add(dli);
            if (Integer.ValueOf(toSelect)==dli.Counter) nsc.country=dli.country;
            if (Integer.ValueOf(toSelect)==dli.Counter && dli.CountrySelected!=null) toDeleteList.add(dli.CountrySelected);
            
        }
        CountrySelectedList=nlist;
        CountryItemList.add(nsc);
        return null;
    }
    public Class CountryItemCls
    {
      public Boolean selected {get;set;}
      public IATA_ISO_Country__c country {get;set;}
      public Integer Counter {get;set;}
      public CountryItemCls(Integer vcounter, IATA_ISO_Country__c vcountry)
      {
        this.Counter=vcounter;
        this.country = vcountry;
        this.selected=false;
      }
    }
    public Class CountrySelectedCls
    {
      public Boolean selected {get;set;}
      public IATA_ISO_Country__c country {get;set;}
      public Integer Counter {get;set;}
      public GDP_Area_Country__c CountrySelected {get;set;}
      public String CountryName {get;set;}
      public String CountryCode {get;set;}
      public String CountryRegion {get;set;}
      
      public CountrySelectedCls(Integer vcounter, IATA_ISO_Country__c vcountry, GDP_Area_Country__c vcselected)
      {
        this.Counter=vcounter;
        this.country = vcountry;
        this.CountrySelected=vcselected;
        this.selected=false;
        if (vcountry!=null)
        {
            this.CountryName = vcountry.Name;
            this.CountryCode = vcountry.ISO_Code__c;
            this.CountryRegion=vcountry.Region__c;
        }
        if (vcselected!=null)
        {
            this.CountryName = vcselected.IATA_ISO_Country__r.Name;
            this.CountryCode = vcselected.IATA_ISO_Country__r.ISO_Code__c;
            this.CountryRegion=vcselected.IATA_ISO_Country__r.Region__c;
        }
      }
    }
}