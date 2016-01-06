require 'sinatra'
require 'smart_proxy_pulp_plugin/pulp_client'
require 'smart_proxy_pulp_plugin/disk_usage'

module PulpProxy
  class Api < Sinatra::Base
    helpers ::Proxy::Helpers

    get "/status" do
      content_type :json
      begin
        result = PulpClient.get("/api/v2/status/")
        return result.body if result.is_a?(Net::HTTPSuccess)
        log_halt result.code, "Pulp server at #{::PulpProxy::Plugin.settings.pulp_url} returned an error: '#{result.message}'"
      rescue Errno::ECONNREFUSED => e
        log_halt 503, "Pulp server at #{::PulpProxy::Plugin.settings.pulp_url} is not responding"
      rescue SocketError => e
        log_halt 503, "Pulp server '#{URI.parse(::PulpProxy::Plugin.settings.pulp_url.to_s).host}' is unknown"
      end
    end

    get "/status/diskfree" do
      begin
        pulp_disk = DiskUsage.new
        pulp_disk.to_json
      rescue ::Proxy::Error::ConfigurationError
        log_halt 500, "Chould not find df command to evaluate disk space"
      end

    end
  end
end
