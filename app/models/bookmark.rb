class Bookmark < ApplicationRecord
  belongs_to :user

  validates :title, presence: true
  validates :url, presence: true
  validate :url_must_be_http_or_https

  private

  def url_must_be_http_or_https
    uri = URI.parse(url.to_s)
    return if uri.is_a?(URI::HTTP) && uri.host.present?

    errors.add(:url, "must be a valid http(s) URL")
  rescue URI::InvalidURIError
    errors.add(:url, "must be a valid http(s) URL")
  end
end
