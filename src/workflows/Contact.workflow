<?xml version="1.0" encoding="UTF-8"?>
<Workflow xmlns="http://soap.sforce.com/2006/04/metadata">
    <alerts>
        <fullName>Alert_admins_that_a_contact_has_registered</fullName>
        <ccEmails>noreply@iata.org</ccEmails>
        <description>Alert admins that a contact has registered</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portal Administrator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_Admin_of_user_creationVF</template>
    </alerts>
    <alerts>
        <fullName>Alert_admins_that_a_contact_has_registered_cns</fullName>
        <ccEmails>noreply@iata.org</ccEmails>
        <description>Alert admins that a contact has registered - CNS</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portal Administrator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/Notify_Admin_of_user_creationVF_cns</template>
    </alerts>
    <alerts>
        <fullName>EF_Email_Notification_On_Client_EF_Contact_Deactivation</fullName>
        <ccEmails>efs@iata.org</ccEmails>
        <description>E&amp;F : Email Notification On Client E&amp;F Contact Deactivation</description>
        <protected>false</protected>
        <recipients>
            <recipient>EF_Client_Users_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/EF_Contact_Deactivation_Notification</template>
    </alerts>
    <alerts>
        <fullName>EF_Email_Notification_On_Operator_EF_Contact_Deactivation</fullName>
        <ccEmails>efs@iata.org</ccEmails>
        <description>E&amp;F : Email Notification On Operator E&amp;F Contact Deactivation</description>
        <protected>false</protected>
        <recipients>
            <recipient>EF_Operator_Users_Group</recipient>
            <type>group</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>All/EF_Contact_Deactivation_Notification</template>
    </alerts>
    <alerts>
        <fullName>ISSP_BSPCASS_Payment_contact</fullName>
        <description>ISSP_BSPCASS Payment contact</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portal Administrator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_BSP_CASS_Payment_contact</template>
    </alerts>
    <alerts>
        <fullName>ISSP_BSPCASS_Payment_contact_cns</fullName>
        <description>ISSP_BSPCASS Payment contact - CNS</description>
        <protected>false</protected>
        <recipients>
            <recipient>Portal Administrator</recipient>
            <type>accountTeam</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_BSP_CASS_Payment_contact</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Notify_Contact_TD_Granted</fullName>
        <description>ISSP Notify Contact TD Granted</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_T_Dashboard_granted</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Notify_Contact_TD_Premium_Granted</fullName>
        <description>ISSP Notify Contact TD Premium Granted</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_TDpremium_granted</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Notify_Contact_TD_Premium_Granted_First</fullName>
        <description>ISSP Notify Contact TD Premium Granted First</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Notify_contact_of_TDpremium_granted_First</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Notify_Portal_User_Status_Change_UnknownContact</fullName>
        <description>ISSP Notify Portal User Status Change_UnknownContact</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Old_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_User_Status_Change_Inac_VF</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Notify_Portal_User_Status_Change_UnknownContact_cns</fullName>
        <description>ISSP Notify Portal User Status Change_UnknownContact - CNS</description>
        <protected>false</protected>
        <recipients>
            <field>Contact_Old_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_User_Status_Change_VF_CNS</template>
    </alerts>
    <alerts>
        <fullName>ISSP_Send_alert_to_Contact_User_if_someone_is_modifying_his_info</fullName>
        <description>ISSP Send alert to Contact User if someone is modifying his info</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISSP_Alert_If_Contact_Info_Is_Modified</template>
    </alerts>
    <alerts>
        <fullName>ISS_Send_Change_Of_Portal_User_Status_Notification</fullName>
        <description>ISS Send Change Of Portal User Status Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_User_Status_Change_VF</template>
    </alerts>
    <alerts>
        <fullName>ISS_Send_Change_Of_Portal_User_Status_Notification_cns</fullName>
        <description>ISS Send Change Of Portal User Status Notification</description>
        <protected>false</protected>
        <recipients>
            <field>Email</field>
            <type>email</type>
        </recipients>
        <senderAddress>cns_noreply@cnsc.us</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ISS_Portal/ISS_Portal_User_Status_Change_VF_CNS</template>
    </alerts>
    <alerts>
        <fullName>Renewal_Email_alert</fullName>
        <ccEmails>emailtosalesforce@63lv520ssbnqnqm4j9qg25k5r.2-8tfeay.eu3.le.salesforce.com</ccEmails>
        <description>Renewal Email alert</description>
        <protected>false</protected>
        <recipients>
            <field>IDcard_Email__c</field>
            <type>email</type>
        </recipients>
        <senderAddress>noreply@iata.org</senderAddress>
        <senderType>OrgWideEmailAddress</senderType>
        <template>ID_Card_templates/IDCard_RenewalEmail</template>
    </alerts>
    <fieldUpdates>
        <fullName>Contact_Owner</fullName>
        <field>OwnerId</field>
        <lookupValue>administrator@iata.org</lookupValue>
        <lookupValueType>User</lookupValueType>
        <name>Contact Owner</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>LookupValue</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>ISS_Portal_deactivate_inactive_contact</fullName>
        <field>User_Portal_Status__c</field>
        <literalValue>Deactivated</literalValue>
        <name>ISS Portal deactivate inactive contact</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Make_SIS_Super_User</fullName>
        <description>Makes SIS Contact Type = SIS Super User when Invoicing Contact is flagged as TRUE</description>
        <field>SIS_Contact_Type__c</field>
        <literalValue>Super User</literalValue>
        <name>Make SIS Super User</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>New_user_portal</fullName>
        <field>Notification_Template__c</field>
        <formula>&quot;NT-0033&quot;</formula>
        <name>New user portal</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Formula</operation>
        <protected>false</protected>
    </fieldUpdates>
    <fieldUpdates>
        <fullName>Reset_SendIDCardRenewalNotice_c</fullName>
        <field>SendIDCardRenewalNotice__c</field>
        <literalValue>0</literalValue>
        <name>Reset SendIDCardRenewalNotice__c</name>
        <notifyAssignee>false</notifyAssignee>
        <operation>Literal</operation>
        <protected>false</protected>
    </fieldUpdates>
    <rules>
        <fullName>E%26F %3A Notification On Client Contact Deactivation</fullName>
        <actions>
            <name>EF_Email_Notification_On_Client_EF_Contact_Deactivation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Status__c</field>
            <operation>equals</operation>
            <value>Left Company / Relocated,Retired,Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.EF_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.EF_Type__c</field>
            <operation>equals</operation>
            <value>E&amp;F Client</value>
        </criteriaItems>
        <description>Notification of deactivated client E&amp;F contact</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>E%26F %3A Notification On Operator Contact Deactivation</fullName>
        <actions>
            <name>EF_Email_Notification_On_Operator_EF_Contact_Deactivation</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.EF_Status__c</field>
            <operation>equals</operation>
            <value>Active</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Status__c</field>
            <operation>equals</operation>
            <value>Left Company / Relocated,Retired,Inactive</value>
        </criteriaItems>
        <criteriaItems>
            <field>Account.EF_Type__c</field>
            <operation>equals</operation>
            <value>E&amp;F Operator</value>
        </criteriaItems>
        <description>Notification of deactivated operator E&amp;F contact</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>IDCard_RenewalNotice</fullName>
        <actions>
            <name>Renewal_Email_alert</name>
            <type>Alert</type>
        </actions>
        <actions>
            <name>Reset_SendIDCardRenewalNotice_c</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.SendIDCardRenewalNotice__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.HasOptedOutOfEmail</field>
            <operation>equals</operation>
            <value>False</value>
        </criteriaItems>
        <description>Send a renewal Email if the contact has an IDCard that meets the reminder criteria</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP - Change Owner to IATA System</fullName>
        <active>true</active>
        <criteriaItems>
            <field>User.UserType</field>
            <operation>notEqual</operation>
            <value>Standard</value>
        </criteriaItems>
        <triggerType>onCreateOnly</triggerType>
        <workflowTimeTriggers>
            <actions>
                <name>Contact_Owner</name>
                <type>FieldUpdate</type>
            </actions>
            <timeLength>1</timeLength>
            <workflowTimeTriggerUnit>Hours</workflowTimeTriggerUnit>
        </workflowTimeTriggers>
    </rules>
    <rules>
        <fullName>ISSP Notify Contact TD Granted</fullName>
        <actions>
            <name>ISSP_Notify_Contact_TD_Granted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Service_TD_Basic__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Sends email to notify Contact of access granted to Treasury Dashboard Basic</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Notify Contact TD Premium Granted</fullName>
        <actions>
            <name>ISSP_Notify_Contact_TD_Premium_Granted</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Service_TD_Premium__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Service_TD_Basic_exists__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <description>Sends email to notify Contact of access granted to Treasury Dashboard PREMIUM</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP Notify Contact TD Premium Granted_First</fullName>
        <actions>
            <name>ISSP_Notify_Contact_TD_Premium_Granted_First</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Service_TD_Premium__c</field>
            <operation>equals</operation>
            <value>1</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Service_TD_Basic_exists__c</field>
            <operation>equals</operation>
            <value>0</value>
        </criteriaItems>
        <description>Sends email to notify Contact of access granted to Treasury Dashboard PREMIUM, with NO existing prior subscription to TD Basic</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP_BSPCASS Payment contact</fullName>
        <actions>
            <name>ISSP_BSPCASS_Payment_contact</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <booleanFilter>1 AND NOT( 2)</booleanFilter>
        <criteriaItems>
            <field>Contact.BSP_CASS_Payment_contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Community__c</field>
            <operation>startsWith</operation>
            <value>CNS</value>
        </criteriaItems>
        <description>Send email to Portal Admins when &quot;BSP/CASS Payment contact&quot; checkbox is checked on the Contact (in Portal the user can do it in the My Profile page)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>ISSP_BSPCASS Payment contact - CNS</fullName>
        <actions>
            <name>ISSP_BSPCASS_Payment_contact_cns</name>
            <type>Alert</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.BSP_CASS_Payment_contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <criteriaItems>
            <field>Contact.Community__c</field>
            <operation>startsWith</operation>
            <value>CNS</value>
        </criteriaItems>
        <description>Send email to Portal Admins when &quot;BSP/CASS Payment contact&quot; checkbox is checked on the Contact (in Portal the user can do it in the My Profile page)</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <rules>
        <fullName>Mark Invoicing contact as SIS Super User</fullName>
        <actions>
            <name>Make_SIS_Super_User</name>
            <type>FieldUpdate</type>
        </actions>
        <active>true</active>
        <criteriaItems>
            <field>Contact.Invoicing_Contact__c</field>
            <operation>equals</operation>
            <value>True</value>
        </criteriaItems>
        <description>Updates SIS Contact Type to super user to allow the web service for user creation in SIS to go smoothly.</description>
        <triggerType>onCreateOrTriggeringUpdate</triggerType>
    </rules>
    <tasks>
        <fullName>ID_Card_Renewal_Notice</fullName>
        <assignedToType>owner</assignedToType>
        <dueDateOffset>0</dueDateOffset>
        <notifyAssignee>false</notifyAssignee>
        <priority>Normal</priority>
        <protected>false</protected>
        <status>Completed</status>
        <subject>ID Card Renewal Notice</subject>
    </tasks>
</Workflow>
