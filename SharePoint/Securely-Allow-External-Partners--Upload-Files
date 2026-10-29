# Securely Allow External Partners to Upload Files to SharePoint

## Overview

This guide explains how to securely allow external partners, vendors, or customers to upload files to SharePoint while limiting their access to company data.

## Best Practice

Rather than granting access to an existing business site, create a dedicated site specifically for external collaboration.

Benefits:

- Isolates external users from internal content
- Simplifies permission management
- Reduces the risk of accidental data exposure
- Makes auditing and access reviews easier

---

## Option 1 - Create a Dedicated External Collaboration Site (Recommended)

### Create a New Site

1. Open the SharePoint Admin Center.
2. Create a new Team Site or Communication Site.
3. Name the site appropriately.

Example:

- Partner Upload Site
- Vendor Document Exchange
- Customer File Submission Portal

### Configure External Sharing

1. Open the site settings.
2. Navigate to Sharing settings.
3. Enable external sharing.
4. Allow only authenticated external users when possible.

### Invite External Users

1. Open Site Permissions.
2. Select **Add Members**.
3. Enter the partner's email address.
4. Send the invitation.

---

## Option 2 - Create a Dedicated Upload Folder

If a separate site is not possible:

1. Create a dedicated document library or folder.
2. Break permission inheritance.
3. Remove unnecessary groups.
4. Grant access only to required external users.

Avoid granting access to the entire document library when a single folder is sufficient.

---

## Apply Custom Permissions

### Open Site Permissions

1. Open the SharePoint site.
2. Click the **Settings** icon.
3. Select **Site Permissions**.
4. Choose **Advanced Permission Settings**.

### Create a Custom Permission Level

1. Select **Permission Levels**.
2. Click **Add a Permission Level**.
3. Select only the permissions required.
4. Save the new permission level.

Examples:

- Upload Only
- Contribute Without Delete
- Limited Contributor

### Assign Permissions

1. Navigate to the target folder.
2. Select **Manage Access**.
3. Open **Advanced Settings**.
4. Select the user or group.
5. Choose **Edit User Permissions**.
6. Assign the custom permission level.

---

## Security Recommendations

### Follow the Principle of Least Privilege

Grant only the minimum permissions required.

Examples:

✅ Upload files

✅ View uploaded files

❌ Site administration

❌ Permission management

❌ Access to unrelated folders

---

### Use Dedicated Security Groups

Instead of assigning permissions individually:

1. Create a security group.
2. Add external users to the group.
3. Assign permissions to the group.

This simplifies future access reviews.

---

### Review External Access Regularly

At regular intervals:

- Review external users
- Remove inactive accounts
- Verify permissions remain appropriate
- Audit document access

---

## Alternative: Use a File Request

For scenarios where external users only need to submit documents:

1. Create a folder in a document library.
2. Generate a File Request link.
3. Send the link to the external party.

Benefits:

- Users can upload files without browsing the site.
- Internal content remains hidden.
- Simpler user experience.
- Lower security risk.

---

## Best Practices

- Create a dedicated collaboration site for external users.
- Use authenticated external accounts whenever possible.
- Limit access to specific folders or libraries.
- Avoid granting Full Control permissions.
- Review external access regularly.
- Remove access when the engagement is complete.
- Use File Requests when users only need to upload documents.

## Result

External partners can securely upload documents while minimizing exposure to internal company content and maintaining proper access controls.
