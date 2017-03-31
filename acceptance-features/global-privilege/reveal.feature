@possum-wip
Feature: 'reveal' can be used to see all records

  Background:
    Given I successfully run `conjur variable create $ns/secret secretvalue`
    And I create a new user named "alice@$ns"
    
  Scenario: The secret value is not accessible without 'reveal' privilege
    Given I login as "alice@$ns"
    When I run `conjur variable show $ns/secret`
    Then the exit status should be 1

  Scenario: 'reveal' can't be used without permission
    Given I login as "alice@$ns"
    When I run `conjur reveal variable show $ns/secret`
    Then the exit status should be 1
  
  Scenario: The secret value is accessible with 'reveal' privilege
    Given I successfully run `conjur resource permit '!:!:conjur' user:alice@$ns reveal`
    And I login as "alice@$ns"
    Then I successfully run `conjur reveal variable show $ns/secret`
