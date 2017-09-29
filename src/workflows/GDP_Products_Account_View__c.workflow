<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Remove_Pipes_from_Legal_Name1</fullName>
        <description>Remove the pipes from field Legal Name1</description>
        <field>Legal_Name_1__c</field>
        <formula>SUBSTITUTE( Legal_Name_1__c , &quot;|&quot;, &quot;&quot;)</formula>
        <name>Remove Pipes from Legal Name1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Pipes_from_Legal_Name2</fullName>
        <description>Remove Pipes from Legal Name2</description>
        <field>Legal_Name_2__c</field>
        <formula>SUBSTITUTE( Legal_Name_2__c , &apos;|&apos;, &apos;&apos;)</formula>
        <name>Remove Pipes from Legal Name2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Pipes_from_Trading_Name1</fullName>
        <description>Removes Pipes from Trading Name1</description>
        <field>Trading_Name_1__c</field>
        <formula>SUBSTITUTE(Trading_Name_1__c , &apos;|&apos;, &apos;&apos;)</formula>
        <name>Remove Pipes from Trading Name1</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_Pipes_from_Trading_Name2</fullName>
        <description>Remove Pipes from trading Name2</description>
        <field>Trading_Name_2__c</field>
        <formula>SUBSTITUTE(Trading_Name_2__c , &apos;|&apos;, &apos;&apos;)</formula>
        <name>Remove Pipes from Trading Name2</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Remove_pipes_from_Legal_Name3</fullName>
        <description>Remove Pipes from Legal Name3</description>
        <field>Legal_Name_3__c</field>
        <formula>SUBSTITUTE(Legal_Name_3__c , &apos;|&apos;, &apos;&apos;)</formula>
        <name>Remove pipes from Legal Name3</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Set_Agency_Code_Uniqueness_Key</fullName>
        <field>Agency_Code_Uniqueness_Validation__c</field>
        <formula>RecordTypeId + Agency_Code__c</formula>
        <name>Set Agency Code Uniqueness Key</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Remove pipes from Legal Names and Trading Name</fullName>
        <actions>
            <name>Remove_Pipes_from_Legal_Name1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_Pipes_from_Legal_Name2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_Pipes_from_Trading_Name1</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_Pipes_from_Trading_Name2</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Remove_pipes_from_Legal_Name3</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <description>Remove all pipes from Legal Name 1/2/3 and Trading Name 1/2</description>
        <formula>CONTAINS(Legal_Name_1__c , &apos;|&apos;) ||  CONTAINS(Legal_Name_2__c , &apos;|&apos;) ||  CONTAINS(Legal_Name_3__c , &apos;|&apos;) ||  CONTAINS(Trading_Name_1__c, &apos;|&apos;) ||  CONTAINS(Trading_Name_2__c, &apos;|&apos;)</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Validate Agency Code Uniqueness</fullName>
        <actions>
            <name>Set_Agency_Code_Uniqueness_Key</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>true</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
