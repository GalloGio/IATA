import { LightningElement, track, api} from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getBaggageClaim from '@salesforce/apex/ISSP_Baggage_Proration.getBaggageClaim';
import getPickListValuesIntoList from '@salesforce/apex/ISSP_Baggage_Proration.getPickListValuesIntoList';
import getExpiringLink from '@salesforce/apex/ISSP_Baggage_Proration.getExpiringLink';
import UpdateClaim from '@salesforce/apex/ISSP_Baggage_Proration.UpdateClaim';
import fetchAirlineAccountDetailsAura from '@salesforce/apex/ISSP_Baggage_Proration.fetchAirlineAccountDetailsAura';
import getPickListValuesBaggageInformationPIRColor from '@salesforce/apex/ISSP_Baggage_Proration.getPickListValuesBaggageInformationPIRColor';
import getPickListValuesBaggageInformationType from '@salesforce/apex/ISSP_Baggage_Proration.getPickListValuesBaggageInformationType';




export default class PortalProrateRequestsForm extends LightningElement {

    @api recid; // rec  id
    @api isactionedit; // check if is to edit
    @api isactioneditPirForm; // check if is to edit
    @api parentid = ''; // parentId - PIR Form ID
    @api apiflightinformationlist;
    @api apibaginformationlist;
    
    /**
     * Logical variables
     */
    
    @track goToNewComment = false; // control to go to New Comment
    @track goToNewAttachment = false; // control to go to New Attachment
    @track goBack = false; // control to return to list
    @track dataRecords = false;
    @track loading = true; //Handles the loading of the page
    @track error = false; //Handles the error
    @track showAttachments = false; //Handles the Attachments
    @track baggageClaim; // Baggage Claim 
    @track baggageClaimAllData;
    @track flightInformationList;  //Flight_Information__c list
    @track claimCommentsLis;  // Claim CommentsLis list
    @track bagInformationList  ;  //PIR_Bag_Information__c  list
    @track columnsFlightInformationList; //Columns to show in the data table  Flight InformationL ist
    @track columnsBagInformationList; //Columns to show in the data table Bag Information List
    @track columnsAttachments; //Columns to show in the data table Attachments
    @track columnsComents;//Columns to show in the data table Coments
    @track IdPIRForm; //Id to handle the form data
    @track proceedToPaymentDate;
    @track airlineCode;
    @track errorX2letterAirlineCode = false;
    @track AmazonFiles;
    @track showModalOpenParentProrateRequest;
    @track isNew; //informs that is a new Prorate Request
    
    
    /**
     * Combobox variables
     */
    @track portalStatus = ''; //Selected value of the combobox
    @track portalStatusOptionsmap;
    @track portalStatusOptions; //List of options for the combobox
    @track portalStatusBaggageInformationPIRColor = ''; //Selected value of the combobox
    @track portalStatusOptionsBaggageInformationPIRColor; //List of options for the combobox
    @track portalStatusBaggageInformationType = ''; //Selected value of the combobox
    @track portalStatusOptionsBaggageInformationType; //List of options for the combobox

    //Modals
    @track showForm = true;
    @track showModalCorrectProcInvoic = false;
    @track showModalResolution780 = false;
    @track showModalResolution754 = false;
    @track showModalComment = false;
    @track commmentToModal;
    @track showModalEditFlightInformation = false;
    @track dataToEditFlightInformation;
    @track showModalEditBagInformation = false;
    @track dataToEditBagInformation;

    //  Error Messags
    @track msg;
    @track variant;
    @track mode;

    get showMeNow() {
        var aux = false
        if(this.dataRecords && !this.goBack && !this.goToNewAttachment && !this.goToNewComment){
            aux = true;
        }
        return aux;
      }
    
