import { LightningElement, api, track } from 'lwc';

export default class PillFilters extends LightningElement {
	@api value;
	@api fullColumn = false;
	@api dropdownStyle = false;
	@api collapsible = false;
	@track _showAll = false;
    h1 = 0;
    h2 = 0;
    connectedCallback() {
    }

	renderedCallback() {
        this.reloadContentSize();
	}

	removePill(e){
		let currentValue = e.target.dataset.value;
		let selected = JSON.parse(JSON.stringify(this.value));
		let newSelected = [];
		selected.forEach(item => {
			if(item.value !== currentValue){
				newSelected.push(item);
			}
		});
		this.value = newSelected;
        this.reloadContentSize();
		this.dispatchEvent(
			new CustomEvent("change", {"value" : this.value})
		);
	}

	toggleShowAll(e) {
        this._showAll = !this._showAll;
	}

	get pillsBlockContainerClass() {
		return "slds-size_full slds-scrollable_none "
				+ (this.collapsible ? "slds-is-absolute " : "")
                + (this.collapsible && this._showAll ?
                    " open-container" :
                    " collapsed-container");
	}

	get pillsBlockClass() {
		return "slds-float_left slds-grid slds-wrap slds-is-relative"
			+ (!this.collapsible ?
				"  slds-var-p-top_small" :
				(this.fullColumn ? 
					(
						((!this.dropdownStyle && !this._showAll) || this.dropdownStyle ?
							" slds-var-m-right_xx-large slds-var-p-right_x-large"
							: " slds-var-p-right_medium")
						+ " slds-var-p-vertical_x-small slds-var-p-left_x-small"
					) :
                    " slds-var-p-around_x-small")
					+ (this._showAll ?
						(this.dropdownStyle ? 
							" slds-dropdown" :
							"") +
						(this.fullColumn ?
							" slds-size_full" :
							" slds-var-m-top_large") :
							this.fullColumn ? 
								"" :
								" slds-var-m-top_medium"));
	}

	get buttonClass() {
		return "slds-float_right slds-is-absolute slds-var-p-right_small slds-is-sorted slds-is-sorted_"
                + (this._showAll ?
                    "asc" :
                    "desc");
	}


	get buttonLabel() {
		return this._showAll ? "Close" : "Show all"; 
	}

    getContainerHeight() {
        let div = this.template.querySelector('div.slds-size_full');
        return div ? div.offsetHeight : 0;
    }

    getPillsBlockHeight() {
        let div = this.template.querySelector('div.slds-float_left');
        return div ? div.offsetHeight : 0;
    }

    reloadContentSize() {
        this.h1 = this.getContainerHeight();
        this.h2 = this.getPillsBlockHeight();
    }

    get displayButton() {
		return this.collapsible && 
				( this.h2 > this.h1 || this._showAll );
    }
}