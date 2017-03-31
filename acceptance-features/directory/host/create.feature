Feature: Create a Host

  # Possum doesn't support automatic id generation
  @possum-wip
  Scenario: Create a host with automatically generated ID
    When I successfully run `conjur host create`
    And the JSON should have "api_key" 
    And the JSON should have "id"

  # Host must be created within a policy
  @possum-wip
  Scenario: Create a host with explicit ID
    When I successfully run `conjur host create $ns.myhost.example.com`
    And the JSON should have "api_key" 
    And I keep the JSON response at "id" as "ID" 
    Then the output should contain "myhost.example.com"
  
  # Possum doesn't support automatic id generation
  @possum-wip
  Scenario: Create a host owned by the security_admin group
    When I successfully run `conjur host create --as-group $ns/security_admin`
    And I keep the JSON response at "ownerid" as "OWNERID"
    Then the output should contain "/security_admin"
  
  # Host must be created within a policy
  @possum-wip
  Scenario: Host does not belong to any layers by default
    When I successfully run `conjur host create $ns.myhost.example.com`
    And I successfully run `conjur host layers $ns.myhost.example.com`
    And the JSON should be []  
