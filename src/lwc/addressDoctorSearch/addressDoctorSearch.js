/**
 * Created by pvavruska on 8/9/2019.
 */

import { LightningElement,track,api} from 'lwc';

/* APEX */

import quickSearch from '@salesforce/apex/OneId_AddressDoctor.quickSearch';
import validateAddress from '@salesforce/apex/GCS_AccountCreation.checkAddress';

const sldsOpen = 'slds-is-open';

export default class addressDoctorSearch extends LightningElement {
    @api inputValue;
    @api countryCode;
    @api stateName;
    @api city;
    @api street;
    @api zip;
    @api type;
    @api disabled = false;

    @track response;
    @track searching = false;
    @track showSuggestion = false;


    connectedCallback(){
        //this.search();
    }

    hideResults(){
        this.showSuggestion = false;
    }

    @api
    search() {

        var userInputValue = this.inputValue;//c.get("v.inputValue");
        //var resultDiv = c.find('results');
        //let resultDiv = this.template.querySelector('[data-id="results"]');

        //console.log('doctorSearch '+userInputValue+' - '+this.countryCode);

        if(userInputValue === undefined || userInputValue.length < 3) {
            console.log('doctorSearch - no search');
            // Hide suggestion box
            //resultDiv.classList.remove(sldsOpen);
        } else {
            // Call Address Doctor when user input at least 3 characters
            // When user search on input field call Address doctor to get suggestion for validation of address
            this.searching = true;

            try{this.validate()}catch(e){
                console.log('failed to validate.');
            }

            quickSearch({"userInput": userInputValue, "countryCode":this.countryCode})
            .then(result=>{

                //console.log('doctorSearch res \n'+JSON.stringify(result));

                let suggestions = [];

                result.forEach((address,index,arr) => {
                    address.title = address.street;
                    address.title += address
                    .locality === undefined || address.locality.length == 0 ? '' : (', '+address.locality);
                    address.title += address.province === undefined || address.province.length == 0 ? '' : (', '+address.province);
                    address.title += address.postalCode === undefined || address.postalCode.length == 0 ? '' : (', '+address.postalCode);
                    address.key = index;

                    suggestions.push(address);
                });

                console.log(suggestions.length);

                if(suggestions != undefined && suggestions.length > 0) {
                    this.response = suggestions;
                    this.showSuggestion = true;
                } else {
                    let noResult = {'street':userInputValue};
                    suggestions.push(noResult);
                    this.response = suggestions;
                }

                this.searching = false;

                /*if(resultDiv.classList.indexOf(sldsOpen) == -1){
                    resultDiv.classList.add(sldsOpen);
                }*/
            })
            .catch(error => {
                console.log('Error: ', error);
             });

        }
    }


    validate(){
        let addressInfo = {
            street : this.street,
            locality : this.city,
            postalCode : this.zip,
            province : this.stateName,
            countryCode : this.countryCode
        };

        console.log(addressInfo);


        validateAddress({"info":JSON.stringify(addressInfo)})
        .then(result=>{
            console.log(JSON.stringify(result));
        })
        .catch(error=>{
            console.log('Error: ', error);
        });
    }

    /**
        When a user select a sugestion from the suggestion box
    */
    suggestionSelected(event) {
        var suggestionSelected = event.target;

        // Set input with selected value
        var response = this.response;
        var index = parseInt(suggestionSelected.dataset.value);

        this.inputValue = response[index].street;

        //let resultDiv = this.template.querySelector('[data-id="results"]');

        // Hide suggestion box
        //resultDiv.classList.remove(sldsOpen);

        console.log(response[index]);


        this.dispatchEvent(new CustomEvent('addressselected', { detail: { 'addressType': this.type, 'address':response[index]} }));
        this.hideResults();

    }

    closeResults() {
        //let resultDiv = this.template.querySelector('[data-id="results"]');

        // Hide suggestion box
        //resultDiv.classList.remove(sldsOpen);
        // send param with change of street
        this.dispatchEvent(new CustomEvent('addressselected', { detail: { 'addressType': this.type, 'addressSelected':{'street':this.userInputValue}} }));
    }

    get hasSuggestions(){
        return this.showSuggestion && this.response !== undefined && this.response.length > 0;
    }
}