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
        say "ERROR: #{msg}".color(:red)
      end
      def warn(msg='')
        say "WARN: #{msg}".color(:yellow)
      end
    end
  end
end
