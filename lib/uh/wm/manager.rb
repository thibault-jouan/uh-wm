module Uh
  module WM
    class Manager
      INPUT_MASK  = Events::SUBSTRUCTURE_REDIRECT_MASK
      ROOT_MASK   = Events::PROPERTY_CHANGE_MASK |
                    Events::SUBSTRUCTURE_REDIRECT_MASK |
                    Events::SUBSTRUCTURE_NOTIFY_MASK |
                    Events::STRUCTURE_NOTIFY_MASK
      DEFAULT_GEO = Geo.new(0, 0, 320, 240).freeze

      attr_reader :modifier, :modifier_ignore, :display, :clients

      def initialize events, mod, mod_ignore = [], display = Display.new
        @events           = events
        @modifier         = mod
        @modifier_ignore  = mod_ignore
        @display          = display
        @clients          = []
      end

      def to_io
        IO.new(@display.fileno)
      end

      def connect
        @events.emit :connecting, args: @display
        @display.open
        check_other_wm!
        Display.on_error { |*args| handle_error *args }
        @display.sync false
        @events.emit :connected, args: @display
        @display.root.mask = ROOT_MASK
      end

      def disconnect
        @display.close
        @events.emit :disconnected
      end

      def flush
        @display.flush
      end

      def grab_key keysym, mod = nil
        mod_mask = KEY_MODIFIERS[@modifier]
        mod_mask |= KEY_MODIFIERS[mod] if mod
        combine_modifier_masks(@modifier_ignore) do |ignore_mask|
          @display.grab_key keysym.to_s, mod_mask | ignore_mask
        end
      end

      def configure window
        if client = client_for(window)
          client.configure
        else
          geo = @events.emit :configure, args: window
          window.configure_event geo ? geo : DEFAULT_GEO
        end
      end

      def map window
        return if window.override_redirect? || client_for(window)
        @clients << client = Client.new(window)
        @events.emit :manage, args: client
        @display.listen_events window, Events::PROPERTY_CHANGE_MASK
      end

      def unmap window
        return unless client = client_for(window)
        if client.unmap_count > 0
          client.unmap_count -= 1
        else
          unmanage client
        end
      end

      def destroy window
        return unless client = client_for(window)
        unmanage client
      end

      def update_properties window
        return unless client = client_for(window)
        client.update_window_properties
        @events.emit :change, args: client
      end

      def handle_next_event
        handle @display.next_event
      end

      def handle_pending_events
        handle_next_event while @display.pending?
      end

      def handle event
        @events.emit :xevent, args: event
        return unless respond_to? handler = "handle_#{event.type}".to_sym, true
        send handler, event
      end


      private

      def handle_error *args
        @events.emit :xerror, args: args
      end

      def handle_key_press event
        case remove_modifier_masks event.modifier_mask, @modifier_ignore
        when KEY_MODIFIERS[@modifier]
          @events.emit :key, event.key.to_sym
        when KEY_MODIFIERS[@modifier] | KEY_MODIFIERS[:shift]
          @events.emit :key, event.key.to_sym, :shift
        end
      end

      def handle_configure_request event
        configure event.window
      end

      def handle_destroy_notify event
        destroy event.window
      end

      def handle_expose event
        @events.emit :expose, args: event.window
      end

      def handle_map_request event
        map event.window
      end

      def handle_property_notify event
        update_properties event.window
      end

      def handle_unmap_notify event
        unmap event.window
      end

      def client_for window
        @clients.find { |e| e.window == window }
      end

      def unmanage client
        @clients.delete client
        @events.emit :unmanage, args: client
      end

      def check_other_wm!
        Display.on_error { fail OtherWMRunningError }
        @display.listen_events INPUT_MASK
        @display.sync false
      end

      def combine_modifier_masks mods
        yield 0
        (1..mods.size).flat_map { |n| mods.combination(n).to_a }.each do |cmb|
          yield cmb.map { |e| KEY_MODIFIERS[e] }.inject &:|
        end
      end

      def remove_modifier_masks mask, remove
        return mask unless remove.any?
        mask & ~(@modifier_ignore
          .map    { |e| KEY_MODIFIERS[e] }
          .inject &:|
        )
      end
    end
  end
end
