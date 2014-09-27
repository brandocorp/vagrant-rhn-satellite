module VagrantPlugins
  module RhnSatellite
    class Config < Vagrant.plugin('2', :config)

      # The Satellite Server's hostname
      #
      # @return [String]
      attr_accessor :hostname

      # The name of the satellite bootstrap script
      #
      # @return [String]
      attr_accessor :script

      # An array of activation keys to register with
      #
      # @return [Array<String>]
      attr_accessor :activation_keys

      # An optional organizational CA Certificiate
      #
      # @return [String]
      attr_accessor :org_ca_cert

      # An optional organizational GPG Key
      #
      # @return [String]
      attr_accessor :org_gpg_key

      # Use SSL
      #
      # @return [Boolean]
      attr_accessor :ssl

      # RHN Username for hosted RHN interactions
      #
      # @return [String]
      attr_accessor :username

      # RHN Password for hosted RHN interactions
      #
      # @return [String]
      attr_accessor :password

      def initialize
        @hostname = UNSET_VALUE
        @script = UNSET_VALUE
        @activation_keys = []
        @org_ca_cert = UNSET_VALUE
        @org_gpg_key = UNSET_VALUE
        @ssl = UNSET_VALUE
        @username = UNSET_VALUE
        @password = UNSET_VALUE
      end

      def activation_keys=(value)
        @activation_keys = value.is_a?(Array) ? value : [value]
      end

      def validate!(machine)
        errors = _detected_errors
        errors << I18n.t('vagrant_rhn_satellite.config.script_required') if @script.nil?
        { "satellite" => errors }
      end

      def finalize!
        @hostname = nil if @hostname == UNSET_VALUE
        @activation_keys = nil if @activation_keys.empty?
        @org_ca_cert = nil if @org_ca_cert == UNSET_VALUE
        @org_gpg_key = nil if @org_gpg_key == UNSET_VALUE
        @ssl = true if @ssl == UNSET_VALUE
      end

    end
  end
end
