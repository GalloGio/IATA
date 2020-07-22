import { LightningElement, wire, api, track } from "lwc";
import getLatestAccountCertifications from "@salesforce/apex/CW_CertificationSection.getLatestAccountCertifications";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import swipe from 'c/cwSwipe';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwLatestICGUpdatesContainer extends LightningElement {
    @api label;
    @api
    title;

    icons = resources + "/icons/";

    prevImageUrl = this.icons + "double_arrow_right.svg";
    nextImageUrl = this.icons + "double_arrow_left.svg";

    @track selectedAccCertification = {
        Id: "",
        image: "",
        certName: "",
        accName: "",
        city: "",
        detailId: "",
        classes: "clickable-box unselected",
        panelClass: "",
        indicatorClass: "",
        hidden: "",
        tabindex: "",
        position: ""

    };
    @track resultsList;
    @track positionCarousel = 'slds-carousel__panels without-border translate-x-0';
    indicatorClicked;
    interval = null;
    initializedswipe = false;

    // Call
    urlFacilityage;
    @wire(getURL, { page: 'URL_ICG_FacilityPage' })
    wiredURLResultPage({ data }) {
        if (data) {
            this.urlFacilityage = data;
        }
    }
    @wire(getLatestAccountCertifications, {})
    wiredResults({ data }) {
        if (data) {
            let result = JSON.parse(JSON.stringify(data));
            let certificationList = [];
            let index = 0;
            let panelClass = 'slds-carousel__panel cursor-txt swipediv';
            let indicatorClass = 'slds-carousel__indicator-action';

            for (let i = 0; i < result.length; i++) {
                let resObject = result[i];

                let accCert = {
                    Id: resObject.Id,
                    image: resObject.ICG_Certification__r.Image__c,
                    certName: resObject.ICG_Certification__r.Name,
                    accName: resObject.ICG_Account_Role_Detail__r.Name,
                    city: resObject.ICG_Account_Role_Detail__r.City_FOR__c,
                    detailId: resObject.ICG_Account_Role_Detail__r.Id,
                    classes: index === 0 ? "clickable-box selected" : "clickable-box unselected",
                    panelClass: index === 0 ? panelClass + ' panelSelected' : panelClass,
                    indicatorClass: index === 0 ? indicatorClass + ' slds-is-active' : indicatorClass,
                    hidden: index === 0 ? true : false,
                    tabindex: index === 0 ? '0' : '-1',
                    position: 'slds-carousel__panels without-border translate-x' + index + '00'

                };
                index++;
                certificationList.push(accCert);
            }
            this.resultsList = certificationList;
            this.selectedAccCertification = this.resultsList[0];
            //this.updateCss();
        }
    }


    renderedCallback() {
        this.initializeSwipe();
    }

    connectedCallback() {

        this.resetInterval();

    }
    get isaccCertificationResults() {
        if (this.resultsList) {
            return this.resultsList.length > 0;
        }

        return "";
    }

    handleAccCertSelected(event) {
        clearInterval(this.interval);
        this.resetInterval();

        const accCertId = event.target.dataset.item;
        this.selectedAccCertification = this.resultsList.find(
            accCert => accCert.Id === accCertId
        );

        this.updateCss(this.selectedAccCertification.Id);
    }

    previousHandler() {

        clearInterval(this.interval);
        this.resetInterval();

        let index = this.findIndex();

        if (index > -1) {
            if (index === 0) {
                index = this.resultsList.length - 1;
            } else {
                index--;
            }

            this.selectedAccCertification = this.resultsList[index];
            this.updateCss(this.selectedAccCertification.Id);
        }
    }

    updateCss(Id) {

        this.updateList(Id);

        this.resultsList.forEach(element => {
            if (this.selectedAccCertification.Id === element.Id) {
                element.classes = "clickable-box selected";
            } else {
                element.classes = "clickable-box unselected";
            }
        });

    }

    resetInterval() {

        this.interval = setInterval(() => {
            this.nextHandler();
        }, 5000);

    }


    initializeSwipe(){
        if(!this.initializedswipe){
          let swipedivs = this.template.querySelectorAll('.swipediv');
          if(swipedivs && swipedivs.length > 0){
            this.initializedswipe = true;
            swipedivs.forEach(swipediv =>{
              swipe.swipedetect(swipediv, (swipedir)=>{
                // swipedir contains either "none", "left", "right", "top", or "down"
              if(swipedir === 'left') this.nextHandler();
              if(swipedir === 'right') this.previousHandler();
              });
            });
            
          }
        }
    }

    nextHandler() {
        clearInterval(this.interval);
        this.resetInterval();

        let index = this.findIndex();

        if (index > -1) {
            if (index === this.resultsList.length - 1) {
                index = 0;
            } else {
                index++;
            }

            this.selectedAccCertification = this.resultsList[index];
            this.updateCss(this.selectedAccCertification.Id);
        }
    }

    findIndex() {
        if (!this.selectedAccCertification.Id) return -1;

        return this.resultsList.findIndex(
            result => result.Id === this.selectedAccCertification.Id
        );
    }

    handleMoreClicked() {

        let url =
            this.urlFacilityage + '?eid=' +
            encodeURI(this.selectedAccCertification.detailId);

        window.open(url, "_blank");
    }

    //Indicator clicked
    handleIndicator(event) {
        this.indicatorClicked = event.target.dataset.item;
        this.updateList(this.indicatorClicked);
    }

    updateList(indicatorClicked) {

        this.resultsList.forEach(element => {

            if (element.Id === indicatorClicked) {
                element.indicatorClass = 'slds-carousel__indicator-action slds-is-active';
                element.tabindex = '0';
                element.hidden = 'true';
                element.panelClass = 'slds-carousel__panel panelSelected';
                this.positionCarousel = element.position;
                this.selectedAccCertification = element;
            } else {
                element.indicatorClass = 'slds-carousel__indicator-action';
                element.tabindex = '-1';
                element.hidden = 'false';
                element.panelClass = 'slds-carousel__panel';
            }
        });

    }


}