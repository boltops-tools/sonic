require 'spec_helper'

describe Sonic::Execute do
  before(:each) do
    @options = {
      project_root: "spec/fixtures/project",
      filter: "hi-web-stag,hi-clock-stag"
    }
  end

  describe "Sonic#execute" do
    it "should build up options for ssm send command with inline command" do
      execute = Sonic::Execute.new(["uname", "-a"], @options)
      options = execute.build_ssm_options
      expect(options[:instance_ids]).to eq nil
      expect(options[:targets]).to eq [{:key=>"tag:Name", :values=>%w[hi-web-stag hi-clock-stag]}]
      expect(options[:document_name]).to eq "AWS-RunShellScript"
      expect(options[:comment]).to include "sonic "
      expect(options[:parameters]["commands"]).to eq ["uname -a"]
    end

    it "should build up options for ssm send command with file" do
      execute = Sonic::Execute.new(["file://command.txt"], @options)
      options = execute.build_ssm_options
      expect(options[:instance_ids]).to eq nil
      expect(options[:targets]).to eq [{:key=>"tag:Name", :values=>%w[hi-web-stag hi-clock-stag]}]
      expect(options[:document_name]).to eq "AWS-RunShellScript"
      expect(options[:comment]).to include "sonic "
      expect(options[:parameters]["commands"]).to eq([
        '#!/usr/bin/env ruby',
        'puts "hi"'
      ])
    end
  end
end
