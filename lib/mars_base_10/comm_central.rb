# frozen_string_literal: true
require 'urbit'

require_relative  'controller'
require_relative  'viewport'

module MarsBase10
  class Error < StandardError; end

  class CommCentral
    def initialize(config_filename:)
      @viewport = Viewport.new
      @ship = Urbit.connect(config_file: config_filename)
      @ship.login
      sleep 2  # This is temporary for now, we need a way to know that the subscription callbacks have finished.
      @controller = Controller::GroupRoom.new manager: self, ship_connection: @ship, viewport: @viewport
    end

    def activate
      self.controller.start
    end

    def swap_controller
      self.controller.stop
      if Controller::GroupRoom == self.controller.class
        @controller = Controller::GraphRover.new manager: self, ship_connection: self.ship, viewport: @viewport
      else
        @controller = Controller::GroupRoom.new  manager: self, ship_connection: self.ship, viewport: @viewport
      end
      self.controller.start
    end

    def shutdown
      self.controller.stop
    end

    private

    def controller
      @controller
    end

    def ship
      @ship
    end
  end
end
