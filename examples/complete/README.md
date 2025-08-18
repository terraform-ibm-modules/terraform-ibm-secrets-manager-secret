# Example creating arbitrary, username_password and imported_cert type secrets

- Creates new secrets-manager instance (if existing instance GUID not passed in)
- Creates new secret group
- Creates an arbitrary type secret in the secret group
- Creates an key-value type secret in the secret group
- Creates a username_password type secret in the secret group
- Creates a TLS cert, and adds it to secrets manager as an imported_cert secret type in the secret group
- Retrieves metadata for all the secrets created
