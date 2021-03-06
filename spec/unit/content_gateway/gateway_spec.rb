require "spec_helper"

describe ContentGateway::Gateway do
  subject do
    ContentGateway::Gateway.new("label", config, url_generator)
  end

  let(:gateway_without_url_generator) do
    ContentGateway::Gateway.new("label", config)
  end

  let(:config) { double("config", proxy: nil) }
  let(:headers) { { "Content-Type" => "application/json" } }
  let(:payload) { { "data" => 1234 } }
  let(:url_generator) { double("URL generator") }
  let(:path) { "/api/test.json" }
  let(:fullpath) { "www.teste.com/api/test.json" }
  let(:cache) { double("cache", use?: false, status: "HIT") }
  let(:request) { double("request", execute: data) }
  let(:data) { '{"param": "value"}' }
  let(:cache_params) { { timeout: 2, expires_in: 30, stale_expires_in: 180, skip_cache: false, ssl_certificate: {ssl_client_cert: "test", ssl_client_key: "test"} } }
  let(:connection_params) {{ timeout: 2, ssl_certificate: {ssl_client_cert: "test", ssl_client_key: "test"} }}

  before do
    allow(File).to receive(:read).with("test").and_return("cert_content")
    allow(OpenSSL::X509::Certificate).to receive(:new).with("cert_content").and_return("cert")
    allow(OpenSSL::PKey::RSA).to receive(:new).with("cert_content").and_return("key")
  end

  describe "Without url generator" do
    describe "GET method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:get, fullpath, headers, nil, config.proxy, cache_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, fullpath, :get, cache_params).
        and_return(cache)
      end

      describe "#get" do
        it "should do a get request passing the correct parameters" do
          expect(gateway_without_url_generator.get(fullpath, cache_params.merge(headers: headers))).to eql data
        end
      end
    end

    describe "POST method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:post, fullpath, nil, payload, config.proxy, connection_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, fullpath, :post, connection_params).
        and_return(cache)
      end

      describe "#post" do
        it "should do a post request passing the correct parameters" do
          expect(gateway_without_url_generator.post(fullpath, cache_params.merge(payload: payload))).to eql data
        end
      end
    end

    describe "PUT method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:put, fullpath, nil, payload, config.proxy, connection_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, fullpath, :put, connection_params).
        and_return(cache)
      end

      describe "#put" do
        it "should do a put request passing the correct parameters" do
          expect(gateway_without_url_generator.put(fullpath, cache_params.merge(payload: payload))).to eql data
        end
      end
    end

    describe "DELETE method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:delete, fullpath, nil, nil, config.proxy, connection_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, fullpath, :delete, connection_params).
        and_return(cache)
      end

      describe "#delete" do
        it "should do a delete request passing the correct parameters" do
          expect(gateway_without_url_generator.delete(fullpath, cache_params.merge(payload: payload))).to eql data
        end
      end
    end
  end

  describe "With url generator" do
    before do
      expect(url_generator).to receive(:generate).with(path, {}).and_return("url")
    end

    describe "GET method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:get, "url", headers, nil, config.proxy, cache_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, "url", :get, cache_params).
        and_return(cache)
      end

      describe "#get" do
        it "should do a get request passing the correct parameters" do
          expect(subject.get(path, cache_params.merge(headers: headers))).to eql data
        end
      end

      describe "#get_json" do
        it "should parse the response as JSON" do
          expect(subject.get_json(path, cache_params.merge(headers: headers))).to eql JSON.parse(data)
        end
      end
    end

    describe "POST method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:post, "url", nil, payload, config.proxy, connection_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, "url", :post, connection_params).
        and_return(cache)
      end

      describe "#post" do
        it "should do a post request passing the correct parameters" do
          expect(subject.post(path, cache_params.merge(payload: payload))).to eql data
        end
      end

      describe "#post_json" do
        it "should parse the response as JSON" do
          expect(subject.post_json(path, cache_params.merge(payload: payload))).to eql JSON.parse(data)
        end
      end
    end

    describe "PUT method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:put, "url", nil, payload, config.proxy, connection_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, "url", :put, connection_params).
        and_return(cache)
      end

      describe "#put" do
        it "should do a put request passing the correct parameters" do
          expect(subject.put(path, cache_params.merge(payload: payload))).to eql data
        end
      end

      describe "#put_json" do
        it "should parse the response as JSON" do
          expect(subject.put_json(path, cache_params.merge(payload: payload))).to eql JSON.parse(data)
        end
      end
    end

    describe "DELETE method" do
      before do
        expect(ContentGateway::Request).
        to receive(:new).
        with(:delete, "url", nil, nil, config.proxy, connection_params).
        and_return(request)
        expect(ContentGateway::Cache).
        to receive(:new).
        with(config, "url", :delete, connection_params).
        and_return(cache)
      end

      describe "#delete" do
        it "should do a delete request passing the correct parameters" do
          expect(subject.delete(path, cache_params.merge(payload: payload))).to eql data
        end
      end

      describe "#delete_json" do
        it "should parse the response as JSON" do
          expect(subject.delete_json(path, cache_params.merge(payload: payload))).to eql JSON.parse(data)
        end
      end
    end
  end
end
