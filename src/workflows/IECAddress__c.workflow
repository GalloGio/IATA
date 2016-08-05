<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Set_Full_Address</fullName>
        <field>Full_Address__c</field>
        <formula>Street__c &amp;
IF(ISBLANK(City__c), &quot;&quot;, &quot;, &quot; &amp; City__c) &amp; 
IF(ISBLANK(ISO_State__r.Name), IF(ISBLANK(ZipCode__c), &quot;&quot;, &quot;, &quot; &amp; ZipCode__c), &quot;, &quot; &amp; ISO_State__r.Name &amp; IF(ISBLANK(ZipCode__c), &quot;&quot;, &quot; &quot; &amp; ZipCode__c)) &amp; 
IF(ISBLANK(ISO_Country__r.Name), &quot;&quot;, &quot;, &quot; &amp; ISO_Country__r.Name)</formula>
        <name>Set Full Address</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Set_Full_Address</fullName>
        <actions>
            <name>Set_Full_Address</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>IECAddress__c.CreatedById</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
