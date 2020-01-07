import { LightningElement, track, api} from 'lwc';

export default class portalPopupContainer extends LightningElement {

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

	}

	@track widthClass = 'customPopupInteriorHalfScreenCentered';
	
}