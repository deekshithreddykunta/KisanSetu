class FraudDetector:

    def detect(
        self,
        farmer_price,
        market_price
    ):

        if market_price <= 0:
            return {
                "suspicious": False,
                "reason": "Invalid market price"
            }

        difference = abs(
            farmer_price - market_price
        )

        percentage = (
            difference / market_price
        ) * 100

        suspicious = percentage > 40

        return {
            "suspicious": suspicious,
            "difference_percentage": round(
                percentage,
                2
            )
        }