# frozen_string_literal: true

require "roda"
require "digest"

$LOAD_PATH.unshift File.dirname(__FILE__)
require "dependencies"

# The server app entrypoint. We boot it from config.ru.
# See http://roda.jeremyevans.net/ for information about the Roda framework.
class Server < Roda
  plugin :caching
  plugin :public, gzip: true, default_mime: "text/html"
  plugin :head
  plugin :request_headers
  plugin :sessions, secret: ENV["SESSION_SECRET"], key: ENV["SESSION_KEY"]
  plugin :render, escape: true
  plugin :partials

  HEADERS = if %w[production staging].include?(ENV["RACK_ENV"])
              max_age = ENV["STRICT_TRANSPORT_SECURITY_MAX_AGE"]
              # rubocop:disable Metrics/LineLength
              { "Strict-Transport-Security" => "max-age=#{max_age}; includeSubDomains" }
              # rubocop:enable Metrics/LineLength
            else
              {}
            end
  plugin :default_headers, HEADERS

  TITLE_LOOKUP = {
    "/" => "Home",
    "/about" => "About",
    "/contact" => "Contact",
    "/faq" => "FAQ"
  }.freeze

  def layout_locals(request)
    LAYOUT_LOCALS.merge(current_path: request.path,
                        title: title(request.path))
  end

  def title(current_path)
    TITLE_LOOKUP[current_path] || "Pauline Bailey"
  end

  route do |r|
    unless r.ssl? || %w[test development].include?(ENV["RACK_ENV"])
      host = r.host
      path = r.fullpath
      location = "https://#{host}#{path}"

      r.on method: %i[get head] do
        r.redirect(location, 302)
      end

      r.on do
        r.redirect(location, 307)
      end
    end

    r.public

    r.root do
      etag = Digest::SHA1.hexdigest(File.mtime("./views/home.erb").to_s)
      r.etag(etag, weak: true)
      view("home", layout_opts: { locals: layout_locals(r) })
    end

    r.is "contact" do
      first_name = r.session["contact_request_first_name"]
      last_name = r.session["contact_request_last_name"]
      email = r.session["contact_request_email"]
      phone = r.session["contact_request_phone"]
      message = r.session["contact_request_message"]
      contact_request_result = r.session["contact_request_result"]

      # capture values to display in the form immediately after submit,
      # clear session if successful so future page visits show an empty form
      clear_session if contact_request_result == "success"

      view("contact",
           layout_opts: { locals: layout_locals(r) },
           locals: CONTACT_PAGE_LOCALS.merge(
             contact_request_result: contact_request_result,
             contact_request_first_name: first_name,
             contact_request_last_name: last_name,
             contact_request_email: email,
             contact_request_phone: phone,
             contact_request_message: message
           ))
    end

    r.is "about" do
      view("about", layout_opts: { locals: layout_locals(r) })
    end

    r.is "faq" do
      view("faq", layout_opts: { locals: layout_locals(r) })
    end
  end
end
