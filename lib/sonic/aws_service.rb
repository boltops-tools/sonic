require "aws-sdk-ec2"
require "aws-sdk-ecs"
require "aws-sdk-ssm"
require "aws-sdk-s3"

module Sonic
  module AwsService
    def ecs
      @ecs ||= Aws::ECS::Client.new
    end

    def ec2
      @ec2 ||= Aws::EC2::Client.new
    end

    def ec2_resource
      @ec2_resource ||= Aws::EC2::Resource.new
    end

    def ssm
      @ssm ||= Aws::SSM::Client.new
    end

    def s3
      @s3 ||= Aws::S3::Client.new
    end
  end
end
