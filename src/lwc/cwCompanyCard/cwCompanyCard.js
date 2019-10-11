import { LightningElement, api } from "lwc";
import icons from "@salesforce/resourceUrl/icons";

export default class CwCompanyCard extends LightningElement {
    @api input;

    get getCompanyTypeImage() {
        let imageString = "";
        if (this.input) {
            imageString = this.getImageString(this.input.recordTypeName);
        }
        return icons + "/icons/company_type/" + imageString;
    }

    get getLogoUrl() {
        if (this.input) {
            return this.input.logoUrl;
        }

        return "";
    }

    getImageString(recordTypeName) {
        if (recordTypeName === "Airline") {
            return "airline.svg";
        } else if (recordTypeName === "Airport Operator") {
            return "airport-operator.svg";
        } else if (recordTypeName === "Cargo Handling Facility") {
            return "Cargo-Handling-Facility.svg";
        } else if (recordTypeName === "Freight Forwarder") {
            return "freight-forwarder.svg";
        } else if (recordTypeName === "Ramp Handler") {
            return "ramp-handler.svg";
        } else if (recordTypeName === "Shipper") {
            return "shipper.svg";
        } else if (recordTypeName === "Trucker") {
            return "trucker.svg";
        }

        return "missing-photo";
    }
}