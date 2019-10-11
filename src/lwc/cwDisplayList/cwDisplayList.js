import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import CHECKED_IMAGE from '@salesforce/resourceUrl/ic_tic_green';
import UNCHECKED_IMAGE from '@salesforce/resourceUrl/ic_tic_grey';
var allRows;

export default class CwDisplayList extends LightningElement {

    @api input;
    @api title;
    @api falicityData;
    showMoreNumber;
    textMoreNumber;
    @track rows;
    // allRows;
    showAllList;
    @track expandedList = false;
    isRenderCallbackActionExecuted = false;

    checkedImage = CHECKED_IMAGE;
    uncheckedImage = UNCHECKED_IMAGE;

    renderedCallback() {
        if (this.isRenderCallbackActionExecuted) {
            return;
        }
        this.isRenderCallbackActionExecuted = true;

        Promise.all([
                // loadScript(this, DDDD + '/DDDD.example.js'),
                // loadStyle(this, DDDD + '/style.css'),
            ]).then(() => {
                allRows = this.input;
                this.handleInput();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading page',
                        message: error.message,
                        variant: 'error',
                    }),
                );
            });
    }

    handleInput() {
        // eslint-disable-next-line no-console
        console.log(':::::::handleInput - input stringified ' + JSON.stringify(this.input));
        if(allRows !== null && allRows !== undefined){
            if (allRows.length > 6) {
                this.rows = this.expandedList === false ? this.getNFromList(allRows, 6) : allRows;
    
                this.textMoreNumber = allRows.length - 6;
                this.textMoreNumber = '+' + this.textMoreNumber;
                this.showMoreNumber = true;
    
            } else {
                this.rows = allRows;
                this.showMoreNumber = false;
            }
        }
    }

    handleCicleAction() {
        this.expandedList = !this.expandedList;
        this.isRenderCallbackActionExecuted = false;
        // this.handleInput();
    }
    getNFromList(list, number) {
        return list.slice(0, number);
    }

    get facilityDataGeneralCargo (){
        let result = JSON.parse(JSON.stringify(this.falicityData));
        return result.generalCargo;
    }
    get facilityDataDangerousGood (){
        let result = JSON.parse(JSON.stringify(this.falicityData));
        return result.dangerousGoods;
    }
    get facilityDataLifeAnimals (){
        let result = JSON.parse(JSON.stringify(this.falicityData));
        return result.lifeAnimals;
    }
    get facilityDataPharmaceuticals (){
        let result = JSON.parse(JSON.stringify(this.falicityData));
        return result.pharmaceuticals;
    }
    get facilityDataPerishables (){
        let result = JSON.parse(JSON.stringify(this.falicityData));
        return result.perishables;
    }
    get facilityDataAermail(){
        let result = JSON.parse(JSON.stringify(this.falicityData));
        return result.aermail;
    }
}