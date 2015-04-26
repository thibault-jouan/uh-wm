Feature: `layout' run control keyword

  Background:
    Given a file named my_layout.rb with:
      """
      class MyLayout
        def initialize **options
          puts "testing_rc_layout_#{options.inspect}" if options.any?
        end

        def register *_, **options
          puts "testing_rc_layout_register"
        end
      end
      """

  Scenario: configures a layout class
    Given a run control file with:
      """
      layout MyLayout
      """
    When I run uhwm with options -r./my_layout
    Then the output must contain "testing_rc_layout_register"

  Scenario: configures a layout class with options
    Given a run control file with:
      """
      layout MyLayout, foo: :bar
      """
    When I run uhwm with options -r./my_layout
    Then the output must contain "testing_rc_layout_{:foo=>:bar}"

  Scenario: configures a layout instance
    Given a run control file with:
      """
      layout MyLayout.new
      """
    When I run uhwm with options -r./my_layout
    Then the output must contain "testing_rc_layout_register"
