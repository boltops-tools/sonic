module Sonic
  # Processes the sonic ssh options
  module Ssh::CliOptions
    def keys_option
      keys = @options[:keys] || ''
      keys.split(',').map! {|x| ["-i", x.sub(/^~/,ENV['HOME'])] }.flatten
    end
  end
end
