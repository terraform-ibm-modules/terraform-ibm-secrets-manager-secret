# Private-Only Secret Manager example

<!-- BEGIN SCHEMATICS DEPLOY HOOK -->
<a href="https://cloud.ibm.com/schematics/workspaces/create?workspace_name=secrets-manager-secret-private-example&repository=https://github.com/terraform-ibm-modules/terraform-ibm-secrets-manager-secret/tree/main/examples/private"><img src="https://img.shields.io/badge/Deploy%20with IBM%20Cloud%20Schematics-0f62fe?logo=ibm&logoColor=white&labelColor=0f62fe" alt="Deploy with IBM Cloud Schematics" style="height: 16px; vertical-align: text-bottom;"></a>
<!-- END SCHEMATICS DEPLOY HOOK -->


An end-to-end example that uses a private-only Secret Manager. This example uses the IBM Cloud terraform provider to:
 - Create a new resource group if one is not passed in.
 - Create a new secrets manager if one is not passed in.
 - Create a new secrets manager group and private secret engine if existing secrets manager is not passed in.
 - Create a new private certificate inside a secrets manager.

<!-- BEGIN SCHEMATICS DEPLOY TIP HOOK -->
:information_source: Ctrl/Cmd+Click or right-click on the Schematics deploy button to open in a new tab
<!-- END SCHEMATICS DEPLOY TIP HOOK -->
