class WastePredictor:

    def predict(
        self,
        quantity,
        shelf_life_days,
        expected_demand
    ):

        surplus = max(
            quantity - expected_demand,
            0
        )

        if shelf_life_days <= 2:
            risk = "HIGH"
        elif shelf_life_days <= 4:
            risk = "MEDIUM"
        else:
            risk = "LOW"

        return {
            "surplus_quantity": surplus,
            "waste_risk": risk
        }