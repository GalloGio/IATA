import { LightningElement, api, track, wire } from 'lwc';

import fetchJSON from '@salesforce/apex/WebserviceTableController.getJSON';
import { refreshApex } from '@salesforce/apex';

export default class JsonDatatable extends LightningElement {

    /* Helper Methods */


    //returns a new object with renamed keys
    // so if the keyMap is {a: newA, b: newB} and obj is {a: 1, b: 2}
    //result will be {newA: 1, newB: 2}
    renameKeys(keysMap, obj){
        //reduce function performs an operation (first parameter) into every key in the array starting with a initial value (second parameter)
        //in this case we use an empty object {} as starting point and:
        //1. Check if the keysMap has a new key and use it (if not, use the old key) - [keysMap[key] || key
        //2. create a new object with the resulting key and the value for the old key - { _resulting key_: obj[key] }
        //3. merge it to the current temporary object using the spread operator { ...oldObj, ... newObj}
        //4. the reduce function repeats it for all keys
        return Object.keys(obj).reduce(
            (tempObject, key) => ({ ...tempObject, ...{ [keysMap[key] || key]: obj[key] } }), 
            {} 
        );
    }


    /* Variables */
    @track mydata;
    @track showData = false;
    //TODO add an "search while texting function"

    @api autoLoad;

	@api operationType = 'GET';
	@api webserviceEndpoint;
    @api endpointType;
    @api webservicePath;
    @api webserviceBody;
	@api okStatusCode = 200;
    
    @api columnNames; //the names to diplay in each column
    @api //the columns from the webservice response
    set columnOrder(value){
        //if not provided, the columnNames will be the same as the columnOrder
        if(this.columnNames === undefined) this.columnNames = value;
        this.columnOrder = value;
    }
    get columnOrder(){
        return this.columnOrder;
    }
    
    @api
    set maxHeight(value){
        //we need to check if the value is provided and has a unit 
        if(value === undefined) value = "100%"
        else if(value && !isNaN(value)){
            value+='px';// leaves in px by default
        }
        this.maxHeight = value;
        this.template.querySelector(".container").style.setProperty("--box-height", this.maxHeight);

    }
    get maxHeight(){
        return this.maxHeight;
    }



    get finalEndpoint(){
        let endpoint = (this.endpointType.toUpperCase() === 'URL'?'':'Callout:') + this.webserviceEndpoint;

        if(this.methodpath) endpoint += this.methodpath;
        //TODO replace e cenas

        return endpoint;
    }

    get keyMapping(){
        if(this.keyMapping === undefined){
            let keys = this.columnOrder.split(',');
            let names = this.columnNames.split(',');
    
            let map = {};
            for(let i = 0; i < names.length; i++){
                map[keys[i].trim()] = names[i].trim();
            }
            this.keyMapping = map;
        }
        return this.keyMapping;
    }
    
    /* Actions */

    //need to refetch if any mutable parameter changes (endpoint may have query parameters changed, body can change everything)
    @wire(fetchJSON, {endpoint: '$finalEndpoint', method: this.operationType, okStatusCode: this.okStatusCode, jsonBody: '$webserviceBody'})
    wiredRetrieve({error, data}){
        if(data){

            let returnData;
            if ( !(data instanceof Array) ){ 
                //means the webservice does not return an array
                //TODO show errors OR find the array in the list (maybe use a parameters to parse)
            }else{
                returnData = data;
            }

            let dataToDisplay=[];

            returnData.forEach(function(record){
                dataToDisplay.push(this.renameKeys(this.keyMapping, record));
            });
            this.mydata = dataToDisplay;         
        }else if(error){
            //TODO handle error
        }
    }

    //once the component is loaded, only make the call if autoload is true
    connectedCallback(){
        if(this.autoLoad) this.showData = true
    }

    //exposing a function so parents can call: shows table and forces refresh (in case it's already shown)
    @api
    loadTable(){    
        this.showData = true;
        refreshApex(this.wiredRetrieve);
    }

    //exposing a method do hide the table so parents can call
    @api
    hidetable(){
        this.showData = false;
    }
    
}