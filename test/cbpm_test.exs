defmodule CBPMTest do
  use ExUnit.Case

  alias CBPM

  test "generate a pdf" do
    report =
      CBPM.render(%{
        customer_name: "AGFA Mortsel",
        lines:
          Enum.map(1..35, fn _ ->
            %{
              date: ~D[2019-01-01],
              tw: "340",
              laadplaats: "test location",
              ref: "test reference_1",
              number: "202003612",
              forfait: 412.00,
              wu: 12.50,
              cl: 0.0,
              diverse: 100.0,
              totaal: 823.0,
              totaal_no_wu: 823.0,
              cmr: 182_076_712,
              pickup_start: ~N[2019-01-01 00:00:00],
              pickup_stop: ~N[2019-01-01 00:00:00],
              dropoff_start: ~N[2019-01-01 00:00:00],
              dropoff_stop: ~N[2019-01-01 00:00:00],
              pickup_hours: 0,
              pickup_total: 0.0,
              wait_pickup: 1.0,
              dropoff_hours: 0,
              dropoff_total: 0.0,
              wait_dropoff: 2.0,
              wait_both: 3.0,
              waithour_fee: 40.0,
              waithours: 0,
              waithours_total: 0.0
            }
          end)
      })

    File.mkdir_p("tmp")
    File.write("tmp/cbpm.pdf", report)
  end
end
