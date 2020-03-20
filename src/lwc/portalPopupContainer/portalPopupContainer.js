import { LightningElement, track, api} from 'lwc';

export default class portalPopupContainer extends LightningElement {

	@api
	get viewFooter(){
		return this.viewFooterDiv;
	}
	set viewFooter(value){
		if(value !== undefined){
			this.viewFooterDiv = value;
		}
	}

	@track viewFooterDiv = true;

    @api
    get size() {
        return this.widthClass;
	}
	set size(value) {

		if(value === 'half'){
			this.widthClass = 'customPopupInteriorHalfScreenCentered';
		}
		if(value === 'threeQuarters'){
			this.widthClass = 'customPopupInteriorThreeQuartersScreenCentered';
		}
		if(value === '90'){
			this.widthClass = 'customPopupInteriorNinetyScreenCentered';
		}

	}

	@track widthClass = 'customPopupInteriorHalfScreenCentered';

	@api
    get modalType() {
        return this.modalTypeClass;
	}
	set modalType(value) {

		if(value === 'normal'){
			this.modalTypeClass = 'modal';
		}
		if(value === 'narrowTop'){
			this.modalTypeClass = 'modalNarrowTopMargin';
		}

	}

	@track modalTypeClass = 'modal';
	
}