    /**
     * Executed on component opening
     */
    connectedCallback() {
        this.msg = '';
        this.variant = '';
        this.mode = '';

        console.log('[PortalProrateRequestsForm] connectedCallback this.parentid: ', this.parentid);
        console.log('[PortalProrateRequestsForm] connectedCallback this.parentid != undefined: ', this.parentid != 'undefined');
        console.log('[PortalProrateRequestsForm] connectedCallback this.parentid !== undefined: ', this.parentid !== 'undefined');
        console.log('[PortalProrateRequestsForm] connectedCallback this.parentid !== null: ', this.parentid !== null);
        console.log('[PortalProrateRequestsForm] connectedCallback this.parentid !==: ', this.parentid !== '');

        if(this.parentid != 'undefined' && this.parentid !== null && this.parentid !== ''){
            this.parentid = JSON.parse(JSON.stringify(this.parentid));
        }
        console.log('[PortalProrateRequestsForm] connectedCallback INIT');
        console.log('[PortalProrateRequestsForm] connectedCallback this.recid: ', this.recid);
        console.log('[PortalProrateRequestsForm] connectedCallback this.parentid: ', this.parentid);

        this.showAttachments = false;
        this.loading = true;
        // this.IdPIRForm = this.recid;
        this.buildcolumnsComents();
        this.buildAttacments();
        this.buildflightInformationList();
        this.buildbagInformationList();
        // this.fetchBaggageClaim(this.recid);
        if(this.recid != 'undefined' && this.recid != null && this.recid !== ''){
            console.log('[PortalProrateRequestsForm] connectedCallback : this.recid !== null');
            this.IdPIRForm = this.recid;
            this.fetchBaggageClaim(this.recid);
        }
        if(this.parentid != 'undefined' && this.parentid !== null && this.parentid !== ''){
            console.log('[PortalProrateRequestsForm] connectedCallback : this.parentid !== null');
            // this.bagInformationList = JSON.parse(JSON.stringify(results.PIRBagInformation)); 
            this.bagInformationList = JSON.parse(JSON.stringify(this.apibaginformationlist));
            // this.flightInformationList = JSON.parse(JSON.stringify(results.PIRFlightInformation)); 
            this.flightInformationList = JSON.parse(JSON.stringify(this.apiflightinformationlist)); 

            console.log('[PortalProrateRequestsForm] connectedCallback : this.flightInformationList : ',this.flightInformationList);
            console.log('[PortalProrateRequestsForm] connectedCallback : this.bagInformationList : ',this.bagInformationList);

            for(let i = 0; i < this.flightInformationList.length; i++){
                if(this.flightInformationList[i].PIR_Miles__c){
                    this.flightInformationList[i].PIR_Miles__c = this.flightInformationList[i].PIR_Miles__c+'';
                }
                if(this.flightInformationList[i].PIR_Percentage__c){
                    this.flightInformationList[i].PIR_Percentage__c = this.flightInformationList[i].PIR_Percentage__c+'';
                }
                if(this.flightInformationList[i].PIR_Amount_Due__c){
                    this.flightInformationList[i].PIR_Amount_Due__c = this.flightInformationList[i].PIR_Amount_Due__c+'';
                }
                // if(i === 0 && this.flightInformationList[i].PIR_Segment_1__c === '1'){
                //     this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_1_Selected__c ? this.baggageClaim.Is_Segment_1_Selected__c : false;
                // }
                // if(i === 1 && this.flightInformationList[i].PIR_Segment_1__c === '2'){
                //     this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_2_Selected__c ? this.baggageClaim.Is_Segment_2_Selected__c : false;
                // }
                // if(i === 2 && this.flightInformationList[i].PIR_Segment_1__c === '3'){
                //     this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_3_Selected__c ? this.baggageClaim.Is_Segment_3_Selected__c : false;
                // }
                // if(i === 3 && this.flightInformationList[i].PIR_Segment_1__c === '4'){
                //     this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_4_Selected__c ? this.baggageClaim.Is_Segment_4_Selected__c : false;
                // }
            }

            // for(let i = 0; i < this.bagInformationList.length; i++){
            //     if(i === 0 && this.bagInformationList[i].Bag_Number__c === '1'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_1_Selected__c ? this.baggageClaim.Is_Bag_1_Selected__c : false;
            //     }
            //     if(i === 1 && this.bagInformationList[i].Bag_Number__c === '2'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_2_Selected__c ? this.baggageClaim.Is_Bag_2_Selected__c : false;
            //     }
            //     if(i === 2 && this.bagInformationList[i].Bag_Number__c === '3'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_3_Selected__c ? this.baggageClaim.Is_Bag_3_Selected__c : false;
            //     }
            //     if(i === 3 && this.bagInformationList[i].Bag_Number__c === '4'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_4_Selected__c ? this.baggageClaim.Is_Bag_4_Selected__c : false;
            //     }
            //     if(i === 4 && this.bagInformationList[i].Bag_Number__c === '5'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_5_Selected__c ? this.baggageClaim.Is_Bag_5_Selected__c : false;
            //     }
            //     if(i === 5 && this.bagInformationList[i].Bag_Number__c === '6'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_6_Selected__c ? this.baggageClaim.Is_Bag_6_Selected__c : false;
            //     }
            //     if(i === 6 && this.bagInformationList[i].Bag_Number__c === '7'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_7_Selected__c ? this.baggageClaim.Is_Bag_7_Selected__c : false;
            //     }
            //     if(i === 7 && this.bagInformationList[i].Bag_Number__c === '8'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_8_Selected__c ? this.baggageClaim.Is_Bag_8_Selected__c : false;
            //     }
            //     if(i === 8 && this.bagInformationList[i].Bag_Number__c === '9'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_9_Selected__c ? this.baggageClaim.Is_Bag_9_Selected__c : false;
            //     }
            //     if(i === 9 && this.bagInformationList[i].Bag_Number__c === '10'){
            //         this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_10_Selected__c ? this.baggageClaim.Is_Bag_10_Selected__c : false;
            //     }
            // }
            this.dataRecords = true;
            this.goBack = false; 
            this.goToNewAttachment = false; 
            this.goToNewComment = false;



            this.baggageClaim = {};
            // this.baggageClaim.PIR_Form__c = this.parentid;
            this.baggageClaim.Parent_PIR_Form__c = this.parentid.Id;
            this.baggageClaim.Airline_Issuing_Id__c = this.parentid.Airline_issuing__c;
            this.baggageClaim.Airline_issuing__c = this.parentid.Airline_issuing__r.Name;
            this.baggageClaim.Email_Prorate_Dept_Airline_issuing__c = this.parentid.Email_Prorate_Dept_Airline_issuing__c;
            this.baggageClaim.Name = '';
            this.baggageClaim.CreatedBy = {};
            this.baggageClaim.CreatedBy.Name = '';
            this.baggageClaim.LastModifiedBy = {};
            this.baggageClaim.LastModifiedBy.Name = '';
            this.baggageClaim.Parent_PIR_Form__r = {};
            this.baggageClaim.Parent_PIR_Form__r.PIR_Currency_Claim__c = '';
            this.baggageClaim.Parent_PIR_Form__r.PIR_Passenger_Claim_Amount__c = '';
            this.baggageClaim.Parent_PIR_Form__r.PIR_Currency_of_conversion__c = '';
            this.baggageClaim.Parent_PIR_Form__r.Amount__c = '';
            this.loading = false;
            this.isNew = true;
            this.fetchPickListValuesIntoList();
            this.fetchPickListValuesBaggageInformationPIRColor();
            this.fetchPickListValuesBaggageInformationType();
            
            this.baggageClaim.Status__c = 'Open';
            

            
        }
    }


