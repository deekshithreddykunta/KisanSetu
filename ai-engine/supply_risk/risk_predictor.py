class SupplyRiskPredictor:

    def predict(
        self,
        temperature,
        rainfall,
        demand,
        supply
    ):

        risk = 0

        if temperature > 40:
            risk += 30

        if rainfall < 20:
            risk += 20

        if demand > supply * 1.5:
            risk += 30

        if supply == 0:
            risk += 20

        if risk >= 70:
            level = "HIGH"
        elif risk >= 40:
            level = "MEDIUM"
        else:
            level = "LOW"

        return {
            "risk_score": min(risk, 100),
            "risk_level": level
        }