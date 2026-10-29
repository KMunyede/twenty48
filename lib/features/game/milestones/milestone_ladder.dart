class Milestone {
  final int value;
  final String title;
  final String hype;

  const Milestone({
    required this.value,
    required this.title,
    required this.hype,
  });
}

const List<Milestone> milestoneLadder = [
  Milestone(
    value: 1024,
    title: 'Certified Prodigy',
    hype: "You're moving with suspicious confidence. This isn't luck anymore.",
  ),
  Milestone(
    value: 2048,
    title: 'Undisputed Champion',
    hype: 'You beat the classic game. Take a victory lap and stretch your hands.',
  ),
  Milestone(
    value: 4096,
    title: 'Big Brain Specialist',
    hype: 'Normal people stop at 2048. You chose to show off.',
  ),
  Milestone(
    value: 8192,
    title: 'Cold-Blooded Tactician',
    hype: 'Four moves ahead? Try ten. Borderline psychic.',
  ),
  Milestone(
    value: 16384,
    title: 'Board Royalty',
    hype: "The tiles don't just merge anymore, they bow.",
  ),
  Milestone(
    value: 32768,
    title: 'The Untouchable',
    hype: "Mistakes don't happen here. Your thumb is an athlete.",
  ),
  Milestone(
    value: 65536,
    title: 'Mythic Menace',
    hype: "You've bent the board to your will. Remember to blink.",
  ),
  Milestone(
    value: 131072,
    title: 'Walking Legend',
    hype: 'The game is out of answers. Your battery will give up first.',
  ),
];

String? titleForBestTile(int best) {
  if (best < 1024) return null;
  String? result;
  for (final m in milestoneLadder) {
    if (m.value <= best) {
      result = m.title;
    } else {
      break;
    }
  }
  return result;
}

Milestone? nextMilestone(int highestTile) {
  for (final m in milestoneLadder) {
    if (m.value > highestTile) {
      return m;
    }
  }
  return null;
}
