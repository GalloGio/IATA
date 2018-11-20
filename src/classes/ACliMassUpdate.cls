public  class ACliMassUpdate {
    
    public boolean batchRunning {get;set;}
    public  boolean statusesUdpated {get;private set;} 
    public  integer page {get;private set;}
    public  integer numLines {get;private set;}
    public  integer numAccs{get;private set;}
    public  string displayThis {get;private set;}
    public transient  list<AcliAccount> AcliAccounts{get;set;}
    public  string AccountSite{get;Set;}
    private map<String,AcliAccount>  acliAcct {get;set;}
    public integer pageNumber{get;private set;} 
   
    private ID HDq {get;set;}
 
    public string tab {get;set;}
    public boolean stateOFF = false;
   
    public integer MINLEVEL{get;private set;} 
    public integer MAXLEVEL{get;private set;} 
    private integer OFFSET {get;set;}
    private list<AcliAccount> AcliAccountsPage;
    private string tabOldvalue {get;set;}
     
    public list<AcliAccount> getAcliAccountsPage(){
              AcliWrapper wrapperTmp;
            
           if(tabOldvalue <> tab){
               tabOldvalue =tab;
               First();
           }
           acliAcct = new map<String,AcliAccount>();
           Document acliTxtFile = [SELECT Body FROM document where developername = 'AcliUniqueFile' ];
           string acliTxtFileString  = acliTxtFile.Body.tostring() ; 
           AcliAccountsPage = new list<AcliAccount>();
        if(tab == '0' ){
                wrapperTmp = AcliParser.AcliParsingNotFound(acliTxtFileString  ,MINLEVEL,MAXLEVEL,stateOFF );
             acliAcct = wrapperTmp.AcliAccount;
         }else if(tab== '1'){
                wrapperTmp = AcliParser.AcliParsingFound(acliTxtFileString  ,MINLEVEL,MAXLEVEL,stateOFF );
                acliAcct  = wrapperTmp.AcliAccount;
         }
        // throw new transformationException(''+acliAcct);
         if(acliAcct.keyset() <> null)
          numAccs  = acliAcct.keyset().size();    
          else  
          numAccs  = 0;  
          MAXLEVEL = wrapperTmp.LastVisited;
          MINLEVEL =  wrapperTmp.LastVisited -OFFSET;
          numLines =  wrapperTmp.NumberOfLines;   
         return acliAcct.values();
    
    }
    private void setAcliAccountsPage(list<AcliAccount> value){
         AcliAccountsPage = value;
    }
    public PageReference doNull(){
        setStateOFF(!stateOFF);
      return null;
    }
    public boolean getStateOFF(){

        system.debug('state ='+stateOFF );
        return stateOFF ;
    
    }
    
    public void setStateOFF(boolean b){

        stateOFF = b ;
    
    }
    
    public ACliMassUpdate(){
 
         
         OFFSET = 20;
         numAccs =0;
         tabOldvalue ='0';  
         pageNumber = 0;
         tab  = '0';
         batchRunning = false;
         HDq = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
         MINLEVEL =0;
         MAXLEVEL = OFFSET ;
           system.debug('ACliMassUpdate  MAX ='+MAXLEVEL );
         statusesUdpated = false;
    }
     
    public void next(){

        pageNumber += 1;
        MINLEVEL +=OFFSET ;
        MAXLEVEL  +=OFFSET ;
    }
    public void First(){
         pageNumber = 0;
         MINLEVEL =0;
         MAXLEVEL = OFFSET ;
    } 
    public void previous(){
       if(MINLEVEL > 0){ 
        pageNumber -= 1;
        MINLEVEL -=OFFSET ;
        MAXLEVEL  -=OFFSET ;
        }
    }
    
    
    public void convertToACcount(){
     //  throw new transformationException('acliAcct   ' +acliAcct +'   adasdasdasdsa  AccountSite' +AccountSite);
      //  acliAcct.get(AccountSite);
        if(acliAcct.get(AccountSite.trim()) == null)
            throw new transformationException('Error no account found '+ AccountSite + '   ' + acliAcct);

         Account a = AcliAccount.createAcctFromAcliAccount(acliAcct.get(AccountSite.trim()));
         a.recordtypeId = HDq ;
         insert a;
         acliAcct.get(AccountSite.trim()).AcctID = a.id;

        /* acliAcct.remove(AccountSite);
         AcliAccountsPage = acliAcct.values();*/
         

      
    }
   
    public void UpdateAll(){
    
    
    list<AsyncApexJob> batchActive =[ SELECT id,ApexClass.name
                                       FROM AsyncApexJob 
                                       WHERE JobType='BatchApex' 
                                       AND (Status = 'Processing' OR Status = 'Preparing')
                                       AND (ApexClass.name  ='AcliUpdateBatch' OR  ApexClass.name  ='AcliStatusUpdateBatch')
                                       ];
                                   
       if(batchActive.size() == 0)  {
              AcliUpdateBatch btch = new AcliUpdateBatch();
             btch.stateOFF =stateOFF;
        btch.UserEmail = userInfo.getUserEmail();
                DataBase.executeBatch(btch,200);

    }  
          batchRunning = true;
            displayThis ='Job Running please wait...';
     

}

}