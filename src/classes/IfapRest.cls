@RestResource(urlMapping='/IFAP/*')
global with sharing class IfapRest {
    /*
    IfapId:   ID case
    FileName : name of the amazon file name (!filename not the fullname)
    
    */

    private static final string FOLDER = 'IFAP/FinancialDocuments/';
    private static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials(IfapToolManager.IFAPCONFIGARATIONNAME);
    
    @HttpPost          
    webservice static boolean changeStatus(String caseNumber, String FileName, Double FileSize) {
        system.debug('caseNumber' +caseNumber+ ' FileName ' + FileName);

        List<AmazonFile> listfile = new List<AmazonFile>();
        AmazonFile__c amazonFile = new AmazonFile__c();
        
        
        try{
            if(caseNumber <> null){
                List<Case> cse =[select Id, Casenumber, IFAP_Agent_Code__c FROM case where CaseNumber = : caseNumber and STATUS != 'Submitted' ];
                if(cse <> null && cse.size()>0){
    
                    CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
                    cse[0].status = 'Submitted';
                    cse[0].IsComplaint__c = false;
                    update cse;

                    List<AmazonFile__c> listOfFiles = [Select ID, Name, Full_Name_Unique__c from AmazonFile__c WHERE Case__c=: cse[0].Id];
                    List<Id> idsFileToDelete = new list<Id>();
                    

                    for(AmazonFile__c amFile: listOfFiles){
                        if(amFile.name <> fileName)
                            idsFileToDelete.add(amFile.id);
                   }


                   deleteRemainingFiles(idsFileToDelete);
                   String amazonKey = FOLDER + cse[0].caseNumber +'/' + FileName ;
     
                  try{
                      amazonFile = new AmazonFile__c(
                        Name = filename,
                        Full_Name_Unique__c = amazonKey,
                        Size_MB__c = FileSize, //convert to MB
                        Case__c = cse[0].Id
                    );
                    insert amazonFile;

                    } catch ( Exception e) {
                     System.debug('Error creating an AmazonFile__c object: ' + e.getMessage());
                    return false;
                    }
                }
            }

            return true;   
                                                
            }catch(Exception ex){
                TransformationHelper.sendEmailSupport('FATAL: IFAP changeStatus ' +caseNumber ,'STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
                return false;                                                       
            }
        }

        @future(callout=true)
        private static void deleteRemainingFiles(list<Id> iDAmazonFiles){
            List<AmazonFile__c> amazonFiles = new List<AmazonFile__c>();
            
            try{
                amazonFiles = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE ID IN: iDAmazonFiles];
                system.debug('amazonFiles ' + amazonFiles);
                
                if(!amazonFiles.isEmpty()){
                    for(AmazonFile__c amFiles : amazonFiles){
                        AmazonRest.deleteFile(amFiles.Full_Name_Unique__c, CREDENTIALS);
                    }
                }

                //delete from sfdc
                List<AmazonFile__c> amfiles = [SELECT Id, Full_Name_Unique__c FROM AmazonFile__c WHERE ID IN: iDAmazonFiles AND Full_Name_Unique__c like'%.pdf%'];
                database.delete(amfiles);           

            }catch(Exception ex){
                TransformationHelper.sendEmailSupport('FATAL: IFAP deleteRemainingFiles iDAmazonFiles ' + iDAmazonFiles + ' amazonFiles List ' + amazonFiles , 'STACKTRACE   ' + ex.getStackTraceString()  + '  '  + ex.getMessage());
            }    
        }
}