/**
 * Created by pvavruska on 8/7/2019.
 */

import { LightningElement,track,wire,api } from 'lwc';
import getISOCountries from '@salesforce/apex/GCS_RegistrationController.getISOCountries'; /* Will be passed from parent*/
import getCountryStates from '@salesforce/apex/GCS_AccountCreation.getStates';

export default class PortalRegistrationAccountCreation extends LightningElement {

    @track showPageMessage = false;
    @track showCreateAccount = true;

    @api legalName;
    @api selectedCountryId;
    @api isoCountries;
    @api customerType;
    @api accountName;


    // Account data
    website;
    newAccount = {};

    //Address data
    @track accountFields = [];

    //Country data
    countryData;
    stateData;
    @track countryOptions;
    @track stateOptions;
    @track cityOptions;

    renderedCallback(){
        let scrollobjective = this.template.querySelector('[data-name="accCreationWrapper"]');
        scrollobjective.scrollIntoView({ behavior: 'smooth' });
    }

    connectedCallback() {

        console.log(this.selectedCountryId);
        console.log(this.isoCountries);
        console.log(this.customerType);
        console.log(this.accountName);

        getISOCountries().then(result=>{
            //console.log(JSON.stringify(result));

            let dataList = JSON.parse(JSON.stringify(result.countryList));
            let optionList = [];

            optionList.push({ 'label': '', 'value': '' });

            dataList.forEach(function (data) {
                optionList.push({ 'label': data.Name, 'value': data.Id });
            });

            this.countryData = result;
            this.countryOptions = optionList;

            this.stateOptions = [{ 'label': '', 'value': '' }];
        });

        let fields =  [
            {"fieldName":"Legal_name__c","isText":true,"label":"LegalName","value":null,"required":true},
            {"fieldName":"TradeName__c","isText":true,"label":"Trade Name","value":null,"required":false},
            {"fieldName":"BusinessAddress","isAddress":true,"label":"Business Address","value":null,"required":false},
            {"fieldName":"Phone","isText":true,"label":"Phone","value":null,"required":true},
            {"fieldName":"Website","isText":true,"label":"Website","value":null,"required":false},
            {"fieldName":"Email","isText":true,"label":"Email","value":null,"required":false}
            ];

            let addressFields = [
            {"fieldName":"Country","isCountry":true,"label":"Country","value":null,"required":true,"options":this.countryOptions},
            {"fieldName":"State","isState":true,"label":"State","value":null,"required":true,"options":this.stateOptions},
            {"fieldName":"City","isCity":true,"label":"City","value":null,"required":true},
            {"fieldName":"Street","isStreet":true,"label":"Street","value":null,"required":true},
            {"fieldName":"Zip","isZip":true,"label":"Zip","value":null,"required":true}
            ];

        fields.forEach(function (field) {
            field.spacerKey = field.fieldName + '_spacer';

            if(field.isAddress){
                field.value = addressFields;
            }
        });

        this.accountFields = fields;
    }

    validate(){
        this.accountFields.forEach(function (field) {
            if(field.value){
                console.log(field.fieldName+' - '+JSON.stringify(field.value));
            }
        });
    }

    handleFieldChange(event){
        let value = event.target.value;
        let dataId = event.target.dataset.id;
        let address = event.target.dataset.address;
        let addressFieldName = event.target.dataset.addressfield;

        /*console.log(value);
        console.log(address);
        console.log(JSON.stringify(dataId));*/

        let countryChanged = false;

        if(value !== undefined && dataId !== undefined){
            let fields = JSON.parse(JSON.stringify(this.accountFields));

            fields.forEach(function (field) {
                if(field.fieldName == dataId){

                    //Address fields
                    if(address && field.value){
                        let addressFields = field.value;
                        addressFields.forEach(function (addressField) {
                            if(addressField.fieldName == addressFieldName){
                                addressField.value = value;

                                if(addressField.isCountry){
                                    countryChanged = true;
                                }

                            }
                        });

                    }else{
                        field.value = value;
                    }
                }
             });

             if(countryChanged){
                 this.handleCountryChange(value);
             }

             this.accountFields = fields;
        }
    }


    handleCountryChange(countryId){
        let country = this.countryData.countryMap[countryId];

        if(country === undefined || country.Region_Province_and_Cities_Enabled__c == false){
            return;
        }

        getCountryStates({"country":country.Name}).then(result =>{
            console.log(JSON.stringify(result));

            let states = JSON.parse(JSON.stringify(result.states));
            let optionList = [];
            let cityOptions = []

            optionList.push({ 'label': '', 'value': '' });

            states.forEach(function (data) {
                optionList.push({ 'label': data.Name, 'value': data.Id });
                if(data.IATA_ISO_Cities__r !== undefined){
                    cityOptions = data.IATA_ISO_Cities__r;
                }
            });

            this.stateData = result;
            this.stateOptions = optionList;
            this.cityOptions = cityOptions;

        });

    }

    handleCityChange(){
        //if country selected, state data is known, try to find by city, set state
    }

    handleCityKey(event){
        let stateData = this.stateData;
        let value = event.target.value;
        let dataId = event.target.dataset.id;
        let address = event.target.dataset.address;
        let addressFieldName = event.target.dataset.addressfield;

        let cityOptions = [];

        /*
        2 scenarios:
         - state is selected, then filter from that state
         - state not selected - filter all states
        */

        if(stateData !== undefined && stateData.states !== undefined){
            let optionList = [];

            stateData.states.forEach(function (state) {
                if(state.IATA_ISO_Cities__r !== undefined){
                    cityOptions = state.IATA_ISO_Cities__r;
                }

                //optionList.push({ 'label': data.Name, 'value': data.Id });
            });
        }
    }


}