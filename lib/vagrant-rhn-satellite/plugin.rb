I18n.load_path << File.expand_path("../../../locales/en.yml", __FILE__)

module VagrantPlugins
  module RhnSatellite
    class Plugin < Vagrant.plugin('2')
      name 'vagrant-rhn-satellite'

      description <<-TEXT
        This plugin registers a guest vm with the specified satellite server
      TEXT

      action_hook(:register, Plugin::ALL_ACTIONS) do |hook|
        require_relative 'action/satellite_registration'
        hook.after(Vagrant::Action::Builtin::Provision, Action::SatelliteRegistration)
      end

      action_hook(:deregister, Plugin::ALL_ACTIONS) do |hook|
        require_relative 'action/satellite_deregistration'
        hook.after(Vagrant::Action::Builtin::DestroyConfirm, Action::SatelliteDeregistration)
      end

      config(:satellite) do
        require_relative 'config'
        Config
      end

    end
  end
end
