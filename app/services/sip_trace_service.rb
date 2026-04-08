class SipTraceService
  HOMER_API_URL = ENV.fetch("HOMER_API_URL", "").freeze
  HOMER_USERNAME = ENV.fetch("HOMER_USERNAME", "admin").freeze
  HOMER_PASSWORD = ENV.fetch("HOMER_PASSWORD", "sipcapture").freeze

  # Fetch the SIP trace for a phone call from Homer's internal API.
  # Returns a JSON string of SIP messages, or nil if Homer is not configured
  # or the trace is not available.
  def self.fetch_for_call(phone_call)
    return nil if HOMER_API_URL.blank?

    # FreeSWITCH uses the call's external_id (UUID) as the SIP Call-ID
    call_id = phone_call.external_id
    return nil if call_id.blank?

    cdr = phone_call.call_data_record
    return nil if cdr.blank?

    fetch_from_homer(call_id, cdr)
  rescue StandardError => e
    Rails.logger.warn("[SipTraceService] Failed to fetch SIP trace: #{e.message}")
    nil
  end

  private

  def self.connection
    @connection ||= Faraday.new(url: HOMER_API_URL) do |f|
      f.request :json
      f.response :json
      f.options.timeout = 5
      f.options.open_timeout = 2
    end
  end

  def self.authenticate
    @token_cache ||= {}
    # Reuse token for 10 minutes
    if @token_cache[:token] && @token_cache[:expires_at] > Time.current
      return @token_cache[:token]
    end

    response = connection.post("/api/v3/auth") do |req|
      req.body = { username: HOMER_USERNAME, password: HOMER_PASSWORD }
    end

    return nil unless response.success?

    token = response.body.dig("token")
    @token_cache = { token: token, expires_at: 10.minutes.from_now }
    token
  end

  def self.fetch_from_homer(call_id, cdr)
    token = authenticate
    return nil if token.blank?

    # Homer 7 API: search by Call-ID within the call's time window
    response = connection.post("/api/v3/search/call/message") do |req|
      req.headers["Authorization"] = "Bearer #{token}"
      req.body = {
        param: {
          search: {
            "1_call" => {
              callid: [call_id],
              protocol_header: { "raw" => "" }
            }
          },
          location: {},
          transaction: {
            call: true,
            registration: false,
            rest: false
          }
        },
        timestamp: {
          from: (cdr.start_time - 30.seconds).to_i * 1000,
          to: (cdr.end_time + 30.seconds).to_i * 1000
        }
      }
    end

    return nil unless response.success?

    messages = response.body.dig("data", "messages") || []
    messages.map do |msg|
      {
        timestamp: msg["micro_ts"],
        method: msg["method"],
        from: msg["from_user"],
        to: msg["to_user"],
        source_ip: msg["src_ip"],
        destination_ip: msg["dst_ip"],
        raw: msg["raw"]
      }
    end.to_json
  end
end
