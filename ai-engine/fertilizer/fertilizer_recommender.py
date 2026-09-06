class FertilizerRecommender:

    def recommend(
        self,
        nitrogen: float,
        phosphorus: float,
        potassium: float,
        ph: float
    ) -> dict:

        recommendations = []

        if nitrogen < 50:
            recommendations.append(
                "Nitrogen-rich fertilizer"
            )

        if phosphorus < 30:
            recommendations.append(
                "Phosphorus-rich fertilizer"
            )

        if potassium < 30:
            recommendations.append(
                "Potassium-rich fertilizer"
            )

        if not recommendations:
            recommendations.append(
                "Balanced fertilizer"
            )

        return {
            "nitrogen": nitrogen,
            "phosphorus": phosphorus,
            "potassium": potassium,
            "ph": ph,
            "recommendations": recommendations
        }
