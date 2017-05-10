public class SelectTrackedEmailAttachmentsController{

    public Boolean isPanelDisplayed{
        get{
            if(isPanelDisplayed == null){
               isPanelDisplayed = false; 
            }
            return isPanelDisplayed;
        }
        set;
    }

    // controller of parent page
    public sendSingleTrackedEmailController parent {get; set;}

    // User Id
    Id userId {get;set;}

    // will serve as a key for the folder 'My Computer'
    public String computerId = '100000000000000';
    
    // boolean used to indicate which part of the component should be shown and which one should be hidden
    public Boolean myComputerSelected {
        get{
            if(myComputerSelected == null){
                myComputerSelected = selectedFolder == computerId;
            }
            return myComputerSelected;
        }
        set;
    }

    
    /*-- AVAILABLE FOLDERS  --*/

    // folders drop-down list elements
    public List<SelectOption> availableFolders {get;set;}
    
    // Id of the folder selected in the drop-down list
    public String selectedFolder {get;set;}

    /*-- AVAILABLE FOLDERS  --*/


    /*-- AVAILABLE DOCUMENTS --*/

    public String documentFilter {get;set;}

    public Integer nbOfDocuments {get{if(nbOfDocuments == null){nbOfDocuments = 0;} return nbOfDocuments;} set;}

    public Map<Id, Document> documentsInSelectedFolderMap {
        get{
            if(documentsInSelectedFolderMap == null){updateDocumentList(); return documentsInSelectedFolderMap;}
            else{return documentsInSelectedFolderMap;}
        }
        set;
    }

    // Documents drop-down list
    public List<SelectOption> availableDocuments {
        get{
            List<SelectOption> documentList = new List<SelectOption>();
            Map<Id, Document> documentMap = documentsInSelectedFolderMap;
            for(Id documentId : documentMap.keySet()){
                documentList.add(new SelectOption(documentId, documentMap.get(documentId).Name));
            }
            return documentList;
        }
        set;
    }

    // List of documents selected in the Available Documents SelectOption list
    public List<String> availableDocumentsSelected {get;set;}

    /*-- AVAILABLE DOCUMENTS --*/


    /*-- ADDED DOCUMENTS--*/

    // Map of Added documents displayed in added documents SelectOption List
    public Map<String, DocumentSkeleton> addedDocumentMap{
        get{
            if(!isPanelDisplayed){
                return null;
            }
            if(addedDocumentMap == null){
                addedDocumentMap = new Map<String, DocumentSkeleton>();
                if(parent != null){
                    for(String key : parent.documentMap.keySet()){
                        DocumentSkeleton doc = parent.documentMap.get(key);
                        addedDocumentMap.put(key, new DocumentSkeleton(doc.Name, doc.BodyLength, doc.type));
                    }
                }
            }
            return addedDocumentMap;            
        }
        set;
    }
    
    // Added documents SelectOption list
    public List<SelectOption> addedDocuments {
        get{
            if(addedDocumentMap == null){
                return new List<SelectOption>();
            }
            List<SelectOption> options = new List<SelectOption>();
            for(String key : addedDocumentMap.keySet()){
                options.add(new SelectOption(key, addedDocumentMap.get(key).Name));
            }
            return options;
        }
        set;
    }

    // List of documents selected in the Added Documents SelectOption list
    public List<String> addedDocumentsSelected {get;set;}

    // document uploaded from the user's computer
    public Document uploadedDocument {get;set;}

    /*-- ADDED DOCUMENTS--*/


    // Constructor
    public SelectTrackedEmailAttachmentsController(){
        userId = UserInfo.getUserId();
        resetController();
    }

    // method called when the user selects another folder
    public PageReference updateDocumentList(){
        documentFilter = '';
        return applyFilter();
    }

    public PageReference applyFilter(){
            // Update the available documents Map
        if(documentFilter != '' && documentFilter != null){
            System.debug('filter = ' + documentFilter);

            String filter = '%' + documentFilter + '%';
        
            nbOfDocuments = Database.countQuery('SELECT count() FROM Document where FolderId = \'' + selectedFolder + '\' and name like \'' + filter + '\'');
            if(nbOfDocuments > 1000 /*Salesforce limit for collections*/){
                documentsInSelectedFolderMap = new Map<Id, Document>();
            }
            else{
                documentsInSelectedFolderMap = new Map<Id, Document>([select Id, Name, BodyLength, Type from Document where FolderId =: selectedFolder and name like :filter order by Name]);
            }
        }
        else{
            nbOfDocuments = Database.countQuery('SELECT count() FROM Document where FolderId = \'' + selectedFolder + '\'');
        
            if(nbOfDocuments > 1000 /*Salesforce limit for collections*/){
                documentsInSelectedFolderMap = new Map<Id, Document>();
            }
            else{
                documentsInSelectedFolderMap = new Map<Id, Document>([select Id, Name, BodyLength, Type from Document where FolderId =: selectedFolder order by Name]);
            }
        }
        
        availableDocumentsSelected.clear();
        // availableDocuments will be "refreshed" when called by the component
        availableDocuments = null;
        // myComputerSelected will be "refreshed" when called by the component
        myComputerSelected = null;
        
        return null;
    }

    // Method called when the user clicks the ">>" (add) button
    // Case where the user picked one or more documents in Salesforce 
    public void addSalesforceDocuments(){
        if(!myComputerSelected){
            for(String documentId : availableDocumentsSelected){
                addedDocumentMap.put(documentId, new DocumentSkeleton(documentsInSelectedFolderMap.get(documentId), 'salesforce document'));
            }
            availableDocumentsSelected.clear();
        }
    }

    // Method called when the user selects a document from his computer
    public void addPersonalDocument(){
        if(myComputerSelected){
            if(uploadedDocument != null){
                try{
                    uploadedDocument.FolderId = userId;
                    uploadedDocument.AuthorId = userId;
                    insert uploadedDocument;
                                
                    Document doc = [select Id, Name, BodyLength from Document where Id =: uploadedDocument.Id];
                    addedDocumentMap.put(uploadedDocument.Id, new DocumentSkeleton(doc, 'uploaded document'));
                    
                    uploadedDocument.Body = null;
                    uploadedDocument = new Document();
                }
                catch(Exception e){
                    System.debug('error:' + e);
                }
            }
        }
    }

    // Method called when the user clicks the "<<" (remove) button
    public void removeDocuments(){
        for(String documentId : addedDocumentsSelected){
            addedDocumentMap.remove(documentId);
        }
        addedDocumentsSelected.clear();
    }
    
    // Method called when the user clicks the "Cancel" button
    public void cancel(){
        closePanel();
    }
    
    // Method called when the user clicks the "Save" button
    public void save(){
        // Update the Document list of the parent
        parent.documentMap.clear();
        for(String key : addedDocumentMap.keySet()){
            DocumentSkeleton doc = addedDocumentMap.get(key);
            parent.DocumentMap.put(key, new DocumentSkeleton(doc.Name, doc.BodyLength, doc.type));
        }
        closePanel();
    }

    public void displayPanel(){
    	if(!isPanelDisplayed){
	        isPanelDisplayed = true;
	        resetController();
    	}
    }
    
    private void closePanel(){
        parent.showAttachmentsPanel = false;
        isPanelDisplayed = false;
    }

    // Method called at creation and every time the component is displayed
    public void resetController(){
        selectedFolder = userId;

        availableFolders = new List<SelectOption>();
        
        // First select option is upload from computer
        availableFolders.add(new SelectOption(computerId, 'My Computer'));

        // Second select option is user's personal documents
        availableFolders.add(new SelectOption(UserId, 'My Personal Documents'));
        
        // Then we add the other document folders
        for(Folder folder : [select Id, Name from Folder where type = 'Document' order by Name]){
            availableFolders.add(new SelectOption(folder.Id, folder.Name));
        }

        // The default selected folder is the 'My Documents' option
        selectedFolder = UserId;
        
        uploadedDocument = new Document();

        availableDocumentsSelected = new List<String>();
        addedDocumentsSelected = new List<String>();
         
        addedDocumentMap = null;
    }

    public class DocumentSkeleton{
        public String Name {get;set;}
        public Integer BodyLength {get;set;}
        public String type {get;set;}
        public String Size {
            get{
                if(Size == null){
                    if(BodyLength == null){
                        Size = '0 bytes';
                    }
                    else if (BodyLength < 1024){
                        Size = BodyLength + ' Bytes';
                    }
                    else if (BodyLength >= 1024 && BodyLength < (1024*1024)){
                        //KB
                        Decimal kb = Decimal.valueOf(BodyLength);
                        kb = kb.divide(1024,2);
                        Size = kb + ' KB';
                    }
                    else if (BodyLength >= (1024*1024) && BodyLength < (1024*1024*1024)){
                        //MB
                        Decimal mb = Decimal.valueOf(BodyLength);
                        mb = mb.divide((1024*1024),2);
                        Size = mb + ' MB';
                    }
                    else{
                        //GB
                        Decimal gb = Decimal.valueOf(BodyLength);
                        gb = gb.divide((1024*1024*1024),2);
                       
                        Size = gb + ' GB';
                    }
                }
                return Size;
            }
            set;
        }
        
        public DocumentSkeleton(Document doc, String type){
            Name = doc.Name;
            BodyLength = doc.BodyLength;
            this.type = type;
        }
        
        public DocumentSkeleton(String name, Integer bodyLength, String type){
            this.Name = name;
            this.BodyLength = bodyLength;
            this.type = type;
        }
    }
}