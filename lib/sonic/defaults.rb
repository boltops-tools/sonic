module Sonic
  # To include this module must have this in initialize:
  #
  # def initialize(optiions, ...)
  #   @options = options
  #   ...
  # end
  #
  # So @options must be set
  module Defaults
    # user: 123456789.dkr.ecr.us-east-1.amazonaws.com/sonic
    # service_cluster:
    #   default: prod-lo
    #   hi-web-prod: prod-hi
    #   hi-clock-prod: prod-lo
    #   hi-worker-prod: prod-lo
    #
    # Assumes that @service is set in the class that the Defaults module is included in.
    def default_cluster
      service_cluster = settings.data["service_cluster"]
      service_cluster[@service] || service_cluster["default"]
    end

    def default_user
      settings.data["user"] || "ec2-user"
    end

    def settings
      @settings ||= Settings.new(@options[:project_root])
    end
  end
end