    /**
     * Builds the columns for the data table Attachments
     */
    buildcolumnsComents() {
        this.columnsComents = [{
                                label: '',
                                type: 'button-icon',
                                initialWidth: 10,
                                typeAttributes: {
                                    iconName: 'action:preview',
                                    title: 'View',
                                    name: 'view',
                                    variant: 'border-filled',
                                    alternativeText: 'View'
                                }
                            },
                            { label: 'Comment N°', fieldName: 'Name', type: 'text'},
                            { label: 'Text', fieldName: 'Comments__c', type: 'text'},
                            { label: 'Account', fieldName: 'Account__c', type: 'text'},
                            { label: 'Created By', fieldName: 'CreatedDate', type: 'date' }
                        ];
    }

    /**
     * Builds the columns for the data table Attachments
     */
    buildAttacments() {
        this.columnsAttachments = [{
                                label: 'Action',
                                type: 'button-icon',
                                initialWidth: 10,
                                typeAttributes: {
                                    iconName: 'action:preview',
                                    title: 'View',
                                    name: 'view',
                                    variant: 'border-filled',
                                    alternativeText: 'View'
                                }
                            },
                            { label: 'AmazonFile Name', fieldName: 'Name', type: 'text'},
                            { label: 'Size MB', fieldName: 'Size_MB__c', type: 'text' },
                            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
                        ];
    }
    /**
     * Builds the columns for the data table bag Information List
     */
    buildbagInformationList() {
        if(this.isactionedit){
            this.columnsBagInformationList = [{
                                                label: '',
                                                type: 'button-icon',
                                                initialWidth: 10,
                                                typeAttributes: {
                                                    iconName: 'action:edit',
                                                    title: 'Edit',
                                                    name: 'edit',
                                                    variant: 'border-filled',
                                                    alternativeText: 'Edit'
                                                }
                                            },
                                            { label: 'Prorated', fieldName: 'Is_Bag_1_Selected__c', type: 'boolean'},
                                            { label: 'Bag N°', fieldName: 'Bag_Number__c', type: 'text'},
                                            { label: 'Bag Tag N°', fieldName: 'Bag_Tag_Number__c', type: 'text'},
                                            { label: 'Color', fieldName: 'PIR_Color__c', type: 'text' },
                                            { label: 'Type', fieldName: 'Type__c', type: 'text'}
                                        ];
        }else{
            this.columnsBagInformationList = [
                                { label: 'Prorated', fieldName: 'Is_Bag_1_Selected__c', type: 'boolean'},
                                { label: 'Bag N°', fieldName: 'Bag_Number__c', type: 'text'},
                                { label: 'Bag Tag N°', fieldName: 'Bag_Tag_Number__c', type: 'text'},
                                { label: 'Color', fieldName: 'PIR_Color__c', type: 'text' },
                                { label: 'Type', fieldName: 'Type__c', type: 'text' }
                            ];
        }
    }
    /**
     * Builds the columns for the data table flight Information List
     */
    buildflightInformationList() {
        if(this.isactionedit){
            this.columnsFlightInformationList = [{
                                    label: '',
                                    type: 'button-icon',
                                    initialWidth: 10,
                                    typeAttributes: {
                                        iconName: 'action:edit',
                                        title: 'Edit',
                                        name: 'edit',
                                        variant: 'border-filled',
                                        alternativeText: 'Edit'
                                    }
                                },
                                { label: 'Prorated', fieldName: 'Is_Segment_1_Selected__c', type: 'boolean'},
                                { label: 'Segment Nº', fieldName: 'PIR_Segment_1__c', type: 'text'},
                                { label: 'Airline (Tracing System)', fieldName: 'PIR_Airline__c', type: 'text'},
                                { label: 'From', fieldName: 'PIR_From__c', type: 'text', editable: true},
                                { label: 'To', fieldName: 'To__c', type: 'text', editable: true},
                                { label: 'Flight N°', fieldName: 'PIR_Flight_Number__c', type: 'text'},
                                { label: 'Flight Date', fieldName: 'PIR_Flight_Date__c', type: 'text'},
                                { label: 'Ticket N°', fieldName: 'PIR_Ticket_Number__c', type: 'text'},
                                { label: 'Miles', fieldName: 'PIR_Miles__c', type: 'Number'},
                                { label: 'Percentage', fieldName: 'PIR_Percentage__c', type: 'Percent'},
                                { label: 'Amount Due', fieldName: 'PIR_Amount_Due__c', type: 'Number'}
                            ];
        }else{
            this.columnsFlightInformationList = [
                                { label: 'Prorated', fieldName: 'Is_Segment_1_Selected__c', type: 'boolean'},
                                { label: 'Segment Nº', fieldName: 'PIR_Segment_1__c', type: 'text'},
                                { label: 'Airline (Tracing System)', fieldName: 'PIR_Airline__c', type: 'text'},
                                { label: 'From', fieldName: 'PIR_From__c', type: 'text' },
                                { label: 'To', fieldName: 'To__c', type: 'text' },
                                { label: 'Flight N°', fieldName: 'PIR_Flight_Number__c', type: 'text'},
                                { label: 'Flight Date', fieldName: 'PIR_Flight_Date__c', type: 'text'},
                                { label: 'Ticket N°', fieldName: 'PIR_Ticket_Number__c', type: 'text'},
                                { label: 'Miles', fieldName: 'PIR_Miles__c', type: 'text' },
                                { label: 'Percentage', fieldName: 'PIR_Percentage__c', type: 'amount' },
                                { label: 'Amount Due', fieldName: 'PIR_Amount_Due__c', type: 'text'}
                            ];

        }
    }
    
