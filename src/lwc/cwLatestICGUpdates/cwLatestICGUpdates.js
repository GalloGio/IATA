import { LightningElement, api,wire } from "lwc";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import swipe from 'c/cwSwipe';

export default class CwLatestICGUpdates extends LightningElement {
  @api
  buttonUrl;

  @api
  buttonText;

  @api
  certImageUrl = "";

  @api
  prevImageUrl = "";

  @api
  nextImageUrl = "";

  // Filters
  @api
  certificationType = "";

  @api
  certificationName = "";

  @api
  accRoleDetailName = "";

  @api
  accRoleDetailCity = "";

  @api
  accCertId = "";

  @api
  detailId = "";

  initializedswipe = false;

  urlFacilityage;
  @wire(getURL, {page: 'URL_ICG_FacilityPage'})
  wiredURLResultPage({ data }) {
      if (data) {
          this.urlFacilityage = data;
      }
  }
  previousHandler() {
    let mainClass = this.template.querySelectorAll('.animation-main');
    if(mainClass){
      mainClass.forEach((elem)=>{
        if(!elem.classList.contains('animation-previous'))
        {
          elem.classList.add('animation-previous');
        }
      
        if(elem.classList.contains('animation-next'))
        {
          elem.classList.remove('animation-next');
        }
      });
    }
    this.dispatchEvent(new CustomEvent("previous"));
  }

  nextHandler() {
    let mainClass = this.template.querySelectorAll('.animation-main');
    if(mainClass){
      mainClass.forEach((elem)=>{
        if(!elem.classList.contains('animation-next'))
        {
          elem.classList.add('animation-next');
        }
      
        if(elem.classList.contains('animation-previous'))
        {
          elem.classList.remove('animation-previous');
        }
      });
    }
    this.dispatchEvent(new CustomEvent("next"));
  }

  handleMoreClicked() {

      let url =
      this.urlFacilityage + '?eid='+
      encodeURI(this.detailId);

      window.open(url, "_blank");
  }

  connectedCallback(){
    setInterval(()=>{
      this.template.querySelectorAll('.latesticgupdates').forEach((elem)=>{elem.classList.add('fadeInLeftBig')});
    },5100);

    setInterval(()=>{
      this.template.querySelectorAll('.latesticgupdates').forEach((elem)=>{elem.classList.remove('fadeInLeftBig')});
    },5000);
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
  renderedCallback(){
    this.initializeSwipe();
  }

}