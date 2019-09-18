import { LightningElement, api, track } from 'lwc';

import fetchJSON from '@salesforce/apex/WebserviceTableController.getJSON';

export default class JsonDatatable extends LightningElement {

    /* Variables */

    order;
    names;
    height;

    @track mydata;
    @track showData = false;
    @track showSpinner = false;
    @track noResults = false;
    @track hasError = false;
    
    @api autoLoad = false;
    
    @api handler = '';
    @api operationType = 'GET';
    @api webserviceEndpoint;
    @api endpointType;
    @api webservicePath;
    @api webserviceBody;
    
    @track columns;
    
    @api
    get columnOrder(){
        return this.order;
    }
    set columnOrder(value){
        //if not provided, the columnNames will be the same as the columnOrder
        if(this.columnNames === undefined) this.columnNames = value;
        this.order = value;

        this.assembleColumns();
    }

    @api
    get columnNames(){
        return this.names;
    }
    set columnNames(value){
        this.names = value;
        this.assembleColumns();
    }
    
    @api
    get maxHeight(){
        return this.height;
    }
    set maxHeight(value){
        //we need to check if the value is provided and has a unit 
        if(value === undefined) value = "100%"
        else if(value && !isNaN(value)){
            value+='px';// leaves in px by default
        }
        this.height = value;
    }

    get finalEndpoint(){
        let endpoint = (this.endpointType === 'URL'? '' : 'Callout:') + this.webserviceEndpoint;

        if(this.webservicePath) endpoint += this.webservicePath;
        //TODO replace e cenas

        return endpoint;
    }



    /**********************************************/
    /*************** Helper Methods ***************/
    /**********************************************/
    assembleColumns(){
        let c = [];

        if(this.columnNames && this.columnOrder){
            let fieldNameList = this.columnOrder.split(',');
            let labelList = this.columnNames.split(',');
            for(let i = 0; i < labelList.length; i++){
                c.push({label: labelList[i].trim(), fieldName: fieldNameList[i].trim()});
            }
        }

        this.columns = c;
    }

    //exposing a function so parents can call exposes table AND makes another call
    @api
    loadTable(){
        this.showData = false;
        this.noResults = false;
        this.hasError = false;
        this.showSpinner = true;

        fetchJSON({handler: this.handler, endpoint: this.finalEndpoint, method: this.operationType, jsonBody: this.webserviceBody})
        .then(data => {
            let returnData = JSON.parse(data);
            
            if ( !(returnData instanceof Array) ){ 
                returnData = [];
                this.hasError = true;
                console.error('Result is not an array, please fix webservice or use a handler to parse the result');
                return;
            }

            this.mydata = returnData;

            if(this.mydata.length > 0){
                this.showData = true;
            }else{
                this.noResults = true;
            }
        })
        .catch(error => {
            this.hasError = true;
            console.error(JSON.stringify(error));
        })
        .finally(() => {
            this.showSpinner = false;
        });
    }

    //exposing a method do hide the table so parents can call
    @api
    hidetable(){
        this.showData = false;
    }
    

    

    /**********************************************/
    /*************** Lifecycle Hooks **************/
    /**********************************************/

    //once the component is loaded, only make the call if autoload is true
    connectedCallback(){
        if(this.autoLoad){
            this.loadTable();
        }
    }

    renderedCallback(){

        this.template.querySelector(".container").style.maxHeight = this.height;
    }
}