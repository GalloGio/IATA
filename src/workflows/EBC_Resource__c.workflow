<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Update_Image_Url</fullName>
        <field>Image_URL__c</field>
        <formula>SUBSTITUTE(Image_URL__c, &apos;https&apos;, &apos;http&apos;)</formula>
        <name>Update_Image_Url</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Update_Thumbnail_Url</fullName>
        <field>Thumbnail_URL__c</field>
        <formula>SUBSTITUTE(Thumbnail_URL__c, &apos;https&apos;, &apos;http&apos;)</formula>
        <name>Update_Thumbnail_Url</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>From_HTTPS_to_HTTP</fullName>
        <actions>
            <name>Update_Image_Url</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Update_Thumbnail_Url</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2</booleanFilter>
        <criteriaItems>
            <field>EBC_Resource__c.Thumbnail_URL__c</field>
            <operation>contains</operation>
            <value>https</value>
        </criteriaItems>
        <criteriaItems>
            <field>EBC_Resource__c.Image_URL__c</field>
            <operation>contains</operation>
            <value>https</value>
        </criteriaItems>
        <description>Substitute https to http</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
