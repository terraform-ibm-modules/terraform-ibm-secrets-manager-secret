# Private-Only Secret Manager example

An end-to-end example that uses a private-only Secret Manager. This example uses the IBM Cloud terraform provider to:
 - Create a new resource group if one is not passed in.
 - Create a new secrets manager if one is not passed in.
 - Create a new secrets manager group and private secret engine if existing secrets manager is not passed in.
 - Create a new private certifcate inside a secrets manager.
