class ShelfLifePredictor:

    def predict(
        self,
        temperature,
        humidity=60,
        quality_score=80
    ):

        base_days = 7

        if temperature > 30:
            base_days -= 2

        if temperature > 35:
            base_days -= 1

        if humidity > 80:
            base_days -= 1

        if quality_score < 50:
            base_days -= 2

        return max(base_days, 1)