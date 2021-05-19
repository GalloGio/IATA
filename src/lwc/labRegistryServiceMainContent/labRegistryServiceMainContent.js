import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage} from'c/navigationUtils';

//Static Resources
import LabRegistry_CSVTemplate from '@salesforce/resourceUrl/LabRegistry_CSVTemplate';


//Labels
import CSP_LabReg_CompleteDetails		from '@salesforce/label/c.CSP_LabReg_CompleteDetails';
import CSP_LabReg_Download_CSV			from '@salesforce/label/c.CSP_LabReg_Download_CSV';
import CSP_LabReg_UploadDetails			from '@salesforce/label/c.CSP_LabReg_UploadDetails';
import CSP_LabReg_UploadFilledCSV		from '@salesforce/label/c.CSP_LabReg_UploadFilledCSV';
import CSP_LabReg_UploadCSVBtn		from '@salesforce/label/c.CSP_LabReg_UploadCSVBtn';
import CSP_PortalPath						from '@salesforce/label/c.CSP_PortalPath';


export default class labRegistryServiceMainContent extends NavigationMixin(LightningElement) {
	@track labels = {
		CSP_LabReg_CompleteDetails
		,CSP_LabReg_Download_CSV
		,CSP_LabReg_UploadDetails
		,CSP_LabReg_UploadFilledCSV
		,CSP_LabReg_UploadCSVBtn
	}

	downloadTemplate(){
		navigateToPage(this.csvURL,{});
	}
	
	TemplateFile = LabRegistry_CSVTemplate;

	openUploadCSVModal(){
		alert('Chupa');
	}
}