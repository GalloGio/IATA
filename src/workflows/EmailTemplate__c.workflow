<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Fill_EmailTemplate_UniqueId</fullName>
        <field>UniqueId__c</field>
        <formula>RecordType.DeveloperName + &apos;_&apos; + IF(OR(TEXT(Agent_Type__c)=&apos;All&apos;, TEXT(Agent_Type__c)=&apos;&apos;),&apos;&apos; ,IF(TEXT(Agent_Type__c)=&apos;IATA Passenger Sales Agent&apos;,&apos;PAX_&apos;,&apos;CGO_&apos;)) + IATA_ISO_Country__r.ISO_Code__c + &apos;_&apos; + TEXT(Template_Language__c)</formula>
        <name>Fill EmailTemplate UniqueId</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>FSM Update UniqueId Value on Email Template</fullName>
        <actions>
            <name>Fill_EmailTemplate_UniqueId</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>EmailTemplate__c.RecordTypeId</field>
            <operation>equals</operation>
            <value>FSM</value>
        </criteriaItems>
        <description>Fills the UniqueId if it&apos;s empty</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