    /**
     * Get's all the data for the picklist status
     * 
     */
    fetchPickListValuesIntoList() {
        this.msg = '';
        this.variant = '';
        this.mode = '';
        getPickListValuesIntoList()
            .then(results => {
                this.portalStatusOptions = this.formatComboboxValues(results);
                this.portalStatus = this.baggageClaim.Status__c;

            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                this.variant = 'error';
                this.mode = 'sticky';
                this.msg = error;
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });

                this.dispatchEvent(event);
            });
    }
    
    fetchPickListValuesBaggageInformationPIRColor() {
        this.msg = '';
        this.variant = '';
        this.mode = '';
        getPickListValuesBaggageInformationPIRColor()
            .then(results => {
                this.portalStatusOptionsBaggageInformationPIRColor = this.formatComboboxValues(results);

            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                this.variant = 'error';
                this.mode = 'sticky';
                this.msg = error;
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });

                this.dispatchEvent(event);
            });
    }
    
    fetchPickListValuesBaggageInformationType() {
        this.msg = '';
        this.variant = '';
        this.mode = '';
        getPickListValuesBaggageInformationType()
            .then(results => {
                this.portalStatusOptionsBaggageInformationType = this.formatComboboxValues(results);

            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                this.variant = 'error';
                this.mode = 'sticky';
                this.msg = error;
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });
    
                this.dispatchEvent(event);
            });
    }

    
    /**
     * Transforms a list of strings in a object for the combobox
     * @param {*} stringList 
     */
    formatComboboxValues(stringList) {
        let object = [];

        for (let i = 0; i < stringList.length; i++) {
            object = [...object, { value: stringList[i], label: stringList[i] }];
        }

        return object;
    }


    get fetchProceedToPaymentDate() {
        //year="numeric" month="short" day="2-digit" weekday="narrow"
        var options = {year: 'numeric', month: 'short', day: 'numeric' };
        var newDate = new Date(this.baggageClaim.Date_Time_Proceed_to_payment__c);
        let auxVar = newDate.toLocaleDateString('en-US',options).toUpperCase();
        if(auxVar === 'INVALID DATE'){
            auxVar = '';
        }
        return auxVar;
    }

    @api reloadAgainNotEdit(){
        this.msg = '';
        this.variant = '';
        this.mode = '';
        this.isactionedit = false;
        this.showAttachments = false;
        this.dataRecords = false;
        this.loading = true;
        this.IdPIRForm = this.recid;
        this.errorX2letterAirlineCode = false;
        this.buildcolumnsComents();
        this.buildAttacments();
        this.buildflightInformationList();
        this.buildbagInformationList();
        this.fetchBaggageClaim(this.recid);
    }
    @api reloadAgainEdit(){
        this.isactionedit = true;
        this.showAttachments = false;
        this.dataRecords = false;
        this.loading = true;
        this.IdPIRForm = this.recid;
        this.errorX2letterAirlineCode = false;
        this.buildcolumnsComents();
        this.buildAttacments();
        this.buildflightInformationList();
        this.buildbagInformationList();
        this.fetchBaggageClaim(this.recid);

    }

    @api fetchUpdateClaim(){
        this.msg = '';
        this.variant = '';
        this.mode = '';
        this.loading = true;
    
        console.log('Update::: this.baggageClaim: ', this.errorX2letterAirlineCode);
        if(this.errorX2letterAirlineCode){
            this.dispatchEvent(new CustomEvent('removeparentloading'));
            this.template.querySelector('[data-id="focusOnError"]').focus();
            this.loading = false;
            
            this.msg = 'Invalid Airline Designator Code!';
            this.variant = 'error';
            this.mode = 'sticky';
            this.loading = false;
            const event = new ShowToastEvent({
                //title: 'Get PIR Data',
                message: this.msg,
                variant: this.variant,
                mode: this.mode
            });

            this.dispatchEvent(event);
            return;
        }
        
        this.baggageClaim.Status__c = this.portalStatus;

        let bagClaim = {};


        
            for(let i = 0; i < this.flightInformationList.length; i++){
                this.flightInformationList[i].PIR_Miles__c = parseInt(this.flightInformationList[i].PIR_Miles__c);
                this.flightInformationList[i].PIR_Percentage__c = parseInt(this.flightInformationList[i].PIR_Percentage__c);
                this.flightInformationList[i].PIR_Amount_Due__c = parseInt(this.flightInformationList[i].PIR_Amount_Due__c);
                switch(this.flightInformationList[i].PIR_Segment_1__c) {
                    case "1":
                        this.baggageClaim.Is_Segment_1_Selected__c = this.flightInformationList[i].Is_Segment_1_Selected__c ? this.flightInformationList[i].Is_Segment_1_Selected__c : false;
                        break;
                    case "2":
                        this.baggageClaim.Is_Segment_2_Selected__c = this.flightInformationList[i].Is_Segment_1_Selected__c ? this.flightInformationList[i].Is_Segment_1_Selected__c : false;
                        break;
                    case "3":
                        this.baggageClaim.Is_Segment_3_Selected__c = this.flightInformationList[i].Is_Segment_1_Selected__c ? this.flightInformationList[i].Is_Segment_1_Selected__c : false;
                        break;
                    case "4":
                        this.baggageClaim.Is_Segment_4_Selected__c = this.flightInformationList[i].Is_Segment_1_Selected__c ? this.flightInformationList[i].Is_Segment_1_Selected__c : false;
                        break;
                    default:
                        // code block
                }
                let key = "Is_Segment_1_Selected__c";
                delete this.flightInformationList[i][key]; 
            }
    
            for(let i = 0; i < this.bagInformationList.length; i++){
                switch(this.bagInformationList[i].Bag_Number__c) {
                    case "1":
                        this.baggageClaim.Is_Bag_1_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "2":
                        this.baggageClaim.Is_Bag_2_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "3":
                        this.baggageClaim.Is_Bag_3_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "4":
                        this.baggageClaim.Is_Bag_4_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "5":
                        this.baggageClaim.Is_Bag_5_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "6":
                        this.baggageClaim.Is_Bag_6_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "7":
                        this.baggageClaim.Is_Bag_7_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "8":
                        this.baggageClaim.Is_Bag_8_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c ? this.bagInformationList[i].Is_Bag_1_Selected__c : false;
                        break;
                    case "9":
                        this.baggageClaim.Is_Bag_9_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c;
                        break;
                    case "10":
                        this.baggageClaim.Is_Bag_10_Selected__c = this.bagInformationList[i].Is_Bag_1_Selected__c;
                        break;
                    default:
                        // code block
                }
                let key = "Is_Bag_1_Selected__c";
                delete this.bagInformationList[i][key]; 
            }
        
        //Check's if its a new record or update
        if(this.parentid == null || this.parentid === 'undefined' || this.parentid === ''){
            bagClaim = this.baggageClaim;
        }else{
            bagClaim.Calculation_details__c = this.baggageClaim.Calculation_details__c;
            bagClaim.Parent_PIR_Form__c = this.baggageClaim.Parent_PIR_Form__c;
            bagClaim.Status__c = this.baggageClaim.Status__c;
            bagClaim.X2_letter_Airline_Code__c = this.baggageClaim.X2_letter_Airline_Code__c;
            bagClaim.Airline_receiving__c = this.baggageClaim.Airline_receiving__c;

            bagClaim.Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_1_Selected__c;
            bagClaim.Is_Segment_2_Selected__c = this.baggageClaim.Is_Segment_2_Selected__c;
            bagClaim.Is_Segment_3_Selected__c = this.baggageClaim.Is_Segment_3_Selected__c;
            bagClaim.Is_Segment_4_Selected__c = this.baggageClaim.Is_Segment_4_Selected__c;

            bagClaim.Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_1_Selected__c;
            bagClaim.Is_Bag_2_Selected__c = this.baggageClaim.Is_Bag_2_Selected__c;
            bagClaim.Is_Bag_3_Selected__c = this.baggageClaim.Is_Bag_3_Selected__c;
            bagClaim.Is_Bag_4_Selected__c = this.baggageClaim.Is_Bag_4_Selected__c;
            bagClaim.Is_Bag_5_Selected__c = this.baggageClaim.Is_Bag_5_Selected__c;
            bagClaim.Is_Bag_6_Selected__c = this.baggageClaim.Is_Bag_6_Selected__c;
            bagClaim.Is_Bag_7_Selected__c = this.baggageClaim.Is_Bag_7_Selected__c;
            bagClaim.Is_Bag_8_Selected__c = this.baggageClaim.Is_Bag_8_Selected__c;
            bagClaim.Is_Bag_9_Selected__c = this.baggageClaim.Is_Bag_9_Selected__c;
            bagClaim.Is_Bag_10_Selected__c = this.baggageClaim.Is_Bag_10_Selected__c;
                        
        }

        

        let wrapper = {
            PIRFlightInformation: this.flightInformationList,
            PIRBagInformation: this.bagInformationList
        };
 

        console.log('Update wrapper::: ',wrapper);
        console.log('Update bagClaim:::: ',bagClaim);
        console.log('Update JSON.parse(JSON.stringify(bagClaim)):::: ',JSON.parse(JSON.stringify(bagClaim)));

        UpdateClaim({
            sWrapper:JSON.stringify(wrapper),
            PIRClaim:JSON.parse(JSON.stringify(bagClaim))
        })
        .then(results => {
            if(results.includes('OK') ){
                console.log('MR UpdateClaim:: ',results);
                let aRes = results.split('-');
                this.recid = aRes[1];
                this.parentid = '';
                this.dataRecords = false;
                this.isactionedit = false;
                this.dispatchEvent(new CustomEvent('removebuttonsave'));
                this.connectedCallback();
                this.msg = 'Prorate Request Saved successfully';
                this.variant = 'success';
                this.mode = 'pester';
            }else{
                this.error = true;
                this.dispatchEvent(new CustomEvent('removeparentloading'));
                console.log('UpdateClaim - Error : ', error);
                this.variant = 'error';
                this.mode = 'sticky';
                this.msg = 'error';
            }

        })
        .catch(error => {
            this.error = true;
            this.dispatchEvent(new CustomEvent('removeparentloading'));
            console.log('UpdateClaim - Error : ', error);
            this.variant = 'error';
            this.mode = 'sticky';
            this.msg = 'error';
        })
        .finally(() => {
            this.loading = false;
            const event = new ShowToastEvent({
                title: 'Prorate Request Save',
                message: this.msg,
                variant: this.variant,
                mode: this.mode
            });

            this.dispatchEvent(event);
        });
        
    }


    doFetchAirlineAccountDetails(airlineCode){
        this.msg = '';
        this.variant = '';
        this.mode = '';
        fetchAirlineAccountDetailsAura({
            airlineCode : airlineCode,
            accontIssuingId: this.baggageClaim.Airline_Issuing_Id__c
        })
        .then(results => {
            console.log(results.Id);
            if(results.Id){
                this.baggageClaim.Airline_receiving__c = results.Id;
                this.baggageClaim.Airline_receiving_name__c = results.Name;
                this.baggageClaim.Airline_receiving_formula__c = results.Name;
                this.baggageClaim.Email_Prorate_Dept_Airline_receiving__c = results.Email_Prorate__c;
                this.errorX2letterAirlineCode = false;
                this.msg = 'Valid Airline Designator Code!';
                this.variant = 'success';
                this.mode = 'pester';
                this.loading = false;
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });
    
                this.dispatchEvent(event);
            }else{   
                this.msg = 'Invalid Airline Designator Code!';
                this.variant = 'error';
                this.mode = 'pester';
                this.loading = false;
                this.errorX2letterAirlineCode = true;
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });
    
                this.dispatchEvent(event);
            }
            this.loading = false;

        })
        .catch(error => {
            this.error = true;
            this.loading = false;
            this.variant = 'error';
            this.mode = 'sticky';
            this.msg = error;
            const event = new ShowToastEvent({
                //title: 'Get PIR Data',
                message: this.msg,
                variant: this.variant,
                mode: this.mode
            });

            this.dispatchEvent(event);
        });
    }

    handlePortalStatusChange(event) {
        this.portalStatus = event.detail.value;
        console.log("portalStatus ",this.portalStatus);
    }

    /**
     * Get's all the data for the Baggage Claim
     * @param {*} baggageClaimId 
     */
    fetchBaggageClaim(recid){
        this.msg = '';
        this.variant = '';
        this.mode = '';
        getBaggageClaim({
                baggageClaimId: recid
            })
            .then(results => {

                if(results){
                    this.baggageClaimAllData = JSON.parse(JSON.stringify(results));
                }
                if(results.PIRBagClaim.AmazonFiles__r){
                    this.AmazonFiles = JSON.parse(JSON.stringify(results.PIRBagClaim.AmazonFiles__r)); 
                }
                if(results.PIRBagClaim){
                    this.baggageClaim = JSON.parse(JSON.stringify(results.PIRBagClaim)); 
                }
                if(results.PIRComments){
                    this.claimCommentsLis = JSON.parse(JSON.stringify(results.PIRComments)); 
                }
                if(results.PIRBagInformation){
                    this.bagInformationList = JSON.parse(JSON.stringify(results.PIRBagInformation)); 
                }
                if(results.PIRFlightInformation){
                    this.flightInformationList = JSON.parse(JSON.stringify(results.PIRFlightInformation)); 
                }


                
                for(let i = 0; i < this.flightInformationList.length; i++){
                    if(this.flightInformationList[i].PIR_Miles__c){
                        this.flightInformationList[i].PIR_Miles__c = this.flightInformationList[i].PIR_Miles__c+'';
                    }
                    if(this.flightInformationList[i].PIR_Percentage__c){
                        this.flightInformationList[i].PIR_Percentage__c = this.flightInformationList[i].PIR_Percentage__c+'';
                    }
                    if(this.flightInformationList[i].PIR_Amount_Due__c){
                        this.flightInformationList[i].PIR_Amount_Due__c = this.flightInformationList[i].PIR_Amount_Due__c+'';
                    }
                    if(i === 0 && this.flightInformationList[i].PIR_Segment_1__c === '1'){
                        this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_1_Selected__c ? this.baggageClaim.Is_Segment_1_Selected__c : false;
                    }
                    if(i === 1 && this.flightInformationList[i].PIR_Segment_1__c === '2'){
                        this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_2_Selected__c ? this.baggageClaim.Is_Segment_2_Selected__c : false;
                    }
                    if(i === 2 && this.flightInformationList[i].PIR_Segment_1__c === '3'){
                        this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_3_Selected__c ? this.baggageClaim.Is_Segment_3_Selected__c : false;
                    }
                    if(i === 3 && this.flightInformationList[i].PIR_Segment_1__c === '4'){
                        this.flightInformationList[i].Is_Segment_1_Selected__c = this.baggageClaim.Is_Segment_4_Selected__c ? this.baggageClaim.Is_Segment_4_Selected__c : false;
                    }
                }

                for(let i = 0; i < this.bagInformationList.length; i++){
                    if(i === 0 && this.bagInformationList[i].Bag_Number__c === '1'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_1_Selected__c ? this.baggageClaim.Is_Bag_1_Selected__c : false;
                    }
                    if(i === 1 && this.bagInformationList[i].Bag_Number__c === '2'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_2_Selected__c ? this.baggageClaim.Is_Bag_2_Selected__c : false;
                    }
                    if(i === 2 && this.bagInformationList[i].Bag_Number__c === '3'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_3_Selected__c ? this.baggageClaim.Is_Bag_3_Selected__c : false;
                    }
                    if(i === 3 && this.bagInformationList[i].Bag_Number__c === '4'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_4_Selected__c ? this.baggageClaim.Is_Bag_4_Selected__c : false;
                    }
                    if(i === 4 && this.bagInformationList[i].Bag_Number__c === '5'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_5_Selected__c ? this.baggageClaim.Is_Bag_5_Selected__c : false;
                    }
                    if(i === 5 && this.bagInformationList[i].Bag_Number__c === '6'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_6_Selected__c ? this.baggageClaim.Is_Bag_6_Selected__c : false;
                    }
                    if(i === 6 && this.bagInformationList[i].Bag_Number__c === '7'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_7_Selected__c ? this.baggageClaim.Is_Bag_7_Selected__c : false;
                    }
                    if(i === 7 && this.bagInformationList[i].Bag_Number__c === '8'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_8_Selected__c ? this.baggageClaim.Is_Bag_8_Selected__c : false;
                    }
                    if(i === 8 && this.bagInformationList[i].Bag_Number__c === '9'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_9_Selected__c ? this.baggageClaim.Is_Bag_9_Selected__c : false;
                    }
                    if(i === 9 && this.bagInformationList[i].Bag_Number__c === '10'){
                        this.bagInformationList[i].Is_Bag_1_Selected__c = this.baggageClaim.Is_Bag_10_Selected__c ? this.baggageClaim.Is_Bag_10_Selected__c : false;
                    }
                }
                
                if(this.baggageClaim.AmazonFiles__r){
                    for(let i = 0; i < this.baggageClaim.AmazonFiles__r.length; i++){
                        this.baggageClaim.AmazonFiles__r[i].Size_MB__c = this.baggageClaim.AmazonFiles__r[i].Size_MB__c+'';
                    }
                }
          
                console.log("MR::: ",this.baggageClaimAllData);
                this.dataRecords = true;
                this.portalStatus = this.baggageClaim.Status__c;
                this.fetchPickListValuesIntoList();
                this.fetchPickListValuesBaggageInformationPIRColor();
                this.fetchPickListValuesBaggageInformationType();
                this.loading = false;
            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                this.variant = 'error';
                this.mode = 'sticky';
                this.msg = error;
                const event = new ShowToastEvent({
                    //title: 'Get PIR Data',
                    message: this.msg,
                    variant: this.variant,
                    mode: this.mode
                });
    
                this.dispatchEvent(event);
            });
    }

    fetchGetExpiringLink(fullName){
        this.msg = '';
        this.variant = '';
        this.mode = '';
        getExpiringLink({
            fileName: fullName
        })
        .then(results => { 
            var win = window.open(results, '_blank');
            //win.focus();

        })
        .catch(error => {
            this.error = true;
            this.loading = false;
            this.variant = 'error';
            this.mode = 'sticky';
            this.msg = error;
            const event = new ShowToastEvent({
                //title: 'Get PIR Data',
                message: this.msg,
                variant: this.variant,
                mode: this.mode
            });

            this.dispatchEvent(event);
        });
    }

   
    /**
     * Handles the new Attachment
     * 
     */
    handleAddAttachmentsClick() {
        this.goToNewAttachment = true;
        this.dispatchEvent(new CustomEvent('checksecondlevel'));
    }

    /**
     * Handles the Create New Comment
     * 
     */
    handleCreateNewCommentClick() {
        this.goToNewComment = true;
        this.dispatchEvent(new CustomEvent('checksecondlevel'));

    }

    /**
     * Handles the Create New Comment
     * 
     */

    handleBackClick() {
        this.goBack = true;
    }
    /**
     * Handles the Create New Comment
     * 
     */

    handleBackNewCommenClick() {
        this.goToNewComment = false;
        this.isnewnavigation = false;
        this.dispatchEvent(new CustomEvent('checksecondlevel'));
    }
    handleBackNewAttachmentClick() {
        this.goToNewAttachment = false;
        this.isnewnavigation = false;
        this.dispatchEvent(new CustomEvent('checksecondlevel'));
    }

    onAddNewAttachment(){
        this.dataRecords = false;
        this.connectedCallback();
        this.handleBackNewAttachmentClick();
    }
    onAddNewComment(){
        this.dataRecords = false;
        this.connectedCallback();
        this.handleBackNewCommenClick();
    }

    handleConvertedAmount(event) {
        this.PIR.Amount__c = event.detail.value;
    }

    handleX2letterAirlineCode(event) {
        this.baggageClaim.X2_letter_Airline_Code__c = event.detail.value;
    }
    handleX2letterAirlineCodeBlur() {
        this.loading = true;
        this.doFetchAirlineAccountDetails(this.baggageClaim.X2_letter_Airline_Code__c);
    
    }
    handleCalculationdetails(event) {
        this.baggageClaim.Calculation_details__c = event.detail.value;
    }

    
    /*
        MODALS Methods
    */
    handleOpenModalCorrectProcInvoic(){
        this.showModalCorrectProcInvoic = true;
    }

    handleCloseModalCorrectProcInvoic(){
        this.showModalCorrectProcInvoic = false;
    }

    handleOpenModalResolution780(){
        this.showModalResolution780 = true;
    }

    handleCloseModalResolution780(){
        this.showModalResolution780 = false;
    }

    handleOpenModalResolution754(){
        this.showModalResolution754 = true;
    }

    handleCloseModalResolution754(){
        this.showModalResolution754 = false;
    }
    
    handleCloseModalComment(){
        this.showModalComment = false;
    }
    /**
     * Handles the row actions in the data table Comment
     * @param {*} event 
     */
    handleRowCommentAction(event) {
        const row = JSON.parse(JSON.stringify(event.detail.row));
        const { Id } = row;
        this.IdPIRForm = Id;
        const actionName = event.detail.action.name;
        this.commmentToModal = row;
        switch (actionName) {
            case 'view':
                this.showModalComment = true;
                break;
            default:
        }
    }
    handleNewAttachmentClickModal(){
        this.handleCloseModalComment();
        this.handleCreateNewCommentClick();
    }

    handleRowAttachemntAction(event){
        const row = JSON.parse(JSON.stringify(event.detail.row));
        this.fetchGetExpiringLink(row.Full_Name_Unique__c);
    }

    handlechangeIs_Segment_1_Selected(event){
        this.dataToEditFlightInformation.Is_Segment_1_Selected__c = event.detail.checked;
    }
    handlechangePIR_Airline(event){
        this.dataToEditFlightInformation.PIR_Airline__c = event.detail.value;
    }
    handlechangePIR_From(event){
        this.dataToEditFlightInformation.PIR_From__c = event.detail.value;
    }
    handlechangeTo(event){
        this.dataToEditFlightInformation.To__c = event.detail.value;
    }
    handlechangePIR_Flight_Number(event){
        this.dataToEditFlightInformation.PIR_Flight_Number__c = event.detail.value;
    }
    handlechangePIR_Flight_Date(event){
        this.dataToEditFlightInformation.PIR_Flight_Date__c = event.detail.value;
    }
    handlechangePIR_Ticket_Number(event){
        this.dataToEditFlightInformation.PIR_Ticket_Number__c = event.detail.value;
    }
    handlechangePIR_Miles(event){
        this.dataToEditFlightInformation.PIR_Miles__c = event.detail.value;
    }
    handlechangePIR_Percentage(event){
        this.dataToEditFlightInformation.PIR_Percentage__c = event.detail.value;
    }


    handleRowflightInformationListAction(event){
        const row = JSON.parse(JSON.stringify(event.detail.row));
        let wrapper = {
            Id: row.Id,
            Is_Segment_1_Selected__c: row.Is_Segment_1_Selected__c,
            PIR_Segment_1__c: row.PIR_Segment_1__c,
            PIR_Airline__c: row.PIR_Airline__c,
            PIR_From__c: row.PIR_From__c,
            To__c: row.To__c,
            PIR_Flight_Number__c: row.PIR_Flight_Number__c,
            PIR_Flight_Date__c: row.PIR_Flight_Date__c,
            PIR_Ticket_Number__c: row.PIR_Ticket_Number__c,
            PIR_Miles__c: row.PIR_Miles__c,
            PIR_Percentage__c: row.PIR_Percentage__c,
            PIR_Amount_Due__c: row.PIR_Amount_Due__c,
            PIR_Ref__c: row.PIR_Ref__c
        };
        this.dataToEditFlightInformation = JSON.parse(JSON.stringify(wrapper));
        this.showModalEditFlightInformation = true;
    }

    handleSaveModalEditFlightInformation(){
        console.log('handleSaveModalEditFlightInformation INIT');
        for(let i = 0; i < this.flightInformationList.length; i++){
            if(this.flightInformationList[i].PIR_Segment_1__c === this.dataToEditFlightInformation.PIR_Segment_1__c){
                this.flightInformationList[i] = JSON.parse(JSON.stringify(this.dataToEditFlightInformation));
            }
        }
        this.flightInformationList = JSON.parse(JSON.stringify(this.flightInformationList));
        this.showModalEditFlightInformation = false;
        console.log('handleSaveModalEditFlightInformation END');
    }
    
    handleCloseModalEditFlightInformation(){
        this.showModalEditFlightInformation = false;
    }

    handleRowBagInformationList(event){
        const row = JSON.parse(JSON.stringify(event.detail.row));
        let wrapper = {
            Id: row.Id,
            Is_Bag_1_Selected__c: row.Is_Bag_1_Selected__c,
            Bag_Number__c: row.Bag_Number__c,
            Bag_Tag_Number__c: row.Bag_Tag_Number__c,
            PIR_Color__c: row.PIR_Color__c,
            Type__c: row.Type__c,
            PIR_Form__c: row.PIR_Form__c
        };

        if(row.PIR_Color__c){
            this.portalStatusBaggageInformationPIRColor = row.PIR_Color__c;
        }else{
            this.portalStatusBaggageInformationPIRColor = this.portalStatusOptionsBaggageInformationPIRColor[0]
        }
        if(row.Type__c){
            this.portalStatusBaggageInformationType = row.Type__c;
        }else{
            this.portalStatusBaggageInformationType = this.portalStatusOptionsBaggageInformationType[0]
        }

        this.dataToEditBagInformation = JSON.parse(JSON.stringify(wrapper));
        this.showModalEditBagInformation = true;

    }

    handleSaveModalEditBagInformation(){
        for(let i = 0; i < this.bagInformationList.length; i++){
            if(this.bagInformationList[i].Bag_Number__c === this.dataToEditBagInformation.Bag_Number__c){
                this.bagInformationList[i] = JSON.parse(JSON.stringify(this.dataToEditBagInformation));
            }
        }
        this.bagInformationList = JSON.parse(JSON.stringify(this.bagInformationList));
        this.showModalEditBagInformation = false;
    }

    handleCloseModalEditBagInformation(){
        this.showModalEditBagInformation = false;
    }

    handlechangeBag_Tag_Number(event){
        this.dataToEditBagInformation.Bag_Tag_Number__c = event.detail.value;
    }
    handleBaggageInformationPIRColorChange(event) {
        this.portalStatusBaggageInformationPIRColor = event.detail.value;
        this.dataToEditBagInformation.PIR_Color__c = event.detail.value;
    }

    handleBaggageInformationTypeChange(event) {
        this.portalStatusBaggageInformationType = event.detail.value;
        this.dataToEditBagInformation.Type__c = event.detail.value;
    }

    handlechangeIs_Bag_1_Selected(event){
        this.dataToEditBagInformation.Is_Bag_1_Selected__c = event.detail.checked;
    }

    handleOpenModalParentProrateRequest(){
        //commmentToModal.Baggage_Claim__r.Id
        this.showModalComment = false;
        this.showModalOpenParentProrateRequest = true;
    }
    handleCloseModalParentProrateRequest(){
        this.isactioneditPirForm = false;
        this.showModalComment = true;
        this.showModalOpenParentProrateRequest = false;
    }

      
    handleEditChldClickPirForm(){
        this.template.querySelector('c-portal-prorate-pir-form').reloadAgainEdit();
        this.isactioneditPirForm = true;
    } 

    
    handleCancelChldClickPirForm(){
        this.isactioneditPirForm = false;
        this.template.querySelector('c-portal-prorate-pir-form').reloadAgainNotEdit();

    }  
    handleSaveChldClickPirForm() {
        this.template.querySelector('c-portal-prorate-pir-form').handleSaveClick();
        this.handleCancelChldClickPirForm();
    }
}