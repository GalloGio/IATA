import { LightningElement, api, wire, track } from 'lwc';
import { util, resources } from 'c/igUtility';
import { label } from 'c/igLabels';

export default class IgStationGapAnalysisSelector extends LightningElement {
	@track label = label;
	
	resources = resources; 
	
	@api station;
	@api goBackLabel = 'Change station';
	@api isGoBackVisible = false;
	@api get complianceReviewList() {
		return this._complianceReviewList;
	}
	set complianceReviewList(value) {
		if (value && value.length > 0) {
			this._complianceReviewList = value.map(el => ({
				selected: el.id === value[0].id,
				data: el
			}));
			this.selectVariation(value[0].id);
		}
	}

	@track _complianceReviewList;
	@track complianceReviewListComboOpened = false;

	toggleComboboxVisibility() {
		this.complianceReviewListComboOpened = !this.complianceReviewListComboOpened;
	}

	get selectorComboContainerClass() {
		return 'combo-container' + (this.complianceReviewListComboOpened ? ' combo-opened' : '');
	}

	variationClickHandler(event) {
		const variationId = event.target.closest('.combo-item').dataset.id;
		this.complianceReviewListComboOpened = false;
		this.selectVariation(variationId);
	}

	goBackClickHandler(event) {
		this.dispatchEvent(new CustomEvent('back'));
	}

	selectVariation(id) {
		this._complianceReviewList.forEach(variation => variation.selected = variation.data.id === id);
		this.dispatchEvent(new CustomEvent('change', {
			detail: {
				gapAnalysisId: id
			}
		}));
	}

	get areMultipleVariations() {
		return this.complianceReviewList && this.complianceReviewList.length > 1;
	}
	get foldIconClass() {
		return 'fold-icon' + (this.areMultipleVariations ? '' : ' slds-hide');
	}
}