require 'pdfbucket/version'

require 'openssl'
require 'digest/sha2'
require 'base64'
require 'uri'

# Main module
module PDFBucket
  #DEFAULT_HOST = 'api.pdfbucket.io'
  DEFAULT_HOST = '8ed3489f.ngrok.io'
  ORIENTATIONS = {
    portrait: 'portrait',
    landscape: 'landscape'
  }
  PAGE_SIZES = {
    a4: 'A4',
    letter: 'Letter'
  }
  POSITIONS = {
    header: 'header',
    footer: 'footer'
  }
  ALIGNMENTS = {
    left:   'left',
    center: 'center',
    right:  'right'
  }

  # Main class
  class PDFBucket
    attr_reader :api_key, :api_secret, :api_host

    def initialize(
      api_key:    ENV['PDF_BUCKET_API_KEY'],
      api_secret: ENV['PDF_BUCKET_API_SECRET'],
      api_host:   ENV['PDF_BUCKET_API_HOST'])

      fail 'bucket api_key is required' if api_key.nil? || api_key.strip.empty?
      fail 'bucket api_secret is required' if api_secret.nil? || api_secret.strip.empty?

      @api_host   = api_host || DEFAULT_HOST
      @api_key    = api_key
      @api_secret = api_secret
    end

    def generate_url(url, orientation, page_size, margin, zoom, expires_in = 0, pagination = false, position = nil, alignment = nil, cache = nil)
      encrypted_uri = encrypt(api_secret, url)

      params = {
        orientation:    ORIENTATIONS[orientation],
        page_size:      PAGE_SIZES[page_size],
        margin:         margin,
        zoom:           zoom,
        expires_in:     expires_in,
        api_key:        api_key,
        encrypted_uri:  encrypted_uri
      }
      set_optional_params(params, pagination, position, alignment, cache)
      build_uri(params)
    end

    def generate_plain_url(url, orientation, page_size, margin, zoom, expires_in = 0, pagination = false, position = nil, alignment = nil, cache = nil)
      signature = sign(api_secret, api_key, url, orientation, page_size, margin, zoom, pagination, position, alignment)

      params = {
        orientation:  ORIENTATIONS[orientation],
        page_size:    PAGE_SIZES[page_size],
        margin:       margin,
        zoom:         zoom,
        expires_in:   expires_in,
        api_key:      api_key,
        uri:          url,
        signature:    signature
      }
      set_optional_params(params, pagination, position, alignment, cache)
      build_uri(params)
    end

    private
    def sign(api_secret, api_key, url, orientation, page_size, margin, zoom, pagination, position, alignment)
      params = [
        api_key,
        url,
        ORIENTATIONS[orientation],
        PAGE_SIZES[page_size],
        pagination.to_s,
        POSITIONS[position],
        ALIGNMENTS[alignment],
        margin,
        zoom
      ].join(',')

      Digest::SHA1.hexdigest("#{params}#{api_secret}")
    end

    def encrypt(key, content)
      binary_key = Base64.decode64(key)
      alg = 'AES-256-CTR'
      iv = OpenSSL::Cipher::Cipher.new(alg).random_iv
      aes_ctr = OpenSSL::Cipher::Cipher.new(alg)
      aes_ctr.encrypt
      aes_ctr.key = binary_key
      aes_ctr.iv = iv

      cipher = aes_ctr.update(content)
      cipher << aes_ctr.final

      Base64.strict_encode64(iv + cipher)
    end

    def build_uri(params)
      URI::HTTPS.build(
        host: api_host,
        path: '/api/convert',
        query: URI.encode_www_form(params)).to_s
    end

    def set_optional_params(params, pagination, position, alignment, cache)
      params.merge!(cache: cache) if cache
      if pagination
        params.merge!({
          pagination: pagination,
          position:   POSITIONS[position],
          alignment:  ALIGNMENTS[alignment]
        })
      end
    end
  end
end
