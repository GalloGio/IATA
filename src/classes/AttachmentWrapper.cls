global class AttachmentWrapper implements Comparable {

    @AuraEnabled
    public String name {get;set;}
    @AuraEnabled
    public String id {get;set;}
    @AuraEnabled
    public Datetime createdDate {get;set;}

    public AttachmentWrapper(Attachment file) {
        this.id = file.Id;
        this.name = file.Name;
        this.createdDate = file.CreatedDate;
    }

    public Integer compareTo(Object compareTo) {
        AttachmentWrapper compareToWrapper = (AttachmentWrapper)compareTo;
        if ( this.createdDate <= compareToWrapper.createdDate ) return 1;
        return -1;
    }

}