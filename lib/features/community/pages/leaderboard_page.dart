import 'package:flutter/material.dart';
import 'package:fitquest/shared/repositories/leaderboard_repository.dart';
import 'package:fitquest/core/di/injection.dart';
import 'package:fitquest/shared/models/leaderboard_entry.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _leaderboardRepository = getIt<LeaderboardRepository>();
  List<LeaderboardEntry> _entries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final entries = await _leaderboardRepository.getLeaderboard();
      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load leaderboard')),
        );
      }
    }
  }

  Color _getRankColor(int rank) {
    if (rank == 1) return Colors.amber;
    if (rank == 2) return const Color(0xFF9E9E9E); // Better contrast grey
    if (rank == 3) return Colors.brown;
    return Colors.blue;
  }

  IconData _getRankIcon(int rank) {
    if (rank == 1) return Icons.emoji_events;
    if (rank == 2) return Icons.workspace_premium;
    if (rank == 3) return Icons.military_tech;
    return Icons.person;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadLeaderboard,
              child: ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, index) {
                  final entry = _entries[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _getRankColor(entry.rank),
                        child: Icon(
                          _getRankIcon(entry.rank),
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        entry.displayName,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Level ${entry.currentLevel} • ${entry.currentStreak} day streak'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${entry.totalXp} XP',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '#${entry.rank}',
                            style: TextStyle(
                              color: const Color(0xFF616161), // Darker grey for better contrast
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}

