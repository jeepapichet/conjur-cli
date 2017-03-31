Feature: Create a group
  
  Scenario: Create a new group
    When I successfully run `conjur group create $ns/ops`
    Then the JSON response should have the following:
      | id         |
      | ownerid    |
      | resource_identifier |
      | roleid     |
    And the JSON response at "id" should include "/ops"

  # Role members includes the policy, does not include the admin user.
  @possum-wip    
  Scenario: Add a user to the group and show the list of members
    Given I successfully run `conjur user create bob@$ns`
    And I successfully run `conjur group create $ns/ops`
    And I successfully run `conjur group members add $ns/ops user:bob@$ns`
    When I successfully run `conjur group members list $ns/ops`
    Then the JSON response should have 2 entries
    And the JSON response at "0" should include "admin@"
    And the JSON response at "1" should include "bob@"
      