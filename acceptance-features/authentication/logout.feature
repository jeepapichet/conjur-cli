Feature: Logout the user

  # expected that command "conjur user create -p alice@ab32dfb681a5225694d5dc49" has exit status of "0", but has "1"
  @possum-wip
  Scenario: Login a new user with a password
    Given I run `conjur user create -p alice@$ns` interactively
    And I type "foobar"
    And I type "foobar"
    And the exit status should be 0
    And I keep the JSON response at "login" as "LOGIN"
    And I run `conjur authn login alice@$ns` interactively
    And I type "foobar"
    And the exit status should be 0
    And I successfully run `conjur authn logout`
    Then the stdout from "conjur authn logout" should contain exactly "Logged out\n"
