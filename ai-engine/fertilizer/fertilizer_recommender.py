class FertilizerRecommender:

    def recommend(
        self,
        nitrogen,
        phosphorus,
        potassium
    ):

        recommendations = []

        if nitrogen < 40:
            recommendations.append(
                "Consider nitrogen-rich fertilizer"
            )

        if phosphorus < 30:
            recommendations.append(
                "Consider phosphorus-rich fertilizer"
            )

        if potassium < 30:
            recommendations.append(
                "Consider potassium-rich fertilizer"
            )

        if not recommendations:
            recommendations.append(
                "NPK levels appear adequate"
            )

        return recommendations