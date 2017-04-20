Feature: Create a Role

  Scenario: Create an abstract role
    When I run `conjur role create job:$ns/chef`
    Then the exit status should be 0
    And the output should contain "Created role"

  # When the new role is created in the policy, there is no role grant to
  # the policy role. The reason is that ownership is triggered by the resource
  # conterpart of the role, which we aren't creating here.
  @possum-wip
  Scenario: Role owner has the new role listed in its memberships
    When I run `conjur role create --json job:$ns/chef`
    Then the exit status should be 0
    And I keep the JSON response at "roleid" as "ROLEID"
    And I run `conjur role memberships policy:$ns`
    And the JSON should include %{ROLEID}
