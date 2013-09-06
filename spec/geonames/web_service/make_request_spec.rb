require 'spec_helper'

describe Geonames::WebService do
  context "with base_urls" do
    before do
      Geonames.base_urls = ["http://lol1.com", "http://lol2.com"]
      Geonames.timeout = 1
    end

    it "queries each URL in turn if there's a timeout" do
      Geonames::WebService.should_receive(:make_one_request).with("http://lol1.com", "pif/paf?a=a&lang=en", open_timeout: Geonames.timeout, read_timeout: Geonames.timeout).and_call_original
      Geonames::WebService.should_receive(:make_one_request).with("http://lol2.com", "pif/paf?a=a&lang=en", open_timeout: Geonames.timeout, read_timeout: Geonames.timeout).and_call_original
      Net::HTTP.any_instance.stub(:request) { Net::HTTP.any_instance.unstub(:request); raise Net::ReadTimeout }
      Geonames::WebService.make_request("pif/paf?a=a") rescue FakeWeb::NetConnectNotAllowedError
    end

    it "raises a Timeout::Error if all domains fail" do
      Net::HTTP.any_instance.stub(:request) { raise Net::ReadTimeout }
      expect {
        Geonames::WebService.make_request("pif/paf?a=a")
        }.to raise_exception(Timeout::Error)
    end
  end

  context "without base_urls" do
    before do
      Geonames.base_url = "http://lol1.com"
    end

    it "queries the URL provided" do
      Geonames::WebService.should_receive(:make_one_request).with("http://lol1.com", "pif/paf?a=a&lang=en", open_timeout: Geonames.timeout, read_timeout: Geonames.timeout)
      Geonames::WebService.make_request("pif/paf?a=a")
    end
  end
end
