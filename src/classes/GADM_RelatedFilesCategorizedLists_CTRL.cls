/**
 * Created by ppop on 8/7/2019.
 */

public with sharing class GADM_RelatedFilesCategorizedLists_CTRL {
   static final  Map<String, String> fileTypeStyleMap = new Map<String, String>
    {
            'BMP' => 'image',
            'CSV' => 'csv',
            'EXCEL' => 'excel',
            'EXCEL_X' => 'excel',
            'EXE' => 'exe',
            'GIF' => 'image',
            'JPG' => 'image',
            'LINK' => 'link',
            'MOV' => 'video',
            'MP4' => 'mp4',
            'PDF' => 'pdf',
            'PNG' => 'image',
            'POWER_POINT' => 'ppt',
            'POWER_POINT_X' => 'ppt',
            'RTF' => 'rtf',
            'TEXT' => 'txt',
            'UNKNOWN' => 'unknown',
            'VISIO' => 'visio',
            'WORD' => 'word',
            'WORD_X' => 'word',
            'XML' => 'xml',
            'ZIP' => 'zip'
    };

    @AuraEnabled
    public static List<FileWrapper> getFiles(List<Id> objectIds){
        Id gadmRecordTypeId = Schema.SObjectType.ContentVersion.getRecordTypeInfosByName().get('GADM').getRecordTypeId();
        List<FileWrapper> files = new List<FileWrapper>();
        List<ContentDocumentLink> documents = [SELECT ContentDocument.LatestPublishedVersion.Id,ContentDocument.FileType,
                                            ContentDocument.Title, ContentDocument.LatestPublishedVersion.RecordTypeId, ContentDocument.LatestPublishedVersion.Category__c FROM ContentDocumentLink
                                            WHERE LinkedEntityId = :objectIds AND ContentDocument.LatestPublishedVersion.Valid_From__c <= today AND ContentDocument.LatestPublishedVersion.Valid_To__c >= today
                                            AND ContentDocument.LatestPublishedVersion.RecordTypeId = :gadmRecordTypeId];

        for(ContentDocumentLink cd: documents){
            files.add(new FileWrapper(cd.ContentDocument.Title, cd.ContentDocument.LatestPublishedVersion.Id, cd.ContentDocument.LatestPublishedVersion.Category__c, cd.ContentDocument.FileType));
        }
        return files;
    }

    private static boolean hasPreview(string fileType){
        return fileType == 'image' || fileType == 'pdf';
    }

    public class FileWrapper{
        @AuraEnabled
        public string category {get; set;}
        @AuraEnabled
        public string fileName {get; set;}
        @AuraEnabled
        public string fileType{get;set;}
        @AuraEnabled
        public string versionId {get; set;}
        @AuraEnabled
        public string link {get; set;}
        @AuraEnabled
        public string preview {get; set;}

        public FileWrapper(string filename, Id versionId, string category, string filetype){
            this.fileName = filename;
            this.versionId = versionId;
            string icon = GADM_RelatedFilesCategorizedLists_CTRL.fileTypeStyleMap.get(fileType);
            this.fileType = 'doctype:' + (icon == null ? 'unknown': icon);
            this.category = string.isEmpty(category) ? 'General': category;
            this.link = Site.getBaseUrl() + '/sfc/servlet.shepherd/version/download/'+ versionId;
            this.preview = hasPreview(icon) ? Site.getBaseUrl() + '/sfc/servlet.shepherd/version/renditionDownload?rendition=ORIGINAL_'+fileType+'&versionId='+versionId : '';
        }
    }
}