import { LightningElement, track, api } from 'lwc';

import CSP_NoSearchResults from '@salesforce/label/c.CSP_NoSearchResults';

const MINIMAL_SEARCH_TERM_LENGTH = 3; // Min number of chars required to search
const SEARCH_DELAY = 300; // Wait 300 ms after user stops typing then, peform search

export default class Lookup extends LightningElement {

    @track label = {
        CSP_NoSearchResults
    }

    @api selection = [];
    @api placeholder = '';
    @api isMultiEntry = false;
    @api 
    get hideIcon(){
        return this._hideIcon;
    } 
    set hideIcon(val){
        this._hideIcon=val;
    } 
    @api errors = [];
    @api scrollAfterNItems;
    @api itemName;

    @track searchTerm = '';
    @track searchResults = [];
    @track hasFocus = false;
    @track getContainerClass;
    @track _hideIcon=false;

    cleanSearchTerm;
    blurTimeout;
    searchThrottlingTimeout;

    // EXPOSED FUNCTIONS

    @api
    setSearchResults(results, scrollBottom) {
        this.searchResults = results.map(result => {
            if (typeof result.icon === 'undefined') {
                result.icon = 'standard:default';
            }
            return result;
		});
		if(scrollBottom){
			let scrollobjective = this.template.querySelector('[data-id="scrollContainer"]');
			scrollobjective.scrollIntoView({ behavior: 'smooth', block:'end' });
		}
    }

    @api
    getSelection() {
        return this.selection;
    }

    @api
    get requiredClass() {
        return this.getContainerClass;
    }
    set requiredClass(value) {
        if (this.itemName === 'iatalookup') {
            this.getContainerClass = 'slds-combobox_container customborder squareShadow slds-has-inline-listbox squareBorder slds-p-around_small ' + value;
        }
        else {
            this.getContainerClass = 'slds-combobox_container customborder squareShadow slds-has-inline-listbox squareBorder slds-p-around_small ';
        }
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

    hasResults() {
        return this.searchResults.length > 0;
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
        // Save selection
        let selectedItem = this.searchResults.filter(result => result.id === recordId);
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

        // Notify parent component that selection has changed **Email Only**
        if (this.itemName === 'emaillookup' || this.itemName === 'servicesearch') {
            this.dispatchEvent(new CustomEvent('selectionchange'));
            this.selection = savepoint;
        }
    }

    handleComboboxClick() {
        // Hide combobox immediatly
        if (this.blurTimeout) {
            window.clearTimeout(this.blurTimeout);
        }
        this.hasFocus = false;
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
        // Prevent action if selection is not allowed
        if (!this.isSelectionAllowed()) {
            return;
        }
        this.searchTerm = '';
        // Delay hiding combobox so that we can capture selected result
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.blurTimeout = window.setTimeout(() => {
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

    handleClearSelection() {
        this.selection = [];
        // Notify parent components that selection has changed
        //this.dispatchEvent(new CustomEvent('selectionchange'));


        this.handleFocus();

    }


    // STYLE EXPRESSIONS

    get getContainerClass() {
        let css = 'slds-combobox_container squareShadow slds-has-inline-listbox squareBorder slds-p-around_small ';
        if (this.hasFocus && this.hasResults()) {
            css += 'slds-has-input-focus ';
        }
        if (this.errors.length > 0) {
            css += 'has-custom-error';
        }
        return css;
    }

    get getDropdownClass() {
        let css = 'slds-combobox slds-dropdown-trigger slds-dropdown-trigger_click ';
        if (this.hasFocus && this.hasResults()) {
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
        let css = 'slds-combobox__form-element slds-input-has-icon ';
        if (this.isMultiEntry) {
            css += 'slds-input-has-icon_right';
        } else {
            css += (this.hasSelection() ? 'slds-input-has-icon_left-right' : 'slds-input-has-icon_right');
        }
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
        if (this.isMultiEntry) {
            return this.searchTerm;
        }
        return this.hasSelection() ? this.selection[0].title : this.searchTerm;
    }

    get getListboxClass() {
        return 'slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid slds-p-around_small customMaxHeight slds-scrollable_y '
            + (this.scrollAfterNItems ? 'slds-dropdown_length-with-icon-' + this.scrollAfterNItems : '');
    }

    get isInputReadonly() {
        if (this.isMultiEntry) {
            return false;
        }
        return this.hasSelection();
    }

    get isExpanded() {
        return this.hasResults();
    }
}