<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>GDP_File_Description_Rt_Plan_Unique_Key</fullName>
        <description>Set GDP_File_Description_To_Rate_Plan.Unique_Key = GDP_File_Description.Id + zqu_Product_Rate_Plan.Id</description>
        <field>Unique_Key__c</field>
        <formula>GDP_File_Description__r.Id + &apos;-&apos; +  Product_Rate_Plan__r.Id</formula>
        <name>GDP File Description Rt Plan Unique Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>GDP File Description To Rate Plan Unique Pair</fullName>
        <actions>
            <name>GDP_File_Description_Rt_Plan_Unique_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Ensure that a GDP File Description matching with Product Rate Plan is defined only once.</description>
        <formula>TRUE</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
