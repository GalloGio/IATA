<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Industry_Group_Unique_Name</fullName>
        <description>To be used for Reg / Div Groups. Copies the Name field into the Unique Name field.</description>
        <field>Unique_Name__c</field>
        <formula>Name</formula>
        <name>Set Industry Group Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Change_recordtype</fullName>
        <description>Change the recordtype from draft to permanent to hide the Approval History on the assigned page layout</description>
        <field>RecordTypeId</field>
        <lookupValue>Reg_Div_Groups</lookupValue>
        <lookupValueType>RecordType</lookupValueType>
        <name>Change recordtype</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Local_Governance_Name</fullName>
        <field>Name</field>
        <formula>IF( ISBLANK(Country__c), Cluster__r.Name, Country__r.Name) +
&quot; - &quot;+
TEXT(Local_Governance_type__c)+
IF(Active__c, &quot;&quot;, &quot; - INACTIVE&quot;)</formula>
        <name>Set Local Governance Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Local_Governance_Unique_Name</fullName>
        <field>Unique_Name__c</field>
        <formula>IF(Active__c, (

RecordType.Name + &quot; - &quot; + IF( ISBLANK(Country__c), Cluster__r.Name, Country__r.Name) +&quot; - &quot;+ TEXT(Local_Governance_type__c)

), 
&quot;&quot;)</formula>
        <name>Set Local Governance Unique Name</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_Approved</fullName>
        <field>Approved__c</field>
        <literalValue>1</literalValue>
        <name>Set as Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_as_Not_Approved</fullName>
        <field>Approved__c</field>
        <literalValue>0</literalValue>
        <name>Set as Not Approved</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Local Governance Auto Name</fullName>
        <actions>
            <name>Set_Local_Governance_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Set_Local_Governance_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Local Groups</value>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>Reg %2F Div Group Auto Unique Name</fullName>
        <actions>
            <name>Set_Industry_Group_Unique_Name</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>LocalGovernance__c.Name</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>LocalGovernance__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>Reg/Div Groups,Draft Reg/Div Group</value>
        </criteriaItems>
        <description>Fill the Unique Name field for industry groups with the (Draft) Reg / Div Group record types</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
