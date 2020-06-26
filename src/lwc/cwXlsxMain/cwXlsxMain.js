import { LightningElement, api } from "lwc";
import { loadScript } from "lightning/platformResourceLoader";
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwXlsxMain extends LightningElement {
    @api headerList;
	@api filename;
	@api worksheetNameList;
	@api sheetData;
	librariesLoaded = false;
	renderedCallback() {

		if (this.librariesLoaded) return;
		this.librariesLoaded = true;
		Promise.all([loadScript(this, resources + "/js/xlsx.full.min.js")])
	}
	@api download() {
		const XLSX = window.XLSX;
		let xlsData = this.sheetData;
		let xlsHeader = this.headerList;
		let ws_name = "";
		let createXLSLFormatObj = Array(xlsData.length).fill([]);
		//let xlsRowsKeys = [];
		/* form header list */
		xlsHeader.forEach((item, index) => createXLSLFormatObj[index] = [item])

		/* form data key list */
		xlsData.forEach((item, selectedRowIndex)=> {
			let xlsRowKey = Object.keys(item[0]);
			item.forEach((value, index) => {
				var innerRowData = [];
				xlsRowKey.forEach(item=>{
					innerRowData.push(value[item]);
				})
				createXLSLFormatObj[selectedRowIndex].push(innerRowData);
			})

		});
		/* creating new Excel */
		var wb = XLSX.utils.book_new();

		/* creating new worksheet */
		var ws = Array(createXLSLFormatObj.length).fill([]);
		for (let i = 0; i < ws.length; i++) {
		/* converting data to excel format and puhing to worksheet */
		let data = XLSX.utils.aoa_to_sheet(createXLSLFormatObj[i]);
		ws[i] = [...ws[i], data];

		/* Add worksheet to Excel */
		XLSX.utils.book_append_sheet(wb, ws[i][0], ws_name[i]);
		}

		/* Write Excel and Download */
		XLSX.writeFile(wb, this.filename);
	}
}