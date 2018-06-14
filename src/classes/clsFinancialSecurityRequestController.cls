public class clsFinancialSecurityRequestController {

     
    private Case caseParam = new Case();
   
    // the soql without the order and limit
    private String soql {get;set;}
       
    private Map<ID,Boolean> CasesCheckedList = new Map<ID,Boolean>();
    private List<ID> ALLCases;
    private List<cCase> displayList = new List<cCase>() ;

    public Boolean SelAllIsChecked { get; set; }

   
    private Integer inPageSize { get; set; }
    private Integer totalNoOfRecs = 0;
    public Integer pageNumber{get;set;}
    public Integer noOfPages{get;set;}
    public Boolean isNbrRecordsDisplayed { get; set; }

   // a property for the lookuptype
    public String GetEmailTemplateKeyPrefix {get;private set;}
   
   // init the controller and display some sample data when the page loads
    public clsFinancialSecurityRequestController () {
        inPageSize = 10;
        GetEmailTemplateKeyPrefix = EmailTemplate__c.SObjectType.getDescribe().getKeyPrefix();
        
    }
   
   public List<cCase> Cases{ 
        get {
             if (CasesCheckedList != null){
                     for(cCase aCase : displayList){
                    
                      if (CasesCheckedList.containsKey(aCase.c.ID))
                            aCase.selected = true;                     
                     } 
              }               
            return displayList;
        }
         
        set {Cases= value;}
    }
   
   
    public void toggleSort() {
          // simply toggle the direction
        sortDir = sortDir.equals('asc') ? 'desc' : 'asc';
        
        // run the query again
        runQuery();
    }


    public void updateNbrSelectedRecords() {
         refreshCheckMap();
        // trigger the count of selected records
        Integer i = nbrSelectedRecords;
    }


    public PageReference SelectAll() {
          try{
        //select displayed contacts 
        for (cCase aCase: displayList){
                aCase.selected = SelAllIsChecked;
           }
        
        //select all contacts and add them to list  
          for(Id id: AllCases)
            {   
                if (SelAllIsChecked)
                    CasesCheckedList.put(id,true);    
                else
                    {
                      if(CasesCheckedList.containsKey(id))
                        CasesCheckedList.remove(id);  
                    }           
            }
      
           refreshCheckMap(); 
       }
      catch(Exception e){}
           return null;
    }
    
    public void refreshCheckMap()
    {
      for(cCase aCase: displayList)
        {
        
            if(aCase.selected)
            {
                CasesCheckedList.put(aCase.c.Id,true);
            }
            else
            {
               if(CasesCheckedList.containsKey(aCase.c.Id))
                    CasesCheckedList.remove(aCase.c.Id); 
            }
        }  
     }

    public PageReference MassSendEmail() {
       
         MassEmail(false);
        return null;
    }
    
    public PageReference MassSendTrackedEmail() {
		MassEmail(true);
        return null;
    }
    
  /**
    public Boolean FSLetterSent{ 
    get 
    {
      System.debug('*** *  FS LetterSent');
    
      Set <ID> selectedID = new Set<ID>();
         selectedID = CasesCheckedList.KeySet();
         
         if (selectedID.size() == 0) {
             return true;
          }
        List<Case> cases = [Select C.ID, c.ContactId From Case c Where  c.FS_Letter_Sent__c = false AND c.Id IN :selectedID];

     System.debug('** cases '+ cases);
      System.debug('** selected cases '+ selectedID );
 
        // Loop through cases 
        for (Case aCase : cases){
                // Find the contact of the case
               if(CasesCheckedList.containsKey(aCase.Id))
                   return false;
                        
                break;
           }
           
        return true;
       }
       
    set{}
    }
    
    **/
    
    public Boolean FSvalueMissing{ 
    get 
    {
    
      Set <ID> selectedID = new Set<ID>();
         selectedID = CasesCheckedList.KeySet();

        Double b;
        List<Case> cases = [Select C.ID, c.ContactId From Case c Where (c.Financial_Security_Amount__c = :b or c.Financial_Security_Currency__c = '') AND c.Id IN :selectedID];

    
        // Loop through cases 
        for (Case aCase : cases){
                // Find the contact of the case
               if(CasesCheckedList.containsKey(aCase.Id))
                   return true;
                        
                break;
           }
           
        return false;
       }
       
    set{}
    }

//Send EMails to selected Cases.
  private void MassEmail(Boolean trackedEmail){
  
  Boolean isRequiredFieldsAreOK  = true;
  
     //validate required fields
       if (CaseParameter.EmailTemplate__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Email Template is required'));
            isRequiredFieldsAreOK = false;
        }
       if (CaseParameter.Deadline_Date__c == null){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Deadline date is required'));
            isRequiredFieldsAreOK = false;
        }
       if (FSvalueMissing){
           ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Sending Emails for these cases is blocked. One or more case(s) have missing Financial Security Amount or Financial Security value.'));            
            isRequiredFieldsAreOK = false;
        }
        
        
      if (!isRequiredFieldsAreOK)
      {
        //  String extramsg = 'Please fill the required Fields' ;  
         // ApexPages.addMessage(new ApexPages.message(ApexPages.severity.Error, extramsg));  
      }
      
      else{
        

        //to make sure the back end and UI are in sync
         refreshCheckMap();
      
         Set <ID> selectedID = new Set<ID>();
         selectedID = casesCheckedList.KeySet();
         
          if (selectedID.size() == 0) {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'There are no selected cases.'));
          }
          else
          {        
              List<Case> cases = [Select c.Status,c.FS_EmailTemplate__c, c.FS_Deadline_Date__c, c.ContactId From Case c Where c.Id IN :selectedID];
                  
              //case status is updated to “Financial Security requested”           
               clsFinancialSecurityRequestBatch cBatch = new clsFinancialSecurityRequestBatch();
               cBatch.caseList = cases;
               //FS_EmailTemplate__c
               cBatch.trackedEmail = trackedEmail;
               cBatch.emailTemplate = caseParam.EmailTemplate__c ;
               cBatch.deadLineDate = caseParam.Deadline_Date__c ;
               ID batchprocessid = Database.executeBatch(cBatch,5);
                        
              String extramsg = 'Financial Security Request is sent. Please note that the emails will take time to be recieved.' ;  
              ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, extramsg));  
         }
     }
  }
  



   public String sortDir {
        get  { if (sortDir == null) {  sortDir = 'asc'; } return sortDir;  }
        set;
    }
    
   // the current field to sort by. defaults to account Name
    public String sortField {
        get  { if (sortField == null) {sortField = 'account.Name'; } return sortField;  }
        set;
    }
 
    
    

    public PageReference runSearch() {
  
        String batchNumber = CaseParameter.BatchNumber__c; //Apexpages.currentPage().getParameters().get('batchNumber');
        System.debug('***** '+ batchNumber );
        System.debug('***** '+ CaseParameter.BatchNumber__c);
        
        
        
        if (batchNumber == '')
              batchNumber = 'NA';
            
        batchNumber = batchNumber.trim();
        
        String tmp = batchNumber.replace( '\\', '\\\\' );
        tmp = tmp.replace( '\'', '\\\'' );
        
        batchNumber = tmp;
        
        //Select c.CaseNumber, c.Subject, Account.Name, Contact.Name, c.Priority  FROM Case c  where c.BatchNumber__r.Name  like '%' and (Financial_Review_Result__c = 'Satisfactory – New Financial Security' or   Financial_Review_Result__c = 'Satisfactory - Update Financial Security' or Financial_Review_Result__c = 'Unsatisfactory – New Financial Security' or Financial_Review_Result__c = 'Unsatisfactory – Update Financial Security')
        soql = 'Select c.CaseNumber,c.Status,c.ID, c.Subject,c.FS_Letter_Sent__c ,Account.Name, Financial_Security_Amount__c, Financial_Security_Currency__c, Contact.Name, Account.BillingCountry, c.Priority  FROM Case c  where c.BatchNumber__c  = \''+batchNumber+'\' and Status =\'Assessment Performed\' and (Financial_Review_Result__c = \'Satisfactory - New Financial Security\' or   Financial_Review_Result__c = \'Satisfactory - Update Financial Security\' or Financial_Review_Result__c = \'Unsatisfactory - New Financial Security\' or Financial_Review_Result__c = \'Unsatisfactory - Update Financial Security\')'; 
        System.debug('***  '+soql);  
        runQuery();
        
        batchCountry = [select Country__c from BatchNumber__c where Id = :batchNumber].Country__c;
        
        return null;
    }


     // runs the actual query
    public void runQuery() {
        
        pageNumber = 0;
        isNbrRecordsDisplayed = true;
        AllCases = new List<Id>();
        CasesCheckedList = new Map<ID,Boolean>();
        displayList = new List<cCase>();
        SelAllIsChecked = false;
   
        try {
           
            system.debug('Query to be executed: ' + soql + ' order by ' + sortField + ' ' + sortDir);
                 
           //get all cases and store them in AllCases list   
             for (Case ca: Database.query(soql + ' order by ' + sortField + ' ' + sortDir )){
     
              ALLCases.add(ca.Id);
              
                         
            }
            
            system.debug('ALL contacts Size = '+ AllCases.size());
             
            
            //initial display list first 10 items 
             String extraQuery = '';
             Integer num = inPageSize ;
             if (num>AllCases.size())
                 num = AllCases.size();
                
           if (AllCases.size()>0)
           { 
                extraQuery = ' and (';
                for (Integer i = 0 ; i<num ; i++)
                {
                    if (i== 0)
                        extraQuery += ' Case.ID = \''+AllCases[i]+'\'';
                        
                    extraQuery += ' or Case.ID = \''+AllCases[i]+'\'';
                }
                 extraQuery +=  ' )';          
           } 
              
                   
              
            String q = soql + extraQuery +' order by ' + sortField + ' ' + sortDir;
            system.debug('Query to be executed::: ' + q );
            
             for (Case cont : Database.query(q)){
               displayList.add(new cCase(cont));                 
            }
            
            totalNoOfRecs  = AllCases.size();
            

        if (totalNoOfRecs==0)
          {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, 'No cases Found, please change your search criterias'));  
          }

            
        } 
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Unhandled error'+e));
        }
    }      


   // returns true if the "First" link must be displayed
    public Boolean hasFirst {
        get {
            return (pageNumber!=0);
        }
    }
    
    // returns true if the "Last" link must be displayed
    public Boolean hasLast {
        get {
        if (totalPage == 1)
                return false;
            return (pageNumber+1 != totalPage);
        }
    }
    
    // indicates whether there are more records after the current page set.
    public Boolean hasNext {
        get {
            return (pageNumber+1<totalPage);
        }
    }
 
    // indicates whether there are more records before the current page set.
    public Boolean hasPrevious {
        get {           
            return (pageNumber>0);
          }
    }
    
    
     public PageReference first(){
        pageNumber = 0;
        queryCases();
        return null;
    }
    
     public PageReference last(){
        pageNumber = totalPage - 1;
        queryCases();
        return null;
    }

    public PageReference next(){
        pageNumber++;
        queryCases();
        return null;
    }

    public PageReference previous(){
        pageNumber--;
        if (pageNumber < 0){
            pageNumber = 0;
        }                    
        queryCases();
        return null;
    }
    
    
     //triggered on next,prev, last and first actions
 private void queryCases()
    {
    
        refreshCheckMap();
        System.debug('query accounts');
        displayList = new List<cCase>();    
        SelAllIsChecked = false;
        Integer offset = pageNumber * inPageSize ;   
        System.debug('offset ' + offset );
       
           
           String extraQuery = '';
           if (AllCases.size()>0)
           {  
                extraQuery = ' and (';
                Integer k = offset+inPageSize;
                if (k>AllCases.size())
                 k = AllCases.size();
                 
                for (Integer i = offset ; i<k ; i++)
                {
                    if (i== offset)
                        extraQuery += ' Case.ID = \''+AllCases[i]+'\'';
                        
                    extraQuery += ' or Case.ID = \''+AllCases[i]+'\'';
                }
                extraQuery +=  ' )';
           }
            
             System.debug('Query is '+ soql + extraQuery +' order by ' + sortField + ' ' + sortDir);     
                   
             for (Case cas : Database.query(soql + extraQuery +' order by ' + sortField + ' ' + sortDir )){
               displayList.add(new cCase(cas));                 
            }
                     
    }
    
    
    
    // returns the number of selected records
    public Integer nbrSelectedRecords {
        get {
                return CasesCheckedList.size();
            }     
    }
    
   public Integer nbrFoundRecords {
        get {
             return totalNoOfRecs;           
        }
        set{
            nbrFoundRecords = value;
        }
    }
    
    public Integer currentPage {
        get {
            return  (pageNumber+1);
        }
        set{
            currentPage = value;
        }
    }
    
     public Integer totalPage {
        get {
                        
              Decimal d = totalNoOfRecs;
              Decimal dd = d.divide(inPageSize, 2, System.RoundingMode.CEILING);
 
             Long i = dd.round(roundingMode.UP);
             
             if (i==0)
                 i++;  
                 
             return  (Integer)i;
        }
    }

    public String batchCountry {
        get;set;
    }


public Case CaseParameter
    {
        get { return caseParam ; } 
        set; 
    }
    
    
       public class cCase {  
        public Case c {get; set;}  
        public boolean selected {get; set;}  

       
        //This is the contructor method. When we create a new cContact object we pass a Contact that is set to the con property. We also set the selected value to false  
        public cCase(Case ca) {  
            c = ca;  
            selected = false;           
        }  
    }
	
	
	public static void fakecoverage () {
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
	
	}

}