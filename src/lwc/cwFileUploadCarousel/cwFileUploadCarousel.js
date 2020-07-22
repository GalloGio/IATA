import { LightningElement, api } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
export default class CwFileUploadCarousel extends LightningElement {
	@api recordId;

	get acceptedFormats() {
		return [".png", ".jpg", ".jpeg"];
	}

	handleUploadFinished(event) {
		let strFileNames = "";

		const uploadedFiles = event.detail.files;

		for (let i = 0; i < uploadedFiles.length; i++) {
			strFileNames += uploadedFiles[i].name + ", ";
		}

		this.dispatchEvent(new CustomEvent("closemodal"));

		this.dispatchEvent(
			new ShowToastEvent({
				title: "Success",
				message: strFileNames + " Files uploaded Successfully",
				variant: "success"
			})
		);
	}
}