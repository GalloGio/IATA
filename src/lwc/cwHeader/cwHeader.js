import { LightningElement, api, wire, track } from "lwc";
import { loadStyle } from "lightning/platformResourceLoader";
import pubsub from "c/cwPubSub";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getUserInfo from "@salesforce/apex/CW_PrivateAreaController.getUserInfo";
import getUserRole from "@salesforce/apex/CW_Utilities.getUserRole";
import labels from 'c/cwOneSourceLabels';
import getSelfRegisterUrl from '@salesforce/apex/CW_LoginController.getSelfRegisterUrl';
import getEnvironmentVariables from '@salesforce/apex/CW_Utilities.getEnvironmentVariables';
import { CurrentPageReference } from 'lightning/navigation';

export default class CwHeader extends LightningElement {
    label = labels.labels();
    icons = resources + "/icons/";
    images = resources + "/img/";

    //icons
    menuresponsive = this.icons + "responsive/ic-menu--open.svg";
    menuresponsiveitem = this.icons + "responsive/ic-responsive-menu.png";
    loginIcon = this.icons + "user.svg";

    //images
    logo = this.images + "iata-logo.svg";
    logoprint = this.images + "one-source-visual-blue.svg";


    @track loadedCss = false;

    @api smallContainer;
    @api showMenu;
    @api relativeLinks;
    @track userInfo;

    @track showModal = false;

    userInfoLoggedIn;
    urlICGHomePage;
    urlPrivateArea;
    rawUserInfo;

    @wire(CurrentPageReference)
    currentPageReference;

    @wire(getUserInfo, {})
    wiredUserInfo(result) {
        this.rawUserInfo = result;
        if (result.data) {
            this.userInfo = JSON.parse(result.data);
            this.getUserRoleJS(null);
        }
    }

    @wire(getEnvironmentVariables, {})
    environmentVariables;

    getUserRoleJS(facId) {
        getUserRole({ facilityId: facId }).then(data => {
            if (data) {
                if (data === "Guest") {
                    this.userInfoLoggedIn = false;
                } else {
                    this.userInfoLoggedIn = true;
                }
            }
        });
    }

    @wire(getURL, { page: "URL_ICG_Home" })
    wiredURLResultPage({ data }) {
        if (data) {
            this.urlICGHomePage = data;
        }
    }

    @wire(getURL, { page: "URL_ICG_PrivateArea" })
    wiredURLPrivateArea({ data }) {
        if (data) {
            this.urlPrivateArea = data;
        }
    }

    renderedCallback() {
        Promise.all([
                loadStyle(this, resources + "/css/main.css"),
                loadStyle(this, resources + "/css/custom.css"),
                loadStyle(this, resources + "/css/public.css")
            ])
            .then(() => {
                this.loadedCss = true;
                pubsub.fire("loadedCss");
            })
      if(this.showModal){
        this.setJoinLabels();
      }
    }

    
    connectedCallback(){
		this.showJoinNowModalCallBack = this.showJoinNowModal.bind(this);
        pubsub.register('showJoinNowPopUp', this.showJoinNowModalCallBack ); 
    }

    handleClick(event) {
        event.preventDefault();
        let targetId = event.target.dataset.targetId;
        if (this.relativeLinks) pubsub.fire("scrolltosection", targetId);
        else location.href = this.urlICGHomePage + "#" + targetId;
    }
    showresponsivemenu() {
        let menur = this.template.querySelector(".collapse");
        if (menur) {
            this.template
                .querySelector(".navbar-collapse")
                .classList.remove("collapse");
            this.template.querySelector(".icoresponsivemenu").src =
                this.icons + "responsive/ic-menu--closed.svg";
        } else {
            this.template.querySelector(".navbar-collapse").classList.add("collapse");
            this.template.querySelector(".icoresponsivemenu").src =
                this.icons + "responsive/ic-menu--open.svg";
        }
    }
    get ContainerType() {
        let container;
        if (this.smallContainer) {
            container = "container";
        } else {
            container = "container container-search";
        }
        return container;
    }

    goToPrivateArea() {
        window.open(this.urlPrivateArea,'_blank');
    }

    goToJoinNow() {
        this.closeModal();
        getSelfRegisterUrl().then(selfRegisterUrl => {
            // To Ruben Nunes: This is the right url in production for the Self-Register, uncomment to fast fix
            // selfRegisterUrl = 'https://portal.iata.org/s/login/SelfRegister?language=en_US&startURL=%2Fs%2Fmanage-service%3FserviceId%3Da2w5J000000kTPTQA2';
            location.href = selfRegisterUrl;
        });
    }

	showJoinNowModalCallBack;
    showJoinNowModal() {
        this.showModal = true;
        
    }

    
    setJoinLabels(){       
        this.template.querySelector('.join_now_title').innerHTML = this.label.icg_join_now_title;
    }

    closeModal() {
        this.showModal = false;
    }

    get isBetaOrg(){
        return this.environmentVariables && this.environmentVariables.data && this.environmentVariables.data.Is_Beta_Org__c === true;
    }

    get isLoaded(){
        return this.loadedCss && (!this.isHomePage || this.isHomePage && this.environmentVariables && this.environmentVariables.data) ;
    }

    get isHomePage(){
        return this.currentPageReference ? this.currentPageReference.attributes.name === 'Home' : false;
    }

    goToPreRegister(){
        window.open(this.label.icg_registration_url,'_blank');
    }
}