class AddRegisterTransportToSIPTrunks < ActiveRecord::Migration[8.0]
  def change
    add_column :sip_trunks, :register_transport, :string, default: "udp"
  end
end
