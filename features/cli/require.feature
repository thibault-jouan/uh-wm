Feature: require CLI option

  Scenario: requires a ruby feature
    Given a file named my_feature.rb with:
      """
      puts 'testing_feature_load'
      """
    When I run uhwm with option -r ./my_feature.rb
    Then the output must contain "testing_feature_load"
