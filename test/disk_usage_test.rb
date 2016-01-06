require 'test_helper'
require 'rack/test'

require 'smart_proxy_pulp_plugin/pulp_plugin'
require 'smart_proxy_pulp_plugin/disk_usage'

class DiskUsageTest < Test::Unit::TestCase
  def test_has_path_should_be_true
    disk_test = ::PulpProxy::DiskUsage.new(:path => ::Sinatra::Application.settings.root)
    assert_equal(::Sinatra::Application.settings.root, disk_test.path)
  end

  def test_has_stat_should_be_true
    disk_test = ::PulpProxy::DiskUsage.new(:path => ::Sinatra::Application.settings.root)
    assert_not_nil(disk_test.stat)
    assert(disk_test.stat.is_a?(Hash))
  end

  def test_should_return_valid_json
    disk_test = ::PulpProxy::DiskUsage.new(:path => ::Sinatra::Application.settings.root)
    data = disk_test.data
    assert_equal([:filesystem, :"1g-blocks", :used, :available, :"use%", :mounted, :path, :size], data.keys)
    json = disk_test.to_json
    assert_nothing_raised JSON::ParserError do
      JSON.parse(json)
    end
  end
end
