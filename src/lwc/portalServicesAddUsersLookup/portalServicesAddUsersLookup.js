/**
 * Created by pvavruska on 7/15/2019.
   Used to search & add user records to portal services

 */
import { LightningElement, track, api } from 'lwc';

import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';
import add from '@salesforce/label/c.Button_Add';
import addAll from '@salesforce/label/c.CSP_Add_All';


const MINIMAL_SEARCH_TERM_LENGTH = 3; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search



export default class PortalServicesAddUsersLookup extends LightningElement {

    @track label = {
        CSP_NoSearchResults,add,addAll
    }

    @api selection = [];
    @api allToAdd = [];
    @api placeholder = '';
    @api isMultiEntry = false;
    @api errors = [];
    @api scrollAfterNItems;
    @api itemName;

    @track searchFlag = false;
    @track searchTerm = '';
    @track searchResults = [];
    @track hasFocus = false;
    @track getContainerClass;
    @track checkedIds = [];

    cleanSearchTerm;
    blurTimeout;
    searchThrottlingTimeout;

    // EXPOSED FUNCTIONS

    @api
    get isSearching(){
        return this.searchFlag;
    }

    set isSearching(value){
        this.searchFlag = value;
    }

    @api
    setSearchResults(results) {
        this.searchFlag = false;
        let checkedIds = this.checkedIds;

        this.searchResults = results.map(result => {
            if (typeof result.icon === 'undefined') {
                result.icon = 'standard:default';
            }

            if(checkedIds.indexOf(result.id) >= 0){
                result.checked = true;
            }

            return result;
        });
    }

    @api
    getSelection() {
        return this.selection;
    }

    @api
        getSearchResults() {
            return this.searchResults;
        }

    @api
    get requiredClass() {
        return this.getContainerClass;
    }
    set requiredClass(value) {
            this.getContainerClass = 'slds-combobox_container customborder squareShadow slds-has-inline-listbox squareBorder slds-p-around_small ';
    }

    @api
    get singleLookupResult() {
        return this.selection;
    }
    set singleLookupResult(result) {

        if (result !== undefined) {
            let ui = JSON.parse(JSON.stringify(result));
            if (ui.length > 0) {
                if (JSON.parse(JSON.stringify(result))[0].title === this.label.CSP_NoSearchResults) {
                    let newSelection = [...this.selection];
                    newSelection.push({ title: this.label.CSP_NoSearchResults, value: '' });
                    this.selection = newSelection;
                } else {
                    let newSelection = [...this.selection];
                    newSelection.push(JSON.parse(JSON.stringify(result))[0]);
                    this.selection = newSelection;
                }
            }
        }
    }

    renderedCallback() {
        if (this.selection.length === 1 && this.selection[0].title === this.label.CSP_NoSearchResults) {
            let mod = this.template.querySelector('input');
            mod.setAttribute('disabled', 'true');
        }
    }


    // INTERNAL FUNCTIONS

    updateSearchTerm(newSearchTerm) {
        this.searchTerm = newSearchTerm;

        // Compare clean new search term with current one and abort if identical
        const newCleanSearchTerm = newSearchTerm.trim().replace(/\*/g, '').toLowerCase();
        if (this.cleanSearchTerm === newCleanSearchTerm) {
            return;
        }

        // Save clean search term
        this.cleanSearchTerm = newCleanSearchTerm;

        // Ignore search terms that are too small
        if (newCleanSearchTerm.length < MINIMAL_SEARCH_TERM_LENGTH) {
            this.searchResults = [];
            return;
        }

        // Apply search throttling (prevents search if user is still typing)
        if (this.searchThrottlingTimeout) {
            clearTimeout(this.searchThrottlingTimeout);
        }
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.searchThrottlingTimeout = setTimeout(() => {
            // Send search event if search term is long enougth
            if (this.cleanSearchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH) {
                this.searchFlag = true;
                const searchEvent = new CustomEvent('search', {
                    detail: {
                        searchTerm: this.cleanSearchTerm,
                        selectedIds: this.selection.map(element => element.id)
                    }
                });
                this.dispatchEvent(searchEvent);
            }
            this.searchThrottlingTimeout = null;
        },
            SEARCH_DELAY
        );
    }

    isSelectionAllowed() {
        if (this.isMultiEntry) {
            return true;
        }
        return !this.hasSelection();
    }

    get hasResults() {
    }

    get hasNoResults(){
        let invalidSearch = this.searchTerm.length < MINIMAL_SEARCH_TERM_LENGTH;
        let resultsValid = this.searchResults !== undefined && this.searchResults.length > 0

        return !invalidSearch && !this.searchFlag && !resultsValid;
    }

    hasSelection() {
        return this.selection.length > 0;
    }


    // EVENT HANDLING

    handleInput(event) {
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.updateSearchTerm(event.target.value);
    }

