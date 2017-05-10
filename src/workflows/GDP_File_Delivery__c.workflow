<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>IEC_GDP_File_Delivery_Email_Notification_GSS</fullName>
        <description>IEC GDP File Delivery Email Notification - GSS</description>
        <protected>false</protected>
        <recipients>
            <field>Technical_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>CurrentUser</senderType>
        <template>IEC_GDP/IEC_GDP_File_Delivery_Notification_GSS</template>
    </alerts>
    <alerts>
        <fullName>IEC_GDP_File_Delivery_Email_Notification_MDP</fullName>
        <description>IEC GDP File Delivery Email Notification - MDP</description>
        <protected>false</protected>
        <recipients>
            <field>Technical_Contact_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>CurrentUser</senderType>
        <template>IEC_GDP/IEC_GDP_File_Delivery_Notification_MDP</template>
    </alerts>
    <fieldUpdates>
        <fullName>IEC_GDP_File_Delivery_Field_Update</fullName>
        <field>Notification__c</field>
        <literalValue>2</literalValue>
        <name>IEC GDP File Delivery Field Update</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>IEC GDP File Delivery Email Notification - GSS</fullName>
        <actions>
            <name>IEC_GDP_File_Delivery_Email_Notification_GSS</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IEC_GDP_File_Delivery_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISPICKVAL(Status__c, &quot;Completed&quot;) 	, ISPICKVAL(Notification__c, &quot;1&quot;) 	, ISPICKVAL(File_Specification__r.Product_Type__c, &quot;GSS&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IEC GDP File Delivery Email Notification - MDP</fullName>
        <actions>
            <name>IEC_GDP_File_Delivery_Email_Notification_MDP</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>IEC_GDP_File_Delivery_Field_Update</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <formula>AND( 	ISPICKVAL(Status__c, &quot;Completed&quot;) 	, ISPICKVAL(Notification__c, &quot;1&quot;) 	, ISPICKVAL(File_Specification__r.Product_Type__c, &quot;MDP&quot;) )</formula>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
</Workflow>
