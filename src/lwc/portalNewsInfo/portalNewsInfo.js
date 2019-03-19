import { LightningElement, wire, track } from 'lwc';
import getBannerInformation from '@salesforce/apex/PortalNewsController.getBannerInformation';

export default class PortalNewsInfo extends LightningElement {
    @track loading = true;
    @track dataRecords = false;
    @track maxSize;
    @track showPagination;
    @track sliderIcons;
    page = 1;
    globaList = [];

    @wire(getBannerInformation)
    wiredNewsInfo(results) {
        this.loading = true;
        if (results.data) {            
            let auxResult = JSON.parse(JSON.stringify(results.data));

            if(auxResult.length > 0) {                
                this.dataRecords = true;

                for (let i = 0; i < auxResult.length; i++) {
                    this.globaList.push(auxResult[i].content);
                }
    
                this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[0];
                
                this.maxSize = this.globaList.length;
                this.showPagination = this.maxSize > 1 ? true : false;
                if (this.showPagination) {
                    this.sliderIconsRenderer();
                }
            } else {
                this.dataRecords = false;
            }
            this.loading = false;
        } else if (results.error) {
            this.error = results.error;
            this.loading = false;
        }
    }

    sliderIconsRenderer() {
        this.sliderIcons = [];
        for (let i = 0; i < this.maxSize; i++) {
            let vari = '';
            if (i === this.page - 1) {
                vari = 'warning';
            }
            this.sliderIcons.push({ variant: vari });
        }
    }
    
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[this.page - 1];
        }
        this.sliderIconsRenderer();
    }

    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
            this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[this.page - 1];
        }
        this.sliderIconsRenderer();
    }

    get dataRecords() {
        return this.dataRecords;
    }      
}