defmodule Membrane.Agora.TokenGenerator do
  @moduledoc false
  def get_token(certificate, app_id, channel, user_id) do
    version = "006"
    salt = :rand.uniform(99_999_999)

    expiration_date =
      DateTime.utc_now() |> DateTime.add(1, :day) |> DateTime.to_unix()

    to_sign = <<salt::little-integer-size(32), expiration_date::little-integer-size(32), 0, 0>>

    signature_payload = <<app_id::binary, channel::binary, user_id::binary, to_sign::binary>>
    signature = :crypto.mac(:hmac, :sha256, certificate, signature_payload)

    payload =
      <<
        byte_size(signature)::little-integer-size(16),
        signature::binary,
        :erlang.crc32(channel)::little-integer-size(32),
        :erlang.crc32(user_id)::little-integer-size(32),
        byte_size(to_sign)::little-integer-size(16),
        to_sign::binary
      >>

    <<version::binary, app_id::binary, Base.encode64(payload)::binary>>
  end
end
