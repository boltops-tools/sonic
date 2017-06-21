require 'spec_helper'

# to run specs with what's remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe Sonic::CLI do
  before(:all) do
    @args = "--project-root spec/fixtures/project --noop"
  end

  describe "sonic" do
    it "ssh should print out ssh command to be ran" do
      out = execute("bin/sonic ssh my-service #{@args} --cluster default")
      expect(out).to include("=> ssh")
    end

    it "execute should print that command has been sent" do
      out = execute("bin/sonic execute #{@args} 1,2,3 uptime")
      expect(out).to include("Command sent")
    end

    it "list should list running instances" do
      out = execute("bin/sonic list #{@args} 1,2,3 --header")
      expect(out).to include("Instance Id")
    end
  end
end
