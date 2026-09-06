class SupplyChainDigitalTwin:

    def traditional_chain(
        self,
        farmer_price,
        intermediary_count,
        margin_per_intermediary,
        transport_cost
    ):

        consumer_price = (
            farmer_price
            + intermediary_count * margin_per_intermediary
            + transport_cost
        )

        return {
            "farmer_price": farmer_price,
            "intermediaries": intermediary_count,
            "transport_cost": transport_cost,
            "consumer_price": round(
                consumer_price,
                2
            )
        }

    def kisan_setu_chain(
        self,
        farmer_price,
        platform_fee,
        transport_cost
    ):

        consumer_price = (
            farmer_price
            + platform_fee
            + transport_cost
        )

        return {
            "farmer_price": farmer_price,
            "platform_fee": platform_fee,
            "transport_cost": transport_cost,
            "consumer_price": round(
                consumer_price,
                2
            )
        }

    def compare(self, traditional, kisan_setu):

        farmer_gain = (
            kisan_setu["farmer_price"]
            - traditional["farmer_price"]
        )

        consumer_saving = (
            traditional["consumer_price"]
            - kisan_setu["consumer_price"]
        )

        return {
            "farmer_gain": round(farmer_gain, 2),
            "consumer_saving": round(
                consumer_saving,
                2
            )
        }