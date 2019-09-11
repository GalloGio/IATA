import { LightningElement, api } from 'lwc';

export default class PortalOscarProgressBar extends LightningElement {
    @api progressStatusList;

    connectedCallback() {
        this.treatSteps();
    }

    treatSteps() {
        let progressStatusListLocal = JSON.parse(JSON.stringify(this.progressStatusList));
        let count = 1;
        // for (i = 0; i < cars.length; i++) {
        let i;
        for (i = 0; i < progressStatusListLocal.length - 1; i++) {

            if (progressStatusListLocal[i].status === "notDone") {
                progressStatusListLocal[i].class = this.getNotDone(progressStatusListLocal[count].status);
            } else if (progressStatusListLocal[i].status === "done") {
                progressStatusListLocal[i].class = this.getDone(progressStatusListLocal[count].status);
            } else if (progressStatusListLocal[i].status === "inProgress") {
                progressStatusListLocal[i].class = this.getInProgress(progressStatusListLocal[count].status);
            } else {
                progressStatusListLocal[i].class = this.getError(progressStatusListLocal[count].status);
            }

            count++;
        }

        this.progressStatusList = progressStatusListLocal;
    }

    getNotDone(step) {
        if (step === "notDone") {
            return "bar barIsNotDone";
        } else if (step === "done") {
            return "bar barIsNotDoneDone";
        } else if (step === "inProgress") {
            return "bar barIsNotDoneInProgress";
        } else { // ERROR
            return "bar barIsNotDoneError";
        }
    }

    getDone(step) {
        if (step === "notDone") {
            return "bar barDoneIsNotDone";
        } else if (step === "done") {
            return "bar barDone";
        } else if (step === "inProgress") {
            return "bar barDoneInProgress";
        } else { // ERROR
            return "bar barDoneError";
        }
    }

    getInProgress(step) {
        if (step === "notDone") {
            return "bar barInProgressIsNotDone";
        } else if (step === "done") {
            return "bar barInProgressDone";
        } else if (step === "inProgress") {
            return "bar barInProgress";
        } else { // ERROR
            return "bar barInProgressError";
        }
    }

    getError(step) {
        if (step === "notDone") {
            return "bar barErrorIsNotDone";
        } else if (step === "done") {
            return "bar barErrorDone";
        } else if (step === "inProgress") {
            return "bar barErrorInProgress";
        } else { // ERROR
            return "bar barError";
        }
    }

}