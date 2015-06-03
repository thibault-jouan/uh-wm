module Factories
  def build_geo x = 0, y = 0, width = 640, height = 480
    Uh::Geo.new(x, y, width, height)
  end

  def build_client window = mock_window
    Uh::WM::Client.new(window)
  end

  def mock_event type = :xany, **options
    double 'event', type: type, **options
  end

  def mock_event_key_press key, modifier_mask
    mock_event :key_press,
      key:            key,
      modifier_mask:  modifier_mask
  end

  def mock_window override_redirect: false, icccm_wm_protocols: []
    instance_spy Uh::Window, 'window',
      to_s:               'wid',
      name:               'wname',
      wclass:             'wclass',
      override_redirect?: override_redirect,
      icccm_wm_protocols: icccm_wm_protocols
  end
end
