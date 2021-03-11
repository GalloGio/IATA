import { LightningElement, track,api } from 'lwc';
//import static resources
import COUNTRY_IMAGES from '@salesforce/resourceUrl/IECFlags48';

export default class tidsTooltip extends LightningElement {
	 @api rules;
	 data=[];
	 @track displayed=true;
	 @track visible = false;
	 @track languages = [];

		getLanguages(){
			this.data = [ {
										language:'',
										text: this.rules.translation_english,
										visible:false,
										islabel:true
										},
										{
										language:COUNTRY_IMAGES + "/flags48/cn.png",
										text: this.rules.translation_chinese,
										visible:false,
										islabel:false
										}, 
										{
										language:COUNTRY_IMAGES + "/flags48/fr.png",
										text: this.rules.translation_french,
										visible:false,
										islabel:false
										},
										{
										language: COUNTRY_IMAGES + "/flags48/jp.png",
										text: this.rules.translation_japanese,
										visible:false,
										islabel:false
										},
										{
											language:COUNTRY_IMAGES + "/flags48/pt.png",
											text: this.rules.translation_portuguese,
											visible:false,
											islabel:false
										},
										{
										language: COUNTRY_IMAGES + "/flags48/es.png",
										text: this.rules.translation_spanish,
										visible:false,
										islabel:false
										}
									];
				let vdisplayed=false;
				this.data.forEach(function(item){
					 if (!(item.text==undefined || item.text=='')){
							item.visible=true;
							vdisplayed=true;
					 }
				});
				this.displayed=vdisplayed;
				this.languages =this.data;
				return this.languages;
		}
		
		openpop(event) {
				event.preventDefault();
				this.getLanguages();
				this.visible = true;
		}
		closepop(event) {
				event.preventDefault();
				this.visible = false;
		}
		connectedCallback() {
			this.getLanguages();
		}
}