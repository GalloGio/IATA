import { LightningElement, api, track, wire } from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import { fireEvent } from 'c/pubsub';
import getRegions from '@salesforce/apex/ADSRController.getRegions';

import PortalIcons from '@salesforce/resourceUrl/PortalIcons';


export default class AdsrSearchFilter extends LightningElement {

	@api searchForm;
	@api depFields;

	@track regionOptions = [];
	@track searchByOptions = [
		{ label: 'Operation', value: 'market', selected: true },
		{ label: 'Agent', value: 'agent' }
	];
	@track serviceOptions;

	activeSearchType = "market";
	defaultRegion = null;
	regionValue = null;
	agentValue = null;
	searchIcon = `${PortalIcons}#search_colored`;

	@wire(CurrentPageReference) pageRef;

    @wire(getRegions)
    loadRegionOptions({ error, data }) {
        if(data){
			this.regionOptions = data;
			let userRegion = this.regionOptions.filter(o => {return o.selected});
			this.regionValue = this.defaultRegion = userRegion && userRegion.length > 0 ? userRegion[0].value : null;
			if(this.defaultRegion) {
				this.search();
			}
			else {
				this.clearResults();
			}
        }
        else {
            this.regionOptions = [];
		}
		
		let localFields = JSON.parse(JSON.stringify(this.fields));
		localFields[0].dependent[0].options = this.regionOptions;
		this.fields = localFields;
	}

    handleChange(event) {
		if("type" === event.detail.name) {
			if(this.activeSearchType !== event.detail.value){
				this.activeSearchType = event.detail.value;
				this.regionValue = null;
				this.agentValue = null;	
				if("market" === this.activeSearchType && this.defaultRegion !== null) {
					this.regionValue = this.defaultRegion;
					this.search();
				}
				else {
					this.clearResults();
				}
			}
		}
		else if("region" === event.detail.name) {
			this.regionValue = event.detail.value;
			this.search(event);
		}
        else if("agent" === event.detail.name) {
			this.agentValue = event.detail.value;
			if(this.agentValue === null){
				this.clearResults();
			}
		}
	}

	handleClick(event) {
		if("search" === event.detail.name) {
			this.search(event);
		}
	}

    search(event) {
		fireEvent(this.pageRef,
			'updateSearchFilters',
			  {
				  type: this.activeSearchType,
				  region: this.regionValue,
				  agent: this.agentValue
			  });

	}

	clearResults() {
		fireEvent(this.pageRef,
			'clearResults', {type: this.activeSearchType});
	}
	
	handleReset(event) {
		this.template.querySelector("c-iata-dependent-picklist").setValue("type", null);
	}

    get disabledMarkets() {
		return this.marketOptions === undefined ||
				this.marketOptions === null ||
				this.marketOptions.length === 0 ||
				this.activeSearchType !== "market";
    }

    get disabledAgent() {
        return this.activeSearchType !== "agent";
	}

	get formContainerClass() {
		return "slds-var-p-bottom_small " +
			(this.disabledAgent ? "slds-border_bottom " : "");
	}

	@track
	fields = [
		{
			type: "radiogroup",
			variant: "tab",
			name: "type",
			label: "Search by",
			tabFullWidth: true,
			required: true,
			options: this.searchByOptions,
			padding: "bottom-small",
			class: "",
			dependent: [{
				dependency: "visibility",
				masterValue: "market",
				type: "radiogroup",
				hideLabel: true,
				displayHorizontal: true,
				alignLeft: true,
				name: "region",
				label: "Region",
				required: true,
				options: this.regionOptions,
				padding: "around-small",
				class: "text-small"
			},
			{
				dependency: "visibility",
				masterValue: "agent",
				type: "number",
				name: "agent",
				label: "Agent Code",
				step: 1,
				hideLabel: true,
				placeholder: "Find IATA Code",
				icon: this.searchIcon,
				iconStyling: "top: 1.4rem;",
				required: true,
				clearButton: true,
				colSize: 3,
				padding: "around-small",
				class: "slds-text-body_regular"
			},
			{
				dependency: "visibility",
				masterValue: "agent",
				type: "button",
				name: "search",
				label: "Search",
				variant: "contained",
				heightLarge: true,
				colSize: 3,
				padding: "around-small"
			}]
		}
	];

}