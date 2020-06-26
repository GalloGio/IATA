import { LightningElement,api,track,wire } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import pubsub from 'c/cwPubSub';
import swipe from 'c/cwSwipe';
import labels from 'c/cwOneSourceLabels';
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";


export default class CwBody extends LightningElement {

    label = labels.labels();
    images = resources + "/img/";
    urlResultPage;

    @track extraClasses;
    @track totrans = "slds-carousel__panels without-border translate-x-0";
    @wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}
    //images
    logo = this.images + 'iata-logo.svg';
    btnyllw = this.images + 'btn-yllw.png';
    iatay1 = this.images + 'iatay1.png';
    iatay2 = this.images + 'iatay2.png';
    iatay3 = this.images + 'iatay3.png';
    iatay4 = this.images + 'iatay4.png';
    employees = this.images + 'employees.png';
    airport = this.images + 'airport.PNG';
    adv1 = this.images + 'adv1.PNG';
    adv2 = this.images + 'adv2.PNG';
    adv3 = this.images + 'adv3.png';
    iatacargo = this.images + 'iata-cargo.jpg';


    @track initialized = false;
    @track showWhatIsIataSource = false;
    @track showMemberAirlines = false;
    @track showStrategicAirlines = false;
    initializedswipe = false;

    parameters = {};

    renderedCallback() {
        if (!this.initialized) {
            console.log(this.label);
            this.initialized = true;
            let hash = window.location.hash;
            //Delay to let the screen load and set ids
            if (hash && hash != '#') {
                setTimeout(() => {
                    this.scrollToSectionCallback(hash.replace('#',''));
                  }, 300);
                
            }               
       
        }
        this.initializeSwipe();
        this.setEpecialLabels();
    }
    scrollToSectionCallback;
    scrollToSection(sectionId) {
        let elem = this.template.querySelector('[id*="'+sectionId+'"]');
        let hashPosition = location.href.indexOf('#');
        if (hashPosition > -1){
            location.href = location.href.substring(0,hashPosition) + '#' + elem.id;
        }else{
            location.href = location.href+'#'+elem.id;
        }
        
        window.scrollBy(0,-110);
    }
    connectedCallback(){
        this.scrollToSectionCallback = this.scrollToSection.bind(this); 
        this.register();
    }
    @api
    register(){
        pubsub.register('scrolltosection', this.scrollToSectionCallback ); 
    } 
    

    getQueryParameters() {
        var params = {};
        var search = location.search.substring(1);
        if (search) {
            params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
                return key === "" ? value : decodeURIComponent(value)
            });
        }
        return params;
    }

    carouselchange(event) {
        let targetId = event && event.target ? event.target.dataset.targetId : event;
        let items = this.template.querySelectorAll(".car-item");
        let bullets = this.template.querySelectorAll(".bullet");
        let positcar;
        for (let i = 0; i < items.length; i++) {
            if (items[i].dataset.targetId === targetId) {               
                bullets[i].classList.add('current');
                items[i].classList.remove('item-inactive');
                items[i].classList.add('item-active');
            } else {
                bullets[i].classList.remove('current');
                items[i].classList.add('item-inactive');
                items[i].classList.remove('item-active');
            }
        }
        if(targetId > 1){
            positcar = targetId - 1; 
            this.totrans = 'slds-carousel__panels without-border translate-x' + positcar + '00'
        }else{
            this.totrans = "slds-carousel__panels without-border translate-x-0";
        }

    }

    seeAllResults() { 
        window.location.href = this.urlResultPage + "?q=all";
    }
    getNextCarouselElementId(){
        let activeItem = this.template.querySelector(".item-active").dataset.targetId;
        let items = this.template.querySelectorAll(".car-item");
        activeItem++;
        activeItem = activeItem.toString();
        if(parseInt(activeItem,10) > items.length){
            activeItem = "1";
        } 
        this.carouselchange(activeItem);
    }
    getPreviousCarouselElementId(){
        let activeItem = this.template.querySelector(".item-active").dataset.targetId;
        let items = this.template.querySelectorAll(".car-item");
        activeItem--;
        activeItem = activeItem.toString();
        if(parseInt(activeItem,10) === 0) activeItem = items.length.toString();
        this.carouselchange(activeItem);
    }

    get backgroundLatestNews() {
        return "backgroundLatestNews";
    }

    get backgroundSmartFacility() {
        return "backgroundSmartFacility";
    }

    initializeSwipe(){
        if(!this.initializedswipe){
          let swipedivs = this.template.querySelectorAll('.swipediv');
          if(swipedivs && swipedivs.length > 0){
            this.initializedswipe = true;
            swipedivs.forEach(swipediv =>{
              swipe.swipedetect(swipediv, (swipedir)=>{
                // swipedir contains either "none", "left", "right", "top", or "down"
              if(swipedir === 'left') this.getNextCarouselElementId();
              if(swipedir === 'right') this.getPreviousCarouselElementId();
              });
            });
            
          }
        }
    }
    
    showWhatsIATAModal(){ 
        this.showWhatIsIataSource = true;
    } 
    closeWhatsIsIataSource() { 
        this.showWhatIsIataSource = false;
    }
    showMemberAirlinesModal() { 
        this.showMemberAirlines = true;
        this.extraClasses = 'modalMemberAirlines';
    }
    showStrategicAirlinesModal() { 
        this.showStrategicAirlines = true;
        this.extraClasses = 'modalStrategicPartners';
    }
    closeMemberAirlines() { 
        this.showMemberAirlines = false;
    }
    closeStrategicAirlines() { 
        this.showStrategicAirlines = false;
    }

      setEpecialLabels(){
        this.template.querySelector('.servicehome1').innerHTML = this.label.service_home1;
        this.template.querySelector('.servicehome1r').innerHTML = this.label.service_home1;
        this.template.querySelector('.servicehome2').innerHTML = this.label.service_home2;
        this.template.querySelector('.servicehome2r').innerHTML = this.label.service_home2;
        this.template.querySelector('.servicehome3').innerHTML = this.label.service_home3;
        this.template.querySelector('.servicehome3r').innerHTML = this.label.service_home3;
        this.template.querySelector('.servicehome4').innerHTML = this.label.service_home4;
        this.template.querySelector('.servicehome4r').innerHTML = this.label.service_home4;

      }
    
      @api
      showJoinNowPopUp(){
        pubsub.fire("showJoinNowPopUp");
      }
}