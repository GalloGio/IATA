public class PlatformEventsQueueable implements Queueable {

    private Map<Id,sObject> ObjectMap;
    private String PE_Name;
    private String ObjSource;
    private Boolean bIsInsert;
    private Boolean bIsUpdate;
    private Boolean bIsDelete;
    private Boolean bIsUndelete;

    public PlatformEventsQueueable(Map<Id,sObject> ObjectMap, String PE_Name, String ObjSource, Boolean bIsInsert, Boolean bIsUpdate, Boolean bIsDelete, Boolean bIsUndelete) {
        this.ObjectMap = ObjectMap;
        this.PE_Name = PE_Name;
        this.ObjSource = ObjSource;
        this.bIsInsert = bIsInsert;
        this.bIsUpdate = bIsUpdate;
        this.bIsDelete = bIsDelete;
        this.bIsUndelete = bIsUndelete;
    }

    public void execute(QueueableContext context) {
        
        PlatformEvents_Helper.publishEvents(ObjectMap, PE_Name, ObjSource, bIsInsert, bIsUpdate, bIsDelete, bIsUndelete);

        System.debug('____ [PlatformEventsQueueable - execute] Events published');
    }
}