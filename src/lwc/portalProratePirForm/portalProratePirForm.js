import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import getPIRForm from '@salesforce/apex/ISSP_Baggage_Proration.getPIRForm';
import getselectOptions from '@salesforce/apex/ISSP_Baggage_Proration.getselectOptions';
import saveForm from '@salesforce/apex/ISSP_Baggage_Proration.saveForm';
import AutoFillData from '@salesforce/apex/ISSP_Baggage_Proration.AutoFillData';
import getPickListValuesBaggageInformationPIRColor from '@salesforce/apex/ISSP_Baggage_Proration.getPickListValuesBaggageInformationPIRColor';
import getPickListValuesBaggageInformationType from '@salesforce/apex/ISSP_Baggage_Proration.getPickListValuesBaggageInformationType';




export default class PortalProratePirForm extends LightningElement {

    @api recid;
    @api isactionedit;


    @track dataRecords = false;
    @track loading = false;
    @track loadingPIRFileRef = false;
    @track error;
    @track mainErrorMessage;
    @track data;
    @track columnsPIRFlightInformation;
    @track columnsPIRBagInformation;
    @track columnsPIRBagClaim;
    @track columnsPIRComments;
    @track sortedBy;
    @track sortedDirection;
    @track readOnlyMode = false;
    @track parentid;
    @track childid;
    @track isActionEditChild;
    @track checkNavigation;
    @track loadingModal = false;
    @track IdBagClaim;

    @track isNew = true;
    @track PIR = {};
    @track PIRAccount = {};
    @track PIRFlightInformation = {};
    @track PIRFlightInformationRecords = false;
    @track PIRBagInformation = {};
    @track PIRBagInformationRecords = false;
    @track PIRBagClaim = {};
    @track PIRBagClaimRecords = false;
    @track portalStatusBaggageInformationPIRColor = ''; //Selected value of the combobox
    @track portalStatusOptionsBaggageInformationPIRColor; //List of options for the combobox
    @track portalStatusBaggageInformationType = ''; //Selected value of the combobox
    @track portalStatusOptionsBaggageInformationType; //List of options for the combobox
    
    //Modals
    @track showForm = true;
    @track showModalCorrectProcInvoic = false;
    @track showModalResolution780 = false;
    @track showModalResolution754 = false;
    @track showModalProrateRequestsForm = false;
    @track showModalEditFlightInformation = false;
    @track dataToEditFlightInformation;
    @track showModalEditBagInformation = false;
    @track dataToEditBagInformation;
    @track showModalOpenParentProrateRequest;
    @track showModalComment = false;
    @track commmentToModal;
    @track goToNewComment = false; // control to go to New Comment
    @track showModalNewComment = false;

    
    @track AirportArrival = 'XXX';
    @track AirlineissuingName;
    @track CreatedByName;
    @track LastModifiedByName;

    // @track recid;
    

    @track CurrencyConversionOptions;
    get PIRFileTypeOptions() {
        return [
            { label: 'None', value: 'None' },
            { label: 'DELAYED', value: 'DELAYED' },
            { label: 'DAMAGED', value: 'DAMAGED' }
        ];
    }
    get TitleOptions() {
        return [
            { label: 'MR.', value: 'MR.' },
            { label: 'MRS.', value: 'MRS.' },
            { label: 'MS.', value: 'MS.' }
        ];
    }
    get CurrencyConversionOptions() {
        return [
            { label: 'MR.', value: 'MR.' },
            { label: 'MRS.', value: 'MRS.' },
            { label: 'MS.', value: 'MS.' }
        ];
    }
    

