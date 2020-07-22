import { LightningElement, wire, track, api } from 'lwc';
import getCertifications from "@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import {
    checkIfDeselectAll,
    checkIfChangeSelectAllText
} from 'c/cwUtilities';


export default class CwValidationPrograms extends LightningElement {
    @track selectedText = 'Select All';
    @api label;
    icons = resources + "/icons/";
    //icons
    tickSelection = this.icons + "ic-gsearch--selected.svg";
    
    @track certifications;
    @wire(getCertifications, {})
    wiredCertifications({ data }) {
        if (data) {
            this.certifications = JSON.parse(JSON.stringify(data));
        }
    }


    onClickItem(event) {
        let eTarget = event.currentTarget;
        let name = eTarget.getAttribute("data-name");

        let selectedProgram;
        let selected;

        this.certifications.forEach(element => {
            if (element.Name === name) {
                element.selected = !element.selected;
                selectedProgram = [element];
                selected = element.selected;
            }
        });

        let items = this.template.querySelectorAll("[data-name='" + name + "']");

        if(selected){
            this._selectItems(items);
        }
        else{
            this._unselectItems(items);
        }

        this.selectedText = checkIfChangeSelectAllText(this.certifications);


        this.dispatchEvent(new CustomEvent('selectvalidationprograms', { detail: selectedProgram }));
    }

    selectAllCertifications() {

        let shouldDeselectAll = checkIfDeselectAll(this.certifications);
        let allPrograms = [];

        this.certifications.forEach(element => {
            element.selected = !shouldDeselectAll;
            allPrograms.push(element);
        });

        let items = this.template.querySelectorAll("[data-type='certification']");
        if(shouldDeselectAll){
            this._unselectItems(items);
        }
        else {
            this._selectItems(items);
        }

        this.selectedText = checkIfChangeSelectAllText(this.certifications);

        this.dispatchEvent(new CustomEvent('selectvalidationprograms', { detail: allPrograms }));
    }

    _selectItems(items) {
        items.forEach(element => {
            element.classList.remove('itemUnselected');
            element.classList.add('itemSelected');
        });
    }

    _unselectItems(items){
        items.forEach(element => {
            element.classList.remove('itemSelected');
            element.classList.add('itemUnselected');
        });
    }
}