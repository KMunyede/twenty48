import 'dart:math';

enum GoalBand { band0, band1, band2, band3, reached }

double progressFraction(int highestTile, int target) {
  if (highestTile < 2 || target <= 1) return 0.0;
  final double logHighest = log(highestTile.toDouble()) / ln2;
  final double logTarget = log(target.toDouble()) / ln2;
  if (logTarget <= 0) return 0.0;
  final double fraction = logHighest / logTarget;
  return fraction.clamp(0.0, 1.0);
}

GoalBand band(double fraction) {
  if (fraction >= 1.0) return GoalBand.reached;
  if (fraction < 0.25) return GoalBand.band0;
  if (fraction < 0.5) return GoalBand.band1;
  if (fraction < 0.75) return GoalBand.band2;
  return GoalBand.band3;
}