    connectedCallback() {
        console.log('INIT connectedCallback');
        console.log('this.recid: ' + this.recid);
        
        if(this.recid !== null && this.recid !== 'undefined' && this.recid !== ''){
            this.isNew = false;
            if(!this.isactionedit){
                this.readOnlyMode = true;
            }
            this.fetchPIRInfo(this.recid);
        }else{
            this.fetchPIRInfo('');
        }

        getselectOptions({ objObject: 'PIR_Form__c', fld: 'PIR_Currency_of_conversion__c' })
            .then(result => {
                let myResult = JSON.parse(JSON.stringify(result));
                
                let myTopicOptions = [{ label: 'None', value: 'None' }];

                Object.keys(myResult).forEach(function (el) {
                    // myTopicOptions.push({ label:myResult[el].label, value: myResult[el].value });
                    myTopicOptions.push({ label: myResult[el], value: el });
                });

                this.CurrencyConversionOptions = myTopicOptions;
            })
            .catch(error => {
                console.log('connectedCallback - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
            });  

     
        this.buildcolumnsComents();
        this.buildPIRBagClaim();
        this.buildflightInformationList();
        this.buildbagInformationList();
    }

    /**
     * Builds the columns for the data table Attachments
     */
    buildcolumnsComents() {
        this.columnsPIRComments = [{
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
                            { label: 'Size MB', fieldName: 'Size_MB__c', type: 'amount' },
                            { label: 'Created Date', fieldName: 'CreatedDate', type: 'date' }
                        ];
    }

    /**
     * Builds the columns for the data table Prorate Request (Bag Claim)
     */
    buildPIRBagClaim() {
        this.columnsPIRBagClaim = [{
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
                            {label: 'Request N°', fieldName: 'Name', type: 'text', sortable: true},
                            {label: 'PIR File Ref.', fieldName: 'PIR_File_Ref__c', type: 'text', sortable: true},
                            {label: 'Airline issuing', fieldName: 'Airline_issuing__c', type: 'text', sortable: true},
                            {label: 'Airline receiving', fieldName: 'Airline_receiving__c', type: 'text', sortable: true},
                            {label: 'Passenger\'s First Name', fieldName: 'Passenger_s_First_Name__c', type: 'text', sortable: true},
                            {label: 'Passenger\'s Last Name', fieldName: 'Passenger_s_Last_Name__c', type: 'text', sortable: true},
                            {label: 'Days to Go vs 60-Day-Limit', fieldName: 'Days_to_Go_vs_60_Day_Limit__c', type: 'text', sortable: true},
                            {label: 'Request Sent Date', fieldName: 'Request_Sent_Date_Formated__c', type: 'text', sortable: true},
                            {label: 'Total Prorated Amount Due', fieldName: 'PIR_Total_Prorated_Amount_Due__c', type: 'text', sortable: true},
                            {label: 'Currency', fieldName: 'PIR_Currency__c', type: 'text', sortable: true},
                            {label: 'Status', fieldName: 'Status__c', type: 'text', sortable: true}
                        ];
    }

    /**
     * Builds the columns for the data table bag Information List
     */
    buildbagInformationList() {
        if(this.isactionedit){
            this.columnsPIRBagInformation = [{
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
                                            // { label: 'Prorated', fieldName: 'Is_Bag_1_Selected__c', type: 'boolean'},
                                            { label: 'Bag N°', fieldName: 'Bag_Number__c', type: 'text'},
                                            { label: 'Bag Tag N°', fieldName: 'Bag_Tag_Number__c', type: 'text'},
                                            { label: 'Color', fieldName: 'PIR_Color__c', type: 'text' },
                                            { label: 'Type', fieldName: 'Type__c', type: 'text'}
                                        ];
        }else{
            this.columnsPIRBagInformation = [
                                // { label: 'Prorated', fieldName: 'Is_Bag_1_Selected__c', type: 'boolean'},
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
            this.columnsPIRFlightInformation = [{
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
                                // { label: 'Prorated', fieldName: 'Is_Segment_1_Selected__c', type: 'boolean'},
                                { label: 'Segment Nº', fieldName: 'PIR_Segment_1__c', type: 'text'},
                                { label: 'Airline (Tracing System)', fieldName: 'PIR_Airline__c', type: 'text'},
                                { label: 'From', fieldName: 'PIR_From__c', type: 'text', editable: true},
                                { label: 'To', fieldName: 'To__c', type: 'text', editable: true},
                                { label: 'Flight N°', fieldName: 'PIR_Flight_Number__c', type: 'text'},
                                { label: 'Flight Date', fieldName: 'PIR_Flight_Date__c', type: 'text'},
                                { label: 'Ticket N°', fieldName: 'PIR_Ticket_Number__c', type: 'text'},
                                { label: 'Miles', fieldName: 'PIR_Miles__c', type: 'number'},
                                { label: 'Percentage', fieldName: 'PIR_Percentage__c', type: 'amount'},
                                { label: 'Amount Due', fieldName: 'PIR_Amount_Due__c', type: 'text'}
                            ];
        }else{
            this.columnsPIRFlightInformation = [
                                // { label: 'Prorated', fieldName: 'Is_Segment_1_Selected__c', type: 'boolean'},
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
     * Get's all the data for the picklist
     * 
     */
    fetchPickListValuesBaggageInformationPIRColor() {
        getPickListValuesBaggageInformationPIRColor()
            .then(results => {
                this.portalStatusOptionsBaggageInformationPIRColor = this.formatComboboxValues(results);

            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                console.log('handleSearch - Error : ', error);
            });
    }
    
    fetchPickListValuesBaggageInformationType() {
        getPickListValuesBaggageInformationType()
            .then(results => {
                this.portalStatusOptionsBaggageInformationType = this.formatComboboxValues(results);

            })
            .catch(error => {
                this.error = true;
                this.loading = false;
                console.log('handleSearch - Error : ', error);
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


    /**
     * 
     * EVENT FIELDS METHODS 
     */
    handleAirportArrival(event) {
        this.PIR.Airport_Arrival__c = event.detail.value;
    }
    handleAirlineCode(event) {
        this.PIR.Airline_Code__c = event.detail.value;
    }
    handlePIRFileType(event) {
        this.PIR.PIR_File_Type__c = event.detail.value;
    }
    handlePIRFileRef(event) {
        this.PIR.PIR_File_Ref__c = event.detail.value;
    }

    handlePIRFileRefBlur() {
        console.log('handlePIRFileRefBlur this.PIR.PIR_FilPIR_File_Ref__ce_Type__c: ',this.PIR.PIR_File_Ref__c);
        console.log('handlePIRFileRefBlur this.PIR.PIR_File_Ref__c.length: ',this.PIR.PIR_File_Ref__c.length);

        if(this.PIR.PIR_File_Ref__c !== '' 
                && this.PIR.Airport_Arrival__c !== '' 
                && this.PIR.Airline_Code__c  !== '' 
                && this.PIR.PIR_File_Type__c !== ''
                && (this.PIR.PIR_File_Ref__c.length === 5 || this.PIR.PIR_File_Ref__c.length === 8) ){

            console.log('handlePIRFileRefBlur this.PIR.Airport_Arrival__c: ',this.PIR.Airport_Arrival__c);
            console.log('handlePIRFileRefBlur this.PIR.Airline_Code__c: ',this.PIR.Airline_Code__c);
            console.log('handlePIRFileRefBlur this.PIR.PIR_File_Type__c: ',this.PIR.PIR_File_Type__c);

            let msg='';
            let variant='';
            let mode='';

            this.loadingPIRFileRef = true;

            /**
             * Clear data if it exists already
             */
            this.PIR.Passenger_s_First_Name__c = '';
            this.PIR.Last_Name__c = '';
            this.PIR.Title__c = '';
            
            for(let i = 0; i < this.PIRFlightInformation.length; i++){
                if(this.PIRFlightInformation[i].PIR_Segment_1__c == null){
                    this.PIRFlightInformation[i].PIR_Flight_Number__c = '';
                }
            }
            for(let i = 0; i < this.PIRBagInformation.length; i++){
                if(this.PIRBagInformation[i].Bag_Number__c == null){
                    this.PIRBagInformation[i].Bag_Number__c = i+1;
                    this.PIRBagInformation[i].Bag_Tag_Number__c = 0;
                    this.PIRBagInformation[i].PIR_Color__c = '';
                    this.PIRBagInformation[i].Type__c = '';
                }
            }

            AutoFillData({PIR:this.PIR})
            .then(results => {
                console.log('results: ',results);
                console.log('results.succeeded: ',results.succeeded);
                console.log('results.Errors: ',results.Errors);
                console.log('results.Errors: ',results.Errors.length);
                
                //console.log('FM:results.length: ',this.results.length);
                //if(results && results.length > 0) {
                if(results !== 'undefined' && results.PIRFlightInformation && results.PIRFlightInformation.length > 0 && results.Errors.length == 0) {
                // if(results.succeeded){
                    msg = 'PIR Form retrive successfully';
                    variant = 'success';
                    mode = 'pester';
                    this.data = JSON.parse(JSON.stringify(results));
                
                    console.log('FM:results.PIR: ',results.PIR);

                    this.PIR = JSON.parse(JSON.stringify(results.PIR));
                    this.PIRAccount = results.PIRAccount;

                    this.PIRFlightInformation = results.PIRFlightInformation;
                    if(results.PIRFlightInformation && results.PIRFlightInformation.length > 0) {
                        this.PIRFlightInformationRecords = true;

                        for(let i = 0; i < this.PIRFlightInformation.length; i++){
                            if(this.PIRFlightInformation[i].PIR_Segment_1__c == null){
                                // this.PIRFlightInformation[i].Id = i;
                                this.PIRFlightInformation[i].PIR_Segment_1__c = i+1;
                            }
                        }
                    }

                    this.PIRBagInformation = results.PIRBagInformation;
                    if(results.PIRBagInformation && results.PIRBagInformation.length > 0) {
                        this.PIRBagInformationRecords = true;

                        for(let i = 0; i < this.PIRBagInformation.length; i++){
                            if(this.PIRBagInformation[i].Bag_Number__c == null){
                                // this.PIRBagInformation[i].Id = i;
                                this.PIRBagInformation[i].Bag_Number__c = i+1;
                            }
                        }
                    }
                    
                    this.fetchPickListValuesBaggageInformationPIRColor();
                    this.fetchPickListValuesBaggageInformationType();

                    this.dataRecords = true;

                    console.log('FM:PIRFlightInformation: ',this.PIRFlightInformation);
                    console.log('FM:PIRFlightInformation.length: ',this.PIRFlightInformation.length);
                    console.log('FM:PIRBagInformation: ',this.PIRBagInformation);
                    console.log('FM:PIRBagInformation.length: ',this.PIRBagInformation.length);
                   
                    
                } else {
                    this.dataRecords = false; 
                    if(results.Errors.length > 0) {
                        // $('.forceToastManager').css('white-space', 'pre-wrap');
                        for(let i=0; i<results.Errors.length ; i++){
                            msg += results.Errors[i] + ' \n ';
                        }
                        
                    }else{
                        msg = 'PIR Form Not retrive - please validate the form data';
                    }
                    variant = 'error';
                    mode = 'sticky';
                }
                console.log('FM:results.result_message: ',results.result_message);
                

                // this.loadingPIRFileRef = false;
                
                console.log('FM:data: ',this.data);
                console.log('FM:PIR: ',this.PIR);
                
            })
            .catch(error => {
                console.log('ITPEmployeesWithStationsInfo - Error : ' + error);
                this.mainErrorMessage = error;
                this.error = error;
                msg = error;
            })
            .finally(() => {
                const event = new ShowToastEvent({
                    title: 'Get PIR Data',
                    message: msg,
                    variant: variant,
                    mode: mode
                });

                this.dispatchEvent(event);
                this.loadingPIRFileRef = false;
            })

            
        }
    }
    handleTitle(event) {
        this.PIR.Title__c = event.detail.value;
    }
    handleFirstName(event) {
        this.PIR.Passenger_s_First_Name__c = event.detail.value;;
    }
    handleLastName(event) {
        this.PIR.Last_Name__c = event.detail.value;
        console.log('FM:this.PIR.Last_Name__c: ',this.PIR.Last_Name__c);
        console.log('FM:this.PIR: ',this.PIR);
    }

    handleCurrencyClaim(event) {
        this.PIR.PIR_Currency_Claim__c = event.detail.value;
    }
    handleClaimAmount(event) {
        this.PIR.PIR_Passenger_Claim_Amount__c = event.detail.value;
    }
    handleCurrencyConversion(event) {
        this.PIR.PIR_Currency_of_conversion__c = event.detail.value;
    }
    handleConvertedAmount(event) {
        this.PIR.Amount__c = event.detail.value;
    }

    @api handleSaveClick(){
        // saveForm(PIR_Form__c paramPIR, List<Flight_Information__c> paramFlight_Information_List, List<PIR_Bag_Information__c> paramBag_Information_List, String operation)
        let operation = '';
        let msg;
        let variant;
        let mode;

        if(this.isNew){
            operation = 'NEW';
        }else{
            operation = 'UPDATE';
        }

        for(let i = 0; i < this.PIRFlightInformation.length; i++){
            this.PIRFlightInformation[i].PIR_Miles__c = parseInt(this.PIRFlightInformation[i].PIR_Miles__c);
            this.PIRFlightInformation[i].PIR_Percentage__c = parseInt(this.PIRFlightInformation[i].PIR_Percentage__c);
            this.PIRFlightInformation[i].PIR_Amount_Due__c = parseInt(this.PIRFlightInformation[i].PIR_Amount_Due__c);
            // switch(this.PIRFlightInformation[i].PIR_Segment_1__c) {
            //     case "1":
            //         this.PIRBagClaim.Is_Segment_1_Selected__c = this.PIRFlightInformation[i].Is_Segment_1_Selected__c ? this.PIRFlightInformation[i].Is_Segment_1_Selected__c : false;
            //         break;
            //     case "2":
            //         this.PIRBagClaim.Is_Segment_2_Selected__c = this.PIRFlightInformation[i].Is_Segment_1_Selected__c ? this.PIRFlightInformation[i].Is_Segment_1_Selected__c : false;
            //         break;
            //     case "3":
            //         this.PIRBagClaim.Is_Segment_3_Selected__c = this.PIRFlightInformation[i].Is_Segment_1_Selected__c ? this.PIRFlightInformation[i].Is_Segment_1_Selected__c : false;
            //         break;
            //     case "4":
            //         this.PIRBagClaim.Is_Segment_4_Selected__c = this.PIRFlightInformation[i].Is_Segment_1_Selected__c ? this.PIRFlightInformation[i].Is_Segment_1_Selected__c : false;
            //         break;
            //     default:
            //         // code block
            // }
            let key = "Is_Segment_1_Selected__c";
            delete this.PIRFlightInformation[i][key]; 
        }

        for(let i = 0; i < this.PIRBagInformation.length; i++){
        //     switch(this.PIRBagInformation[i].Bag_Number__c) {
        //         case "1":
        //             this.PIRBagClaim.Is_Bag_1_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "2":
        //             this.PIRBagClaim.Is_Bag_2_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "3":
        //             this.PIRBagClaim.Is_Bag_3_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "4":
        //             this.PIRBagClaim.Is_Bag_4_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "5":
        //             this.PIRBagClaim.Is_Bag_5_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "6":
        //             this.PIRBagClaim.Is_Bag_6_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "7":
        //             this.PIRBagClaim.Is_Bag_7_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "8":
        //             this.PIRBagClaim.Is_Bag_8_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c ? this.PIRBagInformation[i].Is_Bag_1_Selected__c : false;
        //             break;
        //         case "9":
        //             this.PIRBagClaim.Is_Bag_9_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c;
        //             break;
        //         case "10":
        //             this.PIRBagClaim.Is_Bag_10_Selected__c = this.PIRBagInformation[i].Is_Bag_1_Selected__c;
        //             break;
        //         default:
        //             // code block
        //     }
            let key = "Is_Bag_1_Selected__c";
            delete this.PIRBagInformation[i][key]; 
        }


        console.log('FM:this.PIR: ',this.PIR);

        let wrapper = {
            PIR: this.PIR,
            PIRAccount: {},
            PIRFlightInformation: this.PIRFlightInformation,
            PIRBagInformation: this.PIRBagInformation,
            PIRBagClaim: [],
            PIRComments: []
        };
        
        console.log('FM:wrapper: ',wrapper);
        console.log('FM:operation: ',operation);
        console.log('FM:this.isNew: ',this.isNew);

        this.loadingPIRFileRef = true;
       
        saveForm({
            sWrapper:JSON.stringify(wrapper),
            operation: operation
        })
        .then(results => {
            console.log('FM:results: ',results);
            console.log('FM:results.succeeded: ',results.succeeded);
            if(results.includes('OK') ){
                let aRes = results.split('-');

                this.recid = aRes[1];
                console.log('FM:this.recid: ',this.recid);
                msg = 'PIR Form Saved successfully';
                variant = 'success';
                mode = 'pester';
                console.log('FM:results: ',this.results);
                console.log('MR UpdateClaim:: ',results);
                this.dataRecords = false;
                this.isactionedit = false;
                this.dispatchEvent(new CustomEvent('refreshlist'));
                this.dispatchEvent(new CustomEvent('removebuttonsave'));
                this.connectedCallback();
            }else {
                msg = 'Error Occurred: ' + results;
                variant = 'error';
                mode = 'sticky';
            }
        })
        .catch(error => {
            this.error = true;
            console.log('handleSearch - Error : ', error);
            this.mainErrorMessage = error;
            this.error = error;
            msg = 'Error Occurred: ' + error;
        })
        .finally(() => {
            this.loadingPIRFileRef = false;

            const event = new ShowToastEvent({
                title: 'Save PIR Data',
                message: msg,
                variant: variant,
                mode: mode
        });

            this.dispatchEvent(event);
        })
    }

    handleCreateNewProrateRequest() {
        console.log('INIT handleCreateNewProrateRequest');

        console.log('[PortalProrateRequestsForm] connectedCallback : this.PIRFlightInformation : ',this.PIRFlightInformation);
        console.log('[PortalProrateRequestsForm] connectedCallback : this.PIRBagInformation : ',this.PIRBagInformation);


        this.isActionEditChild = true;
        // this.parentid = this.recid;
        this.parentid = this.PIR;
        this.childid = '';
        this.showModalProrateRequestsForm = true;
        
        
    }

    
    /**
     * Handles the row actions in the data table Prorate Request
     * @param {*} event 
     */
    handleRowBagClaimAction(event) {
        const row = JSON.parse(JSON.stringify(event.detail.row));
        const { Id } = row;
        this.childid = Id;
        this.parentid = '';
        
        const actionName = event.detail.action.name;
        this.commmentToModal = row;
        switch (actionName) {
            case 'view':
                this.isActionEditChild = false;
                this.showModalProrateRequestsForm = true;
                break;
            default:
        }
    }
    
    @api reloadAgainNotEdit(){
        this.isactionedit = false;
        this.readOnlyMode = true;
        // this.showAttachments = false;
        this.dataRecords = false;
        //this.loading = true;
        this.IdPIRForm = this.recid;
        this.errorX2letterAirlineCode = false;
        this.buildcolumnsComents();
        this.buildPIRBagClaim();
        this.buildflightInformationList();
        this.buildbagInformationList();
        // this.fetchBaggageClaim(this.recid);
        this.fetchPIRInfo(this.recid);
    }
    @api reloadAgainEdit(){
        this.isactionedit = true;
        this.readOnlyMode = false;
        // this.showAttachments = false;
        this.dataRecords = false;
        //this.loading = true;
        this.IdPIRForm = this.recid;
        this.errorX2letterAirlineCode = false;
        this.buildcolumnsComents();
        this.buildPIRBagClaim();
        this.buildflightInformationList();
        this.buildbagInformationList();
        this.fetchPIRInfo(this.recid);

    }
    

    /**
     * Get's all the data for the Baggage Claim
     * @param {*} baggageClaimId 
     */
    fetchPIRInfo(recid) {
        this.loadingPIRFileRef = true;
        getPIRForm({
                recid: recid
            })
            .then(results => {
                console.log('FM:results: ',this.results);
                //console.log('FM:results.length: ',this.results.length);
                //if(results && results.length > 0) {
                 if(results !== 'undefined') {
                    this.data = JSON.parse(JSON.stringify(results));
                 
                    this.PIR = JSON.parse(JSON.stringify(results.PIR));
                    this.PIRAccount = results.PIRAccount;
                    this.PIRFlightInformation = results.PIRFlightInformation;
                    if(results.PIRFlightInformation && results.PIRFlightInformation.length > 0) {
                        this.PIRFlightInformationRecords = true;
                    }
                    this.PIRBagInformation = results.PIRBagInformation;
                    if(results.PIRBagInformation && results.PIRBagInformation.length > 0) {
                        this.PIRBagInformationRecords = true;
                    }
                    
                    this.PIRBagClaim = results.PIRBagClaim;
                    if(results.PIRBagClaim && results.PIRBagClaim.length > 0) {
                        this.PIRBagClaimRecords = true;
                    }
                    this.PIRComments = results.PIRComments;
                    if(results.PIRComments && results.PIRComments.length > 0) {
                        this.PIRCommentsRecords = true;
                    }

                    for(let i = 0; i < this.PIRBagClaim.length; i++){
                        this.PIRBagClaim[i].Days_to_Go_vs_60_Day_Limit__c = this.PIRBagClaim[i].Days_to_Go_vs_60_Day_Limit__c == null ? '0':this.PIRBagClaim[i].Days_to_Go_vs_60_Day_Limit__c.toString();
                        this.PIRBagClaim[i].PIR_Total_Prorated_Amount_Due__c = this.PIRBagClaim[i].PIR_Total_Prorated_Amount_Due__c == null ? '0':this.PIRBagClaim[i].PIR_Total_Prorated_Amount_Due__c.toString();
                    }


                    for(let i = 0; i < this.PIRFlightInformation.length; i++){
                        if(this.PIRFlightInformation[i].PIR_Miles__c){
                            this.PIRFlightInformation[i].PIR_Miles__c = this.PIRFlightInformation[i].PIR_Miles__c+'';
                        }
                        if(this.PIRFlightInformation[i].PIR_Percentage__c){
                            this.PIRFlightInformation[i].PIR_Percentage__c = this.PIRFlightInformation[i].PIR_Percentage__c+'';
                        }
                        if(this.PIRFlightInformation[i].PIR_Amount_Due__c){
                            this.PIRFlightInformation[i].PIR_Amount_Due__c = this.PIRFlightInformation[i].PIR_Amount_Due__c+'';
                        }
                        // if(i === 0 && this.PIRFlightInformation[i].PIR_Segment_1__c === '1'){
                        //     this.PIRFlightInformation[i].Is_Segment_1_Selected__c = this.PIRBagClaim.Is_Segment_1_Selected__c ? this.PIRBagClaim.Is_Segment_1_Selected__c : false;
                        // }
                        // if(i === 1 && this.PIRFlightInformation[i].PIR_Segment_1__c === '2'){
                        //     this.PIRFlightInformation[i].Is_Segment_1_Selected__c = this.PIRBagClaim.Is_Segment_2_Selected__c ? this.PIRBagClaim.Is_Segment_2_Selected__c : false;
                        // }
                        // if(i === 2 && this.PIRFlightInformation[i].PIR_Segment_1__c === '3'){
                        //     this.PIRFlightInformation[i].Is_Segment_1_Selected__c = this.PIRBagClaim.Is_Segment_3_Selected__c ? this.PIRBagClaim.Is_Segment_3_Selected__c : false;
                        // }
                        // if(i === 3 && this.PIRFlightInformation[i].PIR_Segment_1__c === '4'){
                        //     this.PIRFlightInformation[i].Is_Segment_1_Selected__c = this.PIRBagClaim.Is_Segment_4_Selected__c ? this.PIRBagClaim.Is_Segment_4_Selected__c : false;
                        // }
                    }
    
                    // for(let i = 0; i < this.PIRBagInformation.length; i++){
                    //     if(i === 0 && this.PIRBagInformation[i].Bag_Number__c === '1'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_1_Selected__c ? this.PIRBagClaim.Is_Bag_1_Selected__c : false;
                    //     }
                    //     if(i === 1 && this.PIRBagInformation[i].Bag_Number__c === '2'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_2_Selected__c ? this.PIRBagClaim.Is_Bag_2_Selected__c : false;
                    //     }
                    //     if(i === 2 && this.PIRBagInformation[i].Bag_Number__c === '3'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_3_Selected__c ? this.PIRBagClaim.Is_Bag_3_Selected__c : false;
                    //     }
                    //     if(i === 3 && this.PIRBagInformation[i].Bag_Number__c === '4'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_4_Selected__c ? this.PIRBagClaim.Is_Bag_4_Selected__c : false;
                    //     }
                    //     if(i === 4 && this.PIRBagInformation[i].Bag_Number__c === '5'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_5_Selected__c ? this.PIRBagClaim.Is_Bag_5_Selected__c : false;
                    //     }
                    //     if(i === 5 && this.PIRBagInformation[i].Bag_Number__c === '6'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_6_Selected__c ? this.PIRBagClaim.Is_Bag_6_Selected__c : false;
                    //     }
                    //     if(i === 6 && this.PIRBagInformation[i].Bag_Number__c === '7'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_7_Selected__c ? this.PIRBagClaim.Is_Bag_7_Selected__c : false;
                    //     }
                    //     if(i === 7 && this.PIRBagInformation[i].Bag_Number__c === '8'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_8_Selected__c ? this.PIRBagClaim.Is_Bag_8_Selected__c : false;
                    //     }
                    //     if(i === 8 && this.PIRBagInformation[i].Bag_Number__c === '9'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_9_Selected__c ? this.PIRBagClaim.Is_Bag_9_Selected__c : false;
                    //     }
                    //     if(i === 9 && this.PIRBagInformation[i].Bag_Number__c === '10'){
                    //         this.PIRBagInformation[i].Is_Bag_1_Selected__c = this.PIRBagClaim.Is_Bag_10_Selected__c ? this.PIRBagClaim.Is_Bag_10_Selected__c : false;
                    //     }
                    // }

                    this.fetchPickListValuesBaggageInformationPIRColor();
                    this.fetchPickListValuesBaggageInformationType();
                    
                    //this.AirlineissuingName = this.PIR.Airline_issuing__r.Name;
                    this.AirlineissuingName = this.PIRAccount.Name;
                    this.CreatedByName = this.PIR.CreatedBy.Name;
                    this.LastModifiedByName = this.PIR.LastModifiedBy.Name;

                    this.dataRecords = true;

                    console.log('FM:PIRFlightInformation: ',this.PIRFlightInformation);
                    console.log('FM:PIRFlightInformation.length: ',this.PIRFlightInformation.length);
                    console.log('FM:PIRBagInformation: ',this.PIRBagInformation);
                    console.log('FM:PIRBagInformation.length: ',this.PIRBagInformation.length);
                    console.log('FM:PIRBagClaim: ',this.PIRBagClaim);
                    console.log('FM:PIRBagClaim.length: ',this.PIRBagClaim.length);
                    console.log('FM:PIRComments: ',this.PIRComments);
                    console.log('FM:PIRComments.length: ',this.PIRComments.length);
                    
                } else {
                    this.dataRecords = false; 
                }
                this.loadingPIRFileRef = false;
                
                console.log('FM:data: ',this.data);
                console.log('FM:PIR: ',this.PIR);
                console.log('FM:PIR: ',this.PIR.Airline_issuing__r.Name);
                
            })
            .catch(error => {
                this.error = true;
                this.loadingPIRFileRef = false;
                console.log('handleSearch - Error : ', error);
            });
    }


    


    /*
        MODALS Methods
    */
    handleOpenModalProrateRequestsForm(){
        this.showModalProrateRequestsForm = true;
    }
    handleOpenModalCorrectProcInvoic(){
        this.showModalCorrectProcInvoic = true;
    }

    handleCloseModalCorrectProcInvoic(){
        this.showModalCorrectProcInvoic = false;
    }
    
    handleOpenModalResolution780(){
        this.showModalResolution780 = true;
    }

    handleCloseModalProrateRequestsForm(){
        this.showModalProrateRequestsForm = false;
        this.connectedCallback();
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


    onRemoveLoading(){
        this.loading = false;
    }
    onCheckNavigation(){
        this.checkNavigation = !this.checkNavigation ;
    }
    removeButtonSave(){
        console.log("removeButtonSave")
        this.loading = false;
        this.isActionEditChild = false ;
    }

    handleSaveChldClick() {
        this.loading = true;
        this.template.querySelector('c-portal-prorate-requests-form').fetchUpdateClaim();
    }
    handleCancelChldClick(){
        this.isActionEditChild = false;
        this.template.querySelector('c-portal-prorate-requests-form').reloadAgainNotEdit();

    }    
    handleEditChldClick(){
        this.template.querySelector('c-portal-prorate-requests-form').reloadAgainEdit();
        this.isActionEditChild = true;
    }        

    /**
     * FlightInformationList and BagInformationList Datatables methods
     *  
     */

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
        console.log('handleSaveModalEditFlightInformation INIT');
    }

    handleSaveModalEditFlightInformation(){
        this.PIRFlightInformation = JSON.parse(JSON.stringify(this.PIRFlightInformation));
        this.dataToEditFlightInformation = JSON.parse(JSON.stringify(this.dataToEditFlightInformation));
      
        for(let i = 0; i < this.PIRFlightInformation.length; i++){
            
            if(this.PIRFlightInformation[i].PIR_Segment_1__c === this.dataToEditFlightInformation.PIR_Segment_1__c){
                this.PIRFlightInformation[i] = this.dataToEditFlightInformation;
            }
        }
        
        // this.flightInformationList = JSON.parse(JSON.stringify(this.flightInformationList));
        this.PIRFlightInformation = JSON.parse(JSON.stringify(this.PIRFlightInformation));
        this.showModalEditFlightInformation = false;
    }
    
    handleCloseModalEditFlightInformation(){
        this.showModalEditFlightInformation = false;
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
        this.PIRBagInformation = JSON.parse(JSON.stringify(this.PIRBagInformation));
        this.dataToEditBagInformation = JSON.parse(JSON.stringify(this.dataToEditBagInformation));

        for(var i = 0; i < this.PIRBagInformation.length; i++){
            if(this.PIRBagInformation[i].Bag_Number__c === this.dataToEditBagInformation.Bag_Number__c){
                this.PIRBagInformation[i] = JSON.parse(JSON.stringify(this.dataToEditBagInformation));
            }
        }

        for(let i = 0; i < this.PIRFlightInformation.length; i++){
            
            if(this.PIRFlightInformation[i].PIR_Segment_1__c === this.dataToEditFlightInformation.PIR_Segment_1__c){
                this.PIRFlightInformation[i] = this.dataToEditFlightInformation;
            }
        }
        // this.bagInformationList = JSON.parse(JSON.stringify(this.bagInformationList));
        this.PIRBagInformation = JSON.parse(JSON.stringify(this.PIRBagInformation));
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
        this.showModalComment = true;
        this.showModalOpenParentProrateRequest = false;
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
        // this.IdBagClaim = Id;
        this.IdBagClaim = row.Baggage_Claim__c;
        console.log('handleRowCommentAction IdBagClaim: ',this.IdBagClaim);
        const actionName = event.detail.action.name;
        this.commmentToModal = row;
        switch (actionName) {
            case 'view':
                this.showModalComment = true;
                break;
            default:
        }
    }

    handleOpenModalNewComment(){
        this.handleCloseModalComment();
        // this.handleCreateNewCommentClick();
        this.showModalNewComment = true;
    }
    handleCloseModalNewComment(){
        this.showModalNewComment = false;
    }

     /**
     * Handles the Create New Comment
     * 
     */
    handleCreateNewCommentClick() {
        // this.goToNewComment = true;
        this.handleOpenModalNewComment();
        this.dispatchEvent(new CustomEvent('checksecondlevel'));

    }
    handleBackNewCommenClick() {
        // this.goToNewComment = false;
        this.handleCloseModalNewComment();
        this.isnewnavigation = false;
        this.dispatchEvent(new CustomEvent('checksecondlevel'));
    }
    onAddNewComment(){
        this.dataRecords = false;
        this.connectedCallback();
        this.handleBackNewCommenClick();
    }
}