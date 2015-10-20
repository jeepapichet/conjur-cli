Feature: Loading a policy can specify the policy's admin

  Background:
    Given I successfully run `conjur group create $ns/admin`
    And a file named "policy.rb" with:
    """
policy 'test-policy-1.0' do
  user "test_user"
end
    """

  Scenario: --as-group works
    When I run `conjur policy load --as-group $ns/admin --collection $ns` interactively
    And I pipe in the file "policy.rb"
    And the exit status should be 0
    When I run `conjur role members policy:$ns/test-policy-1.0`
    Then the output from "conjur role members policy:$ns/test-policy-1.0" should match /group:.*$ns.admin/

  Scenario: --as-role works
    When I run `conjur policy load --as-role group:$ns/admin --collection $ns` interactively
    And I pipe in the file "policy.rb"
    And the exit status should be 0
    When I run `conjur role members policy:$ns/test-policy-1.0`
    Then the output from "conjur role members policy:$ns/test-policy-1.0" should match /group:.*$ns.admin/

  Scenario: --as-group doesn't interfere with policy ownership of other resources
    When I run `conjur policy load --as-group $ns/admin --collection $ns` interactively
    And I pipe in the file "policy.rb"
    And the exit status should be 0
    When I run `conjur resource show user:test_user@$ns-test-policy-1-0 | jsonfield owner`
    Then the output from "conjur resource show user:test_user@$ns-test-policy-1-0 | jsonfield owner" should match /policy:$ns.test-policy-1.0/