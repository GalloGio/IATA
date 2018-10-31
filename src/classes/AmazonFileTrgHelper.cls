public class AmazonFileTrgHelper {

    public static final ID RT_CERTIFICATE_ID = Schema.SObjectType.AmazonFile__c.getRecordTypeInfosByDeveloperName().get('Certificate').getRecordTypeId();
    private static final ID RT_SAAM_ID = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('ProcessEuropeSCE').getRecordTypeId();

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

    public static void AfterInsert(list<AmazonFile__c> listNews) {
        runProcessFromActionField(listNews);
    }
    
    public static void AfterUpdate(map<Id,AmazonFile__c> mapNews, map<Id,AmazonFile__c> mapOlds) {
        runProcessFromActionField(mapNews, mapOlds);
    }

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

    /**
        Check if there is a AmazonFile__c record with its Action__c field modified to trigger an action
        Only when insert
    **/
    public static void runProcessFromActionField(list<AmazonFile__c> listNews) {
        list<AmazonFile__c> listAmazonFileToUpdate = new list<AmazonFile__c>();
        for (AmazonFile__c newFile: listNews) {
            if (!String.isBlank(newFile.Action__c)) {
                listAmazonFileToUpdate.add(newFile);
            }
        }
        executeActions(listAmazonFileToUpdate);
    }

    /**
        Check if there is a AmazonFile__c record with its Action__c field modified to trigger an action
        Only when update
    **/
    public static void runProcessFromActionField(map<Id,AmazonFile__c> mapNews, map<Id,AmazonFile__c> mapOlds) {
        list<AmazonFile__c> listAmazonFileToUpdate = new list<AmazonFile__c>();
        for (AmazonFile__c newFile: mapNews.values()) {
            AmazonFile__c oldFile = mapOlds.get(newFile.Id);
            if (!String.isBlank(newFile.Action__c) && newFile.Action__c!=oldFile.Action__c) {
                listAmazonFileToUpdate.add(newFile);
            }
        }
        executeActions(listAmazonFileToUpdate);
    }
    
    /**
        Prepared the execution of the actions, separates actions in different calls
    **/
    public static void executeActions(list<AmazonFile__c> listAmazonFiles) {
        map<String,list<AmazonFile__c>> mapActions = new map<String,list<AmazonFile__c>>();
        for (AmazonFile__c newFile: listAmazonFiles) {
            list<AmazonFile__c> listFiles = mapActions.get(newFile.Action__c);
            if (listFiles==null) listFiles = new list<AmazonFile__c>();
            listFiles.add(newFile);
            mapActions.put(newFile.Action__c,listFiles);
        }
        executeActionCreateCase(mapActions.get('Create Case'));
        executeActionReminder30days(mapActions.get('Reminder 30 days'));
        executeActionReminderOnExpiry(mapActions.get('Reminder on Expiry'));
    }
    
    /**
        Create Case action
        Creates a case related to current AmazonFile__c.
        For the moment only available for Recordtype Certificate
        After the case creation the current Amazon File record will be linked to that new case
    **/
    public static void executeActionCreateCase(list<AmazonFile__c> listAmazonFiles){
        if(listAmazonFiles==null) return;
        list<Id> listAccountId = new list<Id>();
        // find Amazon File related objects
        for (AmazonFile__c newFile: listAmazonFiles) {
            if (newFile.RecordTypeId==RT_CERTIFICATE_ID && newFile.Account__c!=null) {
                listAccountId.add(newFile.Account__c);
            }
        }
        map<Id,Account> mapAccount = new map<Id,Account>(
            [SELECT Id, Name,
                (SELECT Id, Type__c, Expiry_Date__c
                FROM AmazonFiles__r
                WHERE RecordTypeId=:AmazonFileTrgHelper.RT_CERTIFICATE_ID
                ORDER BY Expiry_Date__c ASC)
            FROM Account
            WHERE Id IN :listAccountId]);

        // Create cases
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= true;
        map<Id,Case> mapCaseToCreate = new map<Id,Case>();
        for (AmazonFile__c newFile: listAmazonFiles) {
            if (newFile.RecordTypeId==RT_CERTIFICATE_ID && newFile.Account__c!=null && newFile.Case__c==null) {
                Account parentAccount = mapAccount.get(newFile.Account__c);
                AmazonFile__c anotherCertificate = findAnotherCertificate(parentAccount.AmazonFiles__r, newFile);
                if( anotherCertificate==null ) {
                    Case cse = new Case(
                    RecordTypeId = RT_SAAM_ID,
                    Subject = 'AP COMPLIANCE CHINA - ' + newFile.Type__c + ' - ' + parentAccount.Name,
                    CaseArea__c = 'Participation Compliance',
                    Reason1__c = 'Compliance',
                    AccountId = parentAccount.Id);
                    cse.setOptions(dmo);
                    mapCaseToCreate.put(newFile.Id,cse);
                } else {
                    newFile.addError('There is another active certificate(' + anotherCertificate.Id + '), cannot create a new case');
                }
            }
        }
        if (!mapCaseToCreate.isEmpty()) insert mapCaseToCreate.values();
        
        // Update Case Lookup Field in Amazon Files
        map<Id,Id> mapAmazonFileCaseId = new map<Id,Id>();
        for (Id amazonFileId: mapCaseToCreate.keyset()) {
            mapAmazonFileCaseId.put(amazonFileId, mapCaseToCreate.get(amazonFileId).Id);
        }
        updateCaseLookupInAmazonFiles(mapAmazonFileCaseId);
    }
    
    /**
        This requires 2 inputs, a list of AmazonFiles (this must be complete list 
        of amazonfile certificates in the same account) and the amazonfile certificate to test.
        This will return a certificate if there is another one under the same account 
        and same type and has a newer expiration date,
        and will return null if there is no other certificate
        
    **/
    private static AmazonFile__c findAnotherCertificate(list<AmazonFile__c> listRelatedAmazonFile, AmazonFile__c currentAmazonFile) {
        for(AmazonFile__c otherFile: listRelatedAmazonFile){
            if (otherFile.Id != currentAmazonFile.Id &&
                otherFile.Type__c == currentAmazonFile.Type__c &&
                otherFile.Expiry_Date__c > currentAmazonFile.Expiry_Date__c) {
                    return otherFile;
                }
        }
        return null;
    }
    /**
        Updates a list of AmazonFile__c to be linked to their case objects.
    **/
    @future
    private static void updateCaseLookupInAmazonFiles(map<Id,Id> mapAmazonFileCaseId) {
        list<AmazonFile__c> listAmazon = [SELECT Id, Case__c FROM AmazonFile__c WHERE Id IN :mapAmazonFileCaseId.keyset()];
        for (AmazonFile__c amazonFile: listAmazon) {
            amazonFile.Case__c = mapAmazonFileCaseId.get(amazonFile.Id);
        }
        update listAmazon;
    }
    
    /**
        Reminder 30 days before the Expiry date
        only for Certificates
    **/
    public static void executeActionReminder30Days(list<AmazonFile__c> listAmazonFiles){
        if(listAmazonFiles==null) return;
        list<Id> listCaseId = new list<Id>();
        for (AmazonFile__c newFile: listAmazonFiles) {
            if (newFile.RecordTypeId==RT_CERTIFICATE_ID) {
                listCaseId.add(newFile.Case__c);
            }
        }
        list<Case> listCase = 
            [SELECT Id, ContactId, OwnerId
            FROM Case 
            WHERE Id IN :listCaseId
            AND isClosed=false
            AND (NOT Owner.Name like '%recycle%')];
        System.debug('*** listCase ' + listCase);
        String templateName = 'AoP_permit_or_Commercial_Registry_reminder';
        sendCertificateReminder(templateName,listCase,'ContactId');
        //String templateName2 = 'AoP_permit_or_Commercial_Registry_reminder_internal';
        //sendCertificateReminder(templateName2,listCase,'OwnerId');
    }
    
    /**
        Reminder on the Expiry date
        only for Certificates
    **/
    private static void executeActionReminderOnExpiry(list<AmazonFile__c> listAmazonFiles){
        if(listAmazonFiles==null) return;
        list<Id> listCaseId = new list<Id>();
        for (AmazonFile__c newFile: listAmazonFiles) {
            if (newFile.RecordTypeId==RT_CERTIFICATE_ID) {
                listCaseId.add(newFile.Case__c);
            }
        }
        list<Case> listCase = 
            [SELECT Id, OwnerId, ContactId
            FROM Case
            WHERE Id IN :listCaseId
            AND isClosed=false
            AND (NOT Owner.Name like '%recycle%')];
        String templateName1 = 'AOC_permit_OR_Commercial_registry_expired';
        sendCertificateReminder(templateName1,listCase,'ContactId');
        String templateName2 = 'AOC_permit_OR_Commercial_registry_expired_internal';
        sendCertificateReminder(templateName2,listCase,'OwnerId');
    }

    /**
        Send an email to the input cases, and their related contacts using the input template
    **/
    private static void sendCertificateReminder(String templateName, list<Case> listCase, String targetField){
        try {
            if (listCase.isEmpty()) return;
            OrgWideEmailAddress orgAddress = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'noreply@iata.org'];
            EmailTemplate template = [SELECT Id FROM EmailTemplate WHERE DeveloperName = :templateName];

            List<Messaging.SingleEmailMessage> listEmail = new List<Messaging.SingleEmailMessage>();
            for(Case cse : listCase) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Id targetId = (Id)cse.get(targetField);
                if (targetId.getSObjectType() == User.sObjectType) {
                    // tsrget is a user
                    mail.setOrgWideEmailAddressId(orgAddress.Id);
                    mail.setTemplateId(template.Id);
                    mail.setTargetObjectId(targetId);
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setSaveAsActivity(false);
                    listEmail.add(mail);
                }
                if (targetId.getSObjectType() == Contact.sObjectType) {
                    //target is a contact
                    mail.setOrgWideEmailAddressId(orgAddress.Id);
                    mail.setTemplateId(template.Id);
                    mail.setTargetObjectId(targetId);
                    mail.setWhatId(cse.Id);
                    mail.setTreatTargetObjectAsRecipient(true);
                    mail.setSaveAsActivity(false);
                    listEmail.add(mail);
                }
                System.debug('*** email ' + mail);
            }

            if (!listEmail.isEmpty()) {
                for (Messaging.SendEmailResult emailResult: Messaging.sendEmail(listEmail,false)) {
                    if (emailResult.isSuccess()) {
                        System.debug('sendMassEmail(' + templateName + ',' + listCase + '): OK');
                    } else {
                        System.debug('sendMassEmail(' + templateName + ',' + listCase + ') ERROR: ' + emailResult.getErrors());
                    }
                }
            }

        } catch (Exception e) {
            System.debug('Error sending an email sendMassEmail(' + templateName + ',' + listCase + '): ' + e.getMessage());
        }
    }
}