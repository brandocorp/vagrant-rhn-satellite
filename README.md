# vagrant-rhn-satellite

A vagrant plugin that allows registration with a Red Hat Network Satellite server as part of the provisioning process.

## Installation

Install [Vagrant](http://www.vagrantup.com/downloads) first!

And then execute:

    $ vagrant plugin install vagrant-rhn-satellite

## Usage

Register with your satellite server:

```ruby
Vagrant.configure("2") do |config|
  config.satellite.script = 'https://satellite.example.com/pub/bootstrap/rhel6-x86_64.sh'
end
```

## Contributing

1. Fork it ( https://github.com/brandocorp/vagrant-rhn-satellite/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
