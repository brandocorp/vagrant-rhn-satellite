require 'log4r'
require 'shellwords'
require 'vagrant/util/downloader'

module VagrantPlugins
  module RhnSatellite
    module Action
      class SatelliteRegistration

        def initialize(app, env)
          @app = app
          @logger = Log4r::Logger.new("vagrant_rhn_satellite::action::satellite_registration")
          @machine = env[:machine]
        end

        def call(env)
          @app.call(env)

          return unless @machine.config.satellite.enable
          return unless @machine.communicate.ready? && provision_enabled?(env)

          @machine.config.satellite.validate_registration!(@machine)

          if system_registered?
            env[:ui].info I18n.t('vagrant-rhn-satellite.action.register.noop')
          else
            env[:ui].info I18n.t('vagrant-rhn-satellite.action.register.required')
            @register_script = determine_register_script
            fetch_register_script(env)
            register_system(env)
          end
        end

        def determine_register_script
          @machine.config.satellite.script || default_register_script
        end

        def default_register_script
          url = @machine.config.satellite.ssl ? 'https://' : 'http://'
          url << "#{@machine.config.satellite.hostname}/pub/bootstrap/"
          url << ["rhel#{rhel_version}", system_architecture, "dev.sh"].join('-')
          url
        end

        def rhel_version
          version = nil
          @machine.communicate.sudo("cat /etc/redhat-release") do |type, data|
            if [:stderr, :stdout].include?(type)
              version_match = data.match(/Red Hat Enterprise Linux Server release (\d).+/)
              version = version_match.captures[0].strip if version_match
            end
          end
          version
        end

        def system_architecture
          arch = nil
          @machine.communicate.sudo('uname -m') do |type, data|
            arch = data.chomp if type == :stdout
          end
          arch
        end

        def provision_enabled?(env)
          env.fetch(:provision_enabled, true)
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

        def fetch_register_script(env)
          begin
            @tmp_file_path = env[:tmp_path].join("#{Time.now.to_i.to_s}-register.sh")
            url = @register_script
            downloader = Vagrant::Util::Downloader.new(
              url,
              @tmp_file_path,
              {}
            )
            env[:ui].info I18n.t(
              'vagrant-rhn-satellite.download.downloading',
              url: url
            )
            downloader.download!
          rescue Vagrant::Errors::DownloaderInterrupted
            # The downloader was interrupted, so just return, because that
            # means we were interrupted as well.
            env[:ui].info(I18n.t('vagrant-rhn-satellite.download.interrupted'))
            return
          end
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

        def register_system(env)
          @machine.communicate.tap do |guest|
            guest.upload(@tmp_file_path, 'register.sh')
            register = "/bin/bash register.sh 2>&1"
            guest.sudo(register)
          end
          env[:ui].info I18n.t(
            'vagrant-rhn-satellite.action.register.success',
            id: system_id
          )
        end

      end
    end
  end
end
