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

      @@noop = false
      def noop=(v)
        @@noop=v
      end

      def say(msg='')
        msg = "NOOP: #{msg}" if @@noop
        puts msg unless mute
      end
      def error(msg='')
        say "ERROR: #{msg}".colorize(:red)
      end
      def warn(msg='')
        say "WARN: #{msg}".colorize(:yellow)
      end
    end
  end
end
