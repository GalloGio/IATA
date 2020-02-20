import { LightningElement, wire, track } from 'lwc';
import getBannerInformation from '@salesforce/apex/PortalNewsController.getBannerInformation';
import CSP_ForYou from '@salesforce/label/c.CSP_ForYou';


export default class PortalNewsInfo extends LightningElement {
    label = {
        CSP_ForYou
    };    
    @track loading = true;
    @track dataRecords = false;
    @track maxSize;
    @track showPagination;
    @track sliderIcons;
	@track isForRefreshTimer = false;
    @track refreshTimer;
    page = 1;
    globaList = [];
    banners = [];

    @wire(getBannerInformation)
    wiredNewsInfo(results) {
        this.loading = true;
        if (results.data) {            
            let auxResult = JSON.parse(JSON.stringify(results.data));            
            if(auxResult.length > 0) {                
                this.dataRecords = true;
                let urlTarget;

                for (let i = 0; i < auxResult.length; i++) {
                    this.globaList.push(auxResult[i].content);
                    
                    if(auxResult[i].bannerItem.Background_image_url_link__c !== undefined) {
                        urlTarget = auxResult[i].bannerItem.Background_image_url_link_target__c !== undefined ? auxResult[i].bannerItem.Background_image_url_link_target__c : '';
                        this.banners[auxResult[i].content] = auxResult[i].bannerItem.Background_image_url_link__c + ',' + urlTarget;
                    }
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
		
		// eslint-disable-next-line @lwc/lwc/no-async-operation
            this.refreshTimer = window.setInterval(() => {
                this.handleNext();
            }, 10000);
    }

    sliderIconsRenderer() {
        this.sliderIcons = [];
        let className = '';
        for (let i = 0; i < this.maxSize; i++) {
            className = 'slideIcon';
            if (i === this.page - 1) {
                className = 'currentSlideIcon';
            }
            this.sliderIcons.push({ className });
        }
    }
	
	handlePreviousPage() {
        this.isForRefreshTimer = true;
        this.handlePrevious();
    }

    handleNextPage() {
        this.isForRefreshTimer = true;
        this.handleNext();
    }
    
    handlePrevious() {
        if (this.page > 1) {
            this.page = this.page - 1;
            this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[this.page - 1];
        } else {
            this.page = this.maxSize;
            this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[this.page - 1];
        }
		
		if (this.isForRefreshTimer) {
            clearInterval(this.refreshTimer);
            this.isForRefreshTimer = false;
        }

        this.sliderIconsRenderer();
    }

    handleNext() {
        if (this.page < this.maxSize) {
            this.page = this.page + 1;
            this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[this.page - 1];
        } else {
            this.page = 1;
            this.bannerImages = '/sfc/servlet.shepherd/version/download/' + this.globaList[this.page - 1];
        }
		
		 if (this.isForRefreshTimer) {
            clearInterval(this.refreshTimer);
            this.isForRefreshTimer = false;
        }

        this.sliderIconsRenderer();
    }

    redirectUrl() {        
        let url = this.banners[this.globaList[this.page - 1]];
        
        if(url.substring(url.length, url.lastIndexOf(",")).substr(1)) {
            window.open(url.substring(0, url.indexOf(",")), url.substring(url.length, url.lastIndexOf(",")).substr(1));
        } else {
            window.open(url.substring(0, url.indexOf(",")));
        }
    }

    get dataRecords() {
        return this.dataRecords;
    }      
}