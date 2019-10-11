import { LightningElement, wire, track, api } from 'lwc';
import getCertifications from '@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications';
import getLocationsList from '@salesforce/apex/CW_LandingSearchBarController.getLocationsList';
import icons from '@salesforce/resourceUrl/icons';
import certImagesResource from "@salesforce/resourceUrl/Certification_Images";

export default class CwResultsPageSearchBar extends LightningElement {


    deletetag = icons + '/icons/ic-delete-tag.svg';
    plusopen = icons + '/icons/icon-plus.svg';
    minusclose = icons + '/icons/icon-minus.svg';
    locationwhite = icons + '/icons/ic-white-location.svg';


    CertifiedAirline = certImagesResource + '/UfW_CertifiedAirline.png';

    availableLocations;
    @track locationPredictiveValues = [];
    @track locationSearchValue = '';
    searchObjects = [];
    @api
    get initialSearch() {
        return this._initialSearch;
    }
    set initialSearch(values) {
        this._initialSearch = values;
        //Align URL Search parameter with search bar
        this.alignInitialSearch();
    }
    _initialSearch;

    @track certifications;
    @wire(getCertifications, {})
    wiredCertifications({ data }) {
        if (data) {
            this.certifications = data;
        }
        //window.setTimeout(.bind(this), 1000);
    }
    @wire(getLocationsList, {})
    wiredLocations({ data }) {
        if (data) {
            this.availableLocations = JSON.parse(data);
        }
    }

    onchangeFunction = function inputChange() {
        this.searchObjects = [];
        let inputs = this.template.querySelectorAll("input");
        for (let i = 0; i < inputs.length; i++) {
            let searchObj = {};
            if ((inputs[i].type === 'checkbox' && inputs[i].checked === true) || (inputs[i].type !== 'checkbox' && inputs[i].value !== '' && inputs[i].value !== undefined)) {
                searchObj.obj = inputs[i].getAttribute("data-obj");
                searchObj.field = inputs[i].getAttribute("data-field");
                searchObj.operator = inputs[i].getAttribute("data-operator");
                if (inputs[i].getAttribute("data-relationfield")) searchObj.relationfield = inputs[i].getAttribute("data-relationfield");
                searchObj.value = inputs[i].value;
                this.searchObjects.push(searchObj);
            }
        }
        const searchEvent = new CustomEvent('search', { detail: this.searchObjects });
        // Dispatches the event.
        this.dispatchEvent(searchEvent);
    }

    initialized = false;
    certificationsRendered = false;
    renderedCallback() {
        if (!this.certificationsRendered && this.certifications) {
            this.alignInitialSearch();
            this.certificationsRendered = true;
        }
        if (this.initialized === true) return;
        this.initialized = true;
        let coll = this.template.querySelectorAll(".collapsible");
        let inputs = this.template.querySelectorAll("input");

        for (let i = 0; i < coll.length; i++) {
            coll[i].addEventListener("click", function() {
                this.classList.toggle("active");
                let content = this.nextElementSibling;
                let imgchild = this.querySelector("img");
                if (content.style.maxHeight) {
                    imgchild.src = icons + '/icons/icon-plus.svg';
                    content.style.maxHeight = null;
                } else {
                    imgchild.src = icons + '/icons/icon-minus.svg';
                    content.style.maxHeight = "100%";
                }
            });
        }

        for (let i = 0; i < inputs.length; i++) {
            //console.log(inputs[i]);
            inputs[i].addEventListener("change", this.onchangeFunction.bind(this));
        }

        //Align datalist for predictive results with inputs.
        //This code is performed to avoid the id changes that LWC makes to elements.
        let listId = this.template.querySelector('datalist').id;
        this.template.querySelector("input[data-field='City__c'").setAttribute("list", listId);

    }

    predictiveSearch(event) {
        this.locationPredictiveValues = [];
        this.locationSearchValue = event.target.value;
        if (!event.target.value || event.target.value.length < 3) {
            return;
        }

        for (let loc in this.availableLocations) {
            // skip loop if the property is from prototype
            if (!this.availableLocations.hasOwnProperty(loc)) continue;
            this.locationPredictiveValues.push({ key: loc, value: this.availableLocations[loc] });

        }
    }

    alignInitialSearch() {
        if (this._initialSearch) {
            let inputs = this.template.querySelectorAll("input");
            let parsedValues = this._initialSearch;
            parsedValues.forEach(function(elem) {
                for (let i = 0; i < inputs.length; i++) {
                    if (inputs[i].getAttribute("data-obj") === elem.obj && inputs[i].getAttribute("data-field") === elem.field && inputs[i].getAttribute("data-operator") === elem.operator) {
                        if (inputs[i].type === 'checkbox' && inputs[i].value === elem.value) {
                            inputs[i].checked = true;
                        } else if (inputs[i].type !== 'checkbox') {
                            inputs[i].value = elem.value;
                        }
                    }

                }
            });
        }
    }

}