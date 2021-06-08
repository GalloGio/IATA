import { LightningElement, api, track } from 'lwc';
import { label } from 'c/igLabels';

export default class IgFilePicker extends LightningElement {	
	
	@track label = label;
	@track _selectedFiles = [];
	
	@api multifile;

	fileInput;
	_nextId = 0;
	
	@api
	get selectedFile() {
		if (!this.multifile) {
			return this._selectedFiles[0] ? this._selectedFiles[0].file : null;
		} else {
			return this._selectedFiles.map(item => item.file);
		}
	}
	@api get displayFile() {}
	set displayFile(file) {
		if (file) {
			if (!this.multifile) {
				this._selectedFiles = [ { id: this.nextId, file: file } ];
			} else {
				this._selectedFiles = file.map(file => ({ id: nextId, file: file }))
			}
		}
	}

	get nextId() {
		return ++this._nextId;
	}

	get selectedFiles() {
		return this._selectedFiles;
	}
	set selectedFiles(value) {
		if (value.length > this._selectedFiles.length) {
			this._selectedFiles = value;
			this.dispatchEvent(new CustomEvent("fileselected"));
		} else if (value.length < this._selectedFiles.length) {
			this._selectedFiles = value;
			this.dispatchEvent(new CustomEvent("fileunselected"));
		} else {
			this._selectedFiles = value;
		}
	}

	get canUploadFiles() {
		return this.multifile || (!this.multifile && this.selectedFiles.length === 0);
	}

	get isSomeFileSelected() {
		return this.selectedFiles.length > 0;
	}

	constructor() {
		super();
		this.fileInput = document.createElement('input');
		this.fileInput.type = 'file';
		this.fileInput.onchange = function(e) { 
			this.selectedFiles = [...this.selectedFiles, {
				id: this.nextId,
				file: e.target.files[0]
			}];
		}.bind(this);
	}

	fileSelectorDialog(ev) {
		this.fileInput.click();
	}

	removeFile(ev) {
		const id = ev.target.closest('.selected-file').dataset.id;
		if (id !== undefined) {
			this.selectedFiles = this.selectedFiles.filter(item => item.id != id);
		}
	}

	dropHandler(ev) {
		ev.preventDefault();
		if (ev.dataTransfer) {
			if (ev.dataTransfer.items && ev.dataTransfer.items.length > 0) {
				if (ev.dataTransfer.items[0].kind === 'file') {
					this.selectedFiles = [...this.selectedFiles, {
						id: this.nextId,
						file: ev.dataTransfer.items[0].getAsFile()
					}];
				}
				ev.dataTransfer.items.clear();
			} else {
				if (ev.dataTransfer.files.length > 0) {
					this.selectedFiles = [...this.selectedFiles, {
						id: this.nextId,
						file: ev.dataTransfer.files[0]
					}];
				}
				ev.dataTransfer.clearData();
			} 
		} else {
			console.error('No dataTransfer available in the event');
		}
		this.template.querySelector('.upload-box').classList.remove('upload-box-hover');
	}

	dragOverHandler(ev) {
		ev.preventDefault();
	}

	dragEnterHandler(ev) {
		this.template.querySelector('.upload-box').classList.add('upload-box-hover');
	}

	dragLeaveHandler(ev) {
		this.template.querySelector('.upload-box').classList.remove('upload-box-hover');
	}

}