package command

import (
	"fmt"
	"strings"

	"github.com/hashicorp/nomad/api"
	"github.com/posener/complete"
)

type ACLBootstrapCommand struct {
	Meta
}

func (c *ACLBootstrapCommand) Help() string {
	helpText := `
Usage: nomad acl bootstrap [options]

  Bootstrap is used to bootstrap the ACL system and get an initial token.

General Options:

  ` + generalOptionsUsage(usageOptsDefault|usageOptsNoNamespace) + `

Bootstrap Options:

  -json
    Output the bootstrap response in JSON format.

  -t
    Format and display the bootstrap response using a Go template.

  -bootstrap-token
    Provide an operator generated management token.

`
	return strings.TrimSpace(helpText)
}

func (c *ACLBootstrapCommand) AutocompleteFlags() complete.Flags {
	return mergeAutocompleteFlags(c.Meta.AutocompleteFlags(FlagSetClient),
		complete.Flags{
			"-json":            complete.PredictNothing,
			"-t":               complete.PredictAnything,
			"-bootstrap-token": complete.PredictAnything,
		})
}

func (c *ACLBootstrapCommand) AutocompleteArgs() complete.Predictor {
	return complete.PredictNothing
}

func (c *ACLBootstrapCommand) Synopsis() string {
	return "Bootstrap the ACL system for initial token"
}

func (c *ACLBootstrapCommand) Name() string { return "acl bootstrap" }

func (c *ACLBootstrapCommand) Run(args []string) int {

	var (
		json           bool
		tmpl           string
		bootstraptoken string
	)

	flags := c.Meta.FlagSet(c.Name(), FlagSetClient)
	flags.Usage = func() { c.Ui.Output(c.Help()) }
	flags.BoolVar(&json, "json", false, "")
	flags.StringVar(&tmpl, "t", "", "")
	flags.StringVar(&bootstraptoken, "bootstrap-token", "", "")
	if err := flags.Parse(args); err != nil {
		return 1
	}

	// Check that we got no arguments
	args = flags.Args()
	if l := len(args); l != 0 {
		c.Ui.Error("This command takes no arguments")
		c.Ui.Error(commandErrorText(c))
		return 1
	}

	// Get the HTTP client
	client, err := c.Meta.Client()
	if err != nil {
		c.Ui.Error(fmt.Sprintf("Error initializing client: %s", err))
		return 1
	}

	btkn := &api.BootstrapRequest{BootstrapSecret: bootstraptoken}

	// Get the bootstrap token
	token, _, err := client.ACLTokens().BootstrapOpts(btkn, nil)
	if err != nil {
		c.Ui.Error(fmt.Sprintf("Error bootstrapping: %s", err))
		return 1
	}

	if json || len(tmpl) > 0 {
		out, err := Format(json, tmpl, token)
		if err != nil {
			c.Ui.Error(err.Error())
			return 1
		}

		c.Ui.Output(out)
		return 0
	}

	// Format the output
	c.Ui.Output(formatKVACLToken(token))
	return 0
}

// formatKVPolicy returns a K/V formatted policy
func formatKVPolicy(policy *api.ACLPolicy) string {
	output := []string{
		fmt.Sprintf("Name|%s", policy.Name),
		fmt.Sprintf("Description|%s", policy.Description),
		fmt.Sprintf("Rules|%s", policy.Rules),
		fmt.Sprintf("CreateIndex|%v", policy.CreateIndex),
		fmt.Sprintf("ModifyIndex|%v", policy.ModifyIndex),
	}
	return formatKV(output)
}

// formatKVACLToken returns a K/V formatted ACL token
func formatKVACLToken(token *api.ACLToken) string {
	// Add the fixed preamble
	output := []string{
		fmt.Sprintf("Accessor ID|%s", token.AccessorID),
		fmt.Sprintf("Secret ID|%s", token.SecretID),
		fmt.Sprintf("Name|%s", token.Name),
		fmt.Sprintf("Type|%s", token.Type),
		fmt.Sprintf("Global|%v", token.Global),
	}

	// Special case the policy output
	if token.Type == "management" {
		output = append(output, "Policies|n/a")
	} else {
		output = append(output, fmt.Sprintf("Policies|%v", token.Policies))
	}

	// Add the generic output
	output = append(output,
		fmt.Sprintf("Create Time|%v", token.CreateTime),
		fmt.Sprintf("Create Index|%d", token.CreateIndex),
		fmt.Sprintf("Modify Index|%d", token.ModifyIndex),
	)
	return formatKV(output)
}
