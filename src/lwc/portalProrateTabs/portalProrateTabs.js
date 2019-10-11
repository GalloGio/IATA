import { LightningElement, track } from 'lwc';

export default class PortalProrateTabs extends LightningElement {

    @track parentId;
    @track operation;
    

     connectedCallback() {

    //      this.parameters = this.getQueryParameters();
    //     console.log('FM this.parameters: ', this.parameters);
    // this.template.querySelector('lightning-tabset').activeTabValue = '<Request';


    }
    handleCreate(event){
        console.log('INIT handleCreate');
        console.log('event.detail: ',event.detail);
        
        let parentid = event.detail;
        
        console.log('parentid: ',parentid);
        console.log('parentid.parentid: ',parentid.parentid);
        console.log('parentid.operation: ',parentid.operation);
        
        // detail: {parentid:this.recid, operation:'create'}
        
        let x = this.template.querySelector('lightning-tabset').activeTabValue;

        this.parentid = parentid.parentid;
        this.operation = parentid.operation;
        console.log('this.parentid : ',this.parentid );
        console.log('this.operation: ',this.operation);
        x.parentid = this.parentid;
        x.operation = this.operation;
        

        this.template.querySelector('lightning-tabset').activeTabValue = 'Request';
        // console.log('handleCreate - x',x);
        

    } 
    
    handleSelect(event) {
        // const contactId = event.detail;
        // this.selectedContact = this.contacts.data.find(
        //     contact => contact.Id === contactId

            this.template.querySelector('lightning-tabset').activeTabValue = '<Request';
    // );
    }
    


    

    // handleSelectCreateNewProrateRequest() {
    //     const contactId = event.detail;
    //     this.selectedContact = this.contacts.data.find(
    //         contact => contact.Id === contactId
    //     );
    // }
}