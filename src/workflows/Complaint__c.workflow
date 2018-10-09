<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>AME_Complaint_out_of_Complaint_team_notification</fullName>
        <description>AME: Complaint out of Complaint team notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>suwal@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/AME_Complaint_out_of_Complaint_Team</template>
    </alerts>
    <alerts>
        <fullName>BJS_Complaint_Notification_email_to_Complaint_Owner</fullName>
        <description>BJS: Complaint_Notification email to Complaint Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/BJS_Complaintassignment</template>
    </alerts>
    <alerts>
        <fullName>BJS_Complaint_out_of_Complaint_team_notification</fullName>
        <description>BJS: Complaint out of Complaint team notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>hyokcholk@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/BJS_Complaint_out_of_Complaint_Team</template>
    </alerts>
    <alerts>
        <fullName>SCA_Complaint_Notification_email_to_Complaint_Owner</fullName>
        <description>SCA: Complaint_Notification email to Complaint Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/SCA_Complaintassignment</template>
    </alerts>
    <alerts>
        <fullName>SCA_Complaint_out_of_Complaint_team_notification</fullName>
        <description>SCA: Complaint out of Complaint team notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>medeirosk@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>montielk@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>solorzanoj@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/SCA_Complaint_out_of_Complaint_Team</template>
    </alerts>
    <alerts>
        <fullName>SIN_Complaint_Notification_email_to_Complaint_Owner</fullName>
        <description>SIN: Complaint_Notification email to Complaint Owner</description>
        <protected>false</protected>
        <recipients>
            <field>Owner__c</field>
            <type>userLookup</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/SIN_Complaintassignment</template>
    </alerts>
    <alerts>
        <fullName>SIN_Complaint_out_of_Complaint_team_notification</fullName>
        <description>SIN: Complaint out of Complaint team notification</description>
        <protected>false</protected>
        <recipients>
            <recipient>mohananb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>shahb@iata.org</recipient>
            <type>user</type>
        </recipients>
        <recipients>
            <recipient>vitharanai@iata.org</recipient>
            <type>user</type>
        </recipients>
        <senderType>CurrentUser</senderType>
        <template>All/SIN_Complaint_out_of_Complaint_Team</template>
    </alerts>
    <rules>
        <fullName>AME%3A COMPLAINT_Notify Complaint Owner</fullName>
        <active>true</active>
        <formula>ISCHANGED(  OwnerId  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>AME%3A COMPLAINT_Notify Complaint Owner_II</fullName>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>AME%3A Complaint not assigned to Complaint Team</fullName>
        <actions>
            <name>AME_Complaint_out_of_Complaint_team_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Motaz Nofal,Luma Arafat,Fayez Shalbak</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.Object_type__c</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.ComplaintRegion__c</field>
            <operation>equals</operation>
            <value>Africa &amp; Middle East</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BJS%3A COMPLAINT_Notify Complaint Owner</fullName>
        <actions>
            <name>BJS_Complaint_Notification_email_to_Complaint_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(  OwnerId  )  &amp;&amp;   ComplaintRegion__c  = &quot;China &amp; North Asia&quot;</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>BJS%3A COMPLAINT_Notify Complaint Owner_II</fullName>
        <actions>
            <name>BJS_Complaint_Notification_email_to_Complaint_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.ComplaintRegion__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>BJS%3A Complaint not assigned to Complaint Team</fullName>
        <actions>
            <name>BJS_Complaint_out_of_Complaint_team_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Hyok Chol Kang,Yiyi Wang,Yao Gu,Jiao XU,Wenpeng Xie</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.Object_type__c</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.ComplaintRegion__c</field>
            <operation>equals</operation>
            <value>China &amp; North Asia</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>COMPLAINT_Automatic messsage to customer_ENG</fullName>
        <active>false</active>
        <criteriaItems>
            <field>Case.BSPCountry__c</field>
            <operation>equals</operation>
        </criteriaItems>
        <description>Automatic message to customer to inform that the case is being categorized as a complaint</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>SCA%3A COMPLAINT_Notify Complaint Owner</fullName>
        <actions>
            <name>SCA_Complaint_Notification_email_to_Complaint_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <description>Notify Complaint Owner about any change</description>
        <formula>ISCHANGED(  OwnerId  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SCA%3A COMPLAINT_Notify Complaint Owner_II</fullName>
        <actions>
            <name>SCA_Complaint_Notification_email_to_Complaint_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <description>Notify Complaint Team when record has been created</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SCA%3A Complaint not assigned to Complaint Team</fullName>
        <actions>
            <name>SCA_Complaint_out_of_Complaint_team_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Jose Solorzano,Kathleen Montiel,Karina Medeiros</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.Object_type__c</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.ComplaintRegion__c</field>
            <operation>equals</operation>
            <value>Americas</value>
        </criteriaItems>
        <description>Show cases not assigned to Complaint Team</description>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIN%3A COMPLAINT_Notify Complaint Owner</fullName>
        <actions>
            <name>SIN_Complaint_Notification_email_to_Complaint_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <formula>ISCHANGED(  OwnerId  )</formula>
        <triggerType>onAllChanges</triggerType>
    </rules>
    <rules>
        <fullName>SIN%3A COMPLAINT_Notify Complaint Owner_II</fullName>
        <actions>
            <name>SIN_Complaint_Notification_email_to_Complaint_Owner</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.OwnerId</field>
            <operation>notEqual</operation>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
    <rules>
        <fullName>SIN%3A Complaint not assigned to Complaint Team</fullName>
        <actions>
            <name>SIN_Complaint_out_of_Complaint_team_notification</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Complaint__c.CreatedById</field>
            <operation>notEqual</operation>
            <value>Bineetha Mohanan,VITHARANA Indrajith,SHAH Bhavini</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.Object_type__c</field>
            <operation>equals</operation>
            <value>Complaint</value>
        </criteriaItems>
        <criteriaItems>
            <field>Complaint__c.ComplaintRegion__c</field>
            <operation>equals</operation>
            <value>Asia &amp; Pacific</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
    </rules>
</Workflow>
