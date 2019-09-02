/**
 * Created by pvavruska on 8/8/2019.
 */

import { LightningElement,api,track } from 'lwc';

/* APEX METHODS */
import getISOCountries from '@salesforce/apex/GCS_RegistrationController.getISOCountries';
import getCountryStates from '@salesforce/apex/GCS_AccountCreation.getStates';

/* LABELS*/

export default class PortalAddressForm extends LightningElement {

    /* Passed address information */
    @api country;
    @api state;
    @api city;
    @api street;
    @api zip;
    @api fieldTitle;

    /* Extra params */
    @api addressValidation;
    @api showSuggestions;


    /* Select options */
    @track cityOptions;
    @track stateOptions;
    @track countryOptions;

    /* Suggestions */
    @track stateSuggestion;
    @track citySuggestion;

    /* Form styling */
    @api inputClass;

    /* Local address information */
    @track countryId = '';
    @track countryCode;
    @track stateId = '';
    @track stateName = '';
    @track thisCity = '';
    @track thisStreet = '';
    @track thisZip = '';

    /* Address data*/
    countryData;
    stateData;

    /* flags */
    @track loadingStates = false;
    @track loadingCountries = true;
    @track citiesListbox = false;
    @track showDoctor = false;

    connectedCallback(){
        getISOCountries().then(result=>{
            let dataList = JSON.parse(JSON.stringify(result.countryList));
            let optionList = this.buildOptions(dataList,true);

            this.countryData = result;
            this.countryOptions = optionList;
            this.loadingCountries = false;

            if(this.country !== undefined && this.country.length > 0){
                this.handleCountryChange(this.country);
            }
        });
    }

    @api
    get address(){
        let address = {
            'Country':this.countryId,
            'State':this.stateId,
            'City':this.thisCity,
            'Street':this.thisStreet,
            'Zip':this.thisZip
        };

        return address;
    }


    /* Build option list */
    buildOptions(dataList, includeEmpty){
        let optionList = [];

        if(includeEmpty){
            optionList.push({ 'label': '', 'value': '' });
        }

        dataList.forEach(function (data) {
            optionList.push({ 'label': data.Name, 'value': data.Id });
        });

        return optionList;

    }

    buildSuggestions(){

    }


    /* Handle form changes */
    handleCountryChange(countryId){

        let country = this.countryData.countryMap[countryId];
        console.log(country)

        if(countryId === undefined || countryId.length == 0){
            this.thisCountry = '';
            return;
        }

        this.countryId = country.Id;
        this.countryCode = country.ISO_Code__c;

        if(country === undefined || country.Region_Province_and_Cities_Enabled__c == false){
            this.stateOptions = [];
            return;
        }

        this.loadingStates = true;

        getCountryStates({"country":country.Name}).then(result =>{
            console.log(result)

            let states = JSON.parse(JSON.stringify(result.states));

            let optionList = this.buildOptions(states,true);

            this.stateData = result;
            this.stateOptions = optionList;
            this.loadingStates = false;
        });

    }

    handleStateChange(stateId){

        let state = this.stateData.states.find(function (state) {
                return state.Id === stateId;
        });


        let stateInput = this.template.querySelector('.stateCombobox');
        //stateInput.value = state.Name;

        this.stateName = state !== undefined ? state.Name : '';
        this.stateId = state !== undefined ? state.Id : '';
    }

    handleCityChange(event){

        let value = event.target.dataset.value;
        let name = event.target.dataset.name;
        let stateid = event.target.dataset.stateid;

        this.citiesListbox = false;
        this.thisCity = name;

        let cityInput = this.template.querySelector('.cityInput');
        cityInput.value = name;

        this.handleStateChange(stateid);
    }

    handleCityKey(event){
        let stateData = this.stateData;
        let value = event.target.value;
        let selectedState = this.stateId;

        this.thisCity = value;

        let cityOptions = [];

        if(value === undefined || value.length == 0){
            this.citySuggestion = [];
            this.citiesListbox = false;
            return;
        }

        let state;

        if(stateData !== undefined && stateData.states !== undefined){

            if(selectedState){

                state = this.stateData.states.find(function (currentState) {
                    return currentState.Id === selectedState;
                });

                stateData = {'states':[state]};
            }

            let suggestionList = [];


            stateData.states.forEach(function (state) {
                if(state.IATA_ISO_Cities__r !== undefined){

                    state.IATA_ISO_Cities__r.forEach(function (city) {
                        if(city.Name !== undefined && city.Name.toLowerCase().indexOf(value.toLowerCase()) > -1){
                            suggestionList.push({
                                'label': city.GeonameHierarchy_label__c,
                                'value': city.Id,
                                'stateid':city.IATA_ISO_State__c,
                                'name':city.Name
                            });
                        }
                    });
                }
            });

            if(suggestionList.length > 0){
                this.citiesListbox = true;
            }else{
                this.citiesListbox = false;
            }

            this.citySuggestion = suggestionList;
        }
    }

    handleFieldChange(event){
        let value = event.target.value;
        let fieldname = event.target.dataset.fieldname;

        console.log(fieldname+' - '+value);

        switch(fieldname){
            case 'Country':
                this.handleCountryChange(value);
                break;
            case 'State':
                this.handleStateChange(value);
                break;
            case 'Street':
                this.thisStreet = value;
                //Possibly auto-validate
                break;
        }
    }

    suggestionSelected(event){
        let address = event.detail;
        //console.log(JSON.parse(JSON.stringify(suggestion)));

        if(address.street){
            this.thisStreet = address.street;
        }

        if(address.street){
            this.thisStreet = address.potalCode;
        }

    }

    /* Control */

    hideCities(){
        this.citiesListbox = false;
    }

    /* Address Doctor */
    validateAddress(){
        console.log('..validateAddress');
        this.showDoctor = true;
        this.template.querySelector('c-address-doctor-search').search();
    }

    /* Condition getters*/

    get hasStateOptions(){
        return this.stateOptions === undefined || this.stateOptions.length == 0;
    }

    get hasCityOptions(){
        return this.cityOptions === undefined || this.cityOptions.length == 0;
    }

    get hasCitySuggestion(){
        return this.citySuggestion !== undefined && this.citySuggestion.length > 0;
    }

    get showCitySuggestions(){
        return this.hasCitySuggestion && this.citiesListbox;
    }
}