public class Order_DTO
{
	//-- Order properties
	public String   orderId{get;set;}
	public String   orderNumber{get;set;}
	public String   orderType{get;set;}
	public String   orderStatus{get;set;}
	public String   orderPreviousType{get;set;}
	public String   orderSource{get;set;}
	public String   orderChannel{get;set;}
	public String   orderInternalRemarks{get;set;}
	public String   salesOrderRemarks{get;set;}
	public Date     orderStartDate{get;set;}

	//-- Order metrics
	public Decimal taxes{get;set;}
	public Decimal orderSubTotalAmount{get;set;}
	public Decimal orderDiscountAmount{get;set;}
	public Decimal orderTotalAmount{get;set;}
	public Decimal totalFreightCharge{get;set;}
	public Decimal totalHandlingCharges{get;set;}

	//-- Order Billing Info
	public Contact_DTO  billToContact{get;set;}
	public Address_DTO  billToAddress{get;set;}
	public String       billToInvoiceText{get;set;}
	public String       orderPONumber{get;set;}

	//-- Order Shipping Info
	public Contact_DTO  shipToContact{get;set;}
	public Address_DTO  shipToAddress{get;set;}
	//public String       shipToInstructionAttention{get;set;}
	//public String       shipToInstructionPhone{get;set;}
	//public String       shipToInstructionEmail{get;set;}
	public String       shipToInstructions{get;set;}

	public Boolean      shipToSameAsBilTo{get;set;}

	//-- Order Products
	public List<OrderItem_DTO> orderItems{get;set;}

	//to be deleted
	public Contact_DTO billTo{get;set;}
	public Contact_DTO shipTo{get;set;}

	public Order_DTO(){}

	public Order_DTO(String orderId)
	{
		Order sfOrder = Order_Sel.getOrderWithItems(orderId);
	}

	public Order_DTO(Order sfOrder)
	{
		orderStartDate          = sfOrder.EffectiveDate;
		orderPONumber           = sfOrder.PoNumber;
		orderType               = sfOrder.Type;
		orderStatus             = sfOrder.Status;
		orderPreviousType       = sfOrder.IEC_Order_Previous_Type__c;
		orderSource             = sfOrder.Source__c;
		orderChannel            = sfOrder.Order_Channel__c;
		orderNumber             = sfOrder.OrderNumber;
		orderInternalRemarks    = sfOrder.Internal_Remark__c;
		salesOrderRemarks       = sfOrder.Sales_Order_Remark__c;

		taxes                   = sfOrder.Taxes__c;
		totalHandlingCharges    = sfOrder.Total_handling_charges__c;
		orderId                 = sfOrder.Id;
		totalFreightCharge      = sfOrder.Total_Freight_Charge__c;
		orderSubTotalAmount     = sfOrder.SubTotal_Amount__c;
		orderDiscountAmount     = sfOrder.Discount_Amount__c;
		orderTotalAmount        = sfOrder.Total_Amount__c;

		billToContact = new Contact_DTO();
			billToContact.contactId         = sfOrder.BillToContactId;
			billToContact.contactName       = sfOrder.BillToContact_Name__c;
			billToContact.contactSalutation = sfOrder.BillToContact_Salutation__c;
			billToContact.contactFirstName  = sfOrder.BillToContact_First_Name__c;
			billToContact.contactLastName   = sfOrder.BillToContact_Last_Name__c;
			billToContact.accountId         = sfOrder.BillToAccount__c;
			billToContact.accountName       = sfOrder.BillToAccount_Name__c;
			billToContact.phone             = sfOrder.BillToContact_Phone__c;
			billToContact.email             = sfOrder.BillToContact_Email__c;


		billToAddress = Address_DTO.format2DTO(sfOrder.BillTo_Location__c);
		billToInvoiceText = sfOrder.Invoice_Text__c;

		shipToContact = new Contact_DTO();
			shipToContact.contactId     = sfOrder.ShipToContactId;
			shipToContact.contactName   = sfOrder.ShipToContact_Name__c;
			shipToContact.accountId     = sfOrder.ShipToAccount__c;
			shipToContact.accountName   = sfOrder.ShipToAccount_Name__c;
			shipToContact.phone         = sfOrder.ShipToContact_Phone__c;
			shipToContact.email         = sfOrder.ShipToContact_Email__c;

		shipToAddress = Address_DTO.format2DTO(sfOrder.ShipTo_Location__c);

		   /* new Address_DTO();
			shipToAddress.street1       = sfOrder.ShippingStreet;
			shipToAddress.city          = sfOrder.ShippingCity;
			shipToAddress.stateLabel    = sfOrder.ShippingState;
			shipToAddress.stateCode     = sfOrder.ShippingStateCode__c;
			shipToAddress.postalCode    = sfOrder.ShippingPostalCode;
			shipToAddress.countryLabel  = sfOrder.ShippingCountry;
			shipToAddress.countryCode   = sfOrder.ShippingCountryCode__c;
			shipToAddress.vatNumber     = sfOrder.ShipToContact_VAT_Number__c;*/

		//shipToInstructionAttention  = sfOrder.IEC_Shipping_Instruction_attention__c;
		//shipToInstructionPhone      = sfOrder.IEC_Shipping_Instruction_phone__c;
		//shipToInstructionEmail      = sfOrder.IEC_Shipping_Instruction_email__c;
		shipToInstructions          = sfOrder.Shipping_Instruction__c;

		shipToSameAsBilTo  = sfOrder.ShipTo_same_BillTo__c;

		//-- Order Products
		Map<Id, List<OrderItem>> orderItemsByOrder = new OrderItem_Sel().getOrderItems(new Set<Id>{sfOrder.Id});

		System.debug('orderItemsByOrder::'+orderItemsByOrder);

		orderItems = new List<OrderItem_DTO>();
		if(!orderItemsByOrder.isEmpty())
		{
			List<OrderItem> lst_orderItems = orderItemsByOrder.get(sfOrder.Id);

			//*** get price
			Map<String, PriceInfo_DTO> mapProductNumber_Price = new Map<String, PriceInfo_DTO>();
			Contact contactInfo = User_Sel.getContactDiscountInfo(sfOrder.ShipToContactId);
			for(OrderItem oi : lst_orderItems)
				mapProductNumber_Price.put(oi.Product_Number__c, null);
			Product_Sel exe = new Product_Sel();

			String customerType = User_Sel.getCustomerType(sfOrder.ShipToContactId);
			mapProductNumber_Price = exe.getProductPriceInfo(mapProductNumber_Price.keySet(), customerType
														   , (contactInfo == null ? null : contactInfo.Account.Region_formula__c), sfOrder.ShippingCountry, false);
														   //, contactInfo.Account.Region_formula__c, contactInfo.Account.ShippingCountry, false);

			orderItems = OrderItem_DTO.format2DTO(lst_orderItems, mapProductNumber_Price);
			orderItems = OrderItem_DTO.setTermAndConditions(orderItems, customerType );
		}
	}
}
