class QualityAnalyzer:

    def analyze(
        self,
        freshness,
        appearance,
        damage
    ):

        score = (
            freshness * 0.4
            + appearance * 0.3
            + (100 - damage) * 0.3
        )

        score = round(score, 2)

        if score >= 80:
            grade = "A"
        elif score >= 60:
            grade = "B"
        else:
            grade = "C"

        return {
            "quality_score": score,
            "grade": grade
        }