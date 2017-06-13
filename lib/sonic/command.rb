require 'thor'

module Sonic
  class Command < Thor
    class << self
      def dispatch(m, args, options, config)
        # Allow calling for help via:
        #   sonic command help
        #   sonic command -h
        #   sonic command --help
        #   sonic command -D
        #
        # as well thor's normal way:
        #
        #   sonic help command
        help_flags = Thor::HELP_MAPPINGS + ["help"]
        if args.length > 1 && !(args & help_flags).empty?
          args -= help_flags
          args.insert(-2, "help")
        end
        super
      end
    end
  end
end