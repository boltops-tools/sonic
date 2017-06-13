require 'spec_helper'

# to run specs with what's remembered from vcr
#   $ rake
#
# to run specs with new fresh data from aws api calls
#   $ rake clean:vcr ; time rake
describe Sonic::CLI do
  before(:all) do
    @args = "--cluster default --noop"
  end

  describe "sonic" do
    it "ssh should print out ssh command to be ran" do
      out = execute("bin/sonic ssh my-service #{@args}")
      expect(out).to include("Running: ssh")
    end
  end
end
