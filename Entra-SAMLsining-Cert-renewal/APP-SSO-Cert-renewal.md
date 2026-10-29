This is a Microsoft Entra ID SAML Signing Certificate renewal for APP, used for Single Sign-On (SSO). It is specifically related to authentication between Microsoft Entra ID (Azure AD) and your company's APP application.

### Please renew your application certificate.

## Recommended action

We recommend you renew the certificate in APP before November 2, 2026 15:38 UTC to avoid downtime with single sign-on. Please follow the steps below.  
In the Azure portal, go to the Single sign-on page for APP.  
In the SAML Signing Certificate section, click Create new certificate.  
Choose a duration of up to 3 years, then click Save, then click OK.  
Select Make new certificate active and click Save at the top. This will roll over your existing certificate to the newly created certificate.  
Download the new certificate and upload it to APP.  
Rolling the certificate in Microsoft Entra ID and configuring it in your app may cause single sign-on downtime. Please plan for potential downtime when performing the steps above.  

## More information
Learn more about managing certificates for federated SSO in Microsoft Entra ID.  
The tenant admin determines the recipients of e-mails like these. Contact the tenant admin to opt out.  
