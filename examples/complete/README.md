# Example creating arbitrary, username_password and imported_cert type secrets

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-secret-complete-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-secret/tree/main/examples/complete"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


- Creates new secrets-manager instance (if existing instance GUID not passed in)
- Creates new secret group
- Creates an arbitrary type secret in the secret group
- Creates an key-value type secret in the secret group
- Creates a username_password type secret in the secret group
- Creates a TLS cert, and adds it to secrets manager as an imported_cert secret type in the secret group
- Retrieves metadata for all the secrets created

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
