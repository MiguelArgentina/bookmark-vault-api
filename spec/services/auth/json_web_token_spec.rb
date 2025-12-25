require "rails_helper"

  RSpec.describe Auth::JsonWebToken do
    include ActiveSupport::Testing::TimeHelpers

    describe ".encode_access_token / .decode" do
      it "round-trips payload data for a valid token" do
        token = described_class.encode_access_token(user_id: 123)
        payload = described_class.decode(token)

        expect(payload[:sub]).to eq(123)
        expect(payload[:iat]).to be_present
        expect(payload[:exp]).to be_present
      end

      it "raises DecodeError for expired tokens" do
        travel_to(Time.current) do
          token = described_class.encode_access_token(user_id: 123)
          travel described_class::ACCESS_TOKEN_TTL + 1.second

          expect { described_class.decode(token) }.to raise_error(Auth::JsonWebToken::DecodeError)
        end
      end

      it "raises DecodeError for garbage tokens" do
        expect { described_class.decode("nope") }.to raise_error(Auth::JsonWebToken::DecodeError)
      end
    end
end
