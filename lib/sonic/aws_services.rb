module Sonic
  module AwsServices
    def ecs
      @ecs ||= Aws::ECS::Client.new
    end

    def ec2
      @ec2 ||= Aws::EC2::Client.new
    end
  end
end
