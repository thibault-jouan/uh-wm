Feature: input events selection

  Scenario: selects the appropriate input event mask for a window manager
    Given uhwm is running
    Then the input event mask must include StructureNotifyMask
    And the input event mask must include SubstructureNotifyMask
    And the input event mask must include SubstructureRedirectMask
    And the input event mask must include PropertyChangeMask
