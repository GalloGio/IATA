public class EF_MassUpdateMatLiController {

    private boolean checkAll = true;
    public EF_Material_Line_Item__c sampleMaterial {get;set;}
    public List <EF_Material_Line_Item__c> listMatSelected {get;set;}
    public List<EF_MaterialWrapper> listMatWrapper {get; set;}
    private Contract contract;
    private ApexPages.StandardController std;

    public EF_MassUpdateMatLiController (){
    }
    public EF_MassUpdateMatLiController(ApexPages.StandardController stdCtrl){
      std=stdCtrl;
        this.contract = (Contract)std.getRecord();
    }



     // the associated materials
     public List<EF_Material_Line_Item__c> materials;

     public Contract getContract(){
       return (Contract) std.getRecord();
     }

    public List<EF_MaterialWrapper> getMaterials() {
    if(listMatWrapper == null) {
      listMatWrapper = new List<EF_MaterialWrapper>();
      for(EF_Material_Line_Item__c m: [SELECT Id, Name, EF_Status__c, EF_Relationship__r.Contract__c, EF_Relationship__r.BillingAgreement_Name__c, EF_Relationship__c, EF_Material__c from EF_Material_Line_Item__c where  EF_Relationship__r.Contract__c =: contract.Id]) {

                listMatWrapper.add(new EF_MaterialWrapper(m));
      }

    }
    return listMatWrapper;

  }


    public List<EF_Material_Line_Item__c> getMatSelected (){
    if(listMatSelected==null) listMatSelected= new List <EF_Material_Line_Item__c>();

    for(EF_MaterialWrapper mli: getMaterials()){
           if(mli.selected){
             listMatSelected.add(mli.mmli);
           }
    }
    return listMatSelected;
  }

    public PageReference selectAll(){
        checkAll = !checkAll;
        for(EF_MaterialWrapper oli: getMaterials() ){
            oli.selected = checkAll;
        }
        return null;
    }

   public string checkHeader{//text displayed on page
        get{
            if (checkAll){ return 'Clear All';
            }else{ return 'Select All';}
        }
        set;
    }

    public void save() {
       try{

        update getMatSelected();
        ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Records saved.');
        ApexPages.addMessage(myMsg);

       }catch(Exception e){
            System.debug('**** error on renewal contract' +e );
          ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: '+e);
      ApexPages.addMessage(myMsg);
        }


   }



}