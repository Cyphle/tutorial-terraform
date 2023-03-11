package test

import (
	"fmt"
	"github.com/gruntwork-io/terratest/modules/http-helper"
	"github.com/gruntwork-io/terratest/modules/terraform"
	"testing"
)

func TestAlbExample(t *testing.T) {
	opts := &terraform.Options{
		TerraformDir: "../examples/networking/alb",
	}

	// Clean up after test. defer makes sure that function is called however function exits
	defer terraform.Destroy(t, opts)

	// Deploy the example
	terraform.InitAndDeploy(t, opts)

	// Get the URl of the ALB
	albDnsName := terraform.OutputRequired(t, opts, "alb_dns_name")
	url := fmt.Sprintf("http://%s", albDnsName)

	// Test that the ALB's default action is working and returns a 404
	expectedStatus := 404
	expectedBody := "404: page not found"
	maxRetries := 10
	timeBetweenRetries := 10 * time.Second

	http_helper.HttpGetWithRetry(
		t,
		url,
		nil,
		expectedStatus,
		expectedBody,
		maxRetries,
		timeBetweenRetries
	)
}
