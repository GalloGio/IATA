import { LightningElement, api } from 'lwc';
import { loadScript, loadStyle } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { util } from 'c/igUtility';
import ig_resources from '@salesforce/resourceUrl/IG_Resources';

export default class IgReportChart extends LightningElement {
    
    @api name = 'Chart name';
    @api allowDetailToggle = false;
    @api set info(value) {
        if (value) {
            value = JSON.parse(JSON.stringify(value));
            this._data = value;
            if (this._isChartJsInitialized) {
                this.renderChart();
            }
        } else {
            if (this.chart) {
                this.chart.destroy();
            }
        }
    }
    get info() {
        return this._data;
    }
    @api type = 'pie';
    @api options = {};

    @api
    toggleDetail() {
        this._showDetail = !this._showDetail;
    }
    @api
    showDetail() {
        this._showDetail = true;
    }
    @api
    hideDetail() {
        this._showDetail = false;
    }

    chart;
    _isChartJsInitialized = false;
    _data = [20, 10, 30, 10];
    _showDetail = false;

    chartClick(event) {
        if (this.chart) {
            const dataset = this.chart.getDatasetAtEvent(event);
            const activePoints = this.chart.getElementsAtEvent(event);
            if (activePoints.length > 0 && dataset.length > 0) {
                const clickedDataIndex = activePoints[0]._index;
                const clickedDatasetIndex = dataset[0]._datasetIndex;
                const value = this.chart.data.datasets[clickedDatasetIndex].data[clickedDataIndex];
                this.dispatchEvent(new CustomEvent('dataselect', {
                    detail: {
                        datasetIndex: clickedDatasetIndex,
                        dataIndex: clickedDataIndex,
                        value: value
                    }
                }));
            }
        }
    }

    renderChart() {
		if (this.info && this._isChartJsInitialized) {
            const ctx = this.template.querySelector('canvas.linechart').getContext('2d');
            if (this.chart) {
                this.chart.destroy();
            }
			this.chart = new window.Chart(ctx, {
                type: this.type,
                data: this.info,
                options: Object.assign({
                    responsive: true,
                    legend: {
                        position: 'right'
                    },
                    animation: {
                        animateScale: true,
                        animateRotate: true
                    }
                }, this.options)
            });
			this.chart.canvas.parentNode.style.height = '100%';
			this.chart.canvas.parentNode.style.width = '100%';
		}
	}

    isChartJsLoading = false;
	async renderedCallback() {
		if (this.isChartJsLoading) {
			return;
        }
        this.isChartJsLoading = true;
		try {
			await Promise.all([
				loadStyle(this, ig_resources + "/css/Chart.min.css"),
				loadScript(this, ig_resources + "/js/Chart.min.js")
			]);
		} catch (error) {
			this.dispatchEvent(
				new ShowToastEvent({
					title: 'Error loading ChartJS',
					message: error.message,
					variant: 'error',
				}),
			);
        }
        this._isChartJsInitialized = true;
        window.Chart.platform.disableCSSInjection = true;
		this.renderChart();
	}

    get viewDetailLabel() {
        return this._showDetail ? 'Hide detail' : 'Show detail';
    }

    viewDetail(event) {
        this._showDetail = !this._showDetail;
    } 

}