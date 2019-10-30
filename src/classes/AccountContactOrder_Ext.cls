/****************************************************************************************************
    Created by CGI, Thai 2015-10-04
        Extension for VF pages "AccountOrder" and "ContactOrder"
****************************************************************************************************/
public class AccountContactOrder_Ext {

class clsOrder {
    public Order orderInfo { get; set; }
    public Boolean allowEdit { get; set; }
    public Boolean allowDelete { get; set; }
    public clsOrder(Order orderInfo) {
        String strTemp1;
        this.orderInfo = orderInfo;
        strTemp1 = ',' + Utility.getTextSetting('Order status allows order modification') + ',';
        this.allowEdit = ((orderInfo.Status == null) || strTemp1.containsIgnoreCase(',' + orderInfo.Status + ','));
        strTemp1 = ',' + Utility.getTextSetting('Order status allows order deletion') + ',';
        this.allowDelete = ((orderInfo.Status == null) || strTemp1.containsIgnoreCase(',' + orderInfo.Status + ','));
    }
}
public List<clsOrder> vfOrder { get; set; }
public Id orderIdToDelete { get; set; }
public String returnURL { get; set; }
public String viewURL { get; set; }
public String editURL { get; set; }
public String newURL { get; set; }
public String newOrderURL { get; set; }

/****************************************************************************************************
    Created by CGI, Thai 2015-10-04
        Constructor
****************************************************************************************************/
public AccountContactOrder_Ext(ApexPages.StandardController controller) {
    Id objId = ((controller.getRecord().get('Id') == null) ? null : Id.valueOf(String.valueOf(controller.getRecord().get('Id'))));
    List<Order> listOrder;
    
    //*** get orders belong to account or contact
    newOrderURL = null;
    if (objId == null)
        listOrder = new List<Order>();
    else {
        viewURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Order?sfdc.override=1&id=';
        editURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Order?sfdc.override=1&retURL=%2F' + String.valueOf(objId).left(15) + '&id=';
        if (objId.getSObjectType().getDescribe().getName() == 'Contact') {
            listOrder = Order_Sel.getOrderForAccountOrContact(null, new List<Id>{objId});
            newURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Order?sfdc.override=1&retURL=%2F' + String.valueOf(objId).left(15)
                   + '&contactID=' + String.valueOf(objId).left(15) + '&save_new=1';
        } else {
            listOrder = Order_Sel.getOrderForAccountOrContact(new List<Id>{objId}, null);
            newURL = URL.getSalesforceBaseUrl().toExternalForm() + '/apex/Order?sfdc.override=1&retURL=%2F' + String.valueOf(objId).left(15)
                   + '&accountID=' + String.valueOf(objId).left(15) + '&save_new=1';
        }
    }
    
    //*** build orders to display
    vfOrder = new List<clsOrder>();
    for (Order o : listOrder)
        vfOrder.add(new clsOrder(o));
    
    //*** build return URL in case of edit
    if (objId != null)
        returnURL = '&retURL=%2F' + String.valueOf(objId).left(15);
} //*** end of "AccountContactOrder_Ext"

} //*** end of class