import { LightningElement, api, track, wire } from "lwc";
import tidsAssetsPath from "@salesforce/resourceUrl/tidsAssets";
//Labels
// Salesforce backend logic
import actionApplication from "@salesforce/apex/TIDSHelper.actionApplication";
import discardApplication from "@salesforce/apex/TIDSHelper.discardApplication";
import getcountryISOCode from "@salesforce/apex/TIDSHelper.getcountryISOCode";
import getPortalServiceDetails from '@salesforce/apex/PortalServicesCtrl.getPortalServiceDetails';


// User Info
import { getCase, resetUserInfo } from "c/tidsUserInfo";

// Publish pattern
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import { NavigationMixin } from "lightning/navigation";

export default class TidsConditions extends NavigationMixin(LightningElement) {
  @wire(CurrentPageReference) pageRef;

  homeEligibilityVisitLink =
    tidsAssetsPath + "/images/home/home-eligibility-visit-link.png";
  homeEligibilityOpenCase =
    tidsAssetsPath + "/images/home/home-eligibility-open-case.png";

  @track portalUrl = "/tids";

  /*label = {
    tidsTitle,
    tidsWhatYouCanDo,
    tidsApologizeMessage,
    tidsOpenCaseTitle,
    tidsOpenCaseDescription,
    tidsVisitLinkTitle,
    tidsVisitLinkDescription
  };*/

  @api message;
  showResumeButton;

  @track tidsCase;
  @track spinner = false;
  @track apologizeMessage = false;

  // Confirmation modal
  @track showConfimationModal = false;

  //Modal Window
  @track modalAction;
  @track showConfimationMsgModal = false;
  @track modalDefaultMessage = "";

  connectedCallback() {
    registerListener("showErrorMessage", this.showErrorMessageCallback, this);
    if (this.message) {
      this.message = JSON.parse(JSON.stringify(this.message));
      if (this.message.apologizeMessage === undefined) {
        this.apologizeMessage = true;
      } else {
        this.apologizeMessage = this.message.apologizeMessage;
      }
    }
    let TIDSportalService = 'TIDS';
    this.tidsCase = getCase();
  }

  // Callbacks
  showErrorMessageCallback(props) {
  }

  handleResume(event) {
    event.preventDefault();
    this.spinner = true;
    this.showConfimationMsgModal = false;
    actionApplication({ caseId: this.tidsCase.Id, action: "resume" })
      .then((result) => {
        this.spinner = false;
        if (result.hasAnError){
            this.oops(result.reason);
            this.modalDefaultMessage =
              "Your application is being reviewed by IATA and can no longer be edited.";
            this.modalAction = "OKTIDS";
            this.showConfimationMsgModal = true;
        } else {
            this.tidsCase = undefined;
            fireEvent(this.pageRef, "resumeApplication");
        }
      })
      .catch((error) => {
        this.oops(error);
      });
  }

  handleRecall(event) {
    event.preventDefault();
    this.spinner = true;
    this.showConfimationMsgModal = false;
    actionApplication({ caseId: this.tidsCase.Id, action: "recall" })
      .then((result) => {
        this.spinner = false;
        if (result.hasAnError){
            this.oops(result.reason);
            this.modalDefaultMessage =
              "Your application is being reviewed by IATA and can no longer be edited.";
            this.modalAction = "OKTIDS";
            this.showConfimationMsgModal = true;
        } else {
            this.redirectTidsApplication();
        }
      })
      .catch((error) => {
        this.oops(error);
      });
  }
 
  handleDiscard(event) {
    event.preventDefault();
    this.spinner = true;
    this.showConfimationModal = false;
    this.showConfimationMsgModal = false;
    actionApplication({ caseId: this.tidsCase.Id, action: "discard" })
      .then((result) => {
        this.spinner = false;
        if (result.hasAnError){
            this.oops(result.reason);
            this.modalDefaultMessage =
              "Your application is being reviewed by IATA and can no longer be edited.";
            this.modalAction = "OKTIDS";
            this.showConfimationMsgModal = true;
        } else {
            this.showConfimationModal = true;
        }
      })
      .catch((error) => {
        this.oops(error);
      });
  }

  discardBusinessLogic() {
    this.spinner = true;
    discardApplication({ caseId: this.tidsCase.Id })
    .then((result) => {
      this.spinner = false;
      if (result.hasAnError){
          this.oops(result.reason);
      }else{
          resetUserInfo();
          this.redirectTids();
      }
      
    })
    .catch(error => {
			this.spinner = false;
			this.oops(error);
		});
  }

  handleTidsCase(event) {
    event.preventDefault();
    this.spinner = true;
    this.showConfimationModal = false;
    this.showConfimationMsgModal = false;
    getcountryISOCode()
      .then((result) => {
        if (result != null) {
          this[NavigationMixin.Navigate](
            {
              type: "standard__webPage",
              attributes: {
                url:
                  this.portalUrl +
                  "/../support-reach-us-create-new-case?category=Travel&topic=Accreditation_Travel_Agent&subtopic=TIDS&countryISO=" +
                  result +
                  "&concerncase=false&emergency=false"
              }
            },
            true
          );
        }
        this.spinner = false;
      })
      .catch((error) => {
        this.oops(error);
      });
  }

  redirectTids() {
    this.tidsCase = undefined;
    this[NavigationMixin.Navigate](
      {
        type: "standard__webPage",
        attributes: {
          url: this.portalUrl
        }
      },
      true
    );
  }

  redirectTidsApplication(event) {
    // event.preventDefault();
    this.tidsCase = undefined;
    this[NavigationMixin.Navigate]({
      type: "standard__namedPage",
      attributes: {
        pageName: "tids"
      }
    });
  }
  // Confirmation modal
  handleModalCancel(event) {
    event.preventDefault();
    this.showConfimationModal = false;
  }

  handleModalConfirm(event) {
    event.preventDefault();
    this.discardBusinessLogic();
  }

  handleCloseTab(event) {
    event.preventDefault();
    window.top.close();
    window.open("", "_parent", "");
    window.close();
  }
  oops(error){
		this.modalDefaultMessage='Oops! something happened, please retry.'
		this.modalAction='OK';
		this.showConfimationModal=true;
	}
}