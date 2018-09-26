public class AmazonFileTrgHelper {

    public static String sapNumberRequiredJSON{
        get{
            return JSON.serialize(new List<String>(AmazonFileTrgHelper.sapNumberRequired));
        }
    }

    public static String expiryDateRequiredJSON{
        get{
            return JSON.serialize(new List<String>(AmazonFileTrgHelper.expiryDateRequired));
        }
    }

    public static String expiredRequiredJSON{
        get{
            return JSON.serialize(new List<String>(AmazonFileTrgHelper.expiredRequired));
        }
    }

    public static Set<String> sapNumberRequired = new Set<String>{
        'Contractual.Contract/Amendment','Contractual.Termination','Contractual.Implementation Summary'
    };

    public static Set<String> expiryDateRequired = new Set<String>{
        'Contractual.Signatory Authentication','Operational Calendars.BSP','Operational Calendars.ICH','Operational Calendars.Client'
    };

    public static Set<String> expiredRequired = new Set<String>{
        ''
    };

    /*

        copy the files back into the appropriate folder
        Delete the old files levereging AmazonRest class


    -----this are few lines to test it from your execute anynuomous the id is hte id of the amazonfile__c
    list<Id> filesIDS = new list<Id>{'a558E0000005gYF'};

    list<AmazonFile__C>  ama = (list<AmazonFile__C>) Database.query('SELECT '
                                                            + TransformationHelper.selectAllFields('AmazonFile__C')
                                                            + ' FROM AmazonFile__C  WHERE ID IN: filesIDS ALL ROWS ');
    system.debug('' +ama);

    AmazonFileTrgHelper.AfterUndelete(new map<Id,AmazonFile__C>{'a558E0000005gZc' => ama[0]});

    */

    private static final AmazonCredentials CREDENTIALS = AmazonCredentials.getCredentials('GenericAttach');
    private static final AmazonCredentials RECYCLEBIN = AmazonCredentials.getCredentials('RecycleBin');

    public static void AfterUndelete(map<Id,AmazonFile__C> trgNewMap){

        try{

            integer maxEntry = trgNewMap.keySet().size();
            integer max = 100/2; //the max number of callouts in an @future Its on 2 cuase we have a copy and a delete!
            integer numberOfLoops = (trgNewMap.KeySet().Size()+1)/50;

            if(numberOfLoops >50) throw new transformationException('Apex limits exceeded not possible to perform the operation');
            //max number of @future calls allowed in a transaction


            map<Integer,List<Id>> listIdToProcessPerInt  = new map<Integer,List<Id>>();
            map<Integer,Id> IdPerInt = new map<Integer,Id>();

            integer k = 0;
            for(Id idFile: trgNewMap.KeySet()){
                IdPerInt.put(k, idFile);
                k++;
            }

            system.debug(' @@@  IdPerInt ' + IdPerInt);
            for(integer y = numberOfLoops;y>-1; y--){//Moonwalker

                integer localMax;

                if((max - maxEntry) > 0) localMax = maxEntry;
                else {localMax = max; maxEntry -=50;}

                for(Integer i = 0; i < localMax  ;i++){

                    if(listIdToProcessPerInt.get(y) == null)
                        listIdToProcessPerInt.put(y, new list<Id>());
                    listIdToProcessPerInt.get(y).add(IdPerInt.get(i));
                }
            }

            system.debug(' @@@ 1  listIdToProcessPerInt ' + listIdToProcessPerInt);
            //for(integer num:listIdToProcessPerInt.keySet()){
            for(integer num = numberOfLoops;num >-1; num--){
                if(Limits.getLimitFutureCalls()<>0){

                    system.debug(' @@@ 2  listIdToProcessPerInt ' + listIdToProcessPerInt.get(num));
                    system.debug(' @@@ 3 Limits.getLimitFutureCalls() ' + Limits.getLimitFutureCalls());
                    AfterUndelete(listIdToProcessPerInt.get(num));
                }

                else throw new transformationException('Apex limits exceeded not possible to perform the operation \n trgNewMap ' + trgNewMap+ '\n listIdToProcessPerInt  '  + listIdToProcessPerInt  +  '\n num '+num   );
            }


        }catch(Exception e){ TransformationHelper.sendEmailSupport('AmazonFileTrgHelper  AfterUndelete  ' , '\n MESSAGE: '  + e.getMessage() +'\n STACKTRACE   ' + e.getStackTraceString()  ); }


    }

    /*
        we need to use an @future cause of the callout operation
        we need to copy back the file and then delete it
    */

    @Future(callout=true)
    public static void AfterUndelete(List<Id> filesIDS){
//  throw new transformationException('#######   filesIDS' +filesIDS);
        try{

            if(Limits.getLimitCallouts()==0) throw new transformationException('At Future Limits reached ');


            map<Id,GenericAttach> genericAttachPerId = new map<Id,GenericAttach>();
            map<Id,AmazonFile__C> amazonFilesPerId = new map<Id,AmazonFile__C>();
            for(AmazonFile__C amF : (list<AmazonFile__C>) Database.query('SELECT '
                                                            + TransformationHelper.selectAllFields('AmazonFile__C')
                                                            + ' FROM AmazonFile__C  WHERE ID IN: filesIDS  ALL ROWS ')){

                    amazonFilesPerId.put(amF.id,amF);
                    genericAttachPerId.put(amF.id,new GenericAttach(amF));

            }


            // first we copy back
            for(Id amazonFId :amazonFilesPerId.keySet()){

                    AmazonRest.copyFile(RECYCLEBIN,genericAttachPerId.get(amazonFId).pathComplete,
                                        CREDENTIALS,genericAttachPerId.get(amazonFId).pathComplete);

            }
            // then we delete
            for(Id amazonFId :amazonFilesPerId.keySet()){

                    AmazonRest.deleteFile(genericAttachPerId.get(amazonFId).pathComplete,RECYCLEBIN);

            }


        }catch(Exception e){
            if(test.isrunningTest())   throw new transformationException( e.getMessage() +'\n STACKTRACE   ' + e.getStackTraceString() + '  \n filesIDS' + filesIDS); 

            TransformationHelper.sendEmailSupport('AmazonFileTrgHelper  AfterUndelete @FUTURE ' , '\n MESSAGE: ' + e.getMessage() +'\n STACKTRACE   ' + e.getStackTraceString() + '  \n filesIDS' + filesIDS  );

        }

    }



    public class genericAttach{


            public string pathComplete {get;set;}
            //public string name {get;set;}


        public genericAttach(AmazonFile__c amazonFile){

                string lookup =  getTheLookUp(amazonFile);
                this.pathComplete = lookup <> null ? lookup.substring(0,3)+'/'+ lookup + '/'+  amazonFile.Name : '';


        }

        // this is to keep it generic as the users might want to add new lookups to this component and there will be no need to change the code
        // and the same time it will be possible to undelete attach belonging to different parents
        public string getTheLookUp(AmazonFile__c amazonFile){

            for(String fieldName: TransformationHelper.getAllFieldsPerDisplayType('AmazonFile__c').get('Reference')){

                    if(amazonFile.get(fieldName) != null && fieldName.endsWith('__c'))  {

                        system.debug('##############   fieldName ' +fieldName);
                        return String.valueOf(amazonFile.get(fieldName));

                    }

            }
            return null;
        }

    }

    public static void checkEFRequiredFields(map<Id,AmazonFile__C> trgNewMap){

        if (trgNewMap != null && trgNewMap.isEmpty() == false) {

            List<AmazonFile__c> efFiles = new List<AmazonFile__c>();

            for (AmazonFile__c af : trgNewMap.values()) {

                if (af.RecordTypeId == AMS_Utils.getId('AmazonFile__c', 'EF_File')) {

                    efFiles.add(af);
                }
            }

            if (efFiles.isEmpty() == false) {

                String errorMessage = 'This field is required for this '+Schema.SobjectType.AmazonFile__c.fields.Category__c.label+'/'+Schema.SobjectType.AmazonFile__c.fields.SubCategory__c.label+': ';
                String key;

                for (AmazonFile__c eff : efFiles) {

                    if (eff.Category__c != null && eff.SubCategory__c != null) {

                        key = eff.Category__c+'.'+eff.SubCategory__c;

                        if (sapNumberRequired.contains(key) && eff.SAP_Number__c == null) {

                            eff.SAP_Number__c.addError(errorMessage+eff.Category__c+'/'+eff.SubCategory__c);
                        }

                        if (expiryDateRequired.contains(key) && eff.Expiry_Date__c == null) {

                            eff.Expiry_Date__c.addError(errorMessage+eff.Category__c+'/'+eff.SubCategory__c);
                        }

                        if (expiredRequired.contains(key) && eff.Expired__c == false) {

                            eff.Expired__c.addError(errorMessage+eff.Category__c+'/'+eff.SubCategory__c);
                        }
                    }
                }
            }
        }
    }

    //AMSU-28;AMSU-113
    public static void setFileIdentifier(List<AmazonFile__c> attachments){
        if (attachments != null && attachments.isEmpty() == false) {
            System.debug('Attachment_Svc - setFileIdentifier');
            System.debug('Attachment_Svc - attachments - ' + attachments);
            List<Case> auxCases = new List<Case>();
            List<AMS_OSCAR__c> updOscar = new List<AMS_OSCAR__c>();
            Set<Id> caseIds = new Set<Id>();
            Set<Id> oscarIds = new Set<Id>();
            Map<ID, AmazonFile__c> mAuxAttach = new Map<ID, AmazonFile__c>();

            System.debug('attachments: ' + attachments);

            for(AmazonFile__c attach : attachments)
            {
                if(attach.Case__c != null)
                {
                    caseIds.add(attach.Case__c);
                    mAuxAttach.put(attach.Case__c, attach);
                }
            }

            if(caseIds != null && caseIds.size() > 0){
                auxCases = [Select id, OSCAR__c, OSCAR__r.Process__c from Case where id in :caseIds and OSCAR__c <> null];
            }

            for(Case auxCase : auxCases)
            {
                AmazonFile__c auxAttach = mAuxAttach.get(auxCase.Id);
                if(auxAttach != null){
                    if(auxCase.OSCAR__r.Process__c == AMS_Utils.CERTIFICATION){
                        auxAttach.File_Identifier_picklist__c = 'DGR_CERT';
                        auxAttach.File_Identifier__c = 'DGR_CERT';
                        
                    }else if(auxCase.OSCAR__r.Process__c == AMS_Utils.PCI_COMPLIANT){
                        auxAttach.File_Identifier_picklist__c = 'PCI_COMPLIANCE';
                        auxAttach.File_Identifier__c = 'PCI_COMPLIANCE';
                    }
                }
            }

            

            
        }
    }

        //FM 06-11-2017 - AMSU28 - add "submitted" state to OSCAR record when agents attach something to the case
    //AMSU-113 - add validation to PCI compliance attach as well
    public static void validateAttachmentIsCase_DGR_Certification(List<AmazonFile__c> attachments)
    {
        System.debug('Attachment_Svc - validateAttachmentIsCase_DGR_Certification');
        List<Case> auxCases = new List<Case>();
        List<AMS_OSCAR__c> updOscar = new List<AMS_OSCAR__c>();
        Set<Id> caseIds = new Set<Id>();
        Set<Id> oscarIds = new Set<Id>();

        System.debug('attachments: ' + attachments);

        for(AmazonFile__c attach : attachments)
        {
            if(attach.Case__c != null)
            {
                caseIds.add(attach.Case__c);
            }
        }

        if(caseIds != null && caseIds.size() > 0){
            auxCases = [Select OSCAR__c from Case where id in :caseIds and OSCAR__c <> null];
        }

        for(Case auxCase : auxCases)
        {
            if(auxCase.OSCAR__c.getSobjectType() == AMS_OSCAR__c.SobjectType)
            {
                oscarIds.add(auxCase.OSCAR__c);
            }
        }
        System.debug('oscarIds: ' + oscarIds);
        List<AMS_OSCAR__c> lOSCAR = [Select Id, Status__c from AMS_OSCAR__c 
                                            where id in :oscarIds 
                                            AND Process__c in (:AMS_Utils.CERTIFICATION , :AMS_Utils.PCI_COMPLIANT)
                                            AND Status__c in ('Accepted_Future Date','Renewal not completed','Open')];

        System.debug('lOSCAR: ' + lOSCAR);

        List<AmazonFile__c> lAuxAttach = [SELECT case__r.OSCAR__c, case__r.OSCAR__r.Process__c ,Name,File_Identifier_picklist__c FROM AmazonFile__c WHERE Case__r.OSCAR__c in :oscarIds];
        Map<ID, Integer> mAuxAttach = new Map<ID, Integer>();

        //Populate Map with the number of attachments that exist in the OSCARs      
        for(AmazonFile__c attch : lAuxAttach){
            if(attch.Case__r.OSCAR__r.Process__c == AMS_Utils.PCI_COMPLIANT && attch.File_Identifier_picklist__c != 'PCI_COMPLIANCE'){
                continue;
            }

            if(!mAuxAttach.containsKey(attch.Case__r.OSCAR__c)){
                mAuxAttach.put(attch.Case__r.OSCAR__c, 1);
            }else{
                Integer i = mAuxAttach.get(attch.Case__r.OSCAR__c) + 1;
                mAuxAttach.put(attch.Case__r.OSCAR__c, i);
            }
        }       

        System.debug('mAuxAttach: ' + mAuxAttach);

        for(AMS_OSCAR__c auxOscar : lOSCAR){
            if(auxOscar != null){

                //Check for other attachments
                Integer attachSize = 0;
                if(mAuxAttach.containsKey(auxOscar.Id)){
                    attachSize = mAuxAttach.get(auxOscar.Id);
                }
                
                System.debug('attachSize: ' + attachSize);
                //only set the status on the 1st attachment loaded
                if(attachSize == 1){
                    
                    auxOscar.Status__c = 'Submitted';
                    
                    updOscar.add(auxOscar);
                }
            }
        }

        System.debug('updOscar: ' + updOscar);
        //if anny update the status of the cases
        update updOscar;
    }

	/*** AMSU-139 ***/
    public static void checkApprover(List<AmazonFile__c> records, Map<Id,AmazonFile__c> oldMap) {
        String usrName = UserInfo.getName();
        Set<String> statusToCheck = new Set<String> {AMS_Utils.REJECTED, AMS_Utils.REJECTED_CLOSED, AMS_Utils.ACCEPTED};
        for(AmazonFile__c record : records) {
            AmazonFile__c oldRecord = oldMap.get(record.Id);
            if(statusToCheck.contains(record.Review_Status__c) && record.Review_Status__c <> oldRecord.Review_Status__c) {
                record.AMS_Updated_Date__c = Datetime.now();
                record.AMS_Updated_By__c = usrName;
            }
        }
    }

}