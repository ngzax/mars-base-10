# frozen_string_literal: true
require 'curses'

require_relative 'pane'
require_relative 'subject'

module MarsBase10
  class GraphRover
    attr_accessor :panes, :viewport

    def initialize(ship:)
      @ship = ship
      @viewport = Viewport.new

      @panes = []
      @p1 = @viewport.add_pane(subject: (ShipSubject.new ship: ship))

      s = Subject.new title: 'Nodes', contents: ['aaaaaaaaaaaaaaaaaaaaaa', 'bbbbbbbbbbb', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm']
      @p2 = @viewport.add_pane(subject: s, at_col: @p1.last_col + 1)
    end

    def start
      self.viewport.open
    end

    def stop
      self.viewport.close
    end
  end

  class Viewport
    attr_reader   :panes, :win

    CURSOR_INVISIBLE = 0
    CURSOR_VISIBLE   = 1

    def initialize
      Curses.init_screen
      Curses.curs_set(CURSOR_INVISIBLE)
      Curses.noecho   # Do not echo characters typed by the user.
      Curses.start_color if Curses.has_colors?
      @panes = []
    end

    #
    # This is the pane in the Viewport which is actively accepting keyboard input.
    #
    def active_pane
      self.panes.first
    end

    def add_pane(subject:, at_row: self.min_row, at_col: self.min_col)
      p = MarsBase10::Pane.new displaying: subject,
                               at_row:     at_row,
                               at_col:     at_col
      @panes << p
      p
    end

    def close
      Curses.close_screen
    end

    def max_cols
      self.win.maxx
    end

    def max_rows
      self.win.maxy
    end

    def min_col
      0
    end

    def min_row
      0
    end

    def open
      loop do
        self.panes.each do |pane|
          pane.draw
          pane.win.refresh
        end
        self.active_pane.process
      end
    end
  end
end
