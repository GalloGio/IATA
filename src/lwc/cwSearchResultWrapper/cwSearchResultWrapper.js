import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import icons from '@salesforce/resourceUrl/icons';

export default class CwSearchResultWrapper extends LightningElement {
    
    airline = icons + '/icons/company_type/airline.svg'; 
    airportoperator = icons + '/icons/company_type/airport-operator.svg'; 
    freight = icons + '/icons/company_type/freight-forwarder.svg'; 
    trucker = icons + '/icons/company_type/trucker.svg'; 
    cargohandling = icons + '/icons/company_type/Cargo-Handling-Facility.svg'; 
    shipper = icons + '/icons/company_type/shipper.svg'; 
    ramphandler = icons + '/icons/company_type/ramp-handler.svg'; 

    share = icons + '/icons/icon_share.svg'; 
    print = icons + '/icons/icon_print.svg'; 


    @track stringResponse;
    @track selectedOne;
    @api lstResults;

    renderedCallback() {
        Promise.all([
                // loadScript(this, DDDD + '/DDDD.example.js'),
                // loadStyle(this, DDDD + '/style.css'),
            ]).then(() => {
                // TODO - will come from google maps´ event
                this.selectedOne = this.lstResults && this.lstResults.length > 0 ? this.lstResults[0] : null;
                
            })
            /*
            .catch(error => {
                
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading static resources',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });*/

    }
    Obj = function(name) {
        this.name = name;
    }
}