class Types::Filter::Common::DateTime < Types::BaseScalar

  def self.coerce_input(ms_since_epoch, ctx)
    Time.at(ms_since_epoch.to_f / 1000)
  end

  def self.coerce_result(value, ctx)
    value.utc.to_i * 1000
  end
end
