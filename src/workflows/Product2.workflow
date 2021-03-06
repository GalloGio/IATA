<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Five_days_defore_Effective_Date_Reached</fullName>
        <description>Five days defore Effective Date Reached</description>
        <protected>false</protected>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_Effective_to_Expiring</template>
    </alerts>
    <alerts>
        <fullName>New_product_is_created</fullName>
        <description>New product is created</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_has_been_added_in_Salesforce_from_SAP</template>
    </alerts>
    <alerts>
        <fullName>Notification_to_the_manager_for_Inactive_Product</fullName>
        <description>Notification to the manager for Inactive Product</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_has_been_made_inactive_from_SAP</template>
    </alerts>
    <alerts>
        <fullName>One_day_defore_Effective_Date_Reached</fullName>
        <description>One day defore Effective Date Reached</description>
        <protected>false</protected>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_Effective_to_Expiring</template>
    </alerts>
    <alerts>
        <fullName>Product_is_Out_of_stock</fullName>
        <description>Product is Out of stock</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_is_Out_of_Stock</template>
    </alerts>
    <alerts>
        <fullName>Product_new_version</fullName>
        <description>Product new version</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_being_replaced_by_a_newer_version</template>
    </alerts>
    <alerts>
        <fullName>Ten_days_before_the_effective_date_reached</fullName>
        <description>Ten days before the effective date reached</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_Effective_to_Expiring</template>
    </alerts>
    <alerts>
        <fullName>day_That_the_Effective_to</fullName>
        <description>Day that the Effective Date Reached</description>
        <protected>false</protected>
        <recipients>
            <field>Alternate_Product_Manager__c</field>
            <type>userLookup</type>
        </recipients>
        <recipients>
            <field>Product_Manager_lookup__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>ECOM_Notification_Templates/Product_Effective_to_Expired</template>
    </alerts>
    <fieldUpdates>
        <fullName>Update_the_date</fullName>
        <field>Effective_To__c</field>
        <formula>TODAY()</formula>
        <name>Update the Effective date</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Inactive product from SAP Inventory</fullName>
        <actions>
            <name>Notification_to_the_manager_for_Inactive_Product</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( 	IF( 		AND( 			PRIORVALUE(SAP_Status_Code__c) &lt;&gt; &quot;I&quot;,PRIORVALUE(SAP_Status_Code__c) &lt;&gt; &quot;Z3&quot; 		), 		true,false 	), 	IF( 		OR(SAP_Status_Code__c = &quot;I&quot;,SAP_Status_Code__c = &quot;Z3&quot;),  		true,false 	), 	IF( ISBLANK(Expected_Availability_Date__c), true,false) )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>New Product created</fullName>
        <actions>
            <name>New_product_is_created</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1</booleanFilter>
        <criteriaItems>
            <field>Product2.IsNewVersion__c</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>Product Effective Date Reached</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Product2.Effective_To__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>day_That_the_Effective_to</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Product2.Effective_To__c</offsetFromField>
            <timeLength>0</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Five_days_defore_Effective_Date_Reached</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Product2.Effective_To__c</offsetFromField>
            <timeLength>-5</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>Ten_days_before_the_effective_date_reached</name>
                <type>Alert</type>
            </actions>
            <actions>
                <name>Update_the_date</name>
                <type>FieldUpdate</type>
            </actions>
            <offsetFromField>Product2.Effective_To__c</offsetFromField>
            <timeLength>-10</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
        <workflowTimeTriggers>
            <actions>
                <name>One_day_defore_Effective_Date_Reached</name>
                <type>Alert</type>
            </actions>
            <offsetFromField>Product2.Effective_To__c</offsetFromField>
            <timeLength>-1</timeLength>
            <workflowTimeTriggerUnit>Days</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>Product is Out-of-Stock</fullName>
        <actions>
            <name>Product_is_Out_of_stock</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>AND( ISPICKVAL(PRIORVALUE( Inventory_Status__c ), &apos;In stock&apos;), TEXT( Inventory_Status__c ) = &apos;Out of stock&apos; )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Product new version</fullName>
        <actions>
            <name>Product_new_version</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Product2.IsNewVersion__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
