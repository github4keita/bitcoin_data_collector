defmodule Bitflyer.Ticker do
  defstruct [
    :best_ask,
    :best_ask_size,
    :best_bid,
    :best_bid_size,
    :ltp,
    :product_code,
    :tick_id,
    :timestamp,
    :total_ask_depth,
    :total_bid_depth,
    :volume,
    :volume_by_product
  ]
end
