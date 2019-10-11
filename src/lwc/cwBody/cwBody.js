import { LightningElement } from 'lwc';
import file from '@salesforce/resourceUrl/IATA_CSS_guidelines_v1';
import demoFiles from '@salesforce/resourceUrl/demo_resource';

export default class CwBody extends LightningElement {
    logo = file + '/IATA-CSS-guidelines-v1/assets/iata-logo.svg'; 
    employees = demoFiles + '/demo_resource/employees.PNG'; 
    airport = demoFiles + '/demo_resource/airport.PNG';
    adv1 = demoFiles + '/demo_resource/adv1.PNG';
    adv2 = demoFiles + '/demo_resource/adv2.PNG';
    adv3 = demoFiles + '/demo_resource/adv3.png';

    iatacargo = demoFiles + '/demo_resource/iata-cargo.jpg';

    iatay1 = demoFiles + '/demo_resource/iatay1.png';
    iatay2 = demoFiles + '/demo_resource/iatay2.png';
    iatay3 = demoFiles + '/demo_resource/iatay3.png';
    iatay4 = demoFiles + '/demo_resource/iatay4.png';

    
    carouselchange(event) {
        let targetId = event.target.dataset.targetId;
        let items = this.template.querySelectorAll(".car-item");
        for (let i = 0; i < items.length; i++) {
            if(items[i].dataset.targetId === targetId){
                items[i].classList.remove('item-inactive');
                items[i].classList.add('item-active');
                
            }else{
                console.log('items[i]', items[i]);
                items[i].classList.add('item-inactive');
                items[i].classList.remove('item-active');
            }
        }
    }
}