# frozen_string_literal: true

require_relative '../controller'

module MarsBase10
  class SocialLounge < Controller
    def active_resource
      '~winter-paches/top-shelf-6391'
    end

    def active_subject(pane:)
      pane.current_subject_index
    end

    def fetch_channel_messages
      if @pane_1 == self.viewport.active_pane
        @pane_1.clear
        @pane_1.subject.title = "Nodes of #{self.active_resource}"
        @pane_1.subject.contents = self.ship.fetch_node_list(resource: self.active_resource)
      end
      nil
    end

    def load_history
      return 0 unless @pane_1 == self.viewport.active_pane
      new_content = self.ship.fetch_older_nodes(resource: self.active_resource, node: self.active_node)
      @pane_1.subject.prepend_content(ary: new_content)
      new_content.length
    end

    #
    # Called by a pane in this controller for bubbling a key press up
    #
    def send(key:)
      case key
      when 'g'    # (G)raph View
        unless @pane_1.active?
          self.viewport.activate pane: @pane_1
          self.action_bar.remove_actions([:g])
        end
      when 'i'    # (I)nspect
        begin
          self.viewport.activate pane: @pane_3
          self.action_bar.add_action({'g': 'Group List'})
        end
      when 'X'
        self.manager.swap_controller
      end
    end

    def show
      self.fetch_channel_messages
    end

    private

    def wire_up_panes
      @panes = []
      # Pane #1 is the Chat Channel Reader. It takes up the entire Viewport. (For now?)
      @pane_1 = self.viewport.add_pane height_pct: 1.0, width_pct: 1.0
      @pane_1.view(subject: self.ship.empty_node_list)
    end
  end
end   # Module Mars::Base::10
