package test

import (
	"log"
	"os"
	"testing"

	"github.com/stretchr/testify/assert"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testhelper"
	"github.com/terraform-ibm-modules/ibmcloud-terratest-wrapper/testschematic"
	"gopkg.in/yaml.v3"
)

// Resource groups are maintained https://github.ibm.com/GoldenEye/ge-dev-account-management
const resourceGroup = "geretain-test-secrets-manager"
const terraformDir = "examples/complete"

// Define a struct with fields that match the structure of the YAML data
const yamlLocation = "../common-dev-assets/common-go-assets/common-permanent-resources.yaml"

const bestRegionYAMLPath = "../common-dev-assets/common-go-assets/cloudinfo-region-secmgr-prefs.yaml"

type Config struct {
	SmGuid          string `yaml:"secretsManagerGuid"`
	SmRegion        string `yaml:"secretsManagerRegion"`
	PrvOnlySmCRN    string `yaml:"privateOnlySecMgrCRN"`
	PrvOnlySmRegion string `yaml:"privateOnlySecMgrRegion"`
}

var smGuid string
var smRegion string
var prvOnlySmCRN string
var prvOnlySmRegion string

// TestMain will be run before any parallel tests, used to read data from yaml for use with tests
func TestMain(m *testing.M) {
	// Read the YAML file contents
	data, err := os.ReadFile(yamlLocation)
	if err != nil {
		log.Fatal(err)
	}
	// Create a struct to hold the YAML data
	var config Config
	// Unmarshal the YAML data into the struct
	err = yaml.Unmarshal(data, &config)
	if err != nil {
		log.Fatal(err)
	}
	// Parse the SM guid and region from data
	smGuid = config.SmGuid
	smRegion = config.SmRegion
	prvOnlySmCRN = config.PrvOnlySmCRN
	prvOnlySmRegion = config.PrvOnlySmRegion
	os.Exit(m.Run())
}
func setupOptions(t *testing.T, prefix string, dir string) *testhelper.TestOptions {

	options := testhelper.TestOptionsDefaultWithVars(&testhelper.TestOptions{
		Testing:       t,
		TerraformDir:  dir,
		Prefix:        prefix,
		ResourceGroup: resourceGroup,
		TerraformVars: map[string]interface{}{
			"existing_sm_instance_guid":   smGuid,
			"existing_sm_instance_region": smRegion,
		},
	})

	return options
}

func TestRunCompleteExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sm-secret-module", terraformDir)
	output, err := options.RunTestConsistency()
	assert.Nil(t, err, "This should not have errored")
	assert.NotNil(t, output, "Expected some output")
}

func TestRunUpgradeExample(t *testing.T) {
	t.Parallel()

	options := setupOptions(t, "sm-secret-module-upg", terraformDir)
	output, err := options.RunTestUpgrade()
	if !options.UpgradeTestSkipped {
		assert.Nil(t, err, "This should not have errored")
		assert.NotNil(t, output, "Expected some output")
	}
}

func TestPrivateInSchematics(t *testing.T) {
	t.Parallel()

	const testLocation = "examples/private"

	options := testschematic.TestSchematicOptionsDefault(&testschematic.TestSchematicOptions{
		Testing: t,
		Prefix:  "sm-s-private",
		TarIncludePatterns: []string{
			"*.tf",
			testLocation + "/*.tf",
		},
		ResourceGroup:          resourceGroup,
		TemplateFolder:         testLocation,
		Tags:                   []string{"test-schematic"},
		DeleteWorkspaceOnFail:  false,
		WaitJobCompleteMinutes: 80,
		BestRegionYAMLPath:     bestRegionYAMLPath,
	})

	options.TerraformVars = []testschematic.TestSchematicTerraformVar{
		{Name: "ibmcloud_api_key", Value: options.RequiredEnvironmentVars["TF_VAR_ibmcloud_api_key"], DataType: "string", Secure: true},
		{Name: "resource_tags", Value: options.Tags, DataType: "list(string)"},
		{Name: "region", Value: options.Region, DataType: "string"},
		{Name: "prefix", Value: options.Prefix, DataType: "string"},
		{Name: "existing_sm_instance_crn", Value: prvOnlySmCRN, DataType: "string"},
		{Name: "existing_sm_instance_region", Value: prvOnlySmRegion, DataType: "string"},
	}

	err := options.RunSchematicTest()
	assert.Nil(t, err, "This should not have errored")
}
