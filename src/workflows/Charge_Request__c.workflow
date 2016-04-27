<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Unit_Price</fullName>
        <description>Update Unit Price for non IATA membership</description>
        <field>Unit_Price_List__c</field>
        <literalValue>7500.00</literalValue>
        <name>Update Unit Price_BSP JOIN</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Update Unit Price</fullName>
        <actions>
            <name>Update_Unit_Price</name>
            <type>FieldUpdate</type>
        </actions>
        <active>false</active>
        <booleanFilter>1 AND 2</booleanFilter>
        <criteriaItems>
            <field>Charge_Request__c.IATA_Membership__c</field>
            <operation>equals</operation>
            <value>No</value>
        </criteriaItems>
        <criteriaItems>
            <field>Charge_Request__c.Product_Service__c</field>
            <operation>equals</operation>
            <value>BSPFEE_JOIN</value>
        </criteriaItems>
        <description>Update Unit Price for Mon IATA menbership for BSPFEE_JOIN - 7,500 and CASS_JOIN - 3,500.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