    handleResultClick(event) {
        const recordId = event.currentTarget.dataset.recordid;

        let searchResults = JSON.parse(JSON.stringify(this.searchResults));
        let checkedIds = [];

        for(let i=0;i<searchResults.length;i++){
            let current = searchResults[i];

            let isChecked = searchResults[i].checked;

            if(current.id === recordId){
                if(isChecked){
                    searchResults[i].checked = false;
                }else{
                    searchResults[i].checked = true;
                }
            }else{
                searchResults[i].checked = isChecked;
            }

            if(searchResults[i].checked){
                checkedIds.push(searchResults[i].id);
            }
        }

        this.searchResults = searchResults;
        this.checkedIds = checkedIds;

        /*
        if (selectedItem.length === 0) {
            return;
        }
        selectedItem = selectedItem[0];
        const newSelection = [...this.selection];
        newSelection.push(selectedItem);
        let savepoint = this.selection;
        this.selection = newSelection;

        // Reset search
        this.searchTerm = '';
        this.searchResults = [];

        if (this.itemName === 'contactlookup') {
            this.dispatchEvent(new CustomEvent('selectionchange'));
        }*/
    }

    handleAddAll(){
        this.selection = this.searchResults;
        this.dispatchEvent(new CustomEvent('addall'));

    }

    handleAdd(){
        let results = JSON.parse(JSON.stringify(this.searchResults));
        let selectedIds = this.checkedIds;

        let filtered = results.filter(item => selectedIds.indexOf(item.id) > -1);

        this.selection = filtered;

        if(filtered !== undefined && filtered.length > 0){
            this.dispatchEvent(new CustomEvent('selectionchange'));
        }

        this.handleBlur();
    }

    handleComboboxClick() {
        if (this.blurTimeout) {
            window.clearTimeout(this.blurTimeout);
        }
    }

    handleFocus() {
        // Prevent action if selection is not allowed
        this.dispatchEvent(new CustomEvent(this.itemName));

        if (!this.isSelectionAllowed()) {
            return;
        }
        this.hasFocus = true;
    }

    handleBlur() {
        // Delay hiding combobox so that we can capture selected result
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = window.setTimeout(() => {
            this.checkedIds = [];
            this.hasFocus = false;
            this.blurTimeout = null;
        },
            300
        );
    }

    handleRemoveSelectedItem(event) {
        const recordId = event.currentTarget.name;
        this.selection = this.selection.filter(item => item.id !== recordId);
        // Notify parent components that selection has changed
        //this.dispatchEvent(new CustomEvent('selectionchange'));
    }

    handleClearSelection(event) {
        this.selection = [];

        if (event.target.value.length > 0) {
            this.searchFlag  = true;
            const searchEvent = new CustomEvent('search', {
                detail: {
                    searchTerm: this.searchTerm,
                    selectedIds: this.selection.map(element => element.id)
                }
            });
            this.dispatchEvent(searchEvent);
        }else{
            const searchEvent = new CustomEvent('search', {
                detail: {
                    searchTerm: this.cleanSearchTerm,
                    selectedIds: this.selection.map(element => element.id)
                }
            });
            this.dispatchEvent(searchEvent);
        }
    }


    // STYLE EXPRESSIONS

    get getContainerClass() {
        let css = 'slds-combobox_container squareShadow slds-has-inline-listbox squareBorder slds-p-around_small ';
        if (this.hasFocus) {
            css += 'slds-has-input-focus ';
        }
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        }
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        if (this.hasFocus) {
            css += 'slds-is-open';
        } else {
            css += 'slds-combobox-lookup';
        }
        return css;
    }

    get getInputClass() {
        let css = 'slds-input slds-combobox__input no-boxshadow customborder has-custom-height hideInputLabel borderlessInput newRecipientTextInput  '
            + (this.errors.length === 0 ? '' : 'has-custom-error ');
        if (!this.isMultiEntry) {
            css += 'slds-combobox__input-value '
                + (this.hasSelection() ? 'has-custom-border' : '');
        }
        return css;
    }

    get getComboboxClass() {
        let css = 'slds-combobox__form-element';
        return css;
    }

    get getSearchIconClass() {
        let css = 'slds-input__icon slds-input__icon_right ';
        if (!this.isMultiEntry) {
            css += (this.hasSelection() ? 'slds-hide' : '');
        }

        return css;
    }

    get getClearSelectionButtonClass() {
        return 'slds-button slds-button_icon slds-input__icon slds-input__icon_right '
            + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getSelectIconName() {
        return this.hasSelection() ? this.selection[0].icon : 'standard:default';
    }

    get getSelectIconClass() {
        return 'slds-combobox__input-entity-icon '
            + (this.hasSelection() ? '' : 'slds-hide');
    }

    get getInputValue() {
        return this.searchTerm;
    }

    get getListboxClass() {
        return 'contactListbox slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid customMaxHeight slds-scrollable_y '
            + (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '');
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }

    get isExpanded() {
        return this.hasSearchTerm;
    }

    get hasSearchTerm(){
        return this.searchTerm !== undefined && this.searchTerm.length >= MINIMAL_SEARCH_TERM_LENGTH;
    }

    get cantAdd(){
        let cantAdd = this.checkedIds === undefined || this.checkedIds.length === 0;//this.searchResults === undefined || this.searchResults.length == 0 || !this.hasFocus;
        return cantAdd;
    }

    get cantAddAll(){
        return this.searchResults === undefined || this.searchResults.length == 0 || !this.hasFocus;
    }
}