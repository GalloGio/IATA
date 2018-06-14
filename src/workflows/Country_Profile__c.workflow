<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <fieldUpdates>
        <fullName>Clear_News_Text</fullName>
        <description>Clear the contents of the News Text field.</description>
        <field>News_Text__c</field>
        <name>Clear News Text</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Notification_Message</fullName>
        <description>Remove the contents of the Notification Message field</description>
        <field>Notification_Message__c</field>
        <name>Clear Notification Message</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Null</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Publish_News</fullName>
        <description>Remove the value in the Publish News pick list</description>
        <field>Publish_News__c</field>
        <name>Clear Publish News</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Clear_Send_Notifications</fullName>
        <description>Remove the value in the Send Notifications pick list</description>
        <field>Send_Notifications__c</field>
        <name>Clear Send Notifications</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>Country Profile Cleanup After Upsert</fullName>
        <actions>
            <name>Clear_News_Text</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Notification_Message</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Publish_News</name>
            <type>FieldUpdate</type>
        </actions>
        <actions>
            <name>Clear_Send_Notifications</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 OR 2 OR 3 OR 4</booleanFilter>
        <criteriaItems>
            <field>Country_Profile__c.News_Text__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Country_Profile__c.Notification_Message__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Country_Profile__c.Publish_News__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Country_Profile__c.Send_Notifications__c</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Resets the notification and news related fields after the record is inserted or updated.</description>
        <triggerType>onAllChanges</triggerType>
    </rules>
</Workflow>
