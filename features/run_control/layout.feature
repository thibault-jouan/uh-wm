Feature: `layout' run control keyword

  Background:
    Given a file named my_layout.rb with:
      """
      class MyLayout
        def initialize **options
          @options = options
        end

        def register *_
          puts "testing_rc_layout_#{@options.inspect}"
        end
      end
      """

  Scenario: configures a layout class
    Given a run control file with:
      """
      layout MyLayout
      """
    When I start the program with options -r./my_layout
    Then the output will contain "testing_rc_layout_{}"

  Scenario: configures a layout class with options
    Given a run control file with:
      """
      layout MyLayout, foo: :bar
      """
    When I start the program with options -r./my_layout
    Then the output will contain "testing_rc_layout_{:foo=>:bar}"

  Scenario: configures a layout instance
    Given a run control file with:
      """
      layout MyLayout.new
      """
    When I start the program with options -r./my_layout
    Then the output will contain "testing_rc_layout_{}"
