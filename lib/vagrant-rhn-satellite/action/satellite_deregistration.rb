require 'log4r'
require 'shellwords'
require "xmlrpc/client"

module VagrantPlugins
  module RhnSatellite
    module Action
      class SatelliteDeregistration

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant_rhn_satellite::action::satellite_registration")
          @machine = env[:machine]
        end

        def call(env)
          @app.call(env)
          return unless @machine.config.satellite.enable
          return unless @machine.communicate.ready?

          @machine.config.satellite.validate_deregistration!(@machine)

          if system_registered?
            env[:ui].info I18n.t('vagrant-rhn-satellite.action.deregister.required')
            deregister_system(env)
          else
            env[:ui].info I18n.t('vagrant-rhn-satellite.action.deregister.noop')
          end
        end

        def system_registered?
          registered = false
          command = '[[ -f /etc/sysconfig/rhn/systemid ]] && echo true || echo false'
          @machine.communicate.sudo(command) do |type, data|
            if [:stderr, :stdout].include?(type)
              registered = true if data =~ /true/
            end
          end
          registered
        end

        def system_id
          @system_id ||= get_system_id
        end

        def get_system_id
          id = nil
          @machine.communicate.sudo("cat /etc/sysconfig/rhn/systemid") do |type, data|
            if [:stderr, :stdout].include?(type)
              id_match = data.match(/\<string\>ID\-(\d+)\<\/string\>/)
              id = id_match.captures[0].strip if id_match
            end
          end
          id
        end

        def satellite_api_url
          url = @machine.config.satellite.ssl ? 'https://' : 'http://'
          url << @machine.config.satellite.hostname
          url << '/rpc/api'
          url
        end

        def deregister_system(env)
          username = @machine.config.satellite.username
          password = @machine.config.satellite.password
          @client = XMLRPC::Client.new2(satellite_api_url)
          @key = @client.call('auth.login', username, password)
          @client.call('system.deleteSystems', @key, system_id.to_i)
          env[:ui].info I18n.t(
            'vagrant-rhn-satellite.action.deregister.success',
            id: system_id
          )
        rescue XMLRPC::FaultException => e
          env[:ui].error I18n.t(
            'vagrant-rhn-satellite.action.deregister.failed',
            id: system_id
          )
        end
      end
    end
  end
end
