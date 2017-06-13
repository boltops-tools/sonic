module Sonic
  class UI
    class << self
      @@mute = false
      def mute
        @@mute
      end
      def mute=(v)
        @@mute=v
      end
      def say(msg='')
        puts msg unless mute
      end
      def error(msg='')
        say "ERROR: #{msg}".colorize(:red)
      end
    end
  end
end